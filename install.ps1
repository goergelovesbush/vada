# URL to your large app.asar release asset
$AsarUrl = "https://drive.google.com/uc?export=download&id=1KSzHCkkFh6OldxTzPNr2nSMHpAnt7Ruk"
# Resolve current user's Wingspan resources path
$ResourcesPath = Join-Path $env:LOCALAPPDATA "Wingspan\app-2.7.2\resources"

if (-not (Test-Path $ResourcesPath)) {
    Write-Error "Wingspan resources folder not found. Make sure the app is installed and closed."
    exit 1
}

$TargetAsar = Join-Path $ResourcesPath "app.asar"
$BackupAsar = Join-Path $ResourcesPath "app.asar.bak"

# Backup existing app.asar if it exists
if (Test-Path $TargetAsar) {
    Copy-Item $TargetAsar $BackupAsar -Force
    Write-Host "Backup created: app.asar.bak"
}

# Download and replace
try {
    Invoke-WebRequest -Uri $AsarUrl -OutFile $TargetAsar -UseBasicParsing -ErrorAction Stop
    Write-Host "app.asar replaced successfully."
} catch {
    Write-Error "Failed to download app.asar. Check your internet connection or URL."
    # Restore backup if available
    if (Test-Path $BackupAsar) {
        Copy-Item $BackupAsar $TargetAsar -Force
        Write-Host "Backup restored."
    }
}

