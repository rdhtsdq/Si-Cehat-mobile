# DESIGN_TOKENS.md — "Calm Sage" Mobile UI

> Instruction for AI agents: apply this design system to the target app. Use the tokens below as the single source of truth. Do not invent new colors, radii, or fonts. If something is missing, derive it from the closest token.
>
> **Confidence legend:** `[M]` = measured from pixel sampling of screenshots (exact hex). `[E]` = estimated visually (verify against the source app if possible).

---

## 1. Concept & Mood

- Domain: maternal / family health companion (screening, learning, reminders, profile).
- Mood: calm, soft, trustworthy, feminine-friendly, warm. Not clinical, not loud.
- Style keywords: sage green + warm cream, pill buttons, big rounded cards, flat (almost no shadows), thin mint borders, soft pastel icon chips, friendly flat illustrations in header.
- Language of UI copy: Bahasa Indonesia, warm tone, addresses the user as "Bunda".
- Layout: mobile-first, single column, ~400px design width, bottom tab bar with 5 tabs, floating action button (FAB) bottom-right.

---

## 2. Color Tokens

### 2.1 Core palette

| Token | Hex | Role |
|---|---|---|
| `--color-primary` | `#4A6E54` [M] | Brand sage green: header bg, primary buttons, active nav pill, FAB, selected day, progress fill, links/highlights |
| `--color-primary-soft` | `#EAF4F0` [M] | Mint tint: section containers, icon chips, inactive tab pills, profile card bg, input surface wrapper |
| `--color-primary-soft-2` | `#DFF0EA` [M] | Slightly deeper mint: icon chip variant (safety/heart icons) |
| `--color-border` | `#D9E7E2` [M] | 1px borders on cards, ghost buttons, outline chips |
| `--color-bg` | `#FFFCF6` [M] | App background (warm cream, NOT pure white) |
| `--color-surface` | `#FFFFFF` [M] | Cards, list rows, inputs, nested cards on mint containers |
| `--color-on-primary` | `#FFFFFF` [M] | Text/icons on primary green |

### 2.2 Text

| Token | Hex | Role |
|---|---|---|
| `--color-text` | `#1D2B29` [M] | Headings, names, primary labels (dark green-black, not pure black) |
| `--color-text-muted` | `#727A77` [E] | Subtitles, helper text, captions |
| `--color-text-placeholder` | `#8A8F93` [M] | Input placeholders, disabled icon glyphs |
| `--color-text-accent` | `#4A6E54` [M] | Time labels, small emphasized IDs/codes, ghost-button text |
| `--color-header-subtitle` | `#E3F0E6` [E] | Light subtitle text on green header (≈ 85% white) |

### 2.3 Semantic / accent

| Token | Hex | Role |
|---|---|---|
| `--color-danger-bg` | `#FADDDD` [M] | Destructive button bg (e.g. "Keluar" / logout) |
| `--color-danger-text` | `#C72928` [M] | Destructive text + icon |
| `--color-warning` | `#F5C16C` [M] | "Appointment/Periksa" marker, outlined date border |
| `--color-warning-bg` | `#FFF8EC` [M] | Fill for warning-highlighted date cell |
| `--color-success` | `#6FCB8A` [E] | "Selesai/Done" marker (light green dot) |
| `--color-info-due` | `#8E97B7` [M] | "HPL/Due date" marker (muted periwinkle) — in screenshot legend appears red-ish; treat as a distinct 4th status color |
| `--color-status-red` | `#C72928` [M] | Alternate red for critical dot/legend |

### 2.4 Icon-chip pastel pairs (background → glyph)

Used for list-row leading icons (rounded-square chips, ~36px).

| Chip | Background | Glyph color |
|---|---|---|
| Neutral mint | `#EAF4F0` [M] | `#4A6E54` [M] |
| Teal | `#DFF0EA` [M] | `#16685C` [M] |
| Rose | `#FFE2E2` [M] | `#DB2777` [M] (also reds like `#E11D48` [E]) |
| Peach / orange | `#FFF1E8` [M] | `#B45309` [E] |
| Disabled / unknown | `#F2F4F2` [M] | `#8A8F93` [M] |

