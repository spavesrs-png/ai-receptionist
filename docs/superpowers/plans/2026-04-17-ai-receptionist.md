# AI Receptionist Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Build a single self-contained `receptionist.html` that is a fully functional AI receptionist widget powered by the Claude API, with a password-protected admin panel, floating and embedded display modes, brand colour theming, and streaming responses.

**Architecture:** All HTML, CSS, and JavaScript live in one file. Config is persisted to `localStorage`. The Claude API (`claude-sonnet-4-6`) is called directly from the browser via `fetch()` using Server-Sent Events for streaming. No build tools, no frameworks, no backend.

**Tech Stack:** Vanilla HTML5, CSS3 (custom properties for theming), JavaScript ES2020, Web Crypto API (SHA-256 password hashing), Claude API (streaming SSE).

---

## Script block code order (important for a single-file app)

The `<script>` block at the bottom of `<body>` must contain code in this order so variables are defined before use:

1. Embed mode detection
2. Config constants + `loadConfig()` + `saveConfig()` + `applyConfig()` + `darkenColor()`
3. Bubble/panel toggle + notification badge
4. Welcome message (`function showWelcomeMessage`)
5. Chat helpers + `handleSend()` + `buildSystemPrompt()`
6. Admin auth (overlay, password screen)
7. Admin settings form (populate, save, FAQ, colour picker, embed code, password change, API test)

Each task in this plan appends to the correct position in that order. When a task says "add to `<script>`" it means insert in the logical position shown above — not necessarily at the very end.

---

## Task 1: HTML skeleton + CSS foundation

**Files:**
- Create: `receptionist.html`

- [ ] **Step 1: Create the file**

Create `receptionist.html` with this exact content:

```html
<!DOCTYPE html>
<html lang="sv">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>AI Receptionist</title>
  <style>
    *, *::before, *::after { box-sizing: border-box; margin: 0; padding: 0; }

    :root {
      --brand: #4F46E5;
      --brand-dark: #3730A3;
      --white: #ffffff;
      --gray-50: #F9FAFB;
      --gray-100: #F3F4F6;
      --gray-200: #E5E7EB;
      --gray-400: #9CA3AF;
      --gray-500: #6B7280;
      --gray-700: #374151;
      --gray-900: #111827;
      --radius: 12px;
      --shadow: 0 4px 24px rgba(0,0,0,0.12);
      --font: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, sans-serif;
    }

    body {
      font-family: var(--font);
      font-size: 15px;
      color: var(--gray-900);
      line-height: 1.5;
    }
  </style>
</head>
<body>

  <script>
    console.log('AI Receptionist loading...');
  </script>
</body>
</html>
```

- [ ] **Step 2: Verify in browser**

Open `receptionist.html` in your browser (double-click the file). You should see:
- A blank white page
- In DevTools console (F12 → Console tab): `AI Receptionist loading...`
- Zero red errors in the console

- [ ] **Step 3: Commit**

```bash
cd c:/Users/simon/marketingskills/ai-receptionist
git add receptionist.html
git commit -m "feat: HTML skeleton with CSS custom properties"
```

---

## Task 2: Static chat panel + floating bubble (HTML + CSS only)

No JavaScript yet — just the visual structure so you can see the widget immediately.

**Files:**
- Modify: `receptionist.html`

- [ ] **Step 1: Add chat panel HTML**

Replace the blank line between `<body>` and `<script>` with:

```html
  <!-- Floating bubble -->
  <button id="bubble-btn" aria-label="Öppna chat">
    <svg width="26" height="26" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
      <path d="M21 15a2 2 0 0 1-2 2H7l-4 4V5a2 2 0 0 1 2-2h14a2 2 0 0 1 2 2z"></path>
    </svg>
    <span id="bubble-badge" hidden>1</span>
  </button>

  <!-- Chat panel (starts hidden; class removed by JS on open) -->
  <div id="chat-panel" class="hidden">
    <div id="chat-header">
      <div id="header-info">
        <div id="header-avatar">R</div>
        <div>
          <div id="header-title">AI Receptionist</div>
          <div id="header-status">● Online nu</div>
        </div>
      </div>
      <button id="close-btn" aria-label="Stäng">✕</button>
    </div>

    <div id="messages-area"></div>

    <div id="input-area">
      <input id="message-input" type="text"
             placeholder="Skriv ett meddelande..."
             autocomplete="off" />
      <button id="send-btn" disabled aria-label="Skicka">
        <svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5" stroke-linecap="round" stroke-linejoin="round">
          <line x1="22" y1="2" x2="11" y2="13"></line>
          <polygon points="22 2 15 22 11 13 2 9 22 2"></polygon>
        </svg>
      </button>
    </div>

    <div id="admin-bar">
      <a href="#" id="admin-link">Admin</a>
    </div>
  </div>
```

- [ ] **Step 2: Add all chat panel CSS**

Add inside `<style>`, after the `body {}` rule:

