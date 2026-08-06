# Frozen execute_code Resolution — Decompiled Evidence

Session: 2026-08-04 — debugging `execute_code` on OTG Hermes 0.19 (frozen build, dated 2026.7.20).

## Symptom

Every `execute_code` call failed with:

```
usage: hermes [-h] ...
hermes: error: argument command: invalid choice: 'C:\Users\...\Temp\hermes_sandbox_xxx\script.py'
```

Root cause: `_resolve_child_python()` returned `sys.executable` (= `Hermes-OTG.exe`, the hermes CLI), so the script path was passed to the CLI as a subcommand.

## How the truth was found

1. `VIRTUAL_ENV` theory (standard Hermes behavior) — WRONG for this build.
2. Chased "env chain broken" — dead end: `HERMES_GIT_BASH_PATH` (set only in the .cmd) DID reach the backend, proving the chain works. Note: `HERMES_HOME`/`HERMES_OTG`/`TERMINAL_CWD` prove NOTHING — the Electron app sets them explicitly in `backend.env`.
3. Terminal tool env check lied — it strips `VIRTUAL_ENV`/`CONDA_PREFIX` deliberately (`tools/environments/local.py` `_ACTIVE_VENV_MARKER_VARS`), so `echo $VIRTUAL_ENV` is always empty.
4. **Decisive: decompiled the frozen exe.**

## Decompilation recipe (works for this build)

```bash
# pyinstxtractor MUST run under the build's Python version (3.11 here), else PYZ extraction is skipped
/c/OTG-Hermes/dependencies/python-311/python.exe pyinstxtractor.py "C:\OTG-Hermes\Hermes-OTG\Hermes-OTG.exe"

# Read bytecode of a module
/c/OTG-Hermes/dependencies/python-311/python.exe -c "
import marshal, dis
path = r'C:\Users\...\Temp\Hermes-OTG.exe_extracted\PYZ.pyz_extracted\tools\code_execution_tool.pyc'
code = marshal.loads(open(path, 'rb').read()[16:])   # 16-byte header on 3.11
for c in code.co_consts:
    if hasattr(c, 'co_name') and c.co_name == '_resolve_child_python':
        dis.dis(c)"
```

## Decompiled `_resolve_child_python` (OTG-patched, condensed)

Bytecode line numbers map to source ~1775-1815:

```
otg_py = os.environ.get('HERMES_OTG_PYTHON')        # ← line 1792 — OTG override, checked FIRST
if otg_py and os.path.isfile(otg_py):
    return otg_py                                   # ← wins over everything
if mode != 'project':
    return sys.executable
exe_names = ('python.exe', 'python3.exe'); subdirs = ('Scripts',)   # on Windows
for var in ('VIRTUAL_ENV', 'CONDA_PREFIX'):
    root = os.environ.get(var, '').strip()
    if not root: continue
    candidate = os.path.join(root, subdir, exe)
    if os.path.isfile(candidate) and os.access(candidate, os.X_OK) and _is_usable_python(candidate):
        return candidate
return sys.executable                               # ← the failure mode
```

Key facts:
- The OTG build ships a CUSTOM `HERMES_OTG_PYTHON` override that does NOT exist in GitHub main.
- `VIRTUAL_ENV` only matters if `HERMES_OTG_PYTHON` is unset.
- `_is_usable_python` = `python -c "import sys; sys.exit(0 if sys.version_info >= (3,8) else 1)"` (cached).
- `_get_execution_mode()` reads `code_execution.mode` from config.yaml; `project` is default. Frozen build (v2026.7.20 tag) confirmed to contain this code.

## The fix

All 3 launchers (`hermes.cmd`, `hermes-desktop.cmd`, `hermes-gateway-start.cmd`) got:

```bat
set "HERMES_OTG_PYTHON=%SCRIPT_DIR%\data\hermes-agent\venv\Scripts\python.exe"
set "VIRTUAL_ENV=%SCRIPT_DIR%\data\hermes-agent\venv"
```

Note the two SCRIPT_DIR forms: `hermes-desktop.cmd` uses `%SCRIPT_DIR%\data\...` (trailing backslash kept), `hermes.cmd`/gateway use `%SCRIPT_DIR%data\...` (no separator — SCRIPT_DIR keeps its trailing `\`).

## Two additional traps hit while editing the launchers

1. **CRLF corruption**: `patch`/`write_file` wrote LF into CRLF batch files; cmd.exe silently skipped the `set VIRTUAL_ENV` line. Verified `HERMES_HOME` (earlier line) flowed but `VIRTUAL_ENV` (later line) didn't. Fix: byte-level CRLF normalization, verify `data.count(b'\n') - data.count(b'\r\n') == 0`.
2. **`\v` escape**: Python heredocs interpreted `\venv` as vertical-tab (0x0b), corrupting the path. Fix: raw strings or `chr(92)` joins; verify via `line.hex()` for `0b`.

## Terminal vs execute_code env scrubbing (why checks diverge)

- `terminal` tool: `tools/environments/local.py` `_sanitize_subprocess_env` — strips `VIRTUAL_ENV`, `CONDA_PREFIX` (via `_ACTIVE_VENV_MARKER_VARS`) to avoid cross-project uv/poetry clobbering (#23473).
- `execute_code`: `tools/code_execution_tool.py` `_scrub_child_env` — `VIRTUAL_ENV` IS in `_SAFE_ENV_PREFIXES`, so it passes through.
- Consequence: `echo $VIRTUAL_ENV` in terminal is NOT evidence about the backend env. To prove launcher→backend env flow, use a var the Electron app only reads (e.g. `HERMES_GIT_BASH_PATH`).
