# Beranda (S05) UI/UX Remediation Plan

> **For agentic workers:** implement task-by-task, keep the existing Riverpod + `AppColors`/`AppTypography` conventions, and verify with the commands in each task. Steps use checkbox (`- [ ]`) syntax.

**Goal:** Make Beranda (S05) read clearly at first glance, restore the 5-menu hierarchy from the design spec, fix visual defects on the risk card, and bring touch targets, contrast, and semantics up to a usable baseline without changing business logic.

**Scope:** `lib/screens/home/home_screen.dart`, new `lib/screens/home/widgets/*`, `lib/screens/shell/main_shell_screen.dart` (nav bar only), and tests.

**Audience:** Indonesian mothers/guardians, often on mid-range Android devices, sometimes with large system text and low digital confidence.

**Non-goals:** backend/profile error handling, dark mode, nested navigation / bottom-bar persistence on pushed screens, or a full accessibility audit of other screens.

**Constraints:**
- Keep safety copy: default risk state must stay `"Skrining belum tersedia"` (never default to low risk).
- No new packages.
- Keep the 4 bottom-navigation items and their order.
- Keep `MainShellScreen` tab behavior.
- Public widget constructors used by tests should remain stable where practical.

---

## 1. Audit findings

Severity: **Blocker** = visibly broken / misleading; **High** = hurts usability or accessibility; **Medium** = polish or resilience; **Low** = copy/consistency.

| ID | Sev | Area | Finding | Evidence | Fix |
|---|---|---|---|---|---|
| H-01 | Blocker | Visual | Risk card renders an opaque white square inside a rounded pale-green card. The inner block has no radius, so it looks like a layout bug. | `home_screen.dart` risk card: outer `Container(paleGreenBg)` → inner `Container(color: Colors.white)` | One card surface; delete the inner white container |
| H-02 | Blocker | Affordance | The risk card is tappable but has no CTA, chevron, or ripple (opaque children hide the ink). Users cannot tell it opens screening. | `InkWell` wraps opaque `Container`s | `Material(color: paleGreenBg)` + `InkWell` + visible `Lakukan skrining →` row |
| H-03 | Blocker | Accessibility | Risk-title colors fail contrast: `primaryGreen` on white/pale = 2.78:1; `#E6A23C` = 2.19:1. | `riskColor = AppColors.primaryGreen` / `Color(0xFFE6A23C)` | `primaryGreenDark` (4.7:1 on pale), `warningText` (3.5:1), `accentRed` (3.9:1) + status icon |
| H-04 | High | Accessibility | Avatar uses `GestureDetector`; no button semantics, no ripple, no label. | `GestureDetector(onTap: ... MotherProfileScreen)` | `Material` + `InkWell` 48 dp + `Tooltip` + `Semantics(button: true)` |
| H-05 | High | Accessibility | Unread badge is decorative; screen readers only hear "Notifikasi", not the count. | `Stack` + `Positioned` badge | Material `Badge` + `Semantics(label: 'Notifikasi, N belum dibaca')` |
| H-06 | High | Accessibility | Selected bottom-nav color `#4CAF50` on white = 2.78:1 for an 11 px label/icon. | `main_shell_screen.dart` `_buildNavItem` | `primaryGreenDark` (5.1:1), label 12 px, selected semantics |
| H-07 | High | Hierarchy | 9 equal-weight tiles in a 3×3 grid. The spec calls for 5 core menus (3 + 2). Two tiles duplicate entries already in the Edukasi tab. | `home_screen.dart` three `Row`s / 9 `_buildMenuCard` calls; `education_screen.dart` exposes Pustaka + PlayLab | 5 core menus (3+2) + a quieter "Fitur lainnya" list |
| H-08 | High | Visual | "Komunitas" uses `activity.png`, which is a game controller — the same asset as "PlayLab Game". | `activity.png` | Use a people/group icon (or a dedicated asset) |
| H-09 | Medium | Typography | Menu labels are 10 px and hard-code sizes instead of the type scale. Hard to read for the target audience. | `_buildMenuCard` `fontSize: 10` | 12–13 px, token-based, `maxLines: 2`, ellipsis |
| H-10 | Medium | Visual | Menu art mixes watermarked stock, line art, and flat illustration. | `assets/dashboard/*.png` (e.g. watermark in `screening.png`) | One consistent icon treatment (see decision D-02) |
| H-11 | Medium | Layout | Fixed 3-column rows at 320 dp + text scale >1.3 can clip labels. | `Expanded` × 3 with fixed 6 dp padding | `LayoutBuilder`: 3 columns ≥360 dp, 2 columns below; text-scale guard |
| H-12 | Medium | State | `profile.isLoading` is never used on Beranda; no loading feedback while profiles refresh. | `home_screen.dart` ignores `profileProvider.isLoading` | Subtle non-blocking progress while loading |
| H-13 | Medium | Usability | Active-child chip is static even with multiple children; users cannot switch from Beranda. | chip `Container` with no `onTap` | Tappable chip + chevron when `children.length > 1`; static otherwise |
| H-14 | Low | Copy | "Menu" vs "Rencana Menu" is ambiguous. | menu labels | Clarify secondary label with a subtitle |
| H-15 | Low | Navigation | Pushed menu screens hide the bottom bar, although the spec shows Beranda active on S12/S15. | `_push` uses root `Navigator` | Follow-up (nested navigation), not in this plan |

