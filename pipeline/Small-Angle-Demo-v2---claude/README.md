# Small-Angle Approximation Demonstrator — HTML5 (KL-UNL accessible build)

**This simulation must be served over HTTP. It will _not_ run from a
double-clicked `index.html` (a `file://` path).**

## Why it needs a server

The KL-UNL masthead (`foundation/kl-unl-masthead.js`) loads its title, Reset,
and About text by `fetch()`-ing `foundation/contents.json`. Browsers block
`fetch()` of local files under the `file://` protocol (same-origin policy), so
opening `index.html` by double-clicking shows an empty / broken masthead. Served
over HTTP the fetch succeeds and the sim loads normally.

## How to run it locally

Serve from **inside this `html5/` folder**, then open the server root:

```sh
# Python (3.x)
python3 -m http.server 8123
#   then open  http://localhost:8123/

# Node
npx serve            # or:  npx http-server

# VS Code
#   the "Live Server" extension (Open with Live Server)
```

Because you serve from inside `html5/`, the sim is at the **server root** — the
URL is `http://localhost:8123/`, not `.../html5/index.html`.

## Production

When deployed to the cloud host (served over HTTP/HTTPS) it just works — the
`file://` limitation only affects local double-clicking.

## What's here

```
index.html          KL-UNL scaffold: .app-shell + <kl-unl-masthead> + panels
foundation/         shared KL-UNL files, copied in UNCHANGED
                      kl-unl-masthead.js, kl-unl.css, kl-unl.js, contents.json
styles/styles.css   sim-specific styles only (foundation is never edited)
simulation.js       all sim logic (verbatim AS-1 port + canvas rendering)
assets/
  person.png        reused exported observer bitmap (sprites/DefineSprite_66)
  ball.png          reused exported beach-ball bitmap (sprites/DefineSprite_53)
  mathjax/          locally vendored MathJax (no CDN; SVG output)
CONVERSION_NOTES.md  behavior model, AS→HTML5 mapping, deviations
ACCESSIBILITY.md     WCAG affordances, color remaps, keyboard map, live regions
```

No build step, no bundler, no framework, no CDN, no analytics — every file is
local. The only runtime fetch is the local `foundation/contents.json`.

## Browser / OS support

Built to behave identically across operating systems (Windows, **macOS**, Linux,
iOS, Android) and browsers (Chrome, Edge, Firefox, and **Safari** — desktop and
iOS). Notes on how that's achieved:

- **Pointer input is unified.** Mouse, trackpad, touch, and pen all go through one
  Pointer-Events path. The ball drag is driven by window-level listeners (not just
  `setPointerCapture`, which has historically been flaky in WebKit), so it keeps
  tracking even if the pointer leaves the canvas. Non-primary mouse buttons are
  ignored so the right-click / Control-click context menu still works on macOS.
- **Touch.** `touch-action: none` on the canvas lets you drag the ball on
  iPad/iPhone without the page scrolling; `-webkit-user-select`/`-webkit-touch-callout`
  stop Safari from selecting text or showing the image callout mid-drag.
- **Retina / HiDPI** (the default on Mac) is handled by scaling the canvas backing
  store by `devicePixelRatio`, so the diagram is crisp on Mac displays.
- **No reliance on bleeding-edge CSS for layout/behavior.** The canvas keeps its
  intrinsic aspect ratio (from its `width`/`height` attributes) even where the
  `aspect-ratio` property is unsupported; `accent-color` on the sliders is a
  cosmetic enhancement that degrades gracefully on older Safari.
- **Keyboard parity.** Every action (including moving the ball, via the Distance
  slider) is operable from the keyboard the same way on every platform.
- **Reduced motion.** Honors the OS "Reduce motion" setting (e.g. macOS
  System Settings → Accessibility) by skipping the preset ease.

Minimum tested-feature baseline: Safari 13+ (Pointer Events), with the layout and
sliders fully functional; Safari 15+ gets the `aspect-ratio` / `accent-color`
niceties. Human QA on real Safari/macOS hardware is still recommended.
