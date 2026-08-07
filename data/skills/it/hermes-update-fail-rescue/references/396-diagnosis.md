# os error 396 — uv hardlink failure during a Hermes update

## Error transcript (bootstrap-installer.log, dependencies stage)

```
error: Failed to install: referencing-0.37.0-py3-none-any.whl (referencing==0.37.0)
  Caused by: failed to hardlink file from C:\Users\<user>\AppData\Local\hermes\hermes-agent\venv\Lib\site-packages\referencing\py.typed to C:\Users\<user>\AppData\Local\uv\cache\archive-v0\...\referencing\py.typed: The cloud operation cannot be performed on a file with incompatible hardlinks. (os error 396)
```

Same error for `pydantic==2.13.4` and `typing-inspection==0.4.2`. The bootstrap
retries three tiers (all / all-minus-known-broken / core-only) — all fail the
same way — then: `bootstrap FAILED stage=Some("dependencies")`.

The updater prints its own fix in the same log:
> "If this is intentional, set `export UV_LINK_MODE=copy` or use `--link-mode=copy`"

## What 396 means

`ERROR_CLOUD_FILE_INCOMPATIBLE_HARDLINKS` — Windows refuses a hardlink because
the source/target file state is incompatible: cloud placeholders (OneDrive,
TeraBox, Yandex.Disk, ...), ReFS integrity-stream attributes, or files held by a
LIVE PROCESS running from the very directory being rebuilt (a gateway running
from the venv). `UV_LINK_MODE=copy` bypasses linking entirely and is immune to
all of these.

## Reproduction recipe (read-only, safe — do this BEFORE deciding the fix)

1. **Hardlink probe on the exact failing paths** (python):
   create a temp file + `os.link()` a hardlink copy in each of: the venv
   site-packages dir, the uv cache dir, the install home dir, and a control
   (system temp). Record winerror per path.
2. **Real uv code-path probe**: `uv venv <temp>/v && uv pip install --python <temp>/v/Scripts/python.exe six`
   — exercises download → cache → site-packages hardlink with DEFAULT link mode.
3. **Registry check**: `reg query "HKCU\Environment" /v HERMES_HOME` — must be the host path.
4. **Process check**: nothing with `hermes_cli` or the host venv path in its
   command line (gateway services survive the desktop closing — see SKILL.md).

Observed result in the 2026-08-06 incident (post-revert): ALL probes PASSED —
396 did not reproduce in a clean state. The original failure coincided with
live gateway services running FROM the venv during the rebuild (file
contention). Conclusion: keep `UV_LINK_MODE=copy` (structural immunity) AND
kill every Hermes process before updating.

## Installer source facts (install-main.ps1 — the script the updater runs)

- `$HermesHome = $(if ($env:HERMES_HOME) { $env:HERMES_HOME } else { "$env:LOCALAPPDATA\hermes" })` (≈ line 26)
- `$InstallDir = $(if ($env:HERMES_HOME) { "$env:HERMES_HOME\hermes-agent" } else { ... })` (≈ line 27)
  → a leaked `HERMES_HOME` env var REDIRECTS the entire update to the wrong install.
- `[Environment]::SetEnvironmentVariable("HERMES_HOME", $HermesHome, "User")` (≈ line 2085)
  → every install PERSISTS the value to `HKCU\Environment` (last run wins).
- `-NoPersistEnv` switch: NOT present in 0.19; planned for 0.20 enforcement.

## Cloud-provider note

The incident machine had TeraBox + Yandex.Disk cloud clients installed. Cloud
providers can mark directories with attributes that break hardlinks — check:
`powershell "Get-Item <dir> | Select FullName,Attributes"` — watch for
`0x80000` (INTEGRITY_STREAM) and `0x4000` (REPARSE_POINT) flags. Copy mode is
immune regardless of which provider/attribute is the culprit.
