# Requirements Traceability Matrix — Si-Cehat PlayLab MVP

> **Source documents:** `00-MVP-Overview.md`, `01-Game-Requirements.md`, `02-Technical-Architecture.md`, `03-API-Database-Spec.md`, `04-Research-Requirements.md`, `05-Security-Privacy-Testing.md`.  
> **Date:** October 2026  
> **Status:** Phase 0 Baseline

---

## 1. Product Requirements

| Req ID | Summary | Source Doc & Section | Proposed Implementation Location | Acceptance Test | Status |
|---|---|---|---|---|---|
| **PR-01** | MVP game is "Piring Sehat Nimbo" (balanced meal & food variety). | `00-MVP-Overview.md` §1, `01-Game-Requirements.md` §1 | `si-cehat-game-web/src/games/healthy-plate/` | Playable 3–5 min flow introducing balanced meal concept. | Confirmed |
| **PR-02** | Target audience: children aged 6–12 with parent/guardian supervision context. | `00-MVP-Overview.md` §3 | `si-cehat-game-web/src/` (UI/copy/touch sizes) | Touch targets ≥48px, readable text, simple Indonesian copy. | Assumption (exact age sub-group pending) |
| **PR-03** | Core game screens: Intro/Instructions, Gameplay Plate, Knowledge Check (optional/versioned), Results, Recoverable Error. | `01-Game-Requirements.md` §3 | `si-cehat-game-web/src/games/healthy-plate/screens/` | Child can navigate from instructions to plate to results without UI dead-ends. | Confirmed |
| **PR-04** | Touch-friendly drag-and-drop with tap fallback for accessibility. | `01-Game-Requirements.md` §3.3, §6 | `si-cehat-game-web/src/games/healthy-plate/components/PlateArea.tsx` | Cards draggable into plate slots; tapping card then slot also works on low-end touch devices. | Confirmed |
| **PR-05** | Educational feedback is constructive, non-shaming, neutral, without body-image language. | `01-Game-Requirements.md` §5 | `si-cehat-game-web/src/content/healthy-plate/v1.json` | Subject matter expert (SME) content audit confirms neutral encouraging phrasing. | Blocked on SME review (using placeholder v1) |
| **PR-06** | Separate gameplay score from knowledge assessment score. | `00-MVP-Overview.md` §2, `01-Game-Requirements.md` §4 | Game state, Backend `GameResult` model | Final result payload and UI display two distinct fields: `gameplayScore` and `knowledgeScore`. | Confirmed |
| **PR-07** | Results screen displays completion status, child-friendly takeaway, reward (if enabled), and explicit return-to-app action. | `01-Game-Requirements.md` §3.5 | `si-cehat-game-web/src/games/healthy-plate/screens/ResultScreen.tsx` | Return button fires bridge message `EXIT_GAME`; canonical server result is reflected. | Confirmed |

---

## 2. Technical & Architecture Requirements

| Req ID | Summary | Source Doc & Section | Proposed Implementation Location | Acceptance Test | Status |
|---|---|---|---|---|---|
| **TR-01** | Game hosted as standalone static web app (`si-cehat-game-web`). | `02-Technical-Architecture.md` §3, §4 | Standalone Vite + React + TypeScript repo | Standalone `bun run build` produces static SPA artifacts deployable to any origin/CDN. | Confirmed |
| **TR-02** | Flutter host integrates WebView using strict allowlisted origin. | `02-Technical-Architecture.md` §4, `05-Security-Privacy-Testing.md` §3 | `Si-Cehat-mobile/lib/screens/game/game_webview_screen.dart` | WebView refuses navigation outside configured game base URL. | Confirmed |
| **TR-03** | Validated bidirectional JS bridge contract (`GameToAppMessage`). | `02-Technical-Architecture.md` §6 | Web bridge client & Flutter `JavaScriptChannel` | Messages outside schema (`GAME_READY`, `GAME_COMPLETED`, `EXIT_GAME`) are discarded and logged safely. | Confirmed |
| **TR-04** | Backend creates authorized game session bound to authenticated user and active child profile. | `03-API-Database-Spec.md` §3 | `Si-Cehat/src/server/routes/game.routes.ts` (`POST /api/game-sessions`) | Session creation fails if user is unauthenticated or childId does not belong to guardian. | Confirmed |
| **TR-05** | Short-lived single-use bootstrap mechanism without long-lived tokens in URL. | `02-Technical-Architecture.md` §7, `05-Security-Privacy-Testing.md` §3 | Backend session route & game bootstrap handshake | URL contains only ephemeral bootstrap code (`?bootstrap=...`); game exchanges it for session token. | Confirmed |
| **TR-06** | Server recomputes or validates scores; client score is never trusted. | `03-API-Database-Spec.md` §3, §5 | Backend `POST /api/game-sessions/:id/complete` | Submitting spoofed client score is ignored; backend recomputes canonical score from validated item placements. | Confirmed |
| **TR-07** | Idempotent session completion; duplicate requests return canonical result without duplicate rewards. | `03-API-Database-Spec.md` §3, §5 | Backend completion handler & DB unique constraint | Calling `/complete` twice with same session ID yields exact same result and no duplicate XP/streak. | Confirmed |
| **TR-08** | Bounded, schema-validated event telemetry (`GameEvent`). | `03-API-Database-Spec.md` §3, §4 | Backend `POST /api/game-sessions/:id/events` | High-frequency mouse movements rejected; only schema-defined discrete events accepted. | Confirmed |
| **TR-09** | PostgreSQL persistence via Drizzle ORM matching repository conventions. | `02-Technical-Architecture.md` §3, Audit | `Si-Cehat/src/server/db/schema.ts` (`gameSessions`, `gameResults`, etc.) | Tables generate cleanly via `bunx drizzle-kit generate` and push to PostgreSQL. | Confirmed |
| **TR-10** | Explicit offline/network error states in web and Flutter host. | `02-Technical-Architecture.md` §8 | Web error boundary & Flutter WebView error handler | Disconnecting network shows retryable dialog without losing completed session token. | Confirmed |

