param(
  [int]$DebounceSeconds = 5
)

$ErrorActionPreference = "Stop"

$root = Resolve-Path "."
$pending = $false
$lastChange = Get-Date

Write-Host "Watching for changes in $root"
Write-Host "Auto push after $DebounceSeconds seconds of inactivity."

$watcher = New-Object System.IO.FileSystemWatcher
$watcher.Path = $root
$watcher.IncludeSubdirectories = $true
$watcher.EnableRaisingEvents = $true
$watcher.NotifyFilter = [System.IO.NotifyFilters]'FileName, LastWrite, DirectoryName'

$ignored = @(
  "\.git\",
  "\node_modules\",
  "\dist\",
  "\dist-electron\",
  "\.vercel\",
  "\.env.local"
)

$action = {
  param($sender, $eventArgs)
  $path = $eventArgs.FullPath
  foreach ($pattern in $using:ignored) {
    if ($path -like "*$pattern*") {
      return
    }
  }
  $using:pending = $true
  $using:lastChange = Get-Date
}

Register-ObjectEvent $watcher Changed -Action $action | Out-Null
Register-ObjectEvent $watcher Created -Action $action | Out-Null
Register-ObjectEvent $watcher Deleted -Action $action | Out-Null
Register-ObjectEvent $watcher Renamed -Action $action | Out-Null

while ($true) {
  Start-Sleep -Seconds 1
  if ($pending -and ((Get-Date) - $lastChange).TotalSeconds -ge $DebounceSeconds) {
    $pending = $false
    Write-Host "Changes detected. Running autopush..."
    & powershell -ExecutionPolicy Bypass -File "$root\scripts\auto-push.ps1" | Out-Host
  }
}
