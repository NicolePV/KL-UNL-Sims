/* ==========================================================================
   Kepler's Third Law -- HTML5 port of keplers_third.swf
   --------------------------------------------------------------------------
   Behavioral ground truth: the single DoAction block on frame 1 of the
   original SWF. In full, the original is:

     p_txt.restrict = "0-9.e";
     a_txt.restrict = "0-9.e";

     p_txt.onChanged = function() {
       var p = parseFloat(p_txt.text);
       if (p > 0 && isFinite(p)) {
         a_txt.text = Math.round(1000 * Math.pow(p, 0.6666666666666666)) / 1000;
       } else if (p == 0) {
         a_txt.text = 0;
       } else {
         a_txt.text = "";
       }
     };

     a_txt.onChanged = function() {
       var a = parseFloat(a_txt.text);
       if (a > 0 && isFinite(a)) {
         p_txt.text = Math.round(1000 * Math.pow(a, 1.5)) / 1000;
       } else if (a == 0) {
         p_txt.text = 0;
       } else {
         p_txt.text = "";
       }
     };

   Kepler's third law, P^2 = a^3, so a = P^(2/3) and P = a^(3/2).
   Both edit fields carry maxlength 7 and centered alignment in the SWF.

   In ActionScript, assigning to a TextField's .text does NOT fire that field's
   onChanged handler -- only user edits do. Setting .value in JS likewise does
   not fire an "input" event, so the two handlers cannot feed back into each
   other here either. That match is intentional; do not "fix" it with a
   dispatchEvent.
   ========================================================================== */

