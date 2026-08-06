# Python venv Isolation on Windows (Hermes contamination fix)

## Problem

When running Python commands from a project's venv via `terminal()`, the Hermes agent's own venv pollutes the Python import path. Even when explicitly invoking the project venv's Python binary (`apps/api/.venv/Scripts/python.exe`), imports like `google.protobuf` resolve to the Hermes venv instead of the project venv.

Symptom: `ImportError: cannot import name 'runtime_version' from 'google.protobuf'` when the project uses protobuf 6.x but Hermes has protobuf 5.x.

## Root Cause

The terminal shell inherits environment variables from the Hermes process:
- `VIRTUAL_ENV` points to the Hermes venv
- `PYTHONHOME` may be set
- `PYTHONPATH` or `sys.path` entries prioritize the Hermes venv
- `PATH` has the Hermes venv's `Scripts/` directory

## Fix

```bash
# Step 1: Unset Hermes venv environment variables
unset VIRTUAL_ENV PYTHONHOME PYTHONPATH

# Step 2: Prepend the project venv to PATH (before system Python and Hermes)
export PATH="/c/Projects/<project>/repo/apps/api/.venv/Scripts:/c/Users/<user>/AppData/Roaming/uv/python/cpython-3.12-windows-x86_64-none:/usr/bin:$PATH"

# Step 3: Verify — must show the PROJECT venv, not Hermes venv
python -c "import google.protobuf; print(google.protobuf.__file__)"
# Expected: C:\Projects\...\repo\apps\api\.venv\Lib\site-packages\google\protobuf\__init__.py
# Wrong:    C:\Users\<user>\AppData\Local\hermes\hermes-agent\venv\Lib\site-packages\google\protobuf\__init__.py

# Step 4: Also verify no Hermes paths in sys.path
python -c "import sys; print([p for p in sys.path if 'hermes' in p])"
# Expected: [] (empty list)

# Step 5: Run tests with the clean environment
python -m pytest apps/api/tests/ -q --tb=short
```

## One-liner for repeated use

```bash
unset VIRTUAL_ENV PYTHONHOME PYTHONPATH && export PATH="/c/Projects/<project-root>/repo/apps/api/.venv/Scripts:/c/Users/<user>/AppData/Roaming/uv/python/cpython-3.12-windows-x86_64-none:/usr/bin:$PATH" && python -m pytest apps/api/tests/ -q --tb=short
```

## Real-world result

- Before fix: `ImportError: cannot import name 'runtime_version' from 'google.protobuf'` — all 61 tests fail to collect
- After fix: 61 passed in 2.58s

## Why this matters for the task

The fix session needs to run `moon :test` and `pytest` frequently. Without this isolation, every test run fails with import errors. ~5 minutes can be lost debugging import issues that have nothing to do with the codebase.
