---
name: app-debug-workflow
description: "⚠️ TRIGGER: when auditing an unfamiliar full-stack codebase for bugs — security, performance, reliability, dev tooling. Multi-session workflow: discover → duck-verify → plan → handoff → fix → validate. 90-min timebox. Designed for time-pressure coding/debug tasks."
version: 2.0.0
author: Ringo/MilkyWay008
url: https://github.com/MilkyWay008
platforms: [windows]
metadata:
  hermes:
    tags: [debug, audit, security, codebase-review, multi-session, timeboxed]
    related_skills: [complex-project-workflow, systematic-debugging, rubber-duck-council, subagent-first, github-now]
---

# App Debug Workflow

<table>
<tr>
<td width="32">⚠️</td>
<td><strong>TRIGGER CONDITION:</strong> Load this skill when starting a codebase audit — security review, bug hunt, performance audit of an unfamiliar full-stack application. Designed for a time-pressure LLM-Base Refactoring (Python) task: Python gRPC + SQLAlchemy backend, TypeScript React frontend, moonrepo monorepo.</td>
</tr>
<tr>
<td width="32">🔴</td>
<td><strong>HARD RULE:</strong> This is a <strong>multi-session workflow</strong> — debug/plan session (primary) and fix session (secondary). The debug session NEVER writes code. The fix session NEVER plans. Clear handoff docs between them.</td>
</tr>
<tr>
<td width="32">⏱</td>
<td><strong>90-MINUTE TIMEBUDGET:</strong> Hard limit. Track time. If behind, prioritize documenting findings over completing fixes.</td>
</tr>
<tr>
<td width="32">📺</td>
<td><strong>SCREEN-SHARE AWARE:</strong> The task may require camera + screen sharing. Before each phase, announce what's happening so the judge sees you're in control.</td>
</tr>
<tr>
<td width="32">📖</td>
<td><strong>HARD RULE: PHASE-START RE-READ.</strong> At the start of EVERY phase (0 through 6), you MUST re-read this entire skill with <code>skill_view(name='app-debug-workflow')</code> before taking any action. No exceptions. This prevents missed steps, forgotten deliverables, and hallucinated requirements. After re-reading, state a brief checklist of what this phase produces before starting work — so the user can catch gaps before you execute, not after.</td>
</tr>
</table>

## Overview

This workflow is purpose-built for **auditing an unfamiliar codebase under time pressure**. It inverts the `complex-project-workflow` — instead of building from scratch, we start from an existing (buggy) codebase and work backward to find and fix issues.

**Core loop:** Discover → Duck-Verify → Plan → Handoff → Fix → Validate (iterate)

**Multi-session architecture (optional — context health fallback):**
- **Default (single session):** Run Phases 0-6 in one session. Simpler, no handoff overhead.
- **Fallback (multi-session):** If context health degrades (ECHO 🟡/🔴), split into Session A (debug/plan, Phases 0-4+6) and Session B (fix, Phase 5). Handoff docs in `debug-fix-handoff/` make this seamless.
- **Why prepare for multi-session:** The fix session (Phase 5) produces heavy tool call volume — reading files, editing, testing, repeating. Keeping this in the main session accelerates context degradation. The handoff exists to protect the primary session's context health.
- **Session A (Debug/Plan):** Exploration, discovery, rubber-duck audit, task planning, handoff doc creation — NO code writing
- **Session B (Fix):** Execute fixes from task registry via subagents/ACP — NO planning

**Versioning convention for all docs:**
- All deliverables use `-v1` suffix initially: `big-picture-architecture-v1.md`, `bugs-report-v1.md`, `proposed-fix-v1.md`, `task-registry-v1.md`, `fix-handoff-v1.md`
- When rubber duck review or edge-case audit finds issues → create `-v2` versions with corrections
- Never overwrite v1 — keep both so the duck can compare what changed

## AUDIT GATE FALLBACK (when rubber duck is unavailable)

Every audit point (Phase 2 duck verification, Phase 3 duck edge-case audit, Phase 4 duck
final verification, and all pre-flight duck gates) normally runs through the rubber duck
council. **If the rubber duck skill or MCP server is not available** —
`skill_view(name='rubber-duck-council')` fails, the wrapper script is missing, or the MCP
duck tools aren't registered — **do NOT skip the audit**. Fall back to a **subagent
audit** instead:

1. Spawn a `delegate_task` subagent with the EXACT duck prompt for that phase (verify
   findings, catch blind spots, confirm severity, check for missed bugs/edge cases).
2. **Explicitly instruct the subagent:** *"Look for ALL possible edge cases, gaps,
   contradictions, blind spots, and failure modes. Perform a thorough gap analysis —
   what's missing, underspecified, or would break in the real world? Do NOT edit any
   files — audit only, and return a structured findings list with severity + suggested
   fix for each."*
3. Treat the subagent's findings exactly like duck findings: update docs to `-v2`,
   re-audit, iterate until nothing substantial is raised.
4. Log which fallback was used (`subagent-audit` vs `duck-council`) in the phase record.

The audit gate is non-negotiable — the *mechanism* (ducks vs subagent) is interchangeable,
the *edge-case + gap analysis* is not. Never pass a review gate without one of the two.

## Post-Build / Post-Test Bug Review — user's hard workflow rule

When the user returns from testing a build (e.g. an OTG package on a test machine)
with a list of bugs, the workflow is **STRICTLY phased and gated** — the user stated
it explicitly (2026-08-02): *"before we fix anything, let's find the bugs, discuss,
come up with fix plan; only after we finalized everything, then we go fix."*

### Phase order — do NOT skip or merge
1. **Catalog the bugs** — write every bug into a dated report file
   (`bugs-and-fixes-report-<YYYYMMDD>.md` at the build workspace root). One section
   per bug: severity, symptom, observed location, log evidence if available.
2. **Investigate root cause** — for each bug, spawn read-only subagents to find the
   ACTUAL root cause in source (file:line, code path). No fixing during this phase —
   discovery only. Verify official docs via subagents when the fix depends on what a
   feature is supposed to do (e.g. "are these valid toolset names?" → docs check).
3. **Design fix options** — per bug, an A/B/C/D options table (description, pros, cons)
   with a **preferred option** and a one-line rationale. Include the "fix order &
   dependencies" section so the user sees what must go together (e.g. a registry fix
   and a bash-bundling fix are both needed for the terminal to work).
4. **USER REVIEW GATE** — present the full plan and WAIT. The user reviews options,
   may close bugs as "not a bug" (e.g. a free API key rate-limit), may choose different
   options, may convert comments themselves. NO fixes are applied until the user says
   go. Never apply a fix "while we're at it" — the gate is absolute.
5. **Implement** — only after the plan is finalized. Source changes → source repo;
   build-layer changes → build repo (see hermes-otg-build two-repo model).

### Log verification step
When the user reports test-machine bugs, ALWAYS also check the test machine's
`<package>/data/logs/` (errors.log, gateway.log, agent.log) — logs confirm reported
bugs AND surface new ones the user didn't notice (e.g. config drift, blocked context
files, provider fallbacks). Read the logs before finalizing the report.

### Bug-close discipline
- Mark bugs **RESOLVED** only after the fix is applied AND verified (with evidence)
- Mark bugs the user explains as non-bugs **CLOSED** with their explanation recorded
- Tentative resolutions get "verify after next test" status — never claim fixed
  without the user's test confirmation

## 🎯 Triage Matrix (P0-P3) — Fix vs Document vs Skip

When time is tight, use this to decide what to do with each bug:

| Priority | Category | Action | Time to spend |
|----------|----------|--------|---------------|
| **P0 🔴** | Hardcoded secrets, SQL injection, missing auth, XSS | **Must fix** — highest severity | As long as needed |
| **P1 🟡** | N+1 queries, missing error handling, broken auth, CORS misconfig | **Fix if time allows** | Max 5 min per bug |
| **P2 🟢** | Missing loading states, console.log left in, verbose errors, type safety | **Document only** — note in bugs-report | 30 sec per bug |
| **P3 ⚪** | Code style, TODO comments, missing tests, DX improvements | **Skip entirely** — not evaluated | Zero |

**Decision flow:** For each bug → is it P0? Fix immediately. P1? Fix only if ahead of schedule. P2/P3? Document and move on.

---

## Phase 0 — Pre-Flight Setup (8 min)

⚠️ **PHASE START: Re-read the full skill now with `skill_view(name='app-debug-workflow')` before proceeding. Then state a brief checklist of what this phase produces.**

**Purpose:** Load github skill, get repo URL, clone repos. Finish before the timer truly starts ticking.

### Load GitHub & workflow skills
```python
skill_view(name='github-now')
skill_view(name='app-debug-workflow')
```

### Checklist (verify before beginning)
- [ ] Python 3.12+ available (`python3.12 --version`)
- [ ] Node.js v22+ (`node --version`)
- [ ] pnpm latest (`pnpm --version`)
- [ ] moon (`moon --version` — check via `source ~/.bashrc` first if not in PATH)
- [ ] Git (`git --version`)
- [ ] Docker images cached (`docker images postgres` + `docker images redis`)
- [ ] Rubber duck MCP server running
- [ ] ECHO plugin active and healthy
- [ ] Model chain set (suggestive — depends on what the user has): Main agent=frontier model (e.g. GLM 5.2, Claude, GPT, etc.), Subagents=fast capable model (e.g. DeepSeek v4 Pro), ACP=strong coder (e.g. MiniMax M3), King duck=strongest available (e.g. Grok 4.3)
- [ ] Duck file-read bridge active (sandboxfs — C:\Builds + C:\Projects)

### Docker check
If the repo has `docker-compose.yml` or requires PostgreSQL:
> **Ask the user:** "Is Docker Desktop running and the engine unpaused?"

### Clone the repo
```bash
# The user will provide the task repo URL
git clone <task-repo-url> repo
git clone <task-repo-url> repo-src   # reference copy, never touch
```

### 🔴 Repo Size Gate — determines ALL subsequent phases

Immediately after clone, check repo size. This single check controls subagent count, duck squad size, and browser depth for the entire workflow.

```bash
# Check repo size (exclude .git which inflates numbers)
du -sh repo --exclude=.git 2>/dev/null || du -sh repo
```

**Threshold: 70 MB**

| Repo size | Variant | Phase 1 subagents | Phase 2 ducks | Browser discovery |
|-----------|---------|-------------------|---------------|-------------------|
| < 70 MB | Standard | 2 subagents | 3 ducks (`--squad quick`) | Full click-through |
| >= 70 MB | Large | 4 subagents | 1 duck (`ask_duck(provider: "grok")`) | Main routes only |

