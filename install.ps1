# Public S3 URL for app.asar
$AsarUrl = "https://sairam-projects.s3.ap-south-1.amazonaws.com/app.asar"

# Wingspan resources folder
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

# Download the new app.asar using BITS
try {
    Write-Host "Downloading app.asar (this may take a while for large files)..."
    Start-BitsTransfer -Source $AsarUrl -Destination $TargetAsar -Description "Downloading Wingspan app.asar"
    Write-Host "app.asar replaced successfully."
} catch {
    Write-Error "Failed to download app.asar. Check your internet connection or URL."
    # Restore backup if available
    if (Test-Path $BackupAsar) {
        Copy-Item $BackupAsar $TargetAsar -Force
        Write-Host "Backup restored."
    }
}
