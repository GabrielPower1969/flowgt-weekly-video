#!/usr/bin/env python3
"""发布前自检:报告里的播放按钮、目录锚点、模板占位符有没有毛病。

用法:
    python3 check_report.py 2026/2026-08-28_xxx/index.html [transcript.srt]

检查项:
  1. 每个 <button class="pb" data-t="秒">mm:ss</button> 的秒数和显示文本对不对得上
     —— 这是最容易手滑的地方,错了用户点了就跳错位置
  2. data-t 是否超出视频时长(给了 SRT 才检查)
  3. 目录里的 href="#x" 是否都有对应的 <section id="x">,反过来也查
  4. 有没有漏替换的 {{PLACEHOLDER}}
退出码非 0 表示有问题。
"""
import re
import sys

PB = re.compile(r'class="pb"\s+data-t="(\d+(?:\.\d+)?)"\s*>\s*(\d+):(\d\d)\s*<')


def srt_duration(path):
    ts = re.findall(r"(\d\d):(\d\d):(\d\d),\d+\s*-->", open(path, encoding="utf-8-sig").read())
    if not ts:
        return None
    h, m, s = ts[-1]
    return int(h) * 3600 + int(m) * 60 + int(s)


def main():
    if len(sys.argv) < 2:
        sys.exit(__doc__)
    html = open(sys.argv[1], encoding="utf-8").read()
    dur = srt_duration(sys.argv[2]) if len(sys.argv) > 2 else None
    bad = []

    buttons = PB.findall(html)
    for sec, mm, ss in buttons:
        want = int(mm) * 60 + int(ss)
        if abs(float(sec) - want) > 0.5:
            bad.append(f"时间戳对不上: data-t={sec} 但显示 {mm}:{ss}(应为 {want})")
        if dur and float(sec) > dur + 5:
            bad.append(f"时间戳超出视频时长: {mm}:{ss} > {dur // 60}:{dur % 60:02d}")

    anchors = set(re.findall(r'<section id="([\w-]+)"', html))
    links = set(re.findall(r'href="#([\w-]+)"', html))
    for a in links - anchors:
        if a not in ("top",):
            bad.append(f"目录链到了不存在的小节: #{a}")
    for a in anchors - links:
        bad.append(f"小节没有出现在目录里: #{a}")

    for ph in sorted(set(re.findall(r"\{\{[A-Z_]+\}\}", html))):
        bad.append(f"占位符没替换: {ph}")

    print(f"播放按钮 {len(buttons)} 个 · 小节 {len(anchors)} 个" + (f" · 视频 {dur // 60} 分钟" if dur else ""))
    if bad:
        print("\n❌ 有问题:")
        for b in bad:
            print("  -", b)
        sys.exit(1)
    print("✅ 自检通过")


if __name__ == "__main__":
    main()
