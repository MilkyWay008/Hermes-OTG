# Path-Stale Registries & Missing Build Artifacts

Two failure modes discovered during a real time-pressure task fix session (2026-07-20).

---

## 1. Task Registry Written Before Clone — Total Path Mismatch

### What happened
The task registry (`task-registry-v1.md`) was generated from a bugs-report that was written BEFORE the repo was cloned. The author guessed the directory structure: `packages/api/app/`. But the actual codebase uses `apps/api/chirp_api/`. Every file path in the registry was wrong.

### Symptoms in Phase 5 (Fix Session)
- Every `read_file` returns "File not found"
- `search_files` finds nothing at registry paths
- All three P0 bugs appear as false positives because the files don't exist at the expected paths
- Fix session wastes time re-investigating bugs that "don't exist"

### Prevention
- **Phase 0 MUST clone the repo before Phase 1 analysis begins.** The skill flow already enforces this (`git clone` is step 1), but real-world time pressure led to analysis happening before clone.
- If a registry already exists from a prior session, **Phase 5 must verify 3+ random file paths** from the registry against the actual repo with `ls` or `find` before executing any fixes.

### Recovery
```bash
# Find where files actually live
find repo -name "admin_handler.py" -type f

# Cross-reference: the registry says packages/api/app/routes/admin.py
# but find returns apps/api/chirp_api/handlers/admin_handler.py
# Now you know the registry is path-stale — re-map ALL paths
```

### The actual fix
Instead of fixing registry bugs (none existed), the real issue was found by checking the running app: `localhost:3002` returned a 500 with the error message revealing the true problem.

---

## 2. Missing Generated Build Artifacts (Gitignored Files)

### What happened
After a fresh `git clone`, the `packages/proto/generated/` directory contained only `.gitkeep`. The proto TypeScript stubs (`admin.ts`, `auth.ts`, etc.) were never generated. The dev server (Vite/TanStack Start) returned HTTP 500:
```
Failed to load url ../generated/admin (resolved id: ../generated/admin) 
in packages/proto/src/index.ts. Does the file exist?
```

### Root cause
Generated files are gitignored by design. The `package.json` had a `proto:generate` script but it was never run.

### Fix
```bash
cd repo/packages/proto
# The protoc binary and protoc-gen-ts plugin are in local node_modules/.bin/
PATH="./node_modules/.bin:$PATH" ./node_modules/.bin/protoc \
  --ts_out ./generated \
  --proto_path ./protos \
  ./protos/*.proto
```

### Post-generation issue: dev server cache invalidation
After generating the files, Vite's dev server module graph held a stale "file not found" cache. Even though files now existed on disk, the SSR continued returning the same 500 error. HMR file touches did not trigger invalidation. **The dev server needed a full restart** to pick up the newly generated files.

### Checklist when debugging "file not found" errors on fresh clones
1. Check if the directory has only `.gitkeep` → build artifacts never generated
2. Look for `package.json` scripts: `"proto:generate"`, `"build"`, `"generate"`
3. Run the generation script
4. Verify files exist on disk with `ls -la`
5. **Restart the dev server** — HMR/cache won't pick up newly created directories
6. Verify with `curl` before declaring fixed
