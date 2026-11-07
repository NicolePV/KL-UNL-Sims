# Daylight Simulator — HTML5

**This simulation must be served over HTTP. It will not run from a double-clicked
`index.html` (a `file://` path).**

## Why

The KL-UNL masthead component (`foundation/kl-unl-masthead.js`) loads the
simulation's title and its Help and About text with
`fetch('foundation/contents.json')`. Browsers block `fetch()` of local files
under the `file://` protocol for security (the same-origin policy), so opening
`index.html` directly gives you a page whose masthead — title, Reset, Help,
About — never loads.

Served over HTTP the fetch succeeds and the simulation loads normally.

## How to run it locally

Run one of these **from inside this `html5/` folder**:

```
# Python 3
python3 -m http.server 8123
```

```
# Node
npx serve
# or
npx http-server
```

```
# VS Code
Install the "Live Server" extension, then right-click index.html -> "Open with Live Server"
```

Then open <http://localhost:8123/>.

Because you are serving from inside `html5/`, the simulation sits at the server
root — the URL is `http://localhost:8123/`, **not**
`http://localhost:8123/html5/index.html`.

## Production

Deployed to the cloud host over HTTP/HTTPS it simply works. The `file://`
limitation only affects opening the file directly from disk.

## What it loads

Everything is local — there are no CDN, font, or analytics requests, and
nothing leaves the host:

| File | Purpose |
| --- | --- |
| `foundation/kl-unl.css`, `kl-unl.js`, `kl-unl-masthead.js`, `contents.json` | KL-UNL foundation, copied in unchanged |
| `assets/mathjax/tex-mml-svg.js` | MathJax 3.2.2, vendored locally |
| `assets/map-day.jpg`, `assets/map-night.jpg` | NASA day and night Earth maps, exported from the SWF |
| `assets/marker.svg` | "You are here" marker, exported from the SWF |
| `styles/styles.css`, `simulation.js` | This simulation |

## Browser support

Chrome, Edge, Firefox, and Safari on Windows, macOS, Linux, iOS, and Android.
Pointer Events drive both mouse and touch, so dragging the map works on
touchscreens.
