# Sysinternals Suite & windows-mcp Tool Usage (OTG build)

Recorded 2026-08-04 while verifying the OTG sysinternals folder and testing
windows-mcp end-to-end (launch Edge → YouTube Kids).

## 1. Sysinternals location & completing missing tools

- Location: `<OTG_ROOT>\mcp_servers\windows-mcp\sysinternals\` (28 tools shipped;
  +3 after adding procexp = 31 `.exe`).
- The shipped set is CLI-heavy (pslist, handle, sigcheck, strings, tcpvcon,
  PsExec, etc.). **procexp (Process Explorer GUI) is NOT part of the default
  set** — it must be added manually if wanted.
- Completing the suite (proven recipe):
  1. Download official zip (HTTP 200, ~3.5 MB):
     `curl -sL "https://download.sysinternals.com/files/ProcessExplorer.zip" -o procexp.zip`
  2. Extract: contains `procexp.exe` (32-bit), `procexp64.exe`, `procexp64a.exe`, `Eula.txt`.
  3. **Verify signature with the bundled sigcheck BEFORE trusting it:**
     `<OTG_ROOT>\mcp_servers\windows-mcp\sysinternals\sigcheck.exe -accepteula -q procexp64.exe`
     → look for `Verified: Signed` (may be UTF-16 encoded; `strings` on the pipe helps).
  4. Copy into the sysinternals folder; launch test:
     `Start-Process '...\sysinternals\procexp64.exe' -ArgumentList '-accepteula'`
     → confirm the GUI process appears in `tasklist`.
- Drive with windows-mcp once running (Screenshot/Snapshot to see the process tree).

## 2. windows-mcp tool-usage quirks (learned the hard way)

- **App tool schema** — `mode` is REQUIRED and the params differ per mode:
  - `mode: "launch_executable"` + `executable: "C:\...\msedge.exe"` + `args: [...]`
  - NOT `action`/`target` — those keywords get rejected with a pydantic
    validation error. Always `tool_describe` an MCP tool before calling it.
  - Example that worked: `{mode:"launch_executable", executable:"...\msedge.exe",
    args:["--new-window","https://www.youtubekids.com"]}` → returned PID.
- **Screenshot text-summary quirk** — `Screenshot` returns "Focused Window:
  No active window found / Opened Windows: No windows found" in its TEXT
  summary even when the IMAGE clearly shows the app rendered and focused.
  This is the fast path skipping UI-tree enumeration — trust the image, not
  the summary. Use `Snapshot` (full UI tree with element ids/coordinates) when
  you need interactable elements; `Screenshot` for quick visual verification.
- **Screenshot tool has no `use_vision` param** — passing it errors with
  `unexpected keyword argument`. To "see" the capture, pass the returned
  MEDIA: path to `vision_analyze`.

## 3. End-to-end windows-mcp smoke test (reuse as a template)

1. `tool_search` for `mcp__windows_mcp__*` → confirms MCP tools are registered.
2. `tool_describe` the App tool → learn the schema (mode/executable/args).
3. Launch Edge: App `launch_executable` with `--new-window <url>`.
4. `Screenshot` → note the "No windows found" text quirk, pass MEDIA path to
   `vision_analyze` → confirm the page rendered.
5. Cleanup: `Stop-Process -Name <app> -Force`.
