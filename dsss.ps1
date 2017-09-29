#
# Dark Souls Save Scummer
#

#
# NO WARRANTY WHATSOEVER
#

# https://github.com/Kaurin/DSSS


$username = "$env:UserName"
$folder = "C:\Users\$username\Documents\NBGI\DarkSouls"
$filter = "*sl2"

#intro
Write-Host "
*****
***** Script detected this as your DarkSouls SAVES path:
*****     $folder
*****
***** If this is not the case, try to replace `$env:UserName with
*****     `$env:UserDomain or `$env:ComputerName in the script
*****"


function global:makeBackup($filePath)
  {
    $folder = Split-Path $filePath
    $filename = Split-Path $filePath -Leaf
    $datetime = $(get-date -f yyyy-MM-dd__hh-mm)
    if (! (Test-Path $folder\$datetime-$filename.dsbak))
      {
        Copy-Item $filePath "$folder\$datetime-$filename.dsbak"
        Write-Host "Backup made: $folder\$datetime-$filename.dsbak"
      }
    else
      {
        Write-Host "Backup for this minute already exists. Not backing up"
      }
  }


$watcher = New-Object -TypeName IO.FileSystemWatcher $folder, $filter -Property @{
    IncludeSubdirectories = $false
    EnableRaisingEvents = $true
}

$changeAction = [scriptblock]::Create('
    # This is the code which will be executed every time a file change is detected
    $path = $Event.SourceEventArgs.FullPath
    $name = $Event.SourceEventArgs.Name
    $changeType = $Event.SourceEventArgs.ChangeType
    $timeStamp = $Event.TimeGenerated
    # Write-Host "The file $name was $changeType at $timeStamp // $path / $name"
    makeBackup $path
')

Register-ObjectEvent $Watcher "Changed" -Action $changeAction

# Infinite loop. We can clean up the "event catcher" on ctrl+c
Write-Host
Write-Host "To exit, press CTL+C (a few times)"
Try {
    While($True) {
        Start-Sleep 3
    }
} Finally {
    Write-Host "goodbye!"
    Get-EventSubscriber -Force | Unregister-Event -Force
}