### 2.5 Color usage rules

1. Page background is always `--color-bg` (cream). Cards sitting on the page are `--color-surface` (white) with a 1px `--color-border`.
2. Big grouped containers (e.g. list group, calendar block, weight block) use `--color-primary-soft` with **no border**; items inside them are white cards.
3. Only ONE strong green element dominates a viewport region: header, or primary CTA. Everything else is soft mint/white.
4. Never use pure black (`#000`) for text; never use pure white for page background.
5. Red is only for destructive/critical actions. Warm amber is only for calendar/appointment emphasis.

---

## 3. Typography

- **Font family:** `Plus Jakarta Sans` [E] (geometric humanist sans; verify visually). Fallback: `Inter, system-ui, -apple-system, 'Segoe UI', Roboto, sans-serif`.
- Weights used: 400 (body), 500 (labels), 600 (list titles), 700 (headings, buttons).

| Token | Size / Line-height | Weight | Usage |
|---|---|---|---|
| `--text-display` | 24px / 30px [E] | 700 | Screen title in header ("Profil Saya", "Pengingat") |
| `--text-hero` | 22px / 28px [E] | 700 | Hero number/phrase inside a card ("Minggu ke-10") |
| `--text-h2` | 15–16px / 22px [E] | 700 | Section heading ("Data Saya", "Jadwal periksa") |
| `--text-title` | 13px / 18px [E] | 600–700 | Row titles, card titles, button labels |
| `--text-body` | 12px / 18px [E] | 400–500 | Body text, descriptions |
| `--text-caption` | 11px / 15px [E] | 400 | Section subtitles, meta ("1× sehari · Tablet") |
| `--text-micro` | 10px / 14px [E] | 500 | Nav labels, calendar weekday header, chips, legend |

Rules:
- Header subtitle is `--text-caption` in `--color-header-subtitle`.
- Primary button label: `--text-title`, weight 700, white, centered.
- Numbers (days, weeks, kg) may use `font-variant-numeric: tabular-nums`.

---

## 4. Spacing, Radius, Elevation

### 4.1 Spacing scale (4px base) [E]

`4, 8, 12, 16, 20, 24, 32`

- Screen horizontal padding: **16px**
- Gap between sections: **20–24px**
- Gap between section title and content: **8–12px**
- Card inner padding: **12–16px**
- List row padding: **10–12px** vertical, **12px** horizontal
- Gap between stacked list rows inside mint group: **8px**

### 4.2 Radius [E]

| Token | Value | Usage |
|---|---|---|
| `--radius-header` | `0 0 28px 28px` | Header bottom corners |
| `--radius-xl` | 24px | Big mint containers, hero cards |
| `--radius-lg` | 18px | White cards, list rows, grouped cards |
| `--radius-md` | 14px | Inputs, textareas, icon chips, calendar day cells |
| `--radius-sm` | 10px | Small chips, tags |
| `--radius-pill` | 999px | Buttons, tab pills, badges, nav active pill, round icon buttons |

### 4.3 Elevation

- Default: **flat**. No box-shadow on cards; separation comes from color + 1px border.
- FAB and bottom nav: very soft shadow only, e.g. `0 4px 12px rgba(29,43,41,.15)` [E].
- Borders: `1px solid var(--color-border)`.

---

## 5. Layout Structure

### 5.1 Screen anatomy

```
┌──────────────────────────────┐
│ HEADER (primary green)       │  rounded bottom 28px
│  Title (display, white)      │  optional illustration on the right
│  Subtitle (caption)          │
├──────────────────────────────┤
│ cream background             │
│  Section title + subtitle    │
│  [mint container / cards]    │
│  ...                         │
│                       (FAB)  │  fixed bottom-right, above nav
├──────────────────────────────┤
│ BOTTOM NAV (white)           │  5 tabs, active = green pill
└──────────────────────────────┘
```

- Header height: ~100–120px; padding 16px; title at top-left; optional flat illustration (≈ 90px wide) anchored to the right, slightly overflowing downward. Screens with a widget (e.g. progress card) let a white card **overlap the header's bottom edge**.
- Content scrolls under header; bottom padding ≥ 96px so the FAB/nav never cover content.

