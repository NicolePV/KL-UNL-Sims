/* ==========================================================================
   KL-UNL accessible dual control — paired slider + text number box

   Visual updates ride the rapid slider / spin events. Screen reader text is
   routed only through a debounced aria-live region so native range /
   spinbutton streams cannot stutter over the custom announcements.
   ========================================================================== */

import {
  legToFixed, stepToPrec, clamp, keyAccel,
  updateSliderProgress
} from './kl-unl-utils.js';

const SPIN_REPEAT_DELAY_MS = 400;
const SPIN_REPEAT_RATE_MS  =  60;
const LIVE_DEBOUNCE_MS     = 100;
/* Rough VoiceOver speaking time at its default rate. A new message waits
   this long after the previous one so polite updates do not cut it off. */
const SPEECH_MS_PER_CHAR   =   55;
const SPEECH_MAX_MS        = 1500;

/**
 * Synchronized range slider + decimal text field with custom spin buttons.
 *
 * The native range is aria-hidden so VoiceOver never races its valuetext
 * against the component live region. Typed digits commit on blur or Enter.
 */
export class DualControl {
  /**
   * @param {object}               opts
   * @param {HTMLElement|string}   opts.mount           Container or selector.
   * @param {string}               [opts.id='dual']     Base id for inputs.
   * @param {string}               [opts.label='Value'] Visible label text.
   * @param {number}               [opts.min=0]
   * @param {number}               [opts.max=100]
   * @param {number}               [opts.step=1]
   * @param {number}               [opts.pageStep]      PageUp / PageDown delta.
   * @param {number}               [opts.value]
   * @param {string}               [opts.unit='']       Unit to the right of the number
   *        box (peer of minLabel / maxLabel; e.g. '°').
   * @param {string}               [opts.minLabel]      Label under slider min end.
   * @param {string}               [opts.maxLabel]      Label under slider max end.
   * @param {HTMLElement}          [opts.liveRegion]    External live region.
   * @param {boolean}              [opts.createLiveRegion=true]
   * @param {(v:number)=>string}   [opts.formatValue]   Number-box display.
   * @param {(v:number)=>string}   [opts.formatAnnounce] Spoken value text.
   * @param {((v:number, prev:number)=>boolean|string)|number|null} [opts.milestone]
   *        Predicate or modulus for mid-drag callouts (e.g. 30 → value%30===0).
   *        A predicate may return a string to announce instead of the value
   *        (e.g. threshold crossings between prev and v).
   * @param {boolean}              [opts.readOnly=false] Field cannot be typed into;
   *        arrow / page keys, spin ticks, and slider still step the value.
   * @param {boolean}              [opts.textValue=false] Display is text (e.g. a
   *        date), not digits: wider, left-aligned field.
   * @param {boolean}              [opts.wrap=false]    Spin / keys wrap max → min
   *        (slider still stops at its ends).
   * @param {HTMLElement}          [opts.sliderDecor]   Full-width node placed just
   *        above the slider track (e.g. season labels).
   * @param {string}               [opts.describedBy]   Id for aria-describedby on
   *        the number field (the slider is aria-hidden).
   * @param {string}               [opts.spinUpLabel]   Accessible name of up tick.
   * @param {string}               [opts.spinDownLabel] Accessible name of down tick.
   * @param {boolean}              [opts.announceMoving=false]
   * @param {string}               [opts.movingWord='moving']
   * @param {boolean}              [opts.autoAnnounce=true]
   * @param {(v:number, meta:object)=>void} [opts.onInput]
   * @param {(v:number, meta:object)=>void|string|false} [opts.onChange]
   *        meta = { source, announce }. Typed commits (source 'enter' / 'blur')
   *        add { raw, invalid, clamped }: invalid = not a number (value kept),
   *        clamped = outside [min, max] (value pinned to the nearest end).
   * @param {string}               [opts.numberRowClass]
   * @param {string}               [opts.sliderRowClass]
   * @param {string}               [opts.numberClass]
   * @param {string}               [opts.sliderClass]
   */
  constructor(opts = {}) {
    const mount = typeof opts.mount === 'string'
      ? document.querySelector(opts.mount)
      : opts.mount;

    if (!mount) {
      throw new Error('DualControl: opts.mount is required.');
    }

    this.mount            = mount;
    this.id               = opts.id               != null ? opts.id               : 'dual';
    this.label            = opts.label            != null ? opts.label            : 'Value';
    this.labelName        = String(this.label).replace(/[:：]\s*$/, '').trim() || 'Value';
    this.min              = opts.min              != null ? Number(opts.min)      : 0;
    this.max              = opts.max              != null ? Number(opts.max)      : 100;
    this.step             = opts.step             != null ? Number(opts.step)     : 1;
    this.pageStep         = opts.pageStep         != null ? Number(opts.pageStep) : this.step * 5;
    this.unit             = opts.unit             != null ? opts.unit             : '';
    this.minLabel         = opts.minLabel         != null ? opts.minLabel         : String(this.min);
    this.maxLabel         = opts.maxLabel         != null ? opts.maxLabel         : String(this.max);
    this.precision        = stepToPrec(String(this.step));
    this.formatValue      = opts.formatValue      || ((v) => legToFixed(v, this.precision));
    this.formatAnnounce   = opts.formatAnnounce   || ((v) => this.formatValue(v));
    this.milestone        = this._normalizeMilestone(opts.milestone);
    this.announceMoving   = !!opts.announceMoving;
    this.movingWord       = opts.movingWord       != null ? opts.movingWord       : 'moving';
    this.autoAnnounce     = opts.autoAnnounce     !== false;
    this.onInput          = typeof opts.onInput   === 'function' ? opts.onInput   : null;
    this.onChange         = typeof opts.onChange  === 'function' ? opts.onChange  : null;
    this.numberRowClass   = opts.numberRowClass   || 'control-row kl-dual__number-row';
    this.sliderRowClass   = opts.sliderRowClass   || 'control-row kl-dual__slider-row';
    this.numberClass      = opts.numberClass      || 'control-row__input  kl-dual__number';
    this.sliderClass      = opts.sliderClass      || 'control-row__slider kl-dual__slider';
    this.readOnly         = !!opts.readOnly;
    this.textValue        = !!opts.textValue;
    this.wrap             = !!opts.wrap;
    this.sliderDecor      = opts.sliderDecor      || null;
    this.describedBy      = opts.describedBy      || null;
    this.spinUpLabel      = opts.spinUpLabel      || 'Increase ' + this.labelName;
    this.spinDownLabel    = opts.spinDownLabel    || 'Decrease ' + this.labelName;

    this._value           = this._quantize(
      opts.value != null ? Number(opts.value) : this.min
    );
    this._typing           = false;
    this._dragging         = false;
    this._spinning         = false;
    this._keyStepping      = false;
    this._sliderKeyArmed   = false;
    this._lastMilestone    = null;
    this._spinTimer        = 0;
    this._spinRepeat       = 0;
    this._spinDir          = 0;
    this._liveTimer        = 0;
    this._pendingMilestone = null;
    this._speakingUntil    = 0;
    this._bound            = [];

    this._render(opts);
    this._bind();
    this._syncUI({ updateNumber: true });
  }

