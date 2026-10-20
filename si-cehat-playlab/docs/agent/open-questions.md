# Open Questions & Decisions Log — Si-Cehat PlayLab MVP

> **Date:** October 2026  
> **Phase:** Phase 0 Intake

The following items are open product, clinical, research, and technical decisions identified during requirements analysis. They must be resolved with relevant stakeholders before final research participant deployment.

---

## 1. Clinical & Health Content Decisions

### Q1: Nutrition Guideline Reference & Content Approval
- **Context:** The MVP game teaches "Piring Sehat Nimbo" based on basic food variety and balanced meal concepts.
- **Question:** Which authoritative reference should ground the ruleset: *Kemenkes RI "Isi Piringku"* (1/3 makanan pokok, 1/3 sayuran, 1/6 lauk pauk, 1/6 buah-buahan) or a simplified 4-category plate (Karbohidrat, Protein, Sayur, Buah)?
- **Impact:** Determines the slot breakdown on the plate UI and validation rules in `v1.json`.
- **Current Assumption:** We scaffold with the standard Indonesian *Isi Piringku* 4-component model (Karbohidrat, Protein, Sayur, Buah) using clearly labeled placeholder datasets until clinical sign-off.

### Q2: Target Age Group & Cognitive Load
- **Context:** Proposed range is 6–12 years, but literacy and motor skills vary substantially between a 6-year-old (early reader, larger touch targets needed, voice cues beneficial) and a 12-year-old.
- **Question:** Will the initial pilot target early primary (6–8 years) or upper primary (9–12 years)?
- **Impact:** Determines card text length, round complexity, and need for audio narration.
- **Current Assumption:** Mobile layout supports both drag-and-drop and tap-to-place; text is kept under 15 words per instruction.

---

## 2. Research Protocol & Ethics Decisions

### Q3: Research Instrument & Pre/Post-Test Timing
- **Context:** `04-Research-Requirements.md` requires separating gameplay performance from validated knowledge measurement.
- **Question:** Does the study team have an approved validated pre/post knowledge questionnaire? Will T0 (pre-test) happen inside the mobile app before launching the game, or within the web game experience itself?
- **Impact:** Prevents duplicative or confounding assessment screens.
- **Current Assumption:** The web game includes an optional, schema-driven knowledge check boundary that remains deactivated or in placeholder mode until the formal research protocol is delivered.

### Q4: Ethics, Assent, and Participant Identifier Mapping
- **Context:** Collecting child activity data requires parental consent and child assent under institutional ethics oversight.
- **Question:** What is the participant code format (e.g. `P-001`), and will the pseudonym mapping be maintained offline by researchers or stored in a restricted database table?
- **Impact:** Schema definition for researcher data export endpoints.
- **Current Assumption:** The system stores standard platform UUIDs (`childId`) and supports exporting pseudonymous research CSV/JSON with platform identities scrubbed or hashed.

---

## 3. Technical & Infrastructure Decisions

### Q5: Web Game Hosting Origin
- **Context:** WebView hardening requires strict origin allowlisting (e.g., `https://games.sicehat.id` or local dev origin `http://10.0.2.2:5173` / `http://localhost:5173`).
- **Question:** What is the staging and production domain for `si-cehat-game-web`?
- **Impact:** Flutter WebView configuration (`ApiConstants.gameOrigin`) and CORS settings on the backend.
- **Current Assumption:** Configured dynamically via environment variable / `ApiConstants.gameBaseUrl` with fallback to localhost/LAN IP for emulator testing.

### Q6: Offline Gameplay Policy
- **Context:** Flutter app has local SQLite fallback for demo mode, but game sessions require backend integrity validation.
- **Question:** Is full offline gameplay required for Posyandu visits in low-connectivity areas, or is online connectivity acceptable for the MVP pilot?
- **Impact:** Eliminates the complexity of client-side offline cryptographic queuing in the initial MVP.
- **Current Assumption:** MVP strictly requires an active connection for session creation and completion validation, showing friendly recoverable network error states if offline.
