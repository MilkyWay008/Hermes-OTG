---
name: hermes-update-fail-rescue
description: "Use when a Hermes update fails or won't start post-update."
version: 1.0.0
author: Ringo/MilkyWay008
url: https://github.com/MilkyWay008
platforms: [windows]
metadata:
  hermes:
    tags: [hermes, update, rescue, bootstrap, uv, hardlink, error-396, windows, gateway-service]
    related_skills: [env-safe-execution, computer-rescue-workflow, otg-windows-troubleshooting]
---

# Hermes Update-Fail Rescue

**TRIGGER:** the user reports "Hermes update failed", "Hermes won't start after an
update", "the update broke my install", or the desktop app sits forever on
"update in progress — deferring backend start". Also fires when the agent is
asked to fix a host Hermes install while itself running from a portable/OTG instance.

## The failure class

Hermes updates run a staged bootstrap (`hermes-setup.exe --update` → install
script). A failure mid-way leaves the install HALF-updated: new source + broken
venv = the app won't start. The three most common root causes (they combine):

| # | Root cause | Fix |
|---|---|---|
| 1 | **uv hardlink failure — os error 396** at the dependencies stage (`Failed to install: <pkg>` + "cloud operation ... incompatible hardlinks") | set `UV_LINK_MODE=copy` — uv copies instead of hardlinks |
| 2 | **Env leak redirects the updater to the wrong install** (a portable `HERMES_HOME` inherited by the host updater makes it target the portable install) | load `env-safe-execution`; scrub env / hand off |
| 3 | **Live Hermes processes hold the venv** (gateway services, dashboards) while the bootstrap rebuilds it → file contention, often surfacing AS #1 | stop every Hermes process BEFORE the update |

## Diagnose (read-only first — never run the updater yet)