  /* ---- public API ------------------------------------------------------ */

  getValue() {
    return this._value;
  }

  /**
   * Programmatically set the value (e.g. reset / URL restore).
   * @param {number}  next
   * @param {object}  [opts]
   * @param {boolean} [opts.announce=false]
   * @param {boolean} [opts.silent=false]  Skip onInput / onChange.
   * @param {string}  [opts.source='api']
   */
  setValue(next, opts = {}) {
    if (this._typing) return this._value;

    const announce = !!opts.announce;
    const silent   = !!opts.silent;
    const source   = opts.source != null ? opts.source : 'api';
    const v        = this._quantize(next);

    if (v === this._value) {
      this._syncUI({ updateNumber: true });
      return this._value;
    }

    this._value = v;
    this._syncUI({ updateNumber: true });

    if (!silent) {
      this._emitInput(source);
      this._emitChange(source, announce);
    } else if (announce) {
      this.announce(this.formatAnnounce(this._value));
    }

    return this._value;
  }

  /** Push a message into the component (or external) live region. */
  announce(message) {
    if (!this.liveEl || message == null || message === '') return;
    this._queueLive(String(message), false);
  }

  get numberEl() { return this.numberInput; }
  get sliderEl() { return this.slider; }

  /** Point the number field's aria-describedby at an id (null removes it). */
  setDescribedBy(id) {
    this.describedBy = id || null;
    if (this.describedBy) this.numberInput.setAttribute('aria-describedby', this.describedBy);
    else                  this.numberInput.removeAttribute('aria-describedby');
  }

