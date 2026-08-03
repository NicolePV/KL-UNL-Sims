# HR Diagram Star Cluster Fitting Explorer (HTML5)

An accessible, self-contained HTML5 rebuild of the legacy Adobe Flash
*Cluster Fitting Explorer* (`clusterFittingExplorer009`, 12 November 2009),
built on the shared **KL-UNL** foundation.

---

## ⚠️ It must be served over HTTP — it will NOT run from a double-clicked file

Opening `index.html` directly (a `file://` path) shows an empty or broken
title bar. **Why:** the KL-UNL masthead component
(`foundation/kl-unl-masthead.js`) loads the title / Help / About text with
`fetch('foundation/contents.json')`, and browsers block `fetch()` of local
files under `file://` for security (same-origin policy). Served over HTTP the
fetch succeeds and the simulation loads normally.

## How to run it locally

From **inside this `html5/` folder**, start any static web server, then open
the URL it prints:

```sh
# Python 3
python3 -m http.server 8300
#   then open  http://localhost:8300/

# Node
npx serve
#   (or)  npx http-server

# VS Code
# Use the "Live Server" extension and "Open with Live Server".
```

Because you serve *from inside* `html5/`, the simulation is at the server
**root** — the URL is `http://localhost:8300/`, **not**
`.../html5/index.html`.

## Production

When deployed to the cloud host (served over HTTP/HTTPS) it just works. The
`file://` limitation only affects local double-clicking.

---

## What's in here

| Path | Purpose |
|------|---------|
| `index.html` | KL-UNL scaffold: `.app-shell` + `<kl-unl-masthead>` + panels. |
| `foundation/` | The shared KL-UNL files, copied in **unchanged** (`kl-unl-masthead.js`, `kl-unl.css`, `kl-unl.js`) plus `contents.json` (this sim's entry + JSON-validity fixes — see `CONVERSION_NOTES.md`). |
| `styles/styles.css` | Sim-specific styles only; the foundation supplies the shared look. |
| `simulation.js` | All simulation logic (physics ported verbatim from the ActionScript). |
| `assets/clusterData.js` | The eight clusters' star data, extracted verbatim from the decompiled `*.as` data symbols. |
| `assets/mathjax/` | MathJax v3 (CHTML output + contextual menu) and its fonts, **vendored locally** so there is no runtime CDN dependency. CHTML lets the plain numbers/variables inherit the page's sans-serif font. |
| `CONVERSION_NOTES.md` | Behaviour model, ActionScript → HTML5 mapping, deviations. |
| `ACCESSIBILITY.md` | WCAG affordances, keyboard map, colour notes, screen-reader wording. |

The only runtime network requests are local: `foundation/contents.json` and
the local MathJax script. Nothing leaves the host.

## Using the simulation

1. **Select a cluster** from the drop-down. Its stars appear as blue points
   (apparent magnitude vs. temperature).
2. **Drag the diagram up/down** (or focus it and use the arrow keys) to slide
   the cluster onto the red model main sequence. The vertical shift is the
   **distance modulus** `m − M`; read the corresponding apparent magnitudes on
   the blue right-hand axis.
3. **Show horizontal bar** adds a movable reference line that reports matching
   absolute (red) and apparent (blue) magnitudes.
4. The **Distance Modulus Calculator** turns your `m` and `M` into
   `m − M` and a distance `d = 10^((m − M + 5)/5)` parsecs.
5. **Reset** (top bar) restores the initial state.
