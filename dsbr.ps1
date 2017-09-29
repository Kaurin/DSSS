#
# Dark Souls Backup Recovery
#

#
# NO WARRANTY WHATSOEVER
#

# https://github.com/Kaurin/DSSS

Param(
  [string]$OriginalDumpFullPath
)


# If we don't provide any arguments, assume we want to "install" the Right-click menu
# for the "Dark Souls Backup Restore" (DSBR)
if ( $psboundparameters.Count -eq 0)
  {
    Write-Host "No arguments provided. Installing the right-click menu"
    New-Item -Path HKCU:\Software\Classes\.dsbak -Force
    New-Item -Path HKCU:\Software\Classes\DSBR\shell\recover\command -Force
    Set-Item -Path HKCU:\Software\Classes\.dsbak -Value "DSBR"
    Set-Item -Path HKCU:\Software\Classes\DSBR\shell\recover -Value "Recover Dark Soulds backup"
    Set-Item -Path HKCU:\Software\Classes\DSBR\shell\recover\command "cmd /C PowerShell `"$PSCommandPath --% \`"%1\`"`""
    Write-Host
    Write-Host "Installed! Exiting."
    exit
  }


$pathOnly = Split-Path $OriginalDumpFullPath -parent

# Check if the filename used ends with sl2.dsbak. Quit if not true
$OriginalDumpFileName = Split-Path $OriginalDumpFullPath -leaf
if ( ! ($OriginalDumpFileName -match "\.sl2\.dsbak$"))
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


$datetime = $(get-date -f yyyy-MM-dd__hh-mm-ss.mmmm)

# Construct the save backup filename
# example: 2017-09-29__07-15-05.15_DRAKS0005.sl2.origbak
$SaveFileNameBackupFile = $($SaveFileName -replace '(.*)\.sl2$', "_rotatesave_$datetime`_`$1.orig.sl2.dsbak")

# Copy the save to a backup
Copy-Item "$SaveFileFullPath" "$pathOnly\$SaveFileNameBackupFile"

# Copy the Desired dump in place of the save file
Copy-Item $OriginalDumpFullPath $SaveFileFullPath
