# localfirst-apps

> **本地优先软件控制台** —— 一个面板管住本机全部本地 AI 资产：
> 一键下载模型与软件包（并行下载 + 断点续传 + SHA256 校验）、统一启停推理服务（CUDA / Vulkan / CPU 后端可切）、集中启动本地应用。
> 启动应用前自动预检依赖服务：未运行的弹框一键拉起，轮询健康检查接口、就绪后才打开应用；
> 不经面板启动的服务也能凭进程识别，状态徽章始终准确。
> 另有系统托盘驻留、在线自更新、中英双语界面。全程离线可用，数据不出本机。

---

## 快速开始

PowerShell 一键安装命令：

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -Command "iwr -Uri 'https://gh-proxy.org/https://raw.githubusercontent.com/ruoyousi/localfirst-apps/master/install-localfirst-apps.ps1' -OutFile '.\install-localfirst-apps.ps1'; .\install-localfirst-apps.ps1"
```

默认安装到指定目录（如 `E:\`），增加参数即可：

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -Command "iwr -Uri 'https://gh-proxy.org/https://raw.githubusercontent.com/ruoyousi/localfirst-apps/master/install-localfirst-apps.ps1' -OutFile '.\install-localfirst-apps.ps1'; .\install-localfirst-apps.ps1 E:\"
```

安装完成后进入安装目录，双击 `localfirst-apps\control-panel.exe` 打开控制面板，按需下载软件包或模型、启停服务。



```bat
REM 1. 双击运行控制面板
control-panel.exe

REM 2. 「模型」页签：点击下载所需模型（并行下载 + 断点续传 + SHA256 校验）
REM 3. 「服务」页签：一键启动语音 / 图像推理服务（默认 http://127.0.0.1:18080）
REM 4. 「应用」页签：启动本地应用
```

没有 GPU 也能用：服务支持 **CUDA / Vulkan / CPU** 三种后端，在面板里可切换。

---

## 特性

| 功能 | 说明 |
| --- | --- |
| **下载资源** | 扫描根目录下所有 `*.download.json` 清单（模型 / 应用 / 运行时三类），并行下载 + 断点续传 + SHA256 校验；已下载的自动标记，支持重新下载 |
| **启动服务** | 扫描 `bin/**/*.server.json`，列出服务与启动参数，一键启停；防重复实例 |
| **启动应用** | 扫描 `bin/**/*.app.json`，统一入口管理本地应用 |
| **全局日志** | 底部固定日志框，子进程输出实时显示 |

所有清单都从磁盘扫描，**控制面板不硬编码任何模型或服务**——新增资源只要放一个 json 清单即可。

---

## 目录结构

```text
localfirst-apps/
├── control-panel.exe          # 统一控制台（双击运行）
├── config.ini                 # 全局配置（[github] 加速代理 GH_PROXY / 镜像仓库 repo、backup-repo）
├── bin/                       # 应用 / 服务 / 运行时（按子目录组织）
│   ├── DataChart/             # 数据可视化工具
│   ├── Lovo/                  # 语音工具箱（含 audio.cpp 服务配置）
│   ├── Perch/                 # 栖心 AI 角色聊天（含 audio.cpp 服务配置）
│   ├── PixelForge/            # 图片 AI 编辑（含推理服务）
│   └── audio.cpp/             # audio.cpp 推理运行时
│       ├── cuda13/            #   CUDA 后端目录
│       └── vulkan/            #   Vulkan 后端目录
├── config/
│   └── audio.cpp/             # 服务启动配置（TTS / ASR / VAD + 模型索引）
├── models/                    # 共享模型仓库（按子目录 + .download.json 清单）
├── releases/                  # 发布包与构建脚本（不入库）
└── logs/                      # 运行日志
```

> 注：`DocMerger` / `FlowWrite` / `OffOCR` / `TableBuddy` / `Transly` 等更多应用正在持续接入。

---

## 应用清单

