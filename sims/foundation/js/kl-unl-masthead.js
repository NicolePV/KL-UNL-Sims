class KLUNLMasthead extends HTMLElement {
  constructor() {
    super();
    // Attach a Shadow DOM to isolate styles and structure from the main page
    this.attachShadow({ mode: 'open' });
    
    // Internal State Tracking
    this.hasReadHelp          = false;
    this.simData              = null;
    this.activeTriggerButton  = null;
  }

  // Define which attributes to watch for changes
  static get observedAttributes() {
    return ['sim-id', 'json-url'];
  }

  async connectedCallback() {
    const simId   = this.getAttribute('sim-id');
    const jsonUrl = this.getAttribute('json-url') || '../foundation/js/kl-unl-masthead.json';

    if (!simId) {
      console.error('kl-unl-masthead: "sim-id" attribute is required.');
      return;
    }

    try {
      const response  = await fetch(jsonUrl);
      const data      = await response.json();
      this.simData    = data[simId];

      if (!this.simData) {
        console.error(`kl-unl-masthead: Simulation ID "${simId}" not found in JSON.`);
        return;
      }

      this.render();
      this.setupEventListeners();
    } catch (error) {
      console.error('kl-unl-masthead: Failed to load sim-specific data.', error);
    }
  }

  render() {
    const mastheadData   = this.simData.masthead;
    const metaData       = this.simData.meta;

    // Check if help content exists and isn't empty
    const hasHelpContent = ( mastheadData.help && mastheadData.help.content.trim() !== "" );

    this.shadowRoot.innerHTML = `
      <link href="../foundation/css/kl-unl.css" type="text/css" rel="stylesheet" media="all">
      <style>
        :host {
          display:             block;
          font-family:         system-ui, -apple-system, sans-serif;
          box-sizing:          border-box;
        }
        
        /* Responsive Container */
        .masthead-container {
          display:             flex;
          flex-wrap:           wrap;
          justify-content:     space-between;
          align-items:         center;
          gap:                 10px;
          background-color:    var(--background-color,          #ffffff);
          color:               var(--foreground-color,          #1a1a1a);
          padding:             10px 16px;
          border-bottom-width: var(--border-bottom-width,       3px);
          border-bottom-style: var(--border-bottom-style,       solid);
          border-bottom-color: var(--border-bottom-color,       #005a9c);
        }

        h1 {
          margin:              0;
          font-size:           1.15rem;
          line-height:         1.3;
          flex:                1 1 200px;
          min-width:           0;
          word-wrap:           break-word;
        }

        .controls-group {
          display:             flex;
          flex-wrap:           wrap;
          gap:                 8px;
          align-items:         center;
        }

        button, .submit-btn {
          color:               var(--button-foreground-color,   #ffffff);
          background-color:    var(--button-background-color,   #005a9c);
          border-width:        var(--border-width,              1px);
          border-style:        var(--border-style,              solid);
          border-color:        var(--border-color,              #767676);
          padding:             6px 12px;
          border-radius:       4px;
          cursor:              pointer;
          font-weight:         600;
          font-size:           0.85rem;
          transition:          filter 0.1s ease;
        }

        button:hover, .submit-btn:hover {
          filter:              brightness( var(--button-hover-darken, 0.9) );
          outline-width:       var(--button-outline-width,      2px);
          outline-style:       var(--button-outline-style,      solid);
          outline-color:       var(--button-outline-color,      #ffbc00);
          outline-offset:      2px;
        }

        button:focus-visible, .submit-btn:focus-visible {
          filter:              brightness( var(--button-hover-darken, 0.9) );
          outline-width:       var(--button-outline-width,      2px);
          outline-style:       var(--button-outline-style,      solid);
          outline-color:       var(--button-outline-color,      #ffbc00);
          outline-offset:      2px;
        }
        /* Compliant light neon green for initial prompt */
        .initial-prompt {
          color:               var(--alert-color-g,             #b3f681);
          border-color:        var(--alert-color-g,             #b3f681);
        }
        
        /* Modal Dialog Styling */
        /* (for overlay showing help or background information) */
        dialog {
          padding:             24px;
          border-width:        var(--border-width,              1px);
          border-style:        var(--border-style,              solid);
          border-color:        var(--border-color,              #767676);
          border-radius:       8px;
          max-width:           600px;
          width:               90vw;
          max-height:          85vh;
          overflow-y:          auto;
          box-shadow:          0 4px 20px rgba(0,0,0,0.25);
          background-color:    var(--background-color,          #ffffff);
          color:               var(--foreground-color,          #1a1a1a);
        }

        dialog::backdrop {
          background-color:    rgba(0, 0, 0, 0.6);
          backdrop-filter:     blur(2px);
        }

        /* Accessible Form Styling */
        .form-group {
          margin-bottom:       16px;
          display:             flex;
          flex-direction:      column;
          gap:                 6px;
        }

        label, legend {
          font-weight:         600;
          font-size:           0.9rem;
        }

        input[type="email"], select, textarea {
          padding:             8px;
          border:              1px solid #767676;
          border-radius:       4px;
          font-family:         inherit;
          font-size:           0.9rem;
          width:               100%;
          box-sizing:          border-box;
        }

        input[type="email"]:focus-visible, 
        select:focus-visible, 
        textarea:focus-visible {
          outline:             2px solid #ffbc00;
          outline-offset:      1px;
        }

        .likert-group {
          border:              1px solid #ccc;
          border-radius:       6px;
          padding:             10px 14px;
          margin:              0 0 16px 0;
        }

        .likert-options {
          display:             flex;
          justify-content:     space-between;
          gap:                 8px;
          margin-top:          8px;
        }

        .likert-option {
          display:             flex;
          flex-direction:      column;
          align-items:         center;
          font-size:           0.8rem;
          gap:                 4px;
        }

        .dialog-footer {
          margin-top:          20px;
          display:             flex;
          justify-content:     flex-end;
          gap:                 10px;
        }

        .close-btn {
          color:               var(--background-color,          #ffffff);
          background-color:    var(--button-background-color,   #005a9c);
        }

        .hp-field {
          display:             none !important;
        }

        /* Mobile Layout Tweaks (<480px) */
        @media (max-width: 480px) {
          .masthead-container {
            padding:           8px 12px;
          }
          h1 {
            font-size:         1.05rem;
          }
          .controls-group {
            width:             100%;
            justify-content:   flex-start;
          }
          .likert-options {
            flex-wrap:         wrap;
          }
        }
      </style>

      <div class="masthead-container">
        <h1 id="sim-title">${metaData.title}</h1>
        <nav class="controls-group" aria-label="Simulation Controls">
          <button id="resetBtn-mh">Reset</button>
          ${hasHelpContent ? `<button id="helpBtn-mh" class="initial-prompt">Review Help Guide</button>` : ''}
          <button id="aboutBtn-mh">About</button>
          <button id="feedbackBtn-mh">Feedback</button>
        </nav>
      </div>

      <!-- Info Dialog (Help & About) -->
      <dialog id="infoDialog-mh" role="alertdialog" aria-labelledby="dialogTitle-mh">
        <h2 id="dialogTitle-mh" style="margin-top: 0;"></h2>
        <div aria-hidden="true">
          <div id="dialogBody-mh"></div>
        </div>
        <p id="sr-description-mh" class="sr-only"></p>
        <div class="dialog-footer">
          <button id="closeDialogBtn-mh" class="close-btn" aria-describedby="sr-description-mh">Close</button>
        </div>
      </dialog>

      <!-- Feedback Dialog -->
      <dialog id="feedbackDialog-mh" aria-labelledby="feedbackTitle-mh">
        <h2 id="feedbackTitle-mh" style="margin-top: 0;">Submit Astronomy Simulation Feedback</h2>

        <form id="feedbackForm-mh" method="dialog">
          <h5>Thank you for helping us to improve these materials.</h5>
        
          <!-- Honeypot anti-spam field -->
          <input type="text" name="website_hp" class="hp-field" tabindex="-1" autocomplete="off" aria-hidden="true">

          <div class="form-group">
            <label for="fbCategory-mh">Feedback Category <span aria-hidden="true">*</span></label>
            <select id="fbCategory-mh" required>
              <option value="" disabled selected>Select a category...</option>
              <option value="functionality">Functionality / Bug Report</option>
              <option value="appearance"   >Visual / Layout Issue</option>
              <option value="server"       >Server Loading / Performance Issue</option>
              <option value="accessibility">Accessibility Concern (WCAG)</option>
              <option value="astronomy"    >Astronomy or Physics Content Concern</option>
              <option value="enhancement"  >Improvement Suggestion / New Feature Idea</option>
              <option value="other"        >Other</option>
            </select>
          </div>

          <fieldset class="likert-group">
            <legend>Importance Rating (1 = Dust grain, 5 = Supernova) <span aria-hidden="true">*</span></legend>
            <div class="likert-options">
              <label class="likert-option"><input type="radio" name="fbImportance" value="1" required> 1</label>
              <label class="likert-option"><input type="radio" name="fbImportance" value="2"> 2</label>
              <label class="likert-option"><input type="radio" name="fbImportance" value="3"> 3</label>
              <label class="likert-option"><input type="radio" name="fbImportance" value="4"> 4</label>
              <label class="likert-option"><input type="radio" name="fbImportance" value="5"> 5</label>
            </div>
          </fieldset>

          <div class="form-group">
            <label for="fbDescription-mh">Description <span aria-hidden="true">*</span></label>
            <textarea id="fbDescription-mh" rows="4" required placeholder="Please describe what occurred or share an idea..."></textarea>
          </div>

          <div class="form-group">
            <label for="fbName-mh">Name (Optional)</label>
            <input type="text" id="fbName-mh">
          </div>

          <div class="form-group">
            <label for="fbEmail-mh">Email Address (Optional)</label>
            <input type="email" id="fbEmail-mh" placeholder="name@example.edu">
            <small id="emailHelp-mh" style="color: #595959;">Your name or email would only be used to clarify your feedback report and will never be shared.</small>
          </div>

          <div class="dialog-footer">
            <button type="button" id="cancelFbBtn-mh">Cancel</button>
            <button type="submit" class="submit-btn" id="submitFbBtn-mh">Submit Feedback</button>
          </div>
        </form>

        <!-- Post-Submit Confirmation View -->
        <div id="fbSuccessView-mh" style="display: none; text-align: center; padding: 20px 0;">
          <h3>Thank You!</h3>
          <p>Your feedback has been recorded and will helps us to improve these astronomy simulations for everyone.</p>
          <div class="dialog-footer" style="justify-content: center;">
            <button type="button" id="closeFbSuccessBtn-mh" class="close-btn">Close</button>
          </div>
        </div>
      </dialog>
    `;
  }

  setupEventListeners() {
    const shadow         = this.shadowRoot;
    const infoDialog     = shadow.getElementById('infoDialog-mh');
    const fbDialog       = shadow.getElementById('feedbackDialog-mh');
    const helpBtn        = shadow.getElementById('helpBtn-mh');
    const aboutBtn       = shadow.getElementById('aboutBtn-mh');
    const resetBtn       = shadow.getElementById('resetBtn-mh');
    const feedbackBtn    = shadow.getElementById('feedbackBtn-mh');
    const closeBtn       = shadow.getElementById('closeDialogBtn-mh');
    
    const fbForm         = shadow.getElementById('feedbackForm-mh');
    const cancelFbBtn    = shadow.getElementById('cancelFbBtn-mh');
    const closeFbSuccess = shadow.getElementById('closeFbSuccessBtn-mh');

    if (helpBtn) {
      helpBtn.addEventListener('click',   () => this.openInfoModal('help',  helpBtn));
    }
    aboutBtn.addEventListener('click',    () => this.openInfoModal('about', aboutBtn));
    feedbackBtn.addEventListener('click', () => this.openFeedbackModal(feedbackBtn));

    resetBtn.addEventListener('click',    () => {
      this.dispatchEvent(new CustomEvent('sim-reset', { bubbles: true, composed: true }));
    });

    // Close button listener
    closeBtn.addEventListener('click',    (e) => this.closeInfoModal(e));

    // Cancel button listener
    cancelFbBtn.addEventListener('click', (e) => this.closeFeedbackModal(e));

    // Success screen close button listener
    closeFbSuccess.addEventListener('click', () => this.closeFeedbackModal());
    
    // Form submit listener
    fbForm.addEventListener('submit', (e) => this.handleFeedbackSubmit(e));

    // Native dialog cancel hook (triggers via 'Escape' key)
    infoDialog.addEventListener('cancel', () => this.handleFocusRestoration());
  }

  openInfoModal(type, triggerBtn) {
    this.activeTriggerButton = triggerBtn;
    const dialog             = this.shadowRoot.getElementById('infoDialog-mh');
    const title              = this.shadowRoot.getElementById('dialogTitle-mh');
    const body               = this.shadowRoot.getElementById('dialogBody-mh');
    const srDesc             = this.shadowRoot.getElementById('sr-description-mh');
    const targetData         = this.simData.masthead[type];

    title.textContent        = targetData.title;
    let s0                   = targetData.content;

    if ( type == "about" )  {
      // Add boilerplate Astronomy Education at UNL statement to About entry for all simulations
      if ( s0.includes("_DEFAEUNL_") )  {
        s0 = s0.replace( "_DEFAEUNL_", "<p>For additional astronomy education materials please visit <a href=\"https://astro.unl.edu/\" target=\"_blank\" rel=\"noopener\" rel=\"noreferrer\">Astronomy Education<span class=\"sr-only\"> (opens in new tab)</span></a> at the University of Nebraska-Lincoln. </p>" );
      }
      // Add boilerplate AAS Applet Task Force statement to About entry for all simulations
      if ( s0.includes("_AASATF_") )  {
        s0 = s0.replace( "_AASATF_", "<p>This tool has been modernized by the AAS Applet Task Force to meet modern web accessibility standards (WCAG 2.1 AA). </p>" );
      }
      // Add boilerplate funding statement to About entry for most funded simulations
      if ( s0.includes("_FUNDYES_") )  {
        s0 = s0.replace( "_FUNDYES_", "<p>Initial funding for this work was provided by NSF grants #0231270 and/or #0404988. </p>" );
      }
      // Add boilerplate license statement to About entry for all simulations
      s0  += "<p>Copyright 2026 The Board of Regents of the University of Nebraska</p><p class=\"p-indent\">Licensed under <a href=\"https://www.apache.org/licenses/LICENSE-2.0\" target=\"_blank\" rel=\"noopener\" rel=\"noreferrer\">the Apache License, Version 2.0<span class=\"sr-only\"> (opens in new tab)</span></a> (the \"License\"); you may not use this file except in compliance with the License. </p><p class=\"p-indent\">Unless required by applicable law or agreed to in writing, software distributed under the License is distributed on an \"AS IS\" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the License for the specific language governing permissions and limitations under the License. </p>";
    }
    body.innerHTML = s0;

    // Convert rich HTML content to a clean, flat string block for VoiceOver
    const tempDiv            = document.createElement('div');
    tempDiv.innerHTML        = body.innerHTML;
    const flatText           = tempDiv.textContent || tempDiv.innerText || "";

    // Set description text for the Close button
    // 
    // Note that VoiceOver will say "close" first and then read the button
    // description. Getting to this point was fairly difficult, so we may have
    // to live with this order as it is fundamental to the accessibility model.
    // (First label element and then read descriptive text.)
    // 
    srDesc.textContent       = flatText;

    // Handle Help button state modifications on initial click
    if (type === 'help' && !this.hasReadHelp) {
      this.hasReadHelp       = true;
      triggerBtn.textContent = "Help";
      triggerBtn.classList.remove('initial-prompt');
    }

    dialog.showModal();

    // Add small delay to allow VoiceOver to finish processing modal opening event
    setTimeout(() => {
      this.shadowRoot.getElementById('closeDialogBtn-mh').focus();
    }, 50);
  }

  openFeedbackModal(triggerBtn) {
    this.activeTriggerButton = triggerBtn;
    const shadow             = this.shadowRoot;
    const dialog             = shadow.getElementById('feedbackDialog-mh');
    
    // Reset form view states
    shadow.getElementById('feedbackForm-mh').reset();
    shadow.getElementById('feedbackForm-mh').style.display = "block";
    shadow.getElementById('fbSuccessView-mh').style.display = "none";

    dialog.showModal();

    setTimeout(() => {
      shadow.getElementById('fbCategory-mh').focus();
    }, 50);
  }

  async handleFeedbackSubmit(e) {
    e.preventDefault();
    const shadow = this.shadowRoot;

    // 1. Anti-spam Honeypot Check
    const hpVal = shadow.querySelector('input[name="website_hp"]').value;
    if (hpVal) {
      this.closeFeedbackModal();
      return;
    }

    const submitBtn       = shadow.getElementById('submitFbBtn-mh');
    submitBtn.disabled    = true;
    submitBtn.textContent = "Sending...";

    // 2. Gather User Inputs
    const category    = shadow.getElementById('fbCategory-mh').value;
    const description = shadow.getElementById('fbDescription-mh').value;
    const name        = shadow.getElementById('fbName-mh').value;
    const email       = shadow.getElementById('fbEmail-mh').value;
    const importance  = shadow.querySelector('input[name="fbImportance"]:checked')?.value || "3";

    // 3. Assemble Metadata Payload
    const payload = {
      simId:       this.getAttribute('sim-id'),
      timestamp:   new Date().toISOString(),
      originHost:  window.location.origin,
      userAgent:   navigator.userAgent,
      screenRes:   `${window.screen.width}x${window.screen.height}`,
      category:    category,
      importance:  importance,
      description: description,
      userName:    name  || "Not provided",
      userEmail:   email || "Not provided"
    };

    // Determine target mode ('github', 'sheets', or 'both')
    const mode      = this.getAttribute('feedback-mode') || 'both';
    const proxyUrl  = this.getAttribute('proxy-url')     || 'http://astronomy.nmsu.edu/geas/klunl/api/feedback-proxy.php';
    const sheetsUrl = this.getAttribute('sheets-url')    || 'https://script.google.com/macros/s/AKfycbzZV7Z8d-tVO3bGTFiZNxFRIeB6PKyGeSqpvsVRmgqbrXfugMGatGHc64oaT79kKvivpw/exec';

    const requests = [];

    // Option A: Send to GitHub Proxy
    if ((mode === 'github' || mode === 'both') && proxyUrl) {
      requests.push(
        fetch(proxyUrl, {
          method:  'POST',
          headers: { 'Content-Type': 'application/json' },
          body:    JSON.stringify(payload)
        })
      );
    }

    // Option B: Send to Google Apps Script Endpoint
    if ((mode === 'sheets' || mode === 'both') && sheetsUrl) {
      requests.push(
        fetch(sheetsUrl, {
          method: 'POST',
          // Google Apps Script requires text/plain or no-cors mode to avoid preflight CORS blocks
          headers: { 'Content-Type': 'text/plain;charset=utf-8' },
          body: JSON.stringify(payload)
        })
      );
    }

    try {
      await Promise.all(requests);

      // Show Thank You Screen on Success
      shadow.getElementById('feedbackForm-mh').style.display  = "none";
      shadow.getElementById('fbSuccessView-mh').style.display = "block";
      shadow.getElementById('closeFbSuccessBtn-mh').focus();

    } catch (err) {
      console.error('Feedback delivery issue:', err);
      alert('There was a problem submitting your feedback. Please try again later.');
    } finally {
      submitBtn.disabled    = false;
      submitBtn.textContent = "Submit Feedback";
    }
  }

  closeInfoModal() {
    this.shadowRoot.getElementById('infoDialog-mh').close();

    // Clear description so it's ready for next time a masthead button is clicked
    this.shadowRoot.getElementById('sr-description-mh').textContent = "";
    this.handleFocusRestoration();
  }

  closeFeedbackModal() {
    this.shadowRoot.getElementById('feedbackDialog-mh').close();
    this.handleFocusRestoration();
  }

  handleFocusRestoration() {
    if (!this.activeTriggerButton) return;

    // 1. Restore focus to the trigger button for WCAG AA compliance
    this.activeTriggerButton.focus();

    // 2. Clear stuck outline as soon as pointer/touchpad moves
    const clearStuckFocusOnPointerMove = () => {
      if (this.activeTriggerButton && this.shadowRoot.activeElement === this.activeTriggerButton) {
        this.activeTriggerButton.blur();
      }
      // Remove listener immediately so it only runs once per modal close
      this.shadowRoot.removeEventListener('pointermove', clearStuckFocusOnPointerMove);
    };

    // Attach listener for mouse/touchpad movement
    this.shadowRoot.addEventListener('pointermove', clearStuckFocusOnPointerMove, { once: true });
  }
}

// Define the custom element name to explicitly honor project founder
customElements.define('kl-unl-masthead', KLUNLMasthead);

// Allow "skip to main content" screen reader anchor tag to point to Help button
document.querySelector('a[href="#helpBtn-mh"]').addEventListener('click', function (e) {
  e.preventDefault();
  const masthead = document.querySelector('kl-unl-masthead');
  if (masthead && masthead.shadowRoot) {
    const helpBtn = masthead.shadowRoot.querySelector('#helpBtn-mh') || 
                    masthead.shadowRoot.querySelector('button');
    if (helpBtn) {
      helpBtn.focus();
    }
  }
});
