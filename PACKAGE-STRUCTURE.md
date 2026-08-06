# Hermes OTG — Package Structure

> **Why is this repo so small?** GitHub enforces a **100 MiB per-file size limit** for regular git pushes, so this repository hosts the *source & manifest layer* — documentation, launchers, configuration, and skills. The **complete production package** (everything, nothing missing) is distributed as a **Release asset (RAR)**.

## ⚡ Get the full package

Download **`Hermes-OTG v1.0 [H-v0.19.0] (win).rar`** from the [Releases](https://github.com/MilkyWay008/Hermes-OTG/releases) page. It contains every file of the production build (~3.3 GB unpacked, 71,759 files) and runs out of the box.

## 📦 Complete package layout (unpacked RAR)

```
Hermes-OTG/                    (full package root)
├── README.md                  (20 KB)
├── LICENSE.md                 (MIT, 1.1 KB)
├── QUICK-START.md             (3.7 KB)
├── Cheatsheet-OTG_path_env.md (3.0 KB)
├── hermes.cmd / hermes-desktop.cmd / hermes-gateway-start.cmd   (2.4 / 3.2 / 2.9 KB)
├── dependencies/              (~997 MB)  ffmpeg, tts-models, cua-driver, bundled python
├── data/                      (~821 MB)  runtime home: .env, config.yaml, SOUL.md, skills/, node/ (browser), hermes-agent/ (venv)
├── Hermes-OTG/                (~464 MB)  PyInstaller bundle + Electron app
├── git/                       (~409 MB)  portable Git
├── desktop-app/               (~382 MB)  Hermes-OTG-Desktop
├── mcp_servers/               (~241 MB)  windows-mcp + venvs
├── temp/                      (3.8 MB scratch, auto-cleaned)
├── workspace/                 (1 KB, default terminal cwd)
└── sample- IT system rescue reports/   (16 KB)
```

### Second-level breakdown — `dependencies/` (~997 MB)

```
dependencies/                  (~997 MB)
├── python-311/                (~514 MB)  bundled Python 3.11 runtime
├── ffmpeg/                    (~196 MB)  ffmpeg.exe + ffprobe.exe
├── python/                    (~180 MB)  bundled Python (alternate)
├── tts-models/                (~61 MB)   edge TTS voice models (onnx)
├── cua/                       (~47 MB)   computer-use agent driver
└── scripts/                   (25 KB)
```

### Second-level breakdown — `data/` (~821 MB)

```
data/                          (~821 MB)
├── node/                      (~538 MB)  browser runtime: node.exe (~83 MB) + Chromium (~428 MB)
│   └── chromium/chrome-151.0.7922.71/    (~428 MB)
├── hermes-agent/              (~266 MB)  internal venv + hermes_cli
├── skills/                    (~17 MB)   agent skills library
├── SOUL.md                    (28 KB)
├── plugins/                   (13 KB)
├── .env / config.yaml / cron/ / hooks/ / platforms/   (configuration layer)
└── caches, logs, sessions, state (empty at ship time — populated at runtime)
```

## 🗜️ Large files in the package (excluded from this repo, present in the RAR)

| File | Size | Why it ships in the RAR only |
|---|---|---|
| data/node/chromium/chrome-151.0.7922.71/chrome.dll | ~284 MiB | > 100 MiB GitHub limit |
| desktop-app/Hermes-OTG-Desktop/Hermes-OTG.exe | ~204 MiB | > 100 MiB GitHub limit |
| dependencies/ffmpeg/ffmpeg.exe | ~98 MiB | 50–100 MiB warning band |
| dependencies/ffmpeg/ffprobe.exe | ~98 MiB | 50–100 MiB warning band |
| data/node/node.exe | ~83 MiB | 50–100 MiB warning band |
| dependencies/tts-models/en_US-lessac-medium.onnx | ~60 MiB | 50–100 MiB warning band |
| Hermes-OTG/Hermes-OTG.exe | ~58 MiB | 50–100 MiB warning band |
| Hermes-OTG/_internal/ctranslate2.dll | ~57 MiB | 50–100 MiB warning band |

## 📄 What's in this repo vs. what's RAR-only

| In this repo (source/manifest layer) | Only in the Release RAR (full package) |
|---|---|
| README, LICENSE, QUICK-START, cheatsheet | dependencies/ (ffmpeg, python, tts-models, cua) |
| 3× launcher .cmd files | data/node/ (browser + Chromium) |
| data/.env, data/config.yaml, data/SOUL.md | data/hermes-agent/ (internal venv) |
| data/skills/, data/plugins/, data/cron/, data/hooks/ | git/ (portable Git) |
| sample- IT system rescue reports/ | Hermes-OTG/ + desktop-app/ (Electron) |
| | mcp_servers/ (windows-mcp) |

> 🔑 **API keys note:** `data/.env` ships with a free NVIDIA key (rate-limited, intentionally shared) and a self-generated `API_SERVER_KEY` default — both are meant to be replaced by the end user for production use.

## ⚠️ Why the repo can't hold everything

GitHub blocks files larger than 100 MiB on regular pushes (warning at 50 MiB). The full 3.3 GB / ~71,759-file package cannot live in git — which is exactly what Releases are for.
