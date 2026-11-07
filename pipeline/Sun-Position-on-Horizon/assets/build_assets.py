"""
Build html5/assets/scene-data.js for the "Sun's Position on Horizon" conversion.

Reads the JPEXS/FFDec export (shapes/*.svg) and the SWF structure XML, and emits:
  - SHAPE_DEFS  : merged <g id="shN"> markup (paths + gradients, ids namespaced)
  - SCENE       : per-view (0=sunrise, 1=sunset) ordered placement lists, in stage units
  - SHADOW_MATS : the 366 per-frame matrices for each of the 7 shadow clips

Nothing here redraws art: every path/gradient is copied verbatim out of the
exported SVG files. Only the surrounding container and id names change.
"""
import re
import json
import xml.etree.ElementTree as ET
from pathlib import Path

SCRATCH = Path(__file__).parent
DECOMP = SCRATCH / "decomp"
OUT = Path(r"D:/University of Nebraska UNL/Summer 26/Sun's Position on Horizon/html5")

TWIP = 20.0  # SWF stores coordinates in twips (1/20 px)

SVG_NS = "http://www.w3.org/2000/svg"
ET.register_namespace("", SVG_NS)


# --------------------------------------------------------------------------
# 1. Shape extraction -- pull the paths + gradient defs out of each shape SVG
# --------------------------------------------------------------------------

def extract_shape(shape_id):
    """Return (inner_markup, defs_markup) in shape-local (registration point) coords.

    Each FFDec shape SVG is:
        <svg><g transform="matrix(1,0,0,1,tx,ty)">...paths...</g><defs>...</defs></svg>
    The outer <g> translate only moves the registration point to the SVG viewport
    origin, so its children are already in the shape-local coords the SWF uses.
    We drop that wrapper and keep the children untouched.
    """
    raw = (DECOMP / "shapes" / f"{shape_id}.svg").read_text(encoding="utf-8")

    # Namespace every internal id (all files reuse "gradient0", "gradient1", ...)
    ids = sorted(set(re.findall(r'id="([^"]+)"', raw)), key=len, reverse=True)
    for i in ids:
        new = f"s{shape_id}_{i}"
        raw = raw.replace(f'id="{i}"', f'id="{new}"')
        raw = raw.replace(f"url(#{i})", f"url(#{new})")
        raw = raw.replace(f'xlink:href="#{i}"', f'xlink:href="#{new}"')
        raw = raw.replace(f'href="#{i}"', f'href="#{new}"')

    root = ET.fromstring(raw)

    def ser(el):
        s = ET.tostring(el, encoding="unicode")
        return re.sub(r'\sxmlns(:\w+)?="[^"]*"', "", s)

    inner, defs = [], []
    for child in root:
        tag = child.tag.split("}")[-1]
        if tag == "defs":
            defs.extend(ser(c) for c in child)
        elif tag == "g":
            # verify it is the plain registration-point translate we expect
            t = child.get("transform", "")
            m = re.match(r"matrix\(1\.0, 0\.0, 0\.0, 1\.0, ([-\d.]+), ([-\d.]+)\)", t)
            assert m, f"shape {shape_id}: unexpected wrapper transform {t!r}"
            inner.extend(ser(c) for c in child)
        else:
            inner.append(ser(child))

    return "".join(inner), "".join(defs)


# --------------------------------------------------------------------------
# 2. SWF timeline extraction
# --------------------------------------------------------------------------

tree = ET.parse(SCRATCH / "horizon.xml")
sprites = {
    e.get("spriteId"): e
    for e in tree.getroot().iter("item")
    if e.get("type") == "DefineSpriteTag"
}


def read_matrix(el):
    m = el.find("matrix")
    if m is None:
        return None
    g = lambda k, d: float(m.get(k, d))
    return dict(
        a=g("scaleX", "1"), b=g("rotateSkew0", "0"),
        c=g("rotateSkew1", "0"), d=g("scaleY", "1"),
        e=g("translateX", "0") / TWIP, f=g("translateY", "0") / TWIP,
    )


# Flash CXFORM: out = clamp(in * mult/256 + add). This is what turns the full
# colour landscape art into the dark silhouettes the sim actually shows, and
# what makes the direction arrows half transparent.
CX_KEYS = [("red", "Mult"), ("green", "Mult"), ("blue", "Mult"), ("alpha", "Mult"),
           ("red", "Add"), ("green", "Add"), ("blue", "Add"), ("alpha", "Add")]