```css
    /* ── Chat Panel ── */
    #chat-panel {
      position: fixed;
      bottom: 90px;
      right: 20px;
      width: 380px;
      height: 540px;
      background: var(--white);
      border-radius: var(--radius);
      box-shadow: var(--shadow);
      display: flex;
      flex-direction: column;
      overflow: hidden;
      transition: opacity 0.2s ease, transform 0.2s ease;
      z-index: 9999;
    }
    #chat-panel.hidden {
      opacity: 0;
      transform: translateY(12px);
      pointer-events: none;
    }

    /* Header */
    #chat-header {
      background: var(--brand);
      color: var(--white);
      padding: 14px 16px;
      display: flex;
      align-items: center;
      justify-content: space-between;
      flex-shrink: 0;
    }
    #header-info { display: flex; align-items: center; gap: 10px; }
    #header-avatar {
      width: 36px; height: 36px;
      background: rgba(255,255,255,0.25);
      border-radius: 50%;
      display: flex; align-items: center; justify-content: center;
      font-weight: 700; font-size: 16px;
    }
    #header-title { font-weight: 600; font-size: 15px; }
    #header-status { font-size: 12px; opacity: 0.85; }
    #close-btn {
      background: none; border: none; color: var(--white);
      cursor: pointer; font-size: 18px; opacity: 0.8; padding: 4px;
    }
    #close-btn:hover { opacity: 1; }

    /* Messages */
    #messages-area {
      flex: 1; overflow-y: auto; padding: 16px;
      display: flex; flex-direction: column; gap: 10px;
      background: var(--gray-50);
    }
    .msg {
      max-width: 80%; padding: 10px 14px; border-radius: 16px;
      font-size: 14px; line-height: 1.5; word-wrap: break-word;
    }
    .msg-ai {
      background: var(--white); color: var(--gray-900);
      border: 1px solid var(--gray-200);
      align-self: flex-start; border-bottom-left-radius: 4px;
    }
    .msg-user {
      background: var(--brand); color: var(--white);
      align-self: flex-end; border-bottom-right-radius: 4px;
    }
    .msg-error {
      background: #FEF2F2; color: #B91C1C;
      border: 1px solid #FECACA;
      align-self: flex-start; border-bottom-left-radius: 4px;
    }
    .msg-typing {
      background: var(--white); border: 1px solid var(--gray-200);
      align-self: flex-start; border-bottom-left-radius: 4px;
      padding: 12px 16px;
    }
    .typing-dots { display: flex; gap: 4px; }
    .typing-dots span {
      width: 6px; height: 6px; background: var(--gray-400);
      border-radius: 50%; animation: bounce 1.2s infinite;
    }
    .typing-dots span:nth-child(2) { animation-delay: 0.2s; }
    .typing-dots span:nth-child(3) { animation-delay: 0.4s; }
    @keyframes bounce {
      0%, 80%, 100% { transform: translateY(0); }
      40%           { transform: translateY(-6px); }
    }

    /* Input */
    #input-area {
      padding: 12px; display: flex; gap: 8px;
      background: var(--white); border-top: 1px solid var(--gray-200);
      flex-shrink: 0;
    }
    #message-input {
      flex: 1; padding: 10px 14px;
      border: 1px solid var(--gray-200); border-radius: 24px;
      font-family: var(--font); font-size: 14px; outline: none;
      transition: border-color 0.15s;
    }
    #message-input:focus { border-color: var(--brand); }
    #send-btn {
      width: 42px; height: 42px; background: var(--brand);
      color: var(--white); border: none; border-radius: 50%;
      cursor: pointer; display: flex; align-items: center;
      justify-content: center; transition: background 0.15s, opacity 0.15s;
      flex-shrink: 0;
    }
    #send-btn:hover { background: var(--brand-dark); }
    #send-btn:disabled { opacity: 0.4; cursor: not-allowed; }

    /* Admin bar */
    #admin-bar {
      text-align: center; padding: 6px;
      border-top: 1px solid var(--gray-100);
      background: var(--white); flex-shrink: 0;
    }
    #admin-link { font-size: 11px; color: var(--gray-400); text-decoration: none; }
    #admin-link:hover { color: var(--gray-500); }

    /* Floating bubble */
    #bubble-btn {
      position: fixed; bottom: 20px; right: 20px;
      width: 56px; height: 56px; background: var(--brand);
      color: var(--white); border: none; border-radius: 50%;
      cursor: pointer; display: flex; align-items: center;
      justify-content: center;
      box-shadow: 0 4px 16px rgba(0,0,0,0.2);
      transition: background 0.15s, transform 0.15s; z-index: 10000;
    }
    #bubble-btn:hover { background: var(--brand-dark); transform: scale(1.05); }
    #bubble-badge {
      position: absolute; top: -4px; right: -4px;
      width: 20px; height: 20px; background: #EF4444; color: white;
      border-radius: 50%; font-size: 11px; font-weight: 700;
      display: flex; align-items: center; justify-content: center;
      animation: pulse 2s infinite;
    }
    @keyframes pulse {
      0%, 100% { transform: scale(1); }
      50%       { transform: scale(1.15); }
    }

    /* Mobile: full screen chat panel */
    @media (max-width: 480px) {
      #chat-panel { bottom: 0; right: 0; width: 100%; height: 100%; border-radius: 0; }
    }
```

- [ ] **Step 3: Verify in browser**

Reload `receptionist.html`. You should see:
- A purple circular bubble button in the bottom-right corner
- A chat panel above it (visible but faded out — the `hidden` class makes it transparent but still in the DOM so you can inspect it)

To preview the panel fully, temporarily remove `class="hidden"` from `#chat-panel` in the HTML. You should see a complete chat UI with header, empty messages area, input, and a tiny "Admin" link. Put `class="hidden"` back after previewing.

- [ ] **Step 4: Commit**

```bash
git add receptionist.html
git commit -m "feat: static chat panel and floating bubble UI"
```

---

## Task 3: Bubble open/close toggle + notification badge

Wire up the bubble to open/close the panel with animation, and show the notification badge after 4 seconds.

**Files:**
- Modify: `receptionist.html`

- [ ] **Step 1: Add toggle JavaScript**

Replace `console.log('AI Receptionist loading...');` in the `<script>` block with:

```javascript
    // ── Embed mode detection (must be first) ────────────────────────────────
    const isEmbedMode = new URLSearchParams(window.location.search).get('mode') === 'embed';

    // ── DOM refs ─────────────────────────────────────────────────────────────
    const panel      = document.getElementById('chat-panel');
    const bubbleBtn  = document.getElementById('bubble-btn');
    const closeBtn   = document.getElementById('close-btn');
    const bubbleBadge = document.getElementById('bubble-badge');

    // ── Bubble toggle ────────────────────────────────────────────────────────
    let badgeTimer = null;

    function openChat() {
      panel.classList.remove('hidden');
      bubbleBadge.hidden = true;
      clearTimeout(badgeTimer);
    }

    function closeChat() {
      panel.classList.add('hidden');
    }

    bubbleBtn.addEventListener('click', () => {
      panel.classList.contains('hidden') ? openChat() : closeChat();
    });
    closeBtn.addEventListener('click', closeChat);

    // Show notification badge after 4s if chat hasn't been opened
    badgeTimer = setTimeout(() => {
      if (panel.classList.contains('hidden')) bubbleBadge.hidden = false;
    }, 4000);
```

- [ ] **Step 2: Verify in browser**

Reload the page. Verify:
- Only the bubble is visible on load (panel hidden)
- Clicking the bubble → panel slides up smoothly
- Clicking bubble again or ✕ → panel closes
- Wait 4 seconds without clicking → red pulsing "1" badge appears
- Click bubble → badge disappears, panel opens

- [ ] **Step 3: Commit**

```bash
git add receptionist.html
git commit -m "feat: bubble open/close toggle and 4s notification badge nudge"
```

---

## Task 4: Embedded panel mode

Detect `?mode=embed` in the URL and render the chat as a full-page block element.

**Files:**
- Modify: `receptionist.html`

- [ ] **Step 1: Add embed mode CSS**

Add to `<style>`:

