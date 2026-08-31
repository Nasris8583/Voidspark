$ErrorActionPreference = 'Stop'
$serverRoot = Split-Path -Parent $MyInvocation.MyCommand.Path
$backupRoot = Join-Path $serverRoot 'playerbot-v2-backups'
if (-not (Test-Path -LiteralPath $backupRoot -PathType Container)) {
    throw "No backup folder found at $backupRoot"
}
if (Get-Process worldserver,bnetserver -ErrorAction SilentlyContinue) {
    throw 'Stop worldserver and bnetserver before restoring.'
}
$backups = @(Get-ChildItem -LiteralPath $backupRoot -Directory | Sort-Object Name -Descending)
if ($backups.Count -eq 0) { throw 'No Playerbot backup was found.' }

Write-Host 'Available backups:'
for ($i = 0; $i -lt $backups.Count; ++$i) {
    Write-Host "[$($i + 1)] $($backups[$i].Name)"
}
$choice = Read-Host 'Choose a backup number (Enter selects newest)'
$index = if ([string]::IsNullOrWhiteSpace($choice)) { 0 } else { [int]$choice - 1 }
if ($index -lt 0 -or $index -ge $backups.Count) { throw 'Invalid backup selection.' }
$selected = $backups[$index].FullName

Get-ChildItem -LiteralPath $selected -Recurse -File | ForEach-Object {
    $relative = $_.FullName.Substring($selected.Length).TrimStart('\')
    $destination = Join-Path $serverRoot $relative
    New-Item -ItemType Directory -Force -Path (Split-Path -Parent $destination) | Out-Null
    Copy-Item -LiteralPath $_.FullName -Destination $destination -Force
}
Write-Host "Restored files from $selected" -ForegroundColor Green
