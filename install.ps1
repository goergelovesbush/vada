# Pre-signed S3 URL for app.asar
$AsarUrl = "https://sairam-projects.s3.ap-south-1.amazonaws.com/app.asar?response-content-disposition=inline&X-Amz-Content-Sha256=UNSIGNED-PAYLOAD&X-Amz-Security-Token=IQoJb3JpZ2luX2VjEBkaCmFwLXNvdXRoLTEiSDBGAiEAiGvizaUNFfUCeUVHd3M7opZxwMCvalvP3eYbpZ4vr4ECIQDXn2XQkyLUzaNIeNTUIIEgZuDSGU%2Bu77UIIK%2BbPWqjtirCAwji%2F%2F%2F%2F%2F%2F%2F%2F%2F%2F8BEAAaDDQ2MzQ3MDk1MzIwOSIMm5Wb9%2FblKJMfwdM%2BKpYDUj493we5A0YqhFv3N8pjj3b0E9quSewDDDsIrgRRWAavX8%2BCXFw4GJ5kdVByhNOzkd48AyE1JcGzcNEpfHxuM20Gv0sRJ%2BoT%2FH%2B0a%2B2%2BHLDBQKbdO3ENNsqpZWqq63rHMAng3aMakqomcQ9Ufwuv%2BbaahTjw6o7edMUVtxKjnuKlFg712UGu93QDITbxVgo37ruNmnqJ8OfoWiLlL6ymkGDHytSuFskH30D3j0wIuOjnuhuCbpFRQJ6waFbsbuwy3mW3wdyRsUkTE6UNEC42Lp%2Fu7zXJzKi%2BwbR1fI6eZjnylQSSM7w2xTBPcJAu9okrBdB51F1vf9wgXsotxa91C28d3xPnVgt3Z7xTGUBEPHarYC5MpPTV4pmDAEMCoukTzntb6jhI4vQVcYWLdO%2Bv%2B0o%2BcIGtE8p%2BM7f5no59X%2BiAa3BT86%2BXPnsNBJP69xCqmnGx3njW3qKbNBb%2BXK6d2HozlfPKz1lUCXZaG%2BvyxOPepaSZuXpJ%2BDN1wRda7QVVaP%2Bf%2BCoKGytCXG0yA9n9%2Bt8gNp0FmDDaq8nLBjrdAryBH%2FOpLNRpR0VzFtoTYpv0Bw49FVFZs8MVgoF%2FCFGfSpwt123TrtRShLnSoTg3z5ean7cDREkQ%2FeawtX05mXeLXZjHlX4A9BpZzzerfEw%2FaWEUOAFB9LSaavwpc%2F27Y0mPsLrB89oK38SF%2BFDJV3PhyEwR%2BrokZPs3orSwD%2BUuhCU%2FyGNqxy1gRU6%2BZSAsvaGnfZmq%2FG3KehtZWcQ%2Fy%2FNATgyWN1pIY%2BpjcQxjUkJXRZewTYBmsKV5sDBMY623eFn%2BHJHke2Ee%2FHjzF93XsKWnDGGzbDxGKu8V%2FGGDx7wGXnlTTqyn6%2B6rTMPQjsr37b5Wqomnvyq2Du3b6%2BP%2F46FpmWA7twPphVvgdzFJL16TD7HvXSxPhrsULC%2FMLNhg0WInk%2F3SB7fidVkNkzK7BDmZfP2T1tnarg9%2B9cYmoRS3nIkhIyCkTxfNbIeWT4POMkEu360B3pWTe%2FCokME%3D&X-Amz-Algorithm=AWS4-HMAC-SHA256&X-Amz-Credential=ASIAWX2IFQL4R6ZTP64H%2F20260122%2Fap-south-1%2Fs3%2Faws4_request&X-Amz-Date=20260122T170946Z&X-Amz-Expires=43200&X-Amz-SignedHeaders=host&X-Amz-Signature=550dddfac7d493b7b4c4d5f3d812268fa477e31bdf1891ba9f5ee3cd90bd15ce"

# Wingspan resources folder
$ResourcesPath = Join-Path $env:LOCALAPPDATA "Wingspan\app-2.7.2\resources"

if (-not (Test-Path $ResourcesPath)) {
    Write-Error "Wingspan resources folder not found. Make sure the app is installed and closed."
    exit 1
}

$TargetAsar = Join-Path $ResourcesPath "app.asar"
$BackupAsar = Join-Path $ResourcesPath "app.asar.bak"

# Backup existing file
if (Test-Path $TargetAsar) {
    Copy-Item $TargetAsar $BackupAsar -Force
    Write-Host "Backup created: app.asar.bak"
}

# Download directly using Invoke-WebRequest (pre-signed URL handles redirects)
try {
    Write-Host "Downloading app.asar (large file, please wait)..."
    Invoke-WebRequest -Uri $AsarUrl -OutFile $TargetAsar -UseBasicParsing -Verbose
    Write-Host "app.asar replaced successfully."
} catch {
    Write-Error "Failed to download app.asar. Check your internet connection or URL."
    if (Test-Path $BackupAsar) {
        Copy-Item $BackupAsar $TargetAsar -Force
        Write-Host "Backup restored."
    }
}