def read_cxform(el):
    c = el.find("colorTransform")
    if c is None:
        return None
    has_mult = c.get("hasMultTerms") == "true"
    has_add = c.get("hasAddTerms") == "true"
    out = []
    for chan, kind in CX_KEYS:
        key = f"{chan}{kind}Term"
        if kind == "Mult":
            out.append(float(c.get(key, "256")) if has_mult else 256.0)
        else:
            out.append(float(c.get(key, "0")) if has_add else 0.0)
    return out


def timeline(sprite_id):
    """Replay a sprite's tags into a list of per-frame display lists."""
    frames, cur = [], {}
    for it in sprites[sprite_id].find("subTags"):
        kind = it.get("type")
        if kind == "ShowFrameTag":
            frames.append({d: dict(o) for d, o in cur.items()})
        elif kind == "PlaceObject2Tag":
            depth = it.get("depth")
            obj = dict(cur.get(depth, {}))
            if it.get("placeFlagHasCharacter") == "true":
                obj["char"] = it.get("characterId")
            mat = read_matrix(it)
            if mat:
                obj["m"] = mat
            cx = read_cxform(it)
            if cx:
                obj["cx"] = cx
            if it.get("name"):
                obj["name"] = it.get("name")
            cur[depth] = obj
        elif kind == "RemoveObject2Tag":
            cur.pop(it.get("depth"), None)
    return frames


IDENTITY = dict(a=1.0, b=0.0, c=0.0, d=1.0, e=0.0, f=0.0)

# Distinct colour transforms, collected so the SVG only needs a handful of
# <filter> elements rather than one per placement.
FILTERS = []


def filter_index(cx):
    """Return the index of this CXFORM in the shared filter table, or None."""
    if cx is None:
        return None
    key = [round(v, 4) for v in cx]
    if key == [256.0, 256.0, 256.0, 256.0, 0.0, 0.0, 0.0, 0.0]:
        return None                      # identity -- no filter needed
    for i, existing in enumerate(FILTERS):
        if existing == key:
            return i
    FILTERS.append(key)
    return len(FILTERS) - 1


# --- shadow clips: sprite id -> the single shape it animates ----------------
SHADOW_SPRITES = {"83": None, "85": None, "87": None, "89": None,
                  "91": None, "93": None, "95": None}
SHADOW_MATS = {}
for sid in SHADOW_SPRITES:
    frames = timeline(sid)
    assert len(frames) == 366, f"sprite {sid}: expected 366 frames, got {len(frames)}"
    inner_char = None
    mats = []
    for fr in frames:
        assert len(fr) == 1, f"sprite {sid}: expected a single child"
        obj = next(iter(fr.values()))
        inner_char = obj["char"]
        m = obj.get("m", IDENTITY)
        mats.append([round(m["a"], 6), round(m["b"], 6), round(m["c"], 6),
                     round(m["d"], 6), round(m["e"], 4), round(m["f"], 4)])
    SHADOW_SPRITES[sid] = int(inner_char)
    SHADOW_MATS[sid] = mats

# --- the horizonMC (sprite 110) stage, frame 1 = sunrise, frame 2 = sunset --
TEXT_CHARS = {103, 104, 105, 106, 109}   # rendered as real text, not artwork
SUN_DEPTH = "3"

scene = {}
used_shapes = set()

for view, frame in enumerate(timeline("110")):
    layers = {"sky": [], "ground": [], "shadows": [], "fg": [], "labels": {}}
    for depth in sorted(frame, key=int):
        obj = frame[depth]
        d = int(depth)
        char = int(obj["char"])
        m = obj.get("m", IDENTITY)

        if depth == SUN_DEPTH:                       # mySun -- handled separately
            continue
        if char in TEXT_CHARS:                       # East / West / To North / ...
            layers["labels"][char] = [m["e"], m["f"]]
            continue

        fi = filter_index(obj.get("cx"))

        if obj.get("name"):                          # a named shadow clip
            shadow = {
                "name": obj["name"],
                "spr": obj["char"],
                "sh": SHADOW_SPRITES[obj["char"]],
                "m": [m["a"], m["b"], m["c"], m["d"], m["e"], m["f"]],
            }
            if fi is not None:
                shadow["f"] = fi
            layers["shadows"].append(shadow)
            used_shapes.add(SHADOW_SPRITES[obj["char"]])
            continue

        # sprite 81 is a one-frame wrapper around shape 80 (the ground band)
        if char == 81:
            inner = timeline("81")[0]
            io = next(iter(inner.values()))
            assert io.get("cx") is None, "sprite 81 inner placement has a CXFORM"
            char = int(io["char"])
            m = dict(m)  # sprite placed at (0,600 twips); inner shape at (0,0)

        p = {"sh": char, "m": [m["a"], m["b"], m["c"], m["d"], m["e"], m["f"]]}
        if fi is not None:
            p["f"] = fi
        used_shapes.add(char)

        if d < 3:
            layers["sky"].append(p)
        elif d < 8:
            layers["ground"].append(p)
        else:
            layers["fg"].append(p)

    scene[view] = layers

