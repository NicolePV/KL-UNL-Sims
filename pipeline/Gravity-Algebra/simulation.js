/* ==========================================================================
   Gravity Algebra -- simulation logic
   --------------------------------------------------------------------------
   Newton's law of universal gravitation:  F = G * M1 * M2 / R^2

   The user picks a coefficient (multiplier) on each of M1, M2 and R from the
   set {1/3, 1/2, 1, 2, 3}. The modified force is

        F' = G (c1 M1)(c2 M2) / (cr R)^2  =  (c1 * c2 / cr^2) F

   Because every coefficient is a product of powers of 2 and 3 only, the factor
   c1*c2/cr^2 is always an EXACT rational number. The original ActionScript
   tracks the exponents of 2 and 3 as integers (choice.p2 / choice.p3) and
   assembles a whole number or an already-reduced fraction. This file ports
   that arithmetic verbatim (see computeResult), and renders every symbol with
   MathJax so it is spoken, zoomable, and exposes the "Show Math As..." menu.

   Single source of truth: `state`; one render() redraws the equation, the
   controls, and the screen-reader description after every change.
   ========================================================================== */

(function () {
  "use strict";

  /* --------------------------------------------------------------------
     CHOICES -- verbatim from Multiplier Selector.as choicesList.
     value / p2 (exponent of 2) / p3 (exponent of 3) are exactly the source
     numbers; `latex` and `spoken` are the MathJax + screen-reader forms.
     -------------------------------------------------------------------- */
  const CHOICES = [
    { value: 0.3333333333333333, p2: 0,  p3: -1, latex: "\\tfrac{1}{3}", spoken: "one third" },
    { value: 0.5,                p2: -1, p3: 0,  latex: "\\tfrac{1}{2}", spoken: "one half"  },
    { value: 1,                  p2: 0,  p3: 0,  latex: "1",             spoken: "one"       },
    { value: 2,                  p2: 1,  p3: 0,  latex: "2",             spoken: "two"       },
    { value: 3,                  p2: 0,  p3: 1,  latex: "3",             spoken: "three"     }
  ];

  const DEFAULT_INDEX = 2; // "One" -- matches setSelected(2) in the AS source.

  // The three coefficients and how each is spoken as a quantity.
  const COEFS = [
    { key: "m1", quantity: "the coefficient on mass M 1" },
    { key: "m2", quantity: "the coefficient on mass M 2" },
    { key: "r",  quantity: "the coefficient on distance R" }
  ];

  /* --------------------------------------------------------------------
     STATE -- one plain object; the single source of truth.
     -------------------------------------------------------------------- */
  const state = {
    m1: DEFAULT_INDEX,
    m2: DEFAULT_INDEX,
    r:  DEFAULT_INDEX,
    result: { num: 1, den: 1 } // filled in by render()
  };

  const controls = {}; // key -> Coef instance

  /* --------------------------------------------------------------------
     MathJax helpers -- serialize typeset calls onto the startup promise.
     -------------------------------------------------------------------- */

  // MathJax makes every <mjx-container> focusable (tabindex="0") so keyboard
  // users can open its context menu. That would put every symbol (F, G, M1, ...)
  // in the Tab order. We only want the three coefficient controls tabbable, so
  // drop the math pieces out of the sequential tab order. This does NOT disable
  // the right-click "Show Math As..." menu -- that works regardless of tabindex.
  function stripMathTabstops(root) {
    (root || document).querySelectorAll("mjx-container[tabindex]").forEach(function (el) {
      el.setAttribute("tabindex", "-1");
    });
  }

  function typeset(elements) {
    if (!(window.MathJax && MathJax.startup && MathJax.startup.promise)) {
      // MathJax not ready yet; try again shortly.
      window.setTimeout(function () { typeset(elements); }, 60);
      return;
    }
    MathJax.startup.promise = MathJax.startup.promise
      .then(function () { return MathJax.typesetPromise(elements); })
      .then(function () { stripMathTabstops(document); })
      .catch(function (err) { console.error("MathJax typeset error:", err); });
  }

  /* --------------------------------------------------------------------
     computeResult -- verbatim port of frame_1/DoAction.as onChange().
     Returns { num, den } with the fraction already in lowest terms.
     -------------------------------------------------------------------- */
  function computeResult() {
    const c1 = CHOICES[state.m1];
    const c2 = CHOICES[state.m2];
    const cr = CHOICES[state.r];

    // Net exponents of 2 and 3 for  c1 * c2 / cr^2
    const e2 = c1.p2 + c2.p2 - (cr.p2 + cr.p2);
    const e3 = c1.p3 + c2.p3 - (cr.p3 + cr.p3);

    let den = 1; // _loc2_
    let num = 1; // _loc5_

    if (e2 < 0) { den *= Math.pow(2, -e2); } else { num *= Math.pow(2, e2); }
    if (e3 < 0) { den *= Math.pow(3, -e3); } else { num *= Math.pow(3, e3); }

    return { num: num, den: den };
  }

  // Spoken form of the result factor, e.g. "one" / "4" / "3 over 4".
  function resultSpoken(res) {
    if (res.den === 1) {
      return res.num === 1 ? "one" : String(res.num);
    }
    return res.num + " over " + res.den;
  }

  // LaTeX form of the result factor multiplied by F.
  function resultLatex(res) {
    if (res.den === 1) {
      return res.num + "\\,F";
    }
    return "\\dfrac{" + res.num + "}{" + res.den + "}\\,F";
  }

  /* --------------------------------------------------------------------
     Screen-reader status region
     -------------------------------------------------------------------- */
  const srStatus = document.getElementById("sr-status");
  function announce(message) {
    if (srStatus) { srStatus.textContent = message; }
  }

  /* --------------------------------------------------------------------
     Coef -- a custom, accessible coefficient dropdown.
     A button (aria-haspopup="listbox") shows the current value in MathJax
     (red). Activating it opens a listbox of the five choices. Fully keyboard
     operable (arrows / Home / End / Enter / Escape) and touch-friendly; the
     foundation files are never modified (hard rule 9).
     -------------------------------------------------------------------- */
  function Coef(root, def) {
    this.root = root;
    this.key = def.key;
    this.quantity = def.quantity;
    this.open = false;

    root.innerHTML =
      '<button class="coef__btn" type="button" aria-haspopup="listbox" ' +
        'aria-expanded="false" id="coef-' + this.key + '-btn">' +
        '<span class="coef__value"></span>' +
        '<span class="coef__caret" aria-hidden="true"></span>' +
      '</button>' +
      '<ul class="coef__menu" role="listbox" hidden id="coef-' + this.key + '-menu" ' +
        'aria-label="Choose ' + this.quantity + '">' +
        CHOICES.map(function (c, i) {
          return '<li class="coef__option" role="option" tabindex="-1" ' +
                   'data-index="' + i + '" aria-label="' + c.spoken + '" ' +
                   'id="coef-' + def.key + '-opt-' + i + '">' +
                   '<span class="coef__value">\\(' + c.latex + '\\)</span>' +
                 '</li>';
        }).join("") +
      '</ul>';

    this.btn = root.querySelector(".coef__btn");
    this.valueEl = this.btn.querySelector(".coef__value");
    this.menu = root.querySelector(".coef__menu");
    this.options = Array.prototype.slice.call(root.querySelectorAll(".coef__option"));

    const self = this;

    this.btn.addEventListener("click", function () { self.toggle(); });
    this.btn.addEventListener("keydown", function (e) { self.onButtonKey(e); });

    this.options.forEach(function (li) {
      li.addEventListener("click", function () {
        self.choose(parseInt(li.getAttribute("data-index"), 10));
      });
      li.addEventListener("keydown", function (e) { self.onOptionKey(e, li); });
    });

    // Close when focus leaves the whole control, or on an outside pointer.
    root.addEventListener("focusout", function (e) {
      if (!root.contains(e.relatedTarget)) { self.close(false); }
    });

    // The option LaTeX is fixed; typeset it once here.
    typeset(this.options.map(function (li) { return li.querySelector(".coef__value"); }));
  }

  Coef.prototype.setIndex = function (index) {
    // Update the button's displayed value (MathJax) + accessible label.
    const c = CHOICES[index];
    this.valueEl.innerHTML = "\\(" + c.latex + "\\)";
    this.btn.setAttribute(
      "aria-label",
      capitalize(this.quantity) + ", currently " + c.spoken + ". Press to change its value."
    );
    this.options.forEach(function (li) {
      const sel = parseInt(li.getAttribute("data-index"), 10) === index;
      li.setAttribute("aria-selected", sel ? "true" : "false");
    });
    typeset([this.valueEl]);
  };

  Coef.prototype.toggle = function () { this.open ? this.close(true) : this.openMenu(); };

  Coef.prototype.openMenu = function () {
    closeAllExcept(this);
    this.open = true;
    this.menu.hidden = false;
    this.btn.setAttribute("aria-expanded", "true");
    // Focus the currently-selected option.
    const idx = state[this.key];
    const target = this.options[idx] || this.options[0];
    target.focus();
    this.setActive(target);
  };

  Coef.prototype.close = function (focusButton) {
    if (!this.open) { return; }
    this.open = false;
    this.menu.hidden = true;
    this.btn.setAttribute("aria-expanded", "false");
    this.options.forEach(function (li) { li.removeAttribute("data-active"); });
    if (focusButton) { this.btn.focus(); }
  };

  Coef.prototype.setActive = function (li) {
    this.options.forEach(function (o) { o.removeAttribute("data-active"); });
    if (li) { li.setAttribute("data-active", "true"); }
  };

  Coef.prototype.choose = function (index) {
    this.close(true);
    if (index === state[this.key]) { return; } // no change
    state[this.key] = index;
    render();
    // Announce the change plus the new result, with context (units-free factor).
    announce(
      capitalize(this.quantity) + " set to " + CHOICES[index].spoken + ". " +
      "The modified force F prime is now " + resultSpoken(state.result) +
      " times the original force F."
    );
  };

  Coef.prototype.onButtonKey = function (e) {
    switch (e.key) {
      case "ArrowDown":
      case "ArrowUp":
      case "Enter":
      case " ":
      case "Spacebar":
        e.preventDefault();
        this.openMenu();
        break;
      default:
        break;
    }
  };

  Coef.prototype.onOptionKey = function (e, li) {
    const i = this.options.indexOf(li);
    let next = null;
    switch (e.key) {
      case "ArrowDown":  next = this.options[(i + 1) % this.options.length]; break;
      case "ArrowUp":    next = this.options[(i - 1 + this.options.length) % this.options.length]; break;
      case "Home":       next = this.options[0]; break;
      case "End":        next = this.options[this.options.length - 1]; break;
      case "Enter":
      case " ":
      case "Spacebar":
        e.preventDefault();
        this.choose(parseInt(li.getAttribute("data-index"), 10));
        return;
      case "Escape":
        e.preventDefault();
        this.close(true);
        return;
      case "Tab":
        this.close(false);
        return; // allow Tab to move focus normally
      default:
        return;
    }
    if (next) {
      e.preventDefault();
      next.focus();
      this.setActive(next);
    }
  };

  function closeAllExcept(except) {
    Object.keys(controls).forEach(function (k) {
      if (controls[k] !== except) { controls[k].close(false); }
    });
  }

  function capitalize(s) { return s.charAt(0).toUpperCase() + s.slice(1); }

  /* --------------------------------------------------------------------
     render() -- redraw everything from state (single render path).
     -------------------------------------------------------------------- */
  const resultEl = document.getElementById("eq-result");
  const modifiedSrEl = document.getElementById("eq-modified-sr");

  function render() {
    // 1. Coefficient buttons.
    controls.m1.setIndex(state.m1);
    controls.m2.setIndex(state.m2);
    controls.r.setIndex(state.r);

    // 2. Result factor (verbatim arithmetic).
    const res = computeResult();
    state.result = res;

    if (resultEl) {
      resultEl.innerHTML = "\\(" + resultLatex(res) + "\\)";
      typeset([resultEl]);
    }

    // 3. Screen-reader description of the whole modified equation.
    if (modifiedSrEl) {
      modifiedSrEl.textContent =
        "Modified force F prime equals G times " + CHOICES[state.m1].spoken +
        " times mass M 1, times " + CHOICES[state.m2].spoken +
        " times mass M 2, all divided by the quantity " + CHOICES[state.r].spoken +
        " times distance R, squared. This equals " + resultSpoken(res) +
        " times the original force F.";
    }
  }

  /* --------------------------------------------------------------------
     Reset -- masthead "sim-reset" event -> exact initial state.
     -------------------------------------------------------------------- */
  function reset() {
    state.m1 = DEFAULT_INDEX;
    state.m2 = DEFAULT_INDEX;
    state.r = DEFAULT_INDEX;
    Object.keys(controls).forEach(function (k) { controls[k].close(false); });
    render();
    announce("Reset. All three coefficients set to one. " +
             "The modified force F prime equals the original force F.");
  }

  /* --------------------------------------------------------------------
     Boot
     -------------------------------------------------------------------- */
  function boot() {
    document.querySelectorAll(".coef").forEach(function (root) {
      const key = root.getAttribute("data-coef");
      const def = COEFS.filter(function (c) { return c.key === key; })[0];
      if (def) { controls[key] = new Coef(root, def); }
    });

    render();

    // Also strip tab stops off the STATIC equations (the reference formula and
    // the fixed glyphs), which MathJax auto-typesets during its own startup
    // rather than through our typeset() helper.
    if (window.MathJax && MathJax.startup && MathJax.startup.promise) {
      MathJax.startup.promise.then(function () { stripMathTabstops(document); });
    }

    // The masthead dispatches a bubbling, composed "sim-reset" CustomEvent.
    document.addEventListener("sim-reset", reset);
  }

  if (document.readyState === "loading") {
    document.addEventListener("DOMContentLoaded", boot);
  } else {
    boot();
  }

  // kl-unl.js calls klunlInitEqn() on load; this sim owns its own typesetting,
  // so redefine it to a no-op (prevents the default klunlShowEquation() call).
  window.klunlInitEqn = function () {};
})();
