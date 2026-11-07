# Determining Moon Phases Using Bisectors — HTML5

An accessible HTML5 conversion of the NAAP/KL‑UNL Flash simulation
`moonbisector.swf` (`moonBisectorDemo005`). Behavior is reproduced from the
decompiled ActionScript; chrome and layout follow the shared KL‑UNL foundation
and WCAG 2.1 AA guidelines.

## This simulation must be served over HTTP — it will NOT run from a double‑clicked `file://` path.

**Why:** the KL‑UNL masthead component (`foundation/kl-unl-masthead.js`) loads
its title, Help, and About text with `fetch('foundation/contents.json')`, and
the simulation loads its geometry data with `fetch('assets/…json')`. Browsers
block `fetch()` of local files under the `file://` protocol (same‑origin
policy), so opening `index.html` by double‑clicking shows an empty/broken
masthead and a blank scene. Served over HTTP the fetches succeed and everything
loads normally.

## How to run locally

Open a terminal **inside this `html5/` folder** and run any one of:

```bash
python3 -m http.server 8123
```

```bash
npx serve
```

```bash
npx http-server
```

Then open **http://localhost:8123/** (for the `python3` command; use the URL the
Node tools print). Because you are serving from inside `html5/`, the simulation
is at the server root — the URL is `http://localhost:8123/`, **not**
`…/html5/index.html`.

VS Code users can instead use the **Live Server** extension ("Go Live").

## Production

When deployed to the cloud host (served over HTTP/HTTPS) it just works. The
`file://` limitation only affects local double‑clicking.

## Folder contents

```
html5/
  index.html            KL-UNL shell: .app-shell + <kl-unl-masthead> + panels
  foundation/           KL-UNL foundation, copied UNCHANGED
                          kl-unl-masthead.js, kl-unl.css, kl-unl.js,
                          contents.json (already contains the "moonbisector" entry),
                          favicons
  styles/styles.css     sim-specific styles only (layout, custom controls)
  simulation.js         all sim logic (3D engine, controls, accessibility)
  assets/               reused exported art + extracted data:
                          orbit.svg      (Flash symbol 25 — orbit ring + arrowhead)
                          sun-arrow.svg  (Flash symbol 27 — labelled Sun-direction arrow)
                          earth-shore.json  (coastline vector data from Globe.as)
                          moon-layers.json  (maria vector data from MainTimeline.as)
  README.md
  CONVERSION_NOTES.md   behavior model, AS→HTML5 mapping, deviations
  ACCESSIBILITY.md      WCAG affordances, keyboard map, live-region wording
```

No build step, bundler, framework, CDN, analytics, or web fonts. All files are
local; the only runtime network requests are to `foundation/contents.json` and
the two local `assets/*.json` data files.
