# Common Code Audit Patterns

> A quick-reference pattern bank for code reviews and system audits. Use during the Review Gate (Phase 2) and Integration Validation (Phase 4) of the complex project workflow. When reviewing code or system output and something looks suspicious, scan this table for the matching pattern class.

## How to use

1. Note the **symptom** or suspicious code in the diff or system output
2. Find the matching pattern class below
3. Check the "What to look for" column for grep/searches to confirm
4. Apply the fix pattern
5. Verify with the listed check

---

## Vulnerability & Pattern Reference

| Category | What to look for (grep/searches) | Fix pattern | Verify with |
|---|---|---|---|
| **Hardcoded secrets** | `api_key\|password\|secret\|token\|credentials` in source, configs, or committed files | Move to `.env` + `python-dotenv`; create `.env.example`; add to `.gitignore` | Check `.env` not in git diff |
| **SQL injection** | `execute(f"` / `text(f"` / `cursor.execute(.*+` in Python; string interpolation in SQL | Parameterized queries (`:param` / `?` placeholders) or ORM methods | Run existing tests; manually trigger affected endpoint |
| **Missing input validation** | Handler/endpoint functions without type/length/format checks on inputs | Validation guards: type checks, length limits, regex whitelists, pydantic models | Send malformed input; verify graceful rejection |
| **Missing auth/authorization** | Endpoints without auth decorators/interceptors; hardcoded key as sole auth | Auth middleware/interceptor for token validation; OWASP-recommended patterns | Hit endpoint without credentials; verify 401/403 |
| **Missing error handling** | Try/except density low vs handler count; no status code mapping | Add try/except with proper status codes; log error, return safe message | Trigger error condition; verify graceful response |
| **Insecure data storage** | `password\|pwd\|secret\|token` in model/schema files storing plaintext | `bcrypt` / `passlib.hash.bcrypt`; never store reversible hashes | Query DB directly; verify stored values are hashed |
| **Rate limiting missing** | No `ratelimit\|rate_limit\|throttle\|limiter` in middleware/handler files | Decorator-based rate limiting (slowapi, token-bucket middleware) | Hit endpoint 100x in 1s; verify throttling |
| **N+1 queries (ORM)** | ORM loops: `for item in parent.children:` with DB queries inside the loop | Eager loading: `joinedload()`, `selectinload()` in SQLAlchemy | Compare SQL query count before/after |
| **Inefficient ORM** | `.all()` / `.fetchall()` without `.limit()` or filter preceding it | Add `.limit()`, `.offset()`, specific `.filter()` / `.where()` clauses | Check only needed rows returned |
| **Missing CSRF** | State-changing endpoints (POST/PUT/DELETE) on web app without CSRF tokens | CSRF middleware or token generation for session-based auth | Send cross-origin POST; verify blocked |
| **Open redirect** | `redirect\|next\|return_url\|redirect_url` params without destination validation | Whitelist allowed redirect destinations | Pass external URL as redirect param; verify blocked |
| **Insecure deserialization** | `pickle.loads()`, `yaml.load()`, `eval()` on untrusted data | `yaml.safe_load()`, JSON parser, or validate before deserializing | Send malicious payload; verify no execution |
| **Missing CORS config** | CORS absent, or `allow_origins: *` in production | Set specific allowed origins; never `*` in production | Check browser console for CORS errors |
| **Logging sensitive data** | `logging\|logger.\|print()` near password/token/PII handling | Redaction filter; log `****` instead of actual values | Check log output after sensitive operation |
| **Race conditions** | Shared file/DB writes without locks or transactions; non-atomic check-then-act | DB transactions, file locks, async-safe patterns | Simulate concurrent requests; verify consistency |
| **Unvalidated file uploads** | `upload\|file\|multipart` in handler files without type/size validation | Validate file type (magic bytes), size limit, sanitize filename | Upload executable; verify rejection |
| **Synchronous blocking in async** | `requests.get\|time.sleep\|.result()` in async functions | Async DB driver (asyncpg), `asyncio.sleep()`, proper `await` | Check server doesn't freeze during calls |
| **Missing retry logic** | External API/service calls without retry wrappers | Exponential backoff retry (tenacity, backoff libraries) | Simulate transient failure; verify retry works |
| **Missing timeouts** | HTTP/DB calls without timeout parameter | `timeout=30` in httpx/requests; DB connection timeouts | Verify hanging request doesn't block server |
| **Resource leak** | `open()` without `with`, DB sessions without `with` | Context managers (`with open(...)`, `with Session()`) | Check file handles / connections don't grow unbounded |
