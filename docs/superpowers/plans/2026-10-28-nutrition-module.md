# Modul Nutrisi Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Modul nutrisi server-backed yang bisa menghitung satu makanan maupun banyak item, menyimpan ke food diary, dan membandingkan asupan harian dengan target AKG manual.

**Architecture:** Katalog makanan menjadi tabel `FoodItem` di backend. Mobile memuat katalog, menghitung via API (fallback lokal), menyimpan batch ke `DetailedFoodLog`, dan menampilkan ringkasan harian terhadap `NutritionTarget` per anak.

**Tech Stack:** Flutter 3.12+/Dart 3, Riverpod (ChangeNotifierProvider), Bun + Hono + Drizzle + PostgreSQL, `http`.

**Spec:** `docs/superpowers/specs/2026-10-28-nutrition-module-and-notifications-design.md`

## Global Constraints

- Tidak memakai emoji di UI modul baru (kebijakan zero-emoticon).
- Tanggal yang dikirim mobile: `yyyy-MM-dd` lokal; backend parse sebagai UTC midnight.
- Semua endpoint data anak wajib login dan memvalidasi `guardianId`.
- Kalori integer; makro 1 desimal.
- `POST /api/nutrition/calculate` dan `POST /api/food-diary` lama tetap kompatibel.
- Tidak ada feature flag untuk modul nutrisi.
- Commit kecil per task; jalankan test sebelum commit.

## Review Focus

- Berat 0/negatif atau kosong → tidak boleh menghasilkan NaN/negatif.
- Target 0 atau belum diisi → persentase `null`, bukan divide-by-zero.
- Nama makanan tidak dikenal → fallback estimasi ditandai `isEstimate`, bukan error.
- Dua makanan dengan nama mirip/duplikat → pencarian deterministik, bukan acak.
- Simpan batch dua kali/offline → tidak menggandakan entri diary.

---

### Task 1: Backend schema & migration

**Files:**
- Modify: `../Si-Cehat/src/server/db/schema.ts`
- Verify: `../Si-Cehat/bun run typecheck`, `bunx drizzle-kit push --verbose`

**Interfaces:**
- Produces: `foodItems`, `nutritionTargets` tables; `detailedFoodLogs` gains `sugarGram`, `fiberGram`, `foodItemId`.

- [ ] **Step 1: Add `foodItems` and `nutritionTargets` tables** with fields from spec §7.2.
- [ ] **Step 2: Extend `detailedFoodLogs`** with `sugarGram doublePrecision`, `fiberGram doublePrecision`, `foodItemId text`.
- [ ] **Step 3: Run `bun run typecheck`.** Expected: exit 0.
- [ ] **Step 4: Run `bunx drizzle-kit push --verbose`.** Expected: `CREATE TABLE "FoodItem"`, `CREATE TABLE "NutritionTarget"`, `ALTER TABLE "DetailedFoodLog"`, `[✓] Changes applied`.
- [ ] **Step 5: Commit** `feat(nutrition): add catalog and target schema`.

---

### Task 2: Food data, pure calculation service, seed, catalog endpoint

**Files:**
- Create: `../Si-Cehat/src/server/services/food-data.ts`
- Create: `../Si-Cehat/src/server/services/nutrition.ts`
- Create: `../Si-Cehat/src/server/routes/nutrition.routes.ts`
- Modify: `../Si-Cehat/src/server/app.ts`
- Modify: `../Si-Cehat/src/server/db/seed.ts`
- Test: `../Si-Cehat/src/server/__tests__/nutrition.test.ts`

**Interfaces:**
- Produces:
  - `export interface NutritionValues { caloriesKkal: number; carbsGram: number; proteinGram: number; fatGram: number; sugarGram: number; fiberGram: number }`
  - `export function scaleNutrition(food: NutritionValues, weightGram: number): NutritionValues`
  - `export function sumNutrition(items: NutritionValues[]): NutritionValues`
  - `export function getDefaultTarget(ageYears: number): NutritionValues`
  - `export function matchFoodName(foods: Array<{name:string; aliases?:string|null}>, query: string): number` (index or -1)
  - `export const FOOD_SEED: Array<{name:string; aliases:string; category:string; ...NutritionValues; portionDescription:string}>`
  - `GET /api/nutrition/foods`