### 5.2 Bottom navigation

- Height ≈ 62px, white (`--color-surface`), top border 1px `--color-border` [E].
- 5 items: Beranda (home), Skrining (clipboard), Belajar (open book), Ingat (bell), Saya (user).
- Inactive: icon 22px outline, 1.5px stroke, color `#727A77`; label `--text-micro` below.
- Active: **pill** background `--color-primary`, icon + label **inline** (icon left, label right), white text, label weight 700, padding ≈ 8px 14px. The pill expands horizontally, the other tabs keep icon-over-label.
- Icon set: outline/stroke style, rounded joins (Lucide-style).

### 5.3 FAB (assistant button)

- 46px circle, `--color-primary`, white heart-in-chat/message icon (outline), fixed at right 16px, bottom ≈ 72px (above nav). Soft shadow.

---

## 6. Components

### 6.1 Primary button
- Full width (or wide), height 44px, `--radius-pill`, bg `--color-primary`, text white `--text-title` 700. No border/shadow. Pressed: `opacity .9` or darken 6%.

### 6.2 Ghost / outline pill button (e.g. "Riwayat", "Hari ini", "Belum", "Ubah")
- Height 28–32px, padding 0 12px, `--radius-pill`, bg `--color-surface`, border `1px solid --color-border`, text `--color-primary` (or `#33443F` for neutral badges), 11–12px 600.
- Round icon-only variant: 32–36px circle, same style (used for edit pencil, calendar prev/next arrows).

### 6.3 Destructive button ("Keluar")
- Full width, height 44px, pill, bg `--color-danger-bg`, text + leading icon `--color-danger-text`, weight 700.

### 6.4 Header
- bg `--color-primary`, radius `--radius-header`, title `--text-display` white, subtitle `--text-caption` `--color-header-subtitle`, optional right illustration (flat vector art, sage/cream/pink palette, hijab-wearing mother character; swap with brand-appropriate art for the new app).

### 6.5 Mint section container
- bg `--color-primary-soft`, radius `--radius-xl`, padding 12–16px, no border, no shadow. Holds white cards, calendar, chart, forms.

### 6.6 White card / list group
- bg `--color-surface`, radius `--radius-lg`, border 1px `--color-border`.
- **Grouped list** (Profile menu): several rows inside ONE white card separated by 1px hairline dividers (`#E8EFEB` [M]); each row = leading icon chip (36px, radius 14) + label (`--text-title` 600) + trailing chevron `#7F968D` [M] 16px.
- **Standalone row card** (Skrining list): row = 40px icon chip + title (`--text-title` 700) + one-line description (`--text-caption` muted) + trailing status badge.

### 6.7 Status badge / chip
- Pill, border 1px `--color-border`, bg white, 11px 600, e.g. "Belum" (not started). "Done" variant: bg `--color-primary-soft`, text `--color-primary`. "Trimester 1" chip: bg `--color-primary-soft`, text `--color-primary`, no border.

### 6.8 Segmented tabs (Hamil / Nifas / Bayi)
- Three equal pills in a row, gap 0–4px. Active: bg `--color-primary`, white text, 700. Inactive: bg `--color-primary-soft`, text `#727A77`/`--color-primary`.

### 6.9 Progress bar
- Track: height 8px, radius pill, bg `--color-primary-soft` (or white on mint). Fill: `--color-primary`. Label row above: left caption, right percentage 11px 600.

### 6.10 Hero stat card (Pregnancy journey)
- White card on cream, radius 18–24px, contains: caption label, hero text ("Minggu ke-10"), small outlined countdown box on the right (border `--color-border`, radius 14, caption "Menuju HPL" + bold value), progress bar, hairline divider, footer row (icon + label left, bold value right).

### 6.11 Schedule / reminder item
- Time label above the row in `--color-primary` 700 with small bell icon; row card = white, radius 18, border; leading 40px icon chip (`#F2F4F2` neutral), title 13px 700, meta 11px muted. A pill "＋ Tambah" primary button aligned right below the list.

