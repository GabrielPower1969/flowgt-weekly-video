# FLOWGT · 每周最佳视频

每周挑一个我认为最值得学员花时间的视频，把里面的观点提炼成一份**可回放的 HTML 报告**：
左侧常驻目录，最有价值的结论放在最前面，正文里每一个时间戳都是一个播放按钮——
点一下，右下角的播放器就跳到原话那一秒，画面和声音一起对上。

**为什么要这么做：** 大部分"视频笔记"的问题是你无法验证。
把播放按钮做进报告里，读者可以随时跳回原片核对我有没有转述歪——
观点是我的，证据是原作者的，两者一直分得清清楚楚。

---

## 期号索引

**在线阅读（发给学员用这个）：** https://gabrielpower1969.github.io/flowgt-weekly-video/

| 期 | 日期 | 主题 | 主角 | 报告 |
|---|---|---|---|---|
| 02 | 2026-09-04 | 刷 LeetCode：先改观念，再谈刷法 | 土妹（湾区程序员） | [在线读](https://gabrielpower1969.github.io/flowgt-weekly-video/2026/2026-09-04_tumei-leetcode/) · 原片 [前](https://youtu.be/UhmhM6CJ5bs) [后](https://youtu.be/d6XqH991bB8) |
| 01 | 2026-08-28 | AI 时代找工作的难度，远超你想象 | Ethan（Jobright 联创 / CTO） | [在线读](https://gabrielpower1969.github.io/flowgt-weekly-video/2026/2026-08-28_ethan-jobright/) · [原片](https://youtu.be/BR3hN7InkmY) |

> GitHub 仓库页里点 `.html` 只会看到源码，**要发给别人请用上面的 Pages 链接。**

---

## 视频放在哪

每一期的视频**下到本期目录的 `media/video.mp4`**，报告的播放器第一优先就播它——
秒开、有声、离线可用、seek 精确。第 01 期是 `2026/2026-08-28_ethan-jobright/media/video.mp4`
（1080p H.264 + AAC，877MB）。

**为什么不直接用 YouTube 在线播放器：** 双击打开 HTML 时页面 origin 是 `"null"`，
YouTube 会拒绝 JS 播放器并显示**「视频播放器配置错误」**——这是它的策略，绕不过去。
所以在线播放只作降级路径（页面用 http 打开时用 JS API，file:// 时用普通 iframe 重载跳转）。

**画质取 H.264 最高档（≤1080p），不是无脑 `bestvideo`：**
YouTube 上 1440p/2160p 只有 VP9/AV1 编码，Safari 和 QuickTime 可能直接播不了；
H.264 + AAC 的 mp4 是唯一到处都能播的组合。真要 4K：`FMT='bestvideo+bestaudio' ./fetch.sh …`，
但请自己确认播放器能解 AV1。

媒体文件被 `.gitignore` 挡住，不进仓库——clone 下来的人跑一次 `fetch.sh` 就有了。

---

## 报告长什么样

- **00 节** 就是全部结论（卡片式，3 分钟读完）
- 每条结论旁边 `▶ 06:26` 可点，直接跳原话
- 带时间戳 = 嘉宾说的；青色块 = 我的编者按。**两者永远视觉可分辨**
- 最后一节固定写「来源与口径」：哪些是一手原文、哪些是嘉宾自述的单一来源数据、
  哪些是我的推断，以及**我最没把握的两三条**
- 深色 / 浅色主题，手机上也能读

---

## 自己做一期

仓库里的 [`skills/weekly-video`](skills/weekly-video/) 就是做这件事的完整 skill，
在 Claude Code 里直接用：

```bash
# 1) 抓元信息 + 官方字幕 + 视频本体(H.264 最高档),顺手切成便于通读的时间戳块
skills/weekly-video/scripts/fetch.sh "https://youtu.be/XXXX" "2026/2026-09-04_主角-主题"

# 2) 通读 blocks.txt,按 SKILL.md 的流程提炼观点、写报告

# 3) 发布前自检:时间戳是否自洽/超出片长、目录锚点、漏替换的占位符
python3 skills/weekly-video/scripts/check_report.py 2026/2026-09-04_主角-主题/index.html \
                                                    2026/2026-09-04_主角-主题/transcript.srt
```

依赖：`yt-dlp`（`python3 -m pip install -U yt-dlp`）。
没有官方字幕时会回落到本地 `mlx-whisper` 转写——**录音永远不上传任何外部服务**。

目录结构：

```
skills/weekly-video/
├── SKILL.md                     # 工作流 + 硬规矩(观点优先、时间戳必挂、引述要短…)
├── assets/report_shell.html     # 报告骨架:CSS + 播放器 + 主题切换 + {{占位符}}
├── references/components.md     # 组件速查(卡片/引述/编者按/表格/配色)
└── scripts/
    ├── fetch.sh                 # 抓字幕(优先官方字幕,回落 whisper)
    ├── srt_to_blocks.py         # SRT → 20 秒一块的时间戳文本,便于一次通读
    └── check_report.py          # 发布前自检
```

---

## 许可

代码与 skill 采用 MIT（见 [LICENSE](LICENSE)）。报告正文是编者的评注与提炼，引述部分版权归原视频作者。

## 版权

报告只做**观点提炼与评注**，引述保持在最小必要长度，视频版权归原作者所有。
每份报告都在页脚给出原片链接，**请去看完整原片并给作者点赞**。
完整转写（`transcript.srt`）和视频（`media/video.mp4`）只留在本地供核对，不进版本库。