---

## 2. Target design

### Layout

```
┌────────────────────────────────────────┐
│ (avatar)  Halo, Ibu Rina!     (bell•3) │
│           Selamat Pagi                 │
│  [ Anak aktif: Ahmad  ▾ ]              │
│                                        │
│ ┌────────────────────────────────────┐ │
│ │ DIABETES RISK METER                │ │
│ │ ⚠  Skrining belum tersedia         │ │
│ │ Lakukan skrining untuk memahami    │ │
│ │ faktor risiko kebiasaan anak.      │ │
│ │ Lakukan skrining  →                │ │
│ └────────────────────────────────────┘ │
│                                        │
│ Menu Utama                             │
│ ┌────────┐ ┌────────┐ ┌────────┐       │
│ │Skrining│ │  Menu  │ │Reminder│       │
│ └────────┘ └────────┘ └────────┘       │
│ ┌────────┐ ┌────────┐                  │
│ │Konsult.│ │Komunit.│                  │
│ └────────┘ └────────┘                  │
│                                        │
│ Fitur lainnya                          │
│ 🥗  Rencana Menu              Susun >  │
│ 🧮  Kalkulator Nutrisi        Hitung > │
└────────────────────────────────────────┘
```

### Decisions

- **D-01 — Risk card surface:** one `paleGreenBg` card with radius 16. No inner white block. Status is communicated by icon + text + color (never color alone).
- **D-02 — Icon treatment:** use Material icons inside tinted circles for the 5 core menus. This removes the inconsistent/watermarked PNGs and guarantees a consistent look. If the brand wants illustrations, commission a single consistent set later; do not mix the current assets.
- **D-03 — Menu hierarchy:** 5 core menus per `DESIGN_SPEC.md` §S05 `(Skrining, Menu, Reminder, Konsultasi, Komunitas)`. Move `Rencana Menu` and `Kalkulator Nutrisi` into "Fitur lainnya". Remove `Pustaka Edukasi` and `PlayLab Game` from Beranda because the Edukasi tab already exposes them.
- **D-04 — Copy:** keep the spec label `Diabetes Risk Meter`; keep the no-data copy `Skrining belum tersedia`; add the Indonesian CTA `Lakukan skrining`.
- **D-05 — Bottom nav:** keep the custom bar (visual design), but darken the selected green and add semantics.

### Tokens

| Role | Token | Notes |
|---|---|---|
| Card surface | `AppColors.paleGreenBg` | Risk card only |
| Card border | `AppColors.veryLightGreen` | 1 px, optional |
| Risk low / unknown CTA | `AppColors.primaryGreenDark` | 4.7:1 on pale |
| Risk medium | `AppColors.warningText` | 3.5:1 on pale, large text |
| Risk high | `AppColors.accentRed` | 3.9:1 on pale, large text |
| Body on pale | `AppColors.textDark` | 14:1 |
| Secondary text | `AppColors.textSecondary` | only on white |
| Nav selected | `AppColors.primaryGreenDark` | 5.1:1 |
| Nav unselected | `AppColors.textSecondary` | 4.6:1 |
| Core tile label | `AppTypography.titleCard` 12.5, w600 | textDark |
| Secondary title | `AppTypography.titleCard` 14 | textDark |
| Secondary subtitle | `AppTypography.bodySecondary` 12 | textSecondary |

---

## 3. Tasks

### Task 1: Extract home widgets and fix the header

**Files:**
- Create: `lib/screens/home/widgets/home_header.dart`
- Modify: `lib/screens/home/home_screen.dart`
- Modify: `lib/screens/home/widgets/` (new folder)

