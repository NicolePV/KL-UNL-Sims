# Retrograde Motion — HTML5

**This simulation must be served over HTTP. It will not run from a double-clicked
`index.html` (a `file://` path).**

## Why

The KL-UNL masthead component (`foundation/kl-unl-masthead.js`) loads the
simulation's title, Help text and About text with
`fetch('foundation/contents.json')`. Browsers block `fetch()` of local files
under the `file://` protocol for security (same-origin policy), so opening
`index.html` directly gives you a page with an empty or broken masthead — no
title, no Reset, no Help, no About. Served over HTTP the fetch succeeds and the
simulation loads normally.

## How to run it locally

Run one of these from inside this `html5/` folder:

```
python3 -m http.server 8123        # then open http://localhost:8123/
```

```
npx serve                          # or: npx http-server
```

Or use the **Live Server** extension in VS Code.

Note that when you serve from inside `html5/`, the simulation is at the server
root — the URL is `http://localhost:8123/`, not `.../html5/index.html`.

## Production

Deployed to the cloud host over HTTP/HTTPS it just works. The `file://`
limitation only affects local double-clicking.

## What is in here

```
index.html            page scaffold: .app-shell + <kl-unl-masthead> + panels
foundation/           KL-UNL shared files, copied in byte-for-byte unchanged
styles/styles.css     sim-specific styles only
simulation.js         all simulation logic
assets/               exported Flash art reused as-is, plus a local MathJax build
CONVERSION_NOTES.md   behaviour model, ActionScript → HTML5 mapping, deviations
ACCESSIBILITY.md      WCAG affordances, keyboard map, screen-reader wording
```

No build step, no bundler, no framework, no CDN. The only network requests are
local: `foundation/contents.json`, the exported art in `assets/`, and the
vendored MathJax build.
