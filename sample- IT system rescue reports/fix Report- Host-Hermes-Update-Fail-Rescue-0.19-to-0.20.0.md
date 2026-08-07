# Host Hermes Update Rescue — 0.19 → 0.20.0 (os error 396 → UV_LINK_MODE=copy)

**Date:** 2026-08-07
**Author:** OTG Hermes IT Agent
**Type:** Fix Report (Incident + Rescue)
**Machine:** SW-Sky2k (host; Windows build 26100)

---

## Executive Summary

The host Hermes install (0.19.0) had failed a 0.19 → 0.20 update **three days of attempts
earlier** at the Python-dependencies bootstrap stage, leaving it half-updated and unable to
start. A prior rescue attempt by the portable OTG agent had **corrupted the OTG install
itself** (environment leak redirected the host updater to the portable install — see
`Report-for-Jack-OTG-update-incident.md`, 2026-08-06). After a machine-level revert restored
the host to clean 0.19.0 and the OTG was rebuilt, the rescue was re-attempted on 2026-08-07
with a corrected procedure:

1. **Diagnosed read-only** — confirmed clean 0.19.0 host state, correct registry `HERMES_HOME`,
   and reproduced the *absence* of the hardlink failure (transient cause).
2. **Stopped every Hermes process** — including background **gateway services** that survive
   closing the desktop app and hold the venv (the true trigger of the original os error 396).
3. **Handed off a guarded rescue `.cmd`** to the user (never self-executed from the portable
   env) that forces the host target, scrubs leaky env vars, and sets **`UV_LINK_MODE=copy`** —
   the updater's own documented fix.
4. **Update completed end-to-end**: 4,338 commits pulled, dependencies installed cleanly
   (no 396), desktop app rebuilt, new 0.20.0 desktop launched automatically. Exit code 0.

**Net result:** host Hermes healthy on **0.20.0**; local custom patches preserved in a stash
(pending deliberate conflict-resolution merge); portable OTG install untouched; two new/updated
skills (`hermes-update-fail-rescue`, `env-safe-execution`) in place for the next build.

---

## Diagnosis

### Symptom

- Host Hermes stuck on 0.19.0 after a failed 0.20 update; the desktop app sat forever on
  *"update in progress (pid=13744); deferring backend start until it finishes"* — the updater
  process was **dead**, the marker stale.
- The half-built venv could not import the CLI (`ModuleNotFoundError: No module named 'dotenv'`),
  so Hermes physically could not start.

### Findings (read-only)

**1. The updater's own log — `%LOCALAPPDATA%\hermes\logs\bootstrap-installer.log`**
```
bootstrap FAILED stage=dependencies
error: Failed to install: referencing-0.37.0-py3-none-any.whl (referencing==0.37.0)
  Caused by: failed to hardlink file from ...\venv\Lib\site-packages\referencing\py.typed
             to ...\uv\cache\archive-v0\...: The cloud operation cannot be performed on a
             file with incompatible hardlinks. (os error 396)
error: Failed to install: pydantic-2.13.4 ... (os error 396)
error: Failed to install: typing-inspection-0.4.2 ... (os error 396)
[!] Tier 'all' failed (exit 2). Trying next tier...   (all 3 tiers failed identically)
```
The updater itself printed the fix: *"set `export UV_LINK_MODE=copy` ... to suppress this warning."*

**2. Installer target resolution — `bootstrap-cache\install-main.ps1` (lines 26-27, 2083-2086)**
```powershell
$HermesHome = $(if ($env:HERMES_HOME) { $env:HERMES_HOME } else { "$env:LOCALAPPDATA\hermes" })
$InstallDir = $(if ($env:HERMES_HOME) { "$env:HERMES_HOME\hermes-agent" } else { "$env:LOCALAPPDATA\hermes\hermes-agent" })
...
[Environment]::SetEnvironmentVariable("HERMES_HOME", $HermesHome, "User")   # persists on EVERY install
```
`$env:HERMES_HOME` **wins** over the host default — the single line that made the earlier
env-leak corruption possible, and the line the rescue `.cmd` must explicitly override.

