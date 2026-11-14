# REDESIGN_SPEC_SI_CEHAT.md — si_cehat_mobile × "Calm Sage"

> Companion to `DESIGN_TOKENS.md` (the token source of truth: colors, type, spacing, radius, component specs).
> This file adapts that system to **si_cehat_mobile**: screen-by-screen layout, content/microcopy adjustments, and the old→new mapping.
> Scope: **visual redesign only**. Do NOT change business logic, data models, API calls, routes, or feature names.

---

## 0. About the target app

- App: `si_cehat_mobile` — child health companion for parents (Ibu): **diabetes-risk screening, child nutrition, meal plans, growth tracker, education, family profile**.
- Language: Bahasa Indonesia. Audience: parents; tone warm, reassuring, non-clinical, never alarming.
- Current look (to be replaced): Material green (`#2E7D32`, `#4CAF50`), light-gray fills (`#F1F3F4`), pure white background, Poppins-like font, default Material widgets, low visual hierarchy.
- Navigation: bottom tabs **Home · Tracker · Edukasi · Profil** (4 tabs, keep). Active tab already uses an icon+label pill — keep the pattern, restyle it.
- Likely stack: Flutter (verify in repo; if not Flutter, port tokens to the actual stack).

---

## 1. Token cheat-sheet (full detail in DESIGN_TOKENS.md)

```
primary        #4A6E54     primary-soft   #EAF4F0     primary-soft-2 #DFF0EA
border         #D9E7E2     divider        #E8EFEB
bg (page)      #FFFCF6     surface        #FFFFFF
text           #1D2B29     text-muted     #727A77     placeholder    #8A8F93
danger-bg      #FADDDD     danger         #C72928
warning        #F5C16C     warning-bg     #FFF8EC
success        #6FCB8A     due/info       #8E97B7
radius: header 0 0 28 28 · xl 24 · lg 18 · md 14 · sm 10 · pill 999
font: Plus Jakarta Sans (fallback Inter/system)
elevation: flat; 1px border #D9E7E2; soft shadow only on FAB/nav
```

### 1.1 New tokens derived for this app (not in the original system)

Risk levels (diabetes risk meter, badges, summary strips). Same pastel-bg + deeper-fg logic as the chip pairs.

| Token | Background | Foreground | Border |
|---|---|---|---|
| `risk-low` (Risiko Rendah) | `#EAF4F0` | `#4A6E54` | `#D9E7E2` |
| `risk-medium` (Risiko Sedang) | `#FFF8EC` | `#B45309` | `#F5C16C` |
| `risk-high` (Risiko Tinggi) | `#FADDDD` | `#C72928` | `#F3B9B9` |

Choice chip (form option selector, new component — see §3.3):
- unselected: bg `#FFFFFF`, border `1px #D9E7E2`, text `#1D2B29` 500
- selected: bg `#DFF0EA`, border `1.5px #4A6E54`, text `#4A6E54` 700

Nutrition macro tags: text `#727A77` caption; energy value (kkal) `#4A6E54` 700.

### 1.2 Old → new mapping (find & replace guide)

| Current (si_cehat) | New token |
|---|---|
| `#2E7D32` (primary green, buttons, active text) | `primary #4A6E54` |
| `#4CAF50` (tab pill, bright CTA, slider) | `primary #4A6E54` (never bright green) |
| `#E8F5E9`, `#F1F8E9` (light green fills) | `primary-soft #EAF4F0` |
| `#E0F7FA` (cyan banner) | `primary-soft-2 #DFF0EA` |
| `#FFF8E1` (cream-yellow) | `warning-bg #FFF8EC` |
| `#E3F2FD` (light blue chip) | chip teal `#DFF0EA` / `#16685C` |
| `#F3E5F5` (purple placeholder) | chip neutral `#F2F4F2` |
| `#FFEBEE` + red text (badges) | see §3.9 (do not use red for non-critical badges) |
| `#F1F3F4`, `#F4F6F8` (gray input/chip fills) | white surface + `1px #D9E7E2` border (inputs), `primary-soft` (inactive tabs) |
| `#212121` (text) | `text #1D2B29` |
| `#E0E0E0` (borders/dividers) | `border #D9E7E2` / `divider #E8EFEB` |
| `#FFFFFF` page background | `bg #FFFCF6` (cards stay white) |
| Poppins / default font | Plus Jakarta Sans |

