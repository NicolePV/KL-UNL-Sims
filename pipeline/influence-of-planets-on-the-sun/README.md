# Influence of Planets on the Sun Explorer — HTML5

**This simulation must be served over HTTP. It will not run from a double-clicked
`index.html` (a `file://` path).**

## Why

The page uses the shared KL-UNL masthead component (`foundation/kl-unl-masthead.js`),
which loads the simulation's title and its Help / About text with
`fetch('foundation/contents.json')`. Browsers block `fetch()` of local files under
the `file://` protocol (same-origin policy), so opening `index.html` directly gives
an empty or broken masthead — no title, no Reset, no Help, no About. The exported
SVG artwork in `assets/` is drawn onto the canvas through `<img>` elements and is
subject to the same restriction in some browsers.

There is no MathJax and no webfont: the original simulation shows no equations or
mathematical notation, so every number is plain sans-serif text.

Served over HTTP everything resolves normally and the simulation loads.

## How to run it locally

Run one of these **from inside this `html5/` folder**, then open
<http://localhost:8123/>:

Python:

```bash
python3 -m http.server 8123
```

Node:

```bash
npx serve
```

Windows PowerShell (no Python or Node needed — `serve.ps1` ships with this folder):

```bash
powershell -ExecutionPolicy Bypass -File serve.ps1 8123
```

VS Code: install the **Live Server** extension, right-click `index.html`, and choose
*Open with Live Server*.

Because the server root is this folder, the simulation is at
<http://localhost:8123/> — not `.../html5/index.html`.

## Production

When deployed to the cloud host (served over HTTP/HTTPS) it simply works. The
`file://` limitation only affects double-clicking the file locally.

## What is in this folder

| Path | What it is |
| --- | --- |
| `index.html` | The KL-UNL page scaffold: `.app-shell`, `<kl-unl-masthead>`, panels |
| `foundation/` | The shared KL-UNL files, copied in unchanged (see `CONVERSION_NOTES.md` for the one content edit) |
| `styles/styles.css` | Sim-specific styling only; shared style comes from `foundation/kl-unl.css` |
| `simulation.js` | All simulation logic, ported from the decompiled ActionScript |
| `assets/` | The exported Flash artwork, reused as-is (not redrawn) |
| `serve.ps1` | Small static file server for local testing on Windows |
| `CONVERSION_NOTES.md` | Behaviour model, ActionScript → HTML5 mapping, deviations |
| `ACCESSIBILITY.md` | WCAG 2.1 AA affordances, keyboard map, screen-reader wording |
| `fla/` | The original Flash material this was converted from: `ca_extrasolarplanets_starwobble.swf` and its JPEXS/FFDec decompilation (`scripts/`, `shapes/`, `sprites/`, `texts/`, `fonts/`, …), plus the reference screenshot. Kept for provenance; nothing in the simulation loads from it. |

No build step, no bundler, no framework, no CDN. The only network requests are to
files inside this folder.