**Interfaces:**
- Produces: `HomeHeader({required String motherName, required String greeting, required String? activeChildName, required int childCount, required int unreadCount, required VoidCallback onAvatarTap, required VoidCallback onNotificationTap, VoidCallback? onChildTap})`
- Consumes: `profileProvider`, `authProvider`, `notificationProvider`.

- [ ] **Step 1:** Move the header `Row` (avatar, greeting, bell) out of `home_screen.dart` into `HomeHeader`.
- [ ] **Step 2:** Replace the avatar `GestureDetector` with `Material(shape: circle) + InkWell + Tooltip('Buka profil ibu')`. Keep the 48 dp size and green border. Add `Semantics(button: true, label: 'Buka profil ibu')`.
- [ ] **Step 3:** Replace the custom `Stack` badge with `Badge(label: Text(unreadCount > 9 ? '9+' : '$unreadCount'), isLabelVisible: unreadCount > 0, child: IconButton(...))`. Wrap with `Semantics(label: 'Notifikasi, $unreadCount belum dibaca', button: true)` and keep `tooltip: 'Notifikasi'`.
- [ ] **Step 4:** Keep the greeting order (`Halo, ...!` then time-of-day). Use `AppTypography.headingScreen` at 22 and `bodySecondary` at 14.
- [ ] **Step 5:** Make the active-child chip tappable only when `childCount > 1`; add `Icons.expand_more` and `Semantics(label: 'Anak aktif: $name. Ketuk untuk ganti anak.')`. When there is one child, render the same visual without `InkWell`.
- [ ] **Step 6:** Add `const` where possible and avoid rebuilding the greeting on every provider tick (keep `_greetingByHour` pure).

**Acceptance:**
- No `GestureDetector` remains for tappable elements on Beranda.
- Avatar, bell, and chip targets are ≥48 dp.
- Bell semantics include the unread count.

---

### Task 2: Rebuild the Diabetes Risk Meter card

**Files:**
- Create: `lib/screens/home/widgets/risk_meter_card.dart`
- Modify: `lib/screens/home/home_screen.dart`

**Interfaces:**
- Produces: `RiskMeterCard({required String title, required String subtitle, required RiskTone tone, required String ctaLabel, required VoidCallback onTap})`
- Produces: `enum RiskTone { low, medium, high, unknown }`
- Consumes: the existing `latestRiskCategory` mapping in `HomeScreen`.

- [ ] **Step 1:** Keep the current risk mapping (`TINGGI` / `SEDANG` / `RENDAH` / null) and map it to `RiskTone`.
- [ ] **Step 2:** Render one `Material(color: AppColors.paleGreenBg, borderRadius: 16)` → `InkWell(borderRadius: 16)` → `Padding(18)`. Delete the inner `Container(color: Colors.white)`.
- [ ] **Step 3:** Layout: overline `Diabetes Risk Meter` (11, w600, letterSpacing 0.4, `primaryGreenDark`), then a status row (`Icon` + `Text(riskTitle, 22–24, w700)`), then the subtitle (`bodySecondary` 13.5, `textDark`), then a CTA row (`Text(ctaLabel)` + `Icon(Icons.arrow_forward, 16)`) and a trailing `Icons.chevron_right`.
- [ ] **Step 4:** Use `RiskTone` to pick icon + color:
  - low → `Icons.verified`, `primaryGreenDark`
  - medium → `Icons.warning_amber_rounded`, `warningText`
  - high → `Icons.error_outline`, `accentRed`
  - unknown → `Icons.assignment_outlined`, `textDark`
- [ ] **Step 5:** Keep the exact no-data title `Skrining belum tersedia` and subtitle `Ketuk di sini untuk melakukan skrining risiko diabetes anak.`
- [ ] **Step 6:** Keep `onTap: () => _openScreeningFlow(context, ref)` in the parent. Do not move provider reads into the card.

**Acceptance:**
- Risk card renders as a single rounded surface with no square inner block.
- The whole card shows a visible ripple and a CTA/chevron.
- Large status text has ≥3:1 contrast on the card surface; status is not color-only.
- `find.text('Skrining belum tersedia')` still passes.

---

### Task 3: Restore the 5-menu hierarchy

**Files:**
- Create: `lib/screens/home/widgets/home_menu_tile.dart`
- Create: `lib/screens/home/widgets/home_action_tile.dart`
- Modify: `lib/screens/home/home_screen.dart`

**Interfaces:**
- Produces: `HomeMenuTile({required IconData icon, required String label, required Color tint, required VoidCallback onTap})`
- Produces: `HomeActionTile({required IconData icon, required String title, String? subtitle, required VoidCallback onTap})`

