# Blackbody Curves and Filters Explorer — HTML5

An accessible HTML5 port of the NAAP *Blackbody Curves & UBV Filters* Flash
explorer, built on the shared KL-UNL foundation.

## This sim must be served over HTTP — it will NOT run from a double-clicked `file://` path

**Why:** the KL-UNL masthead component (`foundation/kl-unl-masthead.js`) loads the
title / Help / About text with `fetch('foundation/contents.json')`. Browsers block
`fetch()` of local files under the `file://` protocol (same-origin security policy),
so opening `index.html` by double-clicking shows an empty or broken masthead.
Served over HTTP the fetch succeeds and everything loads normally.

## How to run locally

Open a terminal **inside this `html5/` folder** and start any static server:

```
# Python 3
python3 -m http.server 8123
#   then open  http://localhost:8123/

# Node
npx serve
#   or:  npx http-server

# VS Code
#   Use the "Live Server" extension and "Open with Live Server".
```

Because you serve from inside `html5/`, the sim is at the server **root**, so the
URL is `http://localhost:8123/` — not `.../html5/index.html`.

## Production

When deployed to the cloud host (served over HTTP/HTTPS) it just works. The
`file://` limitation only affects local double-clicking.

## What's here

```
index.html            KL-UNL scaffold: .app-shell + <kl-unl-masthead> + panels
foundation/           KL-UNL shared files, copied in UNCHANGED
                        (kl-unl-masthead.js, kl-unl.css, kl-unl.js, contents.json)
styles/styles.css     sim-specific styles only (foundation never edited)
simulation.js         all sim logic (physics, rendering, controls, filters)
assets/mathjax/       MathJax (tex-svg), bundled locally — no CDN at runtime
README.md             this file
CONVERSION_NOTES.md   behavior model, AS→HTML5 mapping, deviations
ACCESSIBILITY.md      WCAG affordances, ARIA, keyboard map, color notes
```

No build step, no bundler, no framework, no external network calls. The only
runtime fetch is the local `foundation/contents.json`.
