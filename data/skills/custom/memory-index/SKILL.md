---
name: memory-index
description: "⚠️ TRIGGER: when managing memory — saving lessons, archiving inline entries, creating/updating reference files, first-time indexing of a flat MEMORY.md, checking profile isolation during writes. HARD RULE: follow tier system — T0 critical rules stay inline, T1 reference files are flat, T1P project files track ongoing builds, T2 lessons use dated frontmatter."
version: 1.0.0
author: Ringo/MilkyWay008
---

# Memory Index System

<table>
<tr>
<td width="32">⚠️</td>
<td><strong>TRIGGER CONDITION:</strong> This skill fires whenever you need to manage persistent memory — first-time indexing of a flat MEMORY.md, saving a new lesson, archiving an old one from the inline "Recent Lessons" table, creating or updating a reference file, writing to MEMORY.md or USER.md, or determining where a piece of information belongs in the tier system.</td>
</tr>
<tr>
<td width="32">🔴</td>
<td><strong>HARD RULE:</strong> Follow the tier system precisely. T0 (inline MEMORY.md + USER.md) = critical safety rules + skills front-of-mind + recent lesson index. T1 (memory-details/reference/) = flat filename, no dates — durable configs and env facts. T1P (memory-details/projects/) = flat filename, no dates — ongoing builds that span days-weeks-months. T2 (memory-details/lessons/) = dated YYYY-MM-DD frontmatter — session-specific lessons. Never mix — a lesson with date information goes to T2, not inline. Project status goes to T1P, not in MEMORY.md.</td>
</tr>
</table>

This skill governs how the tiered memory system works. All memory lives under the Hermes memories directory (typically `<hermes_data_dir>/memories/`).

---

## Architecture

```
memories/
├── MEMORY.md              ← T0: lean index — critical rules inline, links to everything else
├── USER.md                ← T0: user preferences, identity, work style, communication
└── memory-details/
    ├── reference/         ← T1: durable reference files (machine spec, configs, inventory)
    ├── projects/          ← T1P: ongoing build/project files (span days-weeks-months)
    └── lessons/           ← T2: dated lesson archives with frontmatter
```

---

## Memory Root Path Resolution

Your memory root depends on which profile you're running under. Resolve it at runtime:

| Profile Type | Memory Root |
|-------------|-------------|
| **Default profile** | `<HERMES_DATA_DIR>/memories/` |
| **Named profile** | `<HERMES_DATA_DIR>/profiles/<profile_name>/memories/` |

