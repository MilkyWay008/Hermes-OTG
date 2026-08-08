<p align="center">
  <img src="https://raw.githubusercontent.com/NousResearch/hermes-agent/main/assets/banner.png" alt="Hermes Agent banner" width="100%">
</p>

# <p align="center">🚀 Hermes OTG — The Portable Hermes Agent That Does *Everything*</p>

<p align="center">
  <strong>Full-featured Hermes Agent on a USB stick. Zero install. Zero host pollution.</strong><br>
  Run it from any drive, any folder, any Windows 10/11 machine — as TUI, full Desktop app, or Gateway.<br>
  <em>The only portable Hermes that runs side-by-side with your installed one.</em>
</p>

<p align="center">
  <a href="#"><img src="https://img.shields.io/badge/Platform-Windows_10_%7C_11-0078D6?style=for-the-badge" alt="Platform: Windows 10 | 11"></a>
  <a href="#"><img src="https://img.shields.io/badge/Zero_Install-No_Setup-green?style=for-the-badge" alt="Zero Install"></a>
  <a href="#"><img src="https://img.shields.io/badge/Portable-USB_%7C_Any_Drive-8A2BE2?style=for-the-badge" alt="Portable"></a>
  <a href="#"><img src="https://img.shields.io/badge/Offline_Deploy-Ready-orange?style=for-the-badge" alt="Offline Deploy"></a>
  <a href="#"><img src="https://img.shields.io/badge/Desktop-Side_by_Side-FF6B6B?style=for-the-badge" alt="Desktop Side-by-Side"></a>
  <a href="#"><img src="https://img.shields.io/badge/License-MIT-purple?style=for-the-badge" alt="License MIT"></a>
</p>

<p align="center">
  <strong>Agent for agents · IT rescue kit · portable coding workspace</strong>
</p>

<p align="center">
| 📦 <a href="https://github.com/MilkyWay008/Hermes-OTG/releases/latest"><img src="https://img.shields.io/badge/Download_Latest_Release-2EA043?style=for-the-badge" alt="Download Latest Release"></a> | — v1.0.1 [H-v0.19.0] (Windows) — no install, just unzip and run. |
</p>

---

## 📑 Table of Contents