---

## 2. Global shell

### 2.1 Screen types
1. **Tab root screens** (Home, Tracker, Edukasi, Profil): green rounded header (`radius 0 0 28 28`) with large title + caption subtitle, optional right illustration, content on cream.
2. **Pushed detail screens** (Rencana Menu, Skrining Risiko Diabetes, Nutrisi Anak): **compact green header** (≈ 72–88px) with circular ghost back button (white 20% tint or white circle with primary icon), centered/left title in white 700 18–20px, trailing action icons as white-tint circle buttons. No bottom nav on wizard/form screens if it is already hidden today (keep current behavior).
3. Status bar area: header color extends under the status bar.

### 2.2 Bottom navigation (4 tabs)
Per DESIGN_TOKENS §5.2: white bar, 1px top border `#D9E7E2`, inactive icon+label `#727A77`, **active = primary pill with icon and label inline in white**. Icons (outline, Lucide-like): Home → `home`, Tracker → `trending-up`, Edukasi → `book-open`, Profil → `user`. Replace the current active light-green pill.

### 2.3 FAB (optional)
Round 46px primary FAB (right 16, above nav) linking to the existing **Konsultasi** feature, only on Home/Tracker/Edukasi. Skip if the app already has a conflicting floating element. Hidden on forms.

---

## 3. Screen specs

### 3.1 Home
Current: avatar + "Halo, test!" + "Selamat Malam" + bell with red badge; cyan banner with face icon; "Diabetes Risk Meter" card; "Menu Utama" 3-col grid; "Fitur lainnya" list.

New:
- **Header (green):** left: circular avatar 44px (white ring) + greeting stack: caption "Selamat Malam" (header-subtitle color) over "Halo, {nama}!" (display 22–24px white 700). Right: bell as white-tint circle 40px; unread badge = 16px danger dot `#C72928` with white 10px number, offset top-right.
- **Child summary banner** (the cyan banner): white card overlapping header bottom by ~24px, radius 18, border; left 48px mint avatar chip with `smile` icon, title child name 700, caption age · weight · height muted. Keep whatever data it shows today.
- **Diabetes Risk Meter card:** white card, radius 24, border; label "DIABETES RISK METER" in micro 700 uppercase letter-spacing .6 `primary`; big status "Risiko Rendah" in hero 22px 700 with leading 40px circular check icon on `risk-low` bg; one-line description 12px muted; footer link "Lakukan skrining →" primary 700 (or pill ghost button). Card tint follows risk level (`risk-low/medium/high` bg tint on a thin left accent or on the status chip — keep card itself white for readability).
- **Menu Utama:** section title h2 + caption subtitle. 3-column grid, gap 12, tiles = white card radius 18, border, padding 12, centered 48px rounded-square icon chip (radius 14) + 12px 600 label (2 lines max). **Always render as a clean 3-col grid; last row may be left-aligned.** Chip colors:

| Tile | Chip bg / glyph | Icon |
|---|---|---|
| Skrining | `#EAF4F0` / `#4A6E54` | clipboard-list |
| Menu | `#FFF1E8` / `#B45309` | utensils |
| Reminder | `#DFF0EA` / `#16685C` | bell |
| Konsultasi | `#FFE2E2` / `#DB2777` | message-circle |
| Komunitas | `#EAF4F0` / `#4A6E54` | users |

- **Fitur lainnya:** grouped list card (DESIGN_TOKENS §6.6): leading 36px chip, title 13px 600, caption muted, trailing chevron `#7F968D`. Rows separated by hairlines.

### 3.2 Rencana Menu
Current: summary card with sync button, amber "Meal Timing" card, green "Fokus Nutrisi" card, chip tabs, date row, meal cards with photo.

