# Paths of the Sun Demonstrator — HTML5

An accessible, self-contained HTML5 rebuild of the legacy Flash "Paths of the
Sun" demonstrator, built on the shared KL-UNL foundation.

## This sim MUST be served over HTTP — it will NOT run from a double-clicked file

Opening `index.html` directly (a `file://` path) shows a broken/empty masthead.

**Why:** the KL-UNL masthead component (`foundation/kl-unl-masthead.js`) loads its
title and its Help/About text with `fetch('foundation/contents.json')`. Browsers
block `fetch()` of local files over the `file://` protocol (same-origin policy),
so the fetch fails and the title/Help/About never load. Served over HTTP the
fetch succeeds and everything works.

## How to run locally

From **inside this `html5/` folder**, start any static server:

```
# Python (3.x)
python3 -m http.server 8123
# then open  http://localhost:8123/

# Node
npx serve
#   or
npx http-server

# VS Code
# Use the "Live Server" extension and "Open with Live Server".
```

Because you serve from inside `html5/`, the sim is at the server root — open
`http://localhost:8123/` (not `.../html5/index.html`).

## Production

When deployed to the cloud host (served over HTTP/HTTPS) it just works. The
`file://` limitation only affects local double-clicking.

## Layout

```
html5/
  index.html            KL-UNL scaffold (app-shell + <kl-unl-masthead> + panels)
  foundation/           copied UNCHANGED from the linked folder's foundation/
                          kl-unl-masthead.js, kl-unl.css, kl-unl.js, contents.json
  styles/styles.css     sim-specific styles only (foundation never edited)
  simulation.js         all sim logic (the ported celestial-sphere engine)
  assets/               exported shapes reused as-is (stickman, shadow, sun, ground)
  README.md             this file
  CONVERSION_NOTES.md   behaviour model, AS->HTML5 mapping, deviations
  ACCESSIBILITY.md      WCAG affordances, ARIA, keyboard map, color notes
```

No build step, no bundler, no framework, no CDN. The only runtime fetch is the
local `foundation/contents.json`.
