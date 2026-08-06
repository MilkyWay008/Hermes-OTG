---
name: complex-project-workflow
description: "⚠️ MASTER WORKFLOW — use for ANY project: build, consulting, content creation, business ops, research, or multi-phase delivery. 7-phase protocol: Charter → Recon → Blueprint → Review → Execute → Assemble → Retrospect. Hard gates between phases. Context health priority #1 — always orchestrate, never implement directly."
version: 1.0.0
author: Ringo/MilkyWay008
url: https://github.com/MilkyWay008
platforms: [linux, macos, windows]
metadata:
  hermes:
    tags: [planning, audit, build, methodology, orchestration, workflow, project-management, consulting, generic]
    related_skills: [rubber-duck-council, subagent-first, opencode-acp-delegation, pre-project-reconnaissance]
---

# Complex Project Workflow

## Overview

A universal, domain-agnostic project execution methodology. Works for anything — code builds, consulting engagements, content production, business process design, research projects, or any complex multi-phase delivery.

**Core insight:** Every project fails the same way — skip clarity, skip review, or try to do everything at once. This workflow hard-gates against all three.

**Orchestrator discipline (HARD RULE):** You stay at altitude. NEVER implement directly. NEVER review code/content directly. NEVER run tests/validation directly. Delegate everything to subagents or ACP agents. Your context window is for coordination, not implementation. Even duck council queries go through subagents.

## When to Fire

This skill is the **primary** workflow for any project that has 2+ phases, 3+ components, or external stakeholders. If a task fits in a single conversation turn, don't load this — just do it directly.

**Trigger examples:**
- "Let's build a RustDesk fork that embeds MCP" → ✓ Load this
- "I need a consulting proposal for ABC Realty's AI agent setup" → ✓ Load this
- "Let's create a YouTube podcast series from scratch" → ✓ Load this
- "Can you fix this bug in my config file?" → ✗ Don't load this

## WORKFLOW MODES

This skill supports two modes. **Default is coding-centric.** When the project involves clients, stakeholders, or non-technical deliverables, the skill auto-detects and switches to expanded mode.

### Mode Detection

Check at session start:
1. Is there a client or external stakeholder mentioned? → Use **Expanded Mode**
2. Is the primary deliverable non-code (consulting doc, marketing plan, script, podcast, research paper)? → Use **Expanded Mode**
3. Otherwise → Use **Coding Mode** (default)

In **Expanded Mode**, every phase gets the `[CLIENT]` treatment: draft for internal review first (duck council brief), then present to client for sign-off before advancing. The duck council acts as a "mock client" to sharpen deliverables before they reach real stakeholders.

---

## PHASE 0 — Project Charter (ACTIVE DRILL-DOWN)

**Purpose:** A single-page stake in the ground. Prevents scope drift before any work begins.

**HARD RULE:** This is NOT a document I write alone and present. Phase 0 is an **interrogation**. I must drill the user until the charter is solid before allowing Phase 0a to start. If objectives are vague, incomplete, or contradictory, all downstream phases build on sand.

### The Drill-Down Process

I ask. The user answers. I keep asking until every question below has a concrete answer. Do NOT accept "we'll figure it out later" — that's the exact failure mode this phase exists to prevent.

#### Question 1: What are we doing?

One sentence. If the user can't say it in one sentence, the scope is unclear and needs more work. Push until they can.

> *Bad: "We're going to help ABC Realty with AI."*
> *Good: "We're designing 4 AI-agent workflows for ABC Realty: back office admin, customer handling, lead generation, and marketing."*

#### Question 2: Why? What problem does it solve?

What's broken or missing without this project? What's the cost of not doing it?

#### Question 3: Who is this for?

Target audience, stakeholders, clients, end users. Be specific.

#### Question 4: What does "done" look like?

Testable completion criteria. Not "it works" — what specifically proves success?

> *Bad: "The RustDesk fork is done."*
> *Good: "A remote computer can be connected to via RustDesk, and the remote agent has access to windows-mcp tools, TTS/STT, and PowerShell through a single SSE endpoint."*

#### Question 5: What are the constraints?

Budget, timeline, tech stack limitations, regulations, platform restrictions, expertise gaps. What's NOT available?

#### Question 6: What is explicitly NOT in scope?

**This is the most important question.** Anti-scope prevents mission creep. List things the project explicitly will NOT do.

> *Example: "We will NOT build a custom UI. We will NOT support macOS. We will NOT build a native mobile client."*

