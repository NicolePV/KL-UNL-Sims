# Minimal static file server for local development of this sim.
# Usage:  powershell -ExecutionPolicy Bypass -File serve.ps1 [-Port 8123]
# Then open the printed URL (e.g. http://localhost:8123/). Serve from THIS
# folder so the sim sits at the server root. Ctrl+C to stop.
param([int]$Port = 8123)

$root = Split-Path -Parent $MyInvocation.MyCommand.Path
$prefix = "http://localhost:$Port/"
$listener = New-Object System.Net.HttpListener
$listener.Prefixes.Add($prefix)

$mime = @{
  ".html"="text/html; charset=utf-8"; ".js"="text/javascript; charset=utf-8";
  ".mjs"="text/javascript; charset=utf-8"; ".css"="text/css; charset=utf-8";
  ".json"="application/json; charset=utf-8"; ".png"="image/png"; ".jpg"="image/jpeg";
  ".jpeg"="image/jpeg"; ".svg"="image/svg+xml"; ".woff"="font/woff"; ".woff2"="font/woff2";
  ".ttf"="font/ttf"; ".map"="application/json"; ".wasm"="application/wasm"
}

try { $listener.Start() }
catch { Write-Host "Could not start on $prefix - try a different -Port. $_"; exit 1 }
Write-Host "Serving '$root'"
Write-Host "Open  $prefix   (Ctrl+C to stop)"

while ($listener.IsListening) {
  try {
    $ctx = $listener.GetContext()
  } catch { break }
  $rel = [System.Uri]::UnescapeDataString($ctx.Request.Url.AbsolutePath.TrimStart('/'))
  if ([string]::IsNullOrEmpty($rel)) { $rel = "index.html" }
  $path = Join-Path $root $rel
  if ((Test-Path $path) -and -not (Get-Item $path).PSIsContainer) {
    $ext = [System.IO.Path]::GetExtension($path).ToLower()
    $ct = $mime[$ext]; if (-not $ct) { $ct = "application/octet-stream" }
    $ctx.Response.ContentType = $ct
    $ctx.Response.Headers.Add("Cache-Control", "no-store, no-cache, must-revalidate")
    $bytes = [System.IO.File]::ReadAllBytes($path)
    $ctx.Response.ContentLength64 = $bytes.Length
    $ctx.Response.OutputStream.Write($bytes, 0, $bytes.Length)
  } else {
    $ctx.Response.StatusCode = 404
    $msg = [System.Text.Encoding]::UTF8.GetBytes("404 Not Found: $rel")
    $ctx.Response.OutputStream.Write($msg, 0, $msg.Length)
  }
  $ctx.Response.OutputStream.Close()
}
$listener.Stop()
