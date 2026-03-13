$uid = $args[0]
if (-not $uid) { $uid = "crm_leads_menu" }
$b = @{ account = 'admin'; password = 'admin123' } | ConvertTo-Json
$l = Invoke-RestMethod -Uri "https://omnia-app-production.up.railway.app/api/auth:signIn" -Method Post -ContentType "application/json" -Body $b
$h = @{ Authorization = ("Bearer " + $l.data.token); "Content-Type" = "application/json" }
$newUid = ($uid + "_child_" + [DateTimeOffset]::UtcNow.ToUnixTimeSeconds())
$payload = @{
  schema = @{
    type = "void"
    "x-uid" = $newUid
    name = $newUid
    title = "Loaded " + $uid
    "x-component" = "CardItem"
  }
} | ConvertTo-Json -Depth 15
Invoke-RestMethod -Uri ("https://omnia-app-production.up.railway.app/api/uiSchemas:insertAdjacent/" + $uid + "?position=afterBegin") -Headers $h -Method Post -Body $payload | ConvertTo-Json -Depth 20 | Set-Content -Path "scripts/insert-uischema-node-output.json"