#### Question 7: What key risks do you see upfront?

The top 3 risks the user already has in mind before any research. This seeds Phase 0a.

### Gate Rule

Phase 0 is complete only when:
- All 7 questions have concrete answers
- The user confirms the charter is accurate
- **[CLIENT MODE]** The client has signed off

Do NOT proceed to Phase 0a without all three conditions met. An unclear charter guarantees wasted research effort.

### Escalation Handle

> *"If at any point the project seems impossible, excessively costly, or needs fundamental re-scoping — PAUSE and report to the user. Do not grind forward on a flawed foundation."*

This handle applies to EVERY phase below.

---

## PHASE 0a — Reconnaissance

**Purpose:** Validate assumptions before designing. Research dependencies, competitors, constraints, and unknowns.

### What to Investigate

For each major unknown (tool, API, platform, regulation, competitor, market segment):

| Question | Why it matters |
|----------|----------------|
| What are the actual capabilities and limitations? | Prevents designing on false assumptions |
| What runtime/environment does it need? | Docker? Windows? Mobile? Browser? |
| What's the licensing or regulatory landscape? | Commercial viability, compliance burden |
| Are there known blockers or gotchas? | Community knowledge of pain points |
| Who are the main players/alternatives? | Competitive landscape for strategy |

### Execution

- Delegate one focused subagent per research thread
- Run up to 3 subagents in parallel
- Collect results, cross-reference contradictions
- Synthesize into a **"constraints brief"** (1-2 pages max)
- Only then start Phase 1a

### Natural Loop

**Phase 0a ↔ Phase 1a is an expected cycle.** When you start drafting the blueprint, you'll discover gaps in your recon. That's normal — loop back to Phase 0a before going deeper. This is not a failure, it's how good architecture works.

**[CLIENT MODE]** — If Phase 0a reveals industry-specific constraints (regulations, standard practices, competitor strategies), document them separately as a **"landscape brief"** for the client. This is a value-add deliverable in itself.

---

## MODE: TIME-BOXED EVENT PREP (Exams, Demos, Audits)

**Trigger:** The user is preparing for a future session with hard time constraints (e.g. a 90-minute coding exam, a deadline demo, a time-capped audit). The primary deliverable is not the build itself — it's the **readiness** for that event.

**Purpose:** Everything you prep today should be embedded directly into the AGENTS.md that will load at event time. The user should not have to re-explain anything when the event starts.

### Sub-Phase 0b — Context Pre-Loading

When prepping for a time-boxed event, perform these steps IN ORDER before any other work:

#### 1. Create the AGENTS.md as the single source of truth

Create a dedicated project folder with AGENTS.md that will be the working directory during the event. Every piece of prep goes here — not in separate docs, not in memory that degrades across sessions. The user will start a new session with CWD set to this folder, so the AGENTS.md auto-loads as system prompt.

#### 2. Tool verification checklist

Verify every tool the event requires and install what's missing. Log each one's version and install path. Update the AGENTS.md with a status table so the event session knows instantly what's available.

#### 3. Dependency caching

Pre-pull, pre-install, or pre-build anything that would consume event time:

| What | Why | Example |
|------|-----|---------|
| Docker images | 1-3 min pull → ~3 second spin | `postgres:16`, `redis:7-alpine` |
| npm/pip packages | Large downloads at event time = panic | Let the repo's package manager handle these |
| Build artifacts | Compilation during event = time wasted | Pre-build if the toolchain is slow |

**Key rule:** Cache during prep, not during the event. If it takes >30 seconds to download/build, do it now.

#### 4. Scenario planning (A/B/C)

Identify the key unknowns the event repo might present. Document each scenario with the exact commands to run, right in the AGENTS.md. This way at event time there's zero deliberation — just read the scenario, run the command.

**Template pattern:**
```
Scenario A — [condition]:
👉 [exact command]. [follow-up action].

Scenario B — [condition]:
👉 [exact command]. [follow-up action].

Scenario C — [condition]:
👉 [exact command]. [follow-up action].
```

#### 5. Embed mental prep in system prompt

Don't rely on loading skills during the event (which costs context and time). Instead, embed condensed knowledge directly into the AGENTS.md:

- **Common vulnerability/issue tables** — patterns to watch for with fix patterns
- **Fix philosophy** — rules like "standalone over framework", "surgical over sweeping"
- **Workflow reminders** — what order to do things, what NOT to do
- **Tooling notes** — quirks about the shell, network, or environment