(function () {
  "use strict";

  /* --------------------------------------------------------------------
     Constants -- verbatim from the SWF's constant pool / push operands.
     -------------------------------------------------------------------- */

  // The SWF stores the exponent as the double 0.6666666666666666, which is the
  // nearest double to 2/3. Kept as the literal so it matches bit-for-bit.
  var P_TO_A_EXPONENT = 0.6666666666666666;   // a = P^(2/3)
  var A_TO_P_EXPONENT = 1.5;                  // P = a^(3/2)

  var ROUND_SCALE     = 1000;                 // 3-decimal rounding, as in the AS
  var MAX_LENGTH      = 7;                    // DefineEditText MaxLength = 7
  var RESTRICT_RE     = /[^0-9.e]/g;          // TextField.restrict = "0-9.e"

  // Added for keyboard / wheel operability (not present in the Flash original,
  // which was mouse-and-typing only). See ACCESSIBILITY.md.
  var STEP_SMALL      = 0.1;                  // Arrow Up / Down, wheel
  var STEP_LARGE      = 1;                    // Page Up / Down
  var ANNOUNCE_DELAY  = 700;                  // ms of quiet before announcing

  /* --------------------------------------------------------------------
     Single source of truth. p and a hold exactly what the corresponding
     original TextField would hold -- strings, possibly empty.
     -------------------------------------------------------------------- */

  var state = {
    p: "",
    a: ""
  };

  var els = {};              // p, a, status
  var announceTimer = null;  // debounce handle for the live region

  /* --------------------------------------------------------------------
     MathJax helpers
     -------------------------------------------------------------------- */

  // MathJax gives every <mjx-container> tabindex="0" so keyboard users can open
  // its context menu. That would put P, a, the exponents and the equals sign in
  // the Tab order, which must contain only the two value boxes. Dropping them to
  // tabindex="-1" removes them from the Tab sequence without disabling the
  // right-click "Show Math As..." menu, which works regardless of tabindex.
  function stripMathTabstops(root) {
    (root || document)
      .querySelectorAll("mjx-container[tabindex]")
      .forEach(function (el) { el.setAttribute("tabindex", "-1"); });
  }

  // Serialize work onto MathJax's own startup promise so it runs after the
  // initial page typeset, whenever that finishes.
  function afterMathJax(fn) {
    if (!(window.MathJax && window.MathJax.startup && window.MathJax.startup.promise)) {
      window.setTimeout(function () { afterMathJax(fn); }, 60);
      return;
    }
    window.MathJax.startup.promise = window.MathJax.startup.promise
      .then(fn)
      .catch(function (err) { console.error("MathJax error:", err); });
  }

  /* --------------------------------------------------------------------
     The two ported handlers.

     Each takes the text of the field the user edited and returns the text the
     OTHER field should show. Branch order and comparisons follow the AS source
     exactly, including the loose `== 0` (so "0", "0.0" and "0e5" all land in
     the zero branch) and the String() conversion that Flash performs when a
     Number is assigned to TextField.text.
     -------------------------------------------------------------------- */

  // p_txt.onChanged: given the period text, produce the semimajor axis text.
  function periodToAxis(pText) {
    var p = parseFloat(pText);

    if (p > 0 && isFinite(p)) {
      // a = round(1000 * P^(2/3)) / 1000
      return String(Math.round(ROUND_SCALE * Math.pow(p, P_TO_A_EXPONENT)) / ROUND_SCALE);
    }
    if (p == 0) {                                   // eslint-disable-line eqeqeq
      return "0";
    }
    return "";
  }

  // a_txt.onChanged: given the semimajor axis text, produce the period text.
  function axisToPeriod(aText) {
    var a = parseFloat(aText);

    if (a > 0 && isFinite(a)) {
      // P = round(1000 * a^(3/2)) / 1000
      return String(Math.round(ROUND_SCALE * Math.pow(a, A_TO_P_EXPONENT)) / ROUND_SCALE);
    }
    if (a == 0) {                                   // eslint-disable-line eqeqeq
      return "0";
    }
    return "";
  }

  /* --------------------------------------------------------------------
     restrict = "0-9.e" -- strip disallowed characters, keeping the caret
     where the user expects it.
     -------------------------------------------------------------------- */

  function applyRestrict(input) {
    var raw = input.value;
    var clean = raw.replace(RESTRICT_RE, "");

    if (clean === raw) { return clean; }

    // Count how many characters were dropped before the caret so it does not
    // jump to the end of the field.
    var caret = input.selectionStart === null ? clean.length : input.selectionStart;
    var removedBeforeCaret = raw.slice(0, caret).replace(RESTRICT_RE, "").length;

    input.value = clean;
    try {
      input.setSelectionRange(removedBeforeCaret, removedBeforeCaret);
    } catch (e) {
      /* setSelectionRange is unavailable on some input types; harmless here. */
    }
    return clean;
  }

  /* --------------------------------------------------------------------
     Spoken descriptions -- every number is announced with its quantity name
     and its unit spelled out as a word (never a bare number).
     -------------------------------------------------------------------- */

  function spokenPeriod(text) {
    if (text === "") { return "Period P is empty"; }
    return "Period P " + text + (text === "1" ? " year" : " years");
  }

  function spokenAxis(text) {
    if (text === "") { return "Semimajor axis a is empty"; }
    return "Semimajor axis a " + text +
           (text === "1" ? " astronomical unit" : " astronomical units");
  }

  function announce(message) {
    window.clearTimeout(announceTimer);
    announceTimer = window.setTimeout(function () {
      els.status.textContent = message;
    }, ANNOUNCE_DELAY);
  }

  function announceNow(message) {
    window.clearTimeout(announceTimer);
    els.status.textContent = message;
  }

  /* --------------------------------------------------------------------
     render -- the one place the DOM and the live region are written from
     state. Called after every action, whatever triggered it.
     -------------------------------------------------------------------- */

  function render() {
    // Only write when the text actually differs, so an active caret is left
    // alone in the field the user is typing into.
    if (els.p.value !== state.p) { els.p.value = state.p; }
    if (els.a.value !== state.a) { els.a.value = state.a; }

    announce(spokenPeriod(state.p) + ". " + spokenAxis(state.a) + ".");
  }

  /* --------------------------------------------------------------------
     Edit paths. Both the typing path and the stepping path funnel through
     these, so keyboard, wheel and mouse stay in sync.
     -------------------------------------------------------------------- */

  function setPeriod(text) {
    state.p = text;
    state.a = periodToAxis(text);   // p_txt.onChanged
    render();
  }

  function setAxis(text) {
    state.a = text;
    state.p = axisToPeriod(text);   // a_txt.onChanged
    render();
  }

  /* --------------------------------------------------------------------
     Arrow-key and mouse-wheel stepping on a focused value box.
     Values are re-rounded to the sim's own 3-decimal precision so that
     repeated steps cannot accumulate binary floating-point dust.
     -------------------------------------------------------------------- */

  function step(which, delta) {
    var current = parseFloat(which === "p" ? state.p : state.a);
    if (!isFinite(current)) { current = 0; }

    var next = Math.round((current + delta) * ROUND_SCALE) / ROUND_SCALE;
    if (next < 0) { next = 0; }          // the original accepts no minus sign

    var text = String(next);
    // Respect the field's 7-character limit rather than overflowing it.
    if (text.length > MAX_LENGTH) { return; }

    if (which === "p") { setPeriod(text); } else { setAxis(text); }
  }

  function onKeyDown(which, event) {
    var delta = 0;

    switch (event.key) {
      case "ArrowUp":   delta =  STEP_SMALL; break;
      case "ArrowDown": delta = -STEP_SMALL; break;
      case "PageUp":    delta =  STEP_LARGE; break;
      case "PageDown":  delta = -STEP_LARGE; break;
      case "Home":
        // Home = minimum. There is no maximum, so End is left to the browser.
        event.preventDefault();
        if (which === "p") { setPeriod("0"); } else { setAxis("0"); }
        return;
      default:
        return;
    }

    event.preventDefault();   // do not let the page scroll instead
    step(which, delta);
  }

  function onWheel(which, event) {
    // Only while the box has focus, so ordinary page scrolling is unaffected.
    if (document.activeElement !== els[which]) { return; }
    if (event.deltaY === 0) { return; }

    event.preventDefault();
    step(which, event.deltaY < 0 ? STEP_SMALL : -STEP_SMALL);
  }

  /* --------------------------------------------------------------------
     Reset -- masthead "sim-reset" event restores the exact initial state.
     The SWF's two DefineEditText tags carry no initial text, so both boxes
     start empty.
     -------------------------------------------------------------------- */

  function reset() {
    state.p = "";
    state.a = "";
    els.p.value = "";
    els.a.value = "";
    announceNow("Calculator reset. Both boxes are empty.");
  }

  /* --------------------------------------------------------------------
     Equation display, through the foundation's kl-unl.js helper.
     kl-unl.js calls klunlInitEqn() on load; redefining it here supersedes
     the foundation's default, as that file's own comment instructs.
     -------------------------------------------------------------------- */

  window.klunlInitEqn = function () {
    klunlShowEquation(
      ["eq-reference", "\\( P^{2} \\;=\\; a^{3} \\)"],
      ["eq-reference-sr",
       "Kepler's third law: P squared equals a cubed, where P is the orbital " +
       "period in years and a is the semimajor axis in astronomical units."]
    );
  };

  /* --------------------------------------------------------------------
     Boot
     -------------------------------------------------------------------- */

  function boot() {
    els.p      = document.getElementById("p-input");
    els.a      = document.getElementById("a-input");
    els.status = document.getElementById("sr-status");

    [["p", els.p], ["a", els.a]].forEach(function (pair) {
      var which = pair[0];
      var input = pair[1];

      input.addEventListener("input", function () {
        var text = applyRestrict(input);
        if (which === "p") { setPeriod(text); } else { setAxis(text); }
      });

      input.addEventListener("keydown", function (event) {
        onKeyDown(which, event);
      });

      // passive:false so preventDefault() can stop the page from scrolling.
      input.addEventListener("wheel", function (event) {
        onWheel(which, event);
      }, { passive: false });
    });

    // The masthead dispatches a bubbling, composed "sim-reset" CustomEvent.
    document.addEventListener("sim-reset", reset);

    // Typeset the reference equation, then take the math back out of the Tab
    // order (MathJax adds tabindex to its containers during typesetting).
    window.klunlInitEqn();
    afterMathJax(function () { stripMathTabstops(document); });
  }

  if (document.readyState === "loading") {
    document.addEventListener("DOMContentLoaded", boot);
  } else {
    boot();
  }
})();
