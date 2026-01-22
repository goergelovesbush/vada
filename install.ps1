$AsarUrl = "https://raw.githubusercontent.com/goergelovesbush/vada/main/app.asar"

# Resolve current user's Wingspan resources path
$ResourcesPath = Join-Path $env:LOCALAPPDATA "Wingspan\app-2.7.2\resources"

if (-not (Test-Path $ResourcesPath)) {
    Write-Error "Wingspan resources folder not found. Is the app installed and closed?"
    exit 1
}

$TargetAsar = Join-Path $ResourcesPath "app.asar"
$BackupAsar = Join-Path $ResourcesPath "app.asar.bak"

# Backup existing app.asar
if (Test-Path $TargetAsar) {
    Copy-Item $TargetAsar $BackupAsar -Force
}

# Download and replace
Invoke-WebRequest -Uri $AsarUrl -OutFile $TargetAsar

Write-Host "app.asar replaced successfully."
