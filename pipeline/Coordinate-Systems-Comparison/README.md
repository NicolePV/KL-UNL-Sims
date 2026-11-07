# Rotating Sky Explorer — HTML5

**This simulation must be served over HTTP. It will not run from a double-clicked
`index.html` (a `file://` path).**

## Why

The KL-UNL masthead component (`foundation/kl-unl-masthead.js`) loads the
simulation's title and its Help / About text with
`fetch('foundation/contents.json')`. Browsers block `fetch()` of local files under
the `file://` protocol for security (same-origin policy), so opening
`index.html` directly gives you an empty or broken masthead — no title, no Help,
no About, and no working Reset button.

Served over HTTP the fetch succeeds and the simulation loads normally.

## How to run it locally

Run one of these from **inside this `html5/` folder**:

```
# Python 3
python3 -m http.server 8123        # then open http://localhost:8123/

# Node
npx serve                          # or: npx http-server

# VS Code
# install the "Live Server" extension and use "Open with Live Server"
```

Because you are serving from inside `html5/`, the simulation sits at the server
root — open `http://localhost:8123/`, **not** `.../html5/index.html`.

## Production

Once deployed to the cloud host (served over HTTP/HTTPS) it just works. The
`file://` limitation only affects local double-clicking.

## What's in here

| Path | What it is |
| --- | --- |
| `index.html` | KL-UNL scaffold: `.app-shell` + `<kl-unl-masthead>` + panels |
| `foundation/` | Shared KL-UNL files, copied in **unchanged** |
| `styles/styles.css` | Sim-specific styles only |
| `simulation.js` | All simulation logic |
| `assets/` | Vector art reused as-is from the decompiled export, plus MathJax and the Verdana face |
| `CONVERSION_NOTES.md` | Behaviour model, ActionScript → HTML5 mapping, deviations |
| `ACCESSIBILITY.md` | WCAG affordances, keyboard map, screen-reader notes |

Everything is local: the only network requests are `foundation/contents.json`,
the vendored MathJax bundle, the reused SVG assets and the vendored font.
There is no build step, bundler, framework, CDN or analytics.
