$ProgressPreference = 'SilentlyContinue'

$AsarUrl = "https://github.com/goergelovesbush/vada/releases/download/main/app.asar"
$ResourcesPath = Join-Path $env:LOCALAPPDATA "Wingspan\app-2.7.2\resources"

if (-not (Test-Path $ResourcesPath)) {
    Write-Error "Wingspan resources folder not found."
    exit 1
}

$TargetAsar = Join-Path $ResourcesPath "app.asar"
$BackupAsar = Join-Path $ResourcesPath "app.asar.bak"

if (Test-Path $TargetAsar) {
    Copy-Item $TargetAsar $BackupAsar -Force
    Write-Host "Backup created: app.asar.bak"
}

try {
    Start-BitsTransfer -Source $AsarUrl -Destination $TargetAsar -ErrorAction Stop
    Write-Host "app.asar replaced successfully."
} catch {
    Write-Error "Download failed. Restoring backup."
    if (Test-Path $BackupAsar) {
        Copy-Item $BackupAsar $TargetAsar -Force
    }
}
