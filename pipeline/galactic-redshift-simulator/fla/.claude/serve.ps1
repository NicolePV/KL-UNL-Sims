# Static file server for the Galactic Redshift Simulator (html5/).
#
# Why PowerShell and not `python3 -m http.server` / `npx serve`?
# Neither exists on this machine: node/npm/npx are not installed, and the
# python.exe / python3.exe on PATH are 0-byte Microsoft Store alias stubs, not
# interpreters. This uses System.Net.HttpListener, which is built into Windows.
#
# The sim MUST be served over HTTP: the KL-UNL masthead fetches
# foundation/contents.json, and browsers block fetch() over file://.
# See html5/README.md.
#
# Serving html5/ as the document root means the sim is at the server ROOT,
# i.e. http://localhost:8123/ -- matching what README.md tells users.
#
# NOTE: every path operation uses -LiteralPath. The project folder name
# contains "[2]", and PowerShell would otherwise treat those brackets as a
# wildcard character class and fail to resolve the path.

# Port 8180, not 8123: Windows has 8123 in its TCP excluded-port ranges on this
# machine (`netsh int ipv4 show excludedportrange protocol=tcp`), so nothing can
# bind it. 8145 and 8155 are excluded too. If 8180 ever becomes excluded as
# well, pick another free port here and in .claude/launch.json, or set
# "autoPort": true in launch.json to let the OS assign one.
param(
  [string]$Root = (Join-Path $PSScriptRoot '..\html5'),
  [int]$Port = 8180
)

$ErrorActionPreference = 'Stop'

if (-not (Test-Path -LiteralPath $Root)) {
  Write-Host "ERROR: document root not found: $Root"
  exit 1
}
$Root = (Resolve-Path -LiteralPath $Root).Path

$listener = New-Object System.Net.HttpListener
$listener.Prefixes.Add("http://localhost:$Port/")

try {
  $listener.Start()
} catch {
  Write-Host "ERROR: could not bind http://localhost:$Port/ -- $($_.Exception.Message)"
  Write-Host "Another server may already be running on that port."
  exit 1
}

Write-Host "Serving $Root"
Write-Host "Ready on http://localhost:$Port/"

$mime = @{
  '.html' = 'text/html; charset=utf-8'
  '.js'   = 'text/javascript; charset=utf-8'
  '.css'  = 'text/css; charset=utf-8'
  '.json' = 'application/json; charset=utf-8'
  '.md'   = 'text/markdown; charset=utf-8'
  '.svg'  = 'image/svg+xml'
  '.png'  = 'image/png'
  '.jpg'  = 'image/jpeg'
  '.jpeg' = 'image/jpeg'
  '.gif'  = 'image/gif'
  '.ico'  = 'image/x-icon'
  '.woff' = 'font/woff'
  '.woff2'= 'font/woff2'
  '.ttf'  = 'font/ttf'
  '.map'  = 'application/json; charset=utf-8'
}

while ($listener.IsListening) {
  try {
    $ctx = $listener.GetContext()
    $rel = [System.Uri]::UnescapeDataString($ctx.Request.Url.AbsolutePath).TrimStart('/')
    if ($rel -eq '') { $rel = 'index.html' }

    $path = Join-Path $Root ($rel -replace '/', '\')

    # Refuse anything that escapes the document root (e.g. ../../secrets).
    $full = [System.IO.Path]::GetFullPath($path)
    if (-not $full.StartsWith($Root, [System.StringComparison]::OrdinalIgnoreCase)) {
      $ctx.Response.StatusCode = 403
      $body = [System.Text.Encoding]::UTF8.GetBytes('403 forbidden')
      $ctx.Response.ContentLength64 = $body.Length
      $ctx.Response.OutputStream.Write($body, 0, $body.Length)
      $ctx.Response.OutputStream.Close()
      Write-Host "403 $rel"
      continue
    }

    if ((Test-Path -LiteralPath $full) -and (Get-Item -LiteralPath $full).PSIsContainer) {
      $full = Join-Path $full 'index.html'
    }

    if (Test-Path -LiteralPath $full) {
      $bytes = [System.IO.File]::ReadAllBytes($full)
      $ext = [System.IO.Path]::GetExtension($full).ToLowerInvariant()
      $ctx.Response.ContentType = if ($mime.ContainsKey($ext)) { $mime[$ext] } else { 'application/octet-stream' }
      # Dev server: never cache, so edits show up on reload.
      $ctx.Response.Headers.Add('Cache-Control', 'no-store, no-cache, must-revalidate')
      $ctx.Response.StatusCode = 200
      # Set Content-Length explicitly. Without it HttpListener can commit a
      # length of its own choosing and then reject the write with
      # "Bytes to be written to the stream exceed the Content-Length".
      $ctx.Response.ContentLength64 = $bytes.Length
      if ($ctx.Request.HttpMethod -ne 'HEAD') {
        $ctx.Response.OutputStream.Write($bytes, 0, $bytes.Length)
      }
      Write-Host "200 $rel"
    } else {
      $ctx.Response.StatusCode = 404
      $body = [System.Text.Encoding]::UTF8.GetBytes("404 not found: $rel")
      $ctx.Response.ContentType = 'text/plain; charset=utf-8'
      $ctx.Response.ContentLength64 = $body.Length
      if ($ctx.Request.HttpMethod -ne 'HEAD') {
        $ctx.Response.OutputStream.Write($body, 0, $body.Length)
      }
      Write-Host "404 $rel"
    }

    $ctx.Response.OutputStream.Close()
  } catch {
    Write-Host "ERR $($_.Exception.Message)"
  }
}