The format should be scannable: tables and bullet lists, not prose paragraphs. The event session should be able to read the AGENTS.md in <60 seconds and know exactly what's available and what to do.

#### 6. User-QA gate

Before declaring prep complete, ask the user:
- "Is there anything else you want loaded into AGENTS.md that would save time during the event?"
- This catches edge cases only the user knows about (e.g. "oh, also disable screen saver during the exam")

### When NOT to use this mode

- The event is more than 2 weeks away (prep will be stale — do a lighter version closer to the date)
- The event has no tool/dependency requirements (pure whiteboard or verbal)
- The user just wants to study content (not execution readiness)

---

## PHASE 1a — Blueprint

**Purpose:** The big picture. A single document describing what the project is and how it fits together.

### Deliverable: `blueprint.md`

- **The problem / opportunity** — what gap does this fill?
- **Architecture / structure at a glance** — high-level diagram or topology (ASCII, SVG, or org chart)
- **Core components / workstreams** — what are the major pieces?
- **Flow** — how do information, value, or deliverables move through the system
- **Key design decisions** — what choices shape the structure?
- **Scope** — what's in v1 / phase 1 vs deferred
- **Security / compliance model** — encryption, auth, regulatory boundaries, data handling

**Format:** Markdown. Save in project root under `docs/` or equivalent.

**[CLIENT MODE]** — Use business language. An "architecture document" becomes a "system design proposal." ASCII dependency graphs become workflow flowcharts. Deliver to client for review before Phase 1b.

---

## PHASE 1b — Component Breakdown

**Purpose:** Expand the blueprint into concrete components, modules, or workstreams.

### Deliverable: `breakdown.md`

For **each component**:

| Field | What goes here |
|-------|----------------|
| **Name** | One-sentence purpose |
| **Location(s)** | File paths, departments, channels, platforms |
| **Depends on** | What other components it needs |
| **Description** | What it does — functional description |
| **Sub-tasks / milestones** | The major pieces of work within this component |
| **Acceptance criteria** | Specific, testable pass/fail conditions |
| **Risks** | Top 3-5 risks with likelihood, impact, mitigation |
| **Effort** | Rough estimate — hours, days, or complexity level |

### Dependency Map

Include a dependency graph that shows which components block others:

```
          ┌───────────┐
          │ Back Office│
          └─────┬─────┘
                │
     ┌──────────▼──────────┐
     │  Customer Handling   │
     └──────────┬──────────┘
                │
     ┌──────────▼──────────┐     ┌────────────────┐
     │     Lead Gen         │◄────│   Marketing      │
     └──────────────────────┘     └────────────────┘
```

---

## PHASE 2 — Review Gate #1

**Purpose:** Submit Blueprint + Breakdown to the duck council. Find blind spots. Iterate until clean. Then make a Go/No-Go decision.

### Gate Format

```
Gate: Architecture & Design Review
Submit: blueprint.md + breakdown.md
Method: Subagent → duck council (reverse exception — even rubber duck through subagents)
Expectation: Council finds no substantial gaps or contradictions
Failure: Council identifies issues → iterate 1a/1b → re-submit
```

### What to Ask the Duck Council

> **Audit reference:** `skill_view('complex-project-workflow', 'references/common-code-audit-patterns.md')` — a 20-row pattern bank covering security, performance, reliability, and data-flow anti-patterns. Load during review to cross-check component designs against common vulnerability classes.

- Are there edge cases the design doesn't handle?
- Is any component underspecified?
- Are there integration risks between components?
- Can you find contradictions, blind spots, or missing pieces?
- Is the scope realistic for the defined phase/project?
- **IMPORTANT:** What would break this project in the real world?

### Iteration Rule

Every duck finding triggers a fix in the relevant doc. Do NOT accumulate a backlog — fix as you go. After fixes, re-submit. Repeat until the duck has nothing substantial to raise.

### Go / No-Go Decision (CRITICAL GATE)

After the duck greenlights Phase 1a + 1b, answer:

> **"Is this project worth building as designed?"**

Options:
- **Go** — proceed to Phase 1c
- **Pivot** — the design is wrong, but the core idea is salvageable → return to Phase 0 / 0a with revised charter
- **Kill** — the project is fundamentally flawed, too expensive, or unnecessary → close the project, report to user, save lessons to Phase 5

