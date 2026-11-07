# Eclipsing Binary Simulator (Accessible HTML5)

**Live: https://sy-xia.github.io/eclipsing-binary-simulator/**

An accessible HTML5 rebuild of the legacy Flash "Eclipsing Binary Simulator"
(NAAP), built on the shared KL-UNL foundation.

This simulation **must be served over HTTP — it will not run from a
double-clicked `index.html` (`file://`) path.**

**Why:** the KL-UNL masthead component (`foundation/kl-unl-masthead.js`) loads
the sim's title, Help, and About text with
`fetch('foundation/contents.json')`. Browsers block `fetch()` of local files
under the `file://` protocol for security (same-origin policy), so opening
`index.html` directly shows an empty or broken masthead.

## How to run locally

Run one of these from inside the `html5/` folder, then open
**http://localhost:8123/** (note: the sim is at the server root when you serve
from inside `html5/`, so the URL is `http://localhost:8123/`, not
`.../html5/index.html`):

```bash
python3 -m http.server 8123
```

```bash
npx serve
```

(or `npx http-server`), or use the **Live Server** extension in VS Code.

## Production

When deployed to the cloud host (served over HTTP/HTTPS) it just works; the
`file://` limitation only affects local double-clicking.

## Contents

- `index.html` — KL-UNL shell (masthead + panels)
- `simulation.js` — all simulation logic (port of the decompiled ActionScript)
- `styles/styles.css` — sim-specific styles layered on the KL-UNL foundation
- `foundation/` — shared KL-UNL files (copied in unchanged; the only content
  edit is this sim's entry in `contents.json`) plus the self-hosted MathJax
- `assets/` — exported Flash assets reused as-is (observed-data light curve
  bitmaps, HR-diagram background, center-of-mass marker)
- `CONVERSION_NOTES.md` — behavior model, AS→HTML5 mapping, deviations
- `ACCESSIBILITY.md` — WCAG affordances, keyboard map, screen-reader notes
- `fla/` — ARCHIVE: the original `binSys097.swf` and its decompiled source
  (ActionScript, shapes, sprites, images, texts, fonts) plus a screenshot of
  the running Flash original. Nothing here is needed to run the sim; it is
  reference material for verifying the conversion.

The HTML5 sim lives at the repository root so GitHub Pages serves it directly.
