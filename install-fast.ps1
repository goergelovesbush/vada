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
    Write-Host "Starting download..."

    $job = Start-BitsTransfer `
        -Source $AsarUrl `
        -Destination $TargetAsar `
        -Asynchronous `
        -ErrorAction Stop

    while ($true) {
        $job = Get-BitsTransfer -Id $job.Id

        switch ($job.JobState) {

            "Connecting" {
                Write-Host "`rConnecting to server..." -NoNewline
            }

            "Queued" {
                Write-Host "`rWaiting for BITS slot..." -NoNewline
            }

            "Transferring" {
                if ($job.BytesTotal -gt 0) {
                    $percent = [math]::Round(($job.BytesTransferred / $job.BytesTotal) * 100, 1)
                    Write-Host "`rDownloading app.asar... $percent%" -NoNewline
                } else {
                    Write-Host "`rDownloading app.asar..." -NoNewline
                }
            }

            "Transferred" {
                break
            }

            "Error" {
                throw "BITS download failed."
            }
        }

        Start-Sleep 1
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
