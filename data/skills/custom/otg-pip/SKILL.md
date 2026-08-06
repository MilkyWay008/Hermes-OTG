---
name: otg-pip
description: "TRIGGER: on OTG Hermes a Python package is missing or a feature won't load — 'module not found' / ImportError, web search via ddgs, extraction (trafilatura), PDF, SSH libs, or native allow_lazy_installs silently doing nothing."
author: Ringo/MilkyWay008
version: 0.1.0
platforms: [windows]
metadata:
  hermes:
    tags: [OTG, pip, venv, python, portable, windows]
    related_skills: [otg-mcp, hermes-agent]
---

# Installing Python Packages for Hermes on OTG (otg-pip)

Trigger: Hermes on an OTG (portable/USB) package needs a Python package that
isn't available — `module not found` / `ImportError`, a feature that needs pip
(web search via `ddgs`, extraction via `trafilatura`, PDF/SSH/compression
libraries, ...), or a package that should have lazy-installed but didn't.

## THE KEY FACT (read this first)

The frozen `Hermes-OTG.exe` **cannot lazy-install packages**. Hermes' native
`allow_lazy_installs` silently fails on OTG: `sys.executable` is the
PyInstaller bootloader (not a real python), and `uv` is not bundled. So any
optional module must be installed MANUALLY into the **INTERNAL venv**:

```
<OTG_ROOT>\data\hermes-agent\venv\
```

This venv is **Python 3.11** — it matches the frozen exe's ABI. Its
site-packages is appended to the frozen agent's `sys.path` at startup
(Option B runtime hook in `rthook_otg.py`), so ANYTHING installed there is
directly importable by Hermes. `fix-otg-paths` keeps its `pyvenv.cfg` home
pointing at the bundled 3.11 base (`dependencies\python-311`) on every launch.

Resolve `<OTG_ROOT>`: `dirname "$HERMES_HOME"` — `HERMES_HOME` is
`<OTG_ROOT>\data\` (note the trailing backslash).

## HARD RULES

- ALWAYS install into the INTERNAL venv with its own tools:
  `<OTG_ROOT>\data\hermes-agent\venv\Scripts\pip.exe`
  (or `<OTG_ROOT>\data\hermes-agent\venv\Scripts\python.exe -m pip`).
- NEVER use the host machine's pip/python — it installs into the HOST
  environment, not the OTG package, and breaks portability.
- NEVER install into the EXTERNAL venv (`dependencies\python\.venv`,
  Python 3.12) — that venv belongs to MCP servers and runs in SEPARATE
  processes. (MCP server deps go through the `otg-mcp` skill instead.)
- Compiled packages (`.pyd`) MUST be **cp311**-compatible — they import
  into the frozen 3.11 exe. Pure-Python wheels (`py3-none-any`) always work;
  `cp312` wheels will crash the agent with an ABI error.
- Remember the append-only world: the frozen PYZ modules always win over
  the internal venv. Don't try to "upgrade" a module that ships frozen
  (e.g. `httpx`, `pydantic`) — it won't take effect in the frozen process.

## STEPS

1. Confirm it's actually missing:
   `<OTG_ROOT>\data\hermes-agent\venv\Scripts\python.exe -c "import <pkg>"` → ImportError
2. Install into the INTERNAL venv:
   `<OTG_ROOT>\data\hermes-agent\venv\Scripts\pip.exe install <pkg>`
3. Verify:
   `<OTG_ROOT>\data\hermes-agent\venv\Scripts\python.exe -c "import <pkg>; print(<pkg>.__version__)"`
4. Done — the frozen agent can now import it. No restart needed if the
   import happens within the current session; restart Hermes if the package
   registers new tools/hooks so they get picked up at startup.

## TROUBLESHOOTING

| Symptom | Cause | Fix |
|---|---|---|
| `pip not found` in the internal venv | venv built without ensurepip / stub pip | Use `<venv python> -m pip install ...` |
| Compiled `.pyd` ImportError / ABI error | Wheel is cp312, exe is 3.11 | Report to the user; try a pure-Python (py3-none-any) alternative |
| No internet / connection error | Offline OTG machine | Cannot install new packages — pre-built features still work |
| Package installs but Hermes still says missing | Installed into the wrong venv (external/host) | Reinstall into `data\hermes-agent\venv` and restart Hermes |
| It's an MCP server, not a plain library | Wrong skill | Use `skill_view(name='otg-mcp')` instead |

## WHICH VENV? (when in doubt)

Ask: *"is this a library Hermes imports, or a server Hermes launches?"*

- **import → INTERNAL venv** (`data\hermes-agent\venv`, 3.11) — this skill.
- **launch → EXTERNAL/MCP venv** (`dependencies\python\.venv` or
  `mcp_servers\<name>\.venv`, 3.12) — the `otg-mcp` skill.
