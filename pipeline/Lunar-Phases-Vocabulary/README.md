# Lunar Phase Vocabulary — HTML5

**This simulation must be served over HTTP. It will not run from a double-clicked
`index.html` (a `file://` path).**

## Why

The KL-UNL masthead (`foundation/kl-unl-masthead.js`) loads the simulation's
title and its Help / About text with `fetch('foundation/contents.json')`.
Browsers block `fetch()` of local files under the `file://` protocol for
security (same-origin policy), so opening `index.html` directly leaves the
masthead empty or broken — no title, no Reset, no Help, no About.

Served over HTTP the fetch succeeds and the simulation loads normally.

## How to run it locally

Run one of these **from inside this `html5/` folder**:

```
# Python 3
python3 -m http.server 8123      # Windows: python -m http.server 8123

# Node
npx serve
# or
npx http-server
```

Then open <http://localhost:8123/>.

Because you are serving from inside `html5/`, the simulation sits at the server
root — the URL is `http://localhost:8123/`, **not** `.../html5/index.html`.

In VS Code, the **Live Server** extension works too: right-click `index.html` →
*Open with Live Server*.

## Production

Once deployed to the cloud host (served over HTTP/HTTPS) it just works. The
`file://` limitation only affects local double-clicking.

## What's in here

| Path | What it is |
| --- | --- |
| `index.html` | Page scaffold: `.app-shell` + `<kl-unl-masthead>` + panels |
| `foundation/` | Shared KL-UNL files, copied in **byte-for-byte unchanged** |
| `styles/styles.css` | Sim-specific styles only |
| `simulation.js` | All simulation logic |
| `assets/moon.jpg` | The moon photograph exported from the SWF, reused as-is |
| `assets/mathjax/` | MathJax, vendored locally (no CDN) |
| `CONVERSION_NOTES.md` | Behaviour model, ActionScript → HTML5 mapping, deviations |
| `ACCESSIBILITY.md` | WCAG affordances, keyboard map, screen-reader wording |

Everything is local. The only network requests are `foundation/contents.json`,
`assets/moon.jpg`, and the vendored MathJax — nothing leaves the host.