New:
- Compact green header: back, title "Rencana Menu", trailing icons (resep `book-open`, refresh) as white-tint circles.
- **Plan summary card:** white, radius 24, border. Top row: 44px mint chip (`smile`) + title "Rencana Menu: {nama}" 15px 700 + target kalori line in `primary` 12px 600. Below: risk strip (full-width pill-ish bar radius 14, `risk-low` tokens, shield icon + text). Then outlined full-width pill button "Sinkronkan {n} Jadwal Makan ke Pengingat" (white bg, `1px primary` border, primary text 700, leading `refresh-cw`).
- **Meal Timing & Gizi Seimbang:** info card `warning-bg #FFF8EC`, border `#F5C16C` at 60% opacity, radius 18; leading 40px circle `#F5C16C` with shield/clock glyph `#1D2B29`; title 13px 700; text 12px muted.
- **Fokus Nutrisi:** mint container (`primary-soft`, radius 24, no border): title 13px 700, then 3 mini items in a row, each = 28px white circle icon chip + 11px caption (2 lines).
- **Plan tabs** ("Menu 1 Hari / Menu 7 Hari / Smart Traditional Meal Plan"): horizontally scrollable pills; active solid primary white 700, inactive `primary-soft` text primary; height 36, gap 8.
- **Date row:** leading `calendar` icon primary + date 13px 700 `text`; right caption "{n} Jadwal Makan" muted.
- **Meal card:** white, radius 18, border, padding 12. Left: photo thumbnail 72×72, radius 14, cover. Right column: row 1 = meal-type label (icon + text, 11px 600 `primary`) + optional chip "Ada Resep" (`primary-soft`, primary text, 10px 700, radius pill) + right-aligned time chip (`#F2F4F2`, radius 10, 11px 600) + chevron; row 2 = dish name 13px 700 `text` (max 2 lines); row 3 = nutrition caption: "{kkal} kkal" in `primary` 700 · "Prot x g · Serat y g" muted 11px; hairline divider; row 4 = right-aligned actions: **Ganti** (ghost pill, `repeat` icon) and **Catat** (mint pill `primary-soft`, primary text, `bookmark-plus` icon), both 28px high.

### 3.3 Skrining Risiko Diabetes (wizard)
Current: "Langkah 1 dari 3", title, description, 3 dropdown fields, 3 chip groups, CTA; weight bottom-sheet picker with slider.

New:
- Compact green header (back + title). Under it, **step indicator**: caption "Langkah 1 dari 3" `primary` 700 + 3-segment progress bar (segments height 6, radius pill, active `primary`, inactive `primary-soft`).
- Step title h2 700; description 12px muted.
- **Form fields:** label 13px 600 `text`; control = white, radius 14, border `1px #D9E7E2`, height 48, value 14px 500, trailing `chevron-down` `#7F968D`. Focus: border `primary` 1.5px. No gray fills.
- **Choice chips** (Riwayat Diabetes Keluarga, Frekuensi Minuman Manis, Aktivitas Fisik): see §1.1 choice chip; row of equal-width chips, gap 8, height 40, radius pill; wrap to next line if > 3.
- **CTA** "Analisis Risiko Diabetes": primary pill, full width, 48px, fixed at bottom with safe-area padding on cream background.
- **Bottom sheet (picker):** white, top radius 24, grab handle 36×4 `#D9E7E2`, title 13px 600 muted centered, selected value hero 28px 700 `primary`, slider (track 6px `primary-soft` / active `primary`, thumb 22px white with 3px `primary` ring), min/max captions muted, CTA "Pilih Nilai Ini" primary pill. Scrim `rgba(29,43,41,.45)`.

### 3.4 Tracker
Current: tabs (Tumbuh Kembang / Aktivitas), weight line chart, 2 stat cards, add-measurement CTA, history list with delete icon.

New:
- Tab root green header "Tracker" + caption (e.g. "Pantau tumbuh kembang anak").
- Segmented pills (DESIGN_TOKENS §6.8): active primary, inactive `primary-soft`.
- **Chart section:** h2 "Grafik BB (Kg)" + caption "{n} pengukuran tercatat" and ghost pill "Riwayat" at right if applicable. Chart sits in a **mint container** (`primary-soft`, radius 24, padding 12) holding a white card (radius 18) with the chart: line `primary` 2.5px, points hollow (white fill, 2px primary stroke), gridlines `#E8EFEB` 1px dashed, axis labels 10px muted. Empty state per §6.15.
- **Stat cards (2-up):** white, radius 18, border; 32px icon chip (weight → mint/primary, height → peach `#FFF1E8`/`#B45309`), label caption muted, value 20px 700 `text`.
- CTA "+ Tambah Pengukuran": primary pill full width.
- **History list:** "Riwayat Pengukuran" h2 + caption. Row card white radius 18 border: leading 40px mint chip with `calendar`, date 13px 700, source chip (e.g. "Mandiri": `primary-soft` bg, primary text, 10px 700), caption "BB: 22,0 kg · TB: 120 cm", trailing delete as 32px round button, bg `danger-bg`, glyph `danger` (destructive allowed here). Confirm dialog before delete if not already present.

