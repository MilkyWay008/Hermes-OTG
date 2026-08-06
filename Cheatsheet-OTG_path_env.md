# Hermes OTG — Path & Environment Cheatsheet

> How to tell the OTG agent where things live, and how to write paths that
> resolve correctly on ANY machine the USB is plugged into.

## 🔑 The core idea

There is **NO template expansion** in SOUL.md (or MEMORY.md / any Hermes system
md) — they are injected as **raw text**. But the OTG agent CAN resolve paths at
runtime, because the terminal tool inherits the wrapper's environment variables.

Use **`$HERMES_HOME`** — it is Hermes' own established convention.

---

## 📍 Paths (OTG)

```
USER.md      lives at  $HERMES_HOME/memories/USER.md
MCP servers  live at   <OTG_ROOT>/mcp_servers/

To resolve at runtime, run in the terminal:
  echo "$HERMES_HOME"        → e.g. D:\hermes-otg\data\
  dirname "$HERMES_HOME"     → e.g. D:\hermes-otg   ← this is OTG_ROOT
```

Why it works:
- The wrapper `.cmd` files set `HERMES_HOME=<otg-root>\data\`
- The terminal tool runs bash with that env inherited
- `dirname "$HERMES_HOME"` gives the OTG root — the agent computes it itself
- Python code uses `get_hermes_home()` which resolves correctly in the frozen binary

Suggested SOUL.md wording:

```markdown
## Paths (OTG)
- USER.md lives at `$HERMES_HOME/memories/USER.md`
- MCP servers live at `<OTG_ROOT>/mcp_servers/`
- Resolve at runtime:
  - `echo "$HERMES_HOME"`    → e.g. D:\hermes-otg\data\
  - `dirname "$HERMES_HOME"` → e.g. D:\hermes-otg   (this is OTG_ROOT)
```

---

## ⚠️ Three Windows gotchas (note these in SOUL.md / MEMORY.md / any system md)

1. **Trailing backslash** — `HERMES_HOME` ends with `\` (`...\data\`). Write
   joins as `$HERMES_HOME/memories/USER.md` (forward slashes work in bash).

2. **`cygpath`** converts between `C:\...` and `/c/...` forms if needed.

3. **⚠ DO NOT use `$VAR` in `config.yaml` `mcp_servers.command:`** — it is
   **NOT expanded** there (only `os.path.expanduser` is applied). For MCP server
   commands in config, keep using **relative paths** (`../mcp_servers/...`).

---

## 📋 Summary — the 3 differences

| Where | Use | Why |
|-------|-----|-----|
| **SOUL.md / system md (prose)** | `$HERMES_HOME/...` + the `dirname` recipe | Agent expands at runtime via terminal |
| **config.yaml** MCP commands | relative `../mcp_servers/...` | `$VAR` is NOT expanded there |
| **Python / scripts** | `get_hermes_home()` | Resolves correctly in frozen binary |

---

## 🐍 OTG Python (bundled)

- The OTG package ships its **own real CPython 3.12** at `<OTG_ROOT>\dependencies\python\`
- All OTG venvs are built with it (`python -m venv`) — never use the host machine's
  python/uv for OTG venvs
- The agent's PATH `python` resolves to it (wrappers prepend via `fix-otg-paths`)
- MCP server installs: load the **`otg-mcp`** skill first

## 🔧 Path portability (automatic)

`dependencies\scripts\fix-otg-paths` runs on every launch: rewrites `pyvenv.cfg
home =`, de-trampolines uv stubs, rescans for new MCP venvs, and prepends the
package dirs to PATH. Manifest: `dependencies\scripts\fix-otg-paths.json`.
