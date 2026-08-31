[CmdletBinding()]
param([string]$ServerPath)

$ErrorActionPreference = 'Stop'
$packRoot = Split-Path -Parent $MyInvocation.MyCommand.Path

if (-not $ServerPath) {
    $ServerPath = Read-Host 'Enter the existing TrinityCore 12.0.7 server folder'
}
$ServerPath = $ServerPath.Trim().Trim('"')
if (-not (Test-Path -LiteralPath $ServerPath -PathType Container)) {
    throw "Server folder not found: $ServerPath"
}
$ServerPath = (Resolve-Path -LiteralPath $ServerPath).Path

$required = @('worldserver.conf', 'bnetserver.conf')
foreach ($name in $required) {
    if (-not (Test-Path -LiteralPath (Join-Path $ServerPath $name) -PathType Leaf)) {
        throw "This does not look like a complete TrinityCore server. Missing: $name"
    }
}

$running = Get-Process worldserver,bnetserver -ErrorAction SilentlyContinue
if ($running) {
    throw 'worldserver or bnetserver is running. Stop both services and run the installer again.'
}

$stamp = Get-Date -Format 'yyyyMMdd-HHmmss'
$backup = Join-Path $ServerPath "playerbot-v2-backups\$stamp"
New-Item -ItemType Directory -Force -Path $backup | Out-Null

$backupFiles = @(
    'bnetserver.exe', 'playerbot.conf', 'Start-Playerbot-V2.cmd',
    'Stop-Playerbot-V2.cmd', 'Restore-PlayerbotV2-Backup.cmd',
    'playerbot-v2-runtime\worldserver.exe'
)
foreach ($relative in $backupFiles) {
    $source = Join-Path $ServerPath $relative
    if (Test-Path -LiteralPath $source -PathType Leaf) {
        $destination = Join-Path $backup $relative
        New-Item -ItemType Directory -Force -Path (Split-Path -Parent $destination) | Out-Null
        Copy-Item -LiteralPath $source -Destination $destination -Force
    }
}
Copy-Item -LiteralPath (Join-Path $ServerPath 'worldserver.conf') -Destination (Join-Path $backup 'worldserver.conf') -Force

$runtimeTarget = Join-Path $ServerPath 'playerbot-v2-runtime'
New-Item -ItemType Directory -Force -Path $runtimeTarget | Out-Null
Copy-Item -Path (Join-Path $packRoot 'payload\runtime\*') -Destination $runtimeTarget -Recurse -Force
Copy-Item -Path (Join-Path $packRoot 'payload\bnet\*') -Destination $ServerPath -Recurse -Force
Copy-Item -LiteralPath (Join-Path $packRoot 'payload\playerbot.conf') -Destination (Join-Path $ServerPath 'playerbot.conf') -Force

$sqlTarget = Join-Path $ServerPath 'sql\playerbot_v2'
New-Item -ItemType Directory -Force -Path $sqlTarget | Out-Null
Copy-Item -Path (Join-Path $packRoot 'payload\sql\playerbot_v2\*') -Destination $sqlTarget -Recurse -Force

Copy-Item -Path (Join-Path $packRoot 'server-tools\*') -Destination $ServerPath -Force

$worldConf = Join-Path $ServerPath 'worldserver.conf'
$confText = [IO.File]::ReadAllText($worldConf)
if ($confText -match '(?m)^\s*RoadGraph\.Enable\s*=.*$') {
    $confText = [regex]::Replace($confText, '(?m)^\s*RoadGraph\.Enable\s*=.*$', 'RoadGraph.Enable = 0')
} else {
    $confText += "`r`n# Playerbot V2 low-memory profile`r`nRoadGraph.Enable = 0`r`n"
}
[IO.File]::WriteAllText($worldConf, $confText, [Text.UTF8Encoding]::new($false))

Set-Content -LiteralPath (Join-Path $ServerPath 'playerbot-v2-installed.txt') -Encoding UTF8 -Value @(
    "Installed: $(Get-Date -Format o)",
    "Package: TrinityCore 12.0.7 Playerbot V2 Easy Pack",
    "Backup: $backup"
)

Write-Host ''
Write-Host 'Playerbot V2 installation completed successfully.' -ForegroundColor Green
Write-Host "Backup created at: $backup"
Write-Host "Start with: $(Join-Path $ServerPath 'Start-Playerbot-V2.cmd')"
