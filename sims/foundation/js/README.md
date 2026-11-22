# KL-UNL Pipeline Foundations

## Foundation Files
Foundation files are designed to be referenced by an HTML file within the
workspace for a simulation. They provide a uniform masthead, style, and set of
common functions, and set up MathJax for displayed equations.
    * Masthead:                         kl-unl-masthead.js
    * Masthead:                         kl-unl-masthead.json
    * Equations:                        kl-unl-mathjax.js
    * Utilities:                        kl-unl-utils.js
      (screen reader timing: SR_FLUSH_MS, SR_SETTLE_MS, announceLive,
       announceSettled; flash safety: createFlashLimiter;
       URL saving: descMoreKeys, hideMoreKeys, buildURL)
                                        kl-unl-dual-control.js
    * Celestial Sphere:                 kl-unl-celestial-sphere.js
      (includes drawCircleArcBack, projectPointScreen / isScreenFront,
       drawSphereRim, drawStarSprite, drawCircleHatch for optional plane hatching)
    * Globe:                            kl-unl-globe.js
    * Earth coastlines:                 kl-unl-earth-shores.js
    * Constellations:                   kl-unl-zodiacal-constellations.js
                                        kl-unl-constellations.json
    * Shading:                          kl-unl-sphere-shading.js
    * Style (utilities):         ../css/kl-unl-utils.css
    * Style (cursors):           ../css/kl-unl-cursors.css
    * Style (DualControl class): ../css/kl-unl-dual-control.css
    * Icon:           ../images/klunl_favicon_32.png
    * Icon:           ../images/klunl_favicon_180.png
    * Icon:           ../images/klunl_ping.png
