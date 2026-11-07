# Melted Nail Demonstration — HTML5

An accessible HTML5 port of the Flash "Melted Nail Demonstration" (a.k.a.
"Blackbody Curves of Melting"), built on the shared KL-UNL foundation.

## This sim must be served over HTTP — it will NOT run from a double-clicked file

Opening `index.html` directly from the filesystem (a `file://` path) shows a
broken/empty masthead and no Help/About text.

**Why:** the KL-UNL masthead component (`foundation/kl-unl-masthead.js`) loads its
title and Help/About text with `fetch('foundation/contents.json')`. Browsers block
`fetch()` of local files under the `file://` protocol (same-origin policy), so that
request fails when the page is double-clicked. Served over HTTP the fetch succeeds
and the sim loads normally. (The bundled MathJax and the nail video load the same way.)

## How to run locally

Run one of these **from inside this `html5/` folder**, then open the printed URL:

```bash
python -m http.server 8123
```

```bash
npx serve
```

Or use the VS Code **Live Server** extension (right-click `index.html` → "Open with Live Server").

When you serve from inside `html5/`, the sim is at the server **root**, so the URL is
`http://localhost:8123/` — not `.../html5/index.html`.

## Production

When deployed to the cloud host (served over HTTP/HTTPS) it just works. The
`file://` limitation only affects local double-clicking.

## What's here

```
index.html            KL-UNL scaffold: .app-shell + <kl-unl-masthead> + panels
foundation/           KL-UNL foundation, copied in UNCHANGED (masthead, css, js,
                      contents.json, favicons). Only content change: none — the
                      "meltednail" entry already existed in contents.json.
styles/styles.css     sim-specific styles only (foundation never edited)
simulation.js         all sim logic (physics, rendering, controls, a11y)
assets/
  nail.mp4 / nail.webm  the nail-heating footage, transcoded from the SWF's
                        embedded VP6 video (the reused exported asset)
  mathjax/tex-svg.js    self-hosted MathJax (no CDN at runtime)
CONVERSION_NOTES.md   behavior model + AS→HTML5 mapping + deviations
ACCESSIBILITY.md      WCAG affordances, keyboard map, live-region wording
```

No build step, no bundler, no framework, no CDN. Everything is local; the only
runtime fetches are `foundation/contents.json`, the local MathJax, and the local
video files.
