# Visual Style & Design Language System - H-R Diagram Explorer

## Objective
Preserve the clean, distinct three-panel layout of the H-R Diagram Explorer while applying modern CSS layout practices and confirming WCAG AA color contrast rules.

## 1. Layout Integrity & Spatial Distribution
* **Three-Panel Grid:** Maintain the structural layout shown in the reference image:
  * Left Column: "Size Comparison" panel stacked on top of the "Cursor Properties" control panel.
  * Right Column: Main "Hertzsprung-Russell Diagram" canvas, with "Plot Labels" and "Plotted Stars" control sections positioned cleanly underneath.
* **Responsive Reflow (WCAG 1.4.10):** Use CSS Grid or Flexbox to allow these columns to gracefully stack vertically on narrow viewports or when zoomed up to 200%, avoiding text overlaps or component clipping.
* **Sizing:** Transition font sizing and padding variables to relative units (`rem`, `em`) instead of fixed pixels (`px`) to allow fluid scaling.

## 2. Color Contrast & Graph Readability (WCAG 1.4.3 / 1.4.11)
* **Isoradius Lines:** The green diagonal isoradius lines ($0.001 R_\odot$ to $1000 R_\odot$) must maintain at least a 3:1 contrast ratio against the white canvas background to remain accessible to low-vision users.
* **Main Sequence Curve:** The brown main sequence evolutionary path line must have sufficient contrast against both the white background and the green background lines.
* **Form Text & Backgrounds:** The text inside input fields, dropdown menus, and labels must meet a strict 4.5:1 contrast ratio against their respective background blocks.

## 3. Interactive Component Sizing
* **Target Sizes (WCAG 2.5.5):** Ensure all clickable targets—including the dropdown scales, checkboxes, radio buttons, and the top-right management buttons (Reset, Help, About)—have a minimum interactive footprint of 44x44 CSS pixels (including padding) to support touch and mobile environments comfortably.