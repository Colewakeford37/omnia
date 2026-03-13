$uid = if ($args.Length -gt 0) { $args[0] } else { "crm_leads_menu" }
$b = @{ account = 'admin'; password = 'admin123' } | ConvertTo-Json
$l = Invoke-RestMethod -Uri "https://omnia-app-production.up.railway.app/api/auth:signIn" -Method Post -ContentType "application/json" -Body $b
$h = @{ Authorization = ("Bearer " + $l.data.token) }
$payload = @{
  name = $uid
  schema = @{
    type = "void"
    "x-uid" = $uid
    name = $uid
    title = ("Page " + $uid)
    "x-component" = "Grid"
    "x-async" = $false
  }
}
$json = $payload | ConvertTo-Json -Depth 20
Invoke-WebRequest -UseBasicParsing -Uri ("https://omnia-app-production.up.railway.app/api/uiSchemas:update/" + $uid) -Method Post -Headers $h -ContentType "application/json" -Body $json | Select-Object -ExpandProperty Content | Set-Content -Path "scripts/update-uischema-action-output.json"
