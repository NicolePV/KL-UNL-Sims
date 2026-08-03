# Planetary Configurations Simulator — HTML5 (KL-UNL)

Accessible HTML5 port of the NAAP *Planetary Configurations Simulator*, built on
the shared KL-UNL foundation. Behaviour is a faithful reproduction of the original
decompiled ActionScript; the chrome and layout follow the KL-UNL foundation and
WCAG 2.1 AA guidelines.

## ⚠️ It must be served over HTTP — double-clicking `index.html` will NOT work

The KL-UNL masthead component (`foundation/kl-unl-masthead.js`) loads the sim's
title / Help / About text with `fetch('foundation/contents.json')`. Browsers block
`fetch()` of local files under the `file://` protocol (same-origin policy), so if
you open `index.html` directly from the file system the masthead comes up empty or
broken. Serve the folder over HTTP and it works normally.

## How to run locally

Run one of these **from inside this `html5/` folder**, then open the printed URL:

```bash
# Python 3
python3 -m http.server 8123
# then open  http://localhost:8123/

# Node (either one)
npx serve
npx http-server
```

Or, in VS Code, use the **Live Server** extension (right-click `index.html` →
"Open with Live Server").

Because you are serving from inside `html5/`, the sim is at the server **root** —
the URL is `http://localhost:8123/`, not `.../html5/index.html`.

## Production

When deployed to the cloud host (served over HTTP/HTTPS) it just works. The
`file://` limitation only affects opening the file locally by double-click.

## Files

```
html5/
  index.html            KL-UNL scaffold: .app-shell + <kl-unl-masthead> + panels
  foundation/           KL-UNL foundation (copied in; see CONVERSION_NOTES.md re contents.json)
  styles/styles.css     sim-specific styles only (foundation is never edited)
  simulation.js         all sim logic, ported from the decompiled ActionScript
  assets/
    zodiac-starfield.png   reused bitmap (original images/203.png)
    constellations.js      reused constellation outline data (original Constellations Data.as)
  README.md             this file
  CONVERSION_NOTES.md   behaviour model, AS→HTML5 mapping, deviations
  ACCESSIBILITY.md      WCAG affordances, ARIA, keyboard map, live-region wording
```

No build step, no bundler, no framework, no CDN. Everything is local; the only
runtime fetch is `foundation/contents.json`.
