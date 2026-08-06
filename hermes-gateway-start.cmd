@echo off
REM Hermes OTG — API Server Launcher
REM Starts the Hermes API server on port 7642 (no full gateway).

setlocal enabledelayedexpansion
set "SCRIPT_DIR=%~dp0"
set "HERMES_HOME=%SCRIPT_DIR%data\\"
set "HERMES_OTG=1"
set "API_SERVER_PORT=7642"
set "API_SERVER_KEY=WtHOANYdb5uJesFphXrf47KGxokz0ilR6MCmDg9cwZByTv2ELPqIUaj3SQ1nV8"
set "HERMES_GIT_BASH_PATH=%SCRIPT_DIR%git\bin\bash.exe"
set "TERMINAL_CWD=%SCRIPT_DIR%workspace"
set "HERMES_DESKTOP_CWD=%SCRIPT_DIR%workspace"
set "HERMES_OTG_PYTHON=%SCRIPT_DIR%data\hermes-agent\venv\Scripts\python.exe"
set "VIRTUAL_ENV=%SCRIPT_DIR%data\hermes-agent\venv"
set "HERMES_LAZY_INSTALL_TARGET=%SCRIPT_DIR%data\lazy-packages"

REM ---- Bundled cua-driver (computer_use toolset) ----
REM computer_use tools spawn cua-driver (stdio MCP) via HERMES_CUA_DRIVER_CMD
REM (authoritative override; see tools/computer_use/cua_backend.py). Staged
REM as dependencies\cua\cua-driver.exe (+ cua-driver-uia.exe UIAccess worker) by
REM assemble-otg-package.sh from full-otg/otg-cua/.
if exist "%SCRIPT_DIR%dependencies\cua\cua-driver.exe" (
    set "HERMES_CUA_DRIVER_CMD=%SCRIPT_DIR%dependencies\cua\cua-driver.exe"
) else (
    echo [WARN] bundled cua-driver not found - computer_use tools unavailable
)

REM ---- Bundled browser stack (node + agent-browser + Chromium) ----
REM browser_* tools need the agent-browser CLI (data\node is prepended to
REM PATH by fix-otg-paths) and AGENT_BROWSER_EXECUTABLE_PATH pointing at
REM the bundled Chrome. Glob the version dir so Chrome updates don't
REM require editing this wrapper. (Two-step glob: Windows dir cannot
REM wildcard a MIDDLE path component, i.e. "chrome-*\chrome.exe" fails
REM with "syntax is incorrect" — glob the dir, then append chrome.exe.)
for /f "delims=" %%d in ('dir /b /s /ad "%SCRIPT_DIR%data\node\chromium\chrome-*" 2^>nul') do set "AGENT_BROWSER_EXECUTABLE_PATH=%%d\chrome.exe"
if not defined AGENT_BROWSER_EXECUTABLE_PATH echo [WARN] bundled Chrome not found - browser tools unavailable

REM ---- Clean stale runtime locks (from crashed/force-killed sessions) ----
if exist "%HERMES_HOME%gateway.lock"    del /q "%HERMES_HOME%gateway.lock"
if exist "%HERMES_HOME%gateway.pid"     del /q "%HERMES_HOME%gateway.pid"
if exist "%HERMES_HOME%auth.lock"       del /q "%HERMES_HOME%auth.lock"
if exist "%HERMES_HOME%state\gateway.heartbeat" del /q "%HERMES_HOME%state\gateway.heartbeat"
if exist "%HERMES_HOME%logs\.__gateway.lock"    del /q "%HERMES_HOME%logs\.__gateway.lock"
if exist "%HERMES_HOME%.models_dev_cache_*.tmp" del /q "%HERMES_HOME%.models_dev_cache_*.tmp"

REM ---- OTG path/venv repair (idempotent; every launch) ----
call "%SCRIPT_DIR%dependencies\scripts\fix-otg-paths.cmd"

echo.
echo ========== Hermes OTG — API Server ==========
echo Data dir: %HERMES_HOME%
echo API port: 7642
echo Gateway:  OFF (use CLI mode for interactive chat)
echo.
echo Launching API server...
echo.

"%SCRIPT_DIR%Hermes-OTG\Hermes-OTG.exe" gateway run

