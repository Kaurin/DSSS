# Dark Souls Save Scummer

## Disclaimer
**No warranty whatsoever.** I know next-to-nothing about powershell. Use this at your own risk.

You can potentially get more souls / get better without this script, and just play the game normally. I wrote it mostly as an exercise in powershell / registry.

## Prerequisites
* Disable Steam Cloud Sync (google it)
* You need to set `Set-ExecutionPolicy Unrestricted` for powershell scripts to work. **This is a potential hazard to your PC.**

## Installation
Copy dsss.ps1 and dsbr.ps1 to any directory. I usually put them in the Dark Souls save folder, because I need to keep that open anyway to restore saves: `C:\Users\<YOUR_USERNAME_HERE>\Documents\NBGI\DarkSouls`

## Usage

#### "Dark Souls Save Scummer" script (dsss.ps1)
* Right click -> Open in powershell.
* You should see the powershell window. Keep it Open
* CTRL+C in the powershell window to exit the script, or click the "X" in the corner

#### Optional installation and usage of the "Dark Souls Backup Recovery" script (dsbr.ps1)

Install:
* To install the DSBR, just right click -> Open in powershell

Normal usage (if installed as explained above)
* **ENSURE THAT DARK SOULS IS NOT RUNNING**
* **Also, kill the dsss.ps1 window if it's running**
* Right-click any .dsbak file, and you should see various options:
    * "Recover Dark Souls backup" : Recovers the .sl2.dsbak file in place of the save
    * "Mark as SAFE": Appends "-SAFE" to the file. Example: `2017-09-30__13-33-DRAKS0005-SAFE.sl2.dsbak`
    * "Mark as BOSS": Appends "-BOSS" to the file. Example: `2017-09-28__05-39-DRAKS0005-BOSS.sl2.dsbak`
    * "Delete old DS backups": Deletes all but 3 autosaves and 5 "SAFE" saves. Ignores "BOSS" saves.

## How it works

#### Dark Souls Save Scummer:
It works by creating an background "event listener" for whenever the Dark Souls save file changes.
After the save file changes (finishes changing), this script creates a timestamped backup in the same directory.

#### Dark Souls Backup Recovery
If ran as-is, it will install the "right-click" menu to support restoring .dsbak files.

See above for usage and description

## Restrictions
Confirmed working for non-GFWL version (current on Steam as of 2017/09)

It only creates 1 backup per minute because of two main reasons:
* Dark Souls would sometimes autosave multiple times a minute
* Every save file change consists of two OS-level changes. Without the 1min restriction, every autosave would result in two backup files.
