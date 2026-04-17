# AI Receptionist — Design Spec
**Date:** 2026-04-17
**Author:** Simon (solo entrepreneur, Sweden)
**Status:** Approved

---

## 1. Product Overview

A single-file AI receptionist widget that small Swedish businesses (restaurants, salons, gyms, dentists) can embed on their website. It answers visitor questions in Swedish or English, provides business information, and directs visitors to book appointments. Business owners configure it through a built-in password-protected admin panel — no code editing required.

**Target customer:** Non-technical Swedish small business owners.
**Distribution:** Business owner receives one HTML file, deploys to Vercel for free.

---

## 2. Architecture

### Technology
- **Single file:** `receptionist.html` — vanilla HTML, CSS, JavaScript. No frameworks, no build tools.
- **Storage:** Browser `localStorage` — all config and the admin password hash are stored client-side.
- **AI:** Claude API (`claude-sonnet-4-6`) called directly from the browser via `fetch()`.
- **Hosting:** Vercel free tier (static file). No backend server. No database.
- **File size target:** Under 50KB. No external fonts, no CDN dependencies. Only external call is to `api.anthropic.com`.

### API Key Ownership
Each business provides their own Claude API key, pasted into the admin panel. The key is stored in `localStorage`. The business pays Anthropic directly for their own usage. Simon (the developer/seller) has no API costs.

### Two Rendering Modes
The page detects its rendering mode via the `?mode=embed` URL parameter:
- **Default (no param):** Floating bubble mode.
- **`?mode=embed`:** Embedded panel mode — renders as a block element that fills its container.

This allows the business owner to use floating mode on their live site and share an embed snippet from the same deployed URL.

---

## 3. Chat Interface

### Visitor Experience
- Clean chat panel: branded header, scrollable message area, text input, send button.
- On load: AI sends a welcome message in Swedish — *"Hej! Hur kan jag hjälpa dig idag?"*
- Language auto-detection: Claude responds in whatever language the visitor writes — Swedish or English. No toggle, no manual selection.
- Streaming responses: Claude's reply appears word-by-word as it is generated, giving a fast, premium feel.
- Session memory only: conversation history is held in a JS array for the current page session. Refreshing the page starts a new conversation. Nothing is persisted to localStorage.

### System Prompt
Injected invisibly with every API call. Contains:
- Business name and role ("You are the AI receptionist for [Business Name]")
- Opening hours, services/prices, FAQs
- Booking link instruction ("When a visitor wants to book, share this link: [URL]")
- Language instruction ("Respond in the same language the visitor uses — Swedish or English only")
- Tone instruction ("Be friendly, professional, and concise")
- Honesty instruction ("Only answer using the information provided. Never invent details.")

### Edge Cases
| Situation | Behaviour |
|---|---|
| API key not configured | Chat shows: *"Den här receptionisten är inte konfigurerad ännu."* / *"This receptionist is not yet configured."* |
| Claude API error | Chat shows: *"Ursäkta, jag har tekniska problem just nu. Ring oss gärna direkt."* + phone number from config if set |
| Empty message sent | Send button disabled, no API call made |
| Visitor sends very long message | Truncated to 1000 characters before sending to API |

---

## 4. Admin Panel

### Access
- A small, discreet "Admin" link at the bottom of the chat widget. Styled to be unobtrusive (small grey text) — visitors won't notice it.
- Clicking it opens a password overlay on top of the chat widget.
- **First visit:** prompts to create a password (entered twice to confirm).
- **Subsequent visits:** prompts to enter the password.
- Password is hashed with SHA-256 (via Web Crypto API) before storing in `localStorage`. Never stored in plain text.

### Settings Form

**Business**
- Business name (text, required)
- Tagline (text, optional — shown in chat header)
- Phone number (text, optional — used in error messages)

**Opening Hours**
- Free-text area (e.g. "Mån–Fre 09:00–18:00, Lör 10:00–14:00")

**Services**
- Free-text area for services and prices (e.g. "Klippning 350kr, Färgning 850kr")

**FAQs**
- Up to 5 FAQ pairs: Question field + Answer field
- Add/remove FAQ pairs dynamically

**Booking**
- Booking link URL (text, e.g. their Bokadirekt or Timma page)

**API**
- Claude API key (password-masked input)
- "Test connection" button — sends a minimal test message to the API and shows success/failure

**Appearance**
- Primary brand colour (colour picker input)
  - Applied to: chat header background, send button, visitor message bubbles
- Widget mode selector: Floating Bubble / Embedded Panel
  - This is a UI choice that reveals or hides the Embed Code section below — it does NOT change the live page behaviour
  - The actual rendering mode is always determined by the URL: no param = floating, `?mode=embed` = embedded
  - Both modes are always available from the same deployed URL simultaneously

**Embed Code** *(shown only when Embedded mode is selected in the toggle)*
- Read-only text area with the iframe snippet (pre-filled with their Vercel URL + `?mode=embed`)
- "Copy" button

### Save Behaviour
- Single "Save Settings" button at bottom of form
- Saves all fields to `localStorage` as a single JSON object
- Changes apply immediately — no page reload required
- Success toast: *"Inställningar sparade!"*

### Password Change
- "Ändra lösenord" link at bottom of admin panel
- Opens an inline form: current password + new password + confirm

---

## 5. Widget Modes

### Floating Bubble Mode
- Fixed position, bottom-right corner of the viewport
- Circular button (56px diameter) with a chat icon, coloured with the primary brand colour
- Clicking opens a chat panel (400px wide, 550px tall) that animates up from the button
- X button in the panel header closes it
- **Notification badge nudge:** After 4 seconds on the page, a pulsing "1" badge appears on the bubble to draw the visitor's attention. Disappears once the chat is opened.
- On mobile (viewport < 480px): panel expands to full screen

### Embedded Panel Mode
- Chat panel renders as a normal block element, 100% width of its container, 600px tall
- No floating button
- Activated via `?mode=embed` URL parameter
- Business owner copies this snippet from the admin panel:

```html
<iframe src="https://your-site.vercel.app/receptionist.html?mode=embed"
        width="100%" height="600" frameborder="0"
        style="border: none; border-radius: 12px;"></iframe>
```

---

## 6. Deployment (Business Owner Steps)

1. Download `receptionist.html` from Simon
2. Create a free account at vercel.com
3. Drag-and-drop the file into Vercel to deploy — get a live URL in under a minute
4. Visit the live URL, click "Admin" at the bottom, set a password
5. Fill in business details, paste Claude API key, choose brand colour and widget mode
6. Copy the embed code (if using embedded mode) and paste into their website builder

---

## 7. Visual Design Principles

- Clean, minimal, professional — must look credible to a dentist or salon owner
- One primary brand colour (business-provided) + white + light grey
- Rounded corners throughout (12px radius)
- Clear font: system font stack (`-apple-system, BlinkMacSystemFont, 'Segoe UI', sans-serif`)
- Smooth transitions (200ms ease) on open/close and message arrival
- No stock photos, no illustrations — pure UI

---

## 8. Out of Scope (v1)

- Appointment booking (only linking to external booking system)
- Analytics or conversation history for the business owner
- Multi-language admin panel (admin panel is in Swedish only)
- Multiple languages beyond Swedish and English
- Voice input
- Image upload
- Export/import config (localStorage only for now)
- Custom domain for the deployed widget