### 6.12 Week strip & calendar
- Week strip: 7 columns; weekday header `--text-micro` muted (Min Sen Sel Rab Kam Jum Sab); date number 13px 700; **selected day** = vertical rounded pill (radius 14, bg primary, white text).
- Month calendar: mint container; month title 700 + prev / "Hari ini" / next ghost pills; 7×N grid; cell ≈ 44×36; day number 12px; **today** = filled primary rounded square (white text); **appointment/focus day** = bg `--color-warning-bg`, 1px border `--color-warning`, tiny dot under number; legend row with 8px colored dots + micro labels: Hari ini (primary), Periksa (warning), Selesai (success), HPL (red/periwinkle).

### 6.13 Content card with illustration (Belajar grid)
- 2-column grid, gap 12px. Card: white, radius 18, border `--color-border`, padding 10–12px.
- Top: illustration banner (radius 14, soft pastel bg, flat vector art). Then title 13px 700 (2 lines max), description 11px muted (1–2 lines), then a **mini primary pill button** "Baca materi →" (height ~26px, 11px 700, white text, with arrow icon).

### 6.14 Form inputs
- Text input / textarea: bg white, radius 14, border 1px `--color-border` (mint), padding 12px, placeholder `--color-text-placeholder`, 12–13px. Sit on a mint container. Textarea min-height ≈ 72px with resize handle visible.

### 6.15 Empty state (chart placeholder)
- White rounded card (radius 18) with centered muted caption (11px, `#9AA0A0`-ish) e.g. "Belum ada data berat. Tambah berat hari ini untuk melihat grafik."

### 6.16 Data table (inside mint container)
- No outer border; rows separated by 1px hairline `#D9E7E2`; header cells 11px muted 500; first column 11px 700; reference note 10–11px muted below.

### 6.17 Profile card
- bg `--color-primary-soft`, radius 24px, padding 16px. Left: 52px circular white avatar with initial (primary color, 20px 700) + tiny camera badge (18px circle, primary bg, white icon) at bottom-right. Middle: name 15px 700 `--color-text`; email 11px; phone 11px muted; code 11px 700 `--color-primary`. Right: round ghost icon button (pencil).

---

## 7. Iconography & Imagery

- Icons: outline, 1.5px stroke, rounded caps/joins, 20–22px in nav, 18–20px in chips (Lucide / Feather style: home, clipboard-list, book-open, bell, user, share-2, database, circle-help, log-out, pencil, camera, shield-check, apple, triangle-alert, heart-pulse, droplets, brain, calendar, chevron-right/left).
- Illustrations: flat vector, soft pastel (sage, cream, blush pink, peach), friendly characters, thin shapes, no heavy outlines. Used in headers (right-aligned) and as card banners.

---

## 8. Motion (suggested [E])

- Duration 150–200ms, ease-out. Press: scale `.98`. Tab change: fade/slide 12px. Active nav pill animates width. No bouncy or flashy effects.

---

## 9. Implementation Snippets

### 9.1 CSS variables

```css
:root {
  /* color */
  --color-primary: #4A6E54;
  --color-primary-soft: #EAF4F0;
  --color-primary-soft-2: #DFF0EA;
  --color-border: #D9E7E2;
  --color-divider: #E8EFEB;
  --color-bg: #FFFCF6;
  --color-surface: #FFFFFF;
  --color-on-primary: #FFFFFF;

  --color-text: #1D2B29;
  --color-text-muted: #727A77;
  --color-text-placeholder: #8A8F93;
  --color-header-subtitle: #E3F0E6;
  --color-chevron: #7F968D;

  --color-danger-bg: #FADDDD;
  --color-danger-text: #C72928;
  --color-warning: #F5C16C;
  --color-warning-bg: #FFF8EC;
  --color-success: #6FCB8A;
  --color-due: #8E97B7;

  --chip-rose-bg: #FFE2E2;   --chip-rose-fg: #DB2777;
  --chip-peach-bg: #FFF1E8;  --chip-peach-fg: #B45309;
  --chip-teal-bg: #DFF0EA;   --chip-teal-fg: #16685C;
  --chip-neutral-bg: #F2F4F2; --chip-neutral-fg: #8A8F93;

  /* type */
  --font-sans: 'Plus Jakarta Sans', Inter, system-ui, -apple-system, 'Segoe UI', Roboto, sans-serif;
  --text-display: 700 24px/30px var(--font-sans);
  --text-hero: 700 22px/28px var(--font-sans);
  --text-h2: 700 16px/22px var(--font-sans);
  --text-title: 600 13px/18px var(--font-sans);
  --text-body: 400 12px/18px var(--font-sans);
  --text-caption: 400 11px/15px var(--font-sans);
  --text-micro: 500 10px/14px var(--font-sans);

  /* space */
  --space-1: 4px; --space-2: 8px; --space-3: 12px; --space-4: 16px;
  --space-5: 20px; --space-6: 24px; --space-8: 32px;

  /* radius */
  --radius-header: 0 0 28px 28px;
  --radius-xl: 24px; --radius-lg: 18px; --radius-md: 14px;
  --radius-sm: 10px; --radius-pill: 999px;

  /* elevation */
  --shadow-float: 0 4px 12px rgba(29, 43, 41, .15);
  --border: 1px solid var(--color-border);
}
```

