# Sun's Position on Horizon — HTML5

**This simulation must be served over HTTP. It will not run from a double-clicked
`index.html` (a `file://` path).**

## Why

The KL-UNL masthead component (`foundation/kl-unl-masthead.js`) loads the
simulation's title and its Help / About text with
`fetch('foundation/contents.json')`. Browsers block `fetch()` of local files
under the `file://` protocol for security reasons (the same-origin policy), so
opening `index.html` directly gives you a page with an empty or broken masthead
— no title, no Reset, no Help, no About. Served over HTTP the fetch succeeds and
everything loads normally.

## How to run it locally

Run one of these from **inside this `html5/` folder**:

```bash
# Python 3
python3 -m http.server 8123
```

```bash
# Node
npx serve
# or
npx http-server
```

Or use the **Live Server** extension in VS Code.

Then open <http://localhost:8123/>.

Because you are serving from inside `html5/`, the simulation sits at the server
root — the URL is `http://localhost:8123/`, **not**
`http://localhost:8123/html5/index.html`.

## Production

Once deployed to the cloud host (served over HTTP/HTTPS) it just works. The
`file://` limitation only affects opening the file directly from disk.

## What's in here

| Path | Purpose |
| --- | --- |
| `index.html` | Page scaffold: KL-UNL app shell, masthead, scene panel, controls panel |
| `simulation.js` | All simulation logic, ported from the decompiled ActionScript |
| `styles/styles.css` | Simulation-specific styles only |
| `foundation/` | Shared KL-UNL files, copied in unchanged |
| `assets/scene-data.js` | Generated scene data: shape library, display lists, shadow matrices |
| `assets/shapes/` | The vector shapes exported from the SWF, reused as-is |
| `assets/fonts/` | Monotype Corsiva, the typeface the original scene uses |
| `assets/build_assets.py` | The script that generated `scene-data.js` from the JPEXS export |

No build step is required to run the simulation. `build_assets.py` is kept only
so the generated data can be regenerated and audited against the original SWF;
see `CONVERSION_NOTES.md`.
