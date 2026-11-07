# Pulsar Period Simulator (HTML5)

**This simulation must be served over HTTP — it will not run from a
double-clicked `index.html` (`file://`) path.**

## Why

The `<kl-unl-masthead>` component (in `foundation/kl-unl-masthead.js`) loads
the page title and Help/About text via `fetch('foundation/contents.json')`.
Browsers block `fetch()` of local files under the `file://` protocol for
security (same-origin policy), so opening `index.html` directly leaves the
masthead empty or broken. Served over HTTP, the fetch succeeds and the page
loads normally.

## How to run locally

From inside this `html5/` folder, start any static file server, for example:

```
python3 -m http.server 8123
```

or

```
npx serve
```

or use the VS Code "Live Server" extension.

Then open the site root in your browser — e.g. `http://localhost:8123/` —
**not** `.../html5/index.html`, since the server root already points at this
folder.

## Production

When this `html5/` folder is deployed to a normal HTTP/HTTPS host, it just
works — the `file://` limitation above only affects local double-clicking.

## Contents

- `index.html` — page shell (KL-UNL masthead + panels)
- `foundation/` — shared KL-UNL foundation files, copied in unchanged
- `styles/styles.css` — sim-specific styles layered on top of `kl-unl.css`
- `simulation.js` — all simulation logic
- `assets/` — exported vector assets reused from the decompiled source
- `CONVERSION_NOTES.md` — behavior model, AS→HTML5 mapping, deviations
- `ACCESSIBILITY.md` — WCAG affordances and known limitations