  /** Replace the slider track with a CSS background (null restores the fill). */
  setTrackGradient(css) {
    const on = !!css;
    this.slider.classList.toggle('kl-dual__slider--custom-track', on);
    if (on) this.slider.style.setProperty('--kl-dual-track', css);
    else    this.slider.style.removeProperty('--kl-dual-track');
  }

  /** True while dragging, spinning, key-stepping, or typing an uncommitted value. */
  isBusy() {
    return this._typing || this._isContinuous();
  }

  destroy() {
    this._clearSpinRepeat();
    clearTimeout(this._liveTimer);
    this._sliderKeyArmed   = false;
    for (const { el, type, fn, opts } of this._bound) {
      el.removeEventListener(type, fn, opts);
    }
    this._bound.length = 0;
    this.mount.replaceChildren();
  }

  /* ---- construction ---------------------------------------------------- */

  _normalizeMilestone(milestone) {
    if (milestone == null) return null;
    if (typeof milestone === 'function') return milestone;
    const mod = Number(milestone);
    if (!Number.isFinite(mod) || mod === 0) return null;
    return (v) => {
      const k = Math.pow(10, this.precision);
      const n = Math.round(v * k);
      const m = Math.round(mod * k);
      return n % m === 0;
    };
  }

  _render(opts) {
    const root = document.createElement('div');
    root.className = 'kl-dual' +
                     (this.readOnly  ? ' kl-dual--readonly' : '') +
                     (this.textValue ? ' kl-dual--text'     : '');
    root.id        = this.id + '-dual';

    const numberId = this.id + '-number';
    const sliderId = this.id + '-slider';
    const liveId   = this.id + '-live';

    root.innerHTML =
      '<div class="' + this.numberRowClass + '">' +
        '<label class="control-row__label" for="' + numberId + '">' +
          this._escape(this.label) +
        '</label>' +
        '<div class="kl-dual__number-wrap">' +
          '<input class="' + this.numberClass + '"' +
                 ' id="' + numberId + '"' +
                 ' type="text"' +
                 ' inputmode="' + (this.textValue ? 'text' : 'decimal') + '"' +
                 (this.readOnly ? ' readonly' : '') +
                 ' autocomplete="off"' +
                 ' spellcheck="false">' +
          '<div class="kl-dual__spins">' +
            '<button type="button" class="kl-dual__spin kl-dual__spin--up"' +
                    ' aria-label="' + this._escape(this.spinUpLabel) + '" tabindex="-1"></button>' +
            '<button type="button" class="kl-dual__spin kl-dual__spin--down"' +
                    ' aria-label="' + this._escape(this.spinDownLabel) + '" tabindex="-1"></button>' +
          '</div>' +
        '</div>' +
        (this.unit
          ? '<span class="kl-dual__unit" aria-hidden="true">' + this._escape(this.unit) + '</span>'
          : '') +
      '</div>' +
      '<div class="' + this.sliderRowClass + '">' +
        '<input class="' + this.sliderClass + '"' +
               ' id="' + sliderId + '"' +
               ' type="range"' +
               ' min="' + this.min + '"' +
               ' max="' + this.max + '"' +
               ' step="' + this.step + '"' +
               ' aria-hidden="true"' +
               ' tabindex="-1">' +
        '<span class="kl-dual__scale-min sim-scale-min" aria-hidden="true">' +
          this.minLabel +
        '</span>' +
        '<span class="kl-dual__scale-max sim-scale-max" aria-hidden="true">' +
          this.maxLabel +
        '</span>' +
      '</div>';

    this.mount.replaceChildren(root);
    this.root         = root;
    this.numberInput  = root.querySelector('#' + numberId);
    this.slider       = root.querySelector('#' + sliderId);
    this.spinUp       = root.querySelector('.kl-dual__spin--up');
    this.spinDown     = root.querySelector('.kl-dual__spin--down');

    if (this.sliderDecor) {
      this.sliderDecor.classList.add('kl-dual__decor');
      this.slider.before(this.sliderDecor);
    }
    if (this.describedBy) this.setDescribedBy(this.describedBy);

    if (opts.liveRegion) {
      this.liveEl = opts.liveRegion;
    } else if (opts.createLiveRegion !== false) {
      const live = document.createElement('p');
      live.className = 'sr-only';
      live.id        = liveId;
      live.setAttribute('aria-live', 'polite');
      live.setAttribute('aria-atomic', 'true');
      root.appendChild(live);
      this.liveEl = live;
    } else {
      this.liveEl = null;
    }
  }

