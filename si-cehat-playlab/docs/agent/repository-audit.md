# Repository Audit Report — Si-Cehat Codebases

> **Date:** October 2026  
> **Auditors:** Senior Technical Lead / Agentic Pair  
> **Audited Targets:**
> 1. Mobile Host: `c:\laragon\www\Si-Cehat-mobile` (Flutter)
> 2. Backend & Web Host: `c:\laragon\www\Si-Cehat` (Bun + Hono + Drizzle)

---

## 1. Executive Summary

A comprehensive, non-destructive audit was performed across both active repositories to determine existing conventions, package dependencies, authentication structures, data models, and verification gates.

The audit verified:
1. **Backend has already scaffolded the required database tables and REST endpoints** for PlayLab (added in commit `ddfa5b1`), using **Drizzle ORM** and **Hono** on **Bun**.
2. **Mobile repository (`Si-Cehat-mobile`) currently lacks a WebView dependency** (`webview_flutter` is missing) and has no existing game launcher or bridge layer.
3. **The web game was temporarily committed directly into the backend client app** (`src/client/pages/PlayLabGamePage.tsx`), which violates the project specification requiring an independently buildable, standalone repository (`si-cehat-game-web`).

---

## 2. Flutter Mobile Repository Audit (`Si-Cehat-mobile`)

### 2.1 Toolchain & Package Manager
* **Flutter SDK:** SDK `^3.12.0` (Dart 3.x).
* **Package Management:** Managed via `pubspec.yaml` and `pubspec.lock`.
* **Verification Gate:** `flutter test` executes 17 automated feature and widget integration tests (`test/features_integration_test.dart`, `test/overflow_test.dart`, `test/si_cehat_full_test.dart`). All 17 tests passed cleanly (Exit Code 0).

### 2.2 Architecture & Feature Conventions
* **State Management:** `Provider` pattern via `MultiProvider` mounted in `lib/main.dart` (`AuthProvider`, `ProfileProvider`, `TrackerProvider`, `ReminderProvider`, `EducationProvider`, `NotificationProvider`).
* **Navigation:** Native `MaterialPageRoute` push transitions without a third-party router. Main screen tabs managed via `HomeScreen` in `lib/screens/home/home_screen.dart` with bottom navigation bar shell.
* **Network & API Client:**
  * Base URL configured in `lib/core/api/api_constants.dart` (Android emulator loopback `http://10.0.2.2:3000`, web `http://localhost:3000`, LAN IP fallback).
  * HTTP operations encapsulated in `ApiClient` singleton (`lib/core/api/api_client.dart`), using `http: ^1.6.0`.
  * Standardized response class `ApiResponse` with `isSuccess`, `statusCode`, `data`, and `errorMessage`.

### 2.3 Authentication & Child Profile Context
* **Auth State:** `AuthProvider` (`lib/providers/auth_provider.dart`) tracks `isLoggedIn`, `isDemoMode`, `currentUserEmail`, and `currentUserName`.
* **Session Persistence:**
  * JWT token stored in `SharedPreferences` (`auth_jwt_token`).
  * Cookie stored in `SharedPreferences` (`auth_session_cookie`).
  * Guardian details stored as JSON in `auth_guardian_data`.
* **Child Profile Context:** `ProfileProvider` (`lib/providers/profile_provider.dart`) maintains `activeChild` (`ChildModel` containing UUID `id`, `name`, `dateOfBirth`, `gender`, `healthNotes`). The active child ID is persisted in `SharedPreferences` under `active_child_id`.

### 2.4 WebView & Embedded Browser Status
* **Finding:** Neither `webview_flutter` nor `flutter_inappwebview` is installed in `pubspec.yaml`.
* **Action Required:** Add `webview_flutter: ^4.10.0` to `pubspec.yaml` to enable secure WebView hosting.

---

## 3. Backend Repository Audit (`Si-Cehat`)

### 3.1 Runtime & Framework
* **Runtime:** Bun (managed with `bun.lock`).
* **Server Framework:** Hono (`^4.13.13`) mounted in `src/server/app.ts` under `/api`.
* **Typecheck & Lint:** `bun run typecheck` (`bunx tsc --noEmit`) passes with 0 errors.

### 3.2 Database & Persistence Layer
* **Active ORM:** **Drizzle ORM** (`drizzle-orm: ^0.45.4`, `postgres: ^3.4.9`).
* **Connection & Normalization:** `src/server/db/index.ts` connects via `postgres(cleanUrl)` and normalizes URL parameters.
* **Schema Definition:** `src/server/db/schema.ts` contains all operational models.
* **Note on Prisma:** A `prisma/schema.prisma` exists from early project initialization, but active backend server routes import and query `drizzleDb` and Drizzle schema exports.

### 3.3 Existing PlayLab Models (from commit `ddfa5b1`)
The schema in `src/server/db/schema.ts` already defines:
1. `gameDefinitions` (id, slug, title, description, competency, currentVersion, targetAgeRange, isPublished)
2. `gameSessions` (id, gameId, gameSlug, gameVersion, guardianId, childId, studyId, participantCode, status, startedAt, completedAt)
3. `gameEvents` (id, sessionId, eventType, sequence, payload, occurredAt)
4. `gameResults` (id, sessionId, gameplayScore, knowledgeScore, totalScore, starsEarned, plateComposition, feedbackSummary, rulesVersion, xpAwarded, finalizedAt)
5. `assessmentAttempts` (id, guardianId, childId, studyId, participantCode, assessmentType, instrumentVersion, score, maxScore, answers, completedAt)

### 3.4 Existing PlayLab Endpoints (`src/server/routes/game.routes.ts`)
The backend already exposes:
* `GET /api/games` — catalogs available games.
* `POST /api/game-sessions` — creates an authorized session bound to `guardianId` and `childId`.
* `GET /api/game-sessions/:id` — returns session status.
* `POST /api/game-sessions/:id/events` — records game events.
* `POST /api/game-sessions/:id/complete` — server-side recomputation of scores from submitted `plateItems` and answers.
* `GET /api/game-sessions/:id/result` — returns canonical finalized score.
* `POST /api/assessments/attempts` — records pre/post test submissions.
* `GET /api/research/export` — exports pseudonymized research dataset with ADMIN or POSYANDU role authorization.

### 3.5 Authentication & Authorization Model
* **Middleware:** `src/server/middleware/auth.ts` inspects cookie `sicehat_session` or `Authorization: Bearer <token>`, verifying HS256 JWT signed with `AUTH_SECRET`.
* **Ownership Verification:**
  * All child queries verify `child.guardianId === session.user.id`.
  * Game session creation checks that the requested `childId` belongs to the requesting guardian.

---

## 4. Repository Boundary & Architectural Decisions

| Decision Area | Audit Finding & Recommendation |
|---|---|
| **User Identity Authority** | Backend `guardians` and `children` tables are the single source of truth. |
| **Session Lifecycle Authority** | Backend owns session initialization, state transitions (`IN_PROGRESS` → `COMPLETED`), and scoring computation. |
| **Game Web Repository Location** | The prototype currently located in `Si-Cehat/src/client/pages/PlayLabGamePage.tsx` must be extracted into an independent repo (`si-cehat-game-web`) per specification. |
| **Mobile Integration** | Flutter will launch the game WebView via an authorized route, passing an ephemeral single-use bootstrap code instead of raw long-lived tokens. |
| **Data Schema Reusability** | Existing Drizzle models in `src/server/db/schema.ts` match all core requirements; no destructive migrations are required. |