Do NOT skip this gate. The duck finding "clean architecture" does not mean "worth building." That's a human decision.

**[CLIENT MODE]** — Before the Go/No-Go, do a **mock client review**: ask the duck council to roleplay as the client and review the documents from a business perspective. Address those findings, then present to the real client.

---

## PHASE 1c — Execution Plan

**Purpose:** Detailed tasks that implement each component. This is what executors (subagents, ACP agents, human team members) will follow.

### Hybrid Registry Format

**One registry index always exists.** A single file (`task-registry.md` or `execution-plan.md`) listing every component, its dependency order, and a pointer to where the detail lives. This lets the duck council see the full map in one shot for logical debug.

**Detail lives in per-component docs** when the project is large enough that one file becomes unwieldy (e.g., >50 tasks or 3+ components). Each component doc contains its own task breakdown with acceptance criteria.

### Task Format

Each task entry (in either the registry or per-component doc):

```markdown
### Task [N]: [Action Verb] [Object]

**Component:** [Which component this belongs to]
**Dependency:** [Task N that must be done first, or "none"]
**Toolset needed:** [e.g., terminal, coding, web, browser]
**Files / artifacts affected:** [exact paths]
**Instructions:** Complete, executable steps. For code: include code blocks. For content: include structure. For research: include exact questions and sources.
**Acceptance criteria:** [Testable pass/fail condition — "what does done look like?"]
```

**[CLIENT MODE]** — Tasks may include client-facing milestones: "Draft contract addendum," "Schedule stakeholder interview," "Record screencast demo." Acceptance criteria can include client sign-off.

### Document Currency Rule

If you discover a flaw in Phase 1a or 1b while writing Phase 1c, **go back and fix the earlier document before moving forward.** Cascading errors are the #1 project killer.

---

## PHASE 2b — Review Gate #2 (Logical Debug)

**Purpose:** Submit ALL documents (Charter, Blueprint, Breakdown, Execution Plan) for a full "logical debug" audit.

### Gate Format

```
Gate: Logical Debug Audit
Submit: charter.md + blueprint.md + breakdown.md + execution plan docs
Method: Subagent → duck council
Expectation: Council confirms the tasks are complete, correctly ordered, and sufficient to build the components described in 1a/1b
Failure: Council identifies gaps, ordering issues, or insufficient task coverage → fix and re-submit
```

### What to Ask

- Given the full document set, are there logical gaps between what the blueprint describes and what the tasks deliver?
- Are tasks in the right dependency order?
- Are there missing tasks — things the breakdown says should exist but the execution plan doesn't cover?
- Are there duplicate or overlapping tasks?
- For each component: "If I execute all its tasks in order, does it produce a working component?"
- For the full set: "If all components are built as described, do they integrate into the system described in the blueprint?"

### Gate Rule

Do NOT proceed to Phase 3 until both Review Gates pass. A duck that keeps finding issues is cheaper than debugging broken integration later.

**[CLIENT MODE]** — This is where you also do the **stakeholder feedback loop**. Present the full plan to the client (or mock client via duck) for sign-off. The duck council acts as a "pre-client audit" so the client sees polished, professional deliverables.

---

### Phase 3

**Purpose:** Build everything, one component at a time.

### HARD GATE: Docs-First Before Any Build (Iteration Safety)

**Before invoking ANY executor (subagent, ACP agent, or manual), you MUST update ALL three architecture documents in this ORDER — top-down:**

1. **Big-picture/architecture doc** — topology, component model, data flow, scope, security model. Any new feature or component gets added here first.
2. **Module breakdown** — dependency graph, per-component tasks, acceptance criteria. The new feature's impact on existing modules gets documented here.
3. **Task registry** — mark completed tasks, add new tasks, update build phases. This is the executor's blueprint.

The ordering matters: big picture first defines the "what and why," breakdown defines the "how," registry defines the "who does what when." Each layer validates the layer above.

**This applies to ANY iteration cycle, not just Phase 3 entry.** When the user says "let's fix bugs and add features" to an existing project, the sequence is: docs → build. Not: build → docs.

**Exception:** A targeted "fix one bug" with zero scope expansion — update only the task registry with the fix note. Skip the full doc refresh.

**Why this rule (confirmed twice by the user across separate sessions):**
- "before you update any build, I want you to update some doc first, so we may have records"
- The user wants verifiable design history, not a race to code
- Stale docs are worse than no docs — they actively mislead duck council reviews and future you

