# Photometry Simulator (Accessible HTML5)

**This sim must be served over HTTP — it will NOT run from a double-clicked
`index.html` (`file://`) path.**

**Why:** the KL-UNL masthead component (`foundation/kl-unl-masthead.js`) loads
the sim's title, Help, and About text with
`fetch('foundation/contents.json')`. Browsers block `fetch()` of local files
under the `file://` protocol for security (same-origin policy), so opening
`index.html` directly shows an empty or broken masthead.

## How to run locally

Run any static HTTP server **from inside this `html5/` folder**, then open the
printed URL:

```
Python:      python3 -m http.server 8123        then open http://localhost:8123/
Node:        npx serve                          (or: npx http-server)
PowerShell:  powershell -ExecutionPolicy Bypass -File serve.ps1 8123
             (a minimal static server, included, for machines without
             Python or Node)
VS Code:     the "Live Server" extension (Open with Live Server on index.html)
```

Note: because you serve from inside `html5/`, the sim is at the server root —
the URL is `http://localhost:8123/`, **not** `.../html5/index.html`.

## Production

When deployed to the cloud host (served over HTTP/HTTPS) it just works; the
`file://` limitation only affects local double-clicking.

## Contents

- `index.html` — KL-UNL scaffold (masthead + panels)
- `foundation/` — shared KL-UNL foundation files, copied in unchanged
  (plus a self-hosted MathJax under `foundation/mathjax/` — no CDN)
- `styles/styles.css` — sim-specific styles only
- `simulation.js` — all simulation logic
- `assets/` — exported Flash art reused as-is (pixel-info balloon)
- `CONVERSION_NOTES.md` — behavior model, AS→JS mapping, deviations
- `ACCESSIBILITY.md` — WCAG affordances, keyboard map, screen-reader notes
