# Notifikasi Aplikasi Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Pengingat lokal yang muncul di OS walau aplikasi ditutup, plus fondasi FCM push untuk event server.

**Architecture:** `flutter_local_notifications` menjadwalkan reminder harian; backend menyimpan device token dan mengirim push via `firebase-admin` bila credential tersedia (no-op tanpa credential). Pusat notifikasi in-app tetap menjadi sumber riwayat.

**Tech Stack:** Flutter 3.12+/Dart 3, `flutter_local_notifications`, `timezone`, `flutter_timezone`, Bun + Hono + Drizzle, `firebase-admin` (fase 2 mobile: `firebase_core`/`firebase_messaging`).

**Spec:** `docs/superpowers/specs/2026-10-28-nutrition-module-and-notifications-design.md`

## Global Constraints

- Reminder lokal memakai `inexactAllowWhileIdle`; tanpa izin exact alarm.
- Tidak ada notifikasi ganda: reminder lokal tidak membuat entri server; event server hanya lewat FCM.
- Tanpa kredensial Firebase, endpoint dan push harus tetap berfungsi (no-op).
- Token FCM tidak boleh dicetak penuh di log.
- Android 13+: minta izin `POST_NOTIFICATIONS` saat membuka tab Reminder.
- iOS belum didukung (tidak ada folder `ios/`).

## Review Focus

- Izin notifikasi ditolak → fitur reminder tetap bisa dipakai, ada banner pengaturan.
- Waktu reminder tidak valid/kosong → tidak menjadwalkan, tidak crash.
- Reboot perangkat → jadwal tetap ada (receiver plugin).
- Reminder dihapus/nonaktif → notifikasi lama benar-benar dibatalkan.
- Token FCM berubah/logout → token lama tidak menerima push.

---

### Task 1: Local notification service + Android setup

**Files:**
- Modify: `pubspec.yaml`
- Modify: `android/app/build.gradle.kts`
- Modify: `android/app/src/main/AndroidManifest.xml`
- Create: `lib/core/services/local_notification_service.dart`
- Test: `test/local_notification_service_test.dart`

**Interfaces:**
- Produces:
  - `class LocalNotificationService` singleton with `Future<void> initialize()`, `Future<bool> requestPermission()`, `Future<void> rescheduleReminders(List<ReminderModel>)`, `Future<void> cancelAll()`, `Future<void> show({required int id, required String title, required String body, String? payload})`, `int notificationIdFor(dynamic reminderId)`.
  - Channel IDs: `reminders`, `general`.

- [ ] **Step 1: Add packages** `flutter_local_notifications`, `timezone`, `flutter_timezone` via `flutter pub add`; expect pub resolution success.
- [ ] **Step 2: Write failing test** for `notificationIdFor('same-id')` returning the same int and `notificationIdFor('other-id')` differing.
- [ ] **Step 3: Run `flutter test test/local_notification_service_test.dart`; expected FAIL.**
- [ ] **Step 4: Implement the service** with `tz.initializeTimeZones()` + `flutter_timezone`; create channels; `zonedSchedule` with `matchDateTimeComponents: DateTimeComponents.time` and `AndroidScheduleMode.inexactAllowWhileIdle`.
- [ ] **Step 5: Android config:** desugaring (`coreLibraryDesugaringEnabled`, `desugar_jdk_libs`), `POST_NOTIFICATIONS`, `RECEIVE_BOOT_COMPLETED`, scheduled/boot receivers.
- [ ] **Step 6: Run test + `flutter build apk --debug`; expected PASS/build success.**
- [ ] **Step 7: Commit** `feat(notifications): add local notification service`.

---

### Task 2: Wire reminders, permissions, and tap navigation

**Files:**
- Modify: `lib/main.dart`
- Modify: `lib/core/services/reminder_service.dart`
- Modify: `lib/providers/reminder_provider.dart`
- Modify: `lib/screens/reminder/reminder_screen.dart`
- Create: `lib/core/services/notification_navigation.dart`
- Test: `test/reminder_scheduling_test.dart`

**Interfaces:**
- Consumes: `LocalNotificationService` from Task 1.
- Produces:
  - `NotificationNavigation.navigatorKey` (`GlobalKey<NavigatorState>`).
  - `NotificationNavigation.handlePayload(String? payload)` opens `ReminderScreen` for `{"type":"REMINDER"}`.
  - `ReminderProvider` calls `rescheduleReminders(_reminders)` after load/create/update/toggle/delete.

- [ ] **Step 1: Write failing test** for payload parsing: reminder payload → route name `reminder`; unknown payload → `null`.
- [ ] **Step 2: Run test; expected FAIL.**
- [ ] **Step 3: Implement navigation + wire `MaterialApp(navigatorKey: ...)` and `onDidReceiveNotificationResponse`.**
- [ ] **Step 4: Replace Timer-based OS scheduling** in `ReminderService`; keep a no-op/in-app stream if needed; call `rescheduleReminders` from `ReminderProvider` after every mutation.
- [ ] **Step 5: Request permission when `ReminderScreen` opens**; show a non-blocking banner if denied.
- [ ] **Step 6: Run all tests + analyze; expected PASS.**
- [ ] **Step 7: Manual check:** schedule a reminder 1–2 minutes ahead, kill the app, verify OS notification; tap opens ReminderScreen.
- [ ] **Step 8: Commit** `feat(notifications): schedule reminders and handle taps`.

