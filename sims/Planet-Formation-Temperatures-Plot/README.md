# Planet Formation Temperatures Plot

An HTML5 / ADA-accessible rebuild of the Flash simulation `formationTemps002.swf`
(NAAP / University of Nebraska-Lincoln, 31 August 2009), built on the shared
KL-UNL foundation.

## This simulation must be served over HTTP — it will not run from a double-clicked `index.html`

**Why.** The KL-UNL masthead component (`foundation/kl-unl-masthead.js`) loads the
simulation title and the Help / About text with `fetch('foundation/contents.json')`.
Browsers block `fetch()` of local files under the `file://` protocol (the
same-origin policy treats every `file://` URL as a unique origin), so opening
`index.html` straight from the file system gives you an empty or broken masthead
and a console error. Served over HTTP the fetch succeeds and everything loads.

## How to run it locally

Run one of these **from inside this `html5/` folder**, then open the URL it prints.

Python:

```bash
python3 -m http.server 8123
```

Node:

```bash
npx serve
```

Node (alternative):

```bash
npx http-server
```

VS Code: install the **Live Server** extension and choose *Open with Live Server*
on `index.html`.

Because the server root is this folder, the simulation is at
`http://localhost:8123/` — **not** `http://localhost:8123/html5/index.html`.

## Production

Deployed to the cloud host and served over HTTP or HTTPS it just works; the
`file://` limitation only affects local double-clicking.

## What is in here

| Path | What it is |
| --- | --- |
| `index.html` | KL-UNL page scaffold: `.app-shell`, `<kl-unl-masthead>`, two `.panel` sections |
| `foundation/` | Shared KL-UNL files, copied in **unchanged** — never edit these |
| `styles/styles.css` | Only this simulation's styles, layered on top of `foundation/kl-unl.css` |
| `simulation.js` | All simulation logic, ported from the decompiled ActionScript |
| `assets/` | Artwork exported from the SWF and reused as-is, plus a local MathJax build |
| `CONVERSION_NOTES.md` | Behaviour model, ActionScript → HTML5 mapping, deviations |
| `ACCESSIBILITY.md` | WCAG affordances, keyboard map, screen-reader wording |

No build step, no bundler, no framework, no CDN. The only network requests at
runtime are for files inside this folder.
