# Solar System Properties Explorer — HTML5

**This simulation must be served over HTTP. It will not run from a double-clicked `index.html` (a `file://` path).**

## Why

The KL-UNL masthead component (`foundation/kl-unl-masthead.js`, which must not be modified) loads
the simulation's title and its Help / About text with `fetch('foundation/contents.json')`. Browsers
block `fetch()` of local files under the `file://` protocol for security reasons (the same-origin
policy), so opening `index.html` directly gives you an empty or broken masthead — no title, no
Reset / Help / About buttons — and the console shows a CORS or "Failed to fetch" error.

Served over HTTP the fetch succeeds and the simulation loads normally.

## How to run it locally

Run one of these **from inside this `html5/` folder**:

Python (bundled with macOS and most Linux distributions; on Windows install from python.org):

```bash
python3 -m http.server 8123
```

Node:

```bash
npx serve
```

or

```bash
npx http-server -p 8123
```

VS Code: install the **Live Server** extension, right-click `index.html`, "Open with Live Server".

Then open <http://localhost:8123/> in your browser. Because the server root *is* this folder, the
simulation is at the root of the URL — `http://localhost:8123/`, **not**
`http://localhost:8123/html5/index.html`.

## Production

Once deployed to the cloud host it is served over HTTP/HTTPS like any other page, so it just works.
The `file://` limitation only affects opening the file locally by double-clicking it.

## What is in here

| Path | Purpose |
| --- | --- |
| `index.html` | KL-UNL page scaffold: `.app-shell`, `<kl-unl-masthead>`, the chart panel and the two control panels |
| `foundation/` | Shared KL-UNL files, copied in **unchanged** (`kl-unl-masthead.js`, `kl-unl.css`, `kl-unl.js`, `contents.json`, favicons) |
| `styles/styles.css` | Sim-specific styles only — nothing here edits or overrides the foundation look |
| `simulation.js` | All simulation logic, ported from the original ActionScript |
| `assets/mathjax/` | MathJax, vendored locally so there is no CDN dependency |
| `CONVERSION_NOTES.md` | Behaviour model, ActionScript → HTML5 mapping, deviations |
| `ACCESSIBILITY.md` | WCAG 2.1 AA affordances, keyboard map, screen-reader wording |

Everything is local: the only network requests the page makes are for its own files
(`foundation/contents.json` and the vendored MathJax). There is no build step, bundler, framework,
CDN or analytics.
