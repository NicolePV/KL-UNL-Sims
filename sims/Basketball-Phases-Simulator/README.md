# Basketball Phases Simulator

An accessible HTML5 rebuild of `basketball.swf`, built on the shared KL-UNL foundation.

## This sim must be served over HTTP — it will not run from a double-clicked `index.html`

**Why.** The KL-UNL masthead (`foundation/kl-unl-masthead.js`) loads the simulation's
title and its Help/About text with `fetch('foundation/contents.json')`. Browsers block
`fetch()` of local files under the `file://` protocol (same-origin policy), so opening
`index.html` directly gives you an empty or broken masthead. Served over HTTP the fetch
succeeds and the sim loads normally.

## How to run it locally

Run one of these **from inside this `html5/` folder**:

```
python3 -m http.server 8123
```
then open <http://localhost:8123/>

```
npx serve
```
(or `npx http-server`)

Or use the **Live Server** extension in VS Code.

Because you are serving from inside `html5/`, the sim sits at the server root — the URL
is `http://localhost:8123/`, not `.../html5/index.html`.

## Production

Deployed to the cloud host over HTTP/HTTPS it just works. The `file://` limitation only
affects opening the file locally by double-clicking.

## What it loads

Everything is local; nothing leaves the host. The only runtime requests are:

- `foundation/contents.json` — masthead title, Help and About text
- `assets/mathjax/tex-mml-svg.js` — MathJax, vendored locally (no CDN)
- `assets/` — the artwork exported from the original SWF

## Layout

```
index.html            KL-UNL scaffold: .app-shell + <kl-unl-masthead> + panels
foundation/           copied UNCHANGED from the shared foundation folder
styles/styles.css     sim-specific styles only
simulation.js         all sim logic
assets/               artwork exported from basketball.swf, reused as-is
                        sequence/f01..f79.png   the 79 ball-rotation frames
                        eye.svg, ball.svg, ball-shadow.svg, orbit.svg, arrow.svg
                        mathjax/                vendored MathJax
CONVERSION_NOTES.md   behaviour model, ActionScript -> JS mapping, deviations
ACCESSIBILITY.md      WCAG affordances, keyboard map, screen-reader wording
```
