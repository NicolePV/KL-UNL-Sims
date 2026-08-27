/* ===========================================================================
   Azimuth/Altitude Demonstrator: HTML5 port of altAzDemo005 (legacy Flash AS1)
   ---------------------------------------------------------------------------
   Rendering uses an HTML5 <canvas> for code-drawn geometry (sphere shading,
   horizon plane, circles, arcs, pole stubs, markers, and feature labels) and
   images for the star and stick figure. Named labels and degree readouts are 
   announced via canvas aria-label and live region.
   
   Math (rotation matrices, great/small-circle front/back splitting,
   screen<->horizon conversion, drag + snapping) is kept identical to legacy 
   source so positions, arcs and drag behaviour match original exactly.
   =========================================================================== */

  // Import celestial sphere and utilities module components
  import {
    CelestialSphere, Circle, Line,
    CELESTIAL_SPHERE_COLORS, 
    D2R, R2D, TWO_PI, HALF_PI, PI,
    locateStar
  } from '../foundation/js/kl-unl-celestial-sphere.js';

  import {
    legToFixed, speak, pMod, snapFixed, amplifyArrowKey, updateSliderProgress,
    hexToRGBA, soon, announceLive, logAct
  } from '../foundation/js/kl-unl-utils.js';

  // Log initialization, browser, platform, and screen size in server access log
  logAct("INIT_AltAz");

  /* =========================================================================
     App: controller, canvas renderer, UI wiring.
     Projection engine: foundation/js/kl-unl-celestial-sphere.js
     ========================================================================= */
  class App {
    constructor() {
      this.S     = new CelestialSphere();
      this.S.CSC = CELESTIAL_SPHERE_COLORS;
      this.S.setSize(320);              // sphereMC.size = 320  -> r = 160
      this.S.setMinPhi(1);              // minViewerAltitude = 1
      this.S.setMaxPhi(90);

      this.STAGE  = 440;                // canvas internal size (square)
      this.CENTER = 220;
      this.dpr    = Math.max(1, Math.min(3, window.devicePixelRatio || 1));

      // star state (horizon az/alt in degrees)
      this.star = { az: 140, alt: 45, sp: { x: 0, y: 0, z: 0 } };

      // label checkbox visibility (zenith/horizon/nadir/meridian)
      this.labels = { zenith: false, horizon: false, nadir: false, meridian: false };

      this.buildCircles();
      this.buildLines();
      this.cacheDom();
      this.loadAssets();
      this.bindEvents();

      this.reset();
    }

    /* =========================================================================
       Define fixed and shifting circles and arcs on celestial sphere
         - meridian2: secondary great circle          (faint grey, zenith-E-nadir-W)
         - altCircle: stellar guide small circle      (light grey, at altitude)
         - azCircle:  stellar guide half-great circle (light grey, at azimuth )
         - meridian:  principal great circle          (dark green, zenith-N-nadir-S)
         - altArc:    stellar guide arc               (red,        at azimuth )
         - azArc:     stellar guide arc               (blue,       at horizon )
       ========================================================================= */
    buildCircles() {
      const S = this.S;
      this.meridian2 = new Circle(S, { thickness: 1, color: this.S.CSC.MRDN2_CIRC, alpha: 0.1 });
      this.azCircle  = new Circle(S, { thickness: 1, color: this.S.CSC.AZ_CIRC,    alpha: 1   });
      this.altCircle = new Circle(S, { thickness: 1, color: this.S.CSC.ALT_CIRC,   alpha: 1   });
      this.meridian  = new Circle(S, { thickness: 2, color: this.S.CSC.MRDN_CIRC,  alpha: 1   });
      this.azArc     = new Circle(S, { thickness: 3, color: this.S.CSC.AZ_ARC,     alpha: 1   });
      this.altArc    = new Circle(S, { thickness: 3, color: this.S.CSC.ALT_ARC,    alpha: 1   });

      this.meridian2.setParameters({ az: 90, alt: 0, tilt: 90 });
      this.azCircle.setParameters ({ az:  0, alt: 0, tilt: 90 });
      this.altCircle.setParameters({ az:  0, alt: 0, tilt: 90 });
      this.meridian.setParameters ({ az:  0, alt: 0, tilt: 90 });
      this.azArc.setParameters    ({ az:  0, alt: 0, tilt:  0 });
      this.altArc.setParameters   ({ az:  0, alt: 0, tilt: 90 });

      // Draw guides first, and then stellar coordinates
      this.circles = [this.meridian2, this.azCircle, this.altCircle,
                      this.meridian,  this.azArc,    this.altArc];
    }

    /* =========================================================================
       Define fixed line segments (label markers) on celestial sphere
         - North Pole: line segment (dark grey, zenith-up)
         - South Pole: line segment (dark gray, nadir-down)
       ========================================================================= */
    buildLines() {
      const S    = this.S;
      const end1 = 1.0;
      const end2 = 1.2;
      this.npLine = new Line(S, { thickness: 2, color: this.S.CSC.POLE_LNSG, alpha: 1 },
                                { az: 0, alt:  90, r: end1 }, { az: 0, alt:  90, r: end2 });
      this.spLine = new Line(S, { thickness: 2, color: this.S.CSC.POLE_LNSG, alpha: 1 },
                                { az: 0, alt: -90, r: end1 }, { az: 0, alt: -90, r: end2 });
      this.lines = [this.npLine, this.spLine];
    }

    cacheDom() {
      this.canvas        = document.getElementById('sky');
      this.ctx           = this.canvas.getContext('2d');
      this.canvas.width  = this.STAGE * this.dpr;
      this.canvas.height = this.STAGE * this.dpr;
      this.ctx.scale(this.dpr, this.dpr);

      this.azSlider  = document.getElementById('azSlider' );
      this.altSlider = document.getElementById('altSlider');
      this.azNumber  = document.getElementById('azNumber' );
      this.altNumber = document.getElementById('altNumber');
      this.chk = {
        zenith:   document.getElementById('chkZenith'  ),
        horizon:  document.getElementById('chkHorizon' ),
        nadir:    document.getElementById('chkNadir'   ),
        meridian: document.getElementById('chkMeridian')
      };
      this.desc       = document.getElementById('diagramDesc');
      this.starHandle = document.getElementById('starHandle' );
    }

    loadAssets() {
      this.imgStar      = new Image();
      this.imgStarHover = new Image();  // adds dark border
      this.imgStick     = new Image();
      let pending = 3;
      const done = () => { if (--pending === 0) this.render(); };
      this.imgStar.onload      = done; this.imgStar.onerror      = done;
      this.imgStarHover.onload = done; this.imgStarHover.onerror = done;
      this.imgStick.onload     = done; this.imgStick.onerror     = done;
      this.imgStar.src         = 'images/star.png';
      this.imgStarHover.src    = 'images/star-hover.png';
      this.imgStick.src        = 'images/stickfigure.png';
      this.starHovered         = false;
    }

    // ----------------------------------------------------------------------
    // Controller methods
    // ----------------------------------------------------------------------
    reset() {
      this.setStarLocation({ az: 140, alt: 45 });
      this.S.setThetaAndPhi(190, 28);
      this.onSphereOrientationChanged();
      this.hideAllLabels();
      this.render();
      this.announce(true);
    }

    onSphereOrientationChanged() {
      // horizonLabel sits on horizon at az = 394 - theta(deg)
      this.horizonAz = 394 - this.S.getTheta();
      this.render();
    }

    updateLabels() {
      this.labels.zenith   = this.chk.zenith.checked;
      this.labels.horizon  = this.chk.horizon.checked;
      this.labels.nadir    = this.chk.nadir.checked;
      this.labels.meridian = this.chk.meridian.checked;

      // Disable show all or hide all buttons as appropriate
      document.getElementById('showAllBtn').disabled = false;
      document.getElementById('hideAllBtn').disabled = false;
      if ( ( this.chk.zenith.checked + this.chk.horizon.checked +
             this.chk.nadir.checked  + this.chk.meridian.checked ) == 0 )  {
        document.getElementById('hideAllBtn').disabled = true;
      }
      if ( ( this.chk.zenith.checked + this.chk.horizon.checked +
             this.chk.nadir.checked  + this.chk.meridian.checked ) == 4 )  {
        document.getElementById('showAllBtn').disabled = true;
      }
      this.render();
      this.announce();
    }
    setAllLabelsVisibility(v) {
      this.chk.zenith.checked = v; this.chk.horizon.checked  = v;
      this.chk.nadir.checked  = v; this.chk.meridian.checked = v;
      this.updateLabels();
    }
    showAllLabels() { this.setAllLabelsVisibility(true);  }
    hideAllLabels() { this.setAllLabelsVisibility(false); }

    onPositionSliderChanged() {
      this.setStarLocation({ az:  Number(this.azSlider.value),
                             alt: Number(this.altSlider.value) }, true);
      this.render();
    }

    setStarLocation(pt, skipSliderSync) {
      const S = this.S;
      if (pt.az !== 360) pt.az = pMod(pt.az, 360);

      this.star.az  = pt.az;
      this.star.alt = pt.alt;

      // azArc: horizon arc from (360-az) back to 0, hidden when az == 0
      if (pt.az !== 0) {
        this.azArc.setParameters({   az: 0,     alt: 0,      tilt:  0, gammaStart: 360 - pt.az, gammaEnd:  0     });
        this.azArc.visible = true;
      } else {
        this.azArc.visible = false;
      }
      this.azCircle.setParameters({  az: pt.az, alt: 0,      tilt: 90, gammaStart: -90,         gammaEnd: 90     });

      // altArc: vertical arc from horizon up (or down) to the star
      if (pt.alt < 0) {
        this.altArc.setParameters({  az: pt.az, alt: 0,      tilt: 90, gammaStart: pt.alt,      gammaEnd:  0     });
        this.altArc.visible = true;
      } else if (pt.alt > 0) {
        this.altArc.setParameters({  az: pt.az, alt: 0,      tilt: 90, gammaStart:   0,         gammaEnd: pt.alt });
        this.altArc.visible = true;
      } else {
        this.altArc.visible = false;
      }
      this.altCircle.setParameters({ az: 0,     alt: pt.alt, tilt:  0 });

      if (!skipSliderSync) {
        this.azSlider.value  = pt.az;
        this.altSlider.value = pt.alt;
        this.azNumber.value  = legToFixed(pt.az,  1);
        this.altNumber.value = legToFixed(pt.alt, 1);
      }
      // Spoken values include angle name and degrees unit.
      this.azSlider.setAttribute ('aria-valuetext', 'Azimuth '  + speak(pt.az,  1, 'degree'));
      this.altSlider.setAttribute('aria-valuetext', 'Altitude ' + speak(pt.alt, 1, 'degree'));
    }

    // ----------------------------------------------------------------------
    // Rendering
    // ----------------------------------------------------------------------
    render() {
      const S = this.S, ctx = this.ctx, cx = this.CENTER, cy = this.CENTER, r = S.c.r;

      // recompute geometry
      for (const c of this.circles) c.update();
      for (const l of this.lines  ) l.update();

      // star + markers screen positions
      const starP = {}; S.parsePointInput({ az: this.star.az, alt: this.star.alt, r: 1 }, starP);
      this.star.p = starP;
      S.WtoSz(starP, this.star.sp);
      const zenithSp = {}; S.WtoSz({ x: 0, y: 0, z:  1 }, zenithSp);
      const nadirSp  = {}; S.WtoSz({ x: 0, y: 0, z: -1 }, nadirSp );
      this.computeLabelAnchors(zenithSp, nadirSp);

      // Fill slider from 0 to thumb position
      updateSliderProgress(document.getElementById('azSlider' ));
      updateSliderProgress(document.getElementById('altSlider'));

      ctx.clearRect(0, 0, this.STAGE, this.STAGE);
      ctx.save();
      ctx.translate(cx, cy);

      // For star, legacy fS/bS bands keyed on screen depth (sp.z),
      // not world altitude — drawn after circles in the matching hemisphere.
      const starFront = this.star.sp.z >= 0;

      // Legacy line layers: bE (unmasked, behind) → shading →
      // bI (under plane) → horizon → aI (over plane) → front circles → fE.
      // External stubs use full alpha; only back *circles* are dimmed.
      this.drawLineLayer(   'bE');
      this.drawCircleBucket('back');
      this.drawValueLabels( 'back');           // before glass and stick figure
      this.drawNamedLabels( 'back');           // before glass (far-side names)
      this.drawMarker({ x: 0, y: 0, z: -1 });  // nadir ring (_bF after _bEL)
      if (!starFront) this.drawStar();         // bS: after back circles

      // Frosted-glass sphere body: a translucent grey disk that sits between
      // the far and near halves, so far-side circles read as fainter (seen
      // "through" the front of the sphere). Also gives the sphere shape.
      this.drawGlass();

      this.drawLineLayer(   'bI');             // inner-below, under the plane
      this.drawHorizonPlane();
      this.drawLineLayer(   'aI');             // inner-above, over the plane
      this.drawAzArcBack();                    // far azArc on the green rim (after plane)

      // Cardinal labels on horizon plane, split by screen depth so stick 
      // figure occludes labels behind it.
      this.drawCardinals(   'back');
      this.drawStick();                        // observer stands on the plane
      this.drawCardinals(   'front');

      // Near-side geometry (in front of sphere center), full strength
      this.drawCircleBucket('front');
      this.drawMarker({ x: 0, y: 0, z: 1 });   // zenith ring (_fF) before npLine
      this.drawLineLayer(   'fE');             // npLine through the ellipse center
      if (starFront) this.drawStar();          // fS: after front circles
      this.drawValueLabels( 'front');          // after stick and front arcs
      this.drawNamedLabels( 'front');          // near-side names, after geometry

      ctx.restore();

      this.positionOverlay();
      this.updateCanvasDescription();
    }

    drawCircleBucket(which) {
      const ctx = this.ctx;
      const dim = (which === 'back') ? 0.55 : 1;   // far-side lines read fainter
      for (const c of this.circles) {
        // Far azArc is coplanar with green disk; painting it here (before
        // the plane) gets covered by the fill. drawAzArcBack() strokes it after.
        if (which === 'back' && c === this.azArc) continue;
        const paths     = c[which];  if (!paths.length) continue;
        ctx.lineCap     = 'round';  // smooths AltAz zeropoint appearance
        ctx.lineWidth   = Math.max(1, c.thick);
        ctx.strokeStyle = c.color;
        ctx.globalAlpha = (c.alpha ) * dim;
        for (const p of paths) {
          ctx.beginPath();
          ctx.moveTo(p.move[0], p.move[1]);
          for (const cu of p.curves) ctx.quadraticCurveTo(cu[0], cu[1], cu[2], cu[3]);
          ctx.stroke();
        }
      }
      ctx.globalAlpha = 1;
    }

    // Far-side azimuth arc, painted after the horizon plane so green fill
    // does not cover it. Same geometry (alt = 0); dimmed like other back
    // circles, with a white halo so blue stays readable on dark rim.
    //
    // Note that without this addition, far-side blue arc appeared to be
    // absent.
    drawAzArcBack() {
      const c     = this.azArc;  if (!c.visible)    return;
      const paths = c.back;      if (!paths.length) return;
      const ctx   = this.ctx;
      const strokePaths = () => {
        for (const p of paths) {
          ctx.beginPath();
          ctx.moveTo(p.move[0], p.move[1]);
          for (const cu of p.curves) ctx.quadraticCurveTo(cu[0], cu[1], cu[2], cu[3]);
          ctx.stroke();
        }
      };
      ctx.save();
      ctx.lineCap     = 'round';
      ctx.lineJoin    = 'round';
      ctx.globalAlpha = (c.alpha ) * 0.55;
      ctx.strokeStyle = hexToRGBA( this.S.CSC.AZ_ARC_BCK, 0.9 );
      ctx.lineWidth   = 5;
      strokePaths();
      ctx.strokeStyle = c.color;
      ctx.lineWidth   = Math.max(1, c.thick);
      strokePaths();
      ctx.restore();
    }

    // Stroke lines (bE / fE / aI / bI) at line's own alpha value.
    // External back stubs (bE) stay full strength so the part past the rim
    // is not dimmed; the glass disk covers the overlapping portion.
    drawLineLayer(which) {
      const ctx = this.ctx;
      for (const l of this.lines) {
        const segs      = l[which];  if (!segs.length) continue;
        ctx.lineWidth   = Math.max(1, l.thick);
        ctx.strokeStyle = l.color;
        ctx.globalAlpha = l.alpha;
        for (const s of segs) {
          ctx.beginPath();
          ctx.moveTo(s.move[0], s.move[1]);
          ctx.lineTo(s.line[0], s.line[1]);
          ctx.stroke();
        }
      }
      ctx.globalAlpha = 1;
    }

    drawHorizonPlane() {
      const ctx = this.ctx, S = this.S, r = S.c.r;
      // The horizon plane is the (horizontal) alt=0 circle. Its orthographic
      // projection is an axis-aligned ellipse: full width (semi-axis r) and a
      // vertical semi-axis r*sin(phi) that opens/closes with the view altitude
      // (phi) but does not rotate with the azimuth (theta). Rotation only
      // repositions the direction labels (separately drawn).
      const yscale = Math.sin(S.phi);             // r*sin(phi) / r
      ctx.save();
      ctx.scale(1, yscale);                       // squash circle into the horizon ellipse
      const above = S.phi > 0;
      const g = ctx.createRadialGradient(0, 0, r * 0.05, 0, 0, r);
      if (above) {                                // above horizon (bright greens)
        g.addColorStop(0,    this.S.CSC.HOR_ABV_1);
        g.addColorStop(0.75, this.S.CSC.HOR_ABV_2);
        g.addColorStop(1,    this.S.CSC.HOR_ABV_3);
      } else {                                    // below horizon (dark greens)
        g.addColorStop(0,    this.S.CSC.HOR_BLW_1);
        g.addColorStop(1,    this.S.CSC.HOR_BLW_2);
      }
      ctx.beginPath(); ctx.arc(0, 0, r, 0, TWO_PI);
      ctx.fillStyle = g; ctx.fill();
      ctx.restore();
    }

    // Marker: small open ring, setOrientationType("absolute") with no args
    // (normal = radial) so it lies flat on the sphere and foreshortens to an
    // ellipse as phi changes. At the poles that is yscale = ±sin(phi).
    drawMarker(p) {
      const ctx = this.ctx;
      const n = { x: p.x, y: p.y, z: p.z };
      let u;
      if (!(n.x === 0 && n.y === 0)) {
        const ux = -n.x * n.z, uy = -n.z * n.y, uz = n.x * n.x + n.y * n.y;
        const m = Math.sqrt(ux * ux + uy * uy + uz * uz);
        u = { x: ux / m, y: uy / m, z: uz / m };
      } else {
        u = { x: 0, y: 1, z: 0 };
      }
      const o = this.absOrient(p, n, u);
      ctx.save();
      ctx.translate(o.sp.x, o.sp.y);
      ctx.rotate(o.shellRot);
      ctx.scale(1, o.yscale);
      ctx.rotate(o.instRot);
      ctx.lineWidth   = 1.5;
      ctx.strokeStyle = this.S.CSC.POLE_MRK1;
      ctx.fillStyle   = hexToRGBA( this.S.CSC.POLE_MRK2, 0.9 );
      ctx.beginPath(); ctx.arc(0, 0, 4, 0, TWO_PI);
      ctx.fill(); ctx.stroke();
      ctx.restore();
    }

    // Frosted-glass sphere body. Translucent grey radial fill: clearer in the
    // center, denser at the rim (also draws sphere outline). Because it is
    // painted after the far-side geometry, back-side meridian/azimuth/altitude
    // lines show through it muted, while near-side lines (drawn after) stay
    // full strength -- the depth cue the original conveyed with masked shading.
    drawGlass() {
      const ctx = this.ctx, r = this.S.c.r;
      const g = ctx.createRadialGradient(0, 0, r * 0.1, 0, 0, r);
      g.addColorStop(0,    hexToRGBA( this.S.CSC.CSPHERE_1, 0.32));
      g.addColorStop(0.80, hexToRGBA( this.S.CSC.CSPHERE_2, 0.38));
      g.addColorStop(1,    hexToRGBA( this.S.CSC.CSPHERE_3, 0.52));
      ctx.beginPath(); ctx.arc(0, 0, r, 0, TWO_PI);
      ctx.fillStyle = g; ctx.fill();
    }

    // Calculate screen transform at world point p, with unit normal n and up
    // vector u, to foreshorten (yscale = normal's screen-z) and rotate for 
    // alignment tangent to the sphere with "up" along u. 
    absOrient(p, n, u) {
      const S       = this.S, c = S.c;
      const sp      = {}; S.WtoSz(p, sp);
      const sp_n    = {}; S.WtoSz({ x: p.x + n.x, y: p.y + n.y, z: p.z + n.z }, sp_n);
      const sp_u    = {}; S.WtoSz({ x: p.x + u.x, y: p.y + u.y, z: p.z + u.z }, sp_u);
      const npz     = (n.x * c.a6 + n.y * c.a7 + n.z * c.a8) / c.r;   // shell yscale factor
      const A       = Math.atan2(sp_n.y - sp.y, sp_n.x - sp.x) + HALF_PI; // shell rotation
      const cA      = Math.cos(A), sA = Math.sin(A);
      const x0      = sp_u.x - sp.x,     y0 = sp_u.y - sp.y;
      const x1      = cA * x0 + sA * y0, y1 = -sA * x0 + cA * y0;
      const instRot = Math.atan2(y1 / npz, x1) + HALF_PI;          // instance rotation
      return { sp, yscale: npz, shellRot: A, instRot };
    }

    // Default absolute orientation: normal = radial, up in the meridional plane
    radialUp(p) {
      const n = { x: p.x, y: p.y, z: p.z };
      let u;
      if (!(n.x === 0 && n.y === 0)) {
        const ux = -n.x * n.z, uy = -n.z * n.y, uz = n.x * n.x + n.y * n.y;
        const m  = Math.sqrt(ux * ux + uy * uy + uz * uz);
        u = { x: ux / m, y: uy / m, z: uz / m };
      } else {
        u = { x: 0,      y: 1,      z: 0      };
      }
      return { n, u };
    }

    // Stick figure (observer) standing at the sphere center. setOrientationType
    // ("absolute", normal (-1,0,0), up = zenith (0,0,1)) -> tilts/foreshortens
    // with the local ground as view rotates.
    drawStick() {
      const ctx = this.ctx;  if (!this.imgStick.naturalWidth) return;
      const sc  = 1.2;
      const w   = this.imgStick.naturalWidth  * sc;
      const h   = this.imgStick.naturalHeight * sc;
      const o   = this.absOrient({ x: 0, y: 0, z: 0 }, { x: -1, y: 0, z: 0 }, { x: 0, y: 0, z: 1 });
      ctx.save();
      ctx.translate(o.sp.x, o.sp.y);
      ctx.rotate(o.shellRot);
      ctx.scale(1, o.yscale);
      ctx.rotate(o.instRot);
      ctx.drawImage(this.imgStick, -w / 2, -h, w, h);   // feet at the origin
      ctx.restore();
    }

    // NESW labels are inlaid on the horizon plane.
    static get CARDINAL_R() { return 0.88; }  // inside green rim
    static get CARDINALS() {
      return [
        { t: 'N', az:   0 }, { t: 'E', az:  90 },
        { t: 'S', az: 180 }, { t: 'W', az: 270 }
      ];
    }

    drawCardinalLabel(az, text) {
      const ctx = this.ctx, S = this.S;
      const p   = {};
      S.parsePointInput({ az, alt: 0, r: App.CARDINAL_R }, p);
      const n   = { x: 0, y: 0, z: 1 };
      const u   = { x: 1, y: 0, z: 0 };   // N's plane "up" — same for all cardinals
      const o   = this.absOrient(p, n, u);
      ctx.save();
      ctx.translate(o.sp.x, o.sp.y);
      ctx.rotate(o.shellRot);
      ctx.scale(1, o.yscale);
    //ctx.rotate(o.instRot - az * D2R); // letters tops point towards stick figure
      ctx.rotate(o.instRot);
      ctx.lineJoin     = 'round';
      ctx.miterLimit   = 2;
      ctx.font         = '600 25px system-ui, -apple-system, Segoe UI, sans-serif';
      ctx.textAlign    = 'center';
      ctx.textBaseline = 'middle';
      ctx.lineWidth    = 3;
      ctx.strokeStyle  = this.S.CSC.NESW_LINE;
      ctx.fillStyle    = this.S.CSC.NESW_FILL;
      ctx.strokeText(text, 0, 0);
      ctx.fillText(  text, 0, 0);
      ctx.restore();
    }

    // which: 'back' (sp.z < 0, before figure) or 'front' (sp.z >= 0, after figure)
    drawCardinals(which) {
      if (this.S.phi <= 0) return;
      const S   = this.S;
      for (const c of App.CARDINALS) {
        const p = {}, sp = {};
        S.parsePointInput({ az: c.az, alt: 0, r: App.CARDINAL_R }, p);
        S.WtoSz(p, sp);
        const behind = sp.z < 0;
        if ((which === 'back' && behind) || (which === 'front' && !behind)) {
          this.drawCardinalLabel(c.az, c.t);
        }
      }
    }

    drawValueLabel(pt, text, ltrColor) {
      const ctx = this.ctx, S = this.S;
      const p   = {};
      S.parsePointInput({ az: pt.az, alt: pt.alt, r: 1.001 }, p);
      const { n, u } = this.radialUp(p);
      const o        = this.absOrient(p, n, u);
      ctx.save();
      ctx.translate(o.sp.x, o.sp.y);
      ctx.rotate(o.shellRot);
      ctx.scale(1, o.yscale);
      ctx.rotate(o.instRot);
      ctx.lineJoin     = 'round';
      ctx.miterLimit   = 2;
      ctx.font         = '700 16px system-ui, -apple-system, Segoe UI, sans-serif';
      ctx.textAlign    = 'center';
      ctx.textBaseline = 'middle';
      ctx.lineWidth    = 3;
      ctx.strokeStyle  = this.S.CSC.LABEL_HALO;
      ctx.fillStyle    = ltrColor;
      ctx.strokeText(text, 0, 0);  // light halo provides contrast around label
      ctx.fillText(  text, 0, 0);  // label within halo
      ctx.restore();
    }

    // which: 'back' (sp.z < 0, before figure) or 'front' (sp.z >= 0, after figure).
    // Az and alt are treated independently, as they can lie on opposite hemispheres.
    drawValueLabels(which) {
      const S = this.S;
      const specs = [
        { pt: { az: this.star.az - 13, alt: 5 },
          text: legToFixed(this.star.az,  1) + '°', color: this.S.CSC.AZ_LABEL  },
        { pt: { az: this.star.az + 13, alt: this.star.alt / 2 },
          text: legToFixed(this.star.alt, 1) + '°', color: this.S.CSC.ALT_LABEL }
      ];
      for (const s of specs) {
        const p = {}, sp = {};
        S.parsePointInput({ az: s.pt.az, alt: s.pt.alt, r: 1.001 }, p);
        S.WtoSz(p, sp);
        const behind = sp.z < 0;
        if ((which === 'back' && behind) || (which === 'front' && !behind)) {
          this.drawValueLabel(s.pt, s.text, s.color);
        }
      }
    }

    // Star. setOrientationType("absolute") with no args -> normal = radial (the
    // star's own direction), so the sprite lies flat against sphere surface
    // and foreshortens toward limb instead of always facing viewer.
    drawStar() {
      const ctx = this.ctx;
      const img = (this.starHovered && this.star.sp.z > 0) ? this.imgStarHover : this.imgStar;
      if (!img.naturalWidth) return;
      const w   = img.naturalWidth, h = img.naturalHeight;
      const p   = this.star.p;                       // unit point (r = 1)
      const { n, u } = this.radialUp(p);
      const o   = this.absOrient(p, n, u);
      ctx.save();
      ctx.translate(o.sp.x, o.sp.y);
      ctx.rotate(o.shellRot);
      ctx.scale(1, o.yscale);
      ctx.rotate(o.instRot);
      ctx.drawImage(img, -w / 2, -h / 2, w, h);     // burst centered on the point
      ctx.restore();
    }

    // Anchor screen points for four named feature labels (used by the leader
    // lines and the offset text placement).
    computeLabelAnchors(zenithSp, nadirSp) {
      const S = this.S;
      const project = (pt) => { const o = {}, sp = {}; S.parsePointInput(pt, o); S.WtoSz(o, sp); return sp; };
      this._labelAnchor = {
        zenith:   zenithSp,
        nadir:    nadirSp,
        horizon:  project({ az: this.horizonAz, alt:  0, r: 1 }),
        meridian: project({ az: 180,            alt: 35, r: 1 })
      };
    }

    // Offsets (x and y in stage px) from each feature point to its text label, 
    // with a clear leader line pointing back to the point: Zenith up-right,
    // Nadir down-right, Meridian left, Horizon Plane down-left -- so marker
    // rings and lines stay visible.
    //
    // Third element determines where leader line should attach: 0-3:TRBL.
    static get LABEL_OFFSET() {
      return { zenith: [34, -20, 2], nadir: [22, 26, 0], horizon: [-46, 26, 0], meridian: [-74, -4, 1] };
    }

    static get NAMED_LABELS() {
      return { zenith: 'Zenith', nadir: 'Nadir', horizon: 'Horizon Plane', meridian: 'Meridian' };
    }

    static get NAMED_LABEL_FONT() {
      return '600 15px system-ui, -apple-system, Segoe UI, sans-serif';
    }

    // Developer-only flag:
    // true  = legacy style (gap before feature, no dot);
    // false = new style (line to feature + small black dot). Not exposed in the UI.
    static LEADER_LEGACY_STYLE = true;

    // Screen position of a named label: preferred offset, then clamped so the
    // glyph box stays a few pixels inside the canvas (Meridian on the left limb
    // would otherwise clip first letters). dx/dy are the clamped vector
    // from the feature so leader still meets text.
    namedLabelPos(key) {
      const ctx          = this.ctx;
      const a            = this._labelAnchor[key];
      const [dx, dy, os] = App.LABEL_OFFSET[key];
      const text         = App.NAMED_LABELS[key];
      ctx.save();
      ctx.font           = App.NAMED_LABEL_FONT;
      const halfW        = ctx.measureText(text).width / 2;
      const match        = App.NAMED_LABEL_FONT.match(/(\d+)px/);
      const halfH        = match ? ( ( parseInt(match[1], 10) + 1 ) / 2 ): 8;  // 15px font default
      const pad          = 8;
      ctx.restore();
      let x = a.x + dx, y = a.y + dy;
      x = Math.min(this.CENTER - pad - halfW, Math.max(-this.CENTER + pad + halfW, x));
      y = Math.min(this.CENTER - pad - halfH, Math.max(-this.CENTER + pad + halfH, y));
      let xll, yll;
      if      ( os == 0 )  { xll = x - a.x;              yll = y - a.y - halfH; }
      else if ( os == 1 )  { xll = x - a.x + 1.15*halfW; yll = y - a.y;         }
      else if ( os == 2 )  { xll = x - a.x;              yll = y - a.y + halfH * 1.3; }
      else if ( os == 3 )  { xll = x - a.x - 1.15*halfW; yll = y - a.y;         }
      return { a, x, y, dx: a.x - x, dy: a.y - y, xll, yll, text };
    }

    // Camera-facing named labels (Legacy default _oType = 0, not absOrient).
    // which: 'back' (feature sp.z < 0, before glass) or 'front' (sp.z >= 0).
    drawNamedLabels(which) {
      const off = App.LABEL_OFFSET;
      for (const key of Object.keys(off)) {
        if (!this.labels[key]) continue;
        const a = this._labelAnchor[key];
        const behind = a.z < 0;
        if ((which === 'back' && behind) || (which === 'front' && !behind)) {
          this.drawLabelLeader(key);
          this.drawNamedLabel( key);
          this.drawLabelLeader(key);
        }
      }
    }

    drawLabelLeader(key) {
      const ctx = this.ctx;
      const { a, dx, dy, xll, yll } = this.namedLabelPos(key);
      let x0, y0, x1, y1, gap = 8, ang = -Math.atan2( -yll, -xll );
      if (App.LEADER_LEGACY_STYLE) {
        x0 = a.x + xll;                   y0 = a.y + yll;
        x1 = a.x - gap * Math.cos( ang ); y1 = a.y + gap * Math.sin( ang );
      } else {
        x0 = a.x + xll; y0 = a.y + yll;
        x1 = a.x;       y1 = a.y;
      }
      // Add light halo so dark line stays visible over white, grey, and green backgrounds
      ctx.save();
      ctx.lineCap     = 'round';
      ctx.lineJoin    = 'round';
      ctx.miterLimit  = 2;          // safety guard for extreme glyph vector joints ("2" spikes)
      ctx.strokeStyle = hexToRGBA( this.S.CSC.LABEL_HALO, 0.85 );
      ctx.lineWidth   = 2.6;
    //ctx.lineWidth   = 3.8;        // leave ~1.25px halo on each side of a 1.3px line
      ctx.beginPath(); ctx.moveTo(x0, y0); ctx.lineTo(x1, y1); ctx.stroke();  // light halo
      ctx.strokeStyle = this.S.CSC.LABEL_LNSG;
      ctx.lineWidth   = 1.3;
      ctx.beginPath(); ctx.moveTo(x0, y0); ctx.lineTo(x1, y1); ctx.stroke();  // dark line
      if (!App.LEADER_LEGACY_STYLE) {
        ctx.fillStyle = this.S.CSC.LABEL_LNSG;
        ctx.beginPath(); ctx.arc(a.x, a.y, 1.6, 0, TWO_PI); ctx.fill();
      }
      ctx.restore();
    }

    drawNamedLabel(key) {
      const ctx = this.ctx;
      const { x, y, text } = this.namedLabelPos(key);
      ctx.save();
      ctx.translate(x, y);           // upright billboard, no absOrient call
    //ctx.lineCap      = 'round';
      ctx.lineJoin     = 'round';
      ctx.miterLimit   = 2;          // safety guard for extreme glyph vector joints ("2" spikes)
      ctx.font         = App.NAMED_LABEL_FONT;
      ctx.textAlign    = 'center';
      ctx.textBaseline = 'middle';
      ctx.lineWidth    = 3;
      ctx.strokeStyle  = this.S.CSC.LABEL_HALO;
      ctx.fillStyle    = this.S.CSC.LABEL_FILL;
      ctx.strokeText(text, 0, 0);
      ctx.fillText(  text, 0, 0);
      ctx.restore();
    }

    // Keyboard handle tracks the star's screen position + current coordinates.
    positionOverlay() {
      this.starHandle.style.left = ((this.CENTER + this.star.sp.x) / this.STAGE * 100) + '%';
      this.starHandle.style.top  = ((this.CENTER + this.star.sp.y) / this.STAGE * 100) + '%';
      this.starHandle.setAttribute('aria-label',
        'Star position. Azimuth ' + speak(this.star.az,  1, 'degree') +
                    ', altitude ' + speak(this.star.alt, 1, 'degree') + '.');
    }

    updateCanvasDescription() {
      const onLabels = [];
      if (this.labels.zenith)   onLabels.push('Zenith');
      if (this.labels.horizon)  onLabels.push('Horizon Plane');
      if (this.labels.nadir)    onLabels.push('Nadir');
      if (this.labels.meridian) onLabels.push('Meridian');

      const labelText = onLabels.length ? onLabels.join(', ') : 'none';
      this.canvas.setAttribute('aria-label',
        'Horizon diagram. Cardinal directions N, E, S, and W shown on the horizon. ' +
        'Star at azimuth ' + speak(this.star.az,  1, 'degree') +
             ', altitude ' + speak(this.star.alt, 1, 'degree') + '. ' + 
        locateStar(this.star.az,this.star.alt) + 'Visible labels: ' + labelText + '.');
    }

    announce(includeOrientation) {
      let msg = 'Star at azimuth ' + speak(this.star.az,  1, 'degree') +
                     ', altitude ' + speak(this.star.alt, 1, 'degree') + '. ' +
                locateStar(this.star.az,this.star.alt);
      if (includeOrientation) {
        msg += ' View reset.';
      }
      this.desc.textContent = msg;
    }

    // ----------------------------------------------------------------------
    // Pointer + keyboard interaction
    // ----------------------------------------------------------------------
    // Convert a pointer event to sphere-local stage coordinates (origin at center).
    pointerToStage(ev) {
      const rect = this.canvas.getBoundingClientRect();
      const sx   = (ev.clientX - rect.left) / rect.width  * this.STAGE - this.CENTER;
      const sy   = (ev.clientY - rect.top)  / rect.height * this.STAGE - this.CENTER;
      return { x: sx, y: sy };
    }

    bindEvents() {
      // Masthead Reset (sim-reset bubbles up from the component)
      document.addEventListener('sim-reset', () => this.reset());

      // Sliders + number fields (both mutate the same state)
      const syncFromSlider = (slider, number) => {
        number.value = legToFixed(Number(slider.value), 1);
        this.onPositionSliderChanged();
        this.announce();
      };
      this.azSlider.addEventListener( 'input', () => syncFromSlider(this.azSlider,  this.azNumber ));
      this.altSlider.addEventListener('input', () => syncFromSlider(this.altSlider, this.altNumber));

      const syncFromNumber = (number, slider) => {
        let v = Number(number.value);
        if (!isFinite(v)) return;
        v = Math.max(Number(slider.min), Math.min(Number(slider.max), v));
        number.value = legToFixed( v, 1 );
        slider.value = v;
        this.onPositionSliderChanged();
        this.announce();
      };
      this.azNumber.addEventListener( 'change',  () => syncFromNumber(this.azNumber,  this.azSlider) );
      this.altNumber.addEventListener('change',  () => syncFromNumber(this.altNumber, this.altSlider));

      const noEinNumber = (event) => {
        if (event.key === 'e' || event.key === 'E') { event.preventDefault() };
      };
      this.azNumber.addEventListener(  'keydown', noEinNumber );
      this.altNumber.addEventListener( 'keydown', noEinNumber );

      // Buttons + checkboxes
      document.getElementById('showAllBtn').addEventListener('click', () => this.showAllLabels());
      document.getElementById('hideAllBtn').addEventListener('click', () => this.hideAllLabels());
      for (const k of Object.keys(this.chk)) {
        this.chk[k].addEventListener('change', () => this.updateLabels());
      }

      // Canvas pointer drag: star (if front-facing) else rotate the sphere
      this.dragMode = null;
      this.canvas.addEventListener('pointermove', (ev) => this.onPointerHover(ev));
      this.canvas.addEventListener('pointerdown', (ev) => this.onPointerDown( ev));
      window.addEventListener(     'pointermove', (ev) => this.onPointerDrag( ev));
      window.addEventListener(     'pointerup',   (ev) => this.onPointerUp(   ev));

      // Keyboard equivalent for the pointer-drag view rotation (arrows rotate the
      // sphere; directions match the mouse drag). The star itself is moved with
      // the Star Position controls.
      this.canvas.addEventListener(    'keydown', (ev) => this.onCanvasKey(ev));
      this.starHandle.addEventListener('keydown', (ev) => this.onStarKey(  ev));

      window.addEventListener('resize', () => this.render());
    }

    nearStar(stage) {
      const dx = stage.x - this.star.sp.x, dy = stage.y - this.star.sp.y;
      return (dx * dx + dy * dy) <= 14 * 14;     // ~star hit radius
    }

    onPointerHover(ev) {
      if (this.dragMode) return;
      const stage = this.pointerToStage(ev);
      const over  = this.nearStar(stage) && this.star.sp.z > 0;
      if (over !== this.starHovered) { this.starHovered = over; this.render(); }
    }

    onPointerDown(ev) {
      const stage = this.pointerToStage(ev);
      this.canvas.setPointerCapture && this.canvas.setPointerCapture(ev.pointerId);
      // AzAlt Draggable Star.onPress: front-facing star -> drag star; else sphere.
      // Move keyboard focus to the matching control so that after a click the
      // arrow keys act on what was clicked (the star handle is pointer-transparent,
      // and ev.preventDefault() below would otherwise suppress default focusing).
      if (this.nearStar(stage) && this.star.sp.z > 0) {
        this.dragMode = 'star';
        this.starHandle.focus();
      } else {
        this.dragMode   = 'sphere';
        this.dragXMouse = stage.x; this.dragYMouse = stage.y;
        this.dragTheta  = this.S.theta; this.dragPhi = this.S.phi;
        this.canvas.focus();
      }
      this.canvas.classList.add('dragging');
      ev.preventDefault();
    }

    onPointerDrag(ev) {
      if (!this.dragMode) return;
      const stage = this.pointerToStage(ev);
      if (this.dragMode === 'star') {
        // AzAlt Draggable Star.onMouseMoveFunc
        const hp = {};
        this.S.StoMH({ x: stage.x, y: stage.y }, hp);
        this.setStarLocation({ az: -hp.az * 180 / PI, alt: hp.alt * 180 / PI });
        this.render();
      } else {
        // CelestialSphere.updateSimpleDragging
        const r = this.S.c.r;
        this.S.setThetaAndPhi(
          R2D * (this.dragTheta - (stage.x - this.dragXMouse) / r),
          R2D * (this.dragPhi   + (stage.y - this.dragYMouse) / r)
        );
        this.onSphereOrientationChanged();
      }
    }

    onPointerUp() {
      if (!this.dragMode) return;
      this.dragMode = null;
      this.canvas.classList.remove('dragging');
      this.announce();
    }

    // Arrow keys rotate view; Shift/CapsLock = x10 larger step (10deg vs 1deg),
    // PageUp/Down = phi in 15deg steps. 
    onCanvasKey(ev) {
      const step = ( ev.shiftKey || ev.getModifierState('CapsLock') ) ? 10 : 1;
      let dTheta = 0, dPhi = 0; 
      switch (ev.key) {
        case 'ArrowLeft':  dTheta =  step;  break;
        case 'ArrowRight': dTheta = -step;  break;
        case 'ArrowUp':    dPhi   = -step;  break;
        case 'ArrowDown':  dPhi   =  step;  break;
        case 'PageUp':     dPhi   =   -15;  break;
        case 'PageDown':   dPhi   =    15;  break;
        default: return;
      }
      ev.preventDefault();
      this.S.setThetaAndPhi(this.S.getTheta() + dTheta, this.S.getPhi() + dPhi);
      this.onSphereOrientationChanged();
      this.announceView();
    }

    // Arrow keys move star (alt/az), mirroring star drag. Same step scheme 
    // as view rotation: 1deg arrows, 10deg with Shift/CapsLock, 15deg Page keys.
    onStarKey(ev) {
      const step = ( ev.shiftKey || ev.getModifierState('CapsLock') ) ? 10 : 1;
      let dAz = 0, dAlt = 0;
      switch (ev.key) {
        case 'ArrowLeft':  dAz  =  step;  break;
        case 'ArrowRight': dAz  = -step;  break;
        case 'ArrowUp':    dAlt =  step;  break;
        case 'ArrowDown':  dAlt = -step;  break;
        case 'PageUp':     dAlt =    15;  break;
        case 'PageDown':   dAlt =   -15;  break;
        default: return;
      }
      ev.preventDefault();
      let alt = this.star.alt + dAlt;
      if (alt > 90) alt = 90; else if (alt < -90) alt = -90;   // slider range
      // setStarLocation normalizes azimuth mod 360 and syncs sliders/boxes.
      this.setStarLocation({ az: this.star.az + dAz, alt: alt });
      this.render();
      this.announce();
    }

    announceView() {
      const az  = pMod(360 - this.S.getTheta(), 360);   // viewer azimuth
      const alt = this.S.getPhi();                      // viewer altitude
      this.desc.textContent = 'View rotated. ' +
           'Viewing azimuth ' + speak(az,  1, 'degree') +
        ', viewing altitude ' + speak(alt, 1, 'degree') + '.';
    }
  }

  // Initialise once the foundation helper (kl-unl.js) is ready. We redefine
  // klunlInitEqn (per the foundation convention) to boot the sim.
  function boot() { if (!window.altAzApp) window.altAzApp = new App(); }
  if (typeof window.klunlInitEqn === 'function') {
    window.klunlInitEqn = boot;
  }
  if (document.readyState === 'loading') {
    document.addEventListener('DOMContentLoaded', boot);
  } else {
    boot();
  }
