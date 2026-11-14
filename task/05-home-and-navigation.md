# 05 — Home & Navigation

## Context

`MainShellScreen` (`lib/screens/shell/main_shell_screen.dart`) hosts a 4-tab
bottom navigation via `IndexedStack`: Home (S05), Tracker (S11), Edukasi (S15),
Profil (S06). `HomeScreen` (`lib/screens/home/home_screen.dart`) renders the
greeting header, the default risk meter ("Skrining belum tersedia"), the
nutrition daily card, and the 5 main menu tiles (Skrining, Menu, Reminder,
Konsultasi, Komunitas). Notification-tap routing is centralized in
`NotificationNavigation` (`lib/core/services/notification_navigation.dart`),
which uses a global `navigatorKey` and queues payloads that arrive before the
shell mounts.

## Findings / Integration Issues

### P1 — Bottom nav label diverged from spec ("Home" vs "Beranda")
`main_shell_screen.dart:53` renders `AppNavItem(..., label: 'Home')`, while
DESIGN_PLAN/PRD (S05) and the tests (`si_cehat_full_test.dart:39`) expect
`"Beranda"`. This is the direct cause of test failure #1. Decide which is
canonical and sync UI + tests.

### P1 — Persistent bottom nav differs from DESIGN_PLAN routing rules
DESIGN_PLAN §5 says the bottom bar shows only on S05/S06/S07/S08/S12/S15 and
**not** on S11 (Tracker). The implementation makes Tracker a permanent tab. This
is likely an intentional consolidation, but it contradicts the reference routing
and AC-02 ("bottom bar does not leak to S11"). Must be confirmed as accepted
product decision, otherwise it's a spec mismatch.

### P2 — Notification-tap routing types are incomplete
`NotificationNavigation.routeNameForPayload` (`notification_navigation.dart:27-42`)
maps `REMINDER` → reminder screen and `CONSULTATION/GAME/EDUCATION/SYSTEM` →
notification center. A `GAME` completion tap therefore opens the notification
center, not the PlayLab score/result context; a `GAME` payload carrying a
`sessionId` has no deep-link handling.

### P2 — Risk meter default vs live data
Home default risk is "Skrining belum tersedia" (correct per PRD FR-04). Verify
that a completed (simulated) screening updates the meter without ever presenting
the simulation as a real clinical result (FR-05 GATED).

## Requirement

- FR-04: home with risk summary + 5 main menus; default risk must NOT be
  auto-"low".
- AC-02: bottom nav visibility rules.
- AC-03: safety/disclaimer states.
- NFR-08: tap targets ≥48dp, semantics, not color-only.

## QA Checklist (manual)

| ID | Scenario | Steps | Expected |
| --- | --- | --- | --- |
| HOME-01 | Greeting + default risk | Launch → home | "Halo, Ibu Rina!"; risk meter shows "Skrining belum tersedia" |
| HOME-02 | 5 main menus | Home | Skrining, Menu, Reminder, Konsultasi, Komunitas tiles present |
| HOME-03 | Menu navigation | Tap each of the 5 tiles | Correct destination opens |
| HOME-04 | Bottom nav labels | Home | Tabs match accepted spec ("Home" vs "Beranda" — resolve open question) |
| HOME-05 | Tab switching | Tap Tracker/Edukasi/Profil | Content switches; state preserved via IndexedStack |
| HOME-06 | Notification deep-link | Send `type=REMINDER` push → tap | Opens Reminder screen; `type=GAME` → notification center (verify intended) |
| HOME-07 | Notification before shell ready | Cold start from notification tap | Payload queued and consumed after shell mounts (no lost tap) |

## Open questions

1. Is `"Home"` or `"Beranda"` the canonical bottom-nav label? (Tests and
   DESIGN_PLAN say "Beranda"; UI says "Home".)
2. Is the 4-tab persistent shell (Tracker included) an accepted product change
   over DESIGN_PLAN's per-screen bottom-bar rules?
3. Should `GAME` notification taps deep-link to PlayLab result rather than the
   notification center?

## Out of scope

- Visual pixel parity with the PDF beyond functional layout (AC-01 covers it
  separately).
- Gamification/avatars (explicitly excluded from mobile baseline, PRD).
