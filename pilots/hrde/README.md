# Pilot Transformation for HRDE 

## Hertzsprung-Russell Diagram Explorer
This tool shows a HRD and a size comparison figure to illustrate the properties of stars.
  * Nicole created an HTML5 version in 2017; she is revamping it for WCAG AA accessibility in 2026.
    * Determine extent of changes necessary for WCAG AA compliance
    * Test how well Specifications and Style markdown files work to augment LLM interaction
  * Invocations
    * [UNL](https://astro.unl.edu/classaction/animations/stellarprops/hrexplorer.html)
    * [NMSU - 2017](http://astronomy.nmsu.edu/geas/labs/hrde/hrd_explorer.html)
    * 2026 pilot results and notes will appear here soon
  * Primary components
    * HRD, with overlays for regions and to show sets of stars
    * Plot controls for x/y-axis labels, region overlays, and near and bright stellar samples
    * Size comparison plot showing Sun and star underneath HRD cursor
    * Temperature number field and slider bar
    * Luminosity number field and slider bar
    * Equation for radius from luminoisty and temperature
  * Special concerns, all due to accessibility issues
    * Displayed equation needs to be recast via MathJax
    * Slider bars have color gradients and so were done as canvas elements rather than HTML sliders
    * Reset, Help, and About messages were sent to a canvas so text not accessible
    * Intersection of Main Sequence and R = 1 isoradius line displays insufficient contrast
    * Dispayed star samples are not accessible other than as points on HRD
  * Additional features (added in 2017)
    * Temperature slider shows stellar colors along length
    * Luminnosity slider ranges from black through various greys to white along length
    * When HRD cursor is moved, dashed horizontal/vertical lines ending in arrows point to L/T axes;  after two seconds dashed lines disappear (arrows remain)
