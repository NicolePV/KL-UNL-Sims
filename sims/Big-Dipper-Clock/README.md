# Big Dipper Clock — HTML5 (KL-UNL accessible build)

An accessible HTML5 rebuild of the original Adobe Flash *Big Dipper Clock*,
built on the shared KL-UNL foundation files.

## ⚠️ This sim must be served over HTTP — it will NOT run from a double-clicked file

Opening `index.html` directly (a `file://` path) shows an empty/broken masthead
and the title, Help, and About text never load.

**Why:** the KL-UNL masthead component (`foundation/kl-unl-masthead.js`) loads its
title / Help / About text with `fetch('foundation/contents.json')`. Browsers block
`fetch()` of local files under the `file://` protocol (same-origin policy), so the
fetch fails and the masthead cannot render. Over HTTP the fetch succeeds and the sim
loads normally.

## How to run locally

Run one of these **from inside this `html5/` folder**, then open the URL it prints:

```
# Python (any 3.x)
python -m http.server 8123
# then open http://localhost:8123/

# Node
npx serve
# (or)  npx http-server

# VS Code
# Install the "Live Server" extension and click "Go Live".
```

Because you serve from inside `html5/`, the sim is at the **server root**, so the URL
is `http://localhost:8123/` — *not* `.../html5/index.html`.

## Production

When deployed to the cloud host (served over HTTP/HTTPS) it just works — the
`file://` limitation only affects local double-clicking.

## Layout of this folder

```
html5/
  index.html          KL-UNL scaffold: .app-shell + <kl-unl-masthead> + panels
  foundation/         KL-UNL files, copied in unchanged (kl-unl-masthead.js,
                      kl-unl.css, kl-unl.js, contents.json)
  styles/styles.css   sim-specific styles only (foundation is never edited)
  simulation.js       all sim logic
  assets/             exported vector shapes reused for the constellation art
                      (262.svg, 273.svg, 271.svg, 274.svg)
  README.md           this file
  CONVERSION_NOTES.md  behavior model, AS→HTML5 mapping, deviations
  ACCESSIBILITY.md    WCAG affordances, ARIA, keyboard map, color notes
```

No build step, no bundler, no framework, no CDN, no analytics. All files are local.
The only runtime fetch is the local `foundation/contents.json`.