### Orchestrator Discipline (HARD RULES)

```
┌───────────────────────────────────────────────────────────┐
│  RULE                                    │ WHY           │
├───────────────────────────────────────────────────────────┤
│ NEVER implement directly                  │ Context health│
│ NEVER review output directly              │ Context health│
│ NEVER run tests directly                  │ Context health│
│ Even duck queries → subagent              │ Context health│
│ One component at a time                   │ Focus + isolation│
│ Validate after each component             │ Catch early    │
└───────────────────────────────────────────────────────────┘
```

### Build Delegation Fallback Chain

When executing Phase 3 tasks, use this priority chain:

1. **ACP agents** (opencode ACP) — first attempt for any coding work
2. **Subagents** (delegate_task with direct API calls via httpx) — fallback when ACP fails or isn't suitable
3. **Manual coding** — last resort only. Manual coding tanks context health on larger builds

**HARD RULE:** Do NOT skip to manual coding because ACP failed. The next step is subagents, not manual. Only go manual when explicitly greenlit by the user.

### Per-Component Sequence

```
1. Load the component's task doc from Phase 1c
2. Spawn executors (ACP agents, subagents, or human assignments)
   - For code: use opencode-acp-delegation
   - For content: use delegated subagents
   - For research: use delegated subagents
3. After component is done → duck debug the output
4. Fix issues found
5. Repeat until component passes
6. Mark component complete, move to next in dependency order
```

### Per-Component Validation

After each component is built, run it through duck council with:

> *"Here is component [name] from the [project] build. Its task doc was [link]. Its output is [link/summary]. Does it satisfy the acceptance criteria from its task doc? Are there edge cases, bugs, or omissions?"*

Fix what the duck finds before moving to the next component.

---

## PHASE 4 — Assembly & Validation

**Purpose:** After all components are built and individually validated, assemble the whole system and run integration validation.

### Execution

1. Compile / link / assemble the full deliverable
   - For code: integration test across all modules
   - For content: compile all pieces into final format
   - For consulting: deliverable package review
2. Run the duck council on the **integrated whole**
3. Fix issues found
4. Only then declare the project deliverable-ready

**[CLIENT MODE]** — This is the final client presentation gate. Ask the duck council to do a "pre-client delivery audit": roleplay as the client, review the full deliverable, suggest improvements. Then present to the real client.

---

## PHASE 5 — Retrospective

**Purpose:** Capture lessons, archive artifacts. The phase that most projects skip — and the one that compounds value over time.

### What to Do

1. **Save lessons learned** to `memory-details/lessons/YYYY-MM-DD_<project-abbrev>-Retro.md`
   - What worked?
   - What didn't?
   - What would we do differently?
   - What skills or templates should be created or updated?
2. **Archive project artifacts** — final docs, deliverables, key decisions
   - Save to OneDrive `hermes/artifacts/<project-name>/` via `cloud-save` skill
3. **Update MEMORY.md** — project pointer to "completed" with key takeaways
4. **Update or create skills** — if the project revealed a reusable pattern, save it as a skill
5. **Close the project** — clean up temp files, temporary cron jobs, working branches

### For Consulting Projects

Add a **Client Handoff Package**:
- Executive summary of what was delivered
- Documentation for ongoing maintenance or usage
- Recommendations for next phase
- Invoice / billing notes if applicable

---

## THE FULL WORKFLOW MAP

```
                                  ┌─────────────┐
                                  │ Phase 0      │
                                  │ Charter      │
                                  └──────┬───────┘
                                         │
                                  ┌──────▼───────┐
                           ┌─────│ Phase 0a     │◄──────┐
                           │     │ Recon         │      │
                           │     └──────┬───────┘      │
                           │            │               │
                           │     ┌──────▼───────┐      │
                           │     │ Phase 1a     │      │
                           │     │ Blueprint     │──────┘ (natural loop)
                           │     └──────┬───────┘      when gaps
                           │            │               found
                           │     ┌──────▼───────┐
                           │     │ Phase 1b     │
                           │     │ Breakdown     │
                           │     └──────┬───────┘
                           │            │
                           │     ┌──────▼───────┐
                           │     │ Phase 2      │
                           │     │ Review Gate  │
                           │     │ (Duck + Go/N)│
                           │     └──────┬───────┘
                           │            │● Go/No-Go
                           │     ┌──────▼───────┐
                           │     │ Phase 1c     │
                           │     │ Execution    │
                           │     │ Plan          │
                           │     └──────┬───────┘
                           │            │
                           │     ┌──────▼───────┐
                           │     │ Phase 2b     │
                           │     │ Debug Gate   │
                           │     └──────┬───────┘
                           │            │
                           │     ┌──────▼───────┐
                           │     │ Phase 3      │
                           │     │ Implement    │── iterates per component
                           │     └──────┬───────┘
                           │            │
                           │     ┌──────▼───────┐
                           │     │ Phase 4      │
                           │     │ Assemble     │
                           │     └──────┬───────┘
                           │            │
                           │     ┌──────▼───────┐
                           │     │ Phase 5      │
                           │     │ Retrospect   │
                           │     └──────────────┘
                           │
                           └─ Each phase: duck + subagents only
                              Even client reviews: duck-mock → fix → real
```

