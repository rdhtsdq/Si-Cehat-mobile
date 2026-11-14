# 09 — Reminder & Notifications

## Context

Two related subsystems:

- **Reminders** — `ReminderProvider` (`lib/providers/reminder_provider.dart`) via
  `GET/POST/PATCH/DELETE /api/reminders`, persisted in `reminders` table.
  `LocalNotificationService` (`lib/core/services/local_notification_service.dart`)
  schedules recurring notifications with `flutter_local_notifications`
  (`zonedSchedule`, `matchDateTimeComponents: time`).
- **Notifications** — `NotificationProvider` via `GET /api/notifications`,
  `PATCH /api/notifications/:id`, `POST /api/notifications/read-all`, with SQLite
  cache. `PushNotificationService` (`lib/core/services/push_notification_service.dart`)
  handles FCM (`firebase_messaging` 17, FID-based) and registers the device to
  `POST /api/notifications/devices`. `NotificationNavigation` routes taps.

## Findings / Integration Issues

### P2 — Triple source of truth (SeedData vs SQLite vs remote)
Reminders/notifications are seeded in `SeedData` (`seed_data.dart:132-192`, fixed
IDs/`createdAt 2026-01-15`), again in `_seedDatabase` (`database_helper.dart:309-342`,
`created_at = now()`), and in the in-memory fallback (`now()-1h/30m`). Providers
initialize from `SeedData` then overwrite from DB/remote. The same two
notifications can appear with **different `createdAt` values** depending on the
source, which changes ordering in the notification center. (Also see
`02-local-persistence.md`.)

### P2 — `_reschedule()` only runs on the local-fallback path
`reminder_provider.dart:63` calls `_reschedule()` inside the local-fallback
`finally` block only. When reminders load **successfully from remote** (`:36-45`),
the method returns early and never reschedules local notifications. Local
notifications therefore only reflect server reminders after some other trigger
(restart into offline, or a mutation). Verify scheduled notifications match the
remote reminder list.

### P2 — FCM foreground handling suppresses system notification
`push_notification_service.dart:70-75` sets foreground presentation options to
`alert:false, badge:false, sound:false`, and `_handleForeground` shows a local
notification on the `general` channel. If the local-notification permission or
channel is missing, a foreground push can be invisible to the user (no banner).

### P3 — `notificationIdFor` uses 31-bit hash, risk of collision
`local_notification_service.dart:217-223` hashes reminder id/title to a 31-bit
id. Collisions between distinct reminders would overwrite one another's schedule.

## Requirement

- FR-10: reminder add/edit, time, switch (P0 schedule storage; P1 tested device
  notifications).
- NFR-01/08: Indonesian labels, clear errors, accessible.
- `docs/firebase-setup.md`: FID registration, logout device deletion, push tap →
  reminder/notification center.

## QA Checklist (manual)

| ID | Scenario | Steps | Expected |
| --- | --- | --- | --- |
| REM-01 | Reminder list | Reminder tab | 4 seeded reminders (Sarapan Pagi, Minum air putih, Aktivitas Fisik, Waktu tidur) |
| REM-02 | Toggle enable | Flip a switch | Persists after restart; local schedule rescheduled |
| REM-03 | Complete today | Tap complete checkbox | Progress count updates; state persists |
| REM-04 | Add reminder | + Tambah Reminder → title/time → save | Appears in list + scheduled |
| REM-05 | Edit reminder | Edit time/title | Updated + rescheduled |
| REM-06 | Delete reminder | Delete | Removed from list + cancelled schedule |
| REM-07 | Local notification fires | Set reminder 1 min ahead → background app | Notification appears at scheduled time |
| REM-08 | Notification tap → reminder | Tap a reminder notification | Opens Reminder screen |
| NOTIF-01 | Center list + unread | Notifications center | Items listed; unread count correct |
| NOTIF-02 | Mark read / all read | Tap "Tandai Dibaca" | Unread clears; synced to server when logged in |
| NOTIF-03 | Delete notification | Swipe/delete | Removed locally + server |
| NOTIF-04 | Remote load replaces cache | Online → center | Server list replaces stale cache (deleted server items gone) |
| NOTIF-05 | Push foreground | Send FCM push while foreground | Local banner on `general` channel (verify it is visible) |
| NOTIF-06 | Push background/tap | Send push, tap from tray | Opens correct screen (reminder vs center) |
| NOTIF-07 | Device registration | Real login → check backend `DeviceToken` | FID registered; logout → `DELETE` unregisters |

## Open questions

1. Should remote-loaded reminders also trigger `_reschedule()` so local
   notifications always mirror the server list?
2. Is suppressing the system foreground banner (in favor of the local channel)
   the intended UX, or should foreground pushes show a native heads-up?
3. Which `createdAt` source should be canonical for seeded notifications
   (SeedData fixed date vs `now()`)?

## Out of scope

- Backend notification generation / `firebase-admin` send pipeline.
- Android 13+ notification permission UX beyond the current request flow.