**3. Process inventory — background gateway services (critical, easy to miss)**
```
cmd.exe  /K "C:\Users\...\hermes\gateway-service\Hermes_Gateway.cmd"          -> pythonw -m hermes_cli.main gateway run
cmd.exe  /K "C:\Users\...\hermes\profiles\gf-helen\gateway-service\Hermes_Gateway_gf-helen.cmd"  -> pythonw ... gateway run
python.exe -m hermes_cli.main dashboard --no-open --host 0.0.0.0 --port 9119   (x2, one from the venv)
python.exe -m src ...                                                          (runs FROM the host venv)
```
These survive closing the desktop app, run **from the very venv the update replaces**, and are
what the updater's *"waiting for Hermes to exit"* stage blocks on. No autostart entries exist
(no Startup shortcuts, no scheduled tasks) — they were launched manually and are safe to stop.

**4. Registry check**
```
HKEY_CURRENT_USER\Environment
    HERMES_HOME  REG_SZ  %LOCALAPPDATA%\hermes    <- correct HOST value
```

**5. Hardlink reproduction — did NOT reproduce (transient cause confirmed)**
Python `os.link` probes in the uv-cache path, venv site-packages, and hermes home: **all
`LINK_OK`**. A real `uv pip install six` (default hardlink mode) into a throwaway temp venv:
**installed in 66ms, exit 0**. Conclusion: the 396 condition was transient — most plausibly
the live gateway holding the venv mid-rebuild. The fix (`UV_LINK_MODE=copy`) was applied anyway
because copy mode makes the failure class *structurally impossible* regardless of the trigger.

### Root Cause

Two compounding failure modes:

