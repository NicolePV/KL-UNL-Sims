# Synodic Lag Demonstrator — HTML5

**This simulation must be served over HTTP. It will not run from a double-clicked
`index.html` (a `file://` path).**

## Why

The KL-UNL masthead component (`foundation/kl-unl-masthead.js`) loads the
simulation's title and its Help / About text by calling
`fetch('foundation/contents.json')`. Browsers block `fetch()` of local files
under the `file://` protocol for security reasons (the same-origin policy), so
opening `index.html` directly gives you a page with an empty or broken masthead —
no title, no Reset, no Help, no About. Served over HTTP the fetch succeeds and
the simulation loads normally.

## How to run it locally

Run one of these **from inside the `html5/` folder**, then open the URL it prints:

```
# Python 3
python3 -m http.server 8123        # then open http://localhost:8123/

# Node
npx serve                          # or:  npx http-server
```

VS Code users can instead right-click `index.html` and choose **Open with Live
Server** (the "Live Server" extension).

Because you are serving *from inside* `html5/`, the simulation sits at the server
root — the URL is `http://localhost:8123/`, **not**
`http://localhost:8123/html5/index.html`.

## Production

Once deployed to the cloud host (served over HTTP/HTTPS) it just works. The
`file://` limitation only affects opening the file directly on your own machine.

## What's in here

| Path | What it is |
| --- | --- |
| `index.html` | Page scaffold: KL-UNL shell, masthead, panels |
| `foundation/` | Shared KL-UNL files, copied in **byte-for-byte unchanged** |
| `styles/styles.css` | Sim-specific styles only, layered on the foundation |
| `simulation.js` | All simulation logic |
| `assets/shapes/` | The exported vector art, reused as-is from the SWF |
| `assets/mathjax/` | MathJax, bundled locally (no CDN at runtime) |
| `CONVERSION_NOTES.md` | Behaviour model, ActionScript → HTML5 mapping, deviations |
| `ACCESSIBILITY.md` | WCAG affordances, keyboard map, screen-reader wording |

There is no build step and no bundler. Every file is local; the only network
request the page makes is for `foundation/contents.json`.