### 3.5 Edukasi
Current: "Edukasi" title with book icon, PlayLab Game banner (rainbow gradient), tabs Video/Podcast/Quiz/Pustaka, video list with red "Preview Video" badges.

New:
- Tab root green header "Edukasi" + caption "Belajar sehat bersama si Kecil", right-side illustration slot.
- **PlayLab Game banner:** flat `primary-soft-2` card radius 24 (no rainbow gradient), 1px border; left 56px circle white with `utensils` icon primary; chip "PlayLab Game" (primary bg, white, 10px 700); stars in `#F5C16C`; title 14px 700 "Piring Sehat Nimbo"; caption "Skor Terakhir: 100/100 · +75 XP" `primary` 600. Two buttons side by side: "Lihat Nilai" (ghost outline pill) and "Main Lagi" (primary pill).
- **Content tabs** (Video/Podcast/Quiz/Pustaka): horizontally scrollable pill row; active primary, inactive `primary-soft`.
- **Content item card:** white, radius 18, border, padding 10. Thumbnail 96×64 radius 14 (placeholder = `#F2F4F2` bg with `play-circle` glyph `#8A8F93`; do NOT use purple). Title 13px 700 (2 lines, ellipsis). Meta row: `clock` + "{n} Menit" 11px muted. "Preview Video" badge → neutral/warning pastel (`#FFF1E8` bg, `#B45309` text), not red.
- Empty/loading: skeleton blocks `#EAF4F0`, radius 14.

### 3.6 Profil
Current: big family illustration in a green circle, "Halo, test!", two cards (Profil Ibu, Profil Anak), Pengaturan group, red "Keluar Akun".

New:
- Tab root green header "Profil Saya" + caption "Kelola data ibu dan anak dalam satu tempat". Keep the family illustration as a 72px avatar-like circle on a `primary-soft` profile card (DESIGN_TOKENS §6.17) with name + email/ID if available.
- "Profil Ibu" / "Profil Anak": grouped list card rows with chips (Ibu → peach `#FFF1E8`/`#B45309` `user`; Anak → mint `#DFF0EA`/`#16685C` `smile`), title 13px 700, caption muted, chevron.
- Pengaturan: grouped list (Ganti / Tambah Anak → `users`; Informasi Privasi & Data → `shield-check`), hairline dividers, chevrons `#7F968D`.
- "Keluar Akun": standalone destructive pill (§6.3), full width, below the list — not inside the group. Version caption at the bottom.

### 3.7 Nutrisi Anak
Current: tabs Hitung Cepat / Susun Asupan; form card with search, amount + unit, cooking method, CTA; filter icon top-right.

New:
- Compact green header (back, "Nutrisi Anak", trailing `sliders-horizontal` icon in white-tint circle).
- Segmented pills (active primary, inactive `primary-soft`).
- Helper caption 12px muted.
- **Form container:** mint container radius 24 padding 16 with white inner fields: search field (leading `search` icon, radius 14, border `#D9E7E2`, placeholder `#8A8F93`), two-column row Jumlah + Satuan (dropdown), full-width dropdown Cara pengolahan. Labels 12px 600 with small leading icons in `primary`.
- CTA "Hitung Nilai Gizi": primary pill, 48px, leading `calculator` icon.
- **Result card (after calculation):** white card radius 24 border; title food name + portion; big energy "kkal" hero `primary`; macro rows as 3–4 small tiles (Karbohidrat, Protein, Lemak, Serat) = mint tiles radius 14 with value 15px 700 and caption; add "Tambahkan ke Asupan" primary pill + ghost "Hitung Lagi".

---

## 4. Content & microcopy guidelines (adapt, don't rewrite features)

