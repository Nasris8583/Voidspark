[CmdletBinding()]
param([string]$ServerPath)

$ErrorActionPreference = 'Stop'
$updateRoot = Split-Path -Parent $MyInvocation.MyCommand.Path
$payloadRoot = Join-Path $updateRoot 'payload'
$expectedWorldHash = 'D93017881D8D3522899C58824D0B3DCF95B904397FD9D81306775532BA24B41B'
$expectedSqlHash = '9B27BE660BDDF6B00F1116B6323D834266945D7B0BABC6980D5B7762E01A846E'

try {
    if (-not $ServerPath) {
        $ServerPath = Read-Host 'Enter the TrinityCore 12.0.7 Voidspark server folder'
    }
    $ServerPath = $ServerPath.Trim().Trim('"')
    if (-not (Test-Path -LiteralPath $ServerPath -PathType Container)) {
        throw "Server folder not found: $ServerPath"
    }
    $ServerPath = (Resolve-Path -LiteralPath $ServerPath).Path

    foreach ($name in @('worldserver.conf', 'bnetserver.conf', 'playerbot.conf')) {
        if (-not (Test-Path -LiteralPath (Join-Path $ServerPath $name) -PathType Leaf)) {
            throw "This is not a Voidspark TrinityCore server folder. Missing: $name"
        }
    }

    $worldTarget = Join-Path $ServerPath 'playerbot-v2-runtime\worldserver.exe'
    if (-not (Test-Path -LiteralPath $worldTarget -PathType Leaf)) {
        throw 'Missing playerbot-v2-runtime\worldserver.exe. Install the Voidspark Easy Pack first.'
    }

    $running = Get-Process worldserver,bnetserver -ErrorAction SilentlyContinue
    if ($running) {
        throw 'The game server is running. Use Stop-Playerbot-V2.cmd, then run this updater again.'
    }

    $worldPayload = Join-Path $payloadRoot 'runtime\worldserver.exe'
    $sqlPayload = Join-Path $payloadRoot 'sql\playerbot_v2\0017_lore_knowledge.sql'
    if ((Get-FileHash -LiteralPath $worldPayload -Algorithm SHA256).Hash -ne $expectedWorldHash) {
        throw 'The packaged world server failed its integrity check. Download the update again.'
    }
    if ((Get-FileHash -LiteralPath $sqlPayload -Algorithm SHA256).Hash -ne $expectedSqlHash) {
        throw 'The packaged lore database update failed its integrity check. Download the update again.'
    }

    $stamp = Get-Date -Format 'yyyyMMdd-HHmmss'
    $backup = Join-Path $ServerPath "playerbot-v2-backups\lore-update-$stamp"
    New-Item -ItemType Directory -Force -Path (Join-Path $backup 'playerbot-v2-runtime') | Out-Null
    Copy-Item -LiteralPath $worldTarget -Destination (Join-Path $backup 'playerbot-v2-runtime\worldserver.exe') -Force

    $sqlTargetDir = Join-Path $ServerPath 'sql\playerbot_v2'
    $sqlTarget = Join-Path $sqlTargetDir '0017_lore_knowledge.sql'
    if (Test-Path -LiteralPath $sqlTarget -PathType Leaf) {
        New-Item -ItemType Directory -Force -Path (Join-Path $backup 'sql\playerbot_v2') | Out-Null
        Copy-Item -LiteralPath $sqlTarget -Destination (Join-Path $backup 'sql\playerbot_v2\0017_lore_knowledge.sql') -Force
    }

    try {
        New-Item -ItemType Directory -Force -Path $sqlTargetDir | Out-Null
        Copy-Item -LiteralPath $worldPayload -Destination $worldTarget -Force
        Copy-Item -LiteralPath $sqlPayload -Destination $sqlTarget -Force
    } catch {
        Copy-Item -LiteralPath (Join-Path $backup 'playerbot-v2-runtime\worldserver.exe') -Destination $worldTarget -Force
        throw
    }

    Set-Content -LiteralPath (Join-Path $ServerPath 'playerbot-v2-lore-update.txt') -Encoding UTF8 -Value @(
        "Installed: $(Get-Date -Format o)",
        'Update: Conversational WoW Lore 0.2.0',
        "Backup: $backup"
    )

    Write-Host ''
    Write-Host 'Conversational WoW lore update installed successfully.' -ForegroundColor Green
    Write-Host "Backup created at: $backup"
    Write-Host 'Start the server normally. Migration 0017 is applied automatically.'
    Write-Host 'Test in game with: /say Who is Arthas?'
} catch {
    Write-Host ''
    Write-Host "Update failed: $($_.Exception.Message)" -ForegroundColor Red
    exit 1
}