- [ ] **Step 1: Write failing tests** in `nutrition.test.ts`:
  - `scaleNutrition` 150 g doubles values and rounds calories.
  - `scaleNutrition` with weight 0 or negative returns all zeroes (no negative values).
  - `sumNutrition` adds six fields; `sumNutrition([])` returns zeroes.
  - `getDefaultTarget(8)` returns `{caloriesKkal:1650, proteinGram:45, fatGram:55, carbsGram:250, fiberGram:23, sugarGram:25}`.
  - `matchFoodName` matches exact, alias, then contains; returns -1 for unknown; duplicate names resolve deterministically (first exact match).
- [ ] **Step 2: Run `bun test src/server/__tests__/nutrition.test.ts`.** Expected: FAIL (module not found).
- [ ] **Step 3: Implement `nutrition.ts` and `food-data.ts`** with the exact signatures above.
- [ ] **Step 4: Run the test again.** Expected: PASS.
- [ ] **Step 5: Add public `nutritionRoutes.get("/nutrition/foods", ...)`** with `search`, `category`, `limit` (max 200), mounted at `/` in `app.ts`.
- [ ] **Step 6: Add an idempotent seed** that upserts `FOOD_SEED` by normalized name; call it from `db/seed.ts`.
- [ ] **Step 7: Verify live:** start API, `curl '/api/nutrition/foods?search=nasi'` → 200 with `foods` array.
- [ ] **Step 8: Commit** `feat(nutrition): add food catalog and calculation service`.

---

### Task 3: Single + batch calculation and target endpoints

**Files:**
- Modify: `../Si-Cehat/src/server/routes/nutrition.routes.ts`
- Modify: `../Si-Cehat/src/server/routes/parent.routes.ts` (remove/replace old `/nutrition/calculate` or delegate)
- Test: `../Si-Cehat/src/server/__tests__/nutrition.test.ts`

**Interfaces:**
- Produces:
  - `POST /api/nutrition/calculate` → `{foodName, foodId?, weightGram, ...NutritionValues, note, isEstimate}`
  - `POST /api/nutrition/calculate-batch` → `{items, totals, target?, percent?}`
  - `GET /api/nutrition/target?childId=` → `{target, defaults}`
  - `PUT /api/nutrition/target` → `{success, target}`
  - `percentOf(total, target): number | null` (0 target → null)

- [ ] **Step 1: Write failing tests** for `percentOf(0, 0) === null`, `percentOf(500, 1000) === 50`, `percentOf(1500, 1000) === 150`.
- [ ] **Step 2: Run tests; expected FAIL.**
- [ ] **Step 3: Implement `percentOf` and the four routes.** Move the legacy `POST /nutrition/calculate` handler out of `parent.routes.ts` into `nutrition.routes.ts` (delete the old registration) while preserving the exact response fields. Calculation uses `foodItems` first, then fuzzy match, then generic fallback with `isEstimate: true`. Batch validates ownership only when a session exists and `childId` is provided.
- [ ] **Step 4: Run tests; expected PASS.**
- [ ] **Step 5: Verify live** with the test account: single calculate, batch with two items, GET/PUT target.
- [ ] **Step 6: Commit** `feat(nutrition): add batch calculation and target endpoints`.

---

### Task 4: Daily summary and diary batch save

**Files:**
- Modify: `../Si-Cehat/src/server/routes/nutrition.routes.ts`
- Modify: `../Si-Cehat/src/server/routes/parent.routes.ts` (`POST /food-diary/batch`, include sugar/fiber on GET)
- Test: `../Si-Cehat/src/server/__tests__/nutrition.test.ts`

**Interfaces:**
- Produces:
  - `GET /api/nutrition/summary?childId=&date=` → `{date, childId, entries, totals, target, remaining, percent}`
  - `POST /api/food-diary/batch` → `{success, items}`

- [ ] **Step 1: Write failing tests** for `remainingOf(total, target)` (max 0) and `sumNutrition([])` returns zeroes.
- [ ] **Step 2: Run tests; expected FAIL.**
- [ ] **Step 3: Implement summary and batch save** in a transaction; derive target via `getOrCreateTarget`.
- [ ] **Step 4: Run tests; expected PASS.**
- [ ] **Step 5: Verify live:** save a batch then GET summary shows the same totals; re-save does not modify earlier dates.
- [ ] **Step 6: Commit** `feat(nutrition): add daily summary and diary batch save`.

---

### Task 5: Mobile models, API constants, provider