```css
    /* ── Embed mode ── */
    body.embed-mode #bubble-btn { display: none; }
    body.embed-mode #chat-panel {
      position: relative;
      bottom: auto; right: auto;
      width: 100%; height: 100vh;
      border-radius: var(--radius);
      box-shadow: var(--shadow);
      opacity: 1; transform: none; pointer-events: auto;
    }
    body.embed-mode #close-btn { display: none; }
```

- [ ] **Step 2: Add embed mode activation**

At the bottom of the `isEmbedMode` detection line in `<script>`, add:

```javascript
    if (isEmbedMode) {
      document.body.classList.add('embed-mode');
      panel.classList.remove('hidden');
    }
```

- [ ] **Step 3: Verify in browser**

Open `receptionist.html?mode=embed` in your browser. You should see:
- No floating bubble
- Chat panel fills the full page, no close button
- Open `receptionist.html` (no param) — floating bubble is back, panel is hidden on load

- [ ] **Step 4: Commit**

```bash
git add receptionist.html
git commit -m "feat: embedded panel mode via ?mode=embed URL param"
```

---

## Task 5: localStorage config system

Load and save all business configuration. Apply brand colour and business name to the UI.

**Files:**
- Modify: `receptionist.html`

- [ ] **Step 1: Add config functions**

Add to `<script>` after the bubble toggle section:

```javascript
    // ── Config ───────────────────────────────────────────────────────────────
    const STORAGE_KEY = 'ai_receptionist_config';

    const DEFAULT_CONFIG = {
      businessName: '',
      tagline: '',
      phone: '',
      hours: '',
      services: '',
      faqs: [{ q: '', a: '' }],
      bookingUrl: '',
      apiKey: '',
      brandColor: '#4F46E5',
      passwordHash: null
    };

    let config = { ...DEFAULT_CONFIG };

    function loadConfig() {
      try {
        const stored = localStorage.getItem(STORAGE_KEY);
        if (stored) config = { ...DEFAULT_CONFIG, ...JSON.parse(stored) };
      } catch {
        config = { ...DEFAULT_CONFIG };
      }
    }

    function saveConfig() {
      localStorage.setItem(STORAGE_KEY, JSON.stringify(config));
    }

    function darkenColor(hex, pct) {
      const n = parseInt(hex.replace('#', ''), 16);
      const r = Math.max(0, (n >> 16)        - Math.round(2.55 * pct));
      const g = Math.max(0, ((n >> 8) & 0xFF) - Math.round(2.55 * pct));
      const b = Math.max(0, (n & 0xFF)        - Math.round(2.55 * pct));
      return '#' + [r, g, b].map(v => v.toString(16).padStart(2, '0')).join('');
    }

    function applyConfig() {
      document.documentElement.style.setProperty('--brand', config.brandColor);
      document.documentElement.style.setProperty('--brand-dark', darkenColor(config.brandColor, 15));
      document.getElementById('header-title').textContent =
        config.businessName || 'AI Receptionist';
      document.getElementById('header-avatar').textContent =
        (config.businessName || 'A')[0].toUpperCase();
    }

    // Load config and apply on startup
    loadConfig();
    applyConfig();
```

- [ ] **Step 2: Verify in browser**

Open DevTools console (F12) and run:

```javascript
localStorage.setItem('ai_receptionist_config', JSON.stringify({ businessName: 'Salong Vera', brandColor: '#059669' }));
location.reload();
```

You should see:
- Header reads "Salong Vera", avatar shows "S"
- Bubble and header are now green

Clear it: `localStorage.removeItem('ai_receptionist_config')` then reload to restore defaults.

- [ ] **Step 3: Commit**

```bash
git add receptionist.html
git commit -m "feat: localStorage config system with brand colour theming"
```

---

## Task 6: Admin panel HTML + CSS

Add the admin overlay — password screen and settings form. No functionality yet, just the UI.

**Files:**
- Modify: `receptionist.html`

- [ ] **Step 1: Add admin overlay HTML**

Add after `</div>` (closing `#chat-panel`) and before `<script>`:

```html
  <!-- Admin overlay -->
  <div id="admin-overlay" hidden>

    <!-- Password screen -->
    <div id="password-screen">
      <div id="admin-card">
        <h2 id="password-title">Admin</h2>
        <p id="password-desc">Ange ditt lösenord</p>
        <input id="password-input" type="password"
               placeholder="Lösenord" autocomplete="current-password" />
        <p id="password-error" hidden style="color:#B91C1C;font-size:13px">Fel lösenord. Försök igen.</p>
        <button id="password-submit-btn">Logga in</button>
        <a href="#" id="cancel-admin">Avbryt</a>
      </div>
    </div>

    <!-- Settings screen -->
    <div id="settings-screen" hidden>
      <div id="settings-panel">

        <div id="settings-header">
          <h2>Inställningar</h2>
          <button id="settings-close-btn">✕</button>
        </div>

        <div id="settings-form">

          <section class="settings-section">
            <h3>Företag</h3>
            <label>Företagsnamn <span style="color:#EF4444">*</span>
              <input type="text" id="s-businessName" placeholder="t.ex. Salong Vera" />
            </label>
            <label>Tagline (valfri)
              <input type="text" id="s-tagline" placeholder="t.ex. Din salong i Gamla Stan" />
            </label>
            <label>Telefonnummer (valfritt)
              <input type="tel" id="s-phone" placeholder="t.ex. 08-123 456 78" />
            </label>
          </section>

          <section class="settings-section">
            <h3>Öppettider</h3>
            <label>
              <textarea id="s-hours" rows="3"
                placeholder="t.ex. Mån–Fre 09:00–18:00&#10;Lör 10:00–14:00&#10;Sön Stängt"></textarea>
            </label>
          </section>

          <section class="settings-section">
            <h3>Tjänster &amp; priser</h3>
            <label>
              <textarea id="s-services" rows="4"
                placeholder="t.ex.&#10;Klippning 350kr&#10;Färgning 850kr"></textarea>
            </label>
          </section>

          <section class="settings-section">
            <h3>Vanliga frågor (FAQ)</h3>
            <div id="faq-list"></div>
            <button type="button" id="add-faq-btn">+ Lägg till fråga</button>
          </section>

          <section class="settings-section">
            <h3>Bokning</h3>
            <label>Bokningslänk
              <input type="url" id="s-bookingUrl"
                     placeholder="t.ex. https://www.bokadirekt.se/..." />
            </label>
          </section>

          <section class="settings-section">
            <h3>Claude API</h3>
            <label>API-nyckel
              <input type="password" id="s-apiKey"
                     placeholder="sk-ant-..." autocomplete="off" />
            </label>
            <button type="button" id="test-api-btn">Testa anslutning</button>
            <p id="api-test-result" hidden style="font-size:13px;margin-top:6px"></p>
          </section>

          <section class="settings-section">
            <h3>Utseende</h3>
            <label>Varumärkesfärg
              <div style="display:flex;align-items:center;gap:10px;margin-top:4px">
                <input type="color" id="s-brandColor" value="#4F46E5" />
                <span id="color-preview" style="display:inline-block;width:28px;height:28px;border-radius:50%;border:2px solid var(--gray-200)"></span>
              </div>
            </label>
            <label>Widgetläge
              <div style="display:flex;gap:20px;margin-top:8px">
                <label style="flex-direction:row;align-items:center;gap:6px;font-weight:400;cursor:pointer;margin-bottom:0">
                  <input type="radio" name="widgetMode" value="floating" checked /> Flytande bubbla
                </label>
                <label style="flex-direction:row;align-items:center;gap:6px;font-weight:400;cursor:pointer;margin-bottom:0">
                  <input type="radio" name="widgetMode" value="embedded" /> Inbäddad panel
                </label>
              </div>
            </label>
          </section>

          <section class="settings-section" id="embed-code-section" hidden>
            <h3>Inbäddningskod</h3>
            <p style="font-size:13px;color:var(--gray-500);margin-bottom:8px">
              Klistra in denna kod på din webbplats:
            </p>
            <textarea id="embed-code-area" readonly rows="4"
              style="font-family:monospace;font-size:12px;background:var(--gray-50)"></textarea>
            <button type="button" id="copy-embed-btn">Kopiera kod</button>
          </section>

          <section class="settings-section">
            <h3>Lösenord</h3>
            <a href="#" id="change-password-link">Ändra lösenord</a>
            <div id="change-password-form" hidden
                 style="display:flex;flex-direction:column;gap:8px;margin-top:10px">
              <input type="password" id="cp-current" placeholder="Nuvarande lösenord" />
              <input type="password" id="cp-new"     placeholder="Nytt lösenord (minst 6 tecken)" />
              <input type="password" id="cp-confirm"  placeholder="Bekräfta nytt lösenord" />
              <button type="button" id="cp-submit-btn">Uppdatera lösenord</button>
              <p id="cp-error" hidden style="font-size:13px;color:#B91C1C"></p>
            </div>
          </section>

        </div><!-- /settings-form -->

        <div id="settings-footer">
          <button id="save-settings-btn">Spara inställningar</button>
          <p id="save-toast" hidden>✓ Inställningar sparade!</p>
        </div>

      </div><!-- /settings-panel -->
    </div><!-- /settings-screen -->

  </div><!-- /admin-overlay -->
```

