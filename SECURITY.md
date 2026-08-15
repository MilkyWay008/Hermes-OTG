# Security Policy

## Supported Versions

| Version | Supported |
|---------|-----------|
| v1.0.1 [H-v0.19.0] | ✅ Current release |
| v1.0.0 | ❌ EOL (superseded) |

Security fixes land in the latest release only — always run the newest version.

## Reporting a Vulnerability

If you find a security issue in Hermes-OTG (the bundled components, the launcher, or the packaging), please report it privately rather than opening a public issue:

- **Email:** sky-2k@proton.me
- **Response window:** within 48 hours, with a status update even if the fix takes longer
- **What to include:**
  - Hermes-OTG version + exact file hash (SHA-256) of the artifact you tested
  - Steps to reproduce (concise)
  - Impact assessment, if you have one (what an attacker could do)

Do not test against machines you do not own. Do not publish exploit details until a fix ships.

## Supply Chain Disclosure

Hermes-OTG is a **portable bundle** — it ships third-party executables so it can run with zero install on the host. That is its purpose, and it means the supply chain deserves explicit documentation.

### What's inside

| Component | Upstream source | Role |
|-----------|----------------|------|
| **Hermes Agent** (Python runtime) | NousResearch/hermes-agent (official) | The agent itself |
| **CPython 3.12** | python.org (official) | Embedded Python interpreter |
| **PortableGit** | git-scm.com (official) | Git operations inside the agent |
| **Sysinternals Suite** (~31 tools) | learn.microsoft.com/sysinternals (Microsoft official) | Diagnostic / rescue tools (procmon, autoruns, etc.) |
| **Python packages** (FastMCP, FastAPI, etc.) | PyPI (official registry) | Agent libraries |

### Verification

- **SHA256SUMS:** every release ships with a `SHA256SUMS` file listing the hash of the release archive (and, where practical, per-component hashes)
- **Verify before use:** `sha256sum -c SHA256SUMS` on the downloaded artifact — if the hash does not match, do not run it and report it (see above)
- **Pinned versions:** all bundled components are pinned to exact versions at build time (no floating/`latest` dependencies); the version manifest is documented in `PACKAGE-STRUCTURE.md`
- **No code execution at build from unverified sources:** components are fetched only from the official upstreams listed above

### Known trust boundaries

- The free bundled NVIDIA API key is for out-of-the-box testing only (rate-limited ~40 req/min) — **not for production use**. Bring your own keys for real work (see README).
- Because OTG is a self-contained bundle, **you are trusting**: (a) the official upstreams above, (b) the Hermes-OTG release signing/hashes, and (c) whatever host you plug the stick into. On a compromised host, no portable tool is a security boundary — OTG is a *rescue* tool, not a sandbox.

## Responsible Disclosure History

- 2026-08 — Initial release (v1.0.0) and v1.0.1. No reported vulnerabilities to date.
