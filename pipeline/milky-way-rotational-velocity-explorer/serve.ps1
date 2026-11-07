# Minimal static file server for local testing of this simulation.
#
# The sim MUST be served over HTTP: the KL-UNL masthead fetches
# foundation/contents.json, and browsers block fetch() over file://.
#
# Usage (from inside the html5 folder):
#     powershell -ExecutionPolicy Bypass -File .\serve.ps1
# then open http://localhost:8123/

param([int]$Port = 8123)

$root = $PSScriptRoot
$types = @{
  '.html' = 'text/html; charset=utf-8'
  '.js'   = 'text/javascript; charset=utf-8'
  '.css'  = 'text/css; charset=utf-8'
  '.json' = 'application/json; charset=utf-8'
  '.svg'  = 'image/svg+xml'
  '.jpg'  = 'image/jpeg'
  '.jpeg' = 'image/jpeg'
  '.png'  = 'image/png'
  '.woff' = 'font/woff'
  '.woff2'= 'font/woff2'
  '.md'   = 'text/markdown; charset=utf-8'
}

$listener = New-Object System.Net.HttpListener
$listener.Prefixes.Add("http://localhost:$Port/")
$listener.Start()
Write-Host "Serving $root at http://localhost:$Port/  (Ctrl+C to stop)"

while ($listener.IsListening) {
  $context = $listener.GetContext()
  $path = [Uri]::UnescapeDataString($context.Request.Url.AbsolutePath)
  if ($path -eq '/') { $path = '/index.html' }
  $file = Join-Path $root ($path.TrimStart('/') -replace '/', '\')

  $context.Response.Headers.Add('Cache-Control', 'no-store')

  try {
    if (Test-Path -LiteralPath $file -PathType Leaf) {
      $ext = [IO.Path]::GetExtension($file).ToLower()
      if ($types.ContainsKey($ext)) { $context.Response.ContentType = $types[$ext] }
      $bytes = [IO.File]::ReadAllBytes($file)
      $context.Response.ContentLength64 = $bytes.Length

      # A HEAD response must carry the headers but no body; writing one raises
      # ProtocolViolationException.
      if ($context.Request.HttpMethod -ne 'HEAD') {
        $context.Response.OutputStream.Write($bytes, 0, $bytes.Length)
      }
    } else {
      $context.Response.StatusCode = 404
    }
  } catch {
    # The client hangs up mid-response all the time (navigating away, cancelled
    # image loads). That is normal and is not worth logging.
  }

  try { $context.Response.Close() } catch { }
}
