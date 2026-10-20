# 03 — API and Database Specification

## 1. Status

This document proposes API and data contracts. Route names and schema examples are not claims about the current repository. The coding agent must inspect existing routes, Prisma models, authentication middleware, and naming conventions before implementing them.

## 2. API principles

- HTTPS in production.
- Authenticate every private endpoint.
- Authorize the active user/profile for each session and assessment.
- Validate request bodies and bound payload size.
- Use consistent error formats.
- Do not trust client-calculated final scores.
- Make completion and reward operations idempotent.
- Record the game, content, rules, and instrument versions.
- Limit research exports to explicitly authorized roles and studies.

## 3. Proposed endpoints

### `GET /api/games`

Purpose: return games available to the authorized user/context.

Potential response fields:
- `id`
- `slug`
- `title`
- `version`
- `status`
- `launch_config` only if it contains no secrets

### `POST /api/game-sessions`

Purpose: create an authorized game session.

Potential request fields:
- `game_id`
- `requested_version` if version selection is allowed by policy
- study/participant reference if required by the existing study model

The server must derive or verify the participant/profile from the authenticated context. Do not trust an arbitrary client-supplied profile ID.

Potential response:
- `session_id`
- `game_id`
- `game_version`
- `status`
- short-lived bootstrap data if required

### `POST /api/game-sessions/:id/events`

Purpose: accept a bounded set of allowed events.

Potential event fields:
- `event_id`
- `event_type`
- `sequence` if ordering is required
- `occurred_at` from the client, treated as untrusted
- schema-validated, purpose-limited `payload`

The server should set its own received timestamp. Avoid collecting unnecessary raw interaction data.

### `POST /api/game-sessions/:id/complete`

Purpose: request finalization.

The client should submit answers or evidence needed for server validation, not an authoritative `knowledge_score` or reward amount.

Server responsibilities:
- Verify ownership and session state.
- Verify game and rules version.
- Validate submitted answers and allowed state transitions.
- Compute or verify scores.
- Persist the final result transactionally.
- Apply idempotency.
- Return the same canonical result for a legitimate retry.

### `GET /api/game-sessions/:id/result`

Purpose: retrieve the canonical server-validated result after authorization.

### `POST /api/assessments/attempts`

Purpose: submit a pre-test, post-test, or follow-up attempt.

Server must validate:
- Authorized participant/study context.
- Instrument version.
- Allowed assessment type and timing.
- Answer schema.
- Duplicate submission policy.

### `GET /api/research/studies/:id/export`

Purpose: export an approved research dataset.

Requirements:
- Restricted to authorized research roles.
- Enforce study-level access.
- Exclude direct identifiers unless specifically approved and necessary.
- Log export activity without logging sensitive exported content.
- Apply agreed retention and deletion policies.

## 4. Proposed entities

### `GameDefinition`

Fields to consider:
- `id`
- `slug`
- `title`
- `current_version`
- `status`
- created/updated timestamps

### `GameSession`

Fields to consider:
- `id`
- reference to existing user/child profile or participant model
- `game_id`
- `game_version`
- `content_version`
- `rules_version`
- `status`
- `started_at`
- `completed_at`
- created/updated timestamps

Suggested statuses:
- `created`
- `in_progress`
- `completion_pending`
- `completed`
- `abandoned`
- `failed`

Use only states the implementation actually needs, and document valid transitions.

### `GameEvent`

Fields to consider:
- `id`
- `session_id`
- `event_id` or another deduplication key
- `event_type`
- `sequence` where necessary
- schema-validated `payload`
- `occurred_at`
- server `received_at`

Do not record every pointer movement by default.

### `GameResult`

Fields to consider:
- `id`
- `session_id`
- `gameplay_score`
- `knowledge_score` only if measured in that session
- `rules_version`
- `finalized_at`

If one session has only one final result, add a unique constraint on `session_id`.

### `AssessmentAttempt`

Fields to consider:
- `id`
- participant/profile reference
- `study_id`
- `assessment_type` (`pre`, `post`, `follow_up`)
- `instrument_version`
- structured answers or approved response representation
- server-calculated score
- `completed_at`

Data model and foreign keys must match the real repository and approved research design.

## 5. Validation and integrity

- Server derives identity from authenticated context wherever possible.
- Verify session ownership on every session endpoint.
- Validate session state before accepting events or completion.
- Reject unsupported game/instrument versions.
- Recompute score using server-held rules/answer keys.
- Use database transactions for final result and reward changes that must remain consistent.
- Add uniqueness constraints for result/session and deduplication IDs as appropriate.
- Apply rate limits and payload size limits.
- Treat client timestamps as advisory, not authoritative.
- Define handling for late, duplicate, out-of-order, and missing events.
- Do not allow a result to be silently overwritten after finalization.

## 6. Error contract

Use the repository’s existing error convention if one exists. Otherwise, define a consistent response shape, for example:

```json
{
  "error": {
    "code": "SESSION_EXPIRED",
    "message": "The game session is no longer active.",
    "request_id": "server-generated-correlation-id"
  }
}
```

Potential error codes:
- `UNAUTHENTICATED`
- `FORBIDDEN`
- `GAME_NOT_AVAILABLE`
- `INVALID_SESSION`
- `SESSION_EXPIRED`
- `INVALID_EVENT`
- `INVALID_ANSWER`
- `VERSION_NOT_SUPPORTED`
- `ALREADY_COMPLETED`
- `RATE_LIMITED`
- `INTERNAL_ERROR`

Do not leak internal stack traces, database details, or other users’ information to clients.

## 7. Migrations and compatibility

- Inspect existing Prisma schema before proposing models.
- Reuse existing user/profile/study models where suitable.
- Use additive, backward-compatible migrations where possible.
- Never drop or rewrite existing user data as part of the game feature without an explicit approved migration plan.
- Document rollback and deployment order.
- Add indexes based on real query patterns and expected scale, not speculation.
- Test migrations against a disposable development/test database before production.

## 8. API/database acceptance criteria

- Unauthorized and cross-profile access tests fail safely.
- Completion retries do not duplicate results or rewards.
- Server score matches expected fixtures for the relevant rules version.
- Unsupported or malformed payloads are rejected.
- Version metadata is saved and returned.
- Research export is role- and study-authorized.
- No secrets or unnecessary direct identifiers appear in API responses or logs.
