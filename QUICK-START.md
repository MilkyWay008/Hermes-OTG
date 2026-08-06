# Hermes OTG — Quick Start

> The fast, practical guide to getting Hermes OTG running and using it.
> For the full overview, features, and architecture, see the repo front page (`README-repo.md`).

---

## 🚀 Launch

Three launchers sit at `<OTG_ROOT>` (the folder containing this guide):

| Launcher | What it does | Who it's for |
|----------|-------------|--------------|
| **`hermes-desktop.cmd`** | Opens the full desktop app (recommended) | ✅ **Everyone — start here** |
| `hermes.cmd` | Text-based terminal UI (TUI) | Advanced users |
| `hermes-gateway-start.cmd` | Runs only the API server (port 7642) | Advanced / programmatic use |

> **If you're not sure which to use, always start with `hermes-desktop.cmd`.**

The first launch may take a few seconds to prepare (paths are re-pointed to the current drive automatically). After that it's instant.

---

## 📂 Key locations

Everything the agent uses lives inside this folder:

| What | Where |
|------|-------|
| **System prompt / personality** (edit to customize the agent) | `data\SOUL.md` |
| **API keys** (edit to add your own) | `data\.env` |
| **Main configuration** (models, tools, MCP servers) | `data\config.yaml` |
| **Memory** (user profile, saved facts) | `data\memories\` |
| **Sessions & state** | `data\state.db` |
| **Working folder** (where the agent does file work by default) | `workspace\` |
| **MCP servers** (installed per-machine) | `mcp_servers\` |
| **Bundled Python + tooling** | `dependencies\` |

---

## 🔑 First Run — Set Your Own API Keys

The release ships with a **free NVIDIA API key** (from build.nvidia.com, ~40 requests/min) so it works out of the box for testing — **not intended for production** (free keys are slow and rate-limited).

For real use:
1. Add your own keys in `data\.env`
2. **Also update the vision model** in `data\config.yaml` (`auxiliary.vision`) so the agent can "see" with a model that matches your key

---

## 🛠 Adding Your Own MCP Servers

New MCP servers are installed **inside this folder** at `mcp_servers\<name>\`:

1. **Ask the agent to add a server** — it knows the proper portable way (bundled Python, never the host machine's Python/uv)
2. Or load the **`otg-mcp`** skill for the full procedure
3. After adding a server to `config.yaml`, **restart the app** — it will be picked up automatically

---

## 🎨 Customizing

- **Agent personality** — edit `data\SOUL.md` (loaded fresh every message)
- **API keys / models** — edit `data\.env` and `data\config.yaml`
- **Config templates** — `data\config.yaml.template-*` / `data\.env.template-*` are clean starting points if you want to regenerate a fresh config

---

## 🛠 Maintenance

- **Performance tip.** For the best experience, avoid running OTG Hermes from a slow USB drive — especially drives with slow I/O on many tiny files (the agent reads/writes lots of small files: skills, memory, state).
- **Memory full?** If the agent reports its memory is full, ask it to use the **`memory-index`** skill to re-index `MEMORY.md` — that frees significant space by moving older entries into the tiered storage.
- **Updates are OFF by design.** This OTG build is specially built and forked from the main Hermes, so the in-app update feature is turned off — each Hermes update would require the whole OTG bundle to be rebuilt. To get the latest OTG Hermes, watch for a new release by its author **Ringo/MilkyWay008**, published shortly after major Hermes updates (e.g. 0.19 → 0.20 → 0.21).

---

## 📖 Talking About Paths

See **`Cheatsheet-OTG_path_env.md`** — how to reference OTG-style paths (`$HERMES_HOME`, `<OTG_ROOT>`) when instructing the agent, plus Windows gotchas.

---

*Hermes OTG — every machine deserves a smart layer.*
