# USB Drive Invisible in My PC — Reset from EFI System Partition to NTFS

**Date:** 2026-08-06
**Author:** OTG Hermes IT Agent
**Type:** Troubleshooting Guide
**Machine:** TM-MarkTwo (Windows Server 2025)

---

## Diagnosis

### Symptom
A 4 GB USB drive was not visible in My PC. Disk Management showed it as **Disk 1 — 3.73 GB, Healthy (Online)**, but both **"Change Drive Letter and Paths"** and **"Format"** were disabled/greyed out.

### Findings (PowerShell, read-only)
```
Get-Disk      : Disk 1 "USB Driver" — Serial E68919000E71, 4,007,657,472 bytes, GPT, Online
Get-Partition : Partition 1 — Type "System", GptType {c12a7328-f81f-11d2-ba4b-00a0c93ec93b}, no drive letter
```

### Root Cause
The entire 3.73 GB disk was partitioned as **one single EFI System Partition (ESP)** — a leftover from when the stick was written as a bootable rescue device. This single GUID explains every symptom:

| Symptom | Cause |
|---------|-------|
| Not shown in My PC | ESPs get no drive letter by default; Explorer never mounts them |
| Can't change drive letter in Disk Mgmt | Windows protects ESPs — letter assignment is disabled in the GUI |
| Can't format in Disk Mgmt | Disk Management refuses to format an EFI System Partition |

**Identification:** User booted the stick on a test machine — it loaded **Windows PE (Macrium Reflect rescue disk)**. Confirmed no longer needed, so a full reset was authorized.

---

## Fix Applied

### Tool Used
**`diskpart.exe`** (Windows DiskPart), run elevated via PowerShell `Start-Process -Verb RunAs` wrapper.

### Steps
1. **Identified disk** — Confirmed via `Get-Disk` / `Get-Partition` that Disk 1 = USB (Serial `E68919000E71`, 3.73 GB), distinct from system Disk 0
2. **Confirmed content on test machine** — Booted the stick: Macrium Reflect rescue PE; user confirmed it's retired
3. **Re-verified before wipe** — Re-checked Disk 1 identity immediately prior to destructive step
4. **Ran diskpart script** (elevated):
   ```
   select disk 1
   clean
   convert mbr
   create partition primary
   format fs=ntfs quick label=USB
   assign
   ```
   Result: all steps succeeded — "DiskPart successfully cleaned / converted / created / formatted / assigned"
5. **Verified final state**:
   ```
   Get-Disk      : Disk 1, MBR, Online
   Get-Partition : Partition 1 — Type "IFS" (NTFS), Drive Letter F:
   Get-Volume    : F: USB, NTFS, Removable, Healthy, 3.73 GB (3.71 GB free)
   ```

### Recovery Time
Approximately 5 minutes from diagnosis to verified usable drive.

### Pitfall Encountered
First elevation attempt used `Start-Process -Verb RunAs -RedirectStandardOutput` — it returned an empty exit code and log (elevated processes cannot inherit the redirect handles). **Fix:** launched an elevated `powershell.exe` wrapper that runs diskpart and writes its own log file from inside the elevated context. This worked reliably.

---

## Recommendation
- Drive is now a normal **F:\ USB (NTFS)** data stick, visible in My PC
- NTFS chosen per user request; if the stick will also be used with TVs/cameras/phones, **FAT32** is the more compatible alternative (at the cost of the 4 GB file-size limit)
- Label is currently "USB" — can be renamed at any time without data loss
- When a "Healthy" disk in Disk Management refuses drive-letter/format changes, check `GptType` — an EFI System Partition is the usual culprit, not a broken disk