| # | Mode | Evidence | Fix |
|---|------|----------|-----|
| 1 | **uv hardlink failure (os error 396)** at the dependencies stage — uv could not hardlink wheel files (`referencing`, `pydantic`, `typing-inspection`) into/from the cache; cloud-incompatible-hardlink error; 3 install tiers failed identically | `bootstrap-installer.log` transcript above | `UV_LINK_MODE=copy` (updater's own documented fix) |
| 2 | **Live Hermes processes holding the venv** during the rebuild (gateway services + dashboards) — the file contention behind the hardlink errors, and the reason the updater's "waiting for Hermes to exit" stage stalls | process inventory above; gateway services survive desktop close | Stop every Hermes process BEFORE re-running the updater |
| 3 | *(pre-existing, from 08-06)* **Env leak redirecting the host updater to a portable install** — `HERMES_HOME` inherited from the portable wrapper + `install-main.ps1` trusting it | `Report-for-Jack-OTG-update-incident.md` | `env-safe-execution` skill; explicit host target; hand-off |

---

## Fix Applied

### Tool Used

A guarded, user-run rescue batch file (`rescue-hermes-update.cmd`) that:
1. Forces `HERMES_HOME=%LOCALAPPDATA%\hermes` (the host) — overrides any leaked value
2. Verifies the target — **aborts if the path contains `hermes-otg`** (portable-install guard)
3. Scrubs portable vars (`HERMES_OTG`, `TERMINAL_CWD`, `VIRTUAL_ENV`)
4. Sets **`UV_LINK_MODE=copy`** (the 396 fix)
5. Runs `hermes-setup.exe --update --branch main`, prints the exit code, pauses

The USER executed it from their clean shell (the agent never self-executes a host updater from
the portable env — `env-safe-execution` Rule 4). Template: `templates/rescue-hermes-update.cmd`
(CRLF-verified: bare LF = 0; guard logic tested via Python `subprocess.run(['cmd','/c',...])`).

### Steps

1. **Pre-flight diagnosis (read-only)** — host state snapshot: git HEAD `477c08b44` (pre-update
   commit, clean 0.19.0), venv python 3.11.15 healthy, no stale `.hermes-update-in-progress`
   marker, uv cache populated, 3.6 TB free, registry `HERMES_HOME` = host.
2. **Stopped every Hermes process** (user-approved): desktop app, both gateway-service trees
   (default + `gf-helen` profile), both dashboards on :9119, the `-m src` venv holder, and an
   orphaned echo-plugin poller. Verified: zero `hermes_cli` processes, zero processes from the
   host venv, port 9119 free.
3. **Fixed the two-CWD trap** — `cd`-ing into the host repo during diagnosis had also rewritten
   the *session record* in state.db (`sessions.cwd`/`git_branch`/`git_repo_root` → host repo,
   making the desktop offer "commit" for the host). Fixed both: terminal `cd` back to the
   workspace AND a backed-up `UPDATE sessions` (see `references/state-db-session-cwd.md`).
4. **User ran the rescue `.cmd`** (hand-off). Updater observed live via
   `bootstrap-installer.log`:
   - `waiting for Hermes to exit` — passed in **6 seconds** (all processes were gone)
   - Autostash engaged: `Saved working directory and index state ... hermes-update-autostash-20260807-080317`
   - **Git pull: 4,338 commits** (`477c08b44` → `99237a444`) — the full 0.19→0.20 jump
   - **Dependencies installed cleanly** — `~ hermes-agent==0.20.0`, 100 packages,
     **zero os error 396** (`UV_LINK_MODE=copy` working)
   - Desktop rebuild: npm `added 209 packages` + `added 466 packages`; web frontend
     `✓ built in 2.72s`; `win-unpacked` regenerated at 08:19
   - **Success:** `stage=update state=Succeeded duration_ms=981523` → `stage=rebuild Succeeded`
     → `launching Hermes desktop exe_path=...\apps\desktop\release\win-unpacked\Hermes.exe`
5. **Post-update verification** (see below).

### Stage-by-stage evidence (from `bootstrap-installer.log`)

| Time (UTC) | Event |
|---|---|
| 08:03:11 | `Hermes Setup starting mode=Update` |
| 08:03:13 | `[update] waiting for Hermes to exit…` |
| 08:03:19 | `Saved working directory and index state On main: hermes-update-autostash-20260807-080317` |
| 08:04:49 | dependency install listing — `+ referencing==0.37.0`, `+ typing-inspection==0.4.2` (the 396 victims, now installing) |
| 08:05:31 | `~ hermes-agent==0.20.0 (from file:///C:/Users/.../hermes-agent)` — package built & installed |
| 08:08:27 / 08:10:00 | `added 209 packages in 3m` / `added 466 packages in 2m` (npm) |
| 08:12:00 | `✓ built in 2.72s` (web_dist frontend) |
| 08:19:35 | `update stage stage=update state=Succeeded duration_ms=Some(981523)` |
| 08:19:39 | `✓ Desktop packaged app ready: ...\win-unpacked\Hermes.exe` |
| 08:19:40 | `launching Hermes desktop exe_path="...\win-unpacked\Hermes.exe"` |

### Recovery Time

~20 minutes from pre-flight start to the new desktop auto-launching (update itself: 16 minutes).

### Pitfalls Encountered

1. **Gateway services survive closing the desktop app** — `gateway-service\Hermes_Gateway.cmd`
   wrappers run `cmd /K ... pythonw -m hermes_cli.main gateway run` from the venv. The updater
   waits on them and they hold the venv. **Kill the wrapper trees, not just the desktop.**
2. **os error 396 did not reproduce in a clean shell** — simple hardlink probes and a real
   `uv pip install` both succeeded post-revert. The trigger was transient (live-process file
   contention). Keep `UV_LINK_MODE=copy` regardless — it is the permanent, structural answer.
3. **Autostash conflict — nothing lost, but patches not applied.** The update reported
   *"restoring local changes hit conflicts"* (upstream 0.20 changed `gateway/platforms/api_server.py`).
   The bootstrap preserved the stash: `stash@{0} hermes-update-autostash-20260807-080317`
   (5 files, 211 insertions / 2 deletions), and the log printed the exact restore command
   (`git stash apply f8cf6a3c...`). Do NOT blind-pop into a fresh install — resolve per-file.
4. **Two CWDs during a host rescue** — terminal `cd` into the host repo also rewrites the
   session record in state.db (the desktop's "commit this repo" prompt). Fix both; documented.
5. **Status bar "missing" after the jump is a redesign, not damage** — 0.20 made the bottom bar
   opt-in (`store/statusbar-prefs.ts`: `$statusbarVisible` default `false`, VS Code
   `workbench.statusBar.visible` model). Restore: **Ctrl+Shift+S** (`view.toggleStatusbar`,
   keybind `mod+shift+s`); per-item toggles via the bar's right-click menu; the model pill
   relocated to the composer.
6. **Portable drive letter changed mid-mission** (E: → F:) — all absolute paths in scripts/notes
   must stay letter-agnostic (`%LOCALAPPDATA%`, `<OTG_ROOT>`); the physical stick is the constant.
7. **`cmd //c` from git-bash swallows the child's stdout** — test batch scripts via Python
   `subprocess.run(['cmd','/c',...])`, not `cmd //c` (documented in `otg-windows-troubleshooting`).

---

## Post-Fix Verification

| Check | Result |
|---|---|
| `.update_exit_code` | `0` (clean exit) |
| Version | `hermes_cli.__version__` = **0.20.0** (pyproject + `__init__.py` both 0.20.0) |
| Commit span | `git rev-list --count 477c08b44..HEAD` = **4,338 commits** (full codebase updated, not just the desktop app) |
| Repo currency | `.update_check` → `behind: 2` (essentially current with main) |
| Desktop | New `win-unpacked\Hermes.exe` launched automatically; backend ready; first-launch renderer connect timeout was transient |
| Status bar | Restored via Ctrl+Shift+S (opt-in redesign) |
| Local patches | `stash@{0} hermes-update-autostash-20260807-080317` — preserved, 5 files (211+/2-), NOT applied (conflict in `api_server.py`) — pending deliberate merge |
| Portable OTG install | Untouched — still running, `data\hermes-agent` (stub + venv) intact |
| Registry | `HERMES_HOME` still = host (persisted value is the host path; no contamination) |

---

## Follow-up Items

1. **Merge the stashed patches deliberately** — inspect `git stash show --stat stash@{0}`,
   resolve the `gateway/platforms/api_server.py` conflict against 0.20 upstream, and decide
   per-file whether each patch still applies or upstream now covers it. Best done in a
   dedicated session (or at next-build time, when the OTG-support patches are actually needed).
2. **Next-build enforcement (0.20 roadmap, from the 08-06 incident report)** — `-NoPersistEnv`
   switch, `HERMES_OTG` gating on update IPC/menu, hard OTG-mode error instead of bootstrap
   fallback, `resolveHermesHome()` registry-skip in OTG mode, per-install `.env` override,
   wrapper env-scrub, upstream updater target validation.
3. **Skills delivered for the next build** — `hermes-update-fail-rescue` (verified, patched
   with the status-bar note; template + 2 references), `env-safe-execution` (installed),
   `computer-rescue-workflow` (cross-linked). All generic (user/agent), no names, portable paths.

---

## Recommendation

- **The 396 class is closed** — ship `UV_LINK_MODE=copy` guidance with any bootstrap that uses
  uv hardlinks on Windows; it costs nothing and removes a whole failure class.
- **Document the process-cleanup step in the updater itself** — the "waiting for Hermes to exit"
  stage should stop (or at least list) gateway-service processes, since they survive the desktop
  closing and hold the venv.
- **Never run a host updater from a portable instance** — enforce with the `HERMES_OTG` gating in
  the next build; until then the `env-safe-execution` rules are the guard.
- **Keep the stash where it is** until the merge is deliberate; the running 0.20.0 is clean and
  the patches are safe.
- **Any future "update failed" report**: load `hermes-update-fail-rescue` → diagnose read-only →
  stop all Hermes processes → hand off the guarded `.cmd` → verify → report the stash.

---

## Appendix — Key Commands & Evidence Strings

```bash
# Diagnosis (read-only)
tail -c 6000 %LOCALAPPDATA%\hermes\logs\bootstrap-installer.log | grep -aE "bootstrap FAILED|os error 396|Failed to install|InstallDir="
reg query "HKCU\Environment" /v HERMES_HOME
venv\Scripts\python.exe -c "import hermes_cli.main"          # half-built venv probe
git rev-parse --short HEAD && git stash list                 # source state + autostash

# Hardlink reproduction (transient — expected NOT to fail post-incident)
python - <<'PY'   # os.link probes on uv-cache / site-packages / temp + real `uv pip install six` into temp venv
PY

# Process cleanup (user-approved)
taskkill /PID <gateway-wrapper-pid> /T /F                    # /T kills the gateway tree
powershell -NoProfile -Command "Get-CimInstance Win32_Process | ? { $_.CommandLine -match 'hermes_cli' }"

# The fix (hand-off .cmd — see templates/rescue-hermes-update.cmd)
set "HERMES_HOME=%LOCALAPPDATA%\hermes" && set "UV_LINK_MODE=copy" && hermes-setup.exe --update --branch main

# Verification
python -c "import hermes_cli; print(hermes_cli.__version__)"   # 0.20.0
git rev-list --count 477c08b44..HEAD                            # 4338
git stash show --stat stash@{0}                                 # the preserved patches
```