| 应用 | 说明 | 入口程序 | 标签 |
| --- | --- | --- | --- |
| **DataChart** | 数据可视化工具 | `data-chart.exe` | 免费 · 离线 · Windows |
| **合稿易 DocMerger** | 合稿易 DocMerger —— 本地文档合稿工具（Java 原生 exe，GraalVM Native Image）：多文档合并 / 内容替换 / 一键成稿，支持 Word 文档，全程离线。 | `DocMerger.exe` | 离线 · 创作 · Windows |
| **心流写作 FlowWrite** | 心流写作 FlowWrite —— 本地优先的 AI 小说写作工作台：项目 / 大纲 / 章节 / 角色 / 世界观设定 / 章节版本与记忆库，长篇创作全程离线。 | `flowwrite.exe` | AI · 离线 · 创作 · Windows |
| **个人工作台 FocusOn** | 个人工作台 FocusOn —— 个体工作方法论工具：四象限待办 / 记账 / 日历提醒 / Markdown 笔记 / 习惯打卡 / 番茄专注 / 履历 / 人脉 / 健康记录 / AI 助手，沉淀属于自己的工作节奏，全程离线。 | `FocusOn.exe` | AI · 离线 · 数据 · Windows |
| **Lovo** | 本地语音工具箱 —— 语音合成 / 声音克隆 / 音色设计 / 语音识别（CLI + HTTP API + 桌面 UI 三形态），推理走本地 audio.cpp 服务，全程离线。 | `voice-ui.exe` | AI · 离线 · 创作 · Windows |
| **离线文档解析 OffOCR** | 离线文档解析 OffOCR —— PaddleOCR-VL + PP-DocLayout 视觉模型，扫描件 / PDF 转结构化数据，支持 Markdown / Word 导出，全程不上传。桌面 UI + 本地 HTTP 服务 + CLI 三形态，模型走共享模型仓库。 | `offocr-ui.exe` | AI · 离线 · Windows |
| **Perch** | 栖心 Perch —— 本地优先的 AI 角色聊天桌面助手，支持本地 TTS 朗读与语音输入（需 audio.cpp 服务）。 | `perch.exe` | AI · 离线 · Windows |
| **PixelForge** | 本地优先、可离线的图片 AI 编辑工具：纯 Rust + Candle 复刻 ComfyUI 的 Qwen-Image-Edit 推理流程，在单张消费级显卡上按提示词编辑 / 生成图片，全程不联网、不依赖 Python。 | `pixelforge-ui.exe` | AI · 离线 · 创作 · Windows |
| **纳戒 Storagering** | 本地提示词库管理器 —— 把散落在聊天记录里的 Prompt 收进「纳戒」，随取随用。全文搜索、标签管理、{{变量}} 填充、AI 优化（需 Ollama），数据只存本机。 | `storagering.exe` | AI · 离线 · 创作 · Windows |
| **表伴 TableBuddy** | 本地数据工作台 —— 把 CSV / Excel 导入为结构化数据表，做查询、筛选、增删改，并以「应用 + 静态资源」的方式对外提供数据服务。所有数据留在本机。 | `tablebuddy.exe` | 数据 · 离线 · 创作 · Windows |
| **离线多语言互译 Transly** | 离线多语言互译 Transly —— 基于本地大模型（HY-MT1.5-1.8B GGUF）的多语言翻译工作台：桌面 UI + HTTP 服务 + CLI 三形态，术语库 / 翻译记忆 / 历史记录本地留存，全程离线。 | `transly-ui.exe` | AI · 离线 · Windows |
| **画语 AI-Prompt-Helper** | AI 绘画提示词助手 —— 维度化组装 Midjourney / Stable Diffusion 提示词，内置参考词库与提示词规范，支持本地保存常用提示词。全程离线。 | `ai-image-prompt-helper.exe` | AI · 离线 · 创作 · Windows |

---

## 推理服务清单

| 服务 | 后端 | 说明 |
| --- | --- | --- |
| **Lovo audio.cpp 服务** | CUDA 13.3 | 本地语音推理服务：Qwen3-TTS 语音合成（VoiceDesign）+ Whisper 语音识别 + FireRed VAD 语音活动检测。RTF 约 0.25（3.9× 实时），需系统已安装 CUDA 13 runtime |
| **Perch audio.cpp 服务** | CUDA 13.3 | 同上语音推理链路，供 Perch 聊天助手使用。RTF 约 0.25，需 CUDA 13 runtime |
| **Perch audio.cpp 服务** | Vulkan 便携版 | Vulkan 后端：免 CUDA runtime，约 60 MB 体积，支持所有 GPU 品牌。速度略慢（RTF 约 0.30）。适合没有 CUDA 环境的机器 |
| **PixelForge 推理服务** | CUDA 13 + 16GB 显存 | 本地 GPU 推理服务：把 Qwen-Image-Edit 推理流程常驻显存，通过 HTTP 向 CLI / 桌面 UI 提供文生图(t2i) 与图生图(i2i) 任务。单 worker 串行消费队列，避免单卡并行挤占 |

---

## 推理运行时清单

| 运行时 | 体积 | 说明 |
| --- | --- | --- |
| **audio.cpp CUDA13 推理运行时** | 262.8 MB | CUDA 13 后端，需系统安装 CUDA 13 runtime |
| **audio.cpp Vulkan 推理运行时** | 59.9 MB | Vulkan 后端，免 CUDA，支持所有 GPU 品牌 |

