# Table Patching Trap — Double-Match Disaster

## What Happens

When using `patch(mode='replace')` to update markdown tables in MEMORY.md, the `old_string` can accidentally match in **two places** — once in the section you're trying to fix, and again in the rows below that contain similar content. This produces:
- **Duplicated rows** (the new content appears twice)
- **Mangled structure** (section headers and table headers get eaten)
- **Truncated rows** (partial rows where only the first few columns survived)

## Real Example (Jul 19, 2026 session)

**Task:** Rotate the RECENT LESSONS table — add a new entry at top, remove 6 oldest entries.

**What was sent:**
```
old_string = the full 10-row table (including the 6 rows to remove)
new_string = only the 2 rows I wanted to keep + the new entry
```

**What happened:** The `old_string` matched the section header + table from two places:
1. The mangled section that needed fixing (correct target)
2. The remaining rows below that were already correct (unintended second match)

Result: new content appeared twice, section headers vanished, truncated `| 2026-07-17 | 🔌 **Hermes-Relay Gateway Conflict**` row appeared.

## The Root Cause

The `patch` tool does UNIQUE matching by default. If `old_string` contains text that appears more than once in the file, patch may match against the wrong occurrence or match against multiple occurrences. Markdown tables with repeated date patterns are especially vulnerable — `| 2026-07-17 |` appears in multiple rows.

## The Fix

### Rule 1: Use `replace_all: false` scope discipline
When replacing a table block, make your `old_string` start with a **unique anchor** (section header with `##`) and end with a **unique terminus** (the line immediately after the table, not part of it).

### Rule 2: Test your old_string for double-match risk
Before calling `patch`, ask: "Does any substring of my old_string appear elsewhere in this file?" For tables, identical date prefixes (`| 2026-07-17 |`) are the #1 culprit.

### Rule 3: Prefer row-by-row edits over block replacement
Instead of replacing an entire 10-row table at once:
- Add a new row by inserting before the first existing row
- Remove old rows one at a time with specific `old_string` that includes enough context
- This isolates each change and prevents cascade failures

### Rule 4: Verify immediately after every table patch
After patching a table section, `read_file` the affected area WITHOUT relying on the diff output alone. Check:
- Section header is intact
- Table header (|---|) is present
- No duplicate rows
- No truncated rows
- Row count matches expectation

## Comparison with read_file Pipe-Convention Trap

| Trap | Root Cause | Fix |
|------|-----------|-----|
| **Pipe-Convention** | Copying line-number `|` as content | Use the content after the `|` separator, not the display format |
| **Table Double-Match** | old_string matching in 2+ places | Anchor with unique headers, prefer row-by-row, verify immediately |