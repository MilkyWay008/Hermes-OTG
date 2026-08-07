# Session CWD lives in state.db — not just the terminal

## Symptom

The Hermes desktop app offers to "commit" changes in an UNRELATED git repo, or
the file browser shows a folder the user never set. Root cause: the agent ran
`cd <some-git-repo>` in the terminal — terminal state persists across calls AND
the session's recorded working directory (which the desktop app reads for its
file/git context) got updated to that folder. Host rescues are the classic
trigger: the agent `cd`s into the host's `hermes-agent` repo and the desktop
suddenly offers commit for the HOST repo.

## There are TWO CWDs, in TWO stores

- **Terminal shell cwd** — fixed with `cd` (or per-command `workdir`).
- **Session record cwd** — `sessions.cwd` (+ `git_branch`, `git_repo_root`) in
  `<HERMES_HOME>/state.db`. **The desktop app reads THIS one.** If it points at
  a git repo, the desktop offers commit/status for that repo.

## Fix (backup first — house rule; WAL-safe backup API)

```python
import sqlite3, os, datetime
db = r"<HERMES_HOME>\state.db"
conn = sqlite3.connect(db, timeout=15)

# consistent snapshot even while Hermes is live (WAL):
os.makedirs(r"<HERMES_HOME>\backups", exist_ok=True)
bak = os.path.join(r"<HERMES_HOME>\backups",
                   f"state.db.bak-{datetime.datetime.now():%Y%m%d-%H%M}")
dst = sqlite3.connect(bak)
with dst:
    conn.backup(dst)
dst.close()

conn.execute(
    "UPDATE sessions SET cwd=?, git_branch=NULL, git_repo_root=NULL WHERE id=?",
    (r"<desired-absolute-path>", "<session-id>"))
conn.commit()
conn.close()
```

- Use Windows backslash paths — matches the convention seen across existing session rows.
- `git_branch`/`git_repo_root` NULLed so the desktop no longer sees a repo at the session cwd.
- Only the `sessions` table has cwd columns (verified: no other table does).

## Pitfalls

- The running backend may cache the old value — if the desktop still shows the
  wrong folder, switch sessions away/back or restart the desktop app; the DB
  value wins on next read.
- Use the sqlite3 backup API, NOT a raw file copy, when `state.db-wal`/`-shm`
  exist (live database).
- After any session where the agent `cd`'d into a git repo, check both CWDs
  before handing the session back to the user.
