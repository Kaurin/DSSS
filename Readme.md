# Dark Souls Save Scummer

## Disclaimer
**No warranty whatsoever.** I know next-to-nothing about powershell. Use this at your own risk.

You can potentially get more souls / get better without this script, and just play the game normally. I wrote it mostly as an exercise in powershell / registry.

## Prerequisites
* Disable Steam Cloud Sync (google it)
* You need to set `Set-ExecutionPolicy Unrestricted` for powershell scripts to work. **This is a potential hazard to your PC.**

## Usage

#### "Dark Souls Save Scummer" script (dsss.ps1)
* Right click -> Open in powershell.
* You should see the powershell window. Keep it Open
* CTRL+C a few times once done to close the window, or click the "X" in the corner

#### Optional installation and usage of the "Dark Souls Backup Recovery" script (dsbr.ps1)

Install:
* To install the DSBR, just right click -> Open in powershell

Normal usage (if installed as explained above)
* **ENSURE THAT DARK SOULS IS NOT RUNNING**
* Right-click any .dsbak file, and you should see an option to recover it

## How it works

#### Dark Souls Save Scummer:
It works by creating an background "event listener" for whenever the Dark Souls save file changes.
After the save file changes (finishes changing), this script creates a timestamped backup in the same directory.

#### Dark Souls Backup Recovery
If ran as-is, it will install the "right-click" menu to support restoring .dsbak files.

In normal operation (via the right-click menu), it will first make a backup of the current save, then replace the right-clicked backup to the savefile

## Restrictions
It only creates 1 backup per minute because of two main reasons:
* Dark Souls would sometimes autosave (change the save file) multiple times a minute
* Every save file change consists of two OS-level changes. Without the 1min restriction, every autosave would result in two backup files.
