# 02 — Local Persistence (SQLite)

## Context

`DatabaseHelper` (`lib/core/database/database_helper.dart`) is the single SQLite
gateway (`si_cehat_local.db`, schema version 4). Tables: `mother_profile`,
`child_profile`, `growth_measurements`, `reminders`, `notifications`,
`activity_logs`, `daily_water_logs`. It seeds demo data on first create
(`_seedDatabase`) and runs additive migrations in `_onUpgradeDB`. On web, or if
the native sqflite binary fails to load, it silently switches to an in-memory
fallback (`_useInMemoryFallback`) with hardcoded demo data. `resetDemoData()`
deletes rows and re-seeds.

Integration points: `ProfileProvider`, `TrackerProvider`, `ReminderProvider`,
`NotificationProvider`, and `PlayLabStorageService` all read/write through
`DatabaseHelper.instance`.

## Findings / Integration Issues

### P1 — In-memory fallback silently drops persistence
`database_helper.dart:27-46` returns `null` (in-memory mode) on web or on any
sqflite init failure, with only a `debugPrint`. There is no user-visible
indicator that data will not survive restart. For the Android D0 target this is
usually fine, but any web/desktop run loses NFR-04 (persistence) without warning.

### P2 — Triple source of truth for seeds
Reminders and notifications exist in three places with slightly different data:
- `SeedData.initialReminders` / `initialNotifications` (`seed_data.dart:132-192`) —
  fixed IDs and `createdAt: DateTime(2026,1,15,...)`.
- `_seedDatabase` (`database_helper.dart:309-342`) — same titles, but
  `created_at = DateTime.now()`.
- In-memory fallback (`_initFallbackData`, `:48-100`) — `DateTime.now()-1h/30m`.

Because providers seed from `SeedData` first and then overwrite from DB/remote,
the visible `createdAt`/ordering of the same two notifications differs depending
on which source won. See `09-reminder-and-notifications.md`.

### ✅ Fixed — `resetDemoData` now clears activity/water logs
`resetDemoData()` (`database_helper.dart:631`) previously deleted only
`notifications`, `reminders`, `growth_measurements`, `child_profile`,
`mother_profile`, leaving orphan rows in `activity_logs` and `daily_water_logs`.
Fixed: it now also deletes `activity_logs` + `daily_water_logs`, and the in-memory
fallback clears `_fallbackActivities` + `_fallbackWater` (regression test in
`test/database_reset_test.dart`).

**Remaining note:** SharedPreferences-held state (`pending_nutrition_batches`,
PlayLab score history, avatar prefs) is still not cleared by reset — but the
"Reset Data Demo" UI entry point itself is currently **not wired** (see
`05`/DESIGN_PLAN AC-06). Clearing prefs is deferred until the reset button is
added.

### P2 — `setActiveChild` accepts arbitrary id without FK-level guard
`setActiveChild` (`:407-417`) updates `is_active` across all children to 0/1 by
id; no transactional guard ensures a single active child if `is_active` ever
gets out of sync.

## Requirement

- NFR-04: local saves are atomic; child/account scoping; migrations must not
  silently delete data.
- AC-04 (persistence): add measurement / edit name / toggle reminder → restart →
  data still present.
- AC-06 (reset demo): returns to seed with a confirmation dialog.
- FR-16: logout/reset cleans up session without swapping profiles.

## QA Checklist (manual)

| ID | Scenario | Steps | Expected |
| --- | --- | --- | --- |
| DB-01 | First launch seeds | Clear app data → launch → open Tracker & Reminder | Default mother (Ibu Rina), child (Ahmad), 5 measurements, 4 reminders, 2 notifications present |
| DB-02 | Persistence across restart | Add measurement, rename mother, toggle reminder off → force-stop → relaunch | All edits persist (Android D0) |
| DB-03 | Migration path | Install an old build (schema < 4) → upgrade to current → relaunch | Data survives; no crash; new columns/tables exist |
| DB-04 | Reset demo | Profile → "Reset Data Demo" → confirm | Returns to seed state; no orphan activity/water rows (fixed; but the reset button itself is not yet wired in the UI) |
| DB-05 | Web/desktop fallback | Run on web/desktop → add data → reload | Data resets to demo (in-memory). Confirm UI warns the user it is ephemeral (currently it does not — record as fail) |
| DB-06 | Single active child | Add 2 children, switch active several times → restart | Exactly one active child, matching last selection |

## Open questions

1. Should the in-memory/web fallback surface a visible "data not persisted"
   banner instead of silently degrading?
2. What is the intended scope of "reset demo" — full wipe (including activity
   logs, water, PlayLab scores, pending nutrition queue) or profile/measurement
   seed only?

## Out of scope

- Database encryption / at-rest security (deferred to D1 risk review, NFR-07).
- Cloud sync / outbox (D1 FR-13).