---

## MODE: EXPANDED (Consulting / Client / Non-Code)

When Mode Detection triggers **Expanded Mode**, overlay these rules on every phase:

| Phase | Expanded Addition |
|-------|-------------------|
| Phase 0 | Charter includes stakeholder map, success metrics, communication cadence |
| Phase 0a | Landscape brief becomes a client deliverable itself |
| Phase 1a | Blueprint uses business language — diagrams, workflow maps, ROI framing |
| Phase 1b | Breakdown includes roles/responsibilities, decision rights |
| Phase 2 | Duck council does "mock client" review before real client presentation |
| Phase 1c | Tasks can include client-facing milestones; AC includes client sign-off |
| Phase 2b | Full deliverable walkthrough with client; duck acts as pre-client prep |
| Phase 3 | Implementation may include meetings, reviews, approvals — not just building |
| Phase 4 | Client delivery package, handoff documentation, training materials |
| Phase 5 | Client handoff package, executive summary for their leadership, recommendations |

### The Three Client Feedback Loops

1. **After Phase 0 (Charter)** — Client approves scope before work begins
2. **After Phase 2 (Architecture Review)** — Client sees and approves the plan
3. **After Phase 4 (Assembly)** — Client receives and accepts the final deliverable

Before each real client presentation, do a **duck council mock run**: ask the ducks to roleplay as the client, critique the deliverable from their perspective, then polish before showing the real thing.

---

## AUDIT GATE FALLBACK (when rubber duck is unavailable)

Every review gate (Phase 2, Phase 2b, per-component validation, Phase 4) normally runs
through the rubber duck council. **If the rubber duck skill or MCP server is not
available** (`skill_view(name='rubber-duck-council')` fails, or the MCP tools aren't
registered), **do NOT skip the audit** — fall back to a **subagent audit** instead:

