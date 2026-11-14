# 04 — Profile (Mother / Child)

## Context

`ProfileProvider` (`lib/providers/profile_provider.dart`) owns the mother,
children list, and `activeChild`. It loads from remote (`GET /api/parent/profile`
+ `GET /api/children`) when a token exists, and falls back to local SQLite.
Active-child selection is persisted in `active_child_id`. Screens:
`ProfileSelectScreen` (S06), `MotherProfileScreen` (S07),
`ChildProfileScreen` (S08), `EditProfileScreen` (E04),
`ChildProfileSetupScreen`, `ChildManageSheet` (E02). Avatars update via
`POST /api/parent/profile/avatar` and `POST /api/children/:id/avatar`, with a
local fallback for demo mode.

## Findings / Integration Issues

### P1 — Authenticated users lose local data when offline
`loadProfiles()` (`profile_provider.dart:127-136`) gates the SQLite fallback on
`token == null || token.isEmpty`:
```dart
if (!apiLoaded && (token == null || token.isEmpty)) { ... local DB ... }
```
A **logged-in** user who goes offline keeps a cached token → the remote calls
fail → `apiLoaded` stays false → but the local fallback is **skipped** because the
token is non-empty. Result: empty `_children`/`_activeChild` and no profile
offline, contradicting NFR-05 and the offline-first intent.

### P2 — Demo profile data is duplicated across provider + DB
`ProfileProvider` constructor hardcodes `Ibu Rina`/`Ahmad` (`:26-45`) and then
calls `loadProfiles()`; `DatabaseHelper` seeds the same data. In demo mode the
final state depends on which source wins, and edits go to DB while the
constructor snapshot is discarded — fragile but usually masked because both seeds
are identical today.

### P2 — Active-child id uses string comparison for numeric ids
`active_child_id` is stored as a string and matched with
`c.id.toString() == savedActiveId`; remote children may have non-numeric ids,
which is handled, but the local DB `setActiveChild` uses `WHERE id = ?` with a
`dynamic` that can be a string for remote ids (mismatch risk when a remote child
is later cached locally).

## Requirement

- FR-03: mother profile and child selection/profile; name, DOB, history,
  measurements; extra fields must state their origin.
- FR-16: active-child selection, logout, local deletion.
- NFR-05: offline works for bundled content and local CRUD.
- AC-04: edits persist after restart.

## QA Checklist (manual)

| ID | Scenario | Steps | Expected |
| --- | --- | --- | --- |
| PROF-01 | Default profiles | Launch (demo) → Profil | Mother "Ibu Rina" + child "Ahmad" listed; Ahmad active |
| PROF-02 | Active child switch | Add 2nd child → switch active → restart | Active selection persists |
| PROF-03 | Add child (demo) | Profile → add child → save | Child appears; active switches to new child |
| PROF-04 | Edit mother | Profil Ibu → Edit → change name/education | Changes persist after restart (demo) |
| PROF-05 | Avatar preset | Profil Ibu → camera → preset "Ibu Si Cehat" | Avatar updates + success snackbar |
| PROF-06 | Avatar upload | Profil Anak → camera → Galeri/Kamera | Image picker opens; avatar updates |
| PROF-07 | Offline as logged-in user | Real login → enable airplane mode → open Profil | **Currently expected to fail** (empty profile) — record against NFR-05 |
| PROF-08 | Logout clears session | Logout → relaunch | No residual guardian/child session data |

## Open questions

1. For authenticated offline, should the local DB mirror the last-known server
   children, or is "empty until online" acceptable for D1?
2. Should remote and local children be merged, or is remote authoritative and
   local is demo-only?

## Out of scope

- Child/account data isolation enforcement (FR-15, D1 server-side).
- Consent/guardian governance (FR-14, D1).
