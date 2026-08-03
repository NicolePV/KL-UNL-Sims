# Meridional Altitude Simulator — HTML5

**This simulation must be served over HTTP. It will not run from a double-clicked
`index.html` (a `file://` path).**

## Why file:// does not work

The shared KL-UNL masthead (`foundation/kl-unl-masthead.js`) loads the simulation's
title, Help text and About text with `fetch('foundation/contents.json')`. Browsers
block `fetch()` of local files under the `file://` protocol for security reasons
(the same-origin policy treats every local file as a separate origin). Opening
`index.html` directly therefore shows an empty or broken masthead — no title, no
Reset / Help / About buttons — even though the rest of the page appears.

Served over HTTP the fetch succeeds and the simulation loads normally.

## How to run it locally

Run one of these **from inside this `html5/` folder**, then open the URL it prints:

```
# Python 3
python3 -m http.server 8123      # then open http://localhost:8123/

# Node
npx serve                        # or: npx http-server
```

Or use the **Live Server** extension in VS Code (right-click `index.html` →
"Open with Live Server").

Because you are serving from inside `html5/`, the simulation sits at the server
root — the URL is `http://localhost:8123/`, **not** `.../html5/index.html`.

## In production

Deployed to the cloud host (served over HTTP/HTTPS) it just works. The `file://`
limitation only affects local double-clicking.

## What is in this folder

| Path | Contents |
| --- | --- |
| `index.html` | Page scaffold: KL-UNL shell, masthead, panels |
| `foundation/` | Shared KL-UNL files, copied in **unchanged** |
| `styles/styles.css` | Sim-specific styles only |
| `simulation.js` | All simulation logic |
| `assets/` | Exported art reused from the SWF, plus a local copy of MathJax |
| `CONVERSION_NOTES.md` | Behaviour model, ActionScript → HTML5 mapping, deviations |
| `ACCESSIBILITY.md` | WCAG affordances, keyboard map, colour remaps |

Everything is local. The only runtime network requests are for files in this
folder — nothing leaves the host, and there is no CDN, bundler or build step.
