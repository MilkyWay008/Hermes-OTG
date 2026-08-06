# memory-index — Tiered Memory System for Hermes Agent

**Author:** Ringo/MilkyWay008
**Version:** 1.0.0
**Category:** software-development

---

## The Problem

Hermes Agent ships with a simple flat memory system: `MEMORY.md` grows unboundedly as every session appends new entries. Over time this creates a 40-50KB blob of unstructured prose — a mix of safety rules, config facts, project updates, session lessons, and user preferences all jumbled together. Every turn injects this entire blob into context, wasting tokens on stale task-progress entries while burying critical safety rules in noise.

The result: agents forget their most important rules because they're drowned in 30KB of flat text. Sessions become less reliable. Corrections get lost. Context windows fill with yesterday's task logs.

## The Solution

**memory-index** replaces the flat dump with a **4-tier memory architecture:**

| Tier | Location | What lives there | Loaded |
|------|----------|-----------------|--------|
| **T0 — Critical** | `MEMORY.md` inline + `USER.md` | Safety rules, skills front-of-mind, recent lesson index, user identity | Every turn |
| **T1 — Reference** | `memory-details/reference/` | Durable configs, env specs, API keys layout, tool quirks | On demand |
| **T1P — Project** | `memory-details/projects/` | Ongoing builds, multi-session project tracking | On demand |
| **T2 — Lesson** | `memory-details/lessons/` | Session-specific lessons with dated frontmatter | On demand |

**MEMORY.md becomes a lean index** — 15-22KB of pointers to detail files, not a 50KB dump. Critical rules fire every session. Everything else loads on demand via `read_file`. Lessons auto-rotate: newest 5-10 inline, older ones archived to disk (never deleted, always searchable).

## What This Skill Does

1. **First-Time Indexing** — Takes a flat, never-organized MEMORY.md and builds the entire tiered structure from scratch: creates directories, classifies every entry using a decision matrix, builds reference/lesson/project files, and populates a clean MEMORY.md skeleton.

2. **Ongoing Maintenance** — When new lessons are learned, file them into the proper tier immediately instead of appending flat entries. Rotate the inline lessons table. Update reference files when configs change.

3. **Corruption Recovery** — When MEMORY.md loses its structure (overwritten, flattened by a careless session), restore from backup and graft in any new entries from the damaged version.

4. **Self-Maintenance** — On first run, adds a SOUL.md instruction so the agent proactively re-indexes when MEMORY.md exceeds 20KB, without needing the user to remind them.

## Quick Start

1. Install this skill into your Hermes skills directory
2. If your MEMORY.md is already flat/bloated, just say: **"use memory-index skill to index my MEMORY.md"**
3. The agent will:
   - Create the `memory-details/` directory tree
   - Read and classify every entry in your flat MEMORY.md
   - Build reference, lesson, and project files
   - Populate a clean, structured MEMORY.md
   - Add the SOUL.md self-maintenance instruction

## Files

```
memory-index/
├── SKILL.md                                    ← Main skill: tier system, templates, workflows
├── README.md                                   ← This file
└── references/
    ├── read-file-pipe-convention.md            ← Avoiding the pipe-character trap in patch()
    └── table-patching-trap.md                  ← Avoiding double-match disasters in table edits
```

## Design Philosophy

- **Memory is a pointer. Skills are the source of truth.** MEMORY.md says *what* to load; skills say *how* to do it. No duplicating workflow instructions in memory.
- **T0 is sacred.** If a rule prevents data loss or corrects a recurring mistake, it stays inline and fires every session. No exceptions.
- **Rotate, don't delete.** Lessons rotate out of the inline table but their detail files live forever in `lessons/`. Nothing is lost — just indexed.
- **Self-maintaining.** The SOUL.md instruction makes the agent responsible for its own memory hygiene. No user nagging needed.
