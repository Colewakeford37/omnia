$b = @{ account = 'admin'; password = 'admin123' } | ConvertTo-Json
$l = Invoke-RestMethod -Uri "https://omnia-app-production.up.railway.app/api/auth:signIn" -Method Post -ContentType "application/json" -Body $b
$h = @{ Authorization = ("Bearer " + $l.data.token) }
$r = Invoke-RestMethod -Uri "https://omnia-app-production.up.railway.app/api/collections:listMeta" -Headers $h -Method Post
($r.data | Where-Object { $_.name -eq 'crm_leads' }) | ConvertTo-Json -Depth 25 | Set-Content -Path "scripts/check-collection-meta-output.json"
