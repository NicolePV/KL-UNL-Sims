# Milky Way Rotational Velocity Explorer — HTML5

**This simulation must be served over HTTP. It will not run from a double-clicked
`index.html` (a `file://` path).**

## Why file:// does not work

The shared KL-UNL masthead (`foundation/kl-unl-masthead.js`) loads the simulation's
title and its Help / About text with `fetch('foundation/contents.json')`. Browsers
block `fetch()` of local files under the `file://` protocol (same-origin policy), so
opening `index.html` directly gives you a page with an empty or broken masthead and a
console error like `kl-unl-masthead: Failed to load sim-specific data`. Served over
HTTP the fetch succeeds and everything loads normally.

## Running it locally

Run one of these **from inside this `html5/` folder**, then open the URL it prints.

Python:

```bash
python3 -m http.server 8123
```

Node:

```bash
npx serve
```

Windows PowerShell (a tiny server is included here):

```bash
powershell -ExecutionPolicy Bypass -File ./serve.ps1
```

VS Code: install the **Live Server** extension and use *Open with Live Server* on
`index.html`.

Because you are serving *from inside* `html5/`, the simulation sits at the server
root — open <http://localhost:8123/>, **not** `.../html5/index.html`.

## Production

Deployed to the cloud host over HTTP/HTTPS it simply works. The `file://`
limitation only affects opening the file locally by double-clicking.

## What is here

```
index.html            page scaffold: .app-shell + <kl-unl-masthead> + panels
simulation.js         all simulation logic (ported from the ActionScript)
styles/styles.css     sim-specific styles only; shared styling comes from kl-unl.css
foundation/           the shared KL-UNL files, copied in
                        kl-unl-masthead.js, kl-unl.css, kl-unl.js  (code unchanged)
                        contents.json  (this sim's entry edited; see CONVERSION_NOTES.md)
                        mathjax/       self-hosted MathJax 3.2.2 (no CDN)
assets/               exported Flash art reused as-is (galaxy bitmap, SVG shapes)
serve.ps1             optional local static server for Windows
CONVERSION_NOTES.md   behaviour model, AS → HTML5 mapping, deviations
ACCESSIBILITY.md      WCAG affordances, keyboard map, colour changes, SR wording
```

There are no build steps, bundlers, frameworks or CDN requests. The only network
requests the page makes are to its own files: `foundation/contents.json`, the
foundation CSS/JS, the self-hosted MathJax bundle and its web fonts, and the
images in `assets/`.
