$ErrorActionPreference = 'Stop'

function Post-Api {
  param([string]$Uri,[hashtable]$Headers,[object]$BodyObj)
  $body = $BodyObj | ConvertTo-Json -Depth 30
  try {
    $r = Invoke-WebRequest -UseBasicParsing -Uri $Uri -Method Post -Headers $Headers -ContentType "application/json" -Body $body
    [pscustomobject]@{ uri = $Uri; ok = $true; status = [int]$r.StatusCode; body = $r.Content }
  } catch {
    $status = 0
    $txt = $_.Exception.Message
    if ($_.Exception.Response) {
      $status = [int]$_.Exception.Response.StatusCode
      $sr = New-Object IO.StreamReader($_.Exception.Response.GetResponseStream())
      $txt = $sr.ReadToEnd()
    }
    [pscustomobject]@{ uri = $Uri; ok = $false; status = $status; body = $txt }
  }
}

$b = @{ account = 'admin'; password = 'admin123' } | ConvertTo-Json
$l = Invoke-RestMethod -Uri "https://omnia-app-production.up.railway.app/api/auth:signIn" -Method Post -ContentType "application/json" -Body $b
$h = @{ Authorization = ("Bearer " + $l.data.token) }
$base = "https://omnia-app-production.up.railway.app/api"
$uid = "test-jsonschema-probe"

$payloads = @(
  @{ uri = "$base/uiSchemas:update"; body = @{ filterByTk = $uid; values = @{ title = "Probe A"; type = "void" } } },
  @{ uri = "$base/uiSchemas:setJsonSchema"; body = @{ filterByTk = $uid; values = @{ type = "void"; title = "Probe B"; "x-component" = "CardItem" } } },
  @{ uri = "$base/uiSchemas:insertAdjacent"; body = @{ filterByTk = $uid; position = "afterBegin"; data = @{ type = "void"; title = "Probe C"; "x-component" = "CardItem" } } }
)

$out = @()
foreach ($p in $payloads) {
  $out += Post-Api -Uri $p.uri -Headers $h -BodyObj $p.body
}

$out | ConvertTo-Json -Depth 20 | Set-Content -Path "scripts/probe-uischema-actions-output.json"
