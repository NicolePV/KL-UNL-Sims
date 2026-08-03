# Supernova Light Curve Fitting Explorer (Accessible HTML5)

**This simulation must be served over HTTP — it will NOT run from a
double-clicked `index.html` (`file://`) path.**

**Why:** the KL-UNL masthead component (`foundation/kl-unl-masthead.js`)
loads the sim's title and About text with
`fetch("foundation/contents.json")`. Browsers block `fetch()` of local
files under the `file://` protocol for security (same-origin policy), so
opening `index.html` directly shows an empty or broken masthead.

## How to run locally

Run one of these from **inside this `html5/` folder**, then open the URL:

```
# Python
python3 -m http.server 8123        # then open http://localhost:8123/

# Node
npx serve                          # or: npx http-server

# VS Code
use the "Live Server" extension on index.html
```

(The sim is at the server root when you serve from inside `html5/`, so the
URL is `http://localhost:8123/` — not `.../html5/index.html`.)

## Production

When deployed to the cloud host (served over HTTP/HTTPS) it just works;
the `file://` limitation only affects local double-clicking.

## What's here

- `index.html` — KL-UNL scaffold (masthead + Light Curve Plot and Distance
  Modulus Calculator panels)
- `simulation.js` — all sim logic (verbatim physics/data from the original
  ActionScript)
- `styles/styles.css` — sim-specific styles layered on the foundation
- `foundation/` — shared KL-UNL files, copied in unchanged (plus this
  sim's `contents.json` entry)
- `assets/snData.js` — the 13 supernovae's observation data, transcribed
  mechanically from the decompiled source
- `assets/mathjax/` — locally vendored MathJax (no CDN; everything is
  self-contained)
- `CONVERSION_NOTES.md` / `ACCESSIBILITY.md` — conversion and
  accessibility documentation
