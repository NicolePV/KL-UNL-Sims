# WCAG AA Accessibility Specifications - H-R Diagram Explorer

## Objective
Update this interactive astronomy tool (HTML/JS/CSS) to meet WCAG AA compliance. It must be fully navigable via keyboard, clearly parsed by screen readers, and structured semantically without disrupting the core canvas plotting logic.

## 1. Keyboard Navigation & Input Synchronization (WCAG 2.1.1)
* **Synchronized Controls:** The Temperature and Luminosity controls feature paired numeric inputs (`<input type="number">`) and slider bars. Ensure both are native HTML form elements or accessible ARIA sliders, and that updating one instantly updates the other, the canvas red 'X' cursor, and the size comparison panel.
* **Focus Order:** Ensure a logical `tabindex` progression: Top header buttons (Reset, Help, About) -> Cursor Properties inputs -> Plot Labels selections -> Plotted Stars selections.
* **Focus Indicator:** Visible focus outlines must remain active for all keyboard users (minimum 3:1 contrast ratio against the background).

## 2. Dynamic Canvas Fallbacks & Live Regions (WCAG 1.1.1 / 4.1.3)
* **H-R Diagram Canvas:**
  * Add a visually hidden, screen-reader-accessible table (`.sr-only`) containing the coordinate data points of the currently active star catalog (e.g., "the nearest stars"). 
  * CRITICAL LOGIC GUARD: Do not alter the directional calculation of the x-axis canvas plotting. Temperature must remain inverted (40,000K on the left, 2,500K on the right).
* **Size Comparison Canvas:**
  * Provide an invisible `aria-live="polite"` container that updates whenever the user adjusts T or L. 
  * **Announcement Template:** "Calculated star radius is now [X] solar radii. Visual comparison updated."
* **Equation Accessibility:**
  * The graphic mathematical formula calculating the Radius must have an `aria-label` or an accompanying screen-reader-only element that reads the relationship clearly.
  * **Example Label:** `aria-label="Radius equals the square root of Luminosity, divided by the square of the ratio of the star's temperature to the Sun's temperature. Current value is [X] solar radii."`

## 3. Form Semantics & Labels (WCAG 1.3.1 / 4.1.2)
* **Grouped Choices:** Group the "Plot Labels" checkboxes and the "Plotted Stars" radio buttons into semantic HTML `<fieldset>` containers with descriptive `<legend>` tags (e.g., `<legend>Plotted Stars Selection</legend>`).
* **Explicit Associations:** Ensure every checkbox, dropdown (`<select>`), and radio button has an explicit, programmatically linked `<label for="...">` matching the input ID.