---
name: vmware-vm-crash-recovery
description: Recover a VMware Workstation VM that won't boot after a host crash (black screen, forced shutdown). Fixes corrupted snapshot delta VMDK files using vmware-vdiskmanager -R.
category: software-development
---

# VMware VM Crash Recovery (Host Power Loss)

Use when a VMware Workstation VM fails to boot after the host machine black-screened or was force-shut-down while the VM was running, with errors like:
- "The specified virtual disk needs repair"
- "Cannot open the disk ... or one of the snapshot disks it depends on"
- "Module 'Disk' power on failed"

## Prerequisites
- VMware Workstation installed (vmware-vdiskmanager.exe at `C:\Program Files (x86)\VMware\VMware Workstation\`)
- Full backup of the VM folder exists (CONFIRM before acting)
- Administrator access on the host

## Step-by-Step

### 1. Confirm backup exists
Ask the user. Do NOT proceed without confirmed backup.

### 2. Remove stale lock files
Delete all `.lck` directories in the VM folder.

### 3. Read the VMware log to find the exact error
Tail the latest `vmware.log`. Look for lines: `DISKLIB-SPARSE`, `DISKLIB-LINK`, `Disk needs repair`

### 4. Inspect the .vmsd file to understand the snapshot chain
Read `VMname.vmsd` — verify which delta disk (000001, 000002, etc.) is the current/corrupted one.

### 5. Repair with vmware-vdiskmanager -R
Run on the **specific corrupted delta disk**:
```
& 'C:\Program Files (x86)\VMware\VMware Workstation\vmware-vdiskmanager.exe' -R "path\to\VM\disk-00000X.vmdk"
```

### 6. Power on and verify
```
& 'C:\Program Files (x86)\VMware\VMware Workstation\vmrun.exe' -T ws start "path\to\VM\VM.vmx"
```
Check the log for: "Windows Boot Manager", "Firmware has transitioned to runtime"

### 7. Advise user
- Take a fresh snapshot after boot
- Consider snapshot consolidation after verification

## Pitfalls
- On Windows with git-bash/MSYS2, use BACKSLASHES in PowerShell paths, not forward slashes — bash expands /c/ paths and breaks quoting
- -R works on twoGbMaxExtentSparse delta disks despite docs saying "monolithic flat only"
- The corrupted disk is always the latest delta (00000X), never the base
