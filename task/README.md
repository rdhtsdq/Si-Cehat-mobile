# Testing Flow & Integration — Task Index

This folder contains one file per module/feature. Each file follows the same
shape: **Context → Findings (integration issues) → Requirement → QA checklist
(manual test cases) → Open questions → Out of scope**.

The audit below is based on static review **plus** real verification:

- `flutter analyze` → `No issues found!`
- `flutter test` → **3 failing tests** (see table)

## Verification snapshot (evidence)

| Result | Detail |
| --- | --- |
| `flutter analyze` | Clean (0 issues) |
| `flutter test` | `00:18 +49 -3` — 3 failures |
| Fail #1 | `si_cehat_full_test.dart:39` — bottom nav label `"Beranda"` no longer exists (now `"Home"`) |
| Fail #2 | `si_cehat_full_test.dart:55` — `"+ Tambah Pengukuran"` no longer exists (now `"Tambah Pengukuran"`) |
| Fail #3 | `features_integration_test.dart:169` — same `"+ Tambah Pengukuran"` drift |

## Cross-cutting findings (highest severity first)

| # | Severity | Finding | Module |
| --- | --- | --- | --- |
| 1 | **P0** | Custom API base URL persistence is broken — `_baseUrlPrefKey` is a URL, not a key | `01-api-client-and-networking.md` |
| 2 | **P0** | Demo/debug builds target production (`https://sicehat.id`) by default | `01-api-client-and-networking.md` |
| 3 | **P1** | Authenticated users lose local data when offline (fallback gated on "no token") | `04-profile.md` |
| 4 | **P1** | Test suite drifted from UI copy (3 failing tests) | `05-home-and-navigation.md`, `06-tracker.md` |
| 5 | **P2** | Date drift risk (UTC `toIso8601String` vs Asia/Jakarta) | `06-tracker.md`, `08-education-and-playlab.md` |
| 6 | **P2** | Triple source of truth for reminders/notifications (SeedData + SQLite + remote) | `09-reminder-and-notifications.md` |
| 7 | **P2** | JWT stored/replayed as `sicehat_session` cookie | `01-api-client-and-networking.md` |

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
