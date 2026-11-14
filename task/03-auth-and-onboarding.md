# 03 — Auth & Onboarding

## Context

Entry flow: `SplashScreen` → (first launch) `OnboardingScreen` → `LoginScreen`.
`AuthProvider` (`lib/providers/auth_provider.dart`) owns `hasSeenOnboarding`,
`isLoggedIn`, `isDemoMode`, and user identity. Two login paths exist:
- **Real** login/register via `POST /api/auth/login` and `/register`
  (`login()`/`register()`).
- **Demo** login via `loginDemo()`, which clears auth and marks `isDemoMode`.

Session state is derived in `_loadState()`: if a token exists it calls
`/api/auth/me` to validate; on 401 it clears; if offline it trusts the cached
token + guardian. Splash awaits `auth.ensureInitialized()` before routing.

## Findings / Integration Issues

### P1 — Demo-login state vs token interplay
`loginDemo()` (`auth_provider.dart:249-261`) calls `_apiClient.clearAuth()`, which
removes the token/cookie/guardian but **does not** clear `is_logged_in`/
`is_demo_mode` (it sets them to true). If a user later does a real login, the
stale demo flags are overwritten correctly; but a demo session that then goes
through `_loadState()` with no token relies purely on `is_demo_mode` pref. Verify
the reset path is unambiguous (see QA-03).

### P2 — `_loadState` offline branch trusts any cached token
`_loadState()` (`:70-79`) sets `_isLoggedIn = true` whenever `/auth/me` fails for
a reason other than 401 (network error, timeout, 5xx). A valid-looking but
revoked/short-lived token therefore keeps the user "logged in" until the server
is reachable. This is the intended offline UX but should be tested against
expired-token + offline combinations.

### P2 — `register` persists login but does not verify response token shape
`register()` (`:202-231`) succeeds whenever `response.data != null`, even if
`token` and `guardian` are both null; it then marks `_isLoggedIn = true` with no
identity. A malformed-but-200 register response can leave a logged-in state with
empty user info.

## Requirement

- FR-01: splash/onboarding per PDF, **no permission request during splash**.
- FR-02: login/register/recovery are P0 demo UI; real auth is D1. Demo must be
  clearly labeled ("tidak terhubung ke akun nyata").
- FR-16: logout cleans up session/data without swapping profiles.
- D0 "Login demo tidak dianggap autentikasi server."

## QA Checklist (manual)

| ID | Scenario | Steps | Expected |
| --- | --- | --- | --- |
| AUTH-01 | First-launch flow | Clear data → launch | Splash → Onboarding → (Lanjut) → Login |
| AUTH-02 | Onboarding remembered | Complete onboarding → relaunch | Skips onboarding → Login directly |
| AUTH-03 | Demo login | Login → "Masuk (demo)" (or demo entry) | Enters shell as "Ibu Rina (Mode Demo)"; label "Mode demo" visible |
| AUTH-04 | Demo persists | Demo login → force-stop → relaunch | Stays in demo session (no re-onboarding, no re-login) |
| AUTH-05 | Logout | Demo/real login → logout | Returns to login; `is_logged_in`/`is_demo_mode` cleared; FCM device unregistered |
| AUTH-06 | Real login success | Valid creds → login | Token saved; `registerDevice()` called; profile loads from server |
| AUTH-07 | Real login wrong creds | Invalid password | Inline error, no navigation |
| AUTH-08 | Register | Fill Nama/HP/Email/Password → submit | Account created, enters shell, guardian data saved |
| AUTH-09 | Forgot password | Tap "Lupa Password?" | Recovery sheet opens (E01) |

## Open questions

1. Which channel (email vs phone) is the canonical login identifier for D1? The
   client currently sends both `email` and `identifier`.
2. Should demo mode be entirely offline (no `/auth/me` probe) to honor the
   "no backend" D0 acceptance?

## Out of scope

- Server-side authentication hardening (D1).
- Consent/guardian governance and retention (FR-14, D1).
