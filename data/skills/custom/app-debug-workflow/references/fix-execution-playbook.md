# Fix Execution Playbook

Detailed reference for Phase 5 (Fix Execution) of the app-debug-workflow.
Covers: fix brief creation, parallel subagent dispatch by file, boot verification, and endpoint testing.

---

## 1. Fix Brief Creation (before dispatching fix subagents)

**What:** A single consolidated document containing exact before/after code for every bug fix.

**Why:** Fix subagents are blank slates. They don't have access to bugs-report, proposed-fix, or task-registry. The fix brief gives them everything they need in one file — no re-reading planning docs required.

**How:** Spawn a research subagent with this prompt shape:

```
Read ALL of the following files and produce a consolidated fix brief:
1. bugs-report-v1.md — full bug report
2. proposed-fix-v1.md — fix plan per bug
3. task-registry-v1.md — ordered task list
4. All source files (main.py, routes.py, database.py, App.tsx, user.proto, user_pb2.py, user_pb2_grpc.py)

For each bug, output:
BUG-XX [T-NN] (P0/P1)
File: <path>
Lines: <start>-<end>
Current code:
<exact current code in code block>
Fix:
<exact replacement code in code block>
Explanation: <one line>

Save to: <project>/temp/fix-brief-v1.md
```

**Verification:** After the research subagent completes, read the fix brief back to verify it contains all expected bugs with correct line numbers and code quotes.

---

## 2. Parallel Subagent Dispatch (grouped by file)

**Rule:** Group fixes by FILE, not by round or priority. Two subagents editing the same file will conflict.

**Typical grouping for a full-stack app:**

| Subagent | Files | Tasks |
|----------|-------|-------|
| 1 | routes.py | All route fixes (import crash, proto path, SQL injection, admin auth, input validation, error contract, db commit, gRPC 404) |
| 2 | main.py + database.py + proto stubs | Secrets, traceback leak, CORS, debug mode, print cleanup, duplicate import, column width, gRPC bind, proto regen |
| 3 | App.tsx | XSS, API URL, useEffect loop, scroll leak, React keys |

**Subagent prompt structure:**
```
You are fixing bugs in a practice/task repo at <repo_path>.
Use the Hermes `patch` tool for edits — NOT Copilot's edit tools.
Use forward-slash paths in all tool calls to avoid backslash escaping issues.

You need to make N fixes to the file <file_path>.
Read the file first, then apply each fix carefully.

FIX 1 (T-XX — BUG-XX): <description>
Find this code (around line N):
<exact current code>
Replace with:
<exact replacement code>

FIX 2 ...

After making all fixes, read the file back to verify. Report what was changed.
Do NOT commit to git.
```

**Key principles:**
- Always tell subagents to use forward-slash paths (patch tool backslash escape issue on Windows)
- Always tell subagents to use Hermes `patch` tool, not Copilot's edit tools
- Always tell subagents to read the file back after patching to verify
- Always tell subagents NOT to commit to git (main agent handles commits)
- For proto stub regeneration, use a subagent with terminal access and provide the exact protoc command

---

## 3. Boot Verification (after all fixes applied)

**When subagent verification fails:** If a verification subagent returns "failed: max_iterations" with no summary, the main agent must do boot verification directly.

**Step 1: Check imports**
```bash
cd <repo>/backend
python -c "from app.api.routes import router; print('ROUTES OK')"
python -c "from app.db.database import UserModel; print('DB OK')"
python -c "from app.proto import user_pb2; print('PROTO OK')"
```
All three should print OK. If any fails, there's an import error to fix.

**Step 2: Check port availability**
```bash
netstat -ano | grep -E ':8000|:8001|:50051' 2>/dev/null || echo "Ports free"
```

**Step 3: Read main.py to find the actual port**
Do NOT trust the handoff doc for port numbers. Read the `uvicorn.run()` call in main.py to find the actual port. Common mismatch: handoff says 8000, code runs on 8001.

**Step 4: Start the server**
```bash
# If app is at module level: python -m uvicorn app.main:app --host 127.0.0.1 --port <port>
# If app is inside run_fastapi() function: python -m app.main
# The multiprocessing pattern (app inside function) requires `python -m app.main`
cd <repo>/backend
python -m app.main &  # background
```

**Step 5: Wait and verify**
```bash
sleep 6
curl -s -o /dev/null -w "%{http_code}" http://localhost:<port>/docs
# Should return 200
```

**Step 6: Test endpoints**
```bash
# User lookup (find actual seed email first via admin endpoint)
curl -s -H "X-API-Key: dev-only-key" http://localhost:<port>/api/admin/users
# Then use the actual email from the response
curl -s -w "\nHTTP %{http_code}" "http://localhost:<port>/api/user?email=<actual_email>"

# Admin without auth — should be 401
curl -s -w "\nHTTP %{http_code}" http://localhost:<port>/api/admin/users

# Admin with wrong key — should be 401
curl -s -w "\nHTTP %{http_code}" -H "X-API-Key: wrong" http://localhost:<port>/api/admin/users

# Admin with dev key — should be 200
curl -s -w "\nHTTP %{http_code}" -H "X-API-Key: dev-only-key" http://localhost:<port>/api/admin/users

# Missing email param — should be 422
curl -s -w "\nHTTP %{http_code}" http://localhost:<port>/api/user
```

**Step 7: Kill the server when done**

---

## 4. Frontend Type Check

```bash
cd <repo>/frontend
npx tsc --noEmit
# Exit code 0 = no type errors
```

---

## 5. Common Issues During Verification

| Issue | Cause | Fix |
|-------|-------|-----|
| `AttributeError: module 'app.main' has no attribute 'app'` | `app` defined inside `run_fastapi()` function | Use `python -m app.main` instead of `uvicorn app.main:app` |
| All endpoints return 404 | Routes not registered, or wrong port | Check actual port in main.py, verify `app.include_router()` is called |
| User lookup returns 404 for expected email | Seed data uses different email | Query admin endpoint to find actual seed emails |
| Admin endpoint returns 200 without auth | Auth fix not applied correctly | Check that `Depends(verify_admin)` is in the endpoint signature |
| `import grpc` fails | grpcio not installed | `pip install grpcio grpcio-tools` |
| Proto stubs mismatch | Stubs not regenerated after proto changes | `python -m grpc_tools.protoc -I. --python_out=. --grpc_python_out=. app/proto/user.proto` |