---

### Task 3: Backend device tokens and push service

**Files:**
- Modify: `../Si-Cehat/src/server/db/schema.ts`
- Create: `../Si-Cehat/src/server/services/push.ts`
- Create: `../Si-Cehat/src/server/routes/notification.routes.ts` (or extend `parent.routes.ts`)
- Modify: `../Si-Cehat/src/server/app.ts`
- Modify: `../Si-Cehat/src/server/services/notifications.ts`
- Modify: `../Si-Cehat/src/server/env.ts`, `.env.example`
- Test: `../Si-Cehat/src/server/__tests__/push.test.ts`

**Interfaces:**
- Produces:
  - `deviceTokens` table.
  - `initPush(): boolean` (false without credentials).
  - `sendPushToGuardian(guardianId: string, input: {title:string; body:string; data?:Record<string,string>}): Promise<void>`.
  - `POST /api/notifications/devices` (auth, upsert by token).
  - `DELETE /api/notifications/devices` (auth, remove token).
- Consumes: `createNotification` from `services/notifications.ts`.

- [ ] **Step 1: Write failing test** for `maskToken('abcdefgh1234') === '****1234'`.
- [ ] **Step 2: Run `bun test src/server/__tests__/push.test.ts`; expected FAIL.**
- [ ] **Step 3: Implement `push.ts`** with lazy `firebase-admin` init; no-op if no credential; delete invalid tokens. Add `maskToken`.
- [ ] **Step 4: Add `deviceTokens` schema + routes**; validate token length ≥ 20; upsert on conflict.
- [ ] **Step 5: Call `void sendPushToGuardian(...)`** from `createNotification` with `{type, referenceId}` data.
- [ ] **Step 6: Run typecheck + tests; expected PASS.**
- [ ] **Step 7: Verify live without credentials:** register/delete device token returns 200; creating a notification still succeeds.
- [ ] **Step 8: Commit** `feat(notifications): add device tokens and push service`.

---

### Task 4: Mobile push interface (no-op, phase 1)

**Files:**
- Create: `lib/core/services/push_notification_service.dart`
- Modify: `lib/main.dart`
- Modify: `lib/providers/auth_provider.dart` (register/unregister on login/logout)
- Test: `test/push_notification_service_test.dart`

**Interfaces:**
- Produces:
  - `class PushMessage { final String title, body; final String? type, referenceId; }`
  - `class PushNotificationService` with `Future<void> initialize()`, `Future<void> registerDevice()`, `Future<void> unregisterDevice()`, `Stream<PushMessage> get messages`.
  - Default implementation: no-op (logs) until phase 2.

- [ ] **Step 1: Write failing test** for `PushMessage.fromData({'title':'A','body':'B','type':'GAME'})`.
- [ ] **Step 2: Run test; expected FAIL.**
- [ ] **Step 3: Implement the no-op service + `PushMessage` parsing.**
- [ ] **Step 4: Call `initialize()` after login and `unregisterDevice()` on logout** (posting to the new endpoint only when a real token exists; in phase 1 no-op).
- [ ] **Step 5: Run tests + analyze; expected PASS.**
- [ ] **Step 6: Commit** `feat(notifications): add push service seam`.

---

### Task 5: FCM phase 2 (blocked until Firebase config)

**Precondition:** `google-services.json` (Android) and Firebase project credentials available.

**Files:**
- Modify: `pubspec.yaml`, `android/app/build.gradle.kts`, `android/build.gradle.kts`
- Modify: `lib/core/services/push_notification_service.dart`
- Modify: `android/app/src/main/AndroidManifest.xml`

- [ ] **Step 1: Add `firebase_core`, `firebase_messaging`; apply Google services plugin; gate behavior with `const bool.fromEnvironment('PUSH_ENABLED', defaultValue: true)`.**
- [ ] **Step 2: Implement `Firebase.initializeApp()`, permission, token refresh, `POST /api/notifications/devices`.**
- [ ] **Step 3: Foreground messages → `LocalNotificationService.show` channel `general`.**
- [ ] **Step 4: `getInitialMessage()` + `onMessageOpenedApp` → NotificationCenter / Reminder.**
- [ ] **Step 5: Logout → DELETE device token.**
- [ ] **Step 6: Build debug/release + send test message from Firebase Console.**
- [ ] **Step 7: Commit** `feat(notifications): enable FCM push`.

---

### Task 6: Final verification

- [ ] `flutter analyze` → No issues.
- [ ] `flutter test` → all pass.
- [ ] `flutter build apk --debug` and `--release` → success.
- [ ] `cd ../Si-Cehat && bun run typecheck && bun test` → pass.
- [ ] Live: schedule reminder, kill app, verify; device token register/delete; push no-op.
- [ ] Update `docs/playlab-integration-guide.md` notification section if behavior changed.
- [ ] Commit docs.
