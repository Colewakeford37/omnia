$uid = if ($args.Length -gt 0) { $args[0] } else { "crm_leads_menu" }
$b = @{ account = 'admin'; password = 'admin123' } | ConvertTo-Json
$l = Invoke-RestMethod -Uri "https://omnia-app-production.up.railway.app/api/auth:signIn" -Method Post -ContentType "application/json" -Body $b
$h = @{ Authorization = ("Bearer " + $l.data.token) }
$r = Invoke-RestMethod -Uri ("https://omnia-app-production.up.railway.app/api/uiSchemas:getJsonSchema/" + $uid) -Headers $h -Method Get
$r | ConvertTo-Json -Depth 20 | Set-Content -Path "scripts/check-uischema-output.json"
