#
# Dark Souls Backup Recovery
#

#
# NO WARRANTY WHATSOEVER
#

# https://github.com/Kaurin/DSSS

Param(
  [string]$OriginalDumpFullPath,
  [string]$Operation
)

# Exit on any error
$ErrorActionPreference = "Stop"

# If we don't provide any arguments, assume we want to "install" the Right-click menu
# for the "Dark Souls Backup Restore" (DSBR)
if ( $psboundparameters.Count -eq 0)
  {
    Write-Host "No arguments provided. Installing the right-click menu"

    Remove-Item -Path HKCU:\Software\Classes\.dsbak -Force -Recurse -ErrorAction SilentlyContinue
    Remove-Item -Path HKCU:\Software\Classes\DSBR -Force  -Recurse -ErrorAction SilentlyContinue

    New-Item -Path HKCU:\Software\Classes\.dsbak -Force
    Set-Item -Path HKCU:\Software\Classes\.dsbak -Value "DSBR"

    # keys restore, markSafe, markBoss, deleteold
    New-Item -Path HKCU:\Software\Classes\DSBR\shell\1restore\command -Force
    New-Item -Path HKCU:\Software\Classes\DSBR\shell\markSafe\command -Force
    New-Item -Path HKCU:\Software\Classes\DSBR\shell\markBoss\command -Force
    New-Item -Path HKCU:\Software\Classes\DSBR\shell\zdeleteOld\command -Force

    # values restore
    Set-Item -Path HKCU:\Software\Classes\DSBR\shell\1restore -Value "Recover Dark Souls backup"
    Set-Item -Path HKCU:\Software\Classes\DSBR\shell\1restore\command "cmd /C PowerShell `"$PSCommandPath -Operation Restore -OriginalDumpFullPath --% \`"%1\`"`""

    # values markSafe
    Set-Item -Path HKCU:\Software\Classes\DSBR\shell\markSafe -Value "Mark as SAFE"
    Set-Item -Path HKCU:\Software\Classes\DSBR\shell\markSafe\command "cmd /C PowerShell `"$PSCommandPath -Operation markSafe -OriginalDumpFullPath --% \`"%1\`"`""

    # values markBoss
    Set-Item -Path HKCU:\Software\Classes\DSBR\shell\markBoss -Value "Mark as BOSS"
    Set-Item -Path HKCU:\Software\Classes\DSBR\shell\markBoss\command "cmd /C PowerShell `"$PSCommandPath -Operation markBoss -OriginalDumpFullPath --% \`"%1\`"`""

    # values Delete old
    Set-Item -Path HKCU:\Software\Classes\DSBR\shell\zdeleteOld -Value "Delete old DS backups"
    Set-Item -Path HKCU:\Software\Classes\DSBR\shell\zdeleteOld\command "cmd /C PowerShell `"$PSCommandPath -Operation DeleteOld -OriginalDumpFullPath --% \`"%1\`"`""

    Write-Host
    Write-Host "Installed! Exiting."
    exit
  }

# This will be frequently used. Base path of the dump
$pathOnly = Split-Path $OriginalDumpFullPath -parent

# Check if the filename used ends with sl2.dsbak. Quit if not true
$OriginalDumpFileName = Split-Path $OriginalDumpFullPath -leaf
if ( $OriginalDumpFileName -notmatch "\.sl2\.dsbak$" )
   {
     Write-Host "Filename should end with '.sl2.dsbak'. Quitting"
     exit
   }

# Get the original SaveFileName full path
$SaveFileFullPath = (dir $pathOnly\*.sl2).FullName
$SaveFileName = Split-Path $SaveFileFullPath -leaf

# Exit if $SaveFileName string null/empty
IF([string]::IsNullOrEmpty($SaveFileName)) {
   Write-Host "Could not find the original save file in '$pathOnly'. Exiting."
   exit
}

$datetime = $(get-date -f yyyy-MM-dd__HH-mm__ss.mmmm)

# Function that restores a right-clicked backup
function doRestore {
  # Construct the save backup filename
  # example: 2017-09-29__07-15-05.15_DRAKS0005.sl2.origbak
  $SaveFileNameBackupFile = $($SaveFileName -replace '(.*)\.sl2$', "_rotatesave_$datetime`_`$1.orig.sl2.dsbak")

  # Back up current save
  Copy-Item "$SaveFileFullPath" "$pathOnly\$SaveFileNameBackupFile"

  # Copy the Desired dump in place of the save file
  Copy-Item "$OriginalDumpFullPath" "$SaveFileFullPath"
}

# Function to delete all but X files
function deleteAllBut {
  param(
    [string]$matchWildcard,
    [string]$directoryForDeletion,
    [string]$nomatchRegex,
    [int]$keepNumFiles
  )
  # List backups (non BOSS or SAFE), and sort by time. Feed to array var $listOfBackups
  $listOfBackups=Get-ChildItem "$directoryForDeletion\$matchWildcard" | Where-Object { $_.FullName -notmatch $nomatchRegex } | sort LastWriteTime -Descending | Foreach-Object {$_.FullName}
  # Convert to ArrayList
  $listOfBackups = New-Object System.Collections.ArrayList(,$listOfBackups)
  #$listOfBackups.GetType()
  #foreach ( $item in $listOfBackups ) { $item }
  try
    {
      $listOfBackups.RemoveRange(0,$keepNumFiles)
      #foreach ( $item in $listOfBackups ) { $item }
      if ($listOfBackups.Count -gt 0)
        {
          foreach ($backupFileToDelete in $listOfBackups)
            {
              Write-Host "Deleting $backupFileToDelete"
              Remove-Item "$backupFileToDelete"
            }
        }
    }
  catch { return }  # Do nothing if we fail to truncate the range
}

# This function deletes old backups except for 3 latest ones
function doDeleteOld {
  deleteAllBut -matchWildcard '*.sl2.dsbak' -directoryForDeletion $pathOnly -nomatchRegex '(-BOSS.sl2.dsbak)|(-SAFE.sl2.dsbak)' -keepNumFiles 3
}

# This function deletes old SAFE backups except for 5 latest ones
function doDeleteOldSAFE {
  deleteAllBut -matchWildcard '*-SAFE.sl2.dsbak' -directoryForDeletion $pathOnly -nomatchRegex '(BOGUSSSSSSSSS)' -keepNumFiles 5 #nomatchRegex is irrelevant here, just provide a safe value
}

# Function that marks a backup. To be used with other doMark* functions below it
function doMark {
  Param(
    [string]$MarkString
  )
  # Let's not do anything if it's already marked
  if ($OriginalDumpFullPath -notmatch "-$MarkString\.sl2\.dsbak$")
    {
      # This won't rename the file if it doesn't match the regex.
      $OriginalDumpFullPath | Rename-Item -NewName {$_ -replace '\.sl2\.dsbak$', "-$MarkString.sl2.dsbak"}
    }
}

# Makes a file *.sl2.dsbak -> *-SAFE.sl2.dsbak
function doMarkSafe {
  doMark -MarkString "SAFE"
}

# Makes a file *.sl2.dsbak -> *-BOSS.sl2.dsbak
function doMarkBoss {
  doMark -MarkString "BOSS"
}

# Start script logic if parameter $Operation passed.
# Simply decide which function(s) to execute based on the $Operation param
switch ($Operation)
    {
        "Restore"
          {
            doRestore
            # Start Dark Souls "Prepare to die" edition
            start steam://run/211420
          }
        "MarkSafe" { doMarkSafe }
        "MarkBoss" { doMarkBoss }
        "DeleteOld"
          {
            doDeleteOld
            doDeleteOldSAFE
          }
    }
