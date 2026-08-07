---
name: computer-rescue-workflow
description: "Rescue machines: diagnose-first, backup-before-edit."
---

# Computer Rescue Workflow — Discipline Rules

Trigger: ANY hands-on repair / rescue / troubleshooting session on the user's
machine — VM recovery, disk repair, config patching, path fixing, MCP server
repair, log analysis that may lead to changes.

These rules were learned the hard way in a VMware VM rescue + OTG build
session. The user (Ringo) was burned by hasty, unapproved, unreported edits.
Follow them EVERY time.

## The 5 Commandments

1. **Diagnose first, report, THEN fix.**
   A request to "check the logs for errors" is NOT a request to fix them.
   Report findings and wait for an explicit "go ahead" / "fix it" before
   running any repair command. Jumping to patching without approval erodes
   trust fast and can make things worse (this user will call it out).

2. **Backup BEFORE any change — never after.**
   A backup created after the edits is worthless for rollback. Confirm the
   user's backup exists up front; make your own `.bak-YYYYMMDD-HHMM` copy
   before touching anything you edit. A `.bak` made after the fact is NOT a
   backup — the user knows this and will ask.

3. **Keep a running ledger of every file you modify.**
   Path + what changed + why. When a session involves many edits, the user
   WILL ask "what did you change in the past 30 minutes?" — you must answer
   precisely, without reconstructing it from memory. A visible todo list
   updated per-edit satisfies this.

4. **Stop changing things that already work.**
   If the user says a fix was tested and working earlier, VERIFY the timeline
   before "improving" it. Unapproved rework of a working state is how you
   break it. Check log timestamps before concluding a past fix failed.

5. **Async delegation by default; sync only on request.**
   Spawn subagents for heavy work so the user is never blocked. Wait for
   their result, then report. (Exception: user says "wait for it".)

## Typical sequence for a rescue

1. Ask/confirm backup exists. Record the backup path.
2. Read the relevant log(s) FIRST (`vmware.log`, `errors.log`, `mcp-stderr.log`).
   Quote the exact error lines back to the user.
3. Report diagnosis + proposed fix. STOP. Wait for approval.
4. On approval: backup every file you'll touch, then make surgical changes.
5. Verify the fix end-to-end (boot the VM, restart Hermes, run the tool).
6. Update the file-change ledger and report the full timeline of what changed.

## Session-specific playbooks

- **Any rescue step that RUNS an executable** (updaters, installers, CLIs, anything
  that reads env vars for paths/config) → ALSO load `skill_view(name='env-safe-execution')`
  as a companion skill. The env-leak risk (HERMES_HOME etc. leaking into subprocesses)
  applies to rescue scenarios — especially when a host install and the OTG coexist and the
  agent is running from inside the OTG.
- VMware VM won't boot after host crash → see `vmware-vm-crash-recovery`
  skill (delta disk repair via `vmware-vdiskmanager -R`). The `-R` command
  works on sparse delta disks; run it on the CURRENT delta from `.vmsd`.
- OTG Hermes MCP servers failing → user-owned `otg-mcp` / `otg-pip` skills
  govern installs/packages. Key patterns learned: uv trampolines must be
  replaced with real binaries; `.cmd` wrappers are NOT launchable by the MCP
  runner — use the venv's `python.exe -m <module> serve` directly with
  `PYTHONPATH: ''` in env; if ONE MCP server fails, TaskGroup cancellation
  cascades and can kill the other — fix both (absolute paths) or disable the
  broken one. Full incident log, config blocks, and a stdio verification
  recipe: `references/otg-mcp-troubleshooting.md`.
- OTG web tools (`web_search`/`web_extract`) → set in config.yaml:
  `web.backend: ddgs`, `web.search_backend: ddgs`,
  `web.extract_backend: trafilatura` (both installed in the internal 3.11
  venv). The `patch` tool refuses config.yaml — edit via a terminal python
  heredoc instead, after backing up. Backend change needs a Hermes restart.
- Config.yaml is security-guarded: `patch`/`write_file` refuse it. Use
  `python - <<EOF` heredoc via terminal, or `hermes config set`. ALWAYS back
  up first.

## Pitfalls

- **PowerShell quoting from git-bash:** `$` variables and backslash paths get
  mangled when passed through bash. Prefer writing a `.ps1`/`.py` file and
  executing it, or single-quote aggressively. Backslash Windows paths beat
  MSYS-style `/c/...` paths when calling native Windows tools.
- **`= ` in PowerShell:** `$var = '...'` inline in a bash-passed command
  breaks parsing — strip variables, inline the value.
- **Hermes config guards:** patch/write_file refuse `config.yaml`; the error
  suggests `hermes config` or editing `~/.hermes/config.yaml`. On OTG the
  config lives under `$HERMES_HOME/config.yaml`.
- **Don't fabricate recovery claims.** Report exit codes and log lines as
  evidence; verify the boot actually succeeded before declaring victory.

## Verification checklist

- [ ] Backup path recorded and confirmed with user
- [ ] Diagnosis quoted from logs (exact error strings)
- [ ] Explicit user approval obtained before any change
- [ ] Every edited file backed up first
- [ ] Fix verified end-to-end (not just "command ran")
- [ ] File-change ledger reported to user