**🔴 HARD RULE:** Check the repo size after clone and SET the variant BEFORE dispatching any Phase 1 subagents. If you forget, you'll dispatch wrong subagent counts and wrong duck squads. The variant applies to ALL subsequent phases — once set, it does not change.

**File the result:** Record the size and variant decision in `temp/repo-size-check.md` so it's visible to the user and referenced by later phases.

### 🔴 Commit lockfile changes after dependency install

After running `pnpm install` (or any dependency install that modifies lockfiles), the lockfile will show as modified in `git status`. This uncommitted artifact persists through all phases and causes confusion at Phase 6 git push.

```bash
cd repo
git add pnpm-lock.yaml  # or package-lock.json, yarn.lock, etc.
git commit -m "chore: update lockfile after dependency install"
```

This keeps the working tree clean so Phase 6 sees only fix-related changes.

### Project folder structure (already prepped)
```
C:\\Projects\\<project-root>\\
  ├── AGENTS.md                        ← this system prompt
  ├── repo\                            ← working copy (fixes happen here)
  ├── repo-src\                        ← untouched clone (reference)
  ├── big-picture-architecture-v1.md   ← architecture & module breakdown
  ├── bugs-report-v1.md                ← all bug findings
  ├── proposed-fix-v1.md               ← fix plan
  ├── task-registry\                   ← task breakdown docs
  │   └── task-registry-v1.md
  ├── debug-fix-handoff\               ← handoff docs between sessions
  │   └── fix-handoff-v1.md
  └── temp\                            ← scratch files
```

**File location quick reference:**

| Document | Save to | Notes |
|----------|---------|-------|
| `big-picture-architecture-v1.md` | **Project root** (per AGENTS.md folder structure) | Created in Phase 1c |
| `bugs-report-v1.md` | **Project root** (per AGENTS.md folder structure) | Updated throughout Phase 1 |
| `proposed-fix-v1.md` | **Project root** (per AGENTS.md folder structure) | From Phase 3 |
| `task-registry-v1.md` | `task-registry/` | For fix session |
| `fix-handoff-v1.md` | `debug-fix-handoff/` | For fix session |
| Temp files | `temp/` | Anything temporary |

**Note:** "Project root" = the root folder of the project being debugged (where AGENTS.md lives). Reference the AGENTS.md folder structure diagram for exact paths. The workflow is not specific to one task — it works for any project.

### 🔴 PRESENT THE PLAN TO THE USER (screen-share moment)
Before Phase 1 begins, tell the user:
> *"Based on the app-debug-workflow skill, here's how we'll tackle this:*
> *1. **Phase 1 — Reconnaissance:** I'll read the codebase, run tests, and explore the app in the browser to find all bugs.*
> *2. **Phase 2 — Duck Verify:** I'll have the duck council audit my findings for blind spots.*
> *3. **Phase 3 — Fix Planning:** I'll design surgical fixes for each confirmed bug.*
> *4. **Phase 4 — Task Registry:** I'll break everything into executable tasks with handoff docs.*
> *5. **Phase 5 — Fix Execution:** You'll take the handoff to a separate session and execute fixes.*
> *6. **Phase 6 — Validation:** We verify all fixes work and push.*
> *Ready to proceed to Phase 1?"*

---

### 🔴 MANDATORY GATE: External Objectives Check (before Phase 1 fires)

**⚠️ This gate fires BEFORE every Phase 1. Do NOT skip — not even when the user says "go."**

The user MAY have specifically listed objectives, task lists, or task requirements that are NOT visible in the repo's README, source code, or AGENTS.md. Examples:
- A task page with 5 structured objectives (e.g., "Issue 1 — Credential problem", "Issue 2 — Query performance")
- A rubric or grading criteria the user received separately
- A task list the user pasted into their notes but didn't commit to the repo
- A screenshot or link with explicit requirements

If the agent jumps into bug-hunting without these, **every minute spent is wasted on the wrong target.**

**THE GATE — ask the user EXPLICITLY before Phase 1:**

> *"Before I start Phase 1 reconnaissance, one critical question: **Is there a separate task list, task page, rubric, or set of specific objectives I should know about** — something that isn't in the README or AGENTS.md? If there's a task page or description you can see, please paste it or tell me what the tasks are. I'll prioritize those as the primary objectives, and treat everything else as secondary."*

**🔴 HARD RULES:**
1. Ask this question EVERY time. Even if the user says "go" or "start Phase 1."
2. Wait for the user's answer. Do NOT dispatch subagents until they respond.
3. If the user says "yes, here it is" → read and integrate those objectives. They become the PRIMARY task list. The bug-hunting workflow runs as secondary support.
4. If the user says "no, nothing else" → proceed with the standard workflow.
5. Do NOT treat this as optional or skip it because you're "pretty sure" there's nothing else. The earlier time-pressure task failure happened precisely because this check was missing.

**Why this gate exists:** In an earlier time-pressure SWE task, the agent spent the entire 90 minutes running a 50-bug sweep when the task page actually listed 5 specific structured engineering tasks. We failed because we never asked. This gate prevents that failure mode permanently.

---

## Phase 1 — Codebase Reconnaissance (15 min)

⚠️ **PHASE START: Re-read the full skill now with `skill_view(name='app-debug-workflow')` before proceeding. Then state a brief checklist of what this phase produces.**

**Purpose:** Understand the system end-to-end before diagnosing anything. **DISCOVERY ONLY — NO FIXING.**

### 1a — Read the README
Read project docs. Understand the app's purpose, architecture, data flow, and dependencies.

### 1b — Map the structure
```bash
# Top-level directory structure
find . -type f -not -path './node_modules/*' -not -path './.git/*' -not -path './venv/*' | sort | head -60

# Build config — also reveals dependency layers
moon print 2>/dev/null || moon project 2>/dev/null || cat .moon/tasks.yml 2>/dev/null
# Note: moon print (moon <1.0) or moon project (moon 2.x) output shows the
# dependency graph — note which modules depend on which. This informs the
# fix order later (lowest layer first).

# Recent commits (if any) — check if git history exists for git blame later
git log --oneline -5

# Dependency graph — generate and save to file (source of truth for all later phases)
(moon print 2>/dev/null || moon project 2>/dev/null) | head -60 > /c/Projects/<project-root>/temp/moon-dependency-graph.md
```
The generated `temp/moon-dependency-graph.md` is now the **source of truth** for the entire codebase structure. It reveals dependency layers: core models → services → API → frontend. All subagents, fix sessions, and duck audits reference this file throughout the workflow instead of re-discovering the structure.

Read these critical files:
- `README.md`, `moon.yml`, `pyproject.toml`, `package.json`
- `.env.example`, `Dockerfile`, `docker-compose.yml`
- Key `.proto` files (gRPC service definitions)
- SQLAlchemy model files
- Main app entry points
- Test configuration and one sample test file

### 🔴 Dependency Chain Check — Frontend & Backend (Phase 1 Discovery)

**Trace the full import dependency chain as part of discovery, regardless of stack.** Surface-level validation (CDN URLs return 200, syntax passes, imports resolve) is not enough — the agent must check what each import internally depends on.

**Frontend checklist (HTML/JS):**
1. Curl every CDN/import URL — confirm 200 OK
2. Curl imported files and check their **internal** imports — are they bare specifiers (e.g. `from 'three'`) or relative paths?
3. If any import uses a bare specifier, the page **must** have an import map to resolve it
4. Verify import map exists (`<script type="importmap">`) and maps the bare specifier to the correct CDN URL
5. Check version compatibility — e.g. OrbitControls from Three.js version X must match the main Three.js version X

**Backend checklist (Python/Node):**
1. Verify all imports listed in requirements/packages actually resolve (`pip install -r requirements.txt` or `npm install` completes)
2. Check for import-time crashes: `python -c "from app.main import app"` before starting the server
3. Look for deliberate import blockers — e.g. a task-style trap where a route file imports a nonexistent module to prevent server boot
4. Check for version conflicts between direct and transitive dependencies
5. For compiled languages (Rust, Go): verify crate/module resolution before building

**Why:** The Tetris debug case proved how easy this is to miss. ACP agents fixed 16 game logic bugs but never caught that `OrbitControls.js` imports `'three'` as a bare specifier with no import map — the real reason the game never started. Add this check early to avoid the same blind spot across both stacks.

### 🏗 Large repo variant (70MB+ / 100K+ lines)
If the repo is unusually large (check with `du -sh . | head -1` and `find . -name '*.py' -o -name '*.ts' -o -name '*.tsx' | wc -l`), scale Phase 1 accordingly:

**Subagents: 2 → 4** — split by module for faster parallel discovery:
| Subagent | Focus | Search targets |
|----------|-------|---------------|
| **A** | Architecture big picture | Configs, entry points, README, directory tree |
| **B** | Backend security + auth | Secrets, SQL injection, auth, CORS via `rg` |
| **C** | Backend perf + reliability | N+1, error handling, session leaks via `rg` |
| **D** | Frontend + browser | UI patterns, console.log, XSS, state issues |

All 4 dispatch in parallel via separate `delegate_task()` calls. Same time budget (15 min) — they run concurrently.

**Browser discovery:** Hit only the 3-4 main routes. No detailed click-through. Check console errors + API docs only.

**File reads:** Use `rg` for targeted pattern search rather than reading files wholesale. `rg` handles 500K lines in ~10 seconds.

**Rubber duck:** Use single duck (`ask_duck(provider: "grok")`) directly instead of wrapper script with `--squad quick` (3 ducks). Reason: 3 ducks too slow for large repos. See rubber-duck-council skill for `ask_duck` syntax and sandboxfs prompt template.

### 1c — Parallel subagent dispatch (🔴 KEY STEP)

**🔴 HARD RULE: DISCOVERY ONLY — NO FIXING.**

**🔴 GIT BLAME IS MANDATORY.** For every bug found, run `git blame -L <line>,<line> <file>` on the affected line(s). If the repo has git history (multiple commits, multiple authors), include the blame metadata in the bug report:
- Author who introduced the bug
- Commit hash and date
- Commit message that introduced it

If the repo has no meaningful git history (e.g., single initial commit), note that in the report: "No git history available." Do NOT skip the check — always attempt blame first.

Spawn **two subagents simultaneously.** Note: `max_concurrent_children` limits batch size (tasks per `delegate_task` call), NOT total parallel tasks. Dispatch individual `delegate_task()` calls one at a time — they stack up and run in parallel automatically.

After dispatch, verify both output files exist before Phase 1d. Subagents can silently fail to write files.

