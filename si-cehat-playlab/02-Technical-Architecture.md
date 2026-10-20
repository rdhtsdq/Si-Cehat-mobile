# 02 — Technical Architecture

## 1. Architecture objective

Integrate one HTML5 educational game into the existing Si-Cehat Flutter app while keeping game rendering, app navigation, backend authority, and research data responsibilities clearly separated.

The following is a proposed architecture. Confirm the actual repository structure, package versions, auth flow, and deployment setup before implementation.

## 2. Logical architecture

```text
Flutter Mobile
├── Existing authentication and profile context
├── Game launcher
├── WebView lifecycle/navigation
└── Result refresh from API
          │
          ├── Limited, validated JS bridge for UI/navigation signals
          └── HTTPS API requests
                    │
Web Game (React + Vite + TypeScript, or plain HTML/CSS/JS)
├── Gameplay state and touch input
├── UI, animation, instructions
├── Educational feedback
└── Minimal, schema-defined events
                    │
Existing Si-Cehat Backend (Bun)
├── Authentication and authorization
├── Session creation/lifecycle
├── Server-side validation/scoring
├── Idempotent completion
└── Research export authorization
                    │
PostgreSQL + Prisma
├── Game definitions/versions
├── Sessions
├── Events
├── Results
└── Assessment attempts
```

## 3. Technology choices

- **Flutter:** existing mobile host and navigation.
- **`webview_flutter`:** candidate package for embedding the web game; verify compatibility with the repository’s Flutter version.
- **Web frontend:** React + Vite + TypeScript if it matches the team’s conventions. Plain HTML/CSS/JavaScript is also acceptable for a small game.
- **Gameplay rendering:** DOM/CSS for the first drag-and-drop game. Consider Phaser only if future requirements justify a game engine.
- **Backend:** existing Bun API if confirmed by repository audit.
- **Persistence:** existing PostgreSQL and Prisma setup if confirmed.
- **Research export:** use existing admin/reporting patterns where possible.

Do not add a framework or service just because it is listed here. Choose the simplest stack that satisfies the requirements.

## 4. Hosting and origin

A proposed deployment is a static web build on a dedicated trusted origin such as `games.example.com`, with the API on its own approved origin. These are placeholders, not actual project domains.

Requirements:
- HTTPS only in production.
- WebView navigation restricted to the approved game origin.
- External links must not inherit the privileged JS bridge.
- Static assets may be cached, but game version must be recorded for each session.
- A study should pin the game/content/rules version during data collection.
- Deployments that change gameplay, scoring, content, or assessment must be documented and reviewed for research impact.

## 5. Responsibilities

### Flutter host

- Maintain the active user/profile context.
- Request a session from the backend.
- Open only the approved game origin.
- Handle loading, errors, back navigation, background/resume, and exit.
- Refresh final result from the backend after completion.
- Never grant rewards solely because a client message claims completion.

### Web game

- Render and run gameplay.
- Manage local interaction state.
- Display educational feedback.
- Send only defined events and completion requests.
- Avoid storing long-lived credentials.
- Never be the authority for final score or reward.

### Backend

- Authenticate and authorize requests.
- Create and validate sessions.
- Verify ownership and state transitions.
- Validate or recompute scoring.
- Enforce idempotency and rate limits.
- Store game/rules/instrument versions.
- Control reward issuance.
- Apply access control to research exports.

## 6. Bridge contract

Example message types:

```typescript
type GameToAppMessage =
  | { type: "GAME_READY"; protocolVersion: 1 }
  | { type: "GAME_COMPLETED"; sessionId: string }
  | { type: "EXIT_GAME" };
```

Interpretation:
- `GAME_READY`: UI readiness signal only.
- `GAME_COMPLETED`: asks Flutter to refresh the result through the backend. It does not prove the result is valid.
- `EXIT_GAME`: asks Flutter to run the approved exit flow.

Requirements:
- Validate each message against a schema.
- Reject unknown message types and malformed payloads.
- Limit payload size.
- Confirm the session ID matches the current authorized session.
- Do not pass long-lived access or refresh tokens through the bridge.
- Do not allow arbitrary page content to call privileged native functionality.

## 7. Session bootstrap

Proposed flow:
1. Flutter requests a new game session from the backend.
2. Backend authorizes the user/profile and returns a session identifier plus a short-lived bootstrap mechanism.
3. Flutter opens the allowlisted game origin.
4. The game exchanges or consumes the bootstrap mechanism according to the implemented contract.
5. All result/event requests are authenticated and authorized by the backend.

A one-time, short-lived code bound to the user/profile, game, and version is one possible design. Do not place permanent tokens or direct child identifiers in query strings. Query strings can appear in logs, history, and monitoring systems.

The exact mechanism must fit the existing authentication system and be reviewed for leakage and replay risks.

## 8. Offline and network behavior

Decide explicitly whether offline gameplay is supported.

For the first MVP, it is acceptable to require a connection for session creation and result submission, provided the UI clearly handles connection failures. If local event queueing is implemented:
- Use stable event IDs or sequence numbers.
- Make retries idempotent.
- Show pending versus server-confirmed state.
- Do not invent or silently discard research results.
- Define how incomplete sessions are represented.

## 9. Observability

- Log operational errors with request/session correlation IDs that do not expose direct identifiers unnecessarily.
- Redact tokens and sensitive payload fields.
- Record game version and error category.
- Avoid logging raw assessment answers unless the approved research data plan requires them.
- Provide enough diagnostics to investigate failed sessions without collecting unnecessary child data.

## 10. Architecture acceptance criteria

- Game is independently buildable and testable.
- Flutter controls app navigation and WebView lifecycle.
- Backend is authoritative for session status and final results.
- WebView bridge is limited and validated.
- Game version is attached to every session.
- No long-lived token is placed in a URL.
- Existing auth/profile patterns are reused where appropriate.
- Network and error states are explicit.
