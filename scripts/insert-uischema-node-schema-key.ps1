$uid = if ($args.Length -gt 0) { $args[0] } else { "0kmslwagwde" }
$b = @{ account = 'admin'; password = 'admin123' } | ConvertTo-Json
$l = Invoke-RestMethod -Uri "https://omnia-app-production.up.railway.app/api/auth:signIn" -Method Post -ContentType "application/json" -Body $b
$h = @{ Authorization = ("Bearer " + $l.data.token) }
$newUid = ($uid + "_child_" + [DateTimeOffset]::UtcNow.ToUnixTimeSeconds())
$payload = @{
  schema = @{
    type = "void"
    "x-uid" = $newUid
    name = $newUid
    title = ("Child " + $newUid)
    "x-component" = "CardItem"
  }
}
$json = $payload | ConvertTo-Json -Depth 20
Invoke-WebRequest -UseBasicParsing -Uri ("https://omnia-app-production.up.railway.app/api/uiSchemas:insertAdjacent/" + $uid + "?position=afterBegin") -Method Post -Headers $h -ContentType "application/json" -Body $json | Select-Object -ExpandProperty Content | Set-Content -Path "scripts/insert-uischema-node-schema-key-output.json"