- [ ] **Step 2: Add admin overlay CSS**

Add to `<style>`:

```css
    /* ── Admin Overlay ── */
    #admin-overlay {
      position: fixed; inset: 0;
      background: rgba(0,0,0,0.5);
      z-index: 99999; display: flex;
      align-items: center; justify-content: center;
    }
    #admin-overlay[hidden] { display: none; }

    /* Password card */
    #admin-card {
      background: var(--white); border-radius: var(--radius);
      padding: 32px; width: 320px;
      display: flex; flex-direction: column; gap: 12px;
      box-shadow: var(--shadow);
    }
    #admin-card h2 { font-size: 20px; font-weight: 700; }
    #admin-card p  { font-size: 14px; color: var(--gray-500); }
    #admin-card input {
      width: 100%; padding: 10px 14px;
      border: 1px solid var(--gray-200); border-radius: 8px;
      font-size: 15px; font-family: var(--font); outline: none;
    }
    #admin-card input:focus { border-color: var(--brand); }
    #password-submit-btn {
      width: 100%; padding: 11px;
      background: var(--brand); color: var(--white);
      border: none; border-radius: 8px;
      font-size: 15px; font-weight: 600; cursor: pointer; font-family: var(--font);
    }
    #password-submit-btn:hover { background: var(--brand-dark); }
    #cancel-admin {
      font-size: 13px; color: var(--gray-400);
      text-align: center; text-decoration: none; display: block;
    }
    #cancel-admin:hover { color: var(--gray-500); }

    /* Settings panel */
    #settings-screen {
      position: fixed; inset: 0;
      display: flex; align-items: center; justify-content: center;
    }
    #settings-screen[hidden] { display: none; }
    #settings-panel {
      background: var(--white); border-radius: var(--radius);
      width: 560px; max-width: calc(100vw - 32px);
      max-height: calc(100vh - 48px);
      display: flex; flex-direction: column;
      box-shadow: var(--shadow); overflow: hidden;
    }
    #settings-header {
      padding: 20px 24px; border-bottom: 1px solid var(--gray-200);
      display: flex; align-items: center; justify-content: space-between;
      flex-shrink: 0;
    }
    #settings-header h2 { font-size: 18px; font-weight: 700; }
    #settings-close-btn {
      background: none; border: none; font-size: 18px;
      cursor: pointer; color: var(--gray-500); padding: 4px;
    }
    #settings-close-btn:hover { color: var(--gray-900); }
    #settings-form {
      overflow-y: auto; padding: 24px;
      display: flex; flex-direction: column; gap: 28px;
    }
    .settings-section h3 {
      font-size: 13px; font-weight: 600; color: var(--gray-500);
      text-transform: uppercase; letter-spacing: 0.06em; margin-bottom: 12px;
    }
    .settings-section label {
      display: flex; flex-direction: column; gap: 6px;
      font-size: 14px; font-weight: 500; color: var(--gray-700);
      margin-bottom: 10px;
    }
    .settings-section label:last-of-type { margin-bottom: 0; }
    .settings-section input[type="text"],
    .settings-section input[type="tel"],
    .settings-section input[type="url"],
    .settings-section input[type="password"],
    .settings-section textarea {
      width: 100%; padding: 9px 13px;
      border: 1px solid var(--gray-200); border-radius: 8px;
      font-size: 14px; font-family: var(--font); outline: none; resize: vertical;
    }
    .settings-section input:focus,
    .settings-section textarea:focus { border-color: var(--brand); }
    .settings-section > button {
      padding: 8px 16px; background: var(--gray-100);
      border: 1px solid var(--gray-200); border-radius: 8px;
      font-size: 14px; font-family: var(--font); cursor: pointer; color: var(--gray-700);
    }
    .settings-section > button:hover { background: var(--gray-200); }
    input[type="color"] {
      width: 44px; height: 34px; border: 1px solid var(--gray-200);
      border-radius: 6px; cursor: pointer; padding: 2px; background: none;
    }
    #change-password-link { font-size: 14px; color: var(--brand); text-decoration: none; }
    #change-password-link:hover { text-decoration: underline; }
    #change-password-form input {
      width: 100%; padding: 9px 13px;
      border: 1px solid var(--gray-200); border-radius: 8px;
      font-size: 14px; font-family: var(--font); outline: none;
    }
    #change-password-form input:focus { border-color: var(--brand); }
    #cp-submit-btn {
      padding: 9px 16px; background: var(--gray-100);
      border: 1px solid var(--gray-200); border-radius: 8px;
      font-size: 14px; font-family: var(--font); cursor: pointer;
    }
    #cp-submit-btn:hover { background: var(--gray-200); }

    /* FAQ pairs */
    .faq-pair {
      position: relative; padding: 12px;
      background: var(--gray-50); border-radius: 8px; margin-bottom: 8px;
    }
    .faq-pair input, .faq-pair textarea {
      display: block; width: 100%; padding: 8px 12px; margin-bottom: 6px;
      border: 1px solid var(--gray-200); border-radius: 6px;
      font-size: 14px; font-family: var(--font); outline: none; resize: vertical;
    }
    .faq-pair input:focus, .faq-pair textarea:focus { border-color: var(--brand); }
    .faq-remove-btn {
      position: absolute; top: 8px; right: 8px;
      background: none; border: none; color: var(--gray-400);
      cursor: pointer; font-size: 18px; line-height: 1; padding: 0;
    }
    .faq-remove-btn:hover { color: #EF4444; }
    #add-faq-btn { font-size: 13px; padding: 6px 12px; }

    /* Footer */
    #settings-footer {
      padding: 16px 24px; border-top: 1px solid var(--gray-200);
      display: flex; align-items: center; gap: 16px; flex-shrink: 0;
    }
    #save-settings-btn {
      padding: 11px 24px; background: var(--brand); color: var(--white);
      border: none; border-radius: 8px; font-size: 15px; font-weight: 600;
      cursor: pointer; font-family: var(--font);
    }
    #save-settings-btn:hover { background: var(--brand-dark); }
    #save-toast { font-size: 14px; color: #059669; font-weight: 500; }
    #save-toast[hidden] { display: none; }
```

