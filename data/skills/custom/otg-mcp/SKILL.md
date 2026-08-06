---
name: otg-mcp
description: "TRIGGER: any MCP server install/configure/troubleshoot on OTG Hermes — adding a server, fixing 'uv trampoline failed', or MCP tools not loading after a drive change."
author: Ringo/MilkyWay008
version: 0.1.0
platforms: [windows]
metadata:
  hermes:
    tags: [OTG, MCP, venv, portable, python, windows]
    related_skills: [native-mcp, mcp-debugging, hermes-agent]
---

# MCP Server Management on OTG Hermes

Trigger: any MCP server install/configure/troubleshoot on an OTG (portable,
USB) Hermes package — adding a server to `config.yaml`, fixing "uv trampoline
failed", fixing "home points to C:\Users\..." in `pyvenv.cfg`, or MCP tools
not loading after the package moved to a different drive.

## Mental model

OTG Hermes is a self-contained portable bundle. It carries its own **real**
CPython at `<OTG_ROOT>\dependencies\python\` and one venv per MCP server
under `<OTG_ROOT>\mcp_servers\<name>\.venv\`. Everything must stay relative
to OTG_ROOT because the drive letter changes between insertions
(E:, D:, I:, ...). Venvs built with `uv` embed the build machine's paths and
ship 45 KB trampoline stubs — both break the moment the package moves.

## HARD RULES

- NEVER use system python or system uv to create/repair OTG venvs. Only
  `<OTG_ROOT>\dependencies\python\python.exe` (the bundled real CPython 3.12).
- NEVER hardcode drive letters in `config.yaml`, `pyvenv.cfg`, or commands.
- NEVER point `config.yaml` `command:` at a venv `.exe` entry point (uv
  trampoline) — use `python -m` with the module instead.
- ALWAYS let `fix-otg-paths` handle path portability — it runs on every
  launch; never hand-edit `pyvenv.cfg` on the target machine.

## Resolving OTG paths at runtime

- `echo $HERMES_HOME` → `<OTG_ROOT>\data\` (note the trailing backslash)
- `dirname "$HERMES_HOME"` → `<OTG_ROOT>` — the OTG package root

## What fix-otg-paths does (runs on every launch, idempotent)

- rewrites each venv's `pyvenv.cfg` `home =` line to the CURRENT
  `<OTG_ROOT>\dependencies\python`
- de-trampolines `Scripts\python.exe` / `pythonw.exe`: copies the real
  bundled python.exe + DLLs beside them; original stub kept as `*.uv-orig`
- re-scans `mcp_servers\*\.venv\pyvenv.cfg` for NEW venvs and auto-registers
  them (so user-installed servers are picked up without a manifest edit)
- manifest: `<OTG_ROOT>\dependencies\scripts\fix-otg-paths.json`
- zero writes when nothing changed (fast path)

## Installing a new MCP server OTG-natively

1. Resolve OTG_ROOT: `dirname "$HERMES_HOME"`.
2. Clone the repo into `<OTG_ROOT>\mcp_servers\<name>\`:
   `git clone <repo> "<OTG_ROOT>/mcp_servers/<name>"`
3. Build the venv with the **bundled** python (never uv):
   `"<OTG_ROOT>\dependencies\python\python.exe" -m venv "<OTG_ROOT>\mcp_servers\<name>\.venv"`
4. Install deps (use `python -m pip` if pip is absent in the venv):
   `"<OTG_ROOT>\mcp_servers\<name>\.venv\Scripts\pip.exe" install -e "<OTG_ROOT>\mcp_servers\<name>"`
5. Register in `<OTG_ROOT>\data\config.yaml` under `mcp_servers:`:
   ```yaml
   mcp_servers:
     <name>:
       command: ../mcp_servers/<name>/.venv/Scripts/python.exe
       args: ["-m", "<module>", "serve"]
       enabled: true
   ```
   Paths are **relative to `<OTG_ROOT>\data\`** (that is how the existing
   windows-mcp entry is written). There is NO `$VAR` expansion in command
   fields — do not try `$HERMES_HOME` there.
6. Restart Hermes (or just next launch) — `fix-otg-paths` rewrites the new
   venv's `pyvenv.cfg` automatically and it works on any drive.

## Troubleshooting

| Symptom | Cause | Fix |
|---|---|---|
| `uv trampoline failed` / MCP server exits instantly | `Scripts\python.exe` is a 45 KB uv stub | De-trampoline (next launch does it) or rebuild the venv with the bundled python (step 3 above) |
| `home points to C:\Users\jennifer\...` in pyvenv.cfg | Venv embeds the build machine path | `fix-otg-paths` rewrites it on next launch — or run `fix-otg-paths.cmd` manually |
| Server runs on the build machine but not after moving drives | Absolute paths baked into pyvenv.cfg / config | Rebuild venv with bundled python; use relative `../mcp_servers/...` paths in config.yaml |
| pip not found in the venv | uv venvs ship no real pip | Use `<venv>\Scripts\python.exe -m pip install ...` |
| New server not in `fix-otg-paths.json` | Manifest not yet rescanned | Restart — fix-otg-paths rescans every launch and auto-registers it |

## Windows gotchas

- `HERMES_HOME` has a **trailing backslash**: `D:\hermes-otg\data\` — be
  careful when joining paths in cmd; in bash use `$HERMES_HOME` as-is.
- No `$VAR` expansion in `config.yaml` mcp `command:`/`args:` — use relative
  paths from `data\` (e.g. `../mcp_servers/<name>/.venv/Scripts/python.exe`).
- Never use the venv `.exe` entry point in config (trampoline) — use
  `python -m <module> serve`.
- Check whether an exe is a trampoline: size < 60000 bytes
  (`dir <venv>\Scripts\python.exe`). Real python.exe is >100 KB.
- In git-bash prefer forward slashes and `$HERMES_HOME`; in cmd use
  backslashes.

## CRITICAL: desktop app spawns the backend with cwd=home, not data\

**Symptom:** MCP servers with relative `command:` paths (`../mcp_servers/...`)
fail to connect with `FileNotFoundError: [WinError 2]`, retried every 5
minutes. `shutil.which()` + `anyio.open_process` resolve the relative command
against the backend process's CWD — and the Electron desktop app
(`resolveHermesCwd()`) spawns the backend with **cwd = `app.getPath("home")`**
(e.g. `C:\Users\<user>`), NOT `data\`. From home, `../mcp_servers/...`
resolves to `C:\Users\mcp_servers\...` which doesn't exist.

**Fix:** every launcher (`hermes.cmd`, `hermes-desktop.cmd`,
`hermes-gateway-start.cmd`) MUST set, before launching:

```bat
set "HERMES_DESKTOP_CWD=%SCRIPT_DIR%data"
```

The Electron app reads `process.env.HERMES_DESKTOP_CWD` as candidate #2 in
`resolveHermesCwd()` (after `project-dir.json`), so the backend spawns with
cwd=`data\` and relative MCP paths resolve. The install dir itself is rejected
via `isPackagedInstallPath()` — do NOT try `project-dir.json` pointing at the
OTG root; it gets skipped.

**Verify backend cwd** (not the terminal tool's cwd — the terminal tool may
strip/mangle env): read the process PEB, or simpler, confirm MCP servers
connect after restart. `Get-CimInstance` / `Get-Process` do NOT expose cwd.