1. Spawn a `delegate_task` subagent (or a small batch) with the EXACT audit prompt the
   ducks would have received (the gate's "What to Ask" list for that phase).
2. **Explicitly instruct the subagent:** *"Look for ALL possible edge cases, gaps,
   contradictions, blind spots, and failure modes. Perform a thorough gap analysis —
   what's missing, underspecified, or would break in the real world?"*
3. The subagent must return a structured findings list (each finding: severity, what's
   wrong, suggested fix). It must NOT edit any project files — audit only.
4. Treat findings exactly like duck findings: fix as you go, re-submit, iterate until
   the subagent raises nothing substantial.
5. Log which fallback was used (`subagent-audit` vs `duck-council`) in the phase record.

The audit gate is non-negotiable — the *mechanism* (ducks vs subagent) is interchangeable,
the *gap analysis* is not. Never proceed through a review gate without one of the two.

---

## SKILL INTERACTIONS

| Skill | Role in this workflow |
|-------|-----------------------|
| `rubber-duck-council` | Provides audit infrastructure for all review gates — ALWAYS via subagents. If unavailable, use the **Audit Gate Fallback** above (subagent audit with explicit edge-case + gap analysis) |
| `subagent-first` | Primary execution mechanism — everything through subagents |
| `opencode-acp-delegation` | Parallel coding agents in Phase 3 for code projects |
| `pre-project-reconnaissance` | Extended Phase 0a for very large or ongoing projects — launch when Phase 0a needs deeper research |
| `writing-plans` | Alternative for Phase 1c when the project is small enough to skip the full workflow |
| `plan` | Quick alternative for single-turn planning (do NOT load this skill for that) |
| `cloud-save` | Archival in Phase 5 |
| `memory-index` | Lesson saving and MEMORY.md updates in Phase 5 |

---

## PITFALLS

### General
- **Skipping the charter** — without a stake in the ground, every phase will drift. Start with Phase 0.
- **Skipping a gate** — the gates exist because each validates a different thing. Skip one and you'll catch the bug in Phase 4, where it costs 10x to fix.
- **Scope creep** — if something isn't in the charter, it doesn't go in the project. Push it to v2.
- **Orchestrator doing work** — the moment you start implementing or reviewing in your own context, you've violated the model. Stop. Use a subagent.
- **Build versioning with retirement folders** — when a major architectural change invalidates the current build, do NOT modify in place. Instead: (a) rename the current build folder with a `(retired)` suffix so it's preserved as reference, (b) copy the retired folder to a new version number (e.g., `echo-build-v2.3`), (c) work only in the new folder, (d) never touch the retired folder for any reason. This keeps history intact and prevents accidental rollback. The old folder's contents serve as the "before" snapshot for documentation — compare script diffs, review what changed, and reference pitfalls that were already solved. user's convention: `{project}-build-v{major}.{minor}` with dated dev-build parent folders.

### Phase 0a
- **Infinite spiral** — recon can go forever. Set a timebox (e.g., "2 rounds of parallel subagents") and stick to it. Deeper research can be its own project using `pre-project-reconnaissance`.
- **Analysis paralysis** — not every unknown needs deep research. Tier your unknowns: critical path vs nice-to-know.

### Phase 3

- **patch() tool corrupts Python indentation** — the Hermes `patch()` tool's fuzzy matching struggles with indentation-sensitive changes. When editing Python files, if `patch()` produces an `IndentationError` or wrong indentation, do NOT retry with broader context blocks (they compound the damage). Instead, read the full file with `read_file`, construct the corrected complete content, and write it with `write_file`. Repeated patch() attempts on corrupted indentation only make the file worse.
- **Inline verification > temp files** — when the system asks for ad-hoc verification after code edits, use `python -c "..."` or `terminal` one-liners instead of creating `hermes-verify-*.py` temp files. Temp files become "changed paths" that trigger a second verification pass. One-liners leave no trace and require no cleanup.
- **SSE mismatch is the most common** — every OpenAI-compatible client defaults to `stream: true`; if the proxy returns plain JSON instead of SSE chunks, the client silently drops the response (see `systematic-debugging` skill's SSE reference).

#### Subagent File-Writing Verification

**Subagents can silently fail to write files.** Two real-world examples from a single session: subagents tasked to copy+update `task-registry-updated-2.md -> task-registry-updated-3.md` both read the source file, said "now I'll create the file," but never wrote it. No error, no warning — just an empty handshake back to the parent.

**Fix — always verify subagent file output immediately:**

```diff
  response = delegate_task(goal="Create updated-file.md", ...)
+ verify: check if "/path/to/updated-file.md" exists, check size > 0
+ if missing → re-delegate with SMALLER scope (1 file, focused goal)
+ or → write it yourself IF it is a non-code file (see typology below)
```

**Why subagents fail silently:**
- Free-tier models (`minimax_free`, etc.) tend to"agree and stop" instead of executing multi-step workflows — they say "I'll create it" but hit the output token limit or internal time limit before calling `write_file`.
- Aggressive token limits on the subagent's model truncate long generation pipelines.
- The subagent's goal was too broad (5+ bullet points, 3+ files to read before writing).

**Prevention — keep subagent write goals atomic:**
```
❌ BAD: "Read the source, create 3 updated docs, update the installer, compile"
✅ GOOD: "Read source.md, create target.md with these specific changes"
```

### Phase 5
- **Not saving lessons**
- **Not archiving** — if the artifacts are scattered, they're useless. Use the cloud-save skill.
- **Not updating skills** — if the project revealed a reusable pattern and you don't save it as a skill, it's lost.

---

## REMEMBER

```
1. Charter first — scope is your north star
2. Recon before design — assumptions are debt
3. Blueprint → Breakdown → Tasks — top-down, never skip a layer
4. Audit every layer — duck council at two depths
5. Go/No-Go kill switch — decide if it's worth building
6. One component at a time — isolation beats parallelism
7. Validate after each — catch failure when it's cheap
8. Retrospect at the end — compound your learning
9. Orchestrate, never implement — context health is the bottleneck
10. Client mode when appropriate — three feedback loops, mock before real
```
