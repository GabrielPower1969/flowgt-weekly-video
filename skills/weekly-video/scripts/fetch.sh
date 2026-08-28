#!/usr/bin/env bash
# ==============================================================================
# fetch.sh —— 抓一个视频的元信息 + 字幕，落到本期目录
#
# 用法:
#   ./fetch.sh <视频URL> <输出目录>
#
# 干了三件事:
#   1. 打印标题/频道/时长/发布日期/videoId  → 写进 meta.txt
#   2. 优先下官方字幕(中文→英文);拿不到才回落到本地 whisper 转写
#   3. 下视频本体到 media/video.mp4 —— 报告的播放器**以本地文件为第一选择**
#
# 为什么一定要本地文件:YouTube 的 JS 播放器在 file:// 下 origin 是 "null",
# YouTube 直接拒绝并显示「视频播放器配置错误」。双击打开报告是最常见的用法,
# 所以不能依赖在线播放器。本地 mp4 秒开、有声、离线可用、seek 精确。
#
# 画质:取 **H.264(avc1) 最高档**,不是无脑 bestvideo。
# 1440p/2160p 在 YouTube 上只有 VP9/AV1 编码,Safari 和 QuickTime 可能直接播不了;
# H.264 + AAC 的 mp4 是唯一到处都能播的组合。要 4K 请自己改 FMT。
#
# 依赖: yt-dlp。没有就先装:
#   python3 -m pip install -U yt-dlp
# 回落转写依赖 mlx-whisper(本地跑,录音永不上传外部服务)
# ==============================================================================
set -euo pipefail

URL="${1:?用法: ./fetch.sh <视频URL> <输出目录>}"
OUT="${2:?用法: ./fetch.sh <视频URL> <输出目录>}"
mkdir -p "$OUT"

YTDLP="${YTDLP:-yt-dlp}"
command -v "$YTDLP" >/dev/null 2>&1 || {
  echo "❌ 找不到 yt-dlp。装一下: python3 -m pip install -U yt-dlp"; exit 1; }

echo "▸ 抓元信息 …"
"$YTDLP" --skip-download \
  --print "title=%(title)s"      --print "uploader=%(uploader)s" \
  --print "duration=%(duration)s" --print "upload_date=%(upload_date)s" \
  --print "id=%(id)s"            --print "url=%(webpage_url)s" \
  "$URL" | tee "$OUT/meta.txt"

echo
echo "▸ 找官方字幕 …"
LANGS=$("$YTDLP" --list-subs "$URL" 2>/dev/null | awk '/^(zh|zh-Hans|zh-CN|en)[[:space:]]/{print $1}' | head -3 || true)

if [ -n "$LANGS" ]; then
  PICK=$(echo "$LANGS" | head -1)
  echo "  用官方字幕: $PICK"
  "$YTDLP" --skip-download --write-sub --sub-lang "$PICK" \
           --convert-subs srt -o "$OUT/transcript.%(ext)s" "$URL" >/dev/null
  # yt-dlp 会写成 transcript.<lang>.srt,统一改名
  mv "$OUT"/transcript.*.srt "$OUT/transcript.srt" 2>/dev/null || true
else
  echo "  ⚠ 没有官方字幕 → 回落到本地 whisper 转写(会下载音轨)"
  "$YTDLP" -x --audio-format mp3 -o "$OUT/audio.%(ext)s" "$URL"
  WH="${MLX_WHISPER:-mlx_whisper}"
  command -v "$WH" >/dev/null 2>&1 || { echo "❌ 找不到 mlx_whisper,请先建转写环境"; exit 1; }
  "$WH" "$OUT/audio.mp3" --output-dir "$OUT" --output-format srt
  mv "$OUT/audio.srt" "$OUT/transcript.srt"
  echo "  ⚠ 记得检查 whisper 幻觉(整段重复同一句)。有就加 --condition-on-previous-text False 重跑。"
fi

echo
echo "▸ 下视频本体(H.264 最高档,给报告的本地播放器用) …"
mkdir -p "$OUT/media"
FMT="${FMT:-bestvideo[vcodec^=avc1][height<=1080]+bestaudio[ext=m4a]/best[ext=mp4]}"
"$YTDLP" -f "$FMT" --merge-output-format mp4 -o "$OUT/media/video.%(ext)s" "$URL"
ls -lh "$OUT/media/video.mp4"

echo
echo "▸ 切成便于通读的时间戳块 …"
python3 "$(dirname "$0")/srt_to_blocks.py" "$OUT/transcript.srt" > "$OUT/blocks.txt"
wc -l < "$OUT/blocks.txt" | xargs echo "  blocks.txt 行数:"

echo
echo "✅ 完成。下一步:通读 $OUT/blocks.txt,按 SKILL.md 的流程提炼观点。"
echo "   媒体在 $OUT/media/video.mp4(已被 .gitignore 挡住,不会进仓库)"