### 9.2 Tailwind config

```js
// tailwind.config.js
module.exports = {
  theme: {
    extend: {
      colors: {
        primary: { DEFAULT: '#4A6E54', soft: '#EAF4F0', soft2: '#DFF0EA' },
        border: '#D9E7E2',
        bg: '#FFFCF6',
        ink: { DEFAULT: '#1D2B29', muted: '#727A77', placeholder: '#8A8F93' },
        danger: { bg: '#FADDDD', DEFAULT: '#C72928' },
        warning: { DEFAULT: '#F5C16C', bg: '#FFF8EC' },
        success: '#6FCB8A',
        due: '#8E97B7',
      },
      fontFamily: { sans: ['"Plus Jakarta Sans"', 'Inter', 'system-ui', 'sans-serif'] },
      borderRadius: { header: '28px', xl: '24px', lg: '18px', md: '14px', sm: '10px' },
      boxShadow: { float: '0 4px 12px rgba(29,43,41,.15)' },
      spacing: { 4.5: '18px' },
    },
  },
};
```

### 9.3 Android (Jetpack Compose / XML) color mapping

```kotlin
val Primary = Color(0xFF4A6E54)
val PrimarySoft = Color(0xFFEAF4F0)
val Border = Color(0xFFD9E7E2)
val Background = Color(0xFFFFFCF6)
val Surface = Color(0xFFFFFFFF)
val TextPrimary = Color(0xFF1D2B29)
val TextMuted = Color(0xFF727A77)
val DangerBg = Color(0xFFFADDDD)
val Danger = Color(0xFFC72928)
val Warning = Color(0xFFF5C16C)
val WarningBg = Color(0xFFFFF8EC)
// shapes: RoundedCornerShape(24.dp / 18.dp / 14.dp / 50%)
```

---

## 10. Do / Don't (for agents)

**Do**
- Keep the cream background + white cards + mint containers layering.
- Use pill shapes for every button, tab, badge.
- Keep headers in solid sage green with large rounded bottom corners.
- Keep copy warm, short, and in the target app's language.
- Use outline icons at consistent stroke width.

**Don't**
- Don't add drop shadows to cards, gradients on buttons, or neon/saturated colors.
- Don't use pure black or pure white page backgrounds.
- Don't mix sharp corners with these rounded shapes.
- Don't use more than one strong CTA per viewport section.
- Don't use red for anything other than destructive/critical states.

---

## 11. Adapting to a Different App

When the new app has a similar concept but different content:
1. Keep the **tokens** (sections 2–4) identical.
2. Replace the **content, icons, and illustrations** (swap to the new domain, keep the flat pastel style).
3. Map new features onto existing components: lists → 6.6, progress → 6.9/6.10, schedule → 6.11/6.12, learning content → 6.13, forms → 6.14, status → 6.7.
4. If a new semantic color is needed, derive it as a pastel bg (≈ 90% lightness) + deeper glyph of the same hue, following the chip pairs in 2.4.
5. If the brand needs a different hue, change **only** `--color-primary`, `--color-primary-soft`, `--color-primary-soft-2`, `--color-border` (keep same lightness/saturation relationships) and leave the rest intact.
