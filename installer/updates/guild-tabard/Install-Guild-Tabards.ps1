[CmdletBinding()]
param([string]$ServerPath)

$ErrorActionPreference = 'Stop'
$updateRoot = Split-Path -Parent $MyInvocation.MyCommand.Path
$worldPayload = Join-Path $updateRoot 'payload\runtime\worldserver.exe'
$expectedWorldHash = '2486A9A252A528A4868BBFE8EC0AAB2B71FC3A99FF9E9403133D5265717E17C1'

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
            throw "This is not a complete Voidspark server folder. Missing: $name"
        }
    }

    $worldTarget = Join-Path $ServerPath 'playerbot-v2-runtime\worldserver.exe'
    if (-not (Test-Path -LiteralPath $worldTarget -PathType Leaf)) {
        throw 'Missing playerbot-v2-runtime\worldserver.exe. Install Voidspark first.'
    }
    if (Get-Process worldserver,bnetserver -ErrorAction SilentlyContinue) {
        throw 'The game server is running. Stop both services, then run this updater again.'
    }
    if ((Get-FileHash -LiteralPath $worldPayload -Algorithm SHA256).Hash -ne $expectedWorldHash) {
        throw 'The packaged world server failed its integrity check. Download the update again.'
    }

    $playerbotConf = Join-Path $ServerPath 'playerbot.conf'
    $stamp = Get-Date -Format 'yyyyMMdd-HHmmss'
    $backup = Join-Path $ServerPath "playerbot-v2-backups\guild-tabards-$stamp"
    New-Item -ItemType Directory -Force -Path (Join-Path $backup 'playerbot-v2-runtime') | Out-Null
    Copy-Item -LiteralPath $worldTarget -Destination (Join-Path $backup 'playerbot-v2-runtime\worldserver.exe') -Force
    Copy-Item -LiteralPath $playerbotConf -Destination (Join-Path $backup 'playerbot.conf') -Force

    try {
        Copy-Item -LiteralPath $worldPayload -Destination $worldTarget -Force
        $text = [IO.File]::ReadAllText($playerbotConf)
        $pattern = '(?m)^\s*Playerbot\.Guild\.AutoEquipTabard\s*=.*$'
        if ($text -match $pattern) {
            $text = [regex]::Replace($text, $pattern, 'Playerbot.Guild.AutoEquipTabard = 1')
        } else {
            $text = $text.TrimEnd() + "`r`n`r`n# Automatically display each bot's own guild tabard.`r`nPlayerbot.Guild.AutoEquipTabard = 1`r`n"
        }
        [IO.File]::WriteAllText($playerbotConf, $text, [Text.UTF8Encoding]::new($false))
    } catch {
        Copy-Item -LiteralPath (Join-Path $backup 'playerbot-v2-runtime\worldserver.exe') -Destination $worldTarget -Force
        Copy-Item -LiteralPath (Join-Path $backup 'playerbot.conf') -Destination $playerbotConf -Force
        throw
    }

    Set-Content -LiteralPath (Join-Path $ServerPath 'playerbot-v2-guild-tabards.txt') -Encoding UTF8 -Value @(
        "Installed: $(Get-Date -Format o)",
        'Update: Automatic Guild Tabards 1.0',
        "Backup: $backup"
    )

    Write-Host ''
    Write-Host 'Automatic bot guild tabards installed successfully.' -ForegroundColor Green
    Write-Host "Backup created at: $backup"
    Write-Host 'Start the server normally. Guilded bots repair their tabard when they log in.'
} catch {
    Write-Host ''
    Write-Host "Update failed: $($_.Exception.Message)" -ForegroundColor Red
    exit 1
}

