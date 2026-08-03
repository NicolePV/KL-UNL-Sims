# Time-Lapse Seasons Demonstrator (HTML5)

**This simulation must be served over HTTP. It will not run from a double-clicked
`index.html` (a `file://` path).**

## Why

The KL-UNL masthead component (`foundation/kl-unl-masthead.js`) loads the
simulation's title and its Help and About text with
`fetch('foundation/contents.json')`. Browsers block `fetch()` of local files
under the `file://` protocol for security (the same-origin policy), so opening
`index.html` directly gives you an empty or broken masthead — no title, no
Help, no About — and the simulation's own day-table fetch fails the same way.
Served over HTTP, both fetches succeed and everything loads normally.

## How to run it locally

Run one of these **from inside this `html5/` folder**:

```
# Python 3
python3 -m http.server 8123

# Node
npx serve
# or
npx http-server
```

Then open <http://localhost:8123/>.

Because you are serving from inside `html5/`, the simulation sits at the server
root — the URL is `http://localhost:8123/`, **not**
`http://localhost:8123/html5/index.html`.

In VS Code you can instead right-click `index.html` and choose **Open with Live
Server** (the "Live Server" extension), which does the same thing.

## In production

When deployed to the cloud host over HTTP/HTTPS it just works — no
configuration needed. The `file://` limitation only ever affects opening the
file directly from disk on your own machine.

## What's in here

| Path | What it is |
| --- | --- |
| `index.html` | The KL-UNL scaffold: `.app-shell`, `<kl-unl-masthead>`, and the panels |
| `foundation/` | The shared KL-UNL files, copied in **unchanged** |
| `styles/styles.css` | Sim-specific styles only |
| `simulation.js` | All simulation logic |
| `assets/images/` | The 315 webcam photographs, reused as exported |
| `assets/shapes/` | Exported vector art (horizon plane, sun, figure, cursors) |
| `assets/daydata.json` | The 366-entry day table carried over from the ActionScript |
| `assets/mathjax/` | MathJax, vendored locally (no CDN) |

Everything is local; the page makes no network requests off the host.

## Note on size

`assets/images/` (about 8 MB) and `assets/mathjax/` (about 24 MB) dominate the
33 MB total. The photographs are the simulation's actual subject matter and the
MathJax build is vendored deliberately so the page has no external
dependencies.