---

## 模型与资源清单

> 体积取自各 `*.download.json` 清单的 `size` 字段；标「待定」者清单尚未填写体积。

### 语音合成（TTS）

| 资源 | 体积 | 说明 |
| --- | --- | --- |
| Qwen3-TTS 1.7B Base | 4,334 MB | 参考音频克隆 |
| Qwen3-TTS 1.7B CustomVoice | 4,311 MB | 9 个预置音色 |
| Qwen3-TTS 1.7B VoiceDesign | 4,311 MB | 文字描述音色 |
| Qwen3-TTS Tokenizer 12Hz | 651 MB | 音频编解码器 |
| Qwen3-TTS 1.7B Base — q5_k 量化 | 2,134 MB | 声纹克隆用 |
| Qwen3-TTS 1.7B VoiceDesign — bf16 无损 | 3,986 MB | 备选（未下载） |
| Qwen3-TTS 1.7B VoiceDesign — q5_k 量化 | 2,111 MB | 当前默认 |
| Qwen3-TTS 1.7B VoiceDesign — q8_0 量化 | 2,687 MB | 备用（未下载） |
| Qwen3-TTS Tokenizer 12Hz — GGUF | 342 MB | GGUF 格式编解码器 |
| Kokoro 82M | 316 MB | 轻量语音合成 |

### 语音识别（ASR）

| 资源 | 体积 | 说明 |
| --- | --- | --- |
| Qwen3-ASR 1.7B | 4,485 MB | 语音识别 |
| Whisper Base（HuggingFace 格式） | 281 MB | 语音识别 |
| Whisper Base（audio.cpp 格式） | 109 MB | 语音识别（供 audio.cpp 服务使用） |

### 语音活动检测（VAD）

| 资源 | 体积 | 说明 |
| --- | --- | --- |
| FireRed VAD | 4.4 MB | 语音活动检测 |

### 翻译 / 对齐

| 资源 | 体积 | 说明 |
| --- | --- | --- |
| HY-MT1.5-1.8B | 1,820 MB | 混元翻译模型 |
| Qwen3-ForcedAligner 0.6B | 1,755 MB | 强制对齐 |

### OCR / 图像

| 资源 | 体积 | 说明 |
| --- | --- | --- |
| PaddleOCR-VL | 待定 | 离线 OCR 文字识别 |
| Qwen-Image 2512 | 待定 | 文生图 |
| Qwen-Image-Edit 2511 | 待定 | 图生图 / 编辑 |

---

## 更新历史

### 2026-10-14
- **本地声音工具-Lovo**：AI辅助生成音频脚本；多角色剧本合成【重要】；设计音色时测试；实时播放波形

### 2026-10-12
- **个人工作台-FocusOn**：增加【个人履历】模块，支持导入导出和打印，AI优化简介
- **纳戒-Storagering**：支持 AI优化 提示词

### 暂无更新记录
- 心流写作-FlowWrite
- 离线多语言互译-Transly
- 离线文档解析-OffOCR
- 合稿易-DocMerger
- AI绘画提示词助手-画语
- 数据可视化工具-DataChart
- TableBuddy-表伴
- JianQi-简企（开发中）
- Perch-栖心（开发中）
- PixForge-像素锻造（开发中）

## 常见问题

**Q: 服务启动报模型不存在？**
先在面板「模型」页签下载对应模型；或检查 `config/audio.cpp/*.json` 的
`models[].path` 是否指向已下载的文件（相对路径按 config 文件所在目录解析）。

**Q: ASR 识别中文返回空？**
audio.cpp 0.9.2 的已知 bug：传 `language=zh` 等中文语言码会返回空文本。
**不要设 language 参数**，模型会自动检测语种。

**Q: ASR 要求什么音频格式？**
16 kHz 单声道 WAV。非此格式先转码：
`ffmpeg -i in.wav -ar 16000 -ac 1 out16k.wav`

**Q: 换机器 / 挪目录要改配置吗？**
不用。配置里全是相对路径，整个目录拷走即可；模型可在新机器上面板一键重新下载。

**Q: 多大显存够用？**
TTS q5_k 约 3.7 GB + ASR 约 1 GB。显存紧张优先 q5_k 档位；
无 GPU 用 Vulkan（全 GPU 厂商支持）或 CPU（慢，RTF 约 6.7）。

---

## 许可

- 服务运行时基于 [audio.cpp](https://github.com/0xShug0/audio.cpp)（Apache 2.0）
- 模型权重遵循各自上游许可（Qwen3-TTS：Qwen 系列许可；Whisper：MIT）
