# Tidal Bulge Simulator (HTML5)

An accessible HTML5 rebuild of the ClassAction **Tidal Bulge Simulator**
(`tidesim.swf`), built on the shared KL-UNL foundation files.

## This sim must be served over HTTP — it will **not** run from a double-clicked `index.html`

The KL-UNL masthead component (`foundation/kl-unl-masthead.js`) loads the page
title and the Help / About text with `fetch('foundation/contents.json')`.
Browsers block `fetch()` of local files opened over the `file://` protocol
(same-origin policy), so opening `index.html` by double-clicking it shows an
empty / broken masthead and the sim will not initialise. Serving the folder over
HTTP makes the fetch succeed and everything loads normally.

## How to run it locally

Run one of these **from inside this `html5/` folder**, then open the URL it prints:

```bash
python3 -m http.server 8123
```
then open <http://localhost:8123/>

Other options:

```bash
npx serve
```

```bash
npx http-server
```

Or, in VS Code, use the **Live Server** extension.

Because you are serving from *inside* `html5/`, the sim is at the server root —
the URL is `http://localhost:8123/`, **not** `.../html5/index.html`.

## Production

When deployed to the cloud host (served over HTTP/HTTPS) it just works. The
`file://` limitation only affects local double-clicking.

## What it does

A top-down diagram of the Earth–Moon system:

- **Run** — start/stop the animation. The Moon orbits the Earth, the Earth
  spins, and the blue tidal bulges track the Earth–Moon line.
- **Include Sun** — adds day/night shading to the Earth and Moon, a *To Sun*
  arrow, and makes the bulges grow and shrink between spring and neap tides.
- **Include Effects of Earth's Rotation** — drags the tidal bulges ahead of the
  Moon by a fixed lead angle.

Reset / Help / About are provided by the KL-UNL masthead.

## File layout

```
html5/
  index.html          KL-UNL scaffold: .app-shell + <kl-unl-masthead> + panels
  simulation.js       all sim logic (ported from the decompiled ActionScript)
  styles/styles.css   sim-specific styles (layered on top of kl-unl.css)
  assets/             reused bitmaps exported from the SWF (earth, moon, shadows)
  foundation/         KL-UNL files, copied in UNCHANGED
  README.md           this file
  CONVERSION_NOTES.md behaviour model + AS→HTML5 mapping + deviations
  ACCESSIBILITY.md    WCAG affordances, ARIA, keyboard map, live-region wording
```

Serve over HTTP; no build step, bundler, framework, CDN, or network access is
required beyond `foundation/contents.json` (fetched locally by the masthead).
