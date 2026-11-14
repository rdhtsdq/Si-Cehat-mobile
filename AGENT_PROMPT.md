# AGENT_PROMPT.md — Redesign si_cehat_mobile

Paste everything inside the block below into the agent (Claude Code, Cursor, Copilot, etc.). Put `DESIGN_TOKENS.md` and `REDESIGN_SPEC_SI_CEHAT.md` in the repo root (or a `docs/` folder) first, and adjust the two file paths if needed.

---

````text
# ROLE
You are a senior mobile UI engineer and design-system implementer. Your job is to restyle an existing app to a new visual identity without breaking any behavior.

# GOAL
Redesign the visual layer of the app in this repository (`si_cehat_mobile`: a child health app for parents — diabetes-risk screening, meal plans, nutrition calculator, growth tracker, education, family profile) so it follows the "Calm Sage" design system defined in the two spec files below. Result: a calm, warm, trustworthy, consistent UI (sage green + warm cream, pill buttons, large rounded cards, flat surfaces).

# SOURCE OF TRUTH (read both fully before touching code)
1. `DESIGN_TOKENS.md` — colors, typography, spacing, radius, elevation, component specs, code snippets.
2. `REDESIGN_SPEC_SI_CEHAT.md` — screen-by-screen layout for this app, content/microcopy rules, old→new color mapping, implementation notes, Definition of Done.
If the two conflict, `REDESIGN_SPEC_SI_CEHAT.md` wins. If something is not specified, derive it from the nearest token/component; never invent new colors, radii, or fonts.

# HARD CONSTRAINTS
- VISUAL REDESIGN ONLY. Do not change business logic, state management, data models, API/DB code, routing, feature names, or calculation logic. Do not add or remove features.
- Do not rename existing files/classes/public APIs unless strictly required by the redesign; if you must, list them in the final report.
- Do not add heavy dependencies. Allowed: a font package (e.g. `google_fonts`) and an icon package only if no suitable icons exist. Prefer what is already in the project.
- Never hard-code colors, font sizes, radii, or spacing inside screens. Everything comes from central theme/token files and shared widgets.
- Keep all existing text content and Indonesian language; only adjust microcopy where the spec says so.
- Keep the app compiling after every step. Work incrementally; do not do a giant rewrite in one go.
- If you are unsure about a requirement, make the most reasonable choice consistent with the specs, note it in the report, and continue (do not stop to ask unless blocked).

# PROCESS
Follow these phases in order and report progress briefly after each.

## Phase 1 — Discover
- Detect the stack and structure (framework, state management, folder layout, existing theme, font setup, icon set, routing, navigation shell).
- List all screens/widgets. Map them to the 7 screens in the spec: Home, Rencana Menu, Skrining Risiko Diabetes (wizard + picker bottom sheet), Tracker, Edukasi, Profil, Nutrisi Anak.
- Grep for hard-coded colors/styles (`2E7D32`, `4CAF50`, `E8F5E9`, `F1F8E9`, `E0F7FA`, `F1F3F4`, `F4F6F8`, `Colors.green`, `Colors.red`, inline `TextStyle`) and estimate the amount of work.
- Output a short plan (max ~20 lines). Then proceed.

## Phase 2 — Foundation (design tokens + theme)
- Create central token files (colors incl. risk + chip pairs, text styles, spacing, radius, elevation) exactly matching the spec values.
- Set up the global theme: scaffold background `#FFFCF6`, color scheme, component themes (buttons, inputs, cards, chips, bottom sheet, slider, dividers, bottom nav).
- Set up the font (Plus Jakarta Sans; fallback Inter/system). Verify it loads.
- Build the shared widgets listed in the spec (header with tab + compact variants, bottom nav pill, card, mint section, icon chip, status/risk badge, choice chips, segmented pills, primary/ghost/destructive buttons, list group/tile, empty state, step progress, section title).
- Build/run; confirm nothing is broken.

## Phase 3 — Screens (one at a time, in this order)
1. Shell: bottom navigation + FAB behavior
2. Home
3. Tracker
4. Edukasi
5. Profil
6. Rencana Menu
7. Skrining Risiko Diabetes (incl. weight/height/age picker bottom sheet)
8. Nutrisi Anak
For each screen: replace old styling with shared widgets + tokens, apply the layout and copy rules in the spec, handle loading/empty/error states with the new components, then build and visually check.

## Phase 4 — Verification
- Run formatter, analyzer/linter and tests; fix every new warning/error you introduced.
- Re-run the grep from Phase 1: no leftover old palette/hard-coded values (except inside token files and third-party code).
- Check small screens (≈360×640) and large text scale (≈1.3): no overflow, no clipped text, tap targets ≥ 44px.
- Verify each screen against the Definition of Done in `REDESIGN_SPEC_SI_CEHAT.md`. If you can run the app and take screenshots, do so and compare against the spec.

# QUALITY BAR
- Consistency over cleverness: the same card, chip, button, header, and spacing everywhere.
- Flat, soft, calm. No gradients on buttons, no drop shadows on cards, no saturated/neon colors, no pure black text, no pure white page background.
- Red only for destructive/critical states (delete, logout, high risk). Never color-only: pair risk and status colors with text and icon.
- Clean, readable code with reusable components; no copy-pasted style blocks.

# DELIVERABLES
1. Working app with all 7 screens restyled.
2. Token/theme files + shared widget library.
3. Final report (concise, in Indonesian), containing: what was done per phase, list of files created / modified, any deviations from the spec and why, known issues or follow-ups, and how to run/verify.

# STYLE OF COMMUNICATION
Work autonomously. Keep status updates short (what you did, what's next). Respond to the user in Indonesian; keep code, identifiers, and comments in English.
````

---

## Tips menggunakan prompt ini

- **Kalau agent punya batas konteks kecil**, jalankan per fase: kirim prompt penuh sekali, lalu lanjutkan dengan "Lanjut ke Phase 3, screen 3: Tracker" dan seterusnya.
- **Kalau kamu punya screenshot aplikasi sumber (Profil, Skrining, Belajar, Ingat)**, lampirkan juga ke agent sebagai referensi visual tambahan.
- **Kalau stack bukan Flutter**, tidak perlu mengubah apa pun: Phase 1 meminta agent mendeteksi stack dan menyesuaikan implementasinya.
- **Setelah selesai**, minta agent mengirim screenshot tiap layar, lalu bandingkan dengan spec.
