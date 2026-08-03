# Eclipse Table &mdash; accessible HTML5 build

An HTML5/CSS/JavaScript rebuild of the Flash **Eclipse Table** simulation
(`eclipse_table010.swf`), on the shared KL-UNL foundation and meeting WCAG 2.1 AA.
It plots every solar and lunar eclipse from 2000 through 2029 by year and month;
pointing at (or keyboard-focusing) a dot shows that eclipse's details.

## It must be served over HTTP &mdash; it will NOT run from a double-clicked file

Opening `index.html` directly from your file manager (a `file://` URL) shows an
empty/broken title bar and no Help/About text.

**Why:** the KL-UNL masthead component (`foundation/kl-unl-masthead.js`) loads its
title and its Help/About text with `fetch('foundation/contents.json')`. Browsers
block `fetch()` of local files under the `file://` protocol (same-origin policy),
so that request fails and the masthead cannot populate. Served over HTTP the fetch
succeeds and everything loads.

## How to run it locally

Open a terminal **inside this `html5/` folder** and start any static server:

```bash
# Python (bundled on macOS/Linux, easy on Windows)
python3 -m http.server 8123
#   then open  http://localhost:8123/

# Node
npx serve
#   or
npx http-server
```

VS Code users can instead use the **Live Server** extension.

Because you are serving from inside `html5/`, the sim is at the server root, so the
URL is `http://localhost:8123/` &mdash; not `.../html5/index.html`.

## Production

When deployed to the cloud host (served over HTTP/HTTPS) it just works with no
changes. The `file://` limitation only affects local double-clicking.

## What's in this folder

```
index.html            KL-UNL scaffold: .app-shell + <kl-unl-masthead> + panels
foundation/           the shared KL-UNL files, copied in unchanged
                        (kl-unl-masthead.js, kl-unl.css, kl-unl.js, contents.json)
styles/styles.css     sim-specific styles only (foundation is never edited)
simulation.js         all sim logic + the verbatim eclipse data tables
assets/               exported art reused as-is (dot & glow SVGs, grid SVG),
                        the ClassAction logo, and the sim's Verdana font
README.md             this file
CONVERSION_NOTES.md   behaviour model, Flash-to-HTML5 mapping, deviations
ACCESSIBILITY.md      WCAG affordances, ARIA, keyboard map, SR wording
```

No build step, bundler, framework, CDN, analytics, or web fonts &mdash; every file
is local. The only runtime network request is the local
`foundation/contents.json`.
