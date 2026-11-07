# Kepler's Third Law — HTML5

**This simulation must be served over HTTP. It will not run from a double-clicked
`index.html` (a `file://` path).**

## Why

The KL-UNL masthead component (`foundation/kl-unl-masthead.js`) loads the sim's
title and its Help / About text with `fetch('foundation/contents.json')`. Browsers
block `fetch()` of local files under the `file://` protocol for security (the
same-origin policy), so opening `index.html` directly leaves the masthead empty or
broken — no title, no Reset / Help / About buttons.

Served over HTTP the fetch succeeds and the sim loads normally.

## How to run it locally

Run one of these **from inside the `html5/` folder**:

```
# Python
python3 -m http.server 8123      # Windows: python -m http.server 8123

# Node
npx serve                        # or: npx http-server
```

Then open <http://localhost:8123/>.

Because you are serving from *inside* `html5/`, the sim sits at the server root —
the URL is `http://localhost:8123/`, **not** `.../html5/index.html`.

In VS Code, the **Live Server** extension does the same thing: right-click
`index.html` → "Open with Live Server".

## Production

When deployed to the cloud host (served over HTTP/HTTPS) it just works. The
`file://` limitation only affects local double-clicking.

## What is in this folder

| Path | Purpose |
| --- | --- |
| `index.html` | KL-UNL scaffold: `.app-shell` + `<kl-unl-masthead>` + the calculator panel |
| `simulation.js` | All sim logic — the port of the original's two `onChanged` handlers |
| `styles/styles.css` | Sim-specific styles only; shared styling comes from the foundation |
| `foundation/` | KL-UNL foundation, copied in **unchanged** — do not edit |
| `assets/mathjax/` | Locally bundled MathJax (`tex-svg.js`); no CDN at runtime |
| `CONVERSION_NOTES.md` | Behavior model, ActionScript → HTML5 mapping, deviations |
| `ACCESSIBILITY.md` | WCAG affordances, keyboard map, screen-reader wording |

There are no other runtime network requests: only `foundation/contents.json` and
the local MathJax bundle are loaded, and nothing leaves the host.