- Keep every existing feature name, route, label that carries meaning (Skrining, Rencana Menu, Tracker, Edukasi, Nutrisi Anak, PlayLab Game, Smart Traditional Meal Plan).
- Greeting: "Halo, {nama}!" + time-of-day caption (Selamat Pagi/Siang/Sore/Malam). Parent-facing helper text may address the user as "Bunda"; refer to the child by name when available instead of "Anak (test)".
- Tone: reassuring + actionable. Examples:
  - Risk low: "Pertahankan pola hidup sehat si Kecil setiap hari."
  - Risk medium: "Yuk perbaiki pola makan dan aktivitas si Kecil. Lakukan skrining ulang bulan depan."
  - Risk high: "Disarankan berkonsultasi dengan tenaga kesehatan. Konsultasi sekarang →" (calm wording, no alarm words, no red full-screen).
- Empty states: friendly one-liner + CTA, e.g. "Belum ada data berat. Tambah pengukuran untuk melihat grafik."
- Numbers: Indonesian formatting (`22,0 kg`, `1.500–1.700 kkal`), consistent units.
- Date format: "Kamis, 12 November 2026".
- Illustrations: flat vector, pastel sage/cream/blush/peach; child-friendly and family-oriented (parent + child), no medical/clinical imagery. Slots: Home banner, tab root headers, Profil, empty states, PlayLab banner.
- Medical disclaimer (if present): caption 11px muted, never red.

---

## 5. Flutter implementation notes (if the repo is Flutter)

Create/centralize (names are suggestions; follow repo conventions):
- `lib/core/theme/app_colors.dart` — all color tokens + risk + chip pairs.
- `lib/core/theme/app_text_styles.dart` — type scale (use `google_fonts` Plus Jakarta Sans, or bundle as asset and declare in `pubspec.yaml`).
- `lib/core/theme/app_spacing.dart` / `app_radius.dart`.
- `lib/core/theme/app_theme.dart` — `ThemeData(useMaterial3: true, colorScheme: ColorScheme.fromSeed(seedColor: AppColors.primary).copyWith(primary: AppColors.primary, surface: AppColors.surface, onSurface: AppColors.text, outline: AppColors.border, error: AppColors.danger), scaffoldBackgroundColor: AppColors.bg, ...)` with component themes: `ElevatedButtonTheme` / `FilledButtonTheme` (pill, 48 high), `OutlinedButtonTheme`, `InputDecorationTheme` (white fill, radius 14, 1px border, focus 1.5px primary), `CardTheme` (white, radius 18, border, elevation 0), `NavigationBarTheme`/custom bottom nav, `SliderTheme`, `ChipTheme`, `BottomSheetTheme` (top radius 24), `DividerTheme` (`#E8EFEB`).
- Shared widgets (build once, reuse everywhere): `AppHeader` (tab + compact variants), `AppBottomNav`, `AppCard`, `MintSection`, `IconChip`, `StatusBadge`, `RiskBadge`, `ChoiceChipGroup`, `SegmentedPills`, `PrimaryButton`, `GhostButton`, `DestructiveButton`, `AppListGroup`/`AppListTile`, `EmptyState`, `StepProgress`, `SectionTitle`.
- Remove hard-coded colors/styles (`Color(0xFF2E7D32)`, `Colors.green`, inline `TextStyle`) from screens; screens must consume tokens/shared widgets only.
- Disable Material default ink-heavy effects where they clash (e.g. use subtle `InkWell` with `primary-soft` splash).
- Support text scale up to 1.3 without overflow; minimum tap target 44×44.

---

## 6. Accessibility

- Contrast: text `#1D2B29` on cream/white passes AA; white on `#4A6E54` passes AA for ≥ 13px bold. Do not place `#727A77` text below 11px or on `#EAF4F0` for essential info.
- Never rely on color alone for risk level — always pair color with text and icon.
- Tap targets ≥ 44px; add semantic labels to icon-only buttons (back, bell, delete, refresh).

---

## 7. Definition of Done

1. No leftover old palette values (search for `2E7D32`, `4CAF50`, `E8F5E9`, `F1F8E9`, `E0F7FA`, `F1F3F4`, `F4F6F8`, `Colors.green`, `Colors.red`).
2. All 7 screens in §3 match the layout rules; shared widgets used instead of per-screen styling.
3. App builds and runs with no new analyzer warnings; no functional regressions (navigation, forms, calculations, data persistence unchanged).
4. No text overflow on a 360×640 viewport and at text scale 1.3.
5. Delivered with a short change log: files created, files modified, deviations from this spec and why.
