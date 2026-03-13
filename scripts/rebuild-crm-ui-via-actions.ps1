$ErrorActionPreference = 'Stop'

function Invoke-JsonPost {
  param(
    [string]$Uri,
    [hashtable]$Headers,
    [object]$BodyObj
  )
  $bodyJson = $BodyObj | ConvertTo-Json -Depth 30
  try {
    $resp = Invoke-WebRequest -UseBasicParsing -Uri $Uri -Method Post -Headers $Headers -ContentType "application/json" -Body $bodyJson
    return [pscustomobject]@{
      ok = $true
      status = [int]$resp.StatusCode
      body = $resp.Content
    }
  } catch {
    $status = 0
    $txt = $_.Exception.Message
    if ($_.Exception.Response) {
      $status = [int]$_.Exception.Response.StatusCode
      $sr = New-Object IO.StreamReader($_.Exception.Response.GetResponseStream())
      $txt = $sr.ReadToEnd()
    }
    return [pscustomobject]@{
      ok = $false
      status = $status
      body = $txt
    }
  }
}

function Invoke-JsonGet {
  param(
    [string]$Uri,
    [hashtable]$Headers
  )
  try {
    $resp = Invoke-WebRequest -UseBasicParsing -Uri $Uri -Method Get -Headers $Headers
    return [pscustomobject]@{
      ok = $true
      status = [int]$resp.StatusCode
      body = $resp.Content
    }
  } catch {
    $status = 0
    $txt = $_.Exception.Message
    if ($_.Exception.Response) {
      $status = [int]$_.Exception.Response.StatusCode
      $sr = New-Object IO.StreamReader($_.Exception.Response.GetResponseStream())
      $txt = $sr.ReadToEnd()
    }
    return [pscustomobject]@{
      ok = $false
      status = $status
      body = $txt
    }
  }
}

$baseUrl = "https://omnia-app-production.up.railway.app"
$creds = @{ account = 'admin'; password = 'admin123' } | ConvertTo-Json
$login = Invoke-RestMethod -Uri "$baseUrl/api/auth:signIn" -Method Post -ContentType "application/json" -Body $creds
$token = $login.data.token
$headers = @{ Authorization = ("Bearer " + $token) }

$uids = @(
  "crm_dashboard",
  "crm_leads_menu",
  "crm_contacts_menu",
  "crm_properties_menu",
  "crm_deals_menu",
  "crm_suburbs_menu",
  "crm_fica_menu",
  "crm_activities_menu",
  "crm_email_templates_menu"
)

$results = @()
foreach ($uid in $uids) {
  $before = Invoke-JsonGet -Uri "$baseUrl/api/uiSchemas:getJsonSchema/$uid" -Headers $headers
  $beforeLen = 0
  if ($before.body) { $beforeLen = $before.body.Length }

  $childUid = ($uid + "_child_" + [DateTimeOffset]::UtcNow.ToUnixTimeSeconds())
  $insertPayload = @{
    schema = @{
      type = "void"
      "x-uid" = $childUid
      name = $childUid
      title = ("Content " + $uid)
      "x-component" = "CardItem"
    }
  }
  $insertUri = ($baseUrl + "/api/uiSchemas:insertAdjacent/" + $uid + "?position=afterBegin")
  $insert = Invoke-JsonPost -Uri $insertUri -Headers $headers -BodyObj $insertPayload

  Start-Sleep -Milliseconds 150
  $after = Invoke-JsonGet -Uri "$baseUrl/api/uiSchemas:getJsonSchema/$uid" -Headers $headers
  $afterLen = 0
  if ($after.body) { $afterLen = $after.body.Length }

  $results += [pscustomobject]@{
    uid = $uid
    beforeStatus = $before.status
    beforeBodyLength = $beforeLen
    insertStatus = $insert.status
    insertOk = $insert.ok
    insertedChildUid = $childUid
    afterStatus = $after.status
    afterBodyLength = $afterLen
    afterBody = $after.body
  }
}

$results | ConvertTo-Json -Depth 20 | Set-Content -Path "scripts/rebuild-crm-ui-via-actions-output.json"