# --- the sun clip (sprite 77): glow shape per view + the date label offset --
sun_frames = timeline("77")
SUN = {}
for view, fr in enumerate(sun_frames):
    glow = fr["1"]
    assert glow.get("cx") is None, "sun glow placement has a CXFORM"
    SUN[view] = int(glow["char"])
    used_shapes.add(int(glow["char"]))

# date sprite 75 sits at depth 2 of the sun clip; the text field is inside it
date_m = sun_frames[0]["2"]["m"]
inner_date = next(iter(timeline("75")[0].values()))
DATE_OFFSET = [date_m["e"] + inner_date["m"]["e"], date_m["f"] + inner_date["m"]["f"]]


# --------------------------------------------------------------------------
# 3. Emit
# --------------------------------------------------------------------------

defs_all, shapes_all = [], []
for sh in sorted(used_shapes):
    inner, defs = extract_shape(sh)
    if defs:
        defs_all.append(defs)
    shapes_all.append(f'<g id="sh{sh}">{inner}</g>')
    # keep the untouched original beside the generated bundle, for provenance
    src = DECOMP / "shapes" / f"{sh}.svg"
    (OUT / "assets" / "shapes" / f"{sh}.svg").write_bytes(src.read_bytes())

defs_markup = "".join(defs_all) + "".join(shapes_all)

js = f"""// Generated from the JPEXS/FFDec export of horizon.swf -- do not hand-edit.
// Build script: tools/build_assets.py (see CONVERSION_NOTES.md).
//
// Every path and gradient below is copied verbatim from the exported
// shapes/*.svg files; only element ids are namespaced so the shapes can share
// one document. Coordinates are in stage units (SWF twips / 20), in the local
// space of the original "sun_Gradient" clip, whose visible area is
// x in [-425, 425], y in [-275, 60].

export const STAGE = {{ x: -425, y: -275, w: 850, h: 335 }};

// Flash colour transforms, as feColorMatrix rows. A placement's "f" field is an
// index into this table. out = clamp(in * mult/256 + add/255), which is what
// renders the landscape as dark silhouettes and the arrows at half alpha.
export const FILTERS = {json.dumps(FILTERS, separators=(",", ":"))};

// Shadow clips animate one shape through 366 authored frames; each entry is an
// SVG matrix(a,b,c,d,e,f) taken straight from the SWF PlaceObject2 tags.
export const SHADOW_MATS = {json.dumps(SHADOW_MATS, separators=(",", ":"))};

// Ordered display list per view (0 = sunrise / East, 1 = sunset / West).
export const SCENE = {json.dumps(scene, separators=(",", ":"))};

// Sun glow shape per view, and the date label's offset inside the sun clip.
export const SUN = {json.dumps(SUN, separators=(",", ":"))};
export const DATE_OFFSET = {json.dumps(DATE_OFFSET)};

export const SHAPE_DEFS = {json.dumps(defs_markup)};
"""

(OUT / "assets" / "scene-data.js").write_text(js, encoding="utf-8")

for f in DECOMP.glob("fonts/*.ttf"):
    (OUT / "assets" / "fonts" / f.name.split("_", 1)[1].replace(" ", "")).write_bytes(f.read_bytes())

print("filters      :", FILTERS)
print("shapes reused:", sorted(used_shapes))
print("shadow clips :", SHADOW_SPRITES)
print("sun glow     :", SUN)
print("date offset  :", DATE_OFFSET)
print("labels view0 :", scene[0]["labels"])
print("labels view1 :", scene[1]["labels"])
print("scene-data.js:", (OUT / "assets" / "scene-data.js").stat().st_size, "bytes")
for v in (0, 1):
    print(f"view{v}: sky={len(scene[v]['sky'])} ground={len(scene[v]['ground'])}"
          f" shadows={len(scene[v]['shadows'])} fg={len(scene[v]['fg'])}")
print("shadow frame 1 / 184 / 275 of clip 83:",
      SHADOW_MATS["83"][0], SHADOW_MATS["83"][183], SHADOW_MATS["83"][274])
