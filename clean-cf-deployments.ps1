param(
    [Parameter(Mandatory=$false)][string]$accountId = "",
    [Parameter(Mandatory=$false)][string]$projectName = "",
    [Parameter(Mandatory=$false)][string]$apiToken = ""
)

$headers = @{
    "Authorization" = "Bearer $apiToken"
    "Content-Type"  = "application/json"
}

$listUrl = "https://api.cloudflare.com/client/v4/accounts/$accountId/pages/projects/$projectName/deployments?per_page=25&page=1"
$firstPage = Invoke-RestMethod -Uri $listUrl -Headers $headers -Method Get

if (-not $firstPage.result -or $firstPage.result.Count -eq 0) {
    Write-Host "No deployments found."
    exit
}

$activeId = $firstPage.result[0].id
$deletedCount = 0

while ($true) {
    $res = Invoke-RestMethod -Uri $listUrl -Headers $headers -Method Get
    $items = $res.result | Where-Object { $_.id -ne $activeId }

    if (-not $items -or $items.Count -eq 0) {
        break
    }

    foreach ($d in $items) {
        $delUrl = "https://api.cloudflare.com/client/v4/accounts/$accountId/pages/projects/$projectName/deployments/$($d.id)"
        try {
            Invoke-RestMethod -Uri $delUrl -Headers $headers -Method Delete
            $deletedCount++
            Write-Host "[$deletedCount] Deleted: $($d.short_id)" -ForegroundColor Green
        } catch {
            Write-Host "Failed: $($d.short_id)" -ForegroundColor Red
        }
    }
}

Write-Host "Completed. Total deleted: $deletedCount (Kept active: $activeId)" -ForegroundColor Cyan