- [ ] **Step 3: Verify in browser**

Reload and click the "Admin" link at the bottom of the chat panel (you need to open the panel first by clicking the bubble). You should see:
- A dark overlay covering the screen
- A clean white card: "Admin", "Ange ditt lösenord", password input, "Logga in" button, "Avbryt" link
- Nothing happens when you click buttons yet (no JS wired)

- [ ] **Step 4: Commit**

```bash
git add receptionist.html
git commit -m "feat: admin overlay HTML and CSS — password card and settings form"
```

---

## Task 7: Password authentication

Wire up the admin link, first-run password creation, and login using SHA-256 via the Web Crypto API.

**Files:**
- Modify: `receptionist.html`

- [ ] **Step 1: Add auth functions and event listeners**

Add to `<script>` after the config section:

```javascript
    // ── Auth ─────────────────────────────────────────────────────────────────
    async function hashPassword(pw) {
      const buf = await crypto.subtle.digest('SHA-256', new TextEncoder().encode(pw));
      return Array.from(new Uint8Array(buf)).map(b => b.toString(16).padStart(2,'0')).join('');
    }

    async function checkPassword(pw) {
      return (await hashPassword(pw)) === config.passwordHash;
    }

    const adminOverlay    = document.getElementById('admin-overlay');
    const passwordScreen  = document.getElementById('password-screen');
    const settingsScreen  = document.getElementById('settings-screen');
    const passwordInput   = document.getElementById('password-input');
    const passwordError   = document.getElementById('password-error');
    const passwordTitle   = document.getElementById('password-title');
    const passwordDesc    = document.getElementById('password-desc');
    const submitBtn       = document.getElementById('password-submit-btn');

    let isCreatingPassword = false;
    let pendingNewPassword = null;

    function openAdminOverlay() {
      adminOverlay.hidden  = false;
      passwordScreen.hidden = false;
      settingsScreen.hidden = true;
      passwordInput.value  = '';
      passwordError.hidden = true;

      if (!config.passwordHash) {
        isCreatingPassword = true;
        pendingNewPassword = null;
        passwordTitle.textContent = 'Välkommen!';
        passwordDesc.textContent  = 'Välj ett lösenord för adminsidan.';
        submitBtn.textContent     = 'Skapa lösenord';
      } else {
        isCreatingPassword = false;
        passwordTitle.textContent = 'Admin';
        passwordDesc.textContent  = 'Ange ditt lösenord';
        submitBtn.textContent     = 'Logga in';
      }
      passwordInput.focus();
    }

    function closeAdminOverlay() {
      adminOverlay.hidden = true;
    }

    document.getElementById('admin-link').addEventListener('click', e => {
      e.preventDefault();
      openAdminOverlay();
    });
    document.getElementById('cancel-admin').addEventListener('click', e => {
      e.preventDefault();
      closeAdminOverlay();
    });
    document.getElementById('settings-close-btn').addEventListener('click', closeAdminOverlay);

    async function handlePasswordSubmit() {
      const value = passwordInput.value.trim();
      if (!value) return;

      if (isCreatingPassword) {
        if (!pendingNewPassword) {
          pendingNewPassword = value;
          passwordDesc.textContent = 'Bekräfta ditt lösenord.';
          passwordInput.value = '';
          return;
        }
        if (value !== pendingNewPassword) {
          passwordError.textContent = 'Lösenorden matchar inte. Börja om.';
          passwordError.hidden = false;
          passwordInput.value = '';
          pendingNewPassword  = null;
          passwordDesc.textContent = 'Välj ett lösenord för adminsidan.';
          return;
        }
        config.passwordHash = await hashPassword(pendingNewPassword);
        saveConfig();
        showSettingsScreen();
      } else {
        if (await checkPassword(value)) {
          showSettingsScreen();
        } else {
          passwordError.textContent = 'Fel lösenord. Försök igen.';
          passwordError.hidden = false;
          passwordInput.value  = '';
          passwordInput.focus();
        }
      }
    }

    submitBtn.addEventListener('click', handlePasswordSubmit);
    passwordInput.addEventListener('keydown', e => { if (e.key === 'Enter') handlePasswordSubmit(); });

    function showSettingsScreen() {
      passwordScreen.hidden = true;
      settingsScreen.hidden = false;
      populateSettingsForm();
    }
```

- [ ] **Step 2: Add a stub for `populateSettingsForm`** (will be filled in Task 8)