---

## 3. Security & Privacy Requirements

| Req ID | Summary | Source Doc & Section | Proposed Implementation Location | Acceptance Test | Status |
|---|---|---|---|---|---|
| **SR-01** | Child privacy & data minimization: no direct child identifiers in telemetry payloads. | `05-Security-Privacy-Testing.md` §5 | Telemetry schemas & logging middleware | Payloads and server logs contain only pseudonymous UUIDs (`sessionId`, `childId`); no names or PII. | Confirmed |
| **SR-02** | Cross-profile isolation: user A cannot access or finalize user B's game session. | `05-Security-Privacy-Testing.md` §4, §6.3 | Backend session authorization checks | Requesting session data with another guardian's JWT returns 403 Forbidden. | Confirmed |
| **SR-03** | Origin hardening: external URLs blocked or opened in external browser without native bridge. | `05-Security-Privacy-Testing.md` §3 | Flutter WebView `navigationDelegate` | Navigation to unauthorized host is blocked (`NavigationDecision.prevent`). | Confirmed |
| **SR-04** | Secret hygiene: no tokens or secrets in URLs, `localStorage`, or git history. | `05-Security-Privacy-Testing.md` §3, §5 | Web game & Flutter client | `.env.example` has only dummy placeholders; URLs contain no JWT. | Confirmed |
| **SR-05** | Sensitive log redaction: tokens and raw assessment answers redacted from logs. | `05-Security-Privacy-Testing.md` §5 | Backend `appLogger` middleware | Log outputs mask authorization tokens and raw test answers. | Confirmed |

---

## 4. Research & Evaluation Requirements

| Req ID | Summary | Source Doc & Section | Proposed Implementation Location | Acceptance Test | Status |
|---|---|---|---|---|---|
| **RR-01** | Strict version traceability: every session records `gameVersion`, `contentVersion`, `rulesVersion`. | `04-Research-Requirements.md` §6 | `GameSession` & `GameResult` entities | Result export includes exact immutable versions used during play. | Confirmed |
| **RR-02** | Knowledge check module decoupled from gameplay practice. | `04-Research-Requirements.md` §3, §4 | `si-cehat-game-web/src/games/healthy-plate/content/` | Knowledge check items only presented if study instrument is approved; answers not revealed beforehand. | Blocked on instrument approval (stubbed with placeholder schema) |
| **RR-03** | Controlled research dataset export with study-level authorization. | `03-API-Database-Spec.md` §3, `04-Research-Requirements.md` §8 | Backend `GET /api/admin/research/export` | Non-admin/non-researcher receives 403; export contains pseudonymous participant codes and codebook. | Confirmed |
| **RR-04** | Explicit missingness / status recording for incomplete or aborted sessions. | `04-Research-Requirements.md` §7 | `GameSession.status` enum (`abandoned`, `in_progress`, `completed`, `failed`) | Exiting mid-game marks session as `abandoned`; no synthetic score generated. | Confirmed |
| **RR-05** | Formative usability pilot (5–8 participants) before claims of effectiveness. | `04-Research-Requirements.md` §5, §10 | Usability test protocol & checklist | Pilot observations recorded with participant codes; no causal efficacy claimed. | Deferred (post-release gate) |
