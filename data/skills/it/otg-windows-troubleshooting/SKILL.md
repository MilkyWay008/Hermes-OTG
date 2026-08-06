---
name: otg-windows-troubleshooting
description: Use when debugging OTG Hermes on Windows.
version: 1.0.0
author: OTG Hermes IT Agent
platforms: [windows]
metadata:
  hermes:
    tags: [otg, windows, frozen-build, pyinstaller, cmd, crlf, execute_code, env]
    related_skills: [otg-pip, otg-mcp, otg-web_extract, vmware-vm-crash-recovery]
---

# OTG Windows Troubleshooting

**TRIGGER:** Work on the OTG Hermes build on Windows — editing `.cmd`/`.bat` launchers, debugging `execute_code`, tracing env vars into the frozen backend, or needing to know what `Hermes-OTG.exe` actually does internally.

## Hard Rule: Diagnose First, Get Approval Before Patching

The user runs a diagnose-first discipline (also in SOUL.md Hasty-Action Rule). **Report findings, let the user decide, then act.** Do NOT jump to patching/fixing when asked to "check the log" or "test" — that is a diagnosis request, not a fix mandate. Mid-session I patched without approval and got called out: *"I asked you to check the log for errors, but I didn't ask you to fix any errors."*

- Asked to investigate → investigate, report, propose. Do not modify.
- Asked to fix → backup first (`.bak-YYYYMMDD-HHMM`), state exactly what you'll change, get agreement.
- Every edit to a file that matters: make a backup copy first. No exceptions.

## Pitfall 1: CRLF Corruption — the #1 .cmd/.bat gotcha

`patch` and `write_file` tools write LF (`\n`) line endings into Windows batch files. **cmd.exe silently SKIPS lines after a bare LF**, so a `set VAR=...` line placed after an LF-ending comment never executes — and there is NO error message.

Symptom pattern that identifies this: env vars set EARLIER in the launcher (e.g. `HERMES_HOME`) reach the process, but a var added later in the file does not — even though the file "looks right" and propagation tests pass.

**Fix (byte-level, always):**
```bash
python - <<'PYEOF'
data = open(path, 'rb').read()
crlf = data.replace(b'\r\n', b'\n').replace(b'\n', b'\r\n')
open(path, 'wb').write(crlf)
PYEOF
# verify:
python -c "d=open(path,'rb').read(); print('bare LF:', d.count(b'\n') - d.count(b'\r\n'))"  # must be 0
```
Always verify bare-LF count == 0 after ANY `.cmd`/`.bat` edit, including edits made with the `patch` tool.

## Pitfall 2: `\v` Escape Mangles `\venv` Paths in Python

When building Windows paths inside Python strings (`"...\data\hermes-agent\venv\Scripts\python.exe"`), `\v` is a valid Python escape = vertical tab (0x0b). `"\\venv"` → `\venv` is fine, but any single-backslash form corrupts silently.

**Fix:** use raw strings (`rb'...'`) or build paths with `chr(92)` joins — never literal `\v` inside normal strings. Verify with a hexdump/`line.hex()` check for `0b` bytes after writing.

## Technique: Decompile the Frozen Hermes-OTG.exe

To know what the frozen build ACTUALLY does (source differs from GitHub main — OTG builds carry custom patches), extract and disassemble it:

```bash
# Use a Python version matching the build (bundled python-311 for 3.11 builds)
/c/OTG-Hermes/dependencies/python-311/python.exe pyinstxtractor.py "C:\\OTG-Hermes\\Hermes-OTG\\Hermes-OTG.exe"
# Then read a module's bytecode:
python -c "
import marshal, dis
code = marshal.loads(open(r'..._extracted\\PYZ.pyz_extracted\\tools\\code_execution_tool.pyc','rb').read()[16:])
for c in code.co_consts:
    if hasattr(c,'co_name') and c.co_name in ('_resolve_child_python','_get_execution_mode'):
        dis.dis(c)"
```
Notes: pyinstxtractor must run under the SAME Python major.minor as the build (else PYZ extraction is skipped). `PYZ.pyz_extracted` holds the real modules; the .pyc header is 16 bytes on 3.11.

