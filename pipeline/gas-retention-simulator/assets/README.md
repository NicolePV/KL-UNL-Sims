# assets/

This folder is intentionally empty of reused art.

Every visual element in the original Flash *Gas Retention Simulator* is **drawn in
code at runtime** (ActionScript `createEmptyMovieClip` / `beginFill` / `lineTo` /
`curveTo` / `attachMovie`): the chamber particles, the Maxwell–Boltzmann curves,
the proportions bar chart, the dashed escape‑speed line, and the draggable cursor.
There are **no exported bitmaps or photographs** the sim uses, so there is nothing
to copy in here — all of that art is reproduced with HTML5 `<canvas>` 2D drawing in
`../simulation.js`.

The exported `shapes/*.svg` in the decompiled source are Flash UI‑component skin
pieces (combo box, checkbox, button, slider, scrollbar) and the 3 px particle
circle. Per the pipeline rules the Flash UI components are replaced with native,
accessible HTML controls rather than reused, so those SVGs are not needed either.