**⚡ Kick off moon `:test` in background** — while subagents discover bugs, start the first `moon :test` in background to build the dependency graph and warm the cache. Narrate to the user (and the judge):
> *"I'm going to start indexing the repo with moonrepo now. This builds the dependency graph and caches the initial test results in the background, while the subagents analyze the code. By the time we're ready to run tests, everything will be cached and responses will be instant."*

Then execute:
```bash
cd /c/Projects/<project-root>/repo
moon :test &
```
This runs in parallel with subagents. By the time Phase 1e arrives, the cache is **already warm** — the test results print instantly instead of spending 1-3 min on cold indexing.

**Subagent A — Architecture & Big Picture**
```python
delegate_task(
    goal="Produce a merged architecture document from the repo. Save as file.",
    context="""Repo at C:\Projects\<project-root>\repo
    Produce ONE merged document: big-picture-architecture-v1.md
    Include: What the app does when working correctly. Architecture flow,
      data model, components, routes/endpoints, dependencies, entry points.
      Also include per-module breakdown: its purpose, files, key classes,
      inter-module dependencies, entry points.
    Save to C:\\Projects\\<project-root>\\big-picture-architecture-v1.md (project root)
    toolsets=['terminal', 'file']
)
```

**Subagent B — Bug Discovery**
```python
delegate_task(
    goal="Audit the repo for bugs across all categories. Save as bugs-report-v1.md.",
    context="""Repo at C:\Projects\<project-root>\repo
    Scan for: Security (hardcoded secrets, SQL injection, missing auth, XSS, CORS misconfig),
    Performance (N+1 queries, no pagination, blocking calls, React re-rendering perf),
    Reliability (missing error handling, no retries, resource leaks, missing loading/error states),
    DX (slow builds, missing types, test gaps), Correctness (race conditions, edge cases, state mgmt).

    Split findings:
    GROUP 1 — Simple/local fixes (isolated, won't affect other modules)
    GROUP 2 — Complex fixes (affects multiple modules, needs architectural change)

    For each bug, include:
    - severity (Critical/High/Med/Low)
    - file:line, reproduction steps, root cause
    - 🔴 MANDATORY: run `git blame -L <line>,<line> <file>` for the affected line and include:
      - Author who introduced the bug
      - Commit hash + date
      - Commit message
      If no git history, note "No git history available"

    Save to C:\\Projects\\<project-root>\\bugs-report-v1.md (project root)""",
    toolsets=['terminal', 'file']
)
```

### 1d — Run the app locally

**🔴 Before starting any dev server, check port availability:**
```bash
# Check if target ports are in use before starting servers
netstat -ano | grep -E ':3000|:5173|:8000|:50051' 2>/dev/null || echo "Ports free"
```
If a port is occupied, either kill the process or change the port in the app config (e.g., `vite.config.ts` `server.port`). Never assume a server is responding just because the process started.

**🔴 Check for import-time crashes before starting the server:**
If the server process exits immediately (exit code 1) without printing any server startup banner, the most likely cause is an import-time error in Python (e.g., `import nonexistent_module` deliberately placed in a route file to block startup). Check the process output for `ModuleNotFoundError`, `ImportError`, or similar. The error message appears before any server banner — it won't show up in curl checks.
```bash
# Pre-flight: verify critical imports work before starting the server
python -c "from app.api.routes import router; print('Imports OK')" 2>&1 || echo "Import error detected — check output above"
```
This catches import-time blockers immediately, without waiting for the server to fail and then debugging why.

```bash
cd /c/Projects/<project-root>/repo
# Start dev server (exact command depends on the repo)
moon run backend:dev 2>/dev/null || python main.py 2>/dev/null || npm run dev
```
Note if the app boots successfully or shows startup errors. This reveals configuration issues immediately. Add any findings to `bugs-report-v1.md`.

**🔴 After starting the server, verify it is actually responding:**
```bash
curl -s -o /dev/null -w "%{http_code}" http://localhost:<port> || echo "Server not responding"
```
"Process started" ≠ "server responding." Always curl the endpoint to confirm.

### 1e — Baseline test run
```bash
cd /c/Projects/<project-root>/repo
# Check for test scripts before running — many repos have no test runner configured
# Look at package.json scripts, pyproject.toml, moon.yml for test tasks first
for f in package.json pyproject.toml moon.yml; do
  [ -f "$f" ] && grep -E '"test"|pytest|jest|vitest' "$f" >/dev/null 2>&1 && echo "Test script found in $f"
done
# Then run whatever is available
moon test 2>/dev/null || pytest 2>/dev/null || npm test 2>/dev/null || echo "No test command found"
```
Document what passes and fails at baseline. This is your truth source for regression detection. Add any findings to `bugs-report-v1.md`.

**If no test runner exists:** Run `tsc --noEmit` (TypeScript projects) or `python -m compileall .` (Python projects) as a bare-minimum compile check. Document the absence of tests as a finding.

### 1f — Browser Discovery — Frontend + Backend (I do it, user verifies)

**🔴 TIME-PRESSURE MODE: SKIP THIS PHASE.** During a time-constrained task (90-min timebox), Phase 1f is skipped entirely due to time constraints. The task prioritizes static code analysis over live browser exploration. Browser discovery is only run during normal (non-time-pressured) debug workflows where time is not critical.

**Purpose (normal workflow only):** I silently run the app and navigate it using Hermes' browser tools to find UI/UX bugs, console errors, API issues. The user verifies my findings afterward — this preserves screen-share engagement while I do the heavy lifting.

#### Start the app (I do this — behind the scenes)
```bash
cd /c/Projects/<project-root>/repo
# Start backend and frontend dev servers — keep running in background
docker compose up -d 2>/dev/null || \
  (nohup python3.12 backend/main.py > /dev/null 2>&1 & nohup npm run dev > /dev/null 2>&1 &)
```
Wait for both servers to be ready. Confirm with `curl localhost:8000/health` or similar.
**These servers stay running in the background** — the user can open them at any time during the session to verify findings.

#### Frontend browser checks (I do this with browser tools)
For each major page/route in the app:

1. **Navigate** — `browser_navigate("http://localhost:5173")` (or whatever URL)
2. **Check console** — `browser_console()` — note all errors, warnings, uncaught exceptions
3. **Visual check** — `browser_vision(question="Does this page have visual bugs, blank areas, missing elements, broken layouts?")`
4. **Click through flows** — buttons, links, forms — interact with each element
5. **Document everything** — URL, what you clicked, what broke (console error, blank page, slow load) → add to `bugs-report-v1.md`