```javascript
    function populateSettingsForm() { /* wired in Task 8 */ }
```

- [ ] **Step 3: Verify in browser**

Open the chat panel, click "Admin". Test:
- **First run** (no password set): title is "Välkommen!", button says "Skapa lösenord"
  - Enter "test123" → "Bekräfta ditt lösenord."
  - Enter "test123" again → settings panel opens (empty for now)
- Reload, click Admin → title "Admin", button "Logga in"
  - Wrong password → "Fel lösenord." error, input clears
  - Correct password → settings panel opens
- Click ✕ in settings → overlay closes

- [ ] **Step 4: Commit**

```bash
git add receptionist.html
git commit -m "feat: SHA-256 password auth — first-run setup and login flow"
```

---

## Task 8: Admin settings form — populate, save, colour picker, FAQ, embed code, password change, API test

**Files:**
- Modify: `receptionist.html`

- [ ] **Step 1: Replace `populateSettingsForm` stub with the real implementation**

Replace `function populateSettingsForm() { /* wired in Task 8 */ }` with:

```javascript
    // ── Settings Form ────────────────────────────────────────────────────────
    function escapeHtml(str) {
      return (str || '').replace(/&/g,'&amp;').replace(/</g,'&lt;')
                        .replace(/>/g,'&gt;').replace(/"/g,'&quot;');
    }

    function populateSettingsForm() {
      document.getElementById('s-businessName').value = config.businessName || '';
      document.getElementById('s-tagline').value      = config.tagline      || '';
      document.getElementById('s-phone').value        = config.phone        || '';
      document.getElementById('s-hours').value        = config.hours        || '';
      document.getElementById('s-services').value     = config.services     || '';
      document.getElementById('s-bookingUrl').value   = config.bookingUrl   || '';
      document.getElementById('s-apiKey').value       = config.apiKey       || '';
      document.getElementById('s-brandColor').value   = config.brandColor   || '#4F46E5';
      document.getElementById('color-preview').style.background = config.brandColor || '#4F46E5';
      renderFaqList();
      updateEmbedSection();
    }

    function renderFaqList() {
      const container = document.getElementById('faq-list');
      container.innerHTML = '';
      const faqs = (config.faqs && config.faqs.length) ? config.faqs : [{ q: '', a: '' }];
      faqs.forEach((faq, i) => {
        const div = document.createElement('div');
        div.className = 'faq-pair';
        div.innerHTML = `
          <input type="text" placeholder="Fråga" value="${escapeHtml(faq.q)}"
                 data-faq="${i}" data-field="q" />
          <textarea rows="2" placeholder="Svar"
                    data-faq="${i}" data-field="a">${escapeHtml(faq.a)}</textarea>
          <button class="faq-remove-btn" data-faq="${i}" title="Ta bort">×</button>`;
        container.appendChild(div);
      });
    }

    function getFaqsFromForm() {
      return Array.from(document.querySelectorAll('.faq-pair')).map(pair => ({
        q: pair.querySelector('[data-field="q"]').value.trim(),
        a: pair.querySelector('[data-field="a"]').value.trim()
      })).filter(f => f.q || f.a);
    }

    document.getElementById('faq-list').addEventListener('click', e => {
      if (!e.target.classList.contains('faq-remove-btn')) return;
      const i = parseInt(e.target.dataset.faq);
      config.faqs.splice(i, 1);
      if (!config.faqs.length) config.faqs = [{ q: '', a: '' }];
      renderFaqList();
    });

    document.getElementById('add-faq-btn').addEventListener('click', () => {
      config.faqs = getFaqsFromForm();
      if (config.faqs.length >= 5) return;
      config.faqs.push({ q: '', a: '' });
      renderFaqList();
    });

    // Live colour preview
    document.getElementById('s-brandColor').addEventListener('input', e => {
      document.getElementById('color-preview').style.background = e.target.value;
    });

    // Widget mode toggle → show/hide embed code section
    document.querySelectorAll('[name="widgetMode"]').forEach(r =>
      r.addEventListener('change', updateEmbedSection)
    );

    function updateEmbedSection() {
      const mode = document.querySelector('[name="widgetMode"]:checked')?.value || 'floating';
      const section = document.getElementById('embed-code-section');
      section.hidden = mode !== 'embedded';
      if (mode === 'embedded') {
        const base = window.location.href.split('?')[0];
        document.getElementById('embed-code-area').value =
          `<iframe src="${base}?mode=embed"\n        width="100%" height="600" frameborder="0"\n        style="border:none;border-radius:12px;"></iframe>`;
      }
    }

    document.getElementById('copy-embed-btn').addEventListener('click', () => {
      const area = document.getElementById('embed-code-area');
      area.select();
      navigator.clipboard.writeText(area.value).catch(() => document.execCommand('copy'));
      const btn = document.getElementById('copy-embed-btn');
      btn.textContent = '✓ Kopierad!';
      setTimeout(() => { btn.textContent = 'Kopiera kod'; }, 2000);
    });

    // Save settings
    document.getElementById('save-settings-btn').addEventListener('click', () => {
      config.businessName = document.getElementById('s-businessName').value.trim();
      config.tagline      = document.getElementById('s-tagline').value.trim();
      config.phone        = document.getElementById('s-phone').value.trim();
      config.hours        = document.getElementById('s-hours').value.trim();
      config.services     = document.getElementById('s-services').value.trim();
      config.faqs         = getFaqsFromForm();
      config.bookingUrl   = document.getElementById('s-bookingUrl').value.trim();
      config.apiKey       = document.getElementById('s-apiKey').value.trim();
      config.brandColor   = document.getElementById('s-brandColor').value;
      saveConfig();
      applyConfig();
      const toast = document.getElementById('save-toast');
      toast.hidden = false;
      setTimeout(() => { toast.hidden = true; }, 3000);
    });

    // Password change
    document.getElementById('change-password-link').addEventListener('click', e => {
      e.preventDefault();
      const form = document.getElementById('change-password-form');
      form.hidden = !form.hidden;
    });

    document.getElementById('cp-submit-btn').addEventListener('click', async () => {
      const current  = document.getElementById('cp-current').value;
      const newPw    = document.getElementById('cp-new').value;
      const confirm  = document.getElementById('cp-confirm').value;
      const errorEl  = document.getElementById('cp-error');
      errorEl.hidden = true;

      if (!await checkPassword(current)) {
        errorEl.textContent = 'Fel nuvarande lösenord.'; errorEl.hidden = false; return;
      }
      if (newPw.length < 6) {
        errorEl.textContent = 'Nytt lösenord måste vara minst 6 tecken.'; errorEl.hidden = false; return;
      }
      if (newPw !== confirm) {
        errorEl.textContent = 'Lösenorden matchar inte.'; errorEl.hidden = false; return;
      }
      config.passwordHash = await hashPassword(newPw);
      saveConfig();
      document.getElementById('change-password-form').hidden = true;
      ['cp-current','cp-new','cp-confirm'].forEach(id => { document.getElementById(id).value = ''; });
      alert('Lösenordet har uppdaterats!');
    });

    // API connection test
    document.getElementById('test-api-btn').addEventListener('click', async () => {
      const key    = document.getElementById('s-apiKey').value.trim();
      const result = document.getElementById('api-test-result');
      const btn    = document.getElementById('test-api-btn');
      if (!key) {
        result.textContent = '⚠ Ange en API-nyckel först.';
        result.style.color = '#B45309'; result.hidden = false; return;
      }
      btn.textContent = 'Testar...';
      try {
        const res = await fetch('https://api.anthropic.com/v1/messages', {
          method: 'POST',
          headers: {
            'x-api-key': key,
            'anthropic-version': '2023-06-01',
            'content-type': 'application/json',
            'anthropic-dangerous-allow-browser': 'true'
          },
          body: JSON.stringify({
            model: 'claude-sonnet-4-6',
            max_tokens: 10,
            messages: [{ role: 'user', content: 'Hi' }]
          })
        });
        if (res.ok) {
          result.textContent = '✓ Anslutning OK!'; result.style.color = '#059669';
        } else {
          const err = await res.json();
          result.textContent = `✗ ${err.error?.message || 'Fel ' + res.status}`;
          result.style.color = '#B91C1C';
        }
      } catch {
        result.textContent = '✗ Kunde inte ansluta.'; result.style.color = '#B91C1C';
      }
      result.hidden = false;
      btn.textContent = 'Testa anslutning';
    });
```