- [ ] **Step 1:** Define the 5 core menus exactly as in the spec:
  1. `Skrining` — `Icons.assignment_outlined` → `_openScreeningFlow`
  2. `Menu` — `Icons.restaurant_outlined` → `MenuCatalogScreen`
  3. `Reminder` — `Icons.notifications_none` → `ReminderScreen`
  4. `Konsultasi` — `Icons.chat_bubble_outline` → `ConsultationScreen`
  5. `Komunitas` — `Icons.groups_outlined` → `CommunityScreen`
- [ ] **Step 2:** Render the grid as a `LayoutBuilder` + `Wrap` so the second row is left-aligned (3 + 2) instead of stretched:
  - tile width = `(maxWidth - 2 * 12) / 3`
  - `runSpacing: 12`
  - if `maxWidth < 360` or `MediaQuery.textScalerOf(context).scale(12) > 16`, use 2 columns.
- [ ] **Step 3:** `HomeMenuTile`: `Material` + `InkWell`, min height 96, radius 12, 1 px border `#EEEEEE`, icon 32 inside a 48 dp tinted circle, label 12.5 w600, `maxLines: 2`, `overflow: TextOverflow.ellipsis`, `textAlign: center`.
- [ ] **Step 4:** Add a `Fitur lainnya` section with:
  - `Rencana Menu` / subtitle `Susun menu sehat seminggu` → `MealPlanScreen`
  - `Kalkulator Nutrisi` / subtitle `Hitung kebutuhan gizi` → `NutritionCalculatorScreen`
- [ ] **Step 5:** Delete the `Pustaka Edukasi` and `PlayLab Game` tiles from Beranda. They remain reachable from the Edukasi tab (`education_screen.dart`).
- [ ] **Step 6:** `HomeActionTile`: 56 dp min height, leading icon in a 40 dp tinted circle, title + optional subtitle, trailing `chevron_right`, `MergeSemantics`, `InkWell`.

**Acceptance:**
- Exactly 5 core menu labels appear on Beranda, in 3 + 2 layout.
- `Pustaka Edukasi` and `PlayLab Game` do not appear on Beranda.
- All labels fit at 360 dp and at 320 dp / text scale 1.3 (2-column fallback).
- Every tile is ≥48 dp and announces a button + label.

---

### Task 4: Bottom-navigation accessibility

**Files:**
- Modify: `lib/screens/shell/main_shell_screen.dart`

- [ ] **Step 1:** Extract `_buildNavItem` into a private `_NavItem` widget inside the same file.
- [ ] **Step 2:** Use `primaryGreenDark` for the selected item and `textSecondary` for unselected. Keep the white bar, top border, and shadow.
- [ ] **Step 3:** Set icon size 24 and label `AppTypography.navLabel` at 12 (from 11).
- [ ] **Step 4:** Wrap each item in `Semantics(selected: isSelected, button: true, label: label)` and `InkResponse(containedInkWell: true, highlightShape: BoxShape.rectangle)`. Add `excludeFromSemantics: true` to the child icon/text to avoid duplicate announcements.
- [ ] **Step 5:** Keep the 68 dp bar height and `SafeArea`.

**Acceptance:**
- Selected label/icon contrast ≥4.5:1 on white.
- TalkBack announces "Beranda, selected, button" (and the other tabs unselected).
- Tap target ≥48 dp on 320 dp width.

---

### Task 5: Loading, empty, and text-scale resilience

**Files:**
- Modify: `lib/screens/home/home_screen.dart`
- Modify: `lib/screens/home/widgets/home_header.dart`

- [ ] **Step 1:** Add a non-blocking loading hint: when `profile.isLoading`, show a 2 px `LinearProgressIndicator` under the header (wrapped in `AnimatedSize`/`AnimatedOpacity`, 150 ms). Do not block the page and do not use a permanent skeleton.
- [ ] **Step 2:** Keep the no-child behavior: hide the child chip and let the risk CTA route to `ChildProfileSetupScreen` (existing `_openScreeningFlow` logic).
- [ ] **Step 3:** Ensure no text sits inside a fixed-height box without `Flexible`/`Expanded`. The risk subtitle must wrap; the CTA must not push the card wider than the viewport.
- [ ] **Step 4:** Keep `SingleChildScrollView` and add `physics: const AlwaysScrollableScrollPhysics()` so the page behaves correctly on tall devices (future pull-to-refresh).
- [ ] **Step 5:** Do not add a `RefreshIndicator` in this iteration unless the provider exposes a stable refresh method; note as a follow-up.

