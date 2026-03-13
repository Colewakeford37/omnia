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

function Get-JsonData {
  param([string]$Body)
  if (-not $Body) { return $null }
  try {
    $obj = $Body | ConvertFrom-Json
    return $obj.data
  } catch {
    return $null
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
  $rootSchema = @{
    type = "void"
    "x-uid" = $uid
    name = $uid
    title = ("Page " + $uid)
    "x-component" = "Grid"
    "x-async" = $false
  }

  $updatePayload = @{
    name = $uid
    schema = $rootSchema
  }
  $update = Invoke-JsonPost -Uri "$baseUrl/api/uiSchemas:update/$uid" -Headers $headers -BodyObj $updatePayload

  $childUid = ($uid + "_child_" + [DateTimeOffset]::UtcNow.ToUnixTimeSeconds())
  $insertPayload = @{
    schema = @{
      type = "void"
      "x-uid" = $childUid
      name = $childUid
      title = ("Loaded " + $uid)
      "x-component" = "CardItem"
    }
  }
  $insertUri = ($baseUrl + "/api/uiSchemas:insertAdjacent/" + $uid + "?position=afterBegin")
  $insert = Invoke-JsonPost -Uri $insertUri -Headers $headers -BodyObj $insertPayload

  Start-Sleep -Milliseconds 120
  $getSchema = Invoke-JsonGet -Uri "$baseUrl/api/uiSchemas:getJsonSchema/$uid" -Headers $headers
  $data = Get-JsonData -Body $getSchema.body
  $hasData = $null -ne $data
  $hasProperties = $false
  $hasInsertedChild = $false
  if ($hasData -and $data.properties) {
    $hasProperties = ($data.properties.PSObject.Properties.Count -gt 0)
    $hasInsertedChild = $null -ne ($data.properties.PSObject.Properties | Where-Object { $_.Name -eq $childUid })
  }

  $results += [pscustomobject]@{
    uid = $uid
    updateOk = $update.ok
    updateStatus = $update.status
    insertOk = $insert.ok
    insertStatus = $insert.status
    insertedChildUid = $childUid
    getSchemaOk = $getSchema.ok
    getSchemaStatus = $getSchema.status
    hasData = $hasData
    hasProperties = $hasProperties
    hasInsertedChild = $hasInsertedChild
    insertBodySnippet = if ($insert.body) { $insert.body.Substring(0, [Math]::Min(280, $insert.body.Length)) } else { "" }
    getBodySnippet = if ($getSchema.body) { $getSchema.body.Substring(0, [Math]::Min(280, $getSchema.body.Length)) } else { "" }
  }
}

$summary = [pscustomobject]@{
  total = $results.Count
  updatesPassed = ($results | Where-Object { $_.updateOk }).Count
  insertsPassed = ($results | Where-Object { $_.insertOk }).Count
  schemaReadsPassed = ($results | Where-Object { $_.getSchemaOk -and $_.hasData }).Count
  childNodesPresent = ($results | Where-Object { $_.hasInsertedChild }).Count
}

[pscustomobject]@{
  summary = $summary
  results = $results
} | ConvertTo-Json -Depth 40 | Set-Content -Path "scripts/repair-crm-ui-via-actions-output.json"

$summary | ConvertTo-Json -Depth 10
