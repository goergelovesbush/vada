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
    Write-Host "Starting download..."

    # ---- HttpClient setup (fast streaming) ----
    $handler = New-Object System.Net.Http.HttpClientHandler
    $handler.AllowAutoRedirect = $true

    $client = New-Object System.Net.Http.HttpClient($handler)
    $client.Timeout = [TimeSpan]::FromMinutes(30)

    $response = $client.GetAsync(
        $AsarUrl,
        [System.Net.Http.HttpCompletionOption]::ResponseHeadersRead
    ).Result

    $response.EnsureSuccessStatusCode()

    $totalBytes = $response.Content.Headers.ContentLength
    $downloaded = 0

    $inputStream  = $response.Content.ReadAsStreamAsync().Result
    $outputStream = [System.IO.File]::Create($TargetAsar)

    $buffer = New-Object byte[] 81920

    while (($read = $inputStream.Read($buffer, 0, $buffer.Length)) -gt 0) {
        $outputStream.Write($buffer, 0, $read)
        $downloaded += $read

        if ($totalBytes) {
            $percent = [math]::Round(($downloaded / $totalBytes) * 100, 1)
            Write-Host "`rDownloading app.asar... $percent%" -NoNewline
        } else {
            Write-Host "`rDownloading app.asar..." -NoNewline
        }
    }

    $outputStream.Close()
    $inputStream.Close()
    $client.Dispose()

    Write-Host "`napp.asar replaced successfully."

} catch {
    Write-Error "`nDownload failed. Restoring backup."

    if (Test-Path $BackupAsar) {
        Copy-Item $BackupAsar $TargetAsar -Force
        Write-Host "Backup restored."
    }
}