  _escape(s) {
    return String(s)
      .replace(/&/g, '&amp;')
      .replace(/</g, '&lt;')
      .replace(/>/g, '&gt;')
      .replace(/"/g, '&quot;');
  }

  _listen(el, type, fn, opts) {
    el.addEventListener(type, fn, opts);
    this._bound.push({ el, type, fn, opts });
  }

  _bind() {
    /* Slider — visual only. Do NOT preventDefault on pointerdown/mousedown:
       Chrome and WebKit need the default action to move the thumb and jump on
       track click. Blur immediately (and on rAF / timeout) so VoiceOver never
       keeps the muted range as the focused slider. Arrow keys after a click/drag
       use an armed window proxy so the range can stay unfocused. */
    const stealSliderFocus = () => {
      if (document.activeElement === this.slider) this.slider.blur();
    };

    const beginSliderGesture = () => {
      this._dragging         = true;
      this._sliderKeyArmed   = true;
      this._lastMilestone    = null;
      this._syncActiveRing();
      this._syncNumberAxMute();
      /* Mute-before-blur so Chrome VO does not burble leaving the number box. */
      this._releaseNumberForGesture();
      stealSliderFocus();
      window.requestAnimationFrame(stealSliderFocus);
      window.setTimeout(stealSliderFocus, 0);
      this._clearLiveRegion();
      this._maybeMovingAnnounce();
    };

    this._listen(this.slider, 'pointerdown', beginSliderGesture);
    this._listen(this.slider, 'mousedown',   beginSliderGesture);
    this._listen(this.slider, 'touchstart',  beginSliderGesture, { passive: true });

    this._listen(document, 'focusin', (evt) => {
      if (evt.target === this.slider) {
        stealSliderFocus();
        window.setTimeout(stealSliderFocus, 0);
        return;
      }
      /* Blurring the muted range lands focus on body/html — keep armed. */
      if (evt.target === document.body ||
          evt.target === document.documentElement) {
        return;
      }
      /* Real focus elsewhere ends the slider arrow / thumb-ring session. */
      if (this._sliderKeyArmed) {
        this._sliderKeyArmed = false;
        this._syncActiveRing();
        this._syncNumberAxMute();
      }
    });

    /* Click outside the range ends the armed session (capture before re-arm). */
    this._listen(document, 'pointerdown', (evt) => {
      if (!this._sliderKeyArmed) return;
      if (evt.target === this.slider || this.slider.contains(evt.target)) return;
      this._sliderKeyArmed = false;
      this._syncActiveRing();
      this._syncNumberAxMute();
    }, true);

    /* While dragging, drop focus if the engine assigns it mid-gesture. */
    this._listen(this.slider, 'pointermove', () => {
      if (this._dragging) stealSliderFocus();
    });

    this._listen(this.slider, 'input', () => {
      stealSliderFocus();
      const v = this._quantize(parseFloat(this.slider.value));
      this._applyContinuous(v, 'slider');
    });

    const endDrag = () => {
      if (!this._dragging) return;
      /* Final write while still muted, then unmute before live announce. */
      this._syncUI({ updateNumber: true, forceNumber: true });
      this._dragging = false;
      this._syncNumberAxMute();
      this._syncActiveRing();
      this._emitChange('slider', true);
    };
    this._listen(this.slider, 'pointerup',     endDrag);
    this._listen(this.slider, 'pointercancel', endDrag);
    this._listen(this.slider, 'touchend',      endDrag);
    this._listen(this.slider, 'change',        endDrag);
    this._listen(window, 'pointerup', endDrag);

    /* Armed slider arrow keys (range stays unfocused for VO). */
    this._listen(window, 'keydown', (evt) => this._onSliderProxyKeyDown(evt));
    this._listen(window, 'keyup',   (evt) => this._onSliderProxyKeyUp(evt));

    /* Number text — typing commits on blur / Enter only. */
    this._listen(this.numberInput, 'input', () => {
      if (this.readOnly) return;
      this._typing = true;
    });

    this._listen(this.numberInput, 'keydown', (evt) => {
      if (!this.textValue && (evt.key === 'e' || evt.key === 'E')) {
        evt.preventDefault();
        return;
      }

      if (evt.key === 'Enter') {
        evt.preventDefault();
        if (this.readOnly) return;
        this._commitTyped('enter');
        this._collapseNumberSelection();
        this.numberInput.blur();
        return;
      }

      /* Collapse before Tab moves focus so Chrome does not keep a sticky range. */
      if (evt.key === 'Tab') {
        this._collapseNumberSelection();
        return;
      }

      const delta = this._deltaForKey(evt);
      if (delta === 0) return;

      evt.preventDefault();
      this._typing = false;
      this._beginKeyStep();
      this._applyContinuous(this._value + delta, 'keyboard');
    });

    this._listen(this.numberInput, 'keyup', (evt) => {
      if (!this._keyStepping) return;
      if (!this._isStepKey(evt.key)) return;
      this._endKeyStep('keyboard');
    });

    /* Collapse while still focused — Chrome keeps a sticky range across blur
       and later treats programmatic .value writes as "selection replaced". */
    this._listen(document, 'pointerdown', (evt) => {
      if (document.activeElement !== this.numberInput) return;
      if (evt.target === this.numberInput) return;
      this._collapseNumberSelection();
    }, true);

    this._listen(this.numberInput, 'blur', () => {
      if (this._keyStepping) this._endKeyStep('keyboard');
      if (this._typing) this._commitTyped('blur');
      this._collapseNumberSelection();
    });

    /* Custom spin buttons with press-and-hold repeat. */
    this._bindSpin(this.spinUp,   +1);
    this._bindSpin(this.spinDown, -1);
  }

  _isStepKey(key) {
    return ['ArrowUp', 'ArrowDown', 'ArrowLeft', 'ArrowRight',
            'PageUp', 'PageDown'].includes(key);
  }

  _deltaForKey(evt) {
    if      (evt.key === 'ArrowUp'    || evt.key === 'ArrowRight') {
      return  keyAccel(evt, this.step);
    } else if (evt.key === 'ArrowDown' || evt.key === 'ArrowLeft') {
      return -keyAccel(evt, this.step);
    } else if (evt.key === 'PageUp') {
      return  this.pageStep;
    } else if (evt.key === 'PageDown') {
      return -this.pageStep;
    }
    return 0;
  }

  _isEditableTarget(el) {
    if (!el || el === this.slider) return false;
    const tag = el.tagName;
    if (tag === 'INPUT' || tag === 'TEXTAREA' || tag === 'SELECT') return true;
    if (el.isContentEditable) return true;
    return false;
  }

  _beginKeyStep() {
    if (this._keyStepping) return;
    this._keyStepping   = true;
    this._lastMilestone = null;
    this._syncActiveRing();
    this._syncNumberAxMute();
    this._clearLiveRegion();
    this._maybeMovingAnnounce();
  }

  _endKeyStep(source) {
    if (!this._keyStepping) return;
    this._syncUI({ updateNumber: true, forceNumber: true });
    this._keyStepping = false;
    this._syncNumberAxMute();
    this._syncActiveRing();
    this._emitChange(source, true);
  }

  _onSliderProxyKeyDown(evt) {
    if (!this._sliderKeyArmed) return;
    if (this._isEditableTarget(evt.target)) return;
    const delta = this._deltaForKey(evt);
    if (delta === 0) return;
    evt.preventDefault();
    this._beginKeyStep();
    this._applyContinuous(this._value + delta, 'slider-key');
  }

  _onSliderProxyKeyUp(evt) {
    if (!this._sliderKeyArmed) return;
    if (!this._keyStepping) return;
    if (!this._isStepKey(evt.key)) return;
    if (this._isEditableTarget(evt.target)) return;
    this._endKeyStep('slider-key');
  }

  _bindSpin(btn, dir) {
    const start = (evt) => {
      /* Block default so the button does not take focus (VO thrash). */
      evt.preventDefault();
      if (typeof btn.blur === 'function') btn.blur();
      this._typing        = false;
      this._spinning      = true;
      this._spinDir       = dir;
      this._lastMilestone = null;
      this._syncActiveRing();
      this._syncNumberAxMute();
      /* Mute then blur — leave blurred; do not restore on release. */
      this._releaseNumberForGesture();
      this._clearLiveRegion();
      this._maybeMovingAnnounce();
      this._nudge(dir, 'spin');
      this._clearSpinRepeat();
      this._spinTimer = window.setTimeout(() => {
        this._spinRepeat = window.setInterval(() => {
          this._nudge(this._spinDir, 'spin');
        }, SPIN_REPEAT_RATE_MS);
      }, SPIN_REPEAT_DELAY_MS);
    };

    const stop = () => {
      if (!this._spinning) return;
      this._clearSpinRepeat();
      /* Sync while muted → unmute → live announce (do not refocus number). */
      this._syncUI({ updateNumber: true, forceNumber: true });
      this._spinning = false;
      this._syncNumberAxMute();
      this._syncActiveRing();
      this._emitChange('spin', true);
    };

    this._listen(btn, 'pointerdown', start);
    this._listen(btn, 'mousedown', (evt) => { evt.preventDefault(); });
    this._listen(btn, 'pointerup',   stop);
    this._listen(btn, 'pointerleave', stop);
    this._listen(btn, 'pointercancel', stop);
    /* Immediate blur if focus still lands — avoid delayed focus→blur burble. */
    this._listen(btn, 'focus', () => { btn.blur(); });
    this._listen(btn, 'keydown', (evt) => {
      if (evt.key !== 'Enter' && evt.key !== ' ') return;
      evt.preventDefault();
      this._nudge(dir, 'spin');
      this._syncUI({ updateNumber: true, forceNumber: true });
      this._emitChange('spin', true);
    });
  }

  _clearSpinRepeat() {
    if (this._spinTimer)  { clearTimeout(this._spinTimer);   this._spinTimer  = 0; }
    if (this._spinRepeat) { clearInterval(this._spinRepeat); this._spinRepeat = 0; }
  }

  /** Drop stale polite text so VO cannot re-read an old value mid-gesture. */
  _clearLiveRegion() {
    clearTimeout(this._liveTimer);
    this._liveTimer        = 0;
    this._pendingMilestone = null;
    if (this.liveEl) this.liveEl.textContent = '';
  }

  /**
   * One speaking slot for the live region. A message waits until the previous
   * one has probably been spoken. A milestone still waiting is replaced by a
   * newer milestone, or folded into the front of a final (release) message,
   * so a crossing just before release is heard once with the final value.
   */
  _queueLive(text, isMilestone) {
    if (this._liveTimer) {
      clearTimeout(this._liveTimer);
      if (!isMilestone && this._pendingMilestone) {
        text = this._pendingMilestone + ' ' + text;
      }
    }
    this._pendingMilestone = isMilestone ? text : null;
    /* Flush first so an identical consecutive string still announces. */
    this.liveEl.textContent = '';
    const wait = Math.max(LIVE_DEBOUNCE_MS, this._speakingUntil - performance.now());
    this._liveTimer = window.setTimeout(() => {
      this._liveTimer         = 0;
      this._pendingMilestone  = null;
      this.liveEl.textContent = text;
      this._speakingUntil     = performance.now() +
                                Math.min(SPEECH_MAX_MS, SPEECH_MS_PER_CHAR * text.length);
    }, wait);
  }

  /** Blue KL-UNL ring on the thumb for the whole armed slider session. */
  _syncActiveRing() {
    this.slider.classList.toggle('kl-dual__slider--active', this._sliderKeyArmed);
  }

  /**
   * Hide the number field from AT during programmatic continuous updates so
   * Chrome+VO does not announce "selection replaced" on every value write.
   * Not used for number-box arrow hold (writes are deferred until keyup).
   */
  _syncNumberAxMute() {
    const mute = this._spinning || this._dragging ||
                 (this._keyStepping && this._sliderKeyArmed);
    if (mute) this.numberInput.setAttribute('aria-hidden', 'true');
    else      this.numberInput.removeAttribute('aria-hidden');
  }

  /**
   * Leave a focused number box for a continuous gesture without Chrome VO
   * burbling the focus exit: aria-hide first, then blur. Caller must already
   * have set the continuous flag and called _syncNumberAxMute (or this sets
   * aria-hidden directly as a belt-and-suspenders).
   */
  _releaseNumberForGesture() {
    if (document.activeElement !== this.numberInput) return;
    this._collapseNumberSelection();
    this.numberInput.setAttribute('aria-hidden', 'true');
    this.numberInput.blur();
  }

  /** Collapse caret so Chrome does not treat later writes as replacing a range. */
  _collapseNumberSelection() {
    try {
      const el = this.numberInput;
      const n = el.value.length;
      /* Re-assign when unfocused so Chrome updates sticky selection bookkeeping. */
      if (document.activeElement !== el) {
        const v = el.value;
        el.value = v;
      }
      el.setSelectionRange(n, n);
    } catch (_) { /* ignore unsupported selection on type */ }
  }

  _writeNumberValue(str) {
    this.numberInput.value = str;
    if (document.activeElement !== this.numberInput) {
      this._collapseNumberSelection();
    }
  }

  /* ---- value plumbing -------------------------------------------------- */

  _quantize(raw) {
    const n = Number(raw);
    if (!Number.isFinite(n)) return this._value;
    const k = Math.pow(10, this.precision);
    return Math.round(clamp(n, this.min, this.max) * k) / k;
  }

  _nudge(dir, source) {
    this._applyContinuous(this._value + dir * this.step, source);
  }

  /** Wrap into [min, max] on a ring of (max - min + step) values. */
  _wrapValue(n) {
    const span = this.max - this.min + this.step;
    return ((n - this.min) % span + span) % span + this.min;
  }

  _applyContinuous(next, source) {
    const raw  = (this.wrap && source !== 'slider') ? this._wrapValue(next) : next;
    const v    = this._quantize(raw);
    const prev = this._value;
    if (v === prev) {
      this._syncUI({ updateNumber: false });
      return;
    }
    this._value = v;
    /* Slider track always; number box updates unless focused mid key-step. */
    this._syncUI({ updateNumber: true });
    this._emitInput(source);
    this._maybeMilestone(prev);
  }

  _commitTyped(source) {
    this._typing = false;
    const raw     = String(this.numberInput.value).trim();
    const parsed  = parseFloat(raw.replace(/,/g, ''));
    const invalid = !Number.isFinite(parsed);
    const clamped = !invalid && (parsed < this.min || parsed > this.max);
    const v       = this._quantize(invalid ? this._value : parsed);
    const changed = v !== this._value;
    this._value = v;
    this._syncUI({ updateNumber: true, forceNumber: true });
    if (changed) this._emitInput(source);
    this._emitChange(source, true, { raw, invalid, clamped });
  }

  /**
   * @param {object}  opts
   * @param {boolean} [opts.updateNumber=false]
   * @param {boolean} [opts.forceNumber=false]  Write the text field even if focused
   *        (interaction ended). Skipped while typing an uncommitted string.
   */
  _syncUI({ updateNumber = false, forceNumber = false } = {}) {
    this.slider.value = String(this._value);
    updateSliderProgress(this.slider);

    if (!updateNumber || this._typing) return;

    const focused = document.activeElement === this.numberInput;

    /* VoiceOver re-announces programmatic .value writes on a focused text
       field during arrow-key hold. Spin / drag must still update digits even
       when focus remains on the number box (spin ticks do not take focus). */
    if (!forceNumber && focused && this._keyStepping) return;
    if (!forceNumber && focused && this._typing) return;
    if (!forceNumber && focused && !this._spinning && !this._dragging) return;

    this._writeNumberValue(this.formatValue(this._value));
  }

  _isContinuous() {
    return this._dragging || this._spinning || this._keyStepping;
  }

  _maybeMovingAnnounce() {
    if (this.announceMoving && this.autoAnnounce) {
      this.announce(this.movingWord);
    }
  }

  _maybeMilestone(prev) {
    if (!this.milestone || !this._isContinuous() || !this.autoAnnounce) return;
    const hit = this.milestone(this._value, prev);
    if (!hit) return;
    /* String results are crossing messages: dedupe on the text so jitter
       back and forth over one threshold speaks it only once. */
    const key = (typeof hit === 'string') ? hit : this._value;
    if (this._lastMilestone === key) return;
    this._lastMilestone = key;
    if (!this.liveEl) return;
    this._queueLive(typeof hit === 'string' ? hit : this.formatAnnounce(this._value), true);
  }

  _emitInput(source) {
    if (this.onInput) this.onInput(this._value, { source });
  }

  _emitChange(source, doAnnounce, extra = {}) {
    let custom = undefined;
    if (this.onChange) {
      custom = this.onChange(this._value, { ...extra, source, announce: doAnnounce });
    }
    if (!doAnnounce || !this.autoAnnounce) return;
    if (custom === false) return;
    if (typeof custom === 'string') {
      this.announce(custom);
      return;
    }
    this.announce(this.formatAnnounce(this._value));
  }
}

export default DualControl;