Where `<HERMES_DATA_DIR>` is the Hermes data directory:
- **Linux/macOS:** `~/.hermes/`
- **Windows:** `%LOCALAPPDATA%/hermes/` (typically `C:\Users\<user>\AppData\Local\hermes\`)

> 🔴 **OTG DRIVE-LETTER PORTABILITY RULE (HARD):** On OTG builds (Hermes on a USB
> stick), the drive letter changes per host — sometimes `C:`, sometimes `D:`,
> `I:`, `G:`, etc. **NEVER write absolute paths with a drive letter** in memory
> entries, reference files, lessons, or projects. Use placeholders instead:
> - `<OTG_ROOT>` = `dirname "$HERMES_HOME"` (resolve at runtime)
> - `<HERMES_HOME>` = the Hermes data dir (e.g. `<letter>:\hermes-otg\data\`)
> - `<user-home>`, `<PG-install-dir>`, `<hermes-node-dir>` for machine-specific facts
> - Example: `<OTG_ROOT>/data/memories/MEMORY.md` — NOT `D:\hermes-otg\data\memories\MEMORY.md`
>
> Historical references to a specific old home are acceptable ONLY with an
> explicit "(old home — resolve per-machine)" annotation. When indexing or
> re-indexing MEMORY.md, scan for and flag any `[A-Z]:\` absolute paths in new
> entries — they are portability defects that will go stale on the next USB
> insertion. Launchers use `%SCRIPT_DIR%` (script-relative) and
> `fix-otg-paths.cmd` rewrites pyvenv.cfg/paths on every launch, so the package
> self-heals — memory must follow the same convention.

When constructing file paths for memory operations:
- T0 MEMORY.md is at `{memory_root}MEMORY.md`
- T0 USER.md is at `{memory_root}USER.md`
- T1 reference files go under `{memory_root}memory-details/reference/`
- T1P project files go under `{memory_root}memory-details/projects/`
- T2 lesson files go under `{memory_root}memory-details/lessons/`
- Monthly backups go under `{memory_root}bkup/`

**Pitfall:** Writing to the wrong profile's memory root silently contaminates another profile. Always verify which profile is active before writing memory files.

---

## Tier Definitions

| Tier | Where | Contents | Loaded every turn? |
|------|-------|----------|-------------------|
| **T0 — Critical** | `MEMORY.md` inline + `USER.md` | Safety rules, process rules, corrective feedback, skills front-of-mind, recent lessons index, user identity/preferences | ✅ Always |
| **T1 — Reference** | `memory-details/reference/<topic>.md` | Machine spec, env setup, API configs, tool quirks, inventory lists | 🔍 On demand (index link in MEMORY.md) |
| **T1P — Project** | `memory-details/projects/<project-name>.md` | Ongoing builds/projects spanning days-weeks-months, progress tracking, architecture notes | 🔍 On demand (load when working on that project) |
| **T2 — Lesson** | `memory-details/lessons/YYYY-MM-DD_Title.md` | Session lessons with frontmatter (date, session_id, tags, summary) | 🔍 On demand (search or link in MEMORY.md) |

---

## MEMORY.md Structure Template

This is the exact structure every MEMORY.md should follow. When building from scratch, use these section headers and table schemas exactly:

```markdown
# Memory Index

> ⚡ **Tier system:** Critical rules stay inline. Reference links → `memory-details/reference/`. Lesson archives → `memory-details/lessons/`. Projects → `memory-details/projects/`.
> User profile → `USER.md`.

---

## ⚠️ CRITICAL SAFETY RULES (must fire every session)

### 🔴 Rule Name — HARD RULE
> Optional quote or emphasis.

- Bullet rules here
- More rules

### Another Rule Section
Description of the rule or procedure.

---

## 🧠 SKILLS FRONT-OF-MIND

These are user-built skills that should always be top-of-mind when engaging in tasks:

| Skill | When to use | Trigger phrase |
|---|---|---|
| `skill-name` | ⚠️ TRIGGER: description of when to fire | "trigger phrase the user might say" |

---

## 🔗 REFERENCE (on-demand — click links to read)

| Topic | File |
|-------|------|
| Topic Name | `reference/filename.md` |

---

## 💼 PROJECTS (on-demand — build/ongoing project files)

| Project | File | Status |
|---------|------|--------|
| Project Name | `projects/filename.md` | One-line status |

---

## 📖 RECENT LESSONS

| Date | Lesson | File |
|------|--------|------|
| YYYY-MM-DD | Brief description of lesson learned. | `lessons/YYYY-MM-DD_Filename.md` |

> 📌 **Rotation rule:** Newest lessons go to top. When inline list exceeds 10, oldest inline entry is removed (detail file in `lessons/` is never deleted). Archived lessons still findable via `session_search` or browsing `lessons/` folder.

---

## 🗂 DURABLE FACTS (inline — on-demand pointers)

These were moved from inline MEMORY.md blocks to dedicated reference/lesson files. One-liner pointers remain here for discoverability.

### Configuration & Architecture
- **Fact name** — Short description. → `reference/filename.md`

### User Preferences & Beliefs
- **Preference name** — Description.

### Known Dead Ends
- **Topic** — Status. Reason it's a dead end.
```

---

## First-Time Indexing (Fresh System, No Prior Structure)

**Use when:** You are on a Hermes system that has never had its memory organized. MEMORY.md is a flat file of raw entries with no tier structure. There is no backup to restore from — you are building the system from scratch.

### Step 0: Add SOUL.md Self-Maintenance Instruction

Before doing anything else, add these lines to the agent's SOUL.md (or equivalent persona file):

```
🔴 MEMORY TOOL DISCIPLINE: Before calling `memory()` to save anything, first load `skill_view(name='memory-index')` and classify the content. Is it a durable fact? → T0 inline or T1 reference file. Is it a session lesson? → T2 lesson file with frontmatter. Is it task progress? → Do NOT save to memory — it's not durable. The `memory()` tool stores entries as flat §-blocks that can regenerate and destroy structured MEMORY.md. Use direct file edits to MEMORY.md or tier files instead.

🔴 MEMORY MAINTENANCE: When MEMORY.md exceeds 90% of its size cap (Hermes shows a percentage indicator like `[94% — 47,000/50,000 chars]`), do NOT wait for it to hit 100% and compact — run `skill_view(name='memory-index')` immediately and re-index MEMORY.md into the tiered system. Re-indexing at 90% recovers far more space than compaction and leaves headroom to work. Do NOT let flat entries pile up.
```

This ensures the agent can self-maintain going forward without the user having to remind them.

### Step 1: Create Directory Structure

```bash
mkdir -p "<hermes_memories>/memory-details/reference"
mkdir -p "<hermes_memories>/memory-details/projects"
mkdir -p "<hermes_memories>/memory-details/lessons"
```

On Windows with git-bash/MSYS2, use forward-slash paths:
```bash
mkdir -p "/c/Users/<user>/AppData/Local/hermes/memories/memory-details/reference"
mkdir -p "/c/Users/<user>/AppData/Local/hermes/memories/memory-details/projects"
mkdir -p "/c/Users/<user>/AppData/Local/hermes/memories/memory-details/lessons"
```

On Linux/macOS:
```bash
mkdir -p "$HOME/.local/share/hermes/memories/memory-details/reference"
mkdir -p "$HOME/.local/share/hermes/memories/memory-details/projects"
mkdir -p "$HOME/.local/share/hermes/memories/memory-details/lessons"
```

### Step 2: Backup the Flat MEMORY.md

```bash
cp "<hermes_memories>/MEMORY.md" "<hermes_memories>/MEMORY.md.flat-backup"
```

Keep this as a read-only reference — never modify it.

### Step 3: Read and Classify Every Entry

Read the flat MEMORY.md. For every paragraph, block, or `§`-separated entry, classify it using this decision matrix:

| If the content is... | Then... |
|---------------------|---------|
| **A safety rule / "never do X" / destructive command warning** | T0 inline — add to CRITICAL SAFETY RULES |
| **A process rule (always do X before Y, check Z first)** | T0 inline — add to CRITICAL SAFETY RULES |
| **A user preference or personal detail (language, tone, name, work style)** | T0 — put in `USER.md` |
| **A durable configuration fact (API keys layout, port numbers, tool versions, environment variables)** | T1 `reference/` file — create or update |
| **A tool quirk or platform-specific gotcha (MSYS2 path issues, CRLF, timeout limits)** | T1 `reference/` file |
| **A documented lesson from a specific session (dated, has "I learned" or "we discovered")** | T2 `lessons/` file with frontmatter |
| **An ongoing build or multi-session project with progress tracking** | T1P `projects/` file |
| **A trigger-to-skill mapping ("when user asks X, load Y skill")** | T0 inline — add to SKILLS FRONT-OF-MIND table |
| **A correction the user gave the agent ("you keep doing X wrong")** | T0 inline — add to CRITICAL SAFETY RULES as a HARD RULE |
| **Task progress / completed-work log / "we finished X today"** | ❌ Delete — not durable memory |
| **Doesn't fit any category but has ongoing value** | T1P — use `other-` prefix convention (`projects/other-<topic>.md`) |

**Key heuristic for skills front-of-mind:** When scanning flat entries, look for phrases like "load the X skill", "use the Y skill first", "TRIGGER: whenever Z is mentioned". These are the skills that matter most. The 10-14 most frequently referenced skills go in the front-of-mind table.

### Step 4: Create Tier Files

For each classified entry:

- **T1 Reference files:** Use flat, descriptive filenames without dates: `machine-spec.md`, `api-keys.md`, `tool-quirks.md`. Group related facts into topic files rather than creating one file per fact.
- **T2 Lesson files:** Use dated filenames: `YYYY-MM-DD_Brief-Title.md`. Include frontmatter with `date`, `session_id` (use `unknown` if not available), `tags`, and `summary`.
- **T1P Project files:** Use flat filenames: `<project-name>.md`. If the project is vague or uncategorized, prefix with `other-`.

**T2 Lesson frontmatter format:**
```markdown
---
date: 2026-06-15
session_id: 20260615_120000_000000
tags: [tag1, tag2, tag3]
summary: One-line summary of what was learned
---
```

**T1 Reference file naming convention:**
- `machine-spec.md` — OS, hardware, paths, toolchain versions
- `<service>-config.md` — configuration for a specific service (e.g., `litellm-config.md`)
- `<topic>-quirks.md` — platform-specific gotchas
- `<service>-inventory.md` — lists of accounts, keys, servers

### Step 5: Build the MEMORY.md Skeleton

Using the Structure Template above, build MEMORY.md from scratch:

1. **Copy the template headers** exactly as shown in the Structure Template section
2. **Populate CRITICAL SAFETY RULES** — deduplicate aggressively; the same rule often appears 3-5 times in flat dumps
3. **Populate SKILLS FRONT-OF-MIND** — the 10-14 most-referenced skills from the flat entries, each with trigger phrase
4. **Populate REFERENCE table** — one row per reference file created
5. **Populate PROJECTS table** — one row per project file created
6. **Populate RECENT LESSONS** — 5-10 newest lessons, newest on top
7. **Populate DURABLE FACTS** — one-liner pointers to every reference/lesson/project file

### Step 6: Create USER.md

Extract user-specific content into `USER.md`:

```markdown
# User Profile

## Identity
- **Name/Nickname:** (from flat entries)
- **Language:** (preferred languages)
- **Tone/Work style:** (from corrections and preferences)

## Work Style
- (preferences about backup, testing, delegation, etc.)

## Technical Environment
- (OS, toolchain, key services)

## Preferences
- (specific durable preferences the agent must remember)
```

### Step 7: Verify and Deduplicate

- Re-read the entire MEMORY.md — check for duplicate rules, missing section headers, broken table formatting
- `wc -c MEMORY.md` — a well-indexed MEMORY.md should be under 25KB
- Verify every reference/lesson/project file listed in the tables actually exists on disk

### Step 8: Clean Up

The flat backup (`MEMORY.md.flat-backup`) stays as a read-only reference. Do not delete it — it proves nothing was lost.

---

## What Goes Where

### Memory vs Skills Separation Principle

**Memory is a pointer. Skills are the source of truth.**

- **MEMORY.md / USER.md** — trigger conditions, user preferences, environment facts, and *which skill to load* for a class of task. One-liner pointers only: `TRIGGER: user asks X → use Y-skill`.
- **Skill SKILL.md** — the full workflow, step-by-step instructions, tool calls, pitfalls. Every detail of *how* to do the task lives here.

**Why:** When the workflow changes (new tool, new folder structure, new API), you update the skill once. If the workflow is duplicated in memory, every stale copy needs updating independently — and they'll be forgotten until they break.

**Rule of thumb:** If you find yourself writing a multi-line step-by-step workflow in a memory entry, stop. Put it in the skill, and just reference the skill from memory.

### T0 — Must Stay Inline
- Safety rules (destructive commands, hasty-action, backup-before-edit)
- Process rules (always do X before Y, check Z first)
- User preferences (language, tone, identity, work style — these go in `USER.md`)
- Skills front-of-mind (10-14 key user-built skills)
- Recent lessons (5-10 newest, with links to detail files)
- Cross-cutting rules that would cause harm if missed

### T1 — Reference Files
- **Machine/environment specs** that change slowly and don't need to fire every session
- **Configuration details** (gateway, services, API keys layout, MCP servers)
- **Tool quirks** (platform-specific gotchas, timeout limits, path issues)
- **Inventory lists** (servers, accounts, keys, profiles)
- These use **flat filenames** like `machine-spec.md` — no dates, updated in place

### T2 — Lesson Files
- **Session-specific lessons** — things learned from mistakes, discoveries, hard-won optimizations
- Use **dated frontmatter** schema:
  ```markdown
  ---
  date: 2026-06-15
  session_id: 20260615_120000_000000
  tags: [tag1, tag2, tag3]
  summary: One-line summary of what was learned
  ---
  ```
- Filename convention: `YYYY-MM-DD_Title-Case-With-Hyphens.md`

### T1P — Project Files
- **Ongoing builds or multi-session work** that spans days, weeks, or months
- **Architecture decisions, progress tracking, module breakdowns** — anything too large for a single session
- **Not a substitute for a skill** — the project file tracks *progress and state*, not a reusable procedure. The skill (if one exists) stays in `skills/` and holds the *how-to*.
- Use **flat filenames** like `<project-name>.md` — no dates, updated in place as the project progresses
- MEMORY.md gets a **one-liner pointer** in the Projects section table + a note to load the project file when working on that project
- **When to create a project file:**
  - You start a build, fork, or integration that will take more than one session
  - The user asks you to track progress on a multi-day task
  - A project has its own architecture docs, module breakdowns, or task registry
- **The `other-` prefix convention:** When you encounter memory that has ongoing details and progress but doesn't clearly belong to reference (T1), lessons (T2), or any existing named project — create a file in `projects/` with the `other-` prefix, e.g. `other-unresolved-research-threads.md`. This keeps MEMORY.md clean while giving orphan memories a home. If it later becomes an actual project, rename it to drop the `other-` prefix. If it becomes obsolete, delete the file.
- **When to update a project file:**
  - A module is completed, blocked, or re-scoped
  - Architecture decisions change
  - You're about to end a session and want to save where you left off
  - Save progress updates to the project file, NOT to MEMORY.md inline entries

---

## Lessons Rotation Mechanism

The inline "Recent Lessons" section in MEMORY.md holds the **5-10 newest lessons**.

### Adding a New Lesson
1. Create the detail file in `memory-details/lessons/` with full frontmatter + content
2. Add a one-line entry to the top of the "Recent Lessons" inline table in MEMORY.md
3. If the table now has >10 entries → remove the 10th (oldest) from the inline table
4. The detail file is **never deleted** — it stays in `lessons/` permanently

### Archiving
- When a lesson falls out of the inline table, its detail file remains in `lessons/`
- Archived lessons are still findable via `session_search()` or by browsing the `lessons/` folder
- If a reference is needed from MEMORY.md for an archived lesson, add a link under an "Archived Lessons" section at the bottom of the reference links area

### When to Create a Lesson
Create a lesson file when:
- You discover a **workaround for a bug or quirk** that took effort to find
- The user **corrects your approach** in a way that reveals a pattern
- You **fix a mistake** — document what went wrong and how to prevent recurrence
- A **non-obvious optimization** saves significant time/tool calls
- A **new pattern or architecture** is established

### When to Create/Update a Reference File
Create or update a reference file when:
- A new tool or service is installed and configured
- An existing config changes significantly (new version, new ports, new paths)
- A new environment quirk is discovered

---

## Skills Front-of-Mind Maintenance

### Discovering Skills for the Table (First-Time Indexing)

When building the front-of-mind table from scratch, scan the flat MEMORY.md for:
- **Skill name mentions:** Look for backtick-quoted names like `` `skill-name` ``
- **Trigger phrases:** Lines starting with "TRIGGER:", "whenever", "use the X skill"
- **Frequency:** Skills mentioned 3+ times across the flat dump are candidates
- **HARD RULE markers:** Skills the user explicitly said "always use this first"

### Ongoing Maintenance

The skills front-of-mind table in MEMORY.md should be reviewed periodically:
- When a new important skill is built → add it (up to ~14 max)
- If a skill proves less useful than expected → remove it to keep the list focused
- Each entry should have: skill name, when-to-use description, trigger phrase

---

## MEMORY.md Recovery Procedure (Corruption / Flat-Dump Cleanup)

**Use when:** MEMORY.md has been overwritten, its structure lost, or a careless session appended flat `§` entries instead of using the tier system. This is a recoverable failure mode.

> **Note:** If you are indexing for the very first time (no prior structure, no backup), use the **First-Time Indexing** workflow above instead.

### Detection Signals
- MEMORY.md has no section headers (no `CRITICAL SAFETY RULES`, `SKILLS FRONT-OF-MIND`, `REFERENCE`, etc.)
- Content is a flat list of `§`-separated paragraphs with no structure
- The file is 25KB+ of inline prose with no tables or pointers
- `USER.md` has the same flat `§` structure

### Recovery Workflow

1. **Rename the corrupt current file** to preserve it as a read-only reference:
   ```bash
   cp "<hermes_memories>/MEMORY.md" "<hermes_memories>/MEMORY.md.corrupt-$(date +%Y%m%d)"
   ```

2. **Find the nearest known-good backup.** Check these locations in order:
   - `MEMORY.md.bak` in the memories directory
   - `bkup/MEMORY.md.bak-*` in the memories directory (named `MEMORY.md.bak-YYYYMMDD`)
   - Any `.bak` files with recent enough creation dates

3. **Restore from backup:**
   ```bash
   cp "<hermes_memories>/bkup/MEMORY.md.bak-YYYYMMDD" "<hermes_memories>/MEMORY.md"
   ```

4. **Read the corrupt file** — do NOT modify it. Use it as the source of entries that need to be grafted in.

5. **Categorize every unique entry** from the corrupt file against the tier system using the classification matrix in the First-Time Indexing section above.

6. **Create/update the tier files** for each category:
   - Update existing reference files that are stale
   - Create new reference files for uncovered topics
   - Create T2 lessons for dated findings
   - Create/update T1P project files for ongoing builds

7. **Update MEMORY.md** with the recovered content:
   - Add new entries to the **RECENT LESSONS** table (newest on top, rotation to max 10)
   - Update **DURABLE FACTS** pointers if applicable

8. **Deduplicate aggressively.** The corrupt file almost certainly contains duplicate entries — the same fact may appear 3-5 times because multiple sessions appended it independently.

### Prevention
- If MEMORY.md starts accumulating flat entries at the bottom, stop and file them into the proper tier system immediately.
- When Hermes reports MEMORY.md has exceeded 90% of its size cap (e.g., `[94%]`), run `memory-index` skill to re-index and recover space — do NOT wait for 100% and rely on compaction.
- Never append flat entries to MEMORY.md. The tier system exists to keep it lean.
- **The SOUL.md instruction (Step 0 of First-Time Indexing) is the long-term guardrail.**

---

## Monthly Backup Rule

At the beginning of each new calendar month, when touching MEMORY.md with this skill:

1. **Check if a backup for the current month already exists:**
   ```bash
   ls <hermes_memories>/bkup/MEMORY.md.bak-$(date +%Y%m)* 2>/dev/null
   ```
2. **If no backup exists for this month, create one:**
   ```bash
   mkdir -p <hermes_memories>/bkup
   cp <hermes_memories>/MEMORY.md <hermes_memories>/bkup/MEMORY.md.bak-$(date +%Y%m%d)
   ```
3. **Cap at 12 monthly backups** — if `bkup/` has more than 12 `MEMORY.md.bak-*` files, remove the oldest.

This ensures you always have a known-good restore point no older than one calendar month. The `bkup/` directory is created by this skill alongside the `memory-details/` tree.

---

## Pitfalls

### This Skill Creates Subdirectories — Always Use Recursive Search

This skill creates a directory tree under the memories folder: `memory-details/` (with `reference/`, `projects/`, `lessons/`) and `bkup/` (monthly backups). When searching for memory-related files, always use **recursive search** (`**/pattern`) — flat searches in the memories directory will miss everything in subdirectories.

**Example:** Looking for a reference file about API configuration:
```
# Wrong — misses files in memory-details/reference/
search_files(pattern='api', path='<hermes_memories>/')

# Right — recursive
search_files(pattern='**/api*', path='<hermes_memories>/')
```

### Profile Isolation (Critical)

When the session runs under one Hermes profile but operates on files in another, cross-contamination happens silently:

| Tool | Operates in which profile? |
|------|---------------------------|
| `skill_manage`, `skill_view`, `skills_list` | **Session's active profile** |
| `memory()`, `session_search` | **Session's active profile** |
| `write_file` with **absolute** path | **Whatever path you give** — can silently cross profiles |
| `terminal` with **absolute** path | **Whatever path you give** — can silently cross profiles |

**Example:** Writing to the default profile's `memories/MEMORY.md` while running under a different profile contaminates the **default** profile's memory index without affecting the active profile. The skill you just created and the backup you just made land in *different* profiles from the file you edited.

**Before any memory/skill write operations, check which profile is active:**
- Check the Hermes active_profile file or environment variable
- Use `session_search` to confirm which profile's data you're seeing

**Recovery pattern:** If a skill or memory file seems "missing", it might be in another profile's namespace. Check `profiles/<name>/skills/` and `profiles/<name>/memories/`.

**Cross-Profile Memory Audit:** When another profile has a large, pre-tier-system MEMORY.md with content that may overlap your own, use the classification matrix in the First-Time Indexing section above to classify, extract unique content, and clean up duplicates.

### read_file Pipe-Convention Trap (New Agent Pitfall)

When editing MEMORY.md with `patch`, the `read_file` display format causes a specific failure mode. See `references/read-file-pipe-convention.md` for the detailed pattern.

The short version: `read_file` output shows `70| | content` — the `70|` is a **line-number separator**, not part of the file. The actual content starts AFTER that `|`. When you copy the visible text into `patch`, the leading pipe count will be wrong, and every row you edit will gain an extra `|` at the start. If you see a `|||` prefix on your table rows instead of `|`, this is why.

### MSYS2 Path Mangling in write_file (Windows)

MSYS2-style `/c/Users/...` paths work correctly in `terminal()` (which runs through git-bash) but break in `write_file()`. The tool treats `/c/` as a literal relative directory name under the workspace root, producing `C:\c\...` orphan directories.

**Rule:** `terminal` → `/c/Users/...` is fine. `write_file` → must use `C:\Users\...` (absolute Windows path). Never mix the two.

### Table Patching Trap — Double-Match Disaster

When using `patch(mode='replace')` to update markdown tables in MEMORY.md, the `old_string` can accidentally match in **two places** because markdown table rows with identical date prefixes look similar to the matcher. This produces duplicated rows, mangled structure, eaten section headers, and truncated table entries. See `references/table-patching-trap.md` for the full pattern, root cause, and fix rules.

**Quick rules:**
1. Anchor `old_string` with a unique section header (`##`) at start + a unique line after the table at end
2. Prefer row-by-row edits over whole-table block replacement
3. Verify with `read_file` after EVERY table patch — don't trust the diff alone

---

## Loading This Skill

This skill is loaded automatically via MEMORY.md injection on every turn. When you need to apply the rotation rules (adding a new lesson, archiving an old one), load this skill explicitly:

```
skill_view(name='memory-index')
```
