# Gravity Algebra — Accessible HTML5 (KL-UNL)

An accessible HTML5 rebuild of the *Gravity Algebra* Flash demonstrator, built on
the shared KL-UNL foundation. It shows Newton's law of universal gravitation and
lets the user change the coefficients on the two masses and the distance to see
how the force changes.

## This sim must be served over HTTP — double-clicking `index.html` will NOT work

Opening `index.html` directly from a `file://` path shows a blank/broken masthead.

**Why:** the KL-UNL masthead component (`foundation/kl-unl-masthead.js`) loads the
title / Help / About text with `fetch('foundation/contents.json')`. Browsers block
`fetch()` of local files under the `file://` protocol (same-origin policy), so that
request fails and the masthead never populates. Served over HTTP the fetch succeeds
and the sim loads normally.

## How to run it locally

Run one of these **from inside this `html5/` folder**, then open the printed URL:

```
# Python (any OS with Python 3)
python -m http.server 8137
#   then open  http://localhost:8137/

# Node
npx serve
#   or
npx http-server

# VS Code
#   Use the "Live Server" extension and "Open with Live Server".
```

Because you serve from inside `html5/`, the sim is at the server **root** — the URL
is `http://localhost:8137/`, not `.../html5/index.html`.

## Production

When deployed to the cloud host (served over HTTP/HTTPS) it just works — the
`file://` limitation only affects local double-clicking.

## What's here

```
index.html            KL-UNL scaffold + <kl-unl-masthead> + the equation panel
foundation/           KL-UNL foundation, copied in UNCHANGED
                        (kl-unl-masthead.js, kl-unl.css, kl-unl.js, contents.json)
styles/styles.css     sim-specific styles only (equation layout + coefficient dropdown)
simulation.js         all sim logic (state, faithful onChange port, dropdown, reset)
assets/mathjax/        MathJax (tex-svg), bundled locally — no CDN at runtime
README.md             this file
CONVERSION_NOTES.md    behavior model, AS→HTML5 mapping, deviations
ACCESSIBILITY.md       WCAG affordances, ARIA, keyboard map, screen-reader wording
```

No build step, no bundler, no framework, no CDN, no analytics. The only runtime
fetch is the local `foundation/contents.json` (plus the local MathJax script).
