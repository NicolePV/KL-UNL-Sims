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
    const jsonUrl = this.getAttribute('json-url') || '../template_masthead/localization.json';

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
      console.error('kl-unl-masthead: Failed to load localization data.', error);
    }
  }

  render() {
    const mastheadData   = this.simData.masthead;
    const metaData       = this.simData.meta;

    // Check if help content exists and isn't empty
    const hasHelpContent = mastheadData.help && mastheadData.help.content.trim() !== "";

    this.shadowRoot.innerHTML = `
      <style>
        :host {
          display:             block;
          font-family:         system-ui, -apple-system, sans-serif;
          box-sizing:          border-box;
        }
        .masthead-container {
          display:             flex;
          justify-content:     space-between;
          align-items:         center;
          background-color:    var(--masthead-bg,   #ffffff);
          color:               var(--masthead-text, #1a1a1a);
          padding:             10px 20px;
          border-bottom:       3px solid var(--primary-color, #005a9c);
        }
        h1 {
          margin:              0;
          font-size:           1.25rem;
        }
        .controls-group {
          display:             flex;
          gap:                 10px;
        }
        button {
          background-color:    var(--bg-color,   #005a9c);
          color:               var(--text-color, #ffffff);
          border:              1px solid var(--input-border, #767676);
          padding:             6px 12px;
          border-radius:       4px;
          cursor:              pointer;
          font-weight:         600;
          font-size:           0.9rem;
          transition:          filter 0.1s ease; /* Smooth hover transition */
        }
        button:hover, button:focus {
          filter:              brightness(var(--hover-darken, 0.9));
          outline:             2px solid var(--focus-ring-color, #ffbc00);
          outline-offset:      2px;
        }
        /* Compliant dynamic red for initial prompt (passes 4.5:1 on light gray button) */
        .initial-prompt {
          color:               var(--alert-color, #b3f681);  /* crimson would be #b30000 */
          border-color:        var(--alert-color, #b3f681);
        }
        
        /* Modal Dialog Styling */
        /* (for overlay showing help or background information) */
        dialog {
          padding:             24px;
          border:              1px solid var(--input-border, #767676);
          border-radius:       8px;
          max-width:           600px;
          width:               80vw;
          max-height:          80vh;
          overflow-y:          auto;
          box-shadow:          0 4px 20px rgba(0,0,0,0.2);
          background-color:    var(--bg-color,   #ffffff);
          color:               var(--text-color, #222222);
        }
        dialog::backdrop {
          background-color:    rgba(0, 0, 0, 0.6);
          backdrop-filter:     blur(2px);
        }
        .dialog-footer {
          margin-top:          20px;
          display:             flex;
          justify-content:     flex-end;
        }
        .close-btn {
          background-color:    var(--primary-color,      #005a9c);
          color:               var(--inverse-text-color, #ffffff);
          border:              none;
        }
      </style>

      <div class="masthead-container">
        <h1 id="sim-title">${metaData.title}</h1>
        <nav class="controls-group" aria-label="Simulation Controls">
          <button id="resetBtn">Reset</button>
          ${hasHelpContent ? `<button id="helpBtn" class="initial-prompt">Review Help Guide</button>` : ''}
          <button id="aboutBtn">About</button>
        </nav>
      </div>

      <dialog id="infoDialog" aria-labelledby="dialogTitle">
        <h2 id="dialogTitle" style="margin-top: 0;"></h2>
        <div id="dialogBody"></div>
        <div class="dialog-footer">
          <button id="closeDialogBtn" class="close-btn">Close</button>
        </div>
      </dialog>
    `;
  }

  setupEventListeners() {
    const shadow   = this.shadowRoot;
    const dialog   = shadow.getElementById('infoDialog');
    const helpBtn  = shadow.getElementById('helpBtn');
    const aboutBtn = shadow.getElementById('aboutBtn');
    const resetBtn = shadow.getElementById('resetBtn');
    const closeBtn = shadow.getElementById('closeDialogBtn');

    if (helpBtn) {
      helpBtn.addEventListener('click', () => this.openModal('help', helpBtn));
    }
    aboutBtn.addEventListener('click', () => this.openModal('about', aboutBtn));
    
    // Bubble the Reset event up so the individual simulation file can listen for it
    resetBtn.addEventListener('click', () => {
      this.dispatchEvent(new CustomEvent('sim-reset', { bubbles: true, composed: true }));
    });

    closeBtn.addEventListener('click', () => this.closeModal());

    // Native dialog cancel hook (triggers via 'Escape' key)
    dialog.addEventListener('cancel', () => this.handleFocusRestoration());
  }

  openModal(type, triggerBtn) {
    this.activeTriggerButton = triggerBtn;
    const dialog             = this.shadowRoot.getElementById('infoDialog');
    const title              = this.shadowRoot.getElementById('dialogTitle');
    const body               = this.shadowRoot.getElementById('dialogBody');
    const targetData         = this.simData.masthead[type];

    title.textContent        = targetData.title;
    body.innerHTML           = targetData.content;

    // Handle Help button state modifications on initial click
    if (type === 'help' && !this.hasReadHelp) {
      this.hasReadHelp       = true;
      triggerBtn.textContent = "Help";
      triggerBtn.classList.remove('initial-prompt');
    }

    dialog.showModal();
    this.shadowRoot.getElementById('closeDialogBtn').focus();
  }

  closeModal() {
    this.shadowRoot.getElementById('infoDialog').close();
    this.handleFocusRestoration();
  }

  handleFocusRestoration() {
    if (this.activeTriggerButton) {
      this.activeTriggerButton.focus();
    }
  }
}

// Define the custom element name to explicitly honor project founder
customElements.define('kl-unl-masthead', KLUNLMasthead);
