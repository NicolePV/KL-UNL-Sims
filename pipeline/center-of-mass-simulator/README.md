# Center of Mass Simulator (HTML5)

**▶ [Run the simulator](https://sy-xia.github.io/center-of-mass-simulator/)**

HTML5 port of `centerOfMass009.swf`, built on the shared KL-UNL foundation.

## Repository layout

| Path | What it is |
| --- | --- |
| `/` (repo root) | the HTML5 simulator — this is what GitHub Pages serves |
| `fla/` | the decompiled Flash source it was ported from (JPEXS/FFDec export of the original SWF), kept for reference |

The port's behaviour was taken from `fla/scripts/`, its geometry checked against
`fla/Capture.PNG` (a screenshot of the running Flash original), and its art
reused as-is from `fla/shapes/`. See CONVERSION_NOTES.md for the full mapping
and ACCESSIBILITY.md for the WCAG work.

## This sim must be served over HTTP. Double-clicking `index.html` will not work.

**Why.** The KL-UNL masthead component (`foundation/kl-unl-masthead.js`) loads the
simulation title and the Help / About text with
`fetch('foundation/contents.json')`. Browsers block `fetch()` of local files under
the `file://` protocol for security (same-origin policy), so opening
`index.html` straight from the file system leaves the masthead empty and logs a
fetch error to the console. Served over HTTP the fetch succeeds and everything
loads normally.

## How to run it locally

Serve **from inside this `html5/` folder**, so the sim sits at the server root.

Windows PowerShell (a tiny static server is included):

```bash
powershell -ExecutionPolicy Bypass -File serve.ps1
```

Python:

```bash
python3 -m http.server 8123
```

Node:

```bash
npx serve
```

VS Code: install the **Live Server** extension and use "Open with Live Server"
on `index.html`.

Then open the printed URL — with the Python example above that is
<http://localhost:8123/>, **not** `.../html5/index.html`, because the server root
is already this folder.

## Production

Deployed to the cloud host over HTTP/HTTPS it just works. The `file://`
limitation only affects local double-clicking.

## What is in here

| Path | What it is |
| --- | --- |
| `index.html` | Page scaffold: `.app-shell`, `<kl-unl-masthead>`, and the three panels |
| `foundation/` | Shared KL-UNL files, copied in unchanged (see note below) |
| `foundation/mathjax/` | Vendored MathJax 3.2.2 (`tex-mml-chtml`) — no CDN |
| `styles/styles.css` | Sim-specific styles only; the foundation is never edited |
| `simulation.js` | All simulation logic |
| `assets/shapes/` | Exported Flash art, reused as-is |
| `CONVERSION_NOTES.md` | Behaviour model, AS → HTML5 mapping, deviations |
| `ACCESSIBILITY.md` | WCAG affordances, keyboard map, colour remaps |
| `serve.ps1` | Minimal static file server for local development |

The code of `kl-unl-masthead.js`, `kl-unl.css` and `kl-unl.js` is byte-for-byte
identical to the copies in the sim folder's `foundation/`. `contents.json` has
this sim's `help` and `about` text updated plus a handful of JSON syntax repairs
that were needed to make the file parse at all — see CONVERSION_NOTES.md, "The
contents.json entry".

No build step, no bundler, no framework, no CDN, no analytics. The only network
requests the page makes are for its own local files.
