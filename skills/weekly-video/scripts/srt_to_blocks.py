#!/usr/bin/env python3
"""把 SRT 合并成 ~N 秒一块的时间戳文本,便于一次通读、定位观点。

用法:
    python3 srt_to_blocks.py transcript.srt [每块秒数,默认20] > blocks.txt

输出每行形如:
    [06:26] 自从疫情之后 白领的job post数量直线下跌 到现在其实是过去10年的历史最低点

为什么不直接读 SRT:一小时的视频 SRT 通常 2000+ 条 cue、150KB+,
按 20 秒合并后只剩 200 行左右,信息一点没丢,读起来还能看出话题边界。
写报告时把行首的 [mm:ss] 换算成秒,就是播放按钮的 data-t。
"""
import re
import sys

TS = re.compile(r"(\d\d):(\d\d):(\d\d),(\d+)\s*-->")


def parse(path):
    text = open(path, encoding="utf-8-sig").read().strip()
    for block in re.split(r"\n\s*\n", text):
        lines = block.strip().split("\n")
        if len(lines) < 2:
            continue
        m = TS.search(block)
        if not m:
            continue
        sec = int(m.group(1)) * 3600 + int(m.group(2)) * 60 + int(m.group(3))
        body = " ".join(l.strip() for l in lines[2:]).strip()
        if body:
            yield sec, body


def main():
    if len(sys.argv) < 2:
        sys.exit(__doc__)
    span = int(sys.argv[2]) if len(sys.argv) > 2 else 20

    start, buf = None, []
    out = []
    for sec, body in parse(sys.argv[1]):
        if start is None:
            start = sec
        buf.append(body)
        if sec - start >= span:
            out.append((start, " ".join(buf)))
            start, buf = None, []
    if buf:
        out.append((start, " ".join(buf)))

    for sec, body in out:
        print(f"[{sec // 60:02d}:{sec % 60:02d}] {body}")


if __name__ == "__main__":
    main()
