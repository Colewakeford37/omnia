$ErrorActionPreference = 'Stop'

$base = 'https://omnia-app-production.up.railway.app'
$path = if ($args.Length -gt 0) { $args[0] } else { '/admin/crm_leads_menu' }
$url = if ($path.StartsWith('http')) { $path } else { ($base + $path) }

$resp = Invoke-WebRequest -UseBasicParsing -Uri $url -Method Get
$html = $resp.Content

Set-Content -Path 'scripts/admin-diagnose-url.txt' -Value $url
Set-Content -Path 'scripts/admin-diagnose-head.html' -Value ($html.Substring(0, [Math]::Min(800, $html.Length)))

$scriptMatches = [regex]::Matches($html, '<script[^>]+src="([^"]+)"', 'IgnoreCase')
$linkMatches = [regex]::Matches($html, '<link[^>]+href="([^"]+)"', 'IgnoreCase')

$assets = New-Object System.Collections.Generic.List[string]
foreach ($m in $scriptMatches) { $assets.Add($m.Groups[1].Value) }
foreach ($m in $linkMatches) { $assets.Add($m.Groups[1].Value) }

$assets = $assets | Where-Object { $_ -and ($_ -notmatch '^https?://') } | Select-Object -Unique
Set-Content -Path 'scripts/admin-diagnose-assets.txt' -Value ($assets -join "`n")

$results = @()
foreach ($a in $assets) {
  $assetUrl = if ($a.StartsWith('/')) { $base + $a } else { $base + '/admin/' + $a }
  try {
    $r = Invoke-WebRequest -UseBasicParsing -Uri $assetUrl -Method Get
    $results += [pscustomobject]@{
      url = $assetUrl
      status = [int]$r.StatusCode
      length = [int]$r.RawContentLength
    }
  } catch {
    $code = 0
    if ($_.Exception.Response) {
      $code = [int]$_.Exception.Response.StatusCode
    }
    $results += [pscustomobject]@{
      url = $assetUrl
      status = $code
      length = 0
    }
  }
}

$json = $results | Sort-Object status, url | ConvertTo-Json -Depth 3
Set-Content -Path 'scripts/admin-diagnose-assets-status.json' -Value $json

($results | Where-Object { $_.status -ne 200 }).Count
