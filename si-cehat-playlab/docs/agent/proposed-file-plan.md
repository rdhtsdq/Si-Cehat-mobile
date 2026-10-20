# Proposed File Plan — Si-Cehat PlayLab MVP

> **Date:** October 2026  
> **Phase:** Phase 1 Scaffolding & Integration Plan

This file plan organizes the new standalone repository, backend refinements, and mobile Flutter integration.

---

## 1. New Standalone Repository: `si-cehat-game-web`

A separate, lightweight, independently deployable React 19 + Vite + TypeScript application:

```text
si-cehat-game-web/
├── .env.example                               # Safe environment template (VITE_API_BASE_URL, etc.)
├── .gitignore
├── index.html                                 # Touch-viewport configured HTML shell
├── package.json                               # Scripts: dev, build, lint, test, preview
├── tsconfig.json
├── tsconfig.node.json
├── vite.config.ts
├── public/
│   └── favicon.ico
├── src/
│   ├── main.tsx                              # Application entry
│   ├── App.tsx                               # Router / Session bootstrap loader
│   ├── styles/
│   │   └── index.css                         # Tailwind CSS / child-friendly typography & tokens
│   ├── content/
│   │   ├── types.ts                          # Schema types for Content & Rules
│   │   └── healthy-plate/
│   │       └── v1.json                       # Versioned 1.0.0 food items, plate rules & quiz
│   ├── bridge/
│   │   ├── types.ts                          # GameToAppMessage union type
│   │   └── playlab-bridge.ts                 # Validated postMessage dispatcher with schema checks
│   ├── api/
│   │   ├── client.ts                         # Typed API client for game sessions & completion
│   │   └── types.ts                          # Session, Event, and Result DTOs
│   ├── games/
│   │   └── healthy-plate/
│   │       ├── HealthyPlateGame.tsx          # Main orchestrator (Intro -> Plate -> Quiz -> Result)
│   │       ├── components/
│   │       │   ├── TopBar.tsx                # Exit button, title, and current XP badge
│   │       │   ├── NimboCoach.tsx            # Animated mascot bubble with mood states
│   │       │   ├── PlateArea.tsx             # Interactive 4-quadrant plate (Drag & Tap target)
│   │       │   ├── FoodCardGrid.tsx          # Food cards with touch drag handlers & tap fallback
│   │       │   ├── KnowledgeQuiz.tsx         # Decoupled knowledge evaluation component
│   │       │   └── ResultCard.tsx            # Celebration modal with server-validated score breakdown
│   │       └── hooks/
│   │           └── usePlateGame.ts           # Pure game state reducer & validation logic
│   └── utils/
│       └── scoring.ts                        # Client-side deterministic preview calculations
├── tests/
│   ├── scoring.test.ts                       # Unit tests for scoring logic & plate validation
│   ├── bridge.test.ts                        # Unit tests for bridge message schema & sanitization
│   └── content-schema.test.ts                # Validation of v1.json against Content Schema
└── docs/
    ├── README.md                             # Project overview & quickstart
    ├── local-development.md                  # Instructions for local run & testing
    ├── deployment.md                         # Static hosting, CDN caching & origin configuration
    └── integration-contract.md               # API & Bridge specifications
```

---

## 2. Existing Backend Refinements (`c:\laragon\www\Si-Cehat`)

The backend already has models and routes in place from commit `ddfa5b1`. Proposed refinements are targeted and additive:

| Target File | Proposed Change | Purpose |
|---|---|---|
| `src/server/routes/game.routes.ts` | Add bootstrap exchange endpoint (`POST /api/game-sessions/bootstrap/exchange`) | Allows the web game to exchange a short-lived single-use bootstrap code for session access without tokens in URLs. |
| `src/server/routes/game.routes.ts` | Verify idempotent retry on `/complete` | Ensure multiple retries return exact identical scores and do not award double XP. |
| `src/server/db/schema.ts` | Keep existing tables intact | `gameDefinitions`, `gameSessions`, `gameEvents`, `gameResults`, `assessmentAttempts` match requirements. |
| `src/client/pages/PlayLabGamePage.tsx` | Deprecate/redirect to standalone game origin | Retain as development fallback or redirect to the standalone build. |

---

## 3. Existing Flutter Mobile Changes (`c:\laragon\www\Si-Cehat-mobile`)

Changes in the Flutter repository are isolated to the game launcher and WebView container:

| Target File | Proposed Change | Purpose |
|---|---|---|
| `pubspec.yaml` | Add dependency `webview_flutter: ^4.10.0` | Enables native WebView on Android/iOS. |
| `lib/core/api/api_constants.dart` | Add `gameSessions` endpoint and `gameWebUrl` getter | Centralizes API endpoint and web game origin. |
| `lib/screens/game/game_webview_screen.dart` | **New file:** Flutter screen managing WebView lifecycle | 1. Requests authorized session from backend.<br>2. Restricts navigation to allowlisted game origin.<br>3. Injects `PlayLabBridge` channel.<br>4. Listens for `GAME_READY`, `GAME_COMPLETED`, `EXIT_GAME`.<br>5. Refreshes child XP and results on exit. |
| `lib/screens/home/home_screen.dart` | Add "Si-Cehat PlayLab" interactive banner/card | Provides child-friendly launcher entry from the main dashboard. |
| `test/game_webview_test.dart` | **New file:** Automated unit & widget tests | Tests bridge message parsing, error state recovery, and origin validation. |