## execute_code Interpreter Resolution (frozen OTG build)

The frozen `_resolve_child_python()` is OTG-patched — it checks env vars in this order:
1. **`HERMES_OTG_PYTHON`** — if set AND the file exists, returned immediately (wins over everything)
2. `VIRTUAL_ENV` / `CONDA_PREFIX` → `<root>/Scripts/python.exe` (standard path)
3. `sys.executable` (= `Hermes-OTG.exe`) — fallback that breaks everything

Symptom of hitting fallback: execute_code errors with `hermes: error: argument command: invalid choice: '<script.py>'` — the script path was handed to the hermes CLI because the resolver returned the frozen exe.

**Fix:** set `HERMES_OTG_PYTHON` in the launchers (not just `VIRTUAL_ENV` — the OTG override shadows it):
```bat
set "HERMES_OTG_PYTHON=%SCRIPT_DIR%\data\hermes-agent\venv\Scripts\python.exe"
set "VIRTUAL_ENV=%SCRIPT_DIR%\data\hermes-agent\venv"
```
Target must pass a 3.8+ version check (`_is_usable_python` runs `python -c "import sys; sys.exit(0 if sys.version_info >= (3,8) else 1)"`).

## Env Plumbing: Launcher → Electron → Backend

- Desktop app = Electron (`desktop-app\Hermes-OTG-Desktop\Hermes-OTG.exe`); it spawns the backend = PyInstaller `Hermes-OTG\Hermes-OTG.exe serve --port 7642`.
- Backend spawn env = `{ ...process.env, HERMES_HOME, ...backend.env, TERMINAL_CWD, ... }` — **process.env of the Electron app flows to the backend**, so vars set in the launcher .cmd DO reach it.
- TRAP: `HERMES_HOME`, `HERMES_OTG`, `TERMINAL_CWD` are set EXPLICITLY by the Electron app in `backend.env` — their presence in the backend does NOT prove the .cmd env flowed. To prove flow, use a var the app only reads (e.g. `HERMES_GIT_BASH_PATH`).
- **The terminal tool DELIBERATELY STRIPS `VIRTUAL_ENV` and `CONDA_PREFIX`** from subprocess envs (`tools/environments/local.py`, `_ACTIVE_VENV_MARKER_VARS`). Never trust `echo $VIRTUAL_ENV` in the terminal to check the backend env — it will always be empty. execute_code's own scrub list (`_SAFE_ENV_PREFIXES`) KEEPS those vars, so they're only visible there.
- There may be BOTH a Start Menu shortcut pointing directly at the exe AND a `hermes-*.cmd` wrapper — check which launched the process (`Get-CimInstance Win32_Process` parent chain) before concluding the launcher ran.

## Web Backend Facts (verified against frozen 0.19 source)

- `ddgs` IS a valid `search_backend` (free, keyless, bundled). `trafilatura` is NOT a valid `extract_backend` — no `plugins/web/trafilatura/` exists; valid extract backends are firecrawl/tavily/exa/parallel (all need keys). Leave `extract_backend: ''` and use the `otg-web_extract` skill's Jina→trafilatura→browser fallback chain.
- Venv `.exe` CLI wrappers (`ddgs.exe`, `trafilatura.exe`) are broken uv trampolines (exit 1 silently) — always use the Python API via `<OTG_ROOT>\data\hermes-agent\venv\Scripts\python.exe`.
- `execute_code` on frozen OTG builds is a separate runtime from `terminal` — a package importable in one is not guaranteed in the other.

## Support Files
- `references/frozen-execute-code-resolution.md` — decompiled `_resolve_child_python` disassembly + the exact env facts recorded while debugging.
- `references/sysinternals-and-windows-mcp.md` — completing the Sysinternals suite (procexp download + sigcheck verify recipe) and windows-mcp tool-usage quirks (App tool `mode:` schema, Screenshot "No windows found" text-vs-image quirk), plus an end-to-end smoke test template.
