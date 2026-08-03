# Sun's Rays Simulator (HTML5)

**This simulation must be served over HTTP. It will not run from a double-clicked
`index.html` (a `file://` path).**

## Why

The shared KL-UNL masthead (`foundation/kl-unl-masthead.js`) loads the simulation's
title and its Help / About text with `fetch('foundation/contents.json')`. Browsers
block `fetch()` of local files under the `file://` protocol for security (the
same-origin policy), so opening `index.html` directly leaves the masthead empty or
broken. Served over HTTP the fetch succeeds and the simulation loads normally.

## How to run it locally

Run one of these **from inside this `html5/` folder**:

```
# Python
python3 -m http.server 8123      # then open http://localhost:8123/

# Node
npx serve                        # or: npx http-server

# VS Code
Use the "Live Server" extension.
```

Because the server is started from inside `html5/`, the simulation is at the server
root — the URL is `http://localhost:8123/`, not `.../html5/index.html`.

## Production

Deployed to the cloud host (served over HTTP/HTTPS) it just works. The `file://`
limitation only affects local double-clicking.

## What is in this folder

| Path | Contents |
| --- | --- |
| `index.html` | KL-UNL scaffold: `.app-shell` + `<kl-unl-masthead>` + the diagram and readout panels |
| `foundation/` | Shared KL-UNL files, copied in byte-for-byte unchanged |
| `styles/styles.css` | Sim-specific styles only |
| `simulation.js` | All simulation logic |
| `assets/earth.png` | The Earth bitmap exported from the original SWF, reused as-is |
| `assets/mathjax/` | MathJax, vendored locally (no CDN) |
| `CONVERSION_NOTES.md` | Behaviour model, ActionScript → HTML5 mapping, deviations |
| `ACCESSIBILITY.md` | WCAG affordances, keyboard map, colour changes, live-region wording |

Everything is local: the only network requests the page makes are
`foundation/contents.json`, `assets/earth.png` and the vendored MathJax bundle.