- [ ] **Step 2: Verify in browser**

Log in to admin and test each feature:
- Fill in business name "Salong Vera" → Save → header updates to "Salong Vera", toast appears
- Change colour to green (`#059669`) → chip updates in real time → Save → bubble goes green
- Add two FAQ entries → remove one → only one remains
- Select "Inbäddad panel" → embed code textarea appears with `?mode=embed` URL
- Click "Kopiera kod" → button shows "✓ Kopierad!" for 2 seconds
- "Ändra lösenord" → form appears → change password → confirm it works on next login

- [ ] **Step 3: Commit**

```bash
git add receptionist.html
git commit -m "feat: admin settings form — save, FAQ, colour picker, embed code, password change, API test"
```

---

## Task 9: Chat messaging + Claude API with streaming

Build the message display helpers, system prompt, and the streaming `handleSend` function.

**Files:**
- Modify: `receptionist.html`

- [ ] **Step 1: Add message display helpers and input wiring**

Add to `<script>` after the config section (before admin auth):

```javascript
    // ── Chat ─────────────────────────────────────────────────────────────────
    const messagesArea  = document.getElementById('messages-area');
    const messageInput  = document.getElementById('message-input');
    const sendBtn       = document.getElementById('send-btn');
    let conversationHistory = [];

    function appendMessage(text, role) {
      const div = document.createElement('div');
      div.className = `msg msg-${role}`;
      div.textContent = text;
      messagesArea.appendChild(div);
      messagesArea.scrollTop = messagesArea.scrollHeight;
      return div;
    }

    function appendError(text) {
      const div = document.createElement('div');
      div.className = 'msg msg-error';
      div.textContent = text;
      messagesArea.appendChild(div);
      messagesArea.scrollTop = messagesArea.scrollHeight;
    }

    function showTypingIndicator() {
      const div = document.createElement('div');
      div.className = 'msg msg-typing';
      div.id = 'typing-indicator';
      div.innerHTML = '<div class="typing-dots"><span></span><span></span><span></span></div>';
      messagesArea.appendChild(div);
      messagesArea.scrollTop = messagesArea.scrollHeight;
    }

    function removeTypingIndicator() {
      document.getElementById('typing-indicator')?.remove();
    }

    messageInput.addEventListener('input', () => {
      sendBtn.disabled = messageInput.value.trim().length === 0;
    });
    messageInput.addEventListener('keydown', e => {
      if (e.key === 'Enter' && !e.shiftKey && !sendBtn.disabled) {
        e.preventDefault();
        handleSend();
      }
    });
    sendBtn.addEventListener('click', handleSend);
```

- [ ] **Step 2: Add system prompt builder**

Add to `<script>` immediately after the chat helpers:

```javascript
    function buildSystemPrompt() {
      const faqText = (config.faqs || [])
        .filter(f => f.q && f.a)
        .map(f => `Q: ${f.q}\nA: ${f.a}`)
        .join('\n\n');

      return `Du är AI-receptionisten för ${config.businessName || 'detta företag'}.

VIKTIG INSTRUKTION OM SPRÅK: Svara ALLTID på samma språk som besökaren skriver på. Om de skriver på svenska → svar på svenska. Om de skriver på engelska → svar på engelska. Blanda aldrig språk i ett svar.

Företagsinformation:
${config.businessName ? `Namn: ${config.businessName}` : ''}
${config.tagline      ? `Tagline: ${config.tagline}`   : ''}
${config.phone        ? `Telefon: ${config.phone}`     : ''}

Öppettider:
${config.hours || 'Inte angivet'}

Tjänster och priser:
${config.services || 'Inte angivet'}

${faqText ? `Vanliga frågor:\n${faqText}` : ''}
${config.bookingUrl ? `\nBokning: Hänvisa till ${config.bookingUrl} när besökaren vill boka.` : ''}

Regler:
- Svara vänligt, professionellt och kortfattat (1–3 meningar)
- Svara BARA baserat på informationen ovan — hitta aldrig på detaljer
- Om du inte vet svaret, säg det ärligt${config.phone ? ` och erbjud besökaren att ringa ${config.phone}` : ''}`;
    }
```

- [ ] **Step 3: Add streaming `handleSend` function**

Add to `<script>` immediately after `buildSystemPrompt`:

```javascript
    async function handleSend() {
      const text = messageInput.value.trim().slice(0, 1000);
      if (!text) return;

      if (!config.apiKey) {
        appendError('Den här receptionisten är inte konfigurerad ännu. / This receptionist is not yet configured.');
        return;
      }

      messageInput.value = '';
      sendBtn.disabled   = true;
      appendMessage(text, 'user');
      conversationHistory.push({ role: 'user', content: text });
      showTypingIndicator();

      let aiEl = null;
      let fullResponse = '';

      try {
        const response = await fetch('https://api.anthropic.com/v1/messages', {
          method: 'POST',
          headers: {
            'x-api-key': config.apiKey,
            'anthropic-version': '2023-06-01',
            'content-type': 'application/json',
            'anthropic-dangerous-allow-browser': 'true'
          },
          body: JSON.stringify({
            model: 'claude-sonnet-4-6',
            max_tokens: 512,
            system: buildSystemPrompt(),
            messages: conversationHistory,
            stream: true
          })
        });

        if (!response.ok) throw new Error(`API ${response.status}`);

        removeTypingIndicator();
        aiEl = appendMessage('', 'ai');

        const reader  = response.body.getReader();
        const decoder = new TextDecoder();

        while (true) {
          const { done, value } = await reader.read();
          if (done) break;
          const lines = decoder.decode(value, { stream: true }).split('\n');
          for (const line of lines) {
            if (!line.startsWith('data: ')) continue;
            const raw = line.slice(6).trim();
            if (!raw || raw === '[DONE]') continue;
            try {
              const evt = JSON.parse(raw);
              if (evt.type === 'content_block_delta' && evt.delta?.type === 'text_delta') {
                fullResponse += evt.delta.text;
                aiEl.textContent = fullResponse;
                messagesArea.scrollTop = messagesArea.scrollHeight;
              }
            } catch { /* skip malformed SSE lines */ }
          }
        }

        conversationHistory.push({ role: 'assistant', content: fullResponse });

      } catch {
        removeTypingIndicator();
        const phone = config.phone ? ` Ring oss på ${config.phone}.` : '';
        appendError(`Ursäkta, jag har tekniska problem just nu.${phone}`);
        conversationHistory.pop();
      }
    }
```

- [ ] **Step 4: Verify in browser**

First, go to Admin → paste your Claude API key → Save. Then:
- Type "Hej!" → bouncing dots → response streams in word-by-word
- Type "Hello, what are your opening hours?" → Claude responds **in English**
- Type "Vad kostar en klippning?" → Claude responds **in Swedish**
- Try a question outside the config → Claude honestly says it doesn't know
- Wrong API key → error message appears in red

- [ ] **Step 5: Commit**

```bash
git add receptionist.html
git commit -m "feat: Claude API integration with streaming SSE responses"
```

---

## Task 10: Welcome message on first open

Show a Swedish greeting the first time the chat panel is opened.

**Files:**
- Modify: `receptionist.html`

- [ ] **Step 1: Add `showWelcomeMessage` (use `function` declaration so it hoists)**

Add to `<script>` after the bubble toggle section and before the chat helpers:

```javascript
    // ── Welcome message ──────────────────────────────────────────────────────
    let welcomeShown = false;

    function showWelcomeMessage() {
      if (welcomeShown) return;
      welcomeShown = true;
      const name = config.businessName ? ` på ${config.businessName}` : '';
      appendMessage(`Hej! Välkommen${name}. Hur kan jag hjälpa dig idag? 😊`, 'ai');
    }
```

- [ ] **Step 2: Call it from `openChat`**

Replace the existing `openChat` function with:

```javascript
    function openChat() {
      panel.classList.remove('hidden');
      bubbleBadge.hidden = true;
      clearTimeout(badgeTimer);
      showWelcomeMessage();
    }
```

- [ ] **Step 3: Call it for embed mode**

Replace the existing embed mode `if` block with:

```javascript
    if (isEmbedMode) {
      document.body.classList.add('embed-mode');
      panel.classList.remove('hidden');
      setTimeout(showWelcomeMessage, 300);
    }
```

- [ ] **Step 4: Verify in browser**

Reload, click bubble → "Hej! Välkommen på [Business Name]. Hur kan jag hjälpa dig idag? 😊" appears.
Close and reopen the chat → welcome message does **not** appear again.
Open `?mode=embed` → welcome appears automatically after 300ms.

- [ ] **Step 5: Commit**

```bash
git add receptionist.html
git commit -m "feat: Swedish welcome message on first chat open"
```

---

## Task 11: Final polish, file size check, and Vercel deployment

**Files:**
- Modify: `receptionist.html`

- [ ] **Step 1: Add `<meta>` tags**

In `<head>`, add after the existing `<meta>` tags:

```html
  <meta name="description" content="AI Receptionist powered by Claude" />
  <meta name="robots" content="noindex" />
```

`noindex` prevents search engines from listing the widget URL in search results.

- [ ] **Step 2: Check file size**

```bash
ls -lh c:/Users/simon/marketingskills/ai-receptionist/receptionist.html
```

Expected output: under 50KB. If over, review the CSS for duplicate rules.

- [ ] **Step 3: Full end-to-end test in a private/incognito window**

Open a private browser window (Ctrl+Shift+N) so localStorage is empty. Work through this checklist:

| # | Test | Expected |
|---|---|---|
| 1 | Open page | Bubble visible bottom-right, no console errors |
| 2 | Wait 4 seconds | Red "1" badge pulses on bubble |
| 3 | Click bubble | Panel opens, badge gone, Swedish welcome message |
| 4 | Click ✕ | Panel closes |
| 5 | Click bubble again | Panel reopens, NO second welcome message |
| 6 | Click Admin | "Välkommen!" first-run screen |
| 7 | Create password | Settings panel opens |
| 8 | Fill all fields + paste API key + pick colour + Save | Toast, header updates |
| 9 | Reload → click bubble | Header shows business name + brand colour |
| 10 | Type "Hej!" | Typing dots → streamed Swedish response |
| 11 | Type "Hello!" | Claude responds in English |
| 12 | Ask something not in config | Honest "I don't know" response |
| 13 | Open `?mode=embed` | Full-page panel, no bubble, no ✕, welcome auto-shows |
| 14 | Admin → Inbäddad panel | Embed code section appears |
| 15 | Copy embed code | Button → "✓ Kopierad!" |
| 16 | DevTools 375px width | Chat panel goes full screen |
| 17 | Admin → Change password | New password works on next login |

- [ ] **Step 4: Final commit**

```bash
git add receptionist.html
git commit -m "feat: production-ready AI receptionist v1.0"
```

- [ ] **Step 5: Deploy to Vercel**

1. Go to [vercel.com](https://vercel.com) and create a free account
2. Click **Add New → Project**
3. Choose **"Deploy without a framework"** and drag-and-drop `receptionist.html`
4. Vercel gives you a live URL like `https://your-project.vercel.app`
5. Visit `your-project.vercel.app/receptionist.html`, click Admin, set your password, fill in settings
6. Share that URL with your first test business!
