# WSL Not Starting After Windows Update — Recovery Guide

**Date:** 2026-06-29
**Author:** OTG Hermes IT Agent
**Type:** Troubleshooting Guide
**Machine:** WSL

---

## Quick Summary

If WSL stops working after a Windows Update, it's almost certainly because the update disabled required Windows features and deleted the WSL2 kernel. **The distro's data is intact** — only the infrastructure around it is broken.

**Fix time:** ~20 minutes. **Data risk:** None (if you follow these steps).

---

## Symptoms

Running `wsl` in PowerShell gives:

```
Catastrophic failure
Error code: Wsl/Service/E_UNEXPECTED
```

Or the distro shows as "Stopped" in `wsl -l -v` but won't start.

---

## Step-by-Step Fix

### Step 1: Check what's broken (read-only)

Open **PowerShell as Administrator** and run:

```powershell
# Check if WSL feature is enabled
dism /online /get-featureinfo /featurename:Microsoft-Windows-Subsystem-Linux | findstr State

# Check if HypervisorPlatform is enabled
dism /online /get-featureinfo /featurename:HypervisorPlatform | findstr State

# Check if WSL kernel exists
dir C:\Windows\System32\lxss\tools

# Check WSL version and distro status
wsl --version
wsl -l -v
```

**What to look for:**
- Features showing **"State: Disabled"** → needs fixing
- `tools` folder missing or only containing `bsdtar` (no `kernel` file) → kernel was deleted
- Distro showing "Stopped" is normal — the fix will get it running

### Step 2: Re-enable the disabled features

```powershell
dism /online /enable-feature /featurename:Microsoft-Windows-Subsystem-Linux /all /norestart
dism /online /enable-feature /featurename:HypervisorPlatform /all /norestart
```

### Step 3: Reboot

```powershell
shutdown /r /t 30 /c "Rebooting to enable WSL features"
```

### Step 4: Restore the WSL kernel

After reboot, the features are enabled but the kernel might still be missing. Fix it with:

```powershell
wsl --update
```

This downloads and installs the latest WSL version with a fresh kernel. The update is safe — it doesn't touch your distro data.

### Step 5: Verify kernel is back

```powershell
dir C:\Windows\System32\lxss\tools
```

You should now see a `kernel` file (about 16 MB) alongside `bsdtar`.

### Step 6: Test WSL

```powershell
wsl -d Ubuntu echo "WSL is alive"
```

If this works, your distro is fully functional.

### Bonus: If WSL still doesn't work

In rare cases, the update also disabled the full Hyper-V role. Check:

```powershell
dism /online /get-featureinfo /featurename:Microsoft-Hyper-V | findstr State
```

If **Disabled**, enable it:

```powershell
dism /online /enable-feature /featurename:Microsoft-Hyper-V /all /norestart
```

Then reboot again. This is needed if `wsl --update` upgraded to WSL 2.7.x or later.

---

## Why This Happens

Windows cumulative updates can reset optional feature states during installation:

1. The update **disables** `Microsoft-Windows-Subsystem-Linux` and `HypervisorPlatform`
2. Disabling these **deletes** the WSL2 kernel file from `C:\Windows\System32\lxss\tools\`
3. WSL tries to start but finds no kernel → `E_UNEXPECTED`

This is **not** intentional removal — it's a side effect of how the servicing stack processes component state. The distro data is never touched.

---

## Prevention

After any Windows Update, run:

```powershell
dism /online /get-featureinfo /featurename:Microsoft-Windows-Subsystem-Linux | findstr State
dism /online /get-featureinfo /featurename:HypervisorPlatform | findstr State
dir C:\Windows\System32\lxss\tools\kernel 2>&1
```

If anything's missing, the fix above takes 20 minutes.

---

## What NOT to Do

- **Do NOT run `wsl --unregister <distro>`** — this deletes the entire distro filesystem (all your data)
- **Do NOT reinstall WSL from scratch** — your distro data is intact, only the kernel needs restoring
- **Do NOT delete or modify the VHDX file** — it's an ext4 filesystem, Windows can't read it natively

---

## File Locations Reference

| Component | Path |
|---|---|
| WSL feature state | `dism /online /get-featureinfo /featurename:Microsoft-Windows-Subsystem-Linux` |
| WSL2 kernel | `C:\Windows\System32\lxss\tools\kernel` |
| WSL install location | `C:\Program Files\WSL\` |
| Distro VHDX | `%LOCALAPPDATA%\wsl\{<uuid>}\ext4.vhdx` |
| Distro registration | `HKCU\Software\Microsoft\Windows\CurrentVersion\Lxss\{<guid>}` |