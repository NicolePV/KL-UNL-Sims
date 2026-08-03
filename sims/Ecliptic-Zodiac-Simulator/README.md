# Ecliptic (Zodiac) Simulator — HTML5

**This simulation must be served over HTTP. It will not run from a
double-clicked `index.html` (a `file://` path).**

## Why

The KL-UNL masthead (`foundation/kl-unl-masthead.js`) loads the simulation's
title and its Help / About text with `fetch('foundation/contents.json')`.
Browsers block `fetch()` of local files under the `file://` protocol for
security reasons (the same-origin policy), so opening `index.html` directly
gives you a page with an empty or broken masthead. Served over HTTP the fetch
succeeds and everything loads normally.

## How to run it locally

Open a terminal **inside this `html5/` folder** and use any one of these:

```
# Python 3
python3 -m http.server 8123

# Node
npx serve
# or
npx http-server
```

Then open <http://localhost:8123/> in a browser.

Because you are serving from inside `html5/`, the simulation sits at the server
root — the URL is `http://localhost:8123/`, **not**
`http://localhost:8123/html5/index.html`.

In VS Code you can instead install the **Live Server** extension, right-click
`index.html` and choose *Open with Live Server*.

## In production

Once deployed to the cloud host (served over HTTP or HTTPS) it just works. The
`file://` limitation only affects local double-clicking.

## What is in here

```
index.html            page scaffold: KL-UNL app shell, masthead, panels
foundation/           the shared KL-UNL files, copied in unchanged
styles/styles.css     sim-specific styles only
simulation.js         all simulation logic
assets/               art and data reused from the Flash export, plus a
                      local copy of MathJax
CONVERSION_NOTES.md   how the ActionScript maps onto this code
ACCESSIBILITY.md      the accessibility affordances and what still needs
                      human QA
```

Everything is local: no build step, no bundler, no framework and no CDN. The
only network requests the page makes are for files inside this folder.
