# Radial Velocity Simulator — HTML5

**This sim must be served over HTTP — it will not run from a double-clicked
`index.html` (file:// path).**

## Why

The KL-UNL masthead component (`foundation/kl-unl-masthead.js`) loads the
page title and Help/About text via `fetch('foundation/contents.json')`.
Browsers block `fetch()` of local files under the `file://` protocol for
security (same-origin policy), so opening `index.html` directly by
double-clicking it shows an empty or broken masthead. Served over HTTP (a
local static server during development, or the production host) the fetch
succeeds and the sim loads normally.

## How to run it locally

From inside this `html5/` folder, start any static file server, then open
the printed URL (the sim is served at the **server root**, e.g.
`http://localhost:8123/` — not `.../html5/index.html`):

**Python:**
```
python3 -m http.server 8123
```

**Node:**
```
npx serve
```
or
```
npx http-server
```

**PowerShell (no external dependency required)** — a minimal static server
is included as `serve.ps1`:
```
powershell -ExecutionPolicy Bypass -File serve.ps1 8123
```

**VS Code:** the "Live Server" extension.

Then open `http://localhost:8123/`.

## Production

When deployed to the cloud host (served over HTTP/HTTPS), it just works —
the `file://` limitation only affects local double-clicking.

## MathJax

`foundation/mathjax/` ships a vendored copy of MathJax v3.2.2 (the
`tex-mml-chtml` combined component plus its `output/chtml/fonts/woff-v2/`
font files, ~22 files), fetched once from the official npm-backed jsdelivr
CDN and included as local static assets — the running page does **not**
call out to any CDN; every MathJax request in the browser network panel
resolves to a local `foundation/mathjax/...` path. This is what the shared
KL-UNL foundation deployment is expected to provide at that path; it's
vendored here because no other sim in this collection had populated it yet.
If `foundation/mathjax/tex-mml-chtml.js` is ever removed or replaced, the
sim still runs correctly and falls back to readable plain-text for every
value/unit instead of MathJax-typeset math.
