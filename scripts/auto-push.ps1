param(
  [string]$Message = ""
)

$ErrorActionPreference = "Stop"

$status = git status --porcelain
if (-not $status) {
  Write-Host "No changes to push."
  exit 0
}

git add -A

if ([string]::IsNullOrWhiteSpace($Message)) {
  $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm"
  $Message = "auto: update $timestamp"
}

git commit -m "$Message" | Out-Host
git push | Out-Host