**What I look for on frontend:**
- Console errors (React crashes, 404 API calls, uncaught exceptions)
- Broken UI (blank pages, overlapping elements, misaligned content)
- Missing loading/error/empty states (no spinner, no toast, no "no data" message)
- Broken navigation (links that 404, routes that don't render)
- Form issues (no validation feedback, no success/error after submit)
- Performance (slow loads, laggy interactions)
- React key warnings, infinite re-renders, stale state

#### Backend browser checks (I do this)
1. `browser_navigate("http://localhost:8000/docs")` — check Swagger UI loads
2. Test a GET endpoint — note response time and content
3. Check health endpoint — verify it's alive
4. Check for verbose error messages (stack traces leaked to client)
5. Check for missing or confusing auth responses

Add all findings to `bugs-report-v1.md`.

#### Present findings to the user
After all discovery is complete:
1. **Verify servers are still running** — `curl localhost:8000/health` and check frontend is responding
2. If servers died, restart them
3. Then present to the user like this:
> *"I found all these bugs. Some are UI-related, some are backend. The app is running and ready for you to verify. Here's the full bug report:*
> *`C:\\Projects\\<project-root>\\bugs-report-v1.md`*
> *Open the frontend at http://localhost:5173 and the backend at http://localhost:8000/docs to verify the UI bugs I found. Admin login: admin@example.com / password.*
> *If the servers aren't responding when you open them, just tell me and I'll restart them.*
>
> *Ready to proceed to Phase 2 — Duck Verification?"*

### Phase 1 Deliverables Checklist — HARD GATE

Before starting Phase 2, verify ALL of these files exist on disk. If ANY are missing, DO NOT proceed — return to the missing step in Phase 1 and complete it.

```bash
# Run this verification before Phase 2
ls -la /c/Projects/<project-root>/big-picture-architecture-v1.md
ls -la /c/Projects/<project-root>/bugs-report-v1.md
ls -la /c/Projects/<project-root>/temp/moon-dependency-graph.md
```

| # | Required File | Phase Step | What it contains |
|---|---------------|------------|-----------------|
| 1 | `big-picture-architecture-v1.md` | 1c (Subagent A) | Full architecture doc |
| 2 | `bugs-report-v1.md` | 1c (Subagent B) | All bug findings consolidated |
| 3 | `temp/moon-dependency-graph.md` | 1b | Moon dependency graph (source of truth for structure) |

If any file is missing:
- **File 1 or 2 missing:** The subagent in 1c either failed or wrote to a wrong path. Check the subagent summary for output paths and re-run if needed.
- **File 3 missing:** `moon print`/`moon project` failed or wasn't run. Run it directly with `moon project <id> --json` for each project and save the output.

Only proceed to Phase 2 when ALL THREE files are confirmed present.

---

## Phase 2 — Rubber Duck Verification (8 min)

⚠️ **PHASE START: Re-read the full skill now with `skill_view(name='app-debug-workflow')` before proceeding. Then state a brief checklist of what this phase produces.**

🔴 **MANDATORY PRE-FLIGHT — Before ANY duck interaction:**
1. Run `skill_view(name='rubber-duck-council')` to reload the full rubber duck toolkit — do NOT rely on memory from session start.
2. Verify the filesystem bridge is alive: `mcp__rubber_duck__mcp_status()` — confirm `filesystem_readonly-mcp` is healthy.
3. Re-read the "File-Read Access (Bridge Tool) 🆕" section — ducks read files via `sandboxfs_*` tools. Pass FILE PATHS, not file contents.

**Before starting:** Ask the user: *"Ready for Phase 2 — I'll feed our findings to the duck council for validation?"*

**Purpose:** Have the duck council validate our findings — catch blind spots, confirm severity, find what we missed.

**Pre-flight:** The dependency graph was already generated in Phase 1b (`temp/moon-dependency-graph.md`). It's the source of truth for the codebase structure — ducks will read this instead of browsing the full repo.

**Method:** Use the rubber-duck-council skill's **quick compare** mode (fastest path — no debate rounds, just compare + king duck synthesis):
```python
# 🔴 MUST load rubber-duck-council skill first to find the wrapper script location
skill_view(name='rubber-duck-council')
# The wrapper script path is printed in the skill output — copy it from there.
# Do NOT hardcode the path or guess — it may change between Hermes versions.
```
Then dispatch via the wrapper script (path from the skill output above):
```bash
# Default: quick squad (3 ducks), compare mode (fastest)
python <wrapper-path-from-skill> --mode compare "prompt..."

# If you need all 6 ducks for thoroughness:
python <wrapper-path-from-skill> --mode compare --squad max "prompt..."

# If your prompt contains long file paths, use --file to pass them:
python <wrapper-path-from-skill> --mode compare --file C:\path\to\file.txt "instruction..."
```
**Why compare mode:** No debate rounds, no 2-phase wait. Ducks research in parallel, king duck synthesizes. Takes ~20-40s instead of ~2-5 min for hybrid. We need every second during the 90-min timebox.

**Squad note**: Default is `--squad quick` (3 ducks). Use `--squad max` (all 6) for thorough verification. When telling ducks about file paths, explicitly mention they have `sandboxfs_read_file` etc. available.

**🔴 HARD RULE: DO NOT use `--squad max` unless the user explicitly asks for it.** Default is always `--squad quick` (3 ducks). Using all 6 ducks wastes OpenRouter API budget and adds 2-3x latency for marginal benefit. The quick squad (3 ducks + king duck synthesis) is sufficient for all phases of this workflow. Only escalate to `--squad max` if the user says "use all ducks" or "thorough verification."

#### What to feed the ducks
- `big-picture-architecture-v1.md` — architecture understanding
- `bugs-report-v1.md` — findings to verify
- `temp/moon-dependency-graph.md` — dependency graph (lets ducks see the full module structure without reading every file)
- Path to the actual repo (ducks have filesystem read access)

#### Duck prompts

**Prompt 1 — Verify architecture understanding (read dependency graph):**
> *"Read the dependency graph at {project}/temp/moon-dependency-graph.md. This shows the full module structure and dependency relationships without reading every file. Now here's our big-picture analysis at {path}. Is it accurate? Did we miss any critical component or dependency? Are the dependencies correct?"*

**Prompt 2 — Verify bug findings + check for missed bugs:**
> *"Here's a bug report for this codebase at {repo_path}. Review each finding:*
> *1. Is it a real bug? (false positive check)*
> *2. Is the severity correct?*
> *3. Are there additional bugs we missed in these same areas?*
> *4. Are there bugs in completely different areas we didn't discover at all?*
> *
> *For each confirmed bug, verify by tracing the code path."*

**Prompt 3 — Security-focused deep audit (use duck_debate for sharpest critique):**
> *"Conduct a focused security audit of this codebase at {repo_path}. Look specifically for:*
> *- Hardcoded secrets / credentials in source*
> *- SQL injection vectors (raw queries, f-string SQL)*
> *- Missing authentication on gRPC endpoints*
> *- Missing input validation*
> *- Insecure data storage*
> *- Rate limiting absence*
> *- Any OWASP Top 10 vulnerability"*

#### Update docs with duck findings
If ducks find additional bugs or corrections:
- Create `bugs-report-v2.md` with new findings merged in
- Create `big-picture-architecture-v2.md` if architecture understanding was corrected
- Keep v1 files as reference
|---

## Phase 3 — Fix Planning (8 min)

⚠️ **PHASE START: Re-read the full skill now with `skill_view(name='app-debug-workflow')` before proceeding. Then state a brief checklist of what this phase produces.**

**Before starting:** Ask the user: *"Ready for Phase 3 — I'll design the fix plan based on confirmed bugs?"*

**Purpose:** Design surgical, minimal fixes for every confirmed bug. Classify all bugs by the triage matrix (P0/P1 = fix, P2 = document, P3 = skip).

**🔴 SURGICAL FIX RULE:** Each fix in `proposed-fix-v1.md` MUST specify:
- Exact file path
- Exact line number(s)
- Current code (the "before" — quoted from the actual file)
- Replacement code (the "after" — the exact replacement)
- One-line rationale

If a fix cannot be described in under 5 lines of code change, it is NOT surgical enough — reconsider and narrow the scope. Do not restructure, refactor, or rewrite surrounding code. Change only the lines that fix the bug.

### Create `proposed-fix-v1.md`

Structure — organized by **triage priority first**, then by **dependency layer** (from moon graph), then by **round**:

The moon dependency graph (from Phase 1b's `moon print`) determines fix order:
- **Layer 0** — Core models / DB (foundation — everything depends on these)
- **Layer 1** — Backend services (depends on Layer 0)
- **Layer 2** — API endpoints (depends on Layer 1)
- **Layer 3** — Frontend (depends on Layer 2 — independent fix possible)

Always fix lower layers first. A fix in Layer 0 may require re-testing Layers 1-3, but a fix in Layer 3 only needs frontend tests.

```markdown
# Proposed Fix — v1

## 🔴 P0 — Must Fix (highest priority)
### Round 1 — Simple fixes
| Bug | File | Fix |
|-----|------|-----|
| Hardcoded API key | utils.py:36 | Move to .env |
| Broken import | items.py:8 | Remove NonExistentModel |

### Round 2 — Complex fixes
| Bug | File | Fix | Depends on |
|-----|------|-----|-----------|
| SQL injection | crud.py:35 | Parameterize query | — |
| Missing auth | items.py:14 | Restore CurrentUser | — |

## 🟡 P1 — Fix If Time Allows
### Round 1 — Simple fixes
| Bug | File | Fix |
|-----|------|-----|
| Missing 404 check | items.py:42 | Restore HTTPException |

### Round 2 — Complex fixes
| Bug | File | Fix | Est. time |
|-----|------|-----|-----------|
| N+1 query | items.py:28 | selectinload | 10 min |

## 🟢 P2 — Document Only
- Bug 2: console.log leaking IDs → noted in bugs-report
- Bug 5: TODO in code → noted in bugs-report

## ⚪ P3 — Skip
- Code style issues, test gaps
```

### Agreement gate — present to the user
After ducks approve the proposed fix, present to the user:
> *"Here's the proposed fix plan. P0 fixes I'm confident we can complete. P1 fixes if time allows. P2/P3 are documented only — not worth spending time on during the task.*
> *Do you agree with this scope? If yes, I'll build the task registry with only these P0 and selected P1 tasks."*

**🔴 HARD RULE:** Do NOT proceed to Phase 4 until the user explicitly agrees to the fix scope. Task registry should ONLY include tasks the user has approved. P2/P3 never get tasks.

### Duck edge-case audit (quick compare)
Feed `proposed-fix-v1.md` (plus `bugs-report-v1.md` or `-v2.md` if updated) to the council via quick compare:

```bash
python scripts/duck-research-wrapper.py --mode compare "Review this proposed fix document against the codebase..."
```

> *"Review this proposed fix document against the codebase. For each fix:*
> *1. Does it actually solve the root cause?*
> *2. Does it introduce new bugs or edge cases?*
> *3. Is the fix minimal, or does it overreach?*
> *4. Are there back-compat concerns?*
> *5. Does it break existing tests?*
> *
> *If issues found, suggest corrections."*

If ducks find issues → bump to `proposed-fix-v2.md` → re-audit. Repeat until clean.

---

## Phase 4 — Task Registry & Handoff (5 min)

⚠️ **PHASE START: Re-read the full skill now with `skill_view(name='app-debug-workflow')` before proceeding. Then state a brief checklist of what this phase produces.**

**Before starting:** Ask the user: *"Ready for Phase 4 — I'll build the task registry with only the P0 and P1 fixes we agreed on?"*

**Purpose:** Decompose only the **user-approved fixes** into executable tasks. P2/P3 bugs NEVER get tasks — they remain documented in bugs-report.

### Create `task-registry-v1.md`

Only includes P0 and user-approved P1 fixes. Organized by **dependency layer first** (from moon graph), then by round. Tasks in lower layers are always executed before higher layers.

### 🔴 SURGICAL FIX RULE — TASK REGISTRY FORMAT: Every task entry MUST include:
- Task ID + Bug ID reference
- Priority + Round
- File path (absolute)
- Exact line number(s)
- Current code (the "before" — quoted exactly from the file)
- Fixed code (the "after" — the exact replacement)
- One-line rationale
- Verification command for that specific fix
- Estimated time

### 🔴 COMMIT MESSAGE TEMPLATE: Every task entry MUST ALSO include a 4-line commit message template:
- **Line 1 (ID line):** `[$BUG_ID] [$TASK_ID]: <one-line summary>`
- **Line 2 (Problem):** `Problem: <what was wrong, in plain English>`
- **Line 3 (Fix):** `Fix: <what we changed, in plain English>`
- **Line 4 (Reasoning):** `Verification: <how to confirm it works>\n\nRefs: Task-Registry <TASK_ID>, Bugs-Report v2 <BUG_ID>`

**Example:**
```
[B-BUG-005] [T-001]: Remove broken import that prevents backend boot

Problem: routes.py imports nonexistent_module on line 6, causing ImportError that blocks server boot.
Fix: Removed import statement from routes.py.
Verification: Backend boots successfully, /api/user endpoint responds 200 OK.

Refs: Task-Registry T-001, Bugs-Report v2 B-BUG-005
```

This commit message template is the **source of truth** that the fix session copies verbatim into each `git commit -m` command. The fix session does NOT generate commit messages independently.

If a task cannot specify the fix at line-level detail (exact before/after code), the fix is not understood well enough — go back and investigate. Vague task descriptions like "fix SQL injection" produce over-engineered fixes. Precise descriptions like "change line 34 from `f"SELECT * FROM users WHERE email = '{email}'"` to `text("SELECT * FROM users WHERE email = :email"), {"email": email}`" produce surgical fixes.

The task registry is the **fix manifest** — subagents execute from it. Zero ambiguity, zero room for rewrites. The main agent creates this file directly (never delegated to subagents).

```markdown
# Task Registry — Fix Session

## 🔴 SURGICAL FIX RULE — READ BEFORE EXECUTING
- Touch MINIMAL code. Change only the lines identified in each task.
- Do NOT restructure, refactor, or rewrite surrounding code.
- Do NOT add new files unless absolutely necessary.
- Do NOT change imports unless the fix requires it.
- Each fix = one code change = one commit.
- If a fix seems to require rewriting a function, STOP and reconsider — you're over-engineering.

## Dependency order (from moon graph)
Layer 0: Core models / DB → Layer 1: Backend services → Layer 2: API endpoints → Layer 3: Frontend

## 🔴 Round 1: P0 Simple Fixes
| # | Triage | File(s) | Change | Verification |
|---|--------|---------|--------|-------------|
| 1 | P0 🔴 | utils.py:36 | Move API key to .env | Run tests |
| 2 | P0 🔴 | items.py:8 | Remove NonExistentModel import | App boots |

## 🟡 Round 1: P1 Simple Fixes
| # | Triage | File(s) | Change | Verification |
|---|--------|---------|--------|-------------|
| 3 | P1 🟡 | items.py:42 | Restore 404 check | GET nonexistent item |

## Round 2: Complex Fixes (all P0, P1 if time)
| # | Triage | Depends on | File(s) | Change | Verification |
|---|--------|-----------|---------|--------|-------------|
| 4 | P0 🔴 | — | crud.py:35 | Parameterize query | Test SQL injection |
| 5 | P0 🔴 | — | items.py:14 | Restore CurrentUser | Auth check passes |
| 6 | P1 🟡 | Task 4 | items.py:28 | selectinload | N+1 gone |
```

### Create `fix-handoff-v1.md`

In `C:\Projects\<project-root>\debug-fix-handoff\`:

```markdown
# Fix Handoff — Round 1

## Context
- Repo path: C:\Projects\<project-root>
epo
- Reference copy: C:\Projects\<project-root>
epo-src
- Model for this session: the user's chosen coding model (e.g. MiniMax M3 or DeepSeek v4 Pro)
- Workflow phase: This session is Phase 5 of the app-debug-workflow.
- **Dependency graph available at**: `repo/.moon/` (built by `moon :test`). Use `moon :test` after each fix — it only tests affected modules based on the dependency graph. Unchanged modules return cached results instantly.

## Dependency order (from moon graph)
Fix in this order — lower layers before higher:
1. **Core models / DB** (if changed, everything downstream needs re-test)
2. **Backend services** (depends on models)
3. **API endpoints** (depends on services)
4. **Frontend** (depends on API — can be fixed independently)
Use `moon :test` after each layer to verify only affected modules.

## What to fix
See `task-registry\task-registry-v1.md` — Round 1 only

## Critical rules (load app-debug-workflow skill)
- Load `skill_view(name='app-debug-workflow')` — this is Phase 5
- One commit per fix, atomic commit messages
- Run tests after EVERY change
- Never break existing functionality
- Add commit body explaining problem + fix rationale
- If bug involves UI, use browser tools to verify the fix
- After Round 1 done → tell the user: "Round 1 fix is done, proceeding to Round 2"
- After Round 2 done → tell the user: "Phase 5 complete — all fixes applied"

## Completion signal
All tasks complete, all tests pass, git status clean.
```

### Create `/goal draft` prompt

**Syntax note:** `/goal draft "..."` triggers Hermes' **completion contracts** feature (v0.18+). Hermes expands the plain-language objective into a structured contract (outcome, verification, constraints, boundaries, stop_when) and auto-continues until the goal is achieved. See: https://vagoj9m72qhzfbicyrbbbz4x.surge.sh/

**🔴 COMMIT MESSAGE FORMAT REQUIREMENT — HARD RULE:** Every `git commit -m` command must use the 4-line template defined in the task registry. The commit message MUST include:
- Line 1: `[$BUG_ID] [$TASK_ID]: <one-line summary>`
- Line 2: `Problem: <what was wrong>`
- Line 3: `Fix: <what we changed>`
- Line 4: `Verification: <how to confirm it works>\n\nRefs: Task-Registry <TASK_ID>, Bugs-Report v2 <BUG_ID>`

**NO ONE-LINERS ALLOWED.** The user requires detailed commits with full problem/fix/verification detail. `git commit -m "fix: T-001"` will be rejected.

A single copy-paste block for the fix session:

> `/goal draft "Execute fixes from task-registry-v1.md in [project-root]/repo. Follow the fix-handoff-v1.md instructions. This is Phase 5 of app-debug-workflow. Load app-debug-workflow skill first. SURGICAL FIXES ONLY — touch minimal code, change only the lines identified in each task, do not restructure or refactor surrounding code. One commit per fix. Run tests after every change. Use browser to verify UI fixes. Notify after Round 1 and Round 2. Do NOT do git push — the main session handles git after verification.

🔴 COMMIT MESSAGE FORMAT: Every commit must use the 4-line template from the task registry: ID line + Problem + Fix + Verification + Refs. NO ONE-LINERS. Copy the exact commit message template from each task in task-registry-v1.md. This is mandatory for the task."`

### Duck final verification (quick compare)
Feed to the duck council via quick compare:
- Updated proposed fix (v1 or v2)
- `task-registry-v1.md`
- `fix-handoff-v1.md`
- The `/goal draft` prompt

```bash
python scripts/duck-research-wrapper.py --mode compare "Review these documents..."
```

> *"Review these documents. Are the tasks properly decomposed? Correct order? Any missing steps? Will executing this task registry produce the fixes described in the proposed fix doc? Is the handoff doc complete enough for another agent to execute?"*

If ducks find issues → create `-v2` versions of task registry and handoff → re-audit.

### ⚡ Parallel optimization — prepare v1.1 while v1 executes
As soon as the user takes v1 to the fix session, dispatch a subagent in the primary session to prepare for the P2 documented fixes:
```python
delegate_task(
    goal="Create task-registry-v1.1.md and fix-handoff-v1.1.md for the P2 documented fixes",
    context="""The P2 fixes are simple, isolated, low-risk changes that were documented during discovery.
    Read bugs-report.md to find P2 entries. Create:
    - task-registry-v1.1.md: All P2 fixes in a single round (no Round 1/2 split needed — they're all trivial)
    - fix-handoff-v1.1.md: Handoff for the fix session to use after v1 completes
    Save both to C:\Projects\<project-root>\debug-fix-handoff\"""
)
```
**Why parallel:** The fix session executes P0/P1 (~20 min). During that time, the primary session is idle — using it to prep v1.1 costs nothing. If the fix session finishes with time to spare, v1.1 is ready to go immediately. If not, no time was wasted. P2 fixes are so simple that no duck audit is needed — the original bugs-report already documented them.

---

## Phase 5 — Fix Execution (Session B, 25 min)

⚠️ **PHASE START: Re-read the full skill now with `skill_view(name='app-debug-workflow')` before proceeding. Then state a brief checklist of what this phase produces.**

**Before starting:** Tell the user:
> *"Ready for Phase 5? When you are, here's the duck-approved /goal draft prompt and the files to take to the fix session:*
> *- `/goal draft` prompt (copy-paste into new session)*
> *- `task-registry-v1.md`*
> *- `fix-handoff-v1.md`*
> *
> *Give these to the fix session, then Phase 5 will begin. After it's done, come back here for Phase 6 (Validation + Push)."*

### Fix execution strategy (before dispatching Round 1)

**Create a fix brief first.** Before dispatching fix subagents, spawn a research subagent to read ALL source files + ALL planning docs (bugs-report, proposed-fix, task-registry) and produce a consolidated fix brief at `temp/fix-brief-v1.md`. For each bug, the brief must contain: bug ID, task ID, file path, exact line numbers, current code (quoted exactly in a code block), replacement code (quoted exactly in a code block), one-line explanation. This gives fix subagents precise before/after instructions without needing to re-read all planning docs — they just follow the brief. The brief is the single source of truth for fix subagents.

**Group fixes by file for parallel subagent dispatch.** When dispatching fix subagents in parallel, group fixes by FILE to prevent race conditions. Two subagents editing the same file will conflict. Example grouping:
- Subagent 1: all `routes.py` fixes (T-01, T-02, T-05, T-06, T-12, T-13, T-14, T-19)
- Subagent 2: all `main.py` + `database.py` + proto fixes (T-03, T-04, T-09, T-10, T-11, T-15, T-16, T-23, T-24)
- Subagent 3: all `App.tsx` fixes (T-07, T-08, T-17, T-18, T-22)

Within a file group, fixes can span both Round 1 and Round 2 — the subagent applies them sequentially. The round distinction is for testing/ordering, not for subagent assignment.

**Verification subagents can fail silently.** A verification subagent dispatched to boot the backend and test endpoints may hit max_iterations and produce no summary. If this happens, the main agent should do the boot verification directly — it's a critical step that can't be skipped. See `references/fix-execution-playbook.md` for the exact boot-test sequence and common verification issues.

### Fallback chain for fix execution
If the primary coding agent fails, fall through in this order:
1. **ACP with the user's preferred strong coder** (primary — best for multi-file coding; e.g. MiniMax M3)
2. **Subagent with the user's fast capable model** (fallback — use `delegate_task` with explicit fix instructions from the fix brief; e.g. DeepSeek v4 Pro)
3. **Manual coding with `write_file`/`patch`** (last resort — only for single-file, simple fixes that can't fail)
Do NOT give up after ACP fails — always try at least one fallback before going manual.

### 🔴 Time exhaustion fallback — create fixed-vs-no_fix.md

If the fix session exhausts its time budget before all tasks are complete:

1. **Immediately stop all fix subagents.** Do NOT start new tasks.
2. **Create `temp/fixed-vs-no_fix.md`** with:
```markdown
# Fixed vs Not Fixed — Time Exhaustion Report
Generated: [timestamp]

## ✅ Fixed (committed)
| Task ID | Bug ID | Priority | File | Commit |
|---------|--------|----------|------|--------|
| T-001 | B-BUG-005 | P0 | routes.py:6 | abc1234 |
| ... | ... | ... | ... | ... |

## ❌ Not Fixed (time exhausted)
| Task ID | Bug ID | Priority | File | Reason |
|---------|--------|----------|------|--------|
| T-018 | B-BUG-022 | P1 | App.tsx:45 | Time exhausted before frontend P1 round |
| ... | ... | ... | ... | ... |
```
3. **For each ❌ task**, include the Problem and Fix from `task-registry-v1.md` — the reviewer needs to know what was intended.
4. **Commit and push whatever is done.** Uncommitted work is worthless.
5. **Tell the user:** *"Time exhausted. I've documented what's fixed and what's not in `fixed-vs-no_fix.md`. Phase 6 will pick up from here."*

**This file is the bridge between Phase 5 and Phase 6.** Phase 6 reads it to include "not fixed" tasks in the final summary.

### Round 1 — Simple fixes
- Applied first — isolated, no cross-module impact
- One commit per fix with detailed commit body
- **Use moon's dependency tracking** — after each fix, run `moon :test` instead of a full test suite. Moon only tests modules affected by the change, thanks to its dependency graph:
  ```bash
  moon :test   # only runs tests for changed modules and their dependents
  ```
  This saves 5-15 minutes per iteration vs running the entire 500K-line test suite.
- If bug involves UI, use browser tools to verify the fix visually
- After all Round 1 done → **notify the user**: *"Round 1 fix is done, now proceeding to Round 2"*
- Only then begin Round 2

### Round 2 — Complex fixes (broad → narrow)
- Fix the module with widest impact first
- Test after each module fix — **always use `moon :test`** for fast, dependency-aware testing
- Move to narrower-impact modules
- If bug involves UI, use browser tools to verify the fix visually
- After all Round 2 done → **notify the user**: *"Round 2 is done. Phase 5 complete — all fixes applied."*
- Return to debug session for validation

### If the fix session encounters blockers
- Document the blocker in `C:\Projects\<project-root>\temp\` with a descriptive filename
- Complete what can be done
- Return to debug session with the blocker report

---

## Phase 6 — Validation + Git Push (7 min)

⚠️ **PHASE START: Re-read the full skill now with `skill_view(name='app-debug-workflow')` before proceeding. Then state a brief checklist of what this phase produces.**

**Before starting:** Ask the user: *"Ready for Phase 6 — final validation and push?"*

**Purpose:** Verify all fixes work, no regressions. If some fixes missed the mark, create v2 handoff for another round. Only push when everything is clean.

### 🔴 Time exhaustion check — read fixed-vs-no_fix.md if it exists

**Before running any Phase 6 validation, check if the fix session ran out of time:**

```bash
# Check if the time exhaustion report exists
ls /c/Projects/<project-root>/temp/fixed-vs-no_fix.md 2>/dev/null && echo "FOUND" || echo "NOT FOUND"
```

**If FOUND:**
1. Read `temp/fixed-vs-no_fix.md` to get the ❌ "Not Fixed" list
2. For each ❌ task, pull the Problem, Fix, and Verification from `task-registry-v1.md`
3. In `fix-summary-v1.md`, add a section at the end titled **"## Tasks Not Fixed (Time Constraint)"**
4. Each not-fixed task entry MUST have the same four fields as fixed tasks: File, Problem, Fix, Verification
5. Format:

```markdown
## Tasks Not Fixed (Time Constraint)

### T-018 [P1] [B-BUG-022] Add Suspense boundary for lazy-loaded components
- **File:** repo/frontend/src/App.tsx, line 45
- **Problem:** React.lazy used without Suspense fallback causes runtime crash during chunk loading.
- **Fix:** Wrap lazy-loaded component in <Suspense fallback={<div>Loading...</div>}>.
- **Reason not fixed:** Time exhausted before frontend P1 round (90-min hard limit reached).

### T-020 [P1] [B-BUG-024] Add Content-Security-Policy header
- **File:** repo/frontend/index.html
- **Problem:** No CSP header — vulnerable to XSS and data injection attacks.
- **Fix:** Add <meta http-equiv="Content-Security-Policy" content="default-src 'self'; script-src 'self' 'unsafe-inline'"> to <head>.
- **Reason not fixed:** Time exhausted — same reason.
```

**🔴 HARD RULE:** Not-fixed tasks get the SAME level of detail as fixed tasks. The reviewer must understand exactly what was found, what the fix would have been, and why it wasn't applied. "Ran out of time" is an acceptable answer — silence is not.

**If NOT FOUND:** All tasks were completed. Skip this section.

### Full test suite — leverage moon's caching
```bash
cd /c/Projects/<project-root>/repo
moon :test
```
Moon only runs tests for modules whose code actually changed. Unchanged modules return cached results instantly — the entire 500K-line suite finishes in seconds, not minutes.

### Browser re-verification
- If UI bugs were fixed, verify in browser that they're resolved
- Check console for new errors

### 🔴 Surgical fix verification (3-way diff)
Before declaring Phase 6 complete, verify fixes were surgical — not over-engineered. Requires three folders:
- `repo/` — the fixed version
- `repo-src/` — the buggy version (no fixes applied)
- `repo-src (no bug)/` — the original clean version (if available)

```bash
# Diff fixed vs clean original — should show ONLY bug-fix lines, nothing else
diff -r repo/ "repo-src (no bug)/" --exclude=node_modules --exclude=.git --exclude=__pycache__ --exclude=app.db | head -80
```

**What to look for:**
- Lines that match the bug-fix tasks in `task-registry-v1.md` → GOOD (surgical)
- Unrelated changes: restructured imports, rewritten functions, new files, changed formatting → BAD (over-engineered)
- If the fix session introduced files or rewrote functions, flag them as regressions

If over-engineering is detected, document which fixes need to be redone surgically and create a v2 task registry for those fixes only.

### If bugs remain (incomplete fixes)
→ Create `task-registry-v2.md` — only the tasks that weren't fixed properly
→ Create `fix-handoff-round-2.md` — focused on remaining issues only
→ Create updated `/goal draft` prompt for the remaining fixes
→ Update `bugs-report-v1.md` or create `bugs-report-v2.md` showing remaining issues
→ Tell the user: *"Some fixes need another pass. Here's the v2 handoff. Take these back to the fix session."*
→ Back to fix session → repeat until clean

### Generate fix-summary-v1.md — mirrored commit detail

For each applied task, create a section in `fix-summary-v1.md` at project root. Every task section MUST mirror the git commit detail — no one-liner checklists. Format:

```markdown
### T-001 [P0] [B-BUG-005] Remove broken import that prevents backend boot
- **File:** repo/backend/app/api/routes.py, line 6
- **Problem:** Import of `nonexistent_module` causes `ImportError`, backend cannot boot.
- **Fix:** Removed `import nonexistent_module` statement.
- **Verification:** Backend boots successfully (`python -c "from app.main import app; print('OK')"` returns OK).

### T-002 [P0] [B-BUG-001] Remove hardcoded JWT_SECRET from source code
- **File:** repo/backend/app/main.py, line 14
- **Problem:** JWT secret embedded in source code — exposed in git history, visible in plaintext.
- **Fix:** Replaced with `os.getenv("JWT_SECRET", "dev-secret-change-me")`.
- **Verification:** Backend boots, env var sourced, `grep "my_secret_key_123" main.py` returns no match.
```

**🔴 HARD RULE:** Every task in the fix summary must include ALL four fields: File, Problem, Fix, Verification. No shortcuts. No "see commit message" references. The fix-summary IS the deliverable the reviewer reads — it must stand alone.

Save to `C:\Projects\<project-root>\fix-summary-v1.md` (project root).

### Documentation for each fix
```bash
# Verify each commit body includes:
#   Problem: what was wrong
#   Root cause: specific file/line/pattern
#   Fix: why this exact change is correct
#   Verification: test results
git log --oneline
```

### Git push — final step

```bash
cd /c/Projects/<project-root>/repo
```

**Step 1: Stage and commit the fix-summary-v1.md:**

```bash
git add fix-summary-v1.md
git commit -m "[FIX-SUMMARY] Document all bugs, fixes, and time-constraint gaps

Problem: Reviewer needs to understand full scope of work at task end.
Fix: Included fix-summary-v1.md with 4-field format per task (Problem/Fix/Verification)
  for all completed tasks and all time-constraint gaps (from fixed-vs-no_fix.md).
Verification: File exists, contains all P0/P1 fixes, documents all skipped tasks
  with clear instructions on how to fix if time permits.

Refs: Task-Registry v1, Bugs-Report v2, Time-Constraint Report (if exists)"
git push
```

**Step 2: Push remaining fix commits (20 individual commits for each T-XXX).**

**Final step before the 90-min timer expires.** If the push fails due to auth, ask the user to authenticate.

---

## ⏱ Time Budget Management (CRITICAL — target 73 min, 17 min buffer)

| Phase | Duration | Cumulative | If running behind |
|-------|----------|------------|-------------------|
| Phase 0 — Pre-Flight + Clone | 8 min | 8 min | Skip (should be done before the task) |
| Phase 1 — Recon (static only in the task) | 15 min | 23 min | Skip browser step (1f) — time-pressure mode skips this automatically |
| Phase 2 — Duck Verify | 8 min | 31 min | Only ask security-specific ducks |
| Phase 3 — Fix Planning | 8 min | 39 min | Skip complex fixes, focus on simples |
| Phase 4 — Task Registry | 5 min | 44 min | Minimize documentation, skip duck final verify |
| Phase 5 — Fix Exec | 25 min | 69 min | Only P0 + P1 fixes |
| Phase 6 — Validation + Push | 4 min | 73 min | Verify only, push whatever is committed |
| **Buffer** | **20 min** | **90 min** | **Absorbs any phase overrun or accident** |

**Hard rule at 80 min:** Stop fixing. Commit what's done, document remaining findings in `bugs-report.md` with severity and fix guidance, and **push**. A partially-fixed audit with clear documentation beats rushing and breaking things.

**Hard rule at 85 min:** Stop everything. Push whatever is committed. Uncommitted work is worthless.

 ---
 
 ## 📋 Abort/Fallback Protocols

| Time remaining | Situation | Action |
|---------------|-----------|--------|
| **T-30 min** (60 min elapsed) | Behind schedule | Skip Phase 2 (duck verify), go straight to fix planning. P2/P3 bugs get documented only. |
| **T-15 min** (75 min elapsed) | Still fixing | **Stop fixing.** Commit whatever is done. Skip Phase 6 validation — just run tests and push. |
| **T-10 min** (80 min elapsed) | 🔴 HARD STOP FIXING | `git add`, `git commit`, `git push`. Document remaining findings in a quick notes file. |
| **T-5 min** (85 min elapsed) | Push failed | Try `git push` again. If still failing, zip the repo folder: `zip -r task-output.zip repo/` and save to desktop. Tell the user to upload manually. |
| **Docker dead** | Container won't start | Switch to SQLite (check if app supports it). If not, document the issue and move to static code analysis only. |
| **Model timeout** | Subagents timing out | Switch to manual mode — read files directly, use `rg`/`grep` for pattern scanning. Skip subagents entirely. |
| **Git push auth fail** | SSH key rejected | Try: `git remote set-url origin https://<token>@github.com/...` or ask user for credentials. Last resort: zip repo. |

---

## 🔴 Hard Rules

### 🔴🔴 Subagent Blank-Slate Rule (applies to ALL phases)
Every subagent prompt MUST include:
- Exact file names to create or read
- Absolute output paths (never relative, never assumed)
- Expected format/structure of the output
- All relevant context they need (they do NOT have access to AGENTS.md, prior phases, conversation history, or the agent's memory)

Subagents are **blank slates**. They know nothing. Do not assume they know the project structure, file naming conventions, or what a prior phase produced. Spell out everything explicitly in every `delegate_task()` call.

**Example of a BAD prompt:** `"Produce an architecture document and save it."`
**Example of a GOOD prompt:** `"Save the architecture document as big-picture-architecture-v1.md at C:/Projects/<project-root>/big-picture-architecture-v1.md. Include: app purpose, architecture flow, data model, components, routes, dependencies, entry points, per-module breakdown."`

### 🔴🔴 Subagent Temp-File Rule — No Collisions (applies to ALL phases)

**TRIGGER:** Whenever 2+ subagents contribute to the same final deliverable file.

**Rule:**
1. Assign each subagent a **unique temp filename** in the `temp/` folder: `temp/<deliverable>-<role>-v1.md`
2. Subagents write ONLY to their assigned temp file — never touch the final deliverable
3. Once all subagents complete, the **main agent consolidates** the temp files into the final deliverable at the correct location
4. Clean up temp files after consolidation

**Example — Phase 1 bug discovery with 3 subagents:**
- Subagent A writes to `temp/bugs-backend-v1.md`
- Subagent B writes to `temp/bugs-frontend-v1.md`
- Subagent C writes to `temp/bugs-runtime-v1.md`
- Main agent merges all into `bugs-report-v1.md` at project root, then deletes temp files

**Single-subagent tasks are unaffected** — this rule only fires when multiple subagents target the same output.

**Why:** Without this, the last subagent to finish silently overwrites all other subagents' work. Discovered in practice run — backend subagent's 406-line, 28-bug report was replaced by runtime subagent's 90-line report because both wrote to `bugs-report-v1.md`.

### 🔴🔴 Post-Phase Verification Gate (applies to ALL phases)
After each phase completes, the main agent MUST verify all expected deliverable files exist at their correct paths before proceeding to the next phase. If ANY expected file is missing:
1. DO NOT start the next phase
2. Determine why the file is missing (subagent failed, wrong path given, etc.)
3. Re-run the subagent or create the file directly
4. Only proceed when all deliverables are confirmed present

### 🔴🔴 Pre-Flight Gate Before ALL Duck Phases
Before starting ANY phase that involves rubber ducks (Phase 2, Phase 3 duck audit, Phase 4 duck verify), verify these files exist at project root:
- `big-picture-architecture-v1.md`
- `bugs-report-v1.md`
- `temp/moon-dependency-graph.md`

If ANY are missing, DO NOT start the duck council. Return to the prior phase and create the missing files first. Feeding nonexistent files to ducks wastes time and produces garbage results.

### Main Agent Orchestrator Rule (context health #1)
The main agent is the **orchestrator** in this workflow. Protecting context health is the #1 priority.

**🟢 Main agent does DIRECTLY (no subagent needed):**
**Rubber Duck Interaction** — Main agent does DIRECTLY (no subagent needed):
1. **⚠️ MUST load the `rubber-duck-council` skill** (`skill_view(name='rubber-duck-council')`) before ANY rubber duck work, regardless of phase. Not optional.
2. **⚠️ MUST use the wrapper script** found inside the `rubber-duck-council` skill (check skill for exact script path). Do NOT call MCP duck tools directly — the wrapper handles prompt construction, squad selection, file-feeding, and synthesis.
3. **⚠️ Always use `--mode compare --squad quick`** (3 ducks) unless the user explicitly says otherwise. This is universal across ALL phases of the workflow. Never use `--squad max` (6 ducks) unless told to.
4. **⚠️ LARGE REPO EXCEPTION:** If the repo qualifies as large variant (70MB+ or 100K+ lines), do NOT use the wrapper script. Instead, use `ask_duck(provider: "grok")` directly — single duck only. Pass file paths (not file contents) and include the sandboxfs bridge instruction in the prompt. See `rubber-duck-council` skill for exact `ask_duck` syntax and sandboxfs prompt template. Reason: 3 ducks too slow for large repos, will fail the time budget.
5. Loading the skill, preparing prompts, calling duck tools, interpreting results — all done by the main agent DIRECTLY. Never delegate rubber duck work to subagents.
2. Writing and updating the proposed fix doc, fix handoff doc, and /goal draft prompt — **⚠️ Also main-agent-only. Never delegate doc preparation to subagents.**
3. Direct conversation with the user (progress updates, phase transitions, presenting findings)
4. Loading skills (skill_view, skills_list)

**🔴 Main agent MUST delegate to subagents or ACP agents:**
- Reading/analyzing the codebase (Phase 1)
- Running browser discovery (Phase 1f — use Hermes browser tools)
- Executing bug discovery scans and architecture mapping
- Running tests and verification
- ANY coding work — never write code directly
- File operations that produce large output (prevent context bloat)

**Why:** Every tool call the main agent makes directly fills the context window with intermediate output. Subagents isolate that noise. If a subagent gets stuck in a loop, the main agent can detect and restart it. If the main agent gets stuck, nobody notices until it's too late.

### Multi-session discipline
- **Session A (debug) NEVER writes code.** Period. All fixes happen in Session B.
- **Session B (fix) NEVER plans.** Use the handoff doc and task registry.
- Handoff docs and task registries are the contract between sessions.

### Screen-share discipline (task-specific)
- Before EVERY phase, announce to the user what comes next and ask "Ready to proceed?"
- Between Phase 0 and Phase 1, present the FULL plan so the judge sees the workflow
- The user should appear engaged and in control on camera

| Situation | What to say |
|-----------|-------------|
| While subagents scan code | *"Let me give the subagents a moment to analyze the codebase. I'll review their findings as they come in."* |
| While rubber duck compares | *"I'm cross-referencing our findings with multiple AI perspectives to catch blind spots. This takes about a minute."* |
| While reading duck results | (Scrolling through report on screen) *"Good, the ducks confirmed most of our findings. One thing they caught..."* |
| While fix session runs | *"I'm applying the fixes now — running tests between each change to make sure nothing breaks."* |
| If stuck / thinking | *"Let me investigate this path further before deciding on the approach."* |
| If behind schedule | *"We're a bit behind, so I'll prioritize the critical fixes and document the rest."* |
| After each commit | *"One fix done, tests passing. Moving to the next issue."* |

### Skill-writing convention: pronoun clarity
- When writing skill documentation, use **"the user"** (not "you") when referring to the human.
- Use **"I"** or **"the agent"** (not "you") when referring to the agent reading the skill.
- This prevents ambiguity: "you" could mean either the agent executing the instructions or the human on the other end of the chat. Examples:
  - ✅ *"The user verifies my findings afterward"*
  - ❌ *"You verify my findings afterward"* (ambiguous — who is "you"?)
  - ✅ *"Present findings to the user"*
  - ❌ *"Tell you what I found"* (unclear if this means tell the human or tell yourself)

### Commit discipline
- One commit per issue
- `git commit -m "fix: [problem]" -m "Problem: ... \nRoot cause: ... \nFix: ... \nBack-compat: ..."`
- Clean worktree before moving to next issue

### Test discipline
- Run tests BEFORE any changes (baseline)
- Run tests AFTER every change
- Never declare a fix done without green tests

### Documentation discipline
- Every finding gets documented, even if you don't have time to fix it
- Severity, location, reproduction steps, potential fix
- This counts as "diagnostic depth" even when time runs out

### Security-first prioritization
1. 🔴 Plaintext secrets / credentials — highest priority
2. 🔴 SQL injection — can leak/compromise all data
3. 🔴 Missing auth — unauthorized access to endpoints
4. 🟡 Reliability — crashes, resource leaks
5. 🟡 Performance — N+1 queries, blocking calls
6. 🟢 Developer experience — build speed, test gaps

### Subagent discipline (context health)
**Phase 1 subagents are the MOST critical.** Their output is large (reading entire codebase) and would destroy context. Always delegate Phase 1 to subagents.

- Phase 1 subagents → a fast, accurate model (e.g. DeepSeek v4 Pro)
- Phase 5 fix execution → ACP strong coder (primary) → subagent fast capable model (fallback) → manual (last resort)
- Rubber duck → quick compare via wrapper script (`--mode compare`, default `--squad quick`)
- Files read by ducks → use `filesystem_readonly-mcp` bridge (sandboxfs). Explicitly tell ducks they have these tools.

---

## 🕳 Pitfalls

| Issue | Fallback |
|-------|----------|
| `moon print` not found (moon 2.x) | Use `moon project` instead — shows project list and dependencies |
| `moon :test` cold cache (first run) | Kick off `moon :test &` in Phase 1c to warm cache before Phase 1e |
| Moon not in PATH | `source ~/.bashrc` first, or use full path to moon binary |
| Moon toolchain plugin vs runtimes | `moon toolchain download` only installs the plugin. Python/Node runtimes download lazily on first `moon run` — expect a one-time delay. Cached after that at `~/.moon/toolchains/`. |
| **Port collision on dev server start** | Before starting any dev server, check if the port is in use: `netstat -ano | grep :3000` (or target port). If occupied, either kill the process or change the port in the app config (e.g., `vite.config.ts` `server.port`). Subagents may report "server started with no errors" even when the port was already taken — always verify with `curl localhost:<port>` afterward. |
| **Import-time crash blocks all startup** | A deliberately broken `import nonexistent_module` in a route file crashes the server at import time with `ModuleNotFoundError`, before any server loop runs. The process exits immediately with no port binding — the curl check just reports "Server not responding" without explaining why. **Pre-flight:** run `python -c "from app.api.routes import router; print('OK')"` before starting the server. If this fails, the server won't start. This pattern is a common time-pressure task trap — route files import a phantom module to test whether the auditor notices the server never booted. |
| **Subagent success report not verified** | A subagent saying "frontend started on :3000 with no errors" is NOT proof the server is accessible. Always verify: `curl -s localhost:<port>` or `browser_navigate("http://localhost:<port>")`. "Process started" ≠ "server responding." |
| **Patch tool backslash escape on Windows** | The `patch` tool interprets `\r`, `\n`, `\t` in paths as escape chars. `C:\Projects\...\repo` becomes `C:\Projects\...\nepo` (the `\r` is eaten). Workaround: use forward-slash paths (`C:/Projects/.../repo/`) in terminal commands, or use `write_file` with absolute Windows paths for file creation. |
| **Fabricated bug counts** | Never report bug counts that were not directly read from `bugs-report-v1.md`. If a subagent's summary says 16 bugs, report 16 — do NOT extrapolate, round, or invent "25 injected + 10 natural = 35" without evidence. The user values facts above all. If the count is uncertain, say "approximately N based on the subagent summary" and verify against the actual file. |
| **`uvicorn app.main:app` fails — app not at module level** | Some FastAPI apps define `app` inside a `run_fastapi()` function (multiprocessing pattern) rather than at module level. `uvicorn app.main:app` will fail with `AttributeError: module 'app.main' has no attribute 'app'`. Fix: run the app via `python -m app.main` instead, which triggers the `if __name__ == "__main__"` block that starts both gRPC and FastAPI subprocesses. |
| **Handoff port mismatch vs actual code** | The fix-handoff doc may state port 8000, but the actual `uvicorn.run()` call inside the code may use port 8001 or another port. Always read `main.py` to find the actual port before attempting to curl endpoints. Don't trust handoff docs for port numbers — trust the source code. |
| **Verification subagent hits max_iterations** | A subagent dispatched to boot the backend and test endpoints may hit max_iterations (50 tool calls) without producing a summary, especially if it encounters port conflicts or import path issues and keeps retrying. If the verification subagent returns "failed: max_iterations" with no summary, the main agent should do the boot verification directly. The boot-test sequence is: (1) `python -c "from app.api.routes import router; print('OK')"` to check imports, (2) `python -m app.main` in background, (3) `sleep 6 && curl -s -o /dev/null -w "%{http_code}" http://localhost:<port>/docs`, (4) test individual endpoints with curl. |
| **Seed data email may not match handoff doc** | The handoff verification checklist may say `GET /api/user?email=candidate1@example.com` should return 200, but the actual seed data may use a different email (e.g., `test@example.com`). If a user lookup returns 404, check the admin endpoint (with auth) to see what users actually exist in the database: `curl -s -H "X-API-Key: dev-only-key" http://localhost:<port>/api/admin/users`. |
| **Stale DB state after mutation bug fix** | When a data-mutation bug (e.g., GET endpoint that writes to DB) is fixed in code, the SQLite DB file may still contain stale mutated data from before the fix. The API will return the wrong data even though the source code is correct. To verify properly: (1) kill the backend process, (2) delete the DB file (`app.db` or similar), (3) restart the backend so it recreates the DB from seed data, (4) then test. Confirmed: `grep -rn "Modified Name" backend/app/ --include="*.py"` returns nothing (fix is in code), but `grep "Modified Name" backend/app.db` returns a match (stale data in DB file). |
| **rm on locked DB file fails silently** | `rm -f app.db` fails with "Device or resource busy" when the backend process is still holding the file. Must kill the process first, wait 2-3 seconds, then delete. If `rm` runs in a background terminal, the failure may be silent — always check exit code or verify the file is gone afterward. |
| **taskkill syntax in git-bash** | `taskkill //F //PID <pid>` fails in git-bash with "Invalid argument/option". Use `powershell -Command "Stop-Process -Id <pid> -Force"` instead. Or find the PID via `netstat -ano | grep :<port>` and kill via PowerShell. |
| **Practice mode — skip git push** | For practice runs, Phase 6 validation is still required but git push can be skipped. Just verify all fixes work end-to-end (backend boots, API responds, frontend connects, no regressions). Tell the user "no git push needed for practice" and focus on the validation checklist. |
| **🔴 Copilot shell CWD mismatch** | When launched inside VS Code Copilot shell ("Hermes soul, Copilot shell"), the Hermes session CWD is the Hermes install directory (`C:\Users\<user>\Workspaces-agents\hermes`), NOT the VS Code workspace path. Subagents inherit this CWD and will create files at the wrong location. **Workaround:** (a) Pass absolute paths in ALL subagent prompts and `write_file`/`patch` calls — never relative paths. (b) Pass `workdir` to `terminal()` calls. (c) For a permanent fix, update the session CWD in `state.db` directly: find the session ID, then `UPDATE sessions SET meta = json_set(meta, '$.cwd', '<project-root>') WHERE id = '<session-id>'`. **Do NOT trust file paths from subagents without verifying with `ls` or `search_files` afterward.** Backup state.db before any modification. |
| **🔴 Fabricated verification claims** | Saying "File verified on disk (3.5 KB)" without actually running a check is a critical trust violation. NEVER claim a file exists unless you have run `search_files` or `terminal ls -la` to confirm it IN THIS TURN. "I wrote the file" ≠ "the file exists." Subagent reports of file creation are claims, not facts — verify independently. If you cannot verify, say "I cannot verify that" rather than fabricating. This applies to: file existence, bug counts, port availability, server responsiveness, test results. |
| **🔴 Narrating instead of executing** | When the user says "go" or "feed the ducks," the tool call MUST happen in the SAME response. Writing paragraphs about "which method to use" or "I'll prepare the prompt now" without making the tool call is wasted time. The tool-use enforcement rule is absolute: if you say you will do something, make the tool call in the same turn. No "I'll do it next" — do it now. |
| **3-way diff for surgical fix verification** | To verify fixes were surgical (not over-engineered), diff the fixed repo against BOTH the buggy version AND the original clean version. Keep three folders: `repo/` (fixed), `repo-src/` (buggy, no fixes), `repo-src (no bug)/` (original clean). Run `diff -r repo/ "repo-src (no bug)/"` — the output should show ONLY the lines that fix bugs, nothing else. Any unrelated changes (restructured imports, rewritten functions, new files) indicate over-engineering. This catches fix-session drift toward rewriting instead of patching. |
| **🔴 Task registry old_string ≠ actual file content** | When executing fixes in Session B from a task registry created in Session A, the `old_string` in the registry may NOT match the actual file on disk. Common causes: (a) the repo was cloned with different line endings or whitespace, (b) a prior fix in the same phase changed the surrounding context, (c) the title/text of a UI element differs from what the debug session assumed. For every task, the fix subagent MUST read the file first and confirm the old_string before calling `patch()`. If the old_string doesn't match, the subagent should adjust it to match the actual file content — the intent of the fix is what matters, not the exact bytes in the registry. This affected T-020 in a practice run: registry expected title "Vite + React + TS", actual file had "TS Frontend". |
| **🔴 Task registry false positives — bugs already fixed in baseline** | Bugs-report-v1.md may flag issues that the baseline code already addresses (e.g., JWT secret using env var, passwords already hashed, SQL already parameterized). The task registry can inherit these as false-positive tasks. Before writing any task in Phase 4, VERIFY the bug still exists in the actual `repo/` source code — do not blindly convert every bugs-report entry into a task. P0-1 (hardcoded JWT) and P0-2 (plaintext passwords) were false positives in the real task: the code already used `os.environ.get("GRPC_JWT_SECRET", ...)` and SHA-256 hashing. The fix session spent time discovering this instead of fixing real bugs. |
| **🔴 Python venv isolation — Hermes venv contaminates project venv** | When running project Python commands (tests, scripts) via `terminal()`, the Hermes agent's own venv may pollute the Python import path. Even when invoking the project's venv Python binary directly, packages like `google.protobuf` load from the Hermes venv instead. **Fix recipe in `references/python-venv-isolation-windows.md`.** Short version: `unset VIRTUAL_ENV PYTHONHOME PYTHONPATH && export PATH="/path/to/project/venv/Scripts:/path/to/system/python:/usr/bin:$PATH"`. Verify with `python -c "import google.protobuf; print(google.protobuf.__file__)"` — must point to project venv. 61 tests that failed under contaminated env passed instantly once isolated. |
| **🔴 search_files fails on MSYS2/Cygwin paths — fall back to terminal grep** | On Windows (git-bash/MSYS), `search_files` with paths under `/c/Projects/...` frequently fails with "IO error: The system cannot find the file specified." This is a path resolution bug — retrying does not fix it. **Immediate fallback:** use `terminal()` with `grep -rn "pattern" path/`. Do NOT retry `search_files` more than once — it wastes task minutes. |
| **🔴 pnpm-lock.yaml (or any lockfile) uncommitted after Phase 0** | Running `pnpm install` in Phase 0 modifies lockfiles. Uncommitted artifacts persist through all phases and show in `git status` at Phase 6. **Fix:** commit as `chore: update lockfile after dependency install` during Phase 0, or document in the handoff. |
| **🔴 Python venv isolation — Hermes venv contaminates project venv** | When running project Python commands (tests, scripts) via `terminal()`, the Hermes agent's own venv may pollute the Python import path. Even when invoking the project's venv Python binary directly, `google.protobuf` and other packages may load from the Hermes venv. **Fix recipe in `references/python-venv-isolation-windows.md`.** In short: `unset VIRTUAL_ENV PYTHONHOME PYTHONPATH && export PATH="/path/to/project/venv/Scripts:/path/to/system/python:/usr/bin:$PATH"`. Verify with `python -c "import google.protobuf; print(google.protobuf.__file__)"` — it must point to the project venv, not the Hermes venv. 61 tests that failed under contaminated env passed instantly once isolated. |
| **🔴 search_files fails on MSYS2/Cygwin paths — fall back to terminal grep** | On Windows (git-bash/MSYS), `search_files` with paths under `/c/Projects/...` frequently fails with "IO error: The system cannot find the file specified." This is a path resolution bug in the tool — retrying with the same path does not fix it. **Immediate fallback:** use `terminal()` with `grep -rn "pattern" path/` instead. Do NOT retry `search_files` more than once — it wastes precious task minutes. |
| **🔴 pnpm-lock.yaml (or any lockfile) uncommitted after Phase 0** | Running `pnpm install` in Phase 0 modifies `pnpm-lock.yaml`. This uncommitted artifact persists through all phases and shows up in `git status`. Either commit it as a `chore:` commit in Phase 0 (preferred), or document it in the handoff so the fix session knows it's intentional. Uncommitted files at Phase 6 cause confusion. |
| **🔴 Task registry paths all wrong (pre-clone) + missing build artifacts** | See `references/path-stale-registry-and-missing-artifacts.md` for two failure modes: (1) task registry written before repo clone → every file path wrong → all P0 bugs false positives; (2) gitignored build artifacts not generated → dev server 500s with import errors. Both discovered during real task fix session. |
| **🔴 Coding agent hangs (no output) — check logs first** | When a coding agent (OpenCode PTY/ACP) produces no output after timeout, do NOT assume the prompt was wrong. Check `~/.local/share/opencode/log/opencode.log` for `step=N` incrementing, `evaluated permission`, `touching file` — these mean the model was working but ran out of time. Retry with longer timeout. Also look for `Upstream idle timeout exceeded` — that's OpenRouter's 5-min upstream limit when a reasoning model (e.g. MiniMax M3) is enabled. Fix: disable reasoning (`reasoning: none` in opencode config). |

---

## Skill Interactions

| Skill | Role |
|-------|------|
| `filesystem_readonly-mcp` | Read-only file access for ducks (jailed to C:\Builds, C:\Projects). See system-doc for details. |
| `rubber-duck-council` | Verification and audit at every phase — use fire-and-forget hybrid mode. If unavailable, use the **Audit Gate Fallback** above (subagent audit with explicit edge-case + gap analysis) |
| `systematic-debugging` | Per-bug investigation methodology |
| `subagent-first` | Always delegate, never implement directly |
| `github-now` | GitHub repo management — create, update, search, plus clone/commit/push via git |
| `complex-project-workflow` | Template this skill was derived from |