1. **Logs** — `%LOCALAPPDATA%\hermes\logs\`:
   - `bootstrap-installer.log` — the updater's own log. Grep for `bootstrap FAILED`, `Failed to install`, `os error`, `stage=`, `InstallDir=`, `HermesHome=`.
   - `desktop.log` — "update in progress (pid=NNNN); deferring backend start" = updater died leaving a stale marker.
   - `errors.log` — `ModuleNotFoundError` at boot import = half-built venv.
2. **Markers** — `.hermes-update-in-progress` (stale if its PID is dead — kills the desktop's startup deferral), `.update_check`, `.update_exit_code`.
3. **Venv** — `hermes-agent\venv\Scripts\python.exe -c "import hermes_cli.main"` must import cleanly.
4. **Git** — `git rev-parse HEAD`, `git status --short` (note local patches BEFORE anything runs).
5. **Registry** — `reg query "HKCU\Environment" /v HERMES_HOME` — must be the HOST install, never a portable one.
6. **Hardlink reproduction** — `references/396-diagnosis.md` (python `os.link` probes + a real `uv pip install` into a throwaway temp venv). If 396 does NOT reproduce, the cause was transient (live-process file contention) — run the fix anyway; copy mode is harmless and makes the class impossible.

## The fix — write a .cmd, hand it to the user

NEVER self-execute a host updater from inside a portable/OTG instance
(env-safe-execution Rule 4). Use `templates/rescue-hermes-update.cmd` — it:
1. Forces `HERMES_HOME` to `%LOCALAPPDATA%\hermes` (the host) — overrides any leaked value
2. Scrubs portable vars (`HERMES_OTG`, `TERMINAL_CWD`, `VIRTUAL_ENV`)
3. Sets `UV_LINK_MODE=copy` (the updater's own documented fix for os error 396)
4. Verifies the target — aborts if the path contains `hermes-otg`
5. Runs `hermes-setup.exe --update --branch main`, prints the exit code, pauses

The USER runs it (clean shell). The agent watches `bootstrap-installer.log` live
and verifies after. The template ships LF — CRLF-convert before use
(`otg-windows-troubleshooting` Pitfall 1).

## Pre-update: stop every Hermes process (critical — easy to miss)

Closing the desktop app is NOT enough:
- **Gateway services** — `%LOCALAPPDATA%\hermes\gateway-service\Hermes_Gateway*.cmd`
  wrappers run `cmd /K ... pythonw -m hermes_cli.main gateway run` and SURVIVE the
  desktop closing. They run FROM the venv the update will replace.
- **Dashboards** — `python -m hermes_cli.main dashboard` (port 9xxx), also from the venv.
- Anything whose command line contains `hermes_cli` or the host venv path.

Kill the wrapper trees (`taskkill /PID <wrapper> /T /F`) and verify zero remain:
no `hermes_cli` processes, nothing running from the host venv, dashboard ports
free. These services launch manually with no autostart entry — safe to kill;
relaunch later via the same `Hermes_Gateway.cmd`.

## Post-update verification

- `.update_exit_code` = `0` and the log shows the final `state=Succeeded` + `launching Hermes desktop`.
- Version: `hermes-agent\venv\Scripts\python.exe -c "import hermes_cli; print(hermes_cli.__version__)"`.
- Desktop launches; a first-launch renderer "Timed out connecting to Hermes backend"
  is often transient — restart the desktop once before investigating.
- After a major version jump the bottom STATUS BAR may be missing — newer desktops
  made it OPT-IN (`view.toggleStatusbar`, default keybind Ctrl+Shift+S; per-item
  toggles via the bar's right-click menu; model pill relocated to the composer).
  It's a redesign, not a bug — tell the user how to bring it back.
- **Autostash conflicts**: the updater stashes local changes before pulling and
  restores them after. On conflict the update STILL SUCCEEDS but the changes stay
  in the stash (`git stash list` → `hermes-update-autostash-<ts>`; `git stash show
  --stat stash@{0}`; re-apply with `git stash apply <sha>`). Report this to the
  user — nothing is lost, but their patches are NOT in the working tree.

## Pitfalls

- **Half-updated state has NO rollback venv** — `venv.stale.*` husks are empty shells; never bet a rollback on them.
- **Stale marker blocks startup** — the desktop waits for a dead updater PID; clearing the marker (or killing the desktop, which clears its own) unblocks it.
- **`install-main.ps1` target resolution** — `$env:HERMES_HOME` WINS over the `%LOCALAPPDATA%\hermes` default (≈ line 26-27), and the installer PERSISTS the value to `HKCU\Environment` on every install (≈ line 2085). Always set the host path explicitly in the process env.
- **396 may not reproduce in a clean shell** — the trigger is often a live gateway holding the venv; do the process cleanup AND keep copy mode.
- **`.cmd` deliverables must be CRLF** — verify bare-LF count == 0 before hand-off.
- **Test batch files via python subprocess**, not `cmd //c` from git-bash (stdout swallowed) — `otg-windows-troubleshooting` Pitfall 3.
- **Two CWDs during a host rescue** — `cd`-ing into the host repo in the terminal ALSO pollutes the session record in state.db (`sessions.cwd`/`git_branch`/`git_repo_root`), making the desktop app offer commit for the host repo. Fix both: `cd` back AND `UPDATE sessions ...` — see `references/state-db-session-cwd.md`.

## Verification checklist (before hand-off)

- [ ] Diagnosis quoted from logs (exact error strings, timestamps checked)
- [ ] Registry HERMES_HOME verified = host
- [ ] All Hermes processes stopped (gateway services + dashboards included)
- [ ] Rescue .cmd CRLF-verified; guard logic tested (safe-abort run + OTG-target trip)
- [ ] USER runs the .cmd (hand-off — never self-execute from a portable env)
- [ ] Post-update: exit code 0, version correct, desktop healthy, stash conflicts reported

## Support files

- `templates/rescue-hermes-update.cmd` — known-good rescue script; copy, CRLF-convert, hand off
- `references/396-diagnosis.md` — error transcript, reproduction recipe, installer source facts
- `references/state-db-session-cwd.md` — the two-CWD trap: terminal `cd` into a repo pollutes `sessions.cwd`/`git_branch`/`git_repo_root` in state.db, which the desktop reads; backed-up `UPDATE` fix
