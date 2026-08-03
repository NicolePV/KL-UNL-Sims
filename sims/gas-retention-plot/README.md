# Gas Retention Plot — Accessible HTML5

An accessible HTML5 rebuild of the NAAP *Gas Retention Plot* Flash simulation,
built on the shared KL-UNL foundation.

## It MUST be served over HTTP — double-clicking `index.html` will NOT work

The KL-UNL masthead component (`foundation/kl-unl-masthead.js`, which is copied
in unchanged) loads its title / Help / About text with
`fetch('foundation/contents.json')`. Browsers block `fetch()` of local files
under the `file://` protocol for security (the same-origin policy), so if you
open `index.html` by double-clicking it, the masthead comes up empty or broken.
Served over HTTP the fetch succeeds and the sim loads normally.

## How to run locally

Open a terminal **inside this `html5/` folder** and start any static server:

```
# Python 3
python3 -m http.server 8123
#   then open  http://localhost:8123/

# Node
npx serve
#   or
npx http-server
```

Or use the VS Code **Live Server** extension (right-click `index.html` →
"Open with Live Server").

Because you are serving from **inside** `html5/`, the sim is at the server root,
so the URL is `http://localhost:8123/` — not `.../html5/index.html`.

## Production

When deployed to the cloud host (served over HTTP/HTTPS) it just works; the
`file://` limitation only affects local double-clicking.

## What's in here

```
index.html            KL-UNL scaffold: .app-shell + <kl-unl-masthead> + panels
foundation/           KL-UNL foundation, copied UNCHANGED
                        kl-unl-masthead.js, kl-unl.css, kl-unl.js, contents.json
styles/styles.css     sim-specific styles only (foundation is never edited)
simulation.js         all sim logic (faithful port of the ActionScript)
assets/tex-svg.js     MathJax (vendored locally; SVG output, no CDN)
README.md             this file
CONVERSION_NOTES.md   behavior model + AS→HTML5 mapping + deviations
ACCESSIBILITY.md      WCAG affordances, ARIA, keyboard map, colour notes
```

No build step, no bundler, no framework, no CDN. The only runtime fetch is the
local `foundation/contents.json`; MathJax is loaded from the local
`assets/tex-svg.js`. Nothing leaves the host.
