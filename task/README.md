# Testing Flow & Integration — Task Index

This folder contains one file per module/feature. Each file follows the same
shape: **Context → Findings (integration issues) → Requirement → QA checklist
(manual test cases) → Open questions → Out of scope**.

The audit below is based on static review **plus** real verification:

- `flutter analyze` → `No issues found!`
- `flutter test` → **3 failing tests** (see table)

## Product decisions (confirmed)

| Decision | Choice | Consequence |
| --- | --- | --- |
| Bottom-nav label | **"Home"** is canonical | UI is correct; update the tests, not the app |
| Navigation shell | **4-tab permanent bottom nav** (current) | Accepted; removed the "diverges from DESIGN_PLAN" finding |
| Connectivity | **Always online** (talks to backend) | Offline-queue & "production-by-default" are **not bugs**; keep base URL configurable for dev/staging |

## Verification snapshot (evidence)

| Result | Detail |
| --- | --- |
| `flutter analyze` | Clean (0 issues) |
| `flutter test` (before fix) | `00:18 +49 -3` — 3 failures |
| `flutter test` (after fix) | `00:21 +55` — **all tests pass** |

Fixed test drift (UI is canonical, tests updated):

- `si_cehat_full_test.dart:39` — `"Beranda"` → `"Home"`
- `si_cehat_full_test.dart:55` — `"+ Tambah Pengukuran"` → `"Tambah Pengukuran"`
- `features_integration_test.dart` — `"+ Tambah Pengukuran"`, `"+ Catat Aktivitas Baru"`,
  tooltip `"Tambah 1 Gelas"`→`"Tambah 1 gelas"`, water `"1 dari 8 Gelas"`→`"1 dari 8 gelas"`

## Cross-cutting findings (final resolution)

| # | Severity | Finding | Module | Status |
| --- | --- | --- | --- | --- |
| 1 | **P0** | Custom API base URL persistence broken — `_baseUrlPrefKey` was a URL, not a key | `01-api-client-and-networking.md` | ✅ **Fixed** (`api_base_url` + regression test) |
| 2 | **P1** | Test suite drifted from UI copy (3 failing tests) | `05-home-and-navigation.md`, `06-tracker.md` | ✅ **Fixed** (tests aligned to canonical UI) |
| 3 | **P2** | Date drift risk (UTC `toIso8601String` vs Asia/Jakarta) | `06-tracker.md`, `08-education-and-playlab.md` | ✅ **Verified non-bug** (all local dates in current flow) |
| 4 | **P2** | Triple source of truth for reminders/notifications (SeedData + SQLite + remote) | `09-reminder-and-notifications.md` | ⏳ **Deferred** (code smell, no user-facing bug) |
| 5 | **P2** | JWT stored/replayed as `sicehat_session` cookie | `01-api-client-and-networking.md` | ⏳ **Needs backend decision** (may break auth) |
| 6 | **P2** | `resetDemoData()` left orphan activity/water rows | `02-local-persistence.md` | ✅ **Fixed** (DB + in-memory fallback + test) |

> Note: "production URL is the default" and "authenticated-offline profile gap"
> were **reclassified as not-bugs** after the "always online" decision. They are
> documented as accepted decisions in the relevant module files.

## Module files

1. [API client & networking](01-api-client-and-networking.md)
2. [Local persistence (SQLite)](02-local-persistence.md)
3. [Auth & onboarding](03-auth-and-onboarding.md)
4. [Profile (mother/child)](04-profile.md)
5. [Home & navigation](05-home-and-navigation.md)
6. [Tracker](06-tracker.md)
7. [Nutrition & food diary](07-nutrition-and-food-diary.md)
8. [Education & PlayLab](08-education-and-playlab.md)
9. [Reminder & notifications](09-reminder-and-notifications.md)
10. [Screening](10-screening.md)
11. [Consultation & community](11-consultation-and-community.md)
