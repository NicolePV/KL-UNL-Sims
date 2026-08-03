# Declination Ranges Simulator (HTML5)

**This simulation must be served over HTTP — it will not run from a
double-clicked `index.html` (a `file://` path).**

## Why

The KL-UNL masthead component (`foundation/kl-unl-masthead.js`) loads the
simulation title and its Help / About text with
`fetch('foundation/contents.json')`. Browsers block `fetch()` of local files
under the `file://` protocol for security (the same-origin policy), so opening
`index.html` directly gives you a page with an empty or broken masthead and no
Help or About buttons. Served over HTTP the fetch succeeds and the simulation
loads normally.

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
root — the URL is `http://localhost:8123/`, not `.../html5/index.html`.

In VS Code you can instead right-click `index.html` and choose **Open with Live
Server** (the "Live Server" extension).

## Production

When deployed to the cloud host it is already served over HTTP/HTTPS, so it just
works. The `file://` limitation only affects local double-clicking.

## What it loads

Everything is local — there is no CDN, bundler, build step or analytics. The
only runtime requests are:

* `foundation/contents.json` (the masthead's text)
* `assets/mathjax/tex-svg.js` (MathJax, bundled locally)
* `assets/*.svg` (the artwork exported from the original Flash file)

Nothing leaves the host.

## Layout

```
index.html            page scaffold (KL-UNL shell + panels)
simulation.js         all simulation logic
styles/styles.css     sim-specific styles only
foundation/           KL-UNL foundation, copied in unchanged
assets/               artwork reused as-is from the Flash export, plus MathJax
CONVERSION_NOTES.md   behaviour model and the Flash -> HTML5 mapping
ACCESSIBILITY.md      the accessibility affordances and what still needs QA
```