**Files:**
- Create: `lib/data/models/nutrition_model.dart`
- Create: `lib/providers/nutrition_provider.dart`
- Modify: `lib/core/api/api_constants.dart`
- Modify: `lib/providers/app_providers.dart`
- Test: `test/nutrition_model_test.dart`, `test/nutrition_provider_test.dart`

**Interfaces:**
- Produces:
  - `class FoodItem { final String id, name, category; final double caloriesKkal, carbsGram, proteinGram, fatGram, sugarGram, fiberGram; factory FoodItem.fromJson(...) }`
  - `class NutritionValues { ...; factory fromJson; NutritionValues operator +(NutritionValues other) }`
  - `class NutritionTarget { ...; factory fromJson }`
  - `class NutritionSummary { ...; factory fromJson }`
  - `class NutritionProvider extends ChangeNotifier` with `foods`, `target`, `summary`, `draft`, `loadCatalog()`, `loadTarget(childId)`, `loadSummary(childId, date)`, `addDraft(FoodItem, grams)`, `removeDraft(index)`, `updateDraftWeight(index, grams)`, `calculateDraft()`, `saveDraftToDiary({childId, date, mealSlot})`, `saveTarget(childId, NutritionTarget)`.

- [ ] **Step 1: Write failing model tests** for parsing the API shape, `NutritionValues +`, and percent/target edge cases.
- [ ] **Step 2: Run `flutter test test/nutrition_model_test.dart`; expected FAIL.**
- [ ] **Step 3: Implement models, constants, provider, and register `nutritionProvider`.**
- [ ] **Step 4: Cache target/summary in `SharedPreferences` per child + date** (`nutrition_target_<childId>`, `nutrition_summary_<childId>_<date>`) and load the cache before the network call.
- [ ] **Step 5: Run tests; expected PASS.**
- [ ] **Step 6: Commit** `feat(nutrition): add mobile models and provider`.

---

### Task 6: Two-tab nutrition UI

**Files:**
- Modify: `lib/screens/nutrition/nutrition_calculator_screen.dart`
- Create: `lib/screens/nutrition/widgets/nutrition_food_picker.dart`
- Create: `lib/screens/nutrition/widgets/nutrition_result_card.dart`
- Create: `lib/screens/nutrition/widgets/nutrition_summary_card.dart`
- Create: `lib/screens/nutrition/widgets/nutrition_target_sheet.dart`
- Test: `test/nutrition_screen_test.dart`

**Interfaces:**
- Consumes: `NutritionProvider` from Task 5.
- Produces: screen with tabs `Hitung Cepat` and `Susun Asupan`, target editor, summary card.

- [ ] **Step 1: Write a failing widget test** that pumps the screen with `ProviderScope` + mocked SharedPreferences and expects both tab labels and a "Atur Target" button.
- [ ] **Step 2: Run the test; expected FAIL.**
- [ ] **Step 3: Refactor the screen** to use `NutritionProvider`; keep the existing manual input and food directory, add "Tambahkan ke Asupan", batch list, summary, and target sheet.
- [ ] **Step 4: Run `flutter analyze` and `flutter test test/nutrition_screen_test.dart`; expected PASS.**
- [ ] **Step 5: Commit** `feat(nutrition): add two-tab nutrition screen`.

---

### Task 7: Offline queue and final verification

**Files:**
- Modify: `lib/providers/nutrition_provider.dart`
- Modify: `lib/screens/nutrition/nutrition_calculator_screen.dart`
- Test: `test/nutrition_provider_test.dart`

**Interfaces:**
- Produces: `pending_nutrition_batches` queue in `SharedPreferences`, retried on `loadCatalog()`.
- Consumes: `POST /api/food-diary/batch`.

- [ ] **Step 1: Write a failing test** that saves a batch while the API fails, then verifies the queue contains one entry and that a second retry with success clears it.
- [ ] **Step 2: Run the test; expected FAIL.**
- [ ] **Step 3: Implement the queue** (append-only, `date`, `mealSlot`, `items`), disable the save button while in flight, and show "menunggu sinkronisasi".
- [ ] **Step 4: Run all mobile tests + analyze; expected PASS.**
- [ ] **Step 5: Build `flutter build apk --debug` and `--release`; expected success.**
- [ ] **Step 6: Update `docs/playlab-integration-guide.md`?** No — add a short `docs/nutrition-module.md` with endpoints and offline behavior.
- [ ] **Step 7: Commit** `feat(nutrition): offline batch queue and docs`.
