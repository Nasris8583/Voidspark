[CmdletBinding()]
param([string]$ServerPath)

$ErrorActionPreference = 'Stop'

function Set-ConfigValue {
    param(
        [Parameter(Mandatory)][string]$Text,
        [Parameter(Mandatory)][string]$Name,
        [Parameter(Mandatory)][string]$Value
    )

    $escaped = [regex]::Escape($Name)
    $pattern = "(?m)^\s*$escaped\s*=.*$"
    $replacement = "$Name = $Value"
    if ($Text -match $pattern) {
        return [regex]::Replace($Text, $pattern, $replacement)
    }
    return $Text.TrimEnd() + "`r`n$replacement`r`n"
}

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
    if (-not (Test-Path -LiteralPath (Join-Path $ServerPath 'playerbot-v2-runtime\worldserver.exe') -PathType Leaf)) {
        throw 'Missing playerbot-v2-runtime\worldserver.exe. Install Voidspark first.'
    }

    if (Get-Process worldserver,bnetserver -ErrorAction SilentlyContinue) {
        throw 'The game server is running. Stop both services, then run this updater again.'
    }

    $playerbotConf = Join-Path $ServerPath 'playerbot.conf'
    $stamp = Get-Date -Format 'yyyyMMdd-HHmmss'
    $backup = Join-Path $ServerPath "playerbot-v2-backups\bg-safe-$stamp"
    New-Item -ItemType Directory -Force -Path $backup | Out-Null
    Copy-Item -LiteralPath $playerbotConf -Destination (Join-Path $backup 'playerbot.conf') -Force

    $settings = [ordered]@{
        'Playerbot.Population.TotalTarget' = '20'
        'Playerbot.Population.Floor' = '20'
        'Playerbot.Population.Ceiling' = '20'
        'Playerbot.V2.AutoResumeCap' = '20'
        'Playerbot.AiWorkerThreads' = '2'
        'PlayerbotV2.ParallelSnapshotBuild' = '1'
        'PlayerbotV2.SnapshotBuildThreads' = '1'
        'Playerbot.Bg.AutoSeed.Matches' = '0'
        'Playerbot.Bg.AutoSeed.Arena' = '0'
        'Playerbot.Bg.Coordinator.Enable' = '1'
        'Playerbot.Housing.Enabled' = '0'
    }

    $text = [IO.File]::ReadAllText($playerbotConf)
    foreach ($entry in $settings.GetEnumerator()) {
        $text = Set-ConfigValue -Text $text -Name $entry.Key -Value $entry.Value
    }

    $temporary = "$playerbotConf.bg-safe-new"
    [IO.File]::WriteAllText($temporary, $text, [Text.UTF8Encoding]::new($false))
    try {
        Move-Item -LiteralPath $temporary -Destination $playerbotConf -Force
    } catch {
        if (Test-Path -LiteralPath $temporary) { Remove-Item -LiteralPath $temporary -Force }
        Copy-Item -LiteralPath (Join-Path $backup 'playerbot.conf') -Destination $playerbotConf -Force
        throw
    }

    $marker = Join-Path $ServerPath 'playerbot-v2-bg-safe-update.txt'
    Set-Content -LiteralPath $marker -Encoding UTF8 -Value @(
        "Installed: $(Get-Date -Format o)",
        'Profile: Voidspark 16 GB BG Safe 1.0',
        'Bot cap: 20',
        "Backup: $backup"
    )

    Write-Host ''
    Write-Host 'Voidspark 16 GB battleground-safe profile installed.' -ForegroundColor Green
    Write-Host 'Bot population capped at 20; battleground coordination remains enabled.'
    Write-Host 'Automatic battleground and arena seeding remain disabled.'
    Write-Host "Original configuration backed up at: $backup"
    Write-Host 'Start the server normally and wait for all bots to log in before entering a battleground.'
} catch {
    Write-Host ''
    Write-Host "Update failed: $($_.Exception.Message)" -ForegroundColor Red
    exit 1
}
