# VMware VM Crash Recovery Report

**Date:** 2026-07-26
**Author:** OTG Hermes IT Agent
**Type:** Troubleshooting Guide
**Machine:** VM: MilkyWay8-CloudSrv (Windows Server 2025)

---

## Diagnosis

### Symptom
VM failed to boot after a host black-screen crash while the VM was running. VMware Workstation displayed:
```
Cannot open the disk '...MW8-CloudSrv-cl1-000002.vmdk' or one of the snapshot disks it depends on.
Module 'Disk' power on failed.
```

### Root Cause (from vmware.log)
```
DISKLIB-SPARSE: "...MW8-CloudSrv-cl1-000002-s001.vmdk" : failed to open (14): Disk needs repair.
DISKLIB-LINK  : DiskLinkOpen: Failed to open '...MW8-CloudSrv-cl1-000002.vmdk': The specified virtual disk needs repair
```

**Snapshot Chain at time of crash:**
| # | Date | Name | Disk |
|---|------|------|------|
| Snap46 | Jul 27 | "072726- pre hermes update" | `MW8-CloudSrv-cl1.vmdk` (base) |
| Snap47 | Jul 28 | "072826- pre hermes update #2" | `MW8-CloudSrv-cl1-000002.vmdk` 🔴 |

### Cause
When the host machine suffered a sudden power loss (black screen, forced shutdown), the VMware delta disk `MW8-CloudSrv-cl1-000002-s001.vmdk` (Snapshot 47) had its sparse extent header corrupted. The delta disk's metadata — the on-disk index that tells VMware how to read the redo-log — got scrambled during the abrupt I/O termination. The guest OS data itself was likely intact; only the disk's structural metadata was damaged.

---

## Fix Applied

### Tool Used
**`vmware-vdiskmanager.exe`** (VMware Virtual Disk Manager)
Location: `C:\Program Files (x86)\VMware\VMware Workstation\vmware-vdiskmanager.exe`

### Steps
1. **Confirmed backup** — User verified full copy of VM folder on external HDD
2. **Removed stale lock files** — Deleted `.lck` directories from VM folder
3. **Inspected snapshot chain** — Read `.vmsd` to identify current delta disk
4. **Repaired corrupted delta** — Ran:
   ```
   vmware-vdiskmanager.exe -R "C:\Users\MilkyWay\VMs\MW8-CloudSrv\MW8-CloudSrv-cl1-000002.vmdk"
   ```
   Result: **"The virtual disk was corrupted and has been successfully repaired."**
5. **Powered on VM** — Used `vmrun start` to boot the VM
6. **Verified boot** — VMware log confirmed Windows Server 2025 booted successfully (SVGA driver loaded, display active)

### Recovery Time
Approximately 5 minutes from diagnosis to verified boot.

---

## Recommendation
- Take a fresh snapshot immediately
- Consider consolidating snapshots to reduce delta chain depth
- The `-R` flag on `vmware-vdiskmanager` works on sparse multi-extent delta disks despite documentation saying "monolithic flat only"
