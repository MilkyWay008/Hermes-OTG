---
name: env-safe-execution
description: "Check & scrub the environment before running executables that read env vars (updaters, installers, CLIs). A portable/OTG env (HERMES_HOME etc.) leaks into every subprocess and can redirect an app to the wrong install."
version: 1.0.0
author: OTG Hermes IT Agent
platforms: [windows]
metadata:
  hermes:
    tags: [env, subprocess, updater, installer, isolation, hermes-home, portable, otg]
    related_skills: [computer-rescue-workflow, otg-windows-troubleshooting, vmware-vm-crash-recovery]
---

# Env-Safe Execution — Check the Env Before You Execute

**TRIGGER:** about to run ANY executable that reads environment variables to resolve paths
or config — Hermes updaters/installers (`hermes-setup.exe --update`, `install.ps1`,
`hermes update`), package installers, SDK CLIs, clone/reclone scripts — ESPECIALLY when a
host install and a portable/OTG instance coexist on the same machine, or when working from
inside the OTG on host-machine tasks.

## The Core Lesson

An agent running an executable from inside a portable/isolated environment is NOT the same
as the user running it. **The user's shell is a clean host env; the agent's shell is a
contaminated portable env.** Every env var the wrapper exported (`HERMES_HOME`, `*_API_KEY`,
install paths, ...) is inherited by EVERY subprocess the agent spawns — and any env-sensitive
app (updaters, installers, CLIs, SDKs) can be silently redirected to the wrong target.

| | User's shell | Agent's shell (from inside OTG/portable) |
|---|---|---|
| Env | clean host env | portable env: `HERMES_HOME=E:\...`, `*_API_KEY`, install paths |
| `hermes-setup.exe --update` | targets the host install | CAN target the OTG install |

## The 5 Rules

### Rule 1 — CHECK THE ENV BEFORE EXECUTING

Before running ANY command that touches another install/app, inspect what the subprocess
would inherit:

```bash
cmd /c set HERMES_HOME
env | grep -i hermes
# or the target app's key vars: env | grep -iE 'API_KEY|INSTALL|HOME'
```

Know the leak before triggering it. If the command's target app reads env vars for
paths/config, you MUST know what those vars are and what the subprocess will see.

### Rule 2 — CLEAN-ENV OR EXPLICIT-TARGET

Scrub the portable env vars, or set them EXPLICITLY to the intended target, before running:

```bash
# scrub the portable vars (git-bash):
env -u HERMES_HOME -u HERMES_OTG -u TERMINAL_CWD <command>
# explicit target (cmd):
set "HERMES_HOME=%LOCALAPPDATA%\hermes" && <command>
```

NEVER rely on inherited values when the target is a different install.

### Rule 3 — VERIFY THE TARGET BEFORE UPDATERS/INSTALLERS

Before any install/update/reclone: confirm the InstallDir / HermesHome / target path
resolves to the INTENDED location (e.g. confirm it's `C:\host`, not `E:\otg`). Quote the
resolved path in your reasoning BEFORE executing. If the app logs what it resolved
(install log, `InstallDir=` line), read it after and compare against what you intended.

### Rule 4 — THE HAND-OFF PATTERN (most important)

If the operation is risky (update / install / reformat / reclone / disk ops), do NOT
execute it yourself in the contaminated env. Instead:

- **(a) Hand the script to the user** — write a `.cmd`/`.ps1` and tell the USER to run it.
  The user's shell is a clean host env.
- **(b) Schedule it for the SYSTEM** — `schtasks /create /sc once /st <time+5s> ...` or a
  delayed mechanism (cron), so the OS executes it with its own env, never yours.

You become the PLANNER, not the EXECUTOR, precisely when execution is dangerous.

### Rule 5 — NEVER PERSIST ENV FROM A PORTABLE INSTANCE

No `setx`, no `[Environment]::SetEnvironmentVariable`, no system/user PATH writes, no
registry env writes — ever. The portable instance must leave NO trace on the host's
persistent environment (a leaked `HERMES_HOME=E:\...` in `HKCU\Environment` is how a host
updater later resolves to the OTG install).

## When To Use

- Any troubleshooting that involves running executables which read env vars — especially
  updaters / installers / CLIs.
- Especially when a host install AND a portable/OTG instance coexist on one machine.
- Especially when the agent itself is running from inside the OTG and doing host work.
- Before `hermes update`, `hermes-setup.exe`, `install.ps1`, reclones, SDK installs, or
  ANY command whose target app resolves install paths from the environment.
- Companion skill for `computer-rescue-workflow` and `otg-windows-troubleshooting` — load
  it whenever those fire and execution is involved.

## Pitfalls

- **The 2026-08-06 incident (real):** the host Hermes updater ran from inside a portable
  "OTG Hermes" instance and targeted the OTG install (E:) instead of the host (C:),
  because the OTG wrapper exported `HERMES_HOME=E:\hermes-otg\data\` (hermes.cmd:7) and it
  leaked into the subprocess the agent spawned. The host updater read `$env:HERMES_HOME`,
  resolved `InstallDir=E:\hermes-otg\data\hermes-agent`, moved the OTG install aside
  (`hermes-agent.broken-20260806-015312`) and re-cloned it. Both desktops froze; the OTG
  install was corrupted (moved aside + re-cloned). The agent executing a file is DIFFERENT
  from the user executing the same file.
- **`HERMES_HOME` is read from the process env AND the registry:** the host updater's
  `resolveHermesHome()` reads `process.env.HERMES_HOME` AND the live `HKCU\Environment`
  value — so even a scrubbed subprocess can be redirected if a previous run persisted the
  var. See Rule 5.
- **`setx` writes are permanent:** a one-line `setx HERMES_HOME ...` from a rescue session
  can corrupt the next host update. Never use it from the OTG.
- **Inherited ≠ intended:** just because a var is set in your shell doesn't mean it's what
  the target app wants — a leaked `HERMES_HOME` is the DEFAULT, not the exception, when
  working from inside the OTG.

## Verification checklist

- [ ] Env inspected (`HERMES_HOME` + the app's key vars) BEFORE running the command
- [ ] Portable vars scrubbed or set explicitly to the intended target
- [ ] Target path resolved and quoted in reasoning (host vs OTG)
- [ ] Risky operation handed off (user script or scheduled task), not self-executed
- [ ] No `setx` / registry / persistent env writes from the portable instance
