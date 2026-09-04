# 组件速查

`assets/report_shell.html` 里已经定义好的 class，直接抄。所有颜色都走 CSS 变量，
深色/浅色两套主题自动切换——**不要在正文里写死颜色**。

## 配色口径

| 变量 | 深色 | 用途 |
|---|---|---|
| `--brand` | 琥珀 `#f3a626` | 主色：播放按钮、序号、强调 |
| `--brand2` | 青 `#4fd1c5` | 次级：编者按、正面结论 |
| `--brand3` | 珊瑚 `#ff7a59` | 警示：难度、坏消息 |

---

## 播放按钮

```html
<button class="pb" data-t="386">06:26</button>
```
`data-t` = 秒（整数），按钮文字 = `mm:ss`。两者必须一致，`check_report.py` 会查。
超过 60 分钟的视频照样写 `76:16`，不要写成 `1:16:16`——保持两段式，脚本按 `mm:ss` 解析。

## 顶部结论卡片（00 节专用）

```html
<div class="takes">
  <div class="take">
    <div class="n">01 · 分母变了</div>
    <h4>一句话结论，别超过 20 个字</h4>
    <p>3 行以内的解释。为什么这条重要、它推翻了什么常识。</p>
    <div class="foot"><button class="pb" data-t="386">06:26</button></div>
  </div>
</div>
```

## 数字四宫格

```html
<div class="stats">
  <div class="stat"><div class="num bad">10 年最低</div>
    <div class="cap">说明文字<br><button class="pb" data-t="386">06:26</button></div></div>
</div>
```
`.num` 可加 `bad`（珊瑚）/ `warn`（琥珀）/ `good`（青）。

## 引述

```html
<div class="quote">
  一两句原话，不要贴大段。
  <span class="who">Ethan · <button class="pb" data-t="430">07:10</button></span>
</div>
```
`.quote.t2` 青色边（正面/方法论），`.quote.t3` 珊瑚边（残酷现实）。
英文视频时，中文译文在上，英文原话用 `<span class="en">` 附在下面。

## 编者按（**必须和原话视觉区分**）

```html
<div class="editor">
  <div class="tt">编者按 · 一句话小标题</div>
  <p>你的判断。不带时间戳——因为这不是他说的。</p>
</div>
```

## 其他

| class | 用途 |
|---|---|
| `.callout` | 整节的核心主张，一节最多一个 |
| `.note` | 灰色小字提醒 / 免责声明 |
| `ul.chk` | 带方框的清单（信号、检查项） |
| `ol.steps` | 带序号的步骤（行动清单） |
| `.tw > table` | 表格，外层 `.tw` 负责横向滚动，**表格永远不要让页面横滚** |
| `td .tag.hard/.mid/.ok` | 表格里的难度标签 |
| `.qb / .qbi` | 金句索引的两栏行（时间戳 + 句子） |
| `.formula` | 居中的公式块，`<em>` 变量高亮 |

## 分段清单（合并视频用）

```js
var FGT_PARTS = [
  {id:'YouTubeID1', start:0,     title:'第一段'},
  {id:'YouTubeID2', start:642.6, title:'第二段'}
];
```
`start` = 该段在**合并后时间轴**上的起点（秒）。单个视频只写一条 `start:0`。
正文所有 `data-t` 一律用合并后时间轴；播放器在没有本地文件时靠这张表换算回原片。

## 目录

```html
<a href="#market"><span class="n">01</span><span>市场到底有多难</span></a>
<div class="sep"></div>   <!-- 分组横线 -->
```
每个 `href="#x"` 都必须有对应的 `<section id="x">`，反之亦然（脚本会查双向）。