**Acceptance:**
- Loading is visible but non-blocking and does not flash on fast loads.
- No `RenderFlex overflow` at 320×568 or text scale 1.3 / 2.0.

---

### Task 6: Tests

**Files:**
- Create: `test/home_screen_ui_test.dart`
- Modify: `test/overflow_test.dart` (add 320 dp case)
- Keep: `test/si_cehat_full_test.dart` (should still pass)

- [ ] **Step 1:** Add a test that Beranda renders the 5 core menus, the risk no-data copy, and the `Fitur lainnya` actions.
- [ ] **Step 2:** Add a semantics test using `tester.getSemantics`:
  - bell includes `Notifikasi` and the unread count,
  - bottom-nav selected item is marked selected,
  - menu tiles are buttons.
- [ ] **Step 3:** Add a tap-target test: every `HomeMenuTile` and `HomeActionTile` is at least 48×48.
- [ ] **Step 4:** Add a 320×568 overflow test at text scale 1.0 and 1.3 using `MediaQuery(data: ... textScaler: TextScaler.linear(1.3), child: ...)`.
- [ ] **Step 5:** Tap test: tapping the risk card from the default provider state opens `ChildProfileSetupScreen`; if the provider already has a complete child, it opens `ScreeningStep1Screen`. Use a `ProviderScope` override if needed.
- [ ] **Step 6:** Run:
  ```bash
  flutter test test/si_cehat_full_test.dart test/overflow_test.dart test/home_screen_ui_test.dart
  ```
  Expected: all pass.

**Acceptance:**
- New tests fail before the change and pass after.
- Existing `S05 Beranda renders risk meter default & 5 main menus` test still passes.

---

### Task 7: Validation and manual QA

- [ ] **Step 1:** `dart format lib/screens/home lib/screens/shell test`
- [ ] **Step 2:** `flutter analyze` → 0 errors, no new warnings.
- [ ] **Step 3:** `flutter test` (full suite) → green.
- [ ] **Step 4:** Manual checks on an Android emulator:
  - 320×568, 360×800, 412×915.
  - System font scale 1.0, 1.3, 2.0.
  - TalkBack: avatar, bell, child chip, risk card, 5 tiles, 2 action tiles, bottom nav.
  - Ripple visibility on every tappable surface.
  - Risk card states: no data, low, medium, high (temporarily set `latestRiskCategory` in a test fixture — do not ship fake risk data).
- [ ] **Step 5:** Screenshot before/after for the PR description.

---

## 4. Acceptance criteria

| AC | Criterion |
|---|---|
| AC-01 | Beranda shows the greeting, the safety risk card, 5 core menus in 3 + 2, and 2 secondary actions. |
| AC-02 | No nested white square in the risk card; single rounded surface; visible CTA + chevron. |
| AC-03 | Default risk copy remains `Skrining belum tersedia`; no screen defaults to low risk. |
| AC-04 | All text ≥4.5:1 (normal) / ≥3:1 (large); status is icon + text + color. |
| AC-05 | Every tappable element is ≥48 dp and has button semantics. |
| AC-06 | No overflow at 320 dp or text scale 1.3 / 2.0. |
| AC-07 | Bottom nav selected state is distinguishable and announced as selected. |
| AC-08 | `flutter analyze` clean; existing + new tests pass. |
| AC-09 | No new dependencies; `AppColors`/`AppTypography` reused. |

---

## 5. Verification commands

```bash
dart format lib/screens/home lib/screens/shell test
flutter analyze
flutter test test/si_cehat_full_test.dart test/overflow_test.dart test/home_screen_ui_test.dart
flutter test
```

---

## 6. Risks and follow-ups

- **R-01 — Icon direction (D-02):** Switching from PNG illustrations to Material icons changes the visual identity. If brand wants illustrations, the PNGs need a consistent, licensed set; do not reuse the watermarked `screening.png`.
- **R-02 — Removing home shortcuts (D-03):** `Pustaka Edukasi` and `PlayLab Game` remain in the Edukasi tab, so no functionality is lost. Confirm the product owner accepts one fewer tap from Beranda.
- **R-03 — Bottom-bar persistence (H-15):** Keeping the bottom bar on pushed menu screens requires nested navigation or shell routes. Treat as a separate navigation task.
- **R-04 — Profile errors:** `ProfileProvider` swallows remote errors and falls back to local data. A user-facing "data lokal / gagal sinkron" state is out of scope but should be planned separately.
- **R-05 — Safety copy:** Any risk visualization must stay non-medical. Do not add a percentage, score, or diagnosis to Beranda.
