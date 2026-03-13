$ErrorActionPreference = 'Stop'

function Invoke-JsonPost {
  param([string]$Uri,[hashtable]$Headers,[object]$BodyObj)
  $bodyJson = $BodyObj | ConvertTo-Json -Depth 40
  try {
    $resp = Invoke-WebRequest -UseBasicParsing -Uri $Uri -Method Post -Headers $Headers -ContentType "application/json" -Body $bodyJson
    return [pscustomobject]@{ ok = $true; status = [int]$resp.StatusCode; body = $resp.Content }
  } catch {
    $status = 0
    $txt = $_.Exception.Message
    if ($_.Exception.Response) {
      $status = [int]$_.Exception.Response.StatusCode
      $sr = New-Object IO.StreamReader($_.Exception.Response.GetResponseStream())
      $txt = $sr.ReadToEnd()
    }
    return [pscustomobject]@{ ok = $false; status = $status; body = $txt }
  }
}

function Invoke-JsonGet {
  param([string]$Uri,[hashtable]$Headers)
  try {
    $resp = Invoke-WebRequest -UseBasicParsing -Uri $Uri -Method Get -Headers $Headers
    return [pscustomobject]@{ ok = $true; status = [int]$resp.StatusCode; body = $resp.Content }
  } catch {
    $status = 0
    $txt = $_.Exception.Message
    if ($_.Exception.Response) {
      $status = [int]$_.Exception.Response.StatusCode
      $sr = New-Object IO.StreamReader($_.Exception.Response.GetResponseStream())
      $txt = $sr.ReadToEnd()
    }
    return [pscustomobject]@{ ok = $false; status = $status; body = $txt }
  }
}

$baseUrl = "https://omnia-app-production.up.railway.app"
$creds = @{ account = 'admin'; password = 'admin123' } | ConvertTo-Json
$login = Invoke-RestMethod -Uri "$baseUrl/api/auth:signIn" -Method Post -ContentType "application/json" -Body $creds
$token = $login.data.token
$headers = @{ Authorization = ("Bearer " + $token) }

$defs = @(
  @{ uid = "crm_dashboard"; title = "Dashboard"; collection = "crm_leads"; columns = @("id","full_name","status","source","createdAt") },
  @{ uid = "crm_leads_menu"; title = "Leads"; collection = "crm_leads"; columns = @("id","full_name","email","phone","status","source","createdAt") },
  @{ uid = "crm_contacts_menu"; title = "Contacts"; collection = "crm_contacts"; columns = @("id","full_name","email","phone","company","createdAt") },
  @{ uid = "crm_properties_menu"; title = "Properties"; collection = "crm_properties"; columns = @("id","title","suburb","city","price","status","listing_date") },
  @{ uid = "crm_deals_menu"; title = "Deals"; collection = "crm_deals"; columns = @("id","title","stage","value","probability","expected_close_date") },
  @{ uid = "crm_suburbs_menu"; title = "Suburbs"; collection = "crm_suburbs"; columns = @("id","name","city","province","average_price","median_price") },
  @{ uid = "crm_fica_menu"; title = "FICA Compliance"; collection = "crm_fica_documents"; columns = @("id","document_type","document_number","status","created_at") },
  @{ uid = "crm_activities_menu"; title = "Activities"; collection = "crm_activities"; columns = @("id","activity_type","subject","status","start_date") },
  @{ uid = "crm_email_templates_menu"; title = "Email Templates"; collection = "crm_email_templates"; columns = @("id","template_name","template_type","is_active","updated_at") }
)

$results = @()
foreach ($def in $defs) {
  $uid = $def.uid
  $suffix = [DateTimeOffset]::UtcNow.ToUnixTimeSeconds()
  $blockUid = ($uid + "_block_" + $suffix)
  $tableUid = ($uid + "_table_" + $suffix)

  $updatePayload = @{
    name = $uid
    schema = @{
      type = "void"
      "x-uid" = $uid
      name = $uid
      title = $def.title
      "x-component" = "Grid"
    }
  }
  $update = Invoke-JsonPost -Uri ($baseUrl + "/api/uiSchemas:update/" + $uid) -Headers $headers -BodyObj $updatePayload

  $insertBlock = Invoke-JsonPost -Uri ($baseUrl + "/api/uiSchemas:insertAdjacent/" + $uid + "?position=afterBegin") -Headers $headers -BodyObj @{
    schema = @{
      type = "void"
      "x-uid" = $blockUid
      name = $blockUid
      "x-decorator" = "DataBlockProvider"
      "x-decorator-props" = @{
        dataSource = "main"
        collection = $def.collection
        action = "list"
        resource = $def.collection
      }
      "x-component" = "CardItem"
    }
  }

  $insertTable = Invoke-JsonPost -Uri ($baseUrl + "/api/uiSchemas:insertAdjacent/" + $blockUid + "?position=afterBegin") -Headers $headers -BodyObj @{
    schema = @{
      type = "array"
      "x-uid" = $tableUid
      name = $tableUid
      "x-component" = "TableV2"
      "x-component-props" = @{
        rowKey = "id"
        pagination = @{ pageSize = 20 }
      }
    }
  }

  $colResults = @()
  foreach ($col in $def.columns) {
    $colUid = ($uid + "_col_" + $col + "_" + $suffix)
    $r = Invoke-JsonPost -Uri ($baseUrl + "/api/uiSchemas:insertAdjacent/" + $tableUid + "?position=afterBegin") -Headers $headers -BodyObj @{
      schema = @{
        type = "void"
        "x-uid" = $colUid
        name = $colUid
        "x-component" = "TableV2.Column"
        "x-component-props" = @{
          dataIndex = $col
          title = $col
        }
      }
    }
    $colResults += $r
  }

  Start-Sleep -Milliseconds 150
  $schemaResp = Invoke-JsonGet -Uri ($baseUrl + "/api/uiSchemas:getJsonSchema/" + $uid) -Headers $headers
  $hasTable = $false
  if ($schemaResp.body -and $schemaResp.body.Contains('"x-component":"TableV2"')) { $hasTable = $true }
  $colsOk = ($colResults | Where-Object { $_.ok }).Count

  $results += [pscustomobject]@{
    uid = $uid
    updateOk = $update.ok
    insertBlockOk = $insertBlock.ok
    insertTableOk = $insertTable.ok
    columnInsertOkCount = $colsOk
    columnInsertTotal = $def.columns.Count
    schemaReadOk = $schemaResp.ok
    hasTableV2 = $hasTable
  }
}

$summary = [pscustomobject]@{
  total = $results.Count
  updated = ($results | Where-Object { $_.updateOk }).Count
  blocksInserted = ($results | Where-Object { $_.insertBlockOk }).Count
  tablesInserted = ($results | Where-Object { $_.insertTableOk }).Count
  schemaReads = ($results | Where-Object { $_.schemaReadOk }).Count
  tableVisibleSchemas = ($results | Where-Object { $_.hasTableV2 }).Count
}

[pscustomobject]@{ summary = $summary; results = $results } | ConvertTo-Json -Depth 30 | Set-Content -Path "scripts/rebuild-crm-pages-visible-via-actions-output.json"
$summary | ConvertTo-Json -Depth 10
