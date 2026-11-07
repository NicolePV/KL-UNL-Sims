# Galactic Redshift Simulator — HTML5

**This simulation must be served over HTTP. It will _not_ run from a double-clicked
`index.html` (a `file://` path).**

## Why

The KL-UNL masthead component (`foundation/kl-unl-masthead.js`) loads the simulation's
title and its Help / About text with `fetch('foundation/contents.json')`. Browsers block
`fetch()` of local files under the `file://` protocol for security reasons (the
same-origin policy treats every local file as a unique opaque origin), so opening
`index.html` directly gives you an empty or broken masthead — no title, no Reset, no
About — and the console shows
`kl-unl-masthead: Failed to load sim-specific data`.

Served over HTTP the fetch succeeds and everything loads normally.

## How to run it locally

Run one of these **from inside this `html5/` folder**:

```bash
python3 -m http.server 8180
```

```bash
npx serve -l 8180
```

```bash
npx http-server -p 8180
```

Then open **<http://localhost:8180/>**.

Because the server's document root is the `html5/` folder itself, the simulation is at
the server root — the URL is `http://localhost:8180/`, *not*
`http://localhost:8180/html5/index.html`.

In VS Code you can instead right-click `index.html` and choose **Open with Live Server**
(the "Live Server" extension), which does the same thing.

## Production

Once deployed to the cloud host it is served over HTTP/HTTPS like any other page, so it
just works. The `file://` limitation only ever affects local double-clicking.

## What it loads

Everything is local and self-contained — no CDN, no bundler, no build step, no
analytics. The only runtime requests are:

| Request | Purpose |
| --- | --- |
| `foundation/contents.json` | masthead title + Help/About text |
| `foundation/kl-unl.css`, `foundation/kl-unl.js`, `foundation/kl-unl-masthead.js` | shared KL-UNL foundation |
| `foundation/mathjax/tex-mml-chtml.js` (+ its `.woff` fonts) | self-hosted MathJax |
| `styles/styles.css`, `simulation.js`, `assets/spectrum-data.js` | this simulation |

## Layout

```
html5/
  index.html            KL-UNL scaffold: .app-shell + <kl-unl-masthead> + panels
  foundation/           copied unchanged from the source folder's foundation/
                        (contents.json additionally carries this sim's About text
                        and the JSON syntax repairs noted in CONVERSION_NOTES.md)
  styles/styles.css     sim-specific styles only
  simulation.js         all simulation logic
  assets/
    spectrum-data.js    galaxy spectrum + U/B/V/R filter tables, extracted
                        verbatim from the decompiled ActionScript
  README.md             this file
  CONVERSION_NOTES.md   behaviour model, AS -> HTML5 mapping, deviations
  ACCESSIBILITY.md      WCAG affordances, keyboard map, screen-reader notes
```
