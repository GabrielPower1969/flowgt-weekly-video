#!/usr/bin/env bash
# ==============================================================================
# merge.sh —— 把多个视频合并成一条,给"一期报告涵盖多个原片"用
#
# 用法:
#   ./merge.sh <输出目录> <URL1> <URL2> [URL3 ...]
#
# 产出:
#   <输出目录>/media/video.mp4   合并后的视频(报告播放器播这个)
#   <输出目录>/parts.json        分段清单,直接填进报告的 FGT_PARTS
#   <输出目录>/meta.txt          每一段的标题/时长/videoId
#
# 关键点:
#   · 优先 stream copy 无损拼接;各段编码参数不一致时才回退到重编码
#   · parts.json 里的 start 是该段在**合并后时间轴**上的起点(秒)
#     报告里所有 data-t 都用合并后时间轴;没有本地文件时,播放器靠这张表
#     把「合并后第 N 秒」换算回「哪个原片的第几秒」
#   · 合并后**先合并再转写**,这样字幕时间戳天然就是合并时间轴,不用做偏移换算
# ==============================================================================
set -euo pipefail

OUT="${1:?用法: ./merge.sh <输出目录> <URL1> <URL2> [...]}"; shift
[ "$#" -ge 2 ] || { echo "❌ 至少给两个视频 URL"; exit 1; }
mkdir -p "$OUT/media" "$OUT/parts"

YTDLP="${YTDLP:-yt-dlp}"
command -v "$YTDLP" >/dev/null 2>&1 || { echo "❌ 找不到 yt-dlp"; exit 1; }
FMT="${FMT:-bestvideo[vcodec^=avc1][height<=1080]+bestaudio[ext=m4a]/best[ext=mp4]}"

: > "$OUT/parts/list.txt"; : > "$OUT/meta.txt"
n=0; start=0; parts=""
for url in "$@"; do
  n=$((n+1))
  echo "▸ [$n/$#] 下载 $url"
  "$YTDLP" -f "$FMT" --merge-output-format mp4 -o "$OUT/parts/p$n.%(ext)s" "$url" >/dev/null
  f="$OUT/parts/p$n.mp4"
  d=$(ffprobe -v error -show_entries format=duration -of csv=p=0 "$f")
  id=$("$YTDLP" --skip-download --print "%(id)s" "$url" 2>/dev/null | tail -1)
  t=$("$YTDLP" --skip-download --print "%(title)s" "$url" 2>/dev/null | tail -1)
  printf "file '%s'\n" "$(cd "$(dirname "$f")" && pwd)/$(basename "$f")" >> "$OUT/parts/list.txt"
  printf "part%d\tid=%s\tstart=%s\tdur=%s\t%s\n" "$n" "$id" "$start" "$d" "$t" >> "$OUT/meta.txt"
  parts="$parts  {id:'$id', start:$start, title:'$(echo "$t" | sed "s/'/\\\\'/g")'},\n"
  start=$(python3 -c "print(round($start + $d, 1))")
done

echo "▸ 拼接(先试 stream copy,不重编码) …"
if ! ffmpeg -v error -f concat -safe 0 -i "$OUT/parts/list.txt" -c copy \
        -movflags +faststart "$OUT/media/video.mp4" -y 2>/dev/null; then
  echo "  ⚠ 各段参数不一致,回退到重编码(慢,但保证能播)"
  ffmpeg -v error -f concat -safe 0 -i "$OUT/parts/list.txt" \
     -c:v libx264 -crf 18 -preset medium -c:a aac -b:a 128k \
     -movflags +faststart "$OUT/media/video.mp4" -y
fi

printf "[\n$parts]\n" | sed '$!N;s/,\n]/\n]/' > "$OUT/parts.json"
got=$(ffprobe -v error -show_entries format=duration -of csv=p=0 "$OUT/media/video.mp4")
echo
echo "✅ 合并完成:$OUT/media/video.mp4"
echo "   合并后时长 = $got 秒(应等于各段之和 = $start)"
echo "   分段清单在 $OUT/parts.json —— 填进报告的 FGT_PARTS"
echo
echo "⚠ 下一步:对**合并后的文件**做转写,不要分别转写再拼时间戳。"
echo "   然后 rm -rf $OUT/parts (中间产物不留)"
