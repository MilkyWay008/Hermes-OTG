---
name: otg-web_extract
description: "OTG web content extraction: Jina Reader first (except X.com), trafilatura fallback (best for X.com), headless browser last resort. Use when asked to read/extract/fetch a URL's content."
version: 2.0.0
author: Ringo/MilkyWay008
platforms: [windows]
metadata:
  hermes:
    tags: [web, extract, jina, trafilatura, otg, url, fetch, read]
    related_skills: [otg-pip, duckduckgo-search]
---

# otg-web_extract — Web Content Extraction for OTG Hermes

**TRIGGER:** User gives a URL and asks to read, extract, fetch, summarize, or look up its content. Also triggers when a task needs page content (e.g. research, verification, data gathering).

**HARD RULE — Extraction Priority (in this order, no exceptions):**

```
Step 1: Jina Reader (r.jina.ai)   ← ALWAYS try first — EXCEPT x.com URLs
Step 2: trafilatura (Python)      ← when Jina fails/blocked; ALSO always used for x.com
Step 3: Headless browser          ← final fallback when both above fail
```

---

## When to use which (the golden rule)

| Site / Situation | Best tool |
|------------------|-----------|
| **X.com / Twitter** | **trafilatura FIRST** (Jina is frequently DDoS-blocked on x.com; trafilatura gets the raw HTML with the post text) |
| **JS-heavy sites** (grok.com, SPA apps, forums, dashboards) | **Jina Reader** (renders JS; trafilatura's static parse only gets the `<title>`) |
| **Normal article / blog / docs page** | Jina Reader (fast, clean markdown) |
| **Jina returns error/blocked/empty** | trafilatura next |
| **trafilatura returns nothing / title-only** | browser last |
| **Login-gated content** | browser only (both Jina + trafilatura fail behind auth) |

**The complementarity rule:** Jina is best for JS-heavy pages; trafilatura is best for X.com and anything Jina can't open — and things trafilatura can't open, Jina usually can. They cover each other's blind spots. Only when BOTH fail do you go to the browser.

---

## Method 1 — Jina Reader (default first choice)

```bash
curl -sL "https://r.jina.ai/https://TARGET_URL"
```

Run via `terminal`. Replace `TARGET_URL` with the full URL.

- Output is clean markdown: `Title:`, `URL Source:`, `Markdown Content:`
- **Free, no API key** (anonymous)
- Strips prompt-injection from scraped content
- **Do NOT retry Jina on YouTube** — always 403 (bot detection). Go straight to browser.
- **X.com** — skip Jina entirely (see Method 2). Jina's x.com block is usually temporary (< 24h on first access), but don't wait for it.
- Rate limits: if 429/451/403, wait a few seconds OR fall through to trafilatura immediately.

**Detecting failure:** Jina returns a JSON error like `{"code":403,"name":"AbuseAlleviationError",...}` or an HTTP error, or an empty/garbage body. If so → go to Method 2.

---

## Method 2 — Trafilatura (Python, bundled in OTG)

Trafilatura is **bundled in the OTG internal venv** — no install needed. Use the internal venv Python:

```
<OTG_ROOT>\data\hermes-agent\venv\Scripts\python.exe
```

Resolve `<OTG_ROOT>`: `dirname "$HERMES_HOME"` (HERMES_HOME ends with a trailing backslash).

### Usage — Method A: execute_code (PRIORITY — preferred)

✅ **`execute_code` works on OTG builds** (fixed via `HERMES_OTG_PYTHON` in launchers + `brotlicffi` in the venv). This is the **cleanest way** — no path resolution needed, runs in the sandbox with the internal venv's Python 3.11:

```python
# execute_code — trafilatura is importable directly
import trafilatura
d = trafilatura.fetch_url('TARGET_URL')
print(trafilatura.extract(d))
```

**Why it's priority:** no shell quoting, no path resolution, output comes back as clean tool result. The sandbox already uses the correct bundled Python 3.11.

**When to fall back to Method B:** if `execute_code` errors with the hermes-usage message (`hermes: error: argument command: invalid choice`) — that means the OTG launcher fix isn't applied on this machine yet (older build, or launchers not updated). Use Method B instead.

---

### Usage — Method B: terminal (FALLBACK — for machines where execute_code is broken)

Use when `execute_code` fails (older OTG builds without the `HERMES_OTG_PYTHON` launcher fix).

**Step 1 — resolve the bundled Python path (portable, never hardcode the drive):**

```bash
OTG_ROOT="$(dirname "$HERMES_HOME")"    # e.g. C:\OTG-Hermes (HERMES_HOME ends with a trailing backslash)
PYBIN="$OTG_ROOT/data/hermes-agent/venv/Scripts/python.exe"
echo "$PYBIN"
```

**Step 2 — extract a URL:**

```bash
"$PYBIN" -c "
import trafilatura
url = 'TARGET_URL'
downloaded = trafilatura.fetch_url(url)
print('Downloaded:', len(downloaded) if downloaded else 0, 'chars')
if downloaded:
    text = trafilatura.extract(downloaded)
    print(text)
"
```

**One-liner form (works from any cwd):**

```bash
"$(dirname "$HERMES_HOME")/data/hermes-agent/venv/Scripts/python.exe" -c "import trafilatura; print(trafilatura.extract(trafilatura.fetch_url('TARGET_URL')))"
```

### Practical tips

- **X.com:** trafilatura works great — the post text is in the raw HTML. This is the FIRST choice for x.com.
- **JS-heavy pages:** trafilatura often returns only the `<title>` (e.g. grok.com gave 71 chars = title only while the page was 468K). If extracted text is suspiciously short or title-only → the page is JS-rendered → use Jina (Method 1) or browser (Method 3).
- **When Jina is blocked:** trafilatura is the immediate fallback.
- **`trafilatura.exe` CLI is a broken trampoline** — ALWAYS use the Python API above, never the .exe.

---

## Method 3 — Headless Browser (final fallback)

If both Jina and trafilatura fail (login-gated, captcha, exotic JS, empty):

```python
browser_navigate(url)   # then read the returned snapshot
browser_snapshot()      # full accessibility tree if needed
```

- Always works for rendered content (it executes JS)
- Captures the accessibility tree — good enough for reading post text, comments, etc.
- Slower than the other two; use only when they fail.

---

## Verify extraction quality

After extracting, sanity-check the result:

- If output is only a title / nav text / "No content" → the real content is JS-rendered → try the OTHER tool (complementarity rule).
- If output contains the substantive content (article body, post text, guide steps) → done.

---

## Known limitations

| Limitation | Workaround |
|------------|-----------|
| YouTube always 403 on Jina | Browser (or youtube-content skill) |
| X.com Jina DDoS block (usually < 24h) | trafilatura (works!) |
| JS-only pages: trafilatura gets title only | Jina Reader (renders JS) |
| Login-gated pages | Browser only |
| Binary files (PDF, images) | Not supported by Jina/trafilatura; use pdf skill or download |

---

## Related

- Search: use `ddgs` (duckduckgo-search skill) — free, keyless, bundled
- Installing Python packages on OTG: `skill_view(name='otg-pip')`
- MCP server work on OTG: `skill_view(name='otg-mcp')`
