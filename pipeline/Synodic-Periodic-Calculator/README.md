# Synodic Period Calculator (HTML5)

An accessible HTML5 rebuild of the legacy Flash **Synodic Period Calculator**,
built on the shared KL-UNL foundation.

## It must be served over HTTP — double-clicking `index.html` will NOT work

**Why:** the KL-UNL masthead (`foundation/kl-unl-masthead.js`, which must not be
modified) loads the page title and the Help/About text with
`fetch('foundation/contents.json')`. Browsers block `fetch()` of local files under
the `file://` protocol (same-origin policy), so opening the file directly leaves
the masthead empty/broken. Served over HTTP the fetch succeeds and everything loads.

## How to run locally

From **inside this `html5/` folder**, start any static server:

```bash
python3 -m http.server 8123
```

then open <http://localhost:8123/>. Alternatives:

```bash
npx serve
```

```bash
npx http-server
```

Or use the **Live Server** extension in VS Code.

Because you serve from inside `html5/`, the sim is at the server root — open
`http://localhost:8123/` (not `.../html5/index.html`).

## Production

When deployed to the cloud host (served over HTTP/HTTPS) it just works. The
`file://` limitation only affects local double-clicking.

## What's here

```
index.html          KL-UNL scaffold: .app-shell + <kl-unl-masthead> + two panels
foundation/         copied UNCHANGED (kl-unl-masthead.js, kl-unl.css, kl-unl.js,
                    contents.json, favicons). The "synodiccalculator" entry was
                    already present in contents.json — no edit was needed.
styles/styles.css   sim-specific styles only (foundation css untouched)
simulation.js       all sim logic (the ported AS1 calculator + a11y controls)
assets/             tex-svg.js (vendored MathJax, SVG output — no font fetches)
README.md           this file
CONVERSION_NOTES.md behaviour model + AS→HTML5 mapping + deviations
ACCESSIBILITY.md    WCAG affordances, keyboard map, colour remaps, SR wording
```

No build step, no bundler, no framework, no CDN. All files are local; the only
runtime fetch is `foundation/contents.json`.

There is **no `<canvas>`**: the original is a pure form calculator (radio
buttons, two linked text fields, and a static fraction equation), so the whole
sim is native accessible HTML with the equation typeset by MathJax.
