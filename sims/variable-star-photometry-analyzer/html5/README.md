# Variable Star Photometry Analyzer (Accessible HTML5)

**This simulation must be served over HTTP — it will NOT run from a
double-clicked `index.html` (`file://`) path.**

## Why

The KL-UNL masthead component (`foundation/kl-unl-masthead.js`) loads the
simulation title and the Help/About text with
`fetch('foundation/contents.json')`, and the simulation itself fetches its
data file (`assets/settings.xml`). Browsers block `fetch()` of local files
under the `file://` protocol for security (same-origin policy), so opening
`index.html` directly shows a broken masthead and the sim data never loads.

## How to run locally

Run one of these from **inside the `html5/` folder**, then open the printed
URL in your browser:

```
python3 -m http.server 8123
```
then open <http://localhost:8123/>

or with Node:

```
npx serve
```
(or `npx http-server`)

or in VS Code: install the **Live Server** extension and click "Go Live" with
`index.html` open.

Note: because you serve from inside `html5/`, the sim is at the server root —
the URL is `http://localhost:8123/`, **not** `.../html5/index.html`.

## Production

When deployed to the cloud host (served over HTTP/HTTPS) it just works; the
`file://` limitation only affects local double-clicking.

## Contents

- `index.html` — KL-UNL shell (masthead + panels)
- `foundation/` — shared KL-UNL foundation files (copied unchanged; only this
  sim's entry in `contents.json` was touched — see `CONVERSION_NOTES.md`)
- `simulation.js` — all simulation logic (ported from the decompiled AS3)
- `styles/styles.css` — sim-specific styles layered on the foundation
- `assets/` — reused exported assets (SVG shapes, fonts), the original
  `settings.xml` data file, and a self-hosted MathJax bundle
- `CONVERSION_NOTES.md` — behavior model, AS→HTML5 mapping, deviations
- `ACCESSIBILITY.md` — WCAG affordances, keyboard map, screen-reader notes
