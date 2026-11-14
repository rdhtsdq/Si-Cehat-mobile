# 06 — Tracker (Growth & Habits)

## Context

`TrackerProvider` (`lib/providers/tracker_provider.dart`) manages growth
measurements (`growth_measurements` via `GET/POST/DELETE /api/tracker/growth`)
and daily habits/activities (`activity_logs` via `/api/tracker/activities`) plus
water intake (`daily_water_logs`, synced to `POST /api/progress`).
`TrackerScreen` (`lib/screens/tracker/tracker_screen.dart`) has two tabs —
"Tumbuh Kembang" (custom-painted growth chart, latest stats, history, add
measurement) and "Aktivitas" (`HabitLogScreen` / `HabitLogView`). Dates are
derived from `DateTime` via `toIso8601String().substring(0,10)`.

## Findings / Integration Issues

### P1 — Stale test expectations for CTA copy (2 failing tests)
`tracker_screen.dart:222` renders `PrimaryButton(text: 'Tambah Pengukuran')`
with a leading `Icon(Icons.add_rounded)`. The tests
(`si_cehat_full_test.dart:55`, `features_integration_test.dart:169`) expect the
literal `"+ Tambah Pengukuran"`. This is test failure #2/#3 — the UI copy changed
without updating the integration suite.

### P2 — Date drift risk (NFR-09)
`loadActivities` computes `dateStr = _activityDate.toIso8601String().substring(0,10)`
(`tracker_provider.dart:153`) and `setWater` does the same (`:239`). If
`_activityDate` ever carries a UTC `DateTime` (e.g. converted from a server
value), the local Asia/Jakarta date can shift by one day. NFR-09 requires
date-only values to not be timezone-converted.

### P2 — `addMeasurement` double-writes local even when remote is authoritative
`addMeasurement` (`:89-123`) POSTs to the server, then **always** inserts locally
and reloads. With a token present, `loadMeasurements` prefers remote, so the local
insert is effectively a cache; but there is no remote-id link, so the locally
inserted row can diverge from the server record (no `remote_id` column for
measurements, unlike `activity_logs`).

### P3 — `totalActiveMinutes` only counts "Aktivitas Fisik"
`totalActiveMinutes` (`:33-35`) filters `category == 'Aktivitas Fisik'`. Any other
activity category contributing to the daily minute target is ignored, so the
"Target Aktivitas Fisik" progress can under-count.

## Requirement

- FR-06: BB/TB tracker + history; interpretation GATED.
- FR-07: activity/food/water notes (P1).
- NFR-09: date-only birth/measurement values must not shift across timezones.
- AC-04: added measurement persists after restart.

## QA Checklist (manual)

| ID | Scenario | Steps | Expected |
| --- | --- | --- | --- |
| TRK-01 | Growth chart + latest | Tracker → Tumbuh Kembang | Chart, "Berat Badan Terakhir", "Tinggi Badan Terakhir", history render |
| TRK-02 | Add measurement | "+ Tambah Pengukuran" (icon) → fill date/BB/TB → save | Chart + history update reactively; persists after restart |
| TRK-03 | Delete measurement | History tile → trash → confirm | Row removed; chart updates |
| TRK-04 | Activity tab | Tracker → Aktivitas | Target activity card, water counter, "+ Catat Aktivitas Baru" present |
| TRK-05 | Log activity | + Catat Aktivitas → pick preset → save | Success snackbar + activity appears |
| TRK-06 | Water increment | Tap "+1 Gelas" | Counter increments; `POST /api/progress` fired when logged in |
| TRK-07 | Date boundary (offline) | Set device timezone to UTC vs Jakarta → log activity at 23:30 | Date recorded as the *local* calendar day, not shifted (NFR-09) |

## Open questions

1. Is `"Tambah Pengukuran"` (icon, no "+" prefix) the final copy, or should tests
   be updated to a canonical `"+ Tambah Pengukuran"`?
2. Should measurements carry a `remote_id` for idempotent offline sync (D1)?
3. Which activity categories should count toward the 60-min target — only
   "Aktivitas Fisik" or a broader set?

## Out of scope

- Nutritional status interpretation (GATED per FR-06).
- Calorie calculation (FR-07: not without validated data).
