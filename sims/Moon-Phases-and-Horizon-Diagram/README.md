# Moon Phases and the Horizon Demonstrator — Accessible HTML5

An accessible HTML5 rebuild of the legacy Flash "Moon Phases and the Horizon
Demonstrator" (internally *positionsdemonstrator*), built on the shared KL‑UNL
foundation. Behaviour matches the original; chrome, layout, and accessibility
follow the KL‑UNL pipeline and WCAG 2.1 AA.

## This sim MUST be served over HTTP — it will NOT run from a double‑clicked `file://` page

**Why:** the KL‑UNL masthead (`foundation/kl-unl-masthead.js`) loads its
title / Help / About text with `fetch('foundation/contents.json')`. Browsers
block `fetch()` of local files under the `file://` protocol (same‑origin
policy), so opening `index.html` by double‑clicking shows an empty or broken
masthead. Served over HTTP the fetch succeeds and the sim loads normally.

## How to run locally

Run one of these **from inside this `html5/` folder**, then open the printed URL:

```bash
python3 -m http.server 8123
```

```bash
npx serve
```

(or `npx http-server`)

Or use the **Live Server** extension in VS Code.

Because you serve from inside `html5/`, the sim is at the server root — open
**http://localhost:8123/** (not `.../html5/index.html`).

## Production

When deployed to the cloud host (served over HTTP/HTTPS) it just works. The
`file://` limitation only affects local double‑clicking.

## What's here

```
html5/
  index.html          KL-UNL scaffold: .app-shell + <kl-unl-masthead> + panels
  foundation/         copied UNCHANGED from the project foundation:
                        kl-unl-masthead.js, kl-unl.css, kl-unl.js,
                        contents.json, favicons
  styles/styles.css   sim-specific styles only (foundation is never edited)
  simulation.js       all sim logic (ported celestial-sphere engine + UI)
  assets/             reused exported art (stickfigure.svg)
  README.md           this file
  CONVERSION_NOTES.md behaviour model, AS→HTML5 mapping, deviations
  ACCESSIBILITY.md    WCAG affordances, keyboard map, ARIA, SR wording
```

No build step, no bundler, no framework, no CDN, no analytics, no external
fonts. The only runtime fetch is the local `foundation/contents.json`.

## Browser support

Standards‑based HTML/CSS/JS with Pointer Events and Canvas 2D — verified to
work in Chrome, Edge, Firefox, and Safari (desktop and iOS), across Windows,
macOS, Linux, iOS, and Android. Touch dragging works on iOS Safari
(`touch-action: none` on the canvas).
