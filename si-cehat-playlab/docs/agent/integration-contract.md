# Integration Contract Specification — Si-Cehat PlayLab

> **Date:** October 2026  
> **Phase:** Phase 1 Architecture & Contracts  
> **Status:** Confirmed Specification

This document defines the formal integration contract between the **Flutter Mobile Host**, the **Standalone Web Game (`si-cehat-game-web`)**, and the **Si-Cehat Backend API**.

---

## 1. JavaScript Bridge Contract

Communication from the Web Game to the Flutter host runs through a named JavaScript channel: `PlayLabBridge`.

### 1.1 Bridge Message Types (`GameToAppMessage`)

```typescript
export type GameToAppMessage =
  | {
      type: "GAME_READY";
      protocolVersion: 1;
    }
  | {
      type: "GAME_COMPLETED";
      sessionId: string;
      scores: {
        gameplayScore: number;
        knowledgeScore: number;
        totalScore: number;
        starsEarned: number;
        xpAwarded: number;
      };
    }
  | {
      type: "EXIT_GAME";
    };
```

### 1.2 Message Semantics & Security Rules

1. **`GAME_READY`**:
   * **Sender:** Web Game on component mount.
   * **Receiver:** Flutter host.
   * **Action:** Flutter hides the initial native loading spinner and displays the WebView container.
2. **`GAME_COMPLETED`**:
   * **Sender:** Web Game upon receiving successful response from `POST /api/game-sessions/:id/complete`.
   * **Receiver:** Flutter host.
   * **Action:** Flutter is notified that gameplay finished. **Critical Security Rule:** Flutter does not trust the `scores` object for issuing authoritative rewards; it triggers a background refresh from `GET /api/game-sessions/:id/result` or `/api/children` to update child XP and badge tallies.
3. **`EXIT_GAME`**:
   * **Sender:** Web Game when the child clicks "Keluar" or finishes the result screen.
   * **Receiver:** Flutter host.
   * **Action:** Flutter cleanly dismisses the WebView screen (`Navigator.pop(context)`) and returns the user to the dashboard.
4. **Origin Hardening:**
   * Flutter ignores any bridge message received from an origin other than the configured allowlist (e.g. `http://localhost:5173`, `http://10.0.2.2:5173`, or `https://games.sicehat.id`).
   * Payloads must be valid JSON matching the schema; unknown message types are safely discarded.

---

## 2. Session Bootstrap & Authorization Handshake

To prevent sensitive, long-lived JWT tokens from appearing in WebView URL query parameters or browser history logs, a short-lived single-use bootstrap handshake is used.

### Handshake Sequence Diagram

```text
Flutter Mobile                 Si-Cehat Backend                Web Game (WebView)
      │                               │                                │
      │ 1. POST /api/game-sessions    │                                │
      │    (with Guardian JWT)        │                                │
      ├──────────────────────────────>│                                │
      │                               │                                │
      │ 2. Returns sessionId &        │                                │
      │    bootstrapToken (TTL 60s)   │                                │
      │<──────────────────────────────┤                                │
      │                               │                                │
      │ 3. Launch WebView URL:        │                                │
      │    game.html?bootstrap=TOKEN  │                                │
      ├───────────────────────────────┼───────────────────────────────>│
      │                               │                                │
      │                               │ 4. POST /bootstrap/exchange    │
      │                               │    { bootstrapToken }          │
      │                               │<───────────────────────────────┤
      │                               │                                │
      │                               │ 5. Returns sessionAuthToken    │
      │                               ├───────────────────────────────>│
      │                               │                                │
      │                               │ 6. POST /complete              │
      │                               │    { plateItems, answers }     │
      │                               │<───────────────────────────────┤
      │                               │                                │
      │                               │ 7. Evaluates & Returns Result  │
      │                               ├───────────────────────────────>│
      │                               │                                │
      │ 8. JS Bridge: GAME_COMPLETED  │                                │
      │<──────────────────────────────┴────────────────────────────────┤
      │                               │                                │
      │ 9. GET /result (Canonical)    │                                │
      ├──────────────────────────────>│                                │
```

---

## 3. Backend REST API Endpoints

All endpoints are prefixed with `/api`. Standard error response shape:

```json
{
  "error": {
    "code": "INVALID_SESSION",
    "message": "Sesi permainan tidak valid atau telah berakhir."
  }
}
```

### 3.1 `GET /api/games`
* **Auth:** Optional / Public.
* **Response:**
```json
{
  "success": true,
  "games": [
    {
      "id": "uuid",
      "slug": "piring-sehat-nimbo",
      "title": "Piring Sehat Nimbo",
      "version": "1.0.0",
      "targetAge": "6-12"
    }
  ]
}
```

### 3.2 `POST /api/game-sessions`
* **Auth:** Required (Guardian JWT).
* **Request:**
```json
{
  "gameSlug": "piring-sehat-nimbo",
  "childId": "child-uuid-optional",
  "studyId": "si-cehat-playlab-eval-2026"
}
```
* **Response (200 OK):**
```json
{
  "success": true,
  "session": {
    "id": "session-uuid",
    "gameSlug": "piring-sehat-nimbo",
    "gameVersion": "1.0.0",
    "status": "IN_PROGRESS",
    "startedAt": "2026-10-21T00:00:00.000Z"
  },
  "bootstrapToken": "short-lived-single-use-token"
}
```

### 3.3 `POST /api/game-sessions/:id/events`
* **Auth:** Session authorization token.
* **Request:**
```json
{
  "eventType": "ITEM_PLACED",
  "sequence": 1,
  "payload": {
    "itemId": "nasi-merah",
    "slot": "karbo"
  }
}
```
* **Response:** `200 OK { "success": true }`.

### 3.4 `POST /api/game-sessions/:id/complete`
* **Auth:** Session authorization token.
* **Request:**
```json
{
  "plateItems": ["nasi-merah", "ikan-bakar", "bayam-bening", "pisang-barangan"],
  "answers": [
    {
      "questionId": "q1_portion",
      "selectedAnswer": "setengah_piring"
    }
  ]
}
```
* **Server-side Validation & Scoring:**
  * Recomputes `gameplayScore` from `plateItems` (verifying 1 karbo, 1 protein, 1 sayur, 1 buah; deducting points if distractors included).
  * Recomputes `knowledgeScore` against versioned `KNOWLEDGE_KEY`.
  * Computes `starsEarned` (1–3 stars) and `xpAwarded`.
  * **Idempotency:** Subsequent calls with the same `id` return the existing canonical `GameResult` record without duplicating child XP in `DailyProgress`.
* **Response (200 OK):**
```json
{
  "success": true,
  "result": {
    "sessionId": "session-uuid",
    "gameplayScore": 100,
    "knowledgeScore": 100,
    "totalScore": 100,
    "starsEarned": 3,
    "xpAwarded": 75,
    "feedbackSummary": "Hebat! Piring makanmu lengkap dan bergizi seimbang.",
    "rulesVersion": "1.0.0"
  }
}
```

### 3.5 `GET /api/game-sessions/:id/result`
* **Auth:** Required (Guardian JWT or Session Token).
* **Response (200 OK):**
```json
{
  "success": true,
  "result": { ... }
}
```

### 3.6 `GET /api/research/export`
* **Auth:** Restricted to users with `role: "ADMIN"` or `role: "POSYANDU"`.
* **Query Parameters:** `?studyId=...&format=json` (or `csv`).
* **Privacy Controls:** Excludes direct child names, guardian phone numbers, and raw email addresses. Maps participants to pseudonymous codes.