- [Why Hermes OTG?](#-why-hermes-otg)
- [✨ Key Features](#-key-features)
- [🎬 See It In Action](#-see-it-in-action)
- [🏆 Not the first portable Hermes — but the first to do ALL of it](#-not-the-first-portable-hermes--but-the-first-to-do-all-of-it)
- [⚡ Quick Start](#-quick-start)
- [🖥️ Three Ways to Run](#️-three-ways-to-run)
- [🛠️ Built for Serious Work: Coding](#️-built-for-serious-work-coding)
- [🆘 Built for Serious Work: IT Rescue](#️-built-for-serious-work-it-rescue)
- [⚙️ How It Works — The Portability Engine](#️-how-it-works--the-portability-engine)
- [📁 Folder Structure](#-folder-structure)
- [🔑 API Keys & Configuration](#-api-keys--configuration)
- [📦 System Requirements & Footprint](#-system-requirements--footprint)
- [🔄 Updating](#-updating)
- [🔒 Security Notes](#-security-notes)
- [❓ FAQ](#-faq)
- [🔍 Search Keywords](#-search-keywords)
- [📝 Credits & License](#-credits--license)

---

## 💡 Why Hermes OTG?

> **"Every machine deserves a smart layer."**

There are plenty of "portable Hermes" projects — most are **bootstrap launchers** that download the agent at first run, or stripped shells that lose the toolset. **Hermes OTG is different:**

- 🧳 **A complete, offline-deployable Hermes** — full headless browser, computer use, MCP, skills, memory, everything — in one folder you can carry on a USB stick.
- 🔄 **Hot-swappable** — move it to any folder, any drive (USB, HDD, `E:`, `I:`, `Z:` — doesn't matter). It just works. **Zero install.**
- 🖥️ **Your choice of interface** — full-feature OTG Hermes Desktop, the classic TUI, or a lean Gateway/API server only.
- 🆘 **Your IT rescue agentic kit** — when your host-installed Hermes breaks (failed update, app conflict), OTG Hermes Desktop runs **side-by-side** with it to diagnose, troubleshoot, and fix.
- 🧠 **Equipped with special skills & harness** for serious tasks — coding, IT system repair, network ops — with **minimal drift**.

---

## ✨ Key Features

### 🧳 Truly Portable — By Design, Not By Launcher Hacks
- **`HERMES_HOME` resolves relative to the executable** — not `~/.hermes`. This is the core design decision that makes it genuinely relocatable.
- **17 hardcoded-path source files + 4 import-time caching bugs patched** at the source level — not patched at launch time. Move it, it just works.
- **All configs, MCP server paths, terminal CWD, and scripts use relative paths** (the "Portability Mandate") — no absolute-path time bombs.
- **Zero install on the host** — no Python, no Node, no Docker, no admin rights, no registry writes.

### 🖥️ Full Desktop App From a USB Stick
- Launch the **complete Electron desktop app** directly from the portable folder.
- The bundled `hermes.exe` runs in **serve mode** (`serve --host 127.0.0.1 --port 7642 --skip-build`) so the desktop renderer gets its full JSON-RPC/WebSocket backend.

### 🔀 Side-by-Side With Your Installed Hermes — The Killer Feature
- **Different desktop app identity** (`com.nousresearch.hermes-otg` appId + `HERMES_OTG` env var → separate Windows named mutex) — **both desktops run simultaneously**.
- **Separate port: 7642** (installed Hermes uses 8642) — no binding conflicts.
- **Separate data dir** — OTG uses its own `state.db`, `memories/`, `skills/`, `SOUL.md`. Your host install is never touched.
- **Gateway OFF by default** — starts only when you explicitly run it.

### 🛠️ Bundled for Serious Agentic Coding
- **FastMCP** — build/run MCP servers out of the box.
- **FastAPI** — spin up APIs on the go.
- **CLI-Anything** — agent-native CLI tooling.
- **PortableGit + bundled real CPython 3.12** — the terminal tool has a working bash shell and Python, fully self-contained.
- **All standard Hermes skills pre-shipped** — the full library, ready.

### 🆘 Bundled for IT System Rescue & Network Ops
- **windows-mcp pre-installed with 31 Sysinternals rescue tools** (PsExec, handle, procdump, accesschk, …).
- **OTG-native MCP install skill (`otg-mcp`)** — add more MCP servers the **portable way**, using the bundled Python (never the host's).
- **`memory-index` skill** — memory housekeeping for long sessions.

### 🧠 Special Skills & Harness
- Purpose-built skills and specially prepared harness so the agent **excels at serious tasks with minimal drift** — coding, IT repair, and network operations that would stall a generic portable agent.

---

## 🎬 See It In Action

**🔀 Side-by-Side with your installed Hermes — survives drive-letter & folder change:**
<video src="https://github.com/user-attachments/assets/8af218d0-cbc7-4959-a5e0-ba5d8176635e" controls width="100%"></video>

---

## 🏆 Not the first portable Hermes — but the first to do ALL of it

We researched the ecosystem before building. There are at least **6 other public portable Hermes projects**. None of them can do everything Hermes OTG does:

| Capability | Other portable Hermes builds | **Hermes OTG** |
|---|:---:|:---:|
| Survives drive-letter change / folder move | ⚠️ Some (launcher hacks: rewrite `pyvenv.cfg` per launch, trampoline shims) | ✅ **By design** — source-patched, relative `HERMES_HOME`, zero launch-time repair |
| Full Electron **desktop app** from USB | ❌ Mostly CLI/TUI/gateway only; a few bundle Electron | ✅ **Full desktop, first-class** |
| Runs **side-by-side** with installed Hermes desktop | ❌ Conflict on ports (8642) or host `~/.hermes`; one **kills** existing processes on its ports | ✅ **Different mutex + port 7642 + isolated data** — both run simultaneously |
| **Offline** deployable (no first-run download) | ❌ Most download upstream at first run | ✅ **Fully bundled** — works without internet |
| Zero-install, zero host pollution | ⚠️ Mixed | ✅ **Yes** — no registry, no `~/.hermes`, no admin |
| Bundled FastMCP / FastAPI / CLI-Anything | ❌ No | ✅ **Yes** |
| Bundled windows-mcp + Sysinternals rescue tools | ❌ No | ✅ **Yes** |
| TUI **and** Desktop **and** Gateway modes | ⚠️ One or two | ✅ **All three** |
| Specialized skills/harness for serious tasks | ❌ No | ✅ **Yes** |

> 🏆 **"First portable Hermes" was already taken. "First portable Hermes that does ALL of it" — that's ours.**

---

## ⚡ Quick Start

### 1. Get the release
<strong>📦 <a href="https://github.com/MilkyWay008/Hermes-OTG/releases/latest">Download the latest **Hermes OTG** release (`.rar`) here.</a></strong>  Extract **anywhere** — a USB stick, external drive, or a plain folder. Do *not* need to run an installer.

### 2. Launch
Double-click the launcher for the mode you want:

| Launcher | What it does | Who it's for |
|----------|--------------|--------------|
| **`hermes-desktop.cmd`** | Opens the full **desktop app** (recommended) | ✅ **Everyone — start here** |
| `hermes.cmd` | Text-based **TUI** | Advanced users |
| `hermes-gateway-start.cmd` | Runs only the **API server** (port 7642) | Advanced / programmatic use |

> The first launch may take a few seconds to prepare (paths re-point to the current drive automatically). After that it's **instant**.

### 3. Add your API keys
Edit `data\.env` and `data\config.yaml` (in the portable folder) to add your own keys. The release ships with a free NVIDIA key so it works out of the box for testing.

### 4. Go
Start chatting. Carry it to another machine — plug in, launch, continue. Your agent's memory, sessions, skills, and state travel with the folder.

---

## 🖥️ Three Ways to Run

```
┌────────────────────────────────────────────────────────────────┐
│              Hermes OTG (any drive, any folder)                │
│                                                                │
│   hermes-desktop.cmd      hermes.cmd        hermes-gateway-    │
│        │                     │               start.cmd         │
│        ▼                     ▼                    ▼            │
│   ┌─────────────┐      ┌──────────┐      ┌──────────────┐      │
│   │ FULL DESKTOP│      │   TUI    │      │  API SERVER  │      │
│   │ (Electron)  │      │ (text UI)│      │   port 7642  │      │
│   └─────────────┘      └──────────┘      └──────────────┘      │
│         └────────────────────┬────────────────────┘            │
│                              ▼                                 │
│                 hermes.exe (PyInstaller,                       │
│                 self-contained, HERMES_HOME → data/)           │
└────────────────────────────────────────────────────────────────┘
```

- **Desktop** — full GUI, recommended for everyone.
- **TUI** — terminal power users.
- **Gateway** — API server only, for programmatic access and remote control (an admin agent can talk to this OTG agent agent-to-agent).

---

## 🆘 Built for Serious Work: IT system Rescue

**Plug it in. Launch it. You have an IT admin agent ready to work.** From the moment OTG Hermes starts, you have eyes and hands on the machine — windows-mcp + 31 Sysinternals tools, PowerShell, file system, registry, browser, and a harness built for serious system work. No setup, no config, no waiting: just ask. It's perfect to go with Hiren's BootCD, MediCat USB, UBCD, Windows-to-Go (WTG), etc.

### 🆘 Use Case 1 — Rescue a broken installed Hermes (the flagship)

> **Your host-installed Hermes desktop fails to run** — failed update? App conflict? Broken config?<br>
> **Plug in OTG Hermes.** Launch **OTG Hermes Desktop** — it can even run *side-by-side* with the broken install (different mutex, different port, isolated data).<br>
> **The OTG agent inspects the host install** — config, state.db, skills, gateway processes — using the bundled **windows-mcp + 31 Sysinternals tools** (PsExec, handle, procdump, accesschk, …), **diagnoses the failure, and fixes it.** Your host agent is rescued.

### 💽 Use Case 2 — Diagnose system & app failures on any machine

> **"The disk on this windows server is failing — check SMART status, find what's filling it, and tell me what to replace."**

> **"This app can't connect to the network — trace why."**

OTG Hermes reads event logs, checks disk health, runs network diagnostics (`Test-NetConnection`, DNS, services), inspects app configs and processes — and walks you to the root cause with diagnostic report & proposed fix ready (even fix it for you if you approve Hermes to do so). It's like having a sysadmin's toolkit that also *thinks*.

### 🏛️ Use Case 3 — Infrastructure setup (domain / Active Directory / LDAP)

> **"Set up the domain on this machine and join it to Active Directory."**

> **"Connect this box to our LDAP directory."**

OTG Hermes guides you through domain configuration, AD/LDAP connectivity, DNS, and authentication — step by step, verifying each stage with the bundled tools, so you're not guessing in front of a server console. With windows-mcp computer_use capability, with your approval, OTG Hermes can even do all the above *FOR* you.

That's the difference between a "portable toy" and a **portable smart layer for every machine**.

**📁 See it in action — real rescues from the sample folder:**

> **🖥️ [VMware VM failure & recovery](sample-%20IT%20system%20rescue%20reports/OTG%20IT-agent%20Local%20fix%20Report-%20%20VMware%20VM%20failure%20%26%20recovery.md)** — a crashed VM brought back from diagnose to fix, in minutes instead of hours.
>
> **🌐 [WSL failure & recovery after Windows Update](sample-%20IT%20system%20rescue%20reports/OTG%20IT-agent%20Remote%20fix%20Report-%20WSL-failure-%26-recovery-after-windows-update.md)** — WSL dead after an update, remotely diagnosed and restored without touching the host's broken install.

These are real-life system rescues that normally take **hours or days** of troubleshooting — completed (diagnose → fix) in **5–20 minutes** by OTG Hermes agent.

---

## 🛠️ Built for Serious Work: Coding

Out of the box, with all followings bundled, Hermes OTG is a **portable agentic coding workstation**:

- **FastMCP** — create and run MCP servers anywhere, no host install.
- **FastAPI** — stand up local APIs for testing or tooling.
- **CLI-Anything** — let the agent directly drive any CLI, and almost any apps in windows.
- **Bundled Python 3.12 + PortableGit** — the terminal tool runs real bash and Python, all inside the folder.
- **Full browser + computer-use toolset** — the agent can browse, automate, and operate like the full Hermes experience.

> 💡 *"Serious agentic coding tasks on the go — without touching the host machine's Python, Node, or environment."*

---

## ⚙️ How It Works — The Portability Engine

```
Upstream Hermes source (immutable)
        │
        ▼
Patched for OTG portability:
  • 17 hardcoded ~/.hermes path files → relative HERMES_HOME
  • 4 import-time path-caching bugs → dynamic resolution
  • Desktop app identity → com.nousresearch.hermes-otg (own mutex)
  • Default API port → 7642 (vs installed 8642; avoid clash)
  • Gateway → OFF by default (HERMES_OTG env var gates it)
        │
        ▼
PyInstaller --onedir build
        │
        ▼
Hermes OTG portable folder (hermes*.cmd + data/ + desktop-app/ + Hermes-OTG/ + mcp_servers/ + dependencies/)
```

**Why this matters:** other portable builds fix paths *at launch time* (rewrite `pyvenv.cfg`, regenerate trampolines). Our Hermes OTG fixes them *in the source* — so the binary is **intrinsically portable**. No setup phase, no repair step, no first-run download. **Instant, every time, from anywhere.**

---

## 📁 Basic Folder Structure

```
Hermes-OTG/
├── hermes-desktop.cmd        # Launch full desktop app (recommended)
├── hermes.cmd                # Launch TUI
├── hermes-gateway-start.cmd  # Launch API server only (port 7642)
├── data/                     # ⚠️ [BACKUP THIS] (excluding folder "node")
│   ├── SOUL.md               #   System prompt / persona
│   ├── state.db              #   Sessions & state
│   ├── config.yaml           #   Hermes config
│   ├── .env                  #   API keys
│   ├── memories/             #   User profile, saved facts
│   ├── skills/               #   User-installed skills (+ custom/)
│   └── logs/
├── mcp_servers/              # MCP servers (installed per-machine, portable way)
│   └── windows-mcp/          #   Pre-installed, 28 Sysinternals rescue tools
├── Hermes-OTG                # PyInstaller-built, self-contained
├── desktop-app				  # Hermes desktop app OTG patched, self-contained
├── dependencies/             # Bundled Python 3.12 + FastMCP/FastAPI/CLI-Anything
├── git/                      # Bundled PortableGit
└── workspace/                # Default working folder
```

> ⚠️ **Back up `data/`** — it holds your agent's identity: personality, memory, sessions, skills.

---

## 🔑 API Keys & Configuration

Edit these in the portable folder (never the host's):

```env
# data/.env
# At minimum, set one provider's API key
NVIDIA_API_KEY=nvapi-xxxxxxxxxxxxxxxx      # ships pre-configured for testing
OPENROUTER_API_KEY=sk-or-v1-xxxxxxxxxxxx    # or your provider of choice
DEEPSEEK_API_KEY=sk-xxxxxxxxxxxxxxxx
```

- **Models / tools / MCP servers** → `data\config.yaml`
- **Persona & Harness** → edit `data\SOUL.md` (loaded fresh every message)
- **Config templates** → `data\config.yaml.template-*` and `data\.env.template-*` are clean starting points
- **MCP servers** → add at `mcp_servers\<name>\` the OTG-native way (ask the agent, or load the `otg-mcp` skill). After adding to `config.yaml`, restart the app.

> 💡 If you change your API key provider, also update the **vision model** in `config.yaml` (`auxiliary.vision`) so the agent can "see".

---

## 📦 System Requirements & Footprint

| Item | Requirement |
|------|-------------|
| OS | Windows 10 / 11 |
| Install | **None** — run from any folder / drive letter or USB drive |
| Admin rights | **Not required** |
| Dependencies on host | **Zero** (Python, Node, Docker all bundled) |
| Internet | Only needed for API calls to your model provider (deployment itself is offline) |

---

## 🔄 Updating

Updates are **OFF by design** — this build is specially forked and patched for portability, so the in-app updater is disabled (each Hermes update would require the whole OTG bundle to be rebuilt).

- To get the latest Hermes OTG, watch for a new release by **Ringo / MilkyWay008**, published shortly after major Hermes updates (e.g. v0.19 → v0.20 → v0.21).
- OTG changes are tracked as git commits on an internal `otg-build` branch, replayed onto new upstream releases with `git rebase` — so updates stay reproducible.

---

## 🔒 Security Notes

> [!WARNING]
> **Your portable folder contains your identity.**  `data/` holds your API keys (`.env`), persona & harness (`SOUL.md`), and all session data (`state.db`, `memories/`). Treat it like a wallet: don't leave the USB stick lying around, and back it up.

- **Zero host pollution** — no registry writes, no `~/.hermes`, no host app data touched. Remove the folder and nothing remains.
- The bundled **free NVIDIA key** is for out-of-the-box testing only (~40 requests/min) — **not for production**. Use your own keys for real work.

---

## ❓ FAQ

<details>
<summary><strong>Will this work if I move it to a different drive letter?</strong></summary>

**Yes.** That's the core design goal. `HERMES_HOME` resolves relative to the executable, and all paths are relative. Move it `E:\` → `D:\` → `I:\`, into a subfolder, onto a different USB stick — it still works. No re-setup.
</details>

<details>
<summary><strong>Can I run it side-by-side with my installed Hermes desktop?</strong></summary>

**Yes — this is the killer feature.** Different app identity (own mutex), different port (7642 vs 8642), and fully isolated data. Both desktops open simultaneously on the same machine. Use the OTG agent to diagnose/fix a broken host install.
</details>

<details>
<summary><strong>Does it need internet on first launch?</strong></summary>

**No.** Everything is bundled — Python, Node, git, MCP servers, skills. Internet is only needed for API calls to your model provider. This makes it ideal for air-gapped or rescue scenarios.
</details>

<details>
<summary><strong>Can I add my own MCP servers?</strong></summary>

**Yes.** Install them inside the folder at `mcp_servers\<name>\` using the bundled Python — never the host's. Load the `otg-mcp` skill for the exact portable procedure, or just ask the agent.
</details>

<details>
<summary><strong>It's slow on my USB stick. What can I do?</strong></summary>

Avoid slow USB drives for heavy use — the agent reads/writes many small files (skills, memory, state). Use a fast USB 3.x stick or a portable SSD for the best experience.
</details>

<details>
<summary><strong>My memory filled up. Help?</strong></summary>

Ask the agent to use the **`memory-index`** skill — it re-indexes `MEMORY.md` into tiered storage and frees significant space.
</details>

---

## 🗺️ Future Dev Plan

Where Hermes OTG goes next:

**(a) 🌍 Linux & macOS are next.** The next major target is bringing OTG Hermes to Linux and macOS — the same zero-install, hot-swappable, side-by-side portable experience on every platform.

**(b) 🤖 Bundled Smart MCP Proxy + Computer-Use MCP for agentic IT Management.** The next release will include a **compiled version of the Smart MCP Proxy with computer-use MCP** — turning every machine node into an MCP node with eyes and hands, so one agent can manage an entire fleet of machines remotely. **Remote brains. Local hands.**

> 🌐 Curious about the full vision? See [**Smart MCP Proxy — True Potential**](https://github.com/MilkyWay008/Smart-MCP-Proxy/blob/main/mcp-proxy-true-potential.md): cascading proxies, enterprise IT hierarchies, agent-as-IT-admin, and the operating system for agentic IT operations.

---

## 🔍 Search Keywords

`Hermes OTG` · `OTG Hermes` · `OTG` · `portable hermes` · `hermes agent portable` · `hermes usb` · `USB AI agent` · `portable AI agent` · `no install AI agent` · `zero install` · `green package` / `绿色版` · `USB bundle` / `U盘版` · `portable bundle` / `便携版` · `Windows portable` · `Windows To Go` · `Windows-to-Go` · `WTG` · `hermes desktop portable` · `side-by-side hermes` · `IT rescue USB` · `Sysinternals AI agent` · `MCP portable` · `offline AI agent` · `Hiren's BootCD` · `Hiren` · `BootCD` · `MediCat USB` · `MediCat` · `Ultimate Boot CD` · `UBCD` · `FalconFour’s Ultimate Boot CD` · `Hermes rescue` · `system rescue` 

---

## 📝 Credits & License

- Built by **Ringo / MilkyWay008**, forked from [NousResearch/hermes-agent](https://github.com/NousResearch/hermes-agent).
- Based on Hermes Agent v0.19.0 (main HEAD), patched for full portability.
- License: **MIT**

---

<p align="center">
  <strong>Hermes OTG — every machine deserves a smart layer.</strong><br>
  <sub>Portable. Zero-install. Side-by-side. Offline. Full-suite. 🧳</sub>
</p>
