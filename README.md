# localfirst-apps

**本地优先应用控制台** —— 一键下载本地 AI 模型、统一启停推理服务、管理本地应用。
全程离线可用，数据不出本机。

## 快速开始

```bat
REM 1. 双击运行控制面板
control-panel.exe

REM 2. 「模型」页签：点击下载所需模型（并行下载 + 断点续传 + SHA256 校验）
REM 3. 「服务」页签：一键启动语音服务（默认 http://127.0.0.1:18080）
REM 4. 「应用」页签：启动本地应用
```

没有 GPU 也能用：服务支持 CUDA / Vulkan / CPU 三种后端，面板里可切换。

## 功能

| 功能 | 说明 |
|---|---|
| **下载模型** | 扫描 `models/**/.download.json` 清单，并行下载 + 断点续传 + SHA256 校验；已下载的自动标记，支持删除 |
| **启动服务** | 扫描 `bin/**/.server.json`，列出服务与启动参数，一键启停；防重复实例 |
| **启动应用** | 扫描 `bin/**/.app.json`，统一入口管理本地应用 |
| **全局日志** | 底部固定日志框，子进程输出实时显示 |

所有清单都从磁盘扫描，**控制面板不硬编码任何模型或服务**——新增只要放一个 json 清单。

## 模型清单

模型文件不随仓库分发，运行面板按需下载（总计约 26 GB，可只下需要的）：

| 模型 | 体积 | 用途 |
|---|---|---|
| Qwen3-TTS VoiceDesign（q5_k） | 2.2 G | TTS 音色设计（文字描述音色），**默认推荐** |
| Qwen3-TTS VoiceDesign（q8_0 / bf16） | 2.8 G / 4.2 G | TTS 备用量化档位，按需下载 |
| Qwen3-TTS Base（q5_k） | 2.2 G | 声纹克隆（3 秒参考音频复刻声音），`perch-tts-clone` 模型用 |
| whisper base | 110 M | 语音识别 |
| FireRed VAD | 2.3 M | 语音活动检测（断句） |

显存敏感（如同时跑 ollama）选 q5_k：实测显存约 3.7 GB、RTF 0.37（2.7 倍实时）。

## 目录结构

```
localfirst-apps/
├── control-panel.exe    ← 控制面板（双击运行）
├── bin/
│   └── audio.cpp/       ← 语音推理服务运行时（cuda13 / vulkan 双后端）
│       ├── cuda13/      ← 推荐：CUDA 后端（GPU 加速）
│       ├── vulkan/      ← 备选：Vulkan 后端（免 CUDA runtime，便携）
│       ├── start-server.bat  ← 命令行启动脚本
│       └── README.md    ← 服务技术文档（API / 转换 / 实测）
├── config/
│   └── audio.cpp/       ← 服务启动配置（路径为相对路径，整个目录可随意挪动）
│       ├── perch-full.json   ← TTS + ASR + VAD（默认）
│       ├── qwen3-tts.json    ← 仅 TTS
│       ├── whisper-asr.json  ← 仅 ASR
│       └── models-index.json ← 模型家族索引
└── models/              ← 模型仓库（面板下载后落盘于此，不入库）
    └── <模型目录>/
        └── .download.json ← 下载清单（直链 + 体积 + SHA256）
```

## 命令行启动（可选）

面板之外也可以直接启服务：

```bat
bin\audio.cpp\start-server.bat          REM TTS + ASR + VAD（默认）
bin\audio.cpp\start-server.bat tts      REM 仅 TTS
bin\audio.cpp\start-server.bat asr      REM 仅 ASR
bin\audio.cpp\start-server.bat vulkan   REM Vulkan 后端
bin\audio.cpp\start-server.bat cpu      REM 纯 CPU
```

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

## 技术文档

服务的 API 协议、模型转换、量化对比、实测数据见
[bin/audio.cpp/README.md](bin/audio.cpp/README.md)。

## 许可

- 服务运行时基于 [audio.cpp](https://github.com/0xShug0/audio.cpp)（Apache 2.0）
- 模型权重遵循各自上游许可（Qwen3-TTS：Qwen 系列许可；Whisper：MIT）
