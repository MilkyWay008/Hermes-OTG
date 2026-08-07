@echo off
setlocal
REM ============================================================
REM  Hermes update rescue — run by the USER in a CLEAN shell
REM  Diagnosis: update failed at the dependencies stage.
REM  Root cause: uv hardlink failure, os error 396
REM  ("cloud operation ... incompatible hardlinks") on packages
REM  like pydantic / referencing / typing-inspection. The updater
REM  itself recommends the fix used below: UV_LINK_MODE=copy.
REM
REM  Safety built in:
REM    - Target forced to the HOST install (%LOCALAPPDATA%\hermes),
REM      never a portable/OTG install (aborts if the path contains
REM      'hermes-otg').
REM    - Portable env vars that could redirect the updater are
REM      scrubbed.
REM    - The USER runs this — never let a portable agent
REM      self-execute a host updater.
REM
REM  CRLF WARNING: this file must be saved with CRLF line endings
REM  (see otg-windows-troubleshooting Pitfall 1). Verify with:
REM    python -c "d=open(r'<this file>','rb').read(); print(d.count(b'\n')-d.count(b'\r\n'))"
REM  (must print 0)
REM ============================================================

echo [1/5] Checking target...
if defined HERMES_HOME (
    echo   NOTE: HERMES_HOME was set to: %HERMES_HOME%
    echo   Overriding it to the host install for this run.
)
set "HERMES_HOME=%LOCALAPPDATA%\hermes"
echo   Target: %HERMES_HOME%
echo %HERMES_HOME% | findstr /i "hermes-otg" >nul
if not errorlevel 1 (
    echo.
    echo   *** ABORT: target contains 'hermes-otg' — this would update a portable install!
    pause
    exit /b 1
)
if not exist "%HERMES_HOME%\hermes-setup.exe" (
    echo.
    echo   *** ABORT: %HERMES_HOME%\hermes-setup.exe not found.
    echo   Is Hermes installed under %LOCALAPPDATA%\hermes on this machine?
    pause
    exit /b 1
)

echo [2/5] Scrubbing portable env vars that could redirect the updater...
set "HERMES_OTG="
set "TERMINAL_CWD="
set "VIRTUAL_ENV="

echo [3/5] Setting the hardlink workaround (the updater's own recommended fix)...
set "UV_LINK_MODE=copy"
echo   UV_LINK_MODE=%UV_LINK_MODE%

echo [4/5] Running host updater...
cd /d "%HERMES_HOME%"
"%HERMES_HOME%\hermes-setup.exe" --update --branch main

echo.
echo [5/5] Update finished with exit code %errorlevel%
echo   Log: %HERMES_HOME%\logs\bootstrap-installer.log
echo   If it shows 'bootstrap FAILED', quote the last 20 lines to your agent.
pause
