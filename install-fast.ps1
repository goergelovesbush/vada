$ProgressPreference = 'SilentlyContinue'

$AsarUrl = "https://github.com/goergelovesbush/vada/releases/download/main/app.asar"
$ResourcesPath = Join-Path $env:LOCALAPPDATA "Wingspan\app-2.7.2\resources"

if (-not (Test-Path $ResourcesPath)) {
    Write-Error "Wingspan resources folder not found."
    exit 1
}

$TargetAsar = Join-Path $ResourcesPath "app.asar"
$BackupAsar = Join-Path $ResourcesPath "app.asar.bak"

# Backup existing app.asar
if (Test-Path $TargetAsar) {
    Copy-Item $TargetAsar $BackupAsar -Force
    Write-Host "Backup created: app.asar.bak"
}

try {
    Write-Host "Downloading app.asar..."

    # Start BITS download asynchronously
    $job = Start-BitsTransfer `
        -Source $AsarUrl `
        -Destination $TargetAsar `
        -Asynchronous `
        -ErrorAction Stop

    # Live progress display
    while ($job.JobState -eq "Transferring") {
        if ($job.BytesTotal -gt 0) {
            $percent = [math]::Round(($job.BytesTransferred / $job.BytesTotal) * 100, 1)
            Write-Host "`rDownloading app.asar... $percent%" -NoNewline
        }
        Start-Sleep 1
        $job = Get-BitsTransfer -Id $job.Id
    }

    Complete-BitsTransfer -BitsJob $job
    Write-Host "`napp.asar replaced successfully."

} catch {
    Write-Error "`nDownload failed. Restoring backup."

    if (Test-Path $BackupAsar) {
        Copy-Item $BackupAsar $TargetAsar -Force
        Write-Host "Backup restored."
    }
}
