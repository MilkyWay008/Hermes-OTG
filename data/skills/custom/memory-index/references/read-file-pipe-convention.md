# read_file Pipe Convention Pitfall

## The Problem

Hermes' `read_file` displays content as `LINE_NUM|CONTENT`. When the file content starts with `|` (e.g., markdown table rows like `| Skill | When |`), the read_file output looks like:

```
70| | Skill | When to use | Trigger phrase |
```

The `70|` is the line-number prefix from read_file — NOT part of the file. The actual file content after `70|` is `| Skill | When to use | Trigger phrase |` (single leading pipe).

## How the Trap Works

When you copy text from read_file output to use as `old_string` in `patch`, you see the display as:

```
70| | Skill | When to use | Trigger phrase |
```

You copy the visible content starting from `| Skill` — getting `| Skill | When to use | Trigger phrase |`. This is correct for the old_string because the actual file starts with `|`.

But when you see:

```
70|| `discovery-proxy` | Before probing...
```

It's `70|` (line number) + `| ` + `discovery-proxy`... So the actual file content starts with `| ` (single pipe). If you write `|| ` in your patch old_string/new_string, you add an extra leading pipe.

## The Pattern

| What you see in read_file | What the actual file contains | 
|---------------------------|------------------------------|
| `70|` + `header text` | `header text` |
| `70|` + `| row content` | `| row content` (starts with pipe) |
| `70|` + `| extra pipe` | `| extra pipe` (starts with one pipe) |

## Safe Approach: How to Avoid the Trap

1. **Never trust the visual alignment.** The `N|` prefix in read_file is NOT a pipe character in the file — it's a line-number separator.

2. **When patching markdown tables:** Use `read_file` with the exact line, then copy the content AFTER the `N|` prefix. What you see after the `|` separator IS the raw file content.

3. **Test:** If a patch fails with "Could not find a match" on a table line, the leading pipe count is likely wrong. Add or remove one leading `|` and retry.

4. **Escape-drift detector:** The patch tool's "escape-drift detected" error with `'\\"` sequences is a symptom of this same pipe confusion — the tool serialized your quotes with backslashes because the match context was wrong.

## Example

**To patch line 70 of a table** that read_file shows as:
```
70| | `discovery-proxy` | Before probing files | "I don't know" |
```

The actual file content starting after `70|` is:
```
| `discovery-proxy` | Before probing files | "I don't know" |
```

So `old_string` should be: `| `discovery-proxy` | Before probing files | "I don't know" |`
(One leading pipe, not two, not zero.)
