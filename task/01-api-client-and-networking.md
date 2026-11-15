# 01 — API Client & Networking

## Context

The app is **always-online** (per product decision) with a thin HTTP layer and
local fallbacks that still exist for resilience. `ApiClient`
(`lib/core/api/api_client.dart`) wraps `package:http` and exposes `get/post/
put/patch/delete`, all returning a custom `ApiResponse` (`isSuccess`,
`statusCode`, `data`, `errorMessage`, `isOffline`). Auth is a JWT stored in
`SharedPreferences` under `auth_jwt_token`, plus a parallel `auth_session_cookie`
and `auth_guardian_data`. Base URL resolution lives in `ApiConstants`
(`lib/core/api/api_constants.dart`) and supports three sources: a saved custom
URL (SharedPreferences), a `--dart-define=API_BASE_URL`, and a hardcoded
production default. The client rejects HTML responses (SPA fallback) so unknown
routes are not treated as successful API calls.

Integration points: every provider (`auth`, `profile`, `tracker`, `reminder`,
`education`, `notification`, `nutrition`) calls `ApiClient.instance`; PlayLab and
FCM device registration also depend on it.

## Findings / Integration Issues

### P0 — Custom base URL persistence is broken
`api_constants.dart:11`:
```dart
static const String _baseUrlPrefKey = 'http://192.168.1.4:3000';
```
`_baseUrlPrefKey` is meant to be a SharedPreferences **key name**, but it is a
URL (a leftover LAN address). Consequences:
- `init()` reads `prefs.getString('http://192.168.1.4:3000')` → always `null`,
  so a previously saved custom URL is **never** restored.
- `setCustomBaseUrl()` writes to the key `'http://192.168.1.4:3000'`, polluting
  prefs and never being read back.

**Impact:** the LAN/debug URL feature ("run on physical device without rebuild")
silently does not work. The hardcoded IP is also a data-hygiene smell.

### ✅ Accepted — Production URL default (always-online app)
Per the confirmed "always online" decision, the app talks to the backend, so
`productionUrl = 'https://sicehat.id'` as the default (`api_constants.dart:4-6`)
is **intended**, not a bug. The `--dart-define=API_BASE_URL` override remains the
recommended way to point at a dev/staging server. The *saved*-URL override is
broken (see the P0 finding above) — fix it or drop the feature.

### P2 — JWT replayed as a session cookie
`api_client.dart:131-147` (`_buildHeaders`) sets `Cookie: sicehat_session=$token`
when a token exists, and `_captureResponseCookies` (`:149-176`) parses
`set-cookie` and stores the cookie value back into the JWT slot via
`saveToken()`. This conflates two distinct credentials and risks the token being
sent as a cookie to the wrong host/scope.

### P2 — Login/register send duplicate credential fields
`auth_provider.dart:120-128` sends both `email` and `identifier` on login;
`:189-199` sends both `motherName` and `name` on register. Likely a
backend-compatibility workaround, but it should be confirmed against the real
API contract.

## Requirement

- FR-02 / FR-13: auth token and offline behavior must be explicit; D0 must not
  hit a real backend.
- NFR-05: no internet required for bundled content and local CRUD.
- NFR-07: no sensitive data in logs, analytics, or the APK; HTTPS on pilot.
- `docs/playlab-integration-guide.md` §2.1 documents the intended
  `API_BASE_URL` override and `gameWebUrl` derivation.

## QA Checklist (manual)

| ID | Scenario | Steps | Expected |
| --- | --- | --- | --- |
| API-01 | No connectivity (graceful error) | Enable airplane mode → launch app → attempt login/fetch | App shows a clear offline error; no hang or crash (resilience only — app is always-online by design) |
| API-02 | Base URL override (dev/staging) | Run with `--dart-define=API_BASE_URL=http://10.0.2.2:3000` → observe requests | Requests go to the override host, not `sicehat.id` |
| API-03 | Saved base URL persists | Set custom URL via debug UI/settings (if present) → restart | Saved URL restored from prefs (currently broken — record as fail against the P0 finding) |
| API-04 | Unknown route → not "success" | Force `baseUrl` to a SPA host that returns HTML 200 for any path | Client returns "Endpoint API tidak ditemukan", not success |
| API-05 | Timeout / unreachable host | Point at `http://10.0.2.2:1` (closed port) | Requests resolve to `isOffline` failure within ~10s; UI shows offline state |
| API-06 | 401 handling | Stale/expired token → call `auth/me` | `_loadState` clears auth and routes to login |

## Open questions

1. Is the `email`+`identifier` (login) and `motherName`+`name` (register)
   duplication required by the current backend, or should the client send a
   single canonical field?
2. Should the custom base URL feature (`setCustomBaseUrl`) be fixed and retained
   for pointing at staging/dev, or is `--dart-define` sufficient?
3. Should the JWT-as-cookie fallback be removed entirely in favor of
   `Authorization: Bearer` only?

## Out of scope

- Backend implementation/contract itself (this module only verifies the mobile
  client's behavior against it).
- TLS/network security of the production server.
- Actual PlayLab web-game payloads (covered in `08-education-and-playlab.md`).
