# Konsultasi + Nutrisi AI Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Sederhanakan modul konsultasi (hapus pemilihan tenaga medis + tambah tanggal) dan ubah kalkulator nutrisi menjadi berbasis analisis foto AI dengan target dari data TB/BB.

**Architecture:** Perubahan menyentuh dua repo: `Si-Cehat` (backend Bun/Hono + Drizzle/PostgreSQL + web admin React/Vite) dan `Si-Cehat-mobile` (Flutter + Riverpod + http + sqflite). Backend diubah dulu (skema + endpoint), lalu web admin, lalu mobile (kontrak API baru). Target gizi memakai rumus asumsi kalori-dari-berat-badan yang berlabel edukatif.

**Tech Stack:** Bun + Hono + Drizzle ORM (PostgreSQL) + Zod; React 19 + Vite + Tailwind (admin); Flutter + Riverpod (ChangeNotifier) + http + image_picker.

**Spec:** `docs/superpowers/specs/2026-11-13-konsultasi-nutrisi-design.md` (repo `Si-Cehat-mobile`).

## Global Constraints

- Backend: repo `Si-Cehat` di `/home/sectra/Documents/Projects/Si-Cehat`; package manager Bun; migrasi via `bunx drizzle-kit generate` (out `./drizzle`) + `drizzle-kit push`.
- Mobile: repo `Si-Cehat-mobile` di `/home/sectra/Documents/Projects/Si-Cehat-mobile`; verifikasi `dart format`, `flutter analyze`, `flutter test`.
- Zod `z.object` non-strict (field asing diabaikan) agar klien lama tidak 400.
- `scheduledDate` disimpan sebagai teks `YYYY-MM-DD` (date-only, tanpa konversi zona waktu).
- Hasil AI foto & target TB/BB wajib berlabel edukatif, bukan diagnosis.
- Target MANUAL tidak boleh ditimpa oleh kalkulasi otomatis.

## Review Focus

1. **Klien lama tanpa `scheduledDate`** → POST konsultasi harus 400 dengan pesan jelas, bukan 500.
2. **Foto tanpa API key / provider non-vision** → endpoint mengembalikan 503 (bukan 500); mobile fallback manual tanpa crash.
3. **Target MANUAL** → kalkulasi TB/BB tidak menimpa target sumber `MANUAL`.
4. **Tanggal tidak bergeser zona waktu** → `scheduledDate` tetap `YYYY-MM-DD` persis yang dikirim.
5. **Makanan tak dikenal dari AI** → item ber-`isEstimate: true` dengan estimasi generik, tidak crash.

---

## Bagian A — Backend (repo `Si-Cehat`)

### Task 1: Skema DB konsultasi + target

**Files:**
- Modify: `src/server/db/schema.ts`
- Modify: `src/server/db/seed.ts`

**Interfaces:**
- Produces: tabel `consultations` dengan kolom `{ id, guardianId, topic, scheduledDate, notes, status, createdAt }` (tanpa `specialistType`/`specialistName`); tabel `medicalPersonnel` dihapus; `nutritionTargets.source` tetap `AKG|MANUAL` + nilai baru `ANTROPOMETRI` (nilai teks, bukan kolom baru).

- [ ] **Step 1: Hapus `medicalPersonnel` dan ubah `consultations`**

Di `schema.ts`: hapus definisi `medicalPersonnel` (baris ~32–51). Di tabel `consultations`, hapus `specialistType`/`specialistName`, tambah `scheduledDate: text("scheduledDate").notNull()`.

- [ ] **Step 2: Sesuaikan `seed.ts`**

Hapus import `medicalPersonnel` dan blok insert-nya (baris ~588–590). Pada seed `consultations` (baris ~212–230), hapus `specialistType`/`specialistName`, tambah `scheduledDate: "2026-11-20"` (nilai contoh).

- [ ] **Step 3: Generate migrasi**

Run: `bunx drizzle-kit generate`
Expected: file SQL baru di `./drizzle/` berisi `ALTER TABLE "Consultation" DROP COLUMN ... ADD COLUMN "scheduledDate" ...` dan `DROP TABLE "MedicalPersonnel"`.

- [ ] **Step 4: Typecheck**

Run: `bun run typecheck`
Expected: tidak ada error terkait `medicalPersonnel`/`specialistType`/`specialistName` di `schema.ts`/`seed.ts`.

- [ ] **Step 5: Commit**

```bash
git add src/server/db/schema.ts src/server/db/seed.ts drizzle/
git commit -m "feat(db): simplify consultation schema and drop medicalPersonnel"
```

### Task 2: Endpoint konsultasi disederhanakan

**Files:**
- Modify: `src/server/routes/parent.routes.ts`
- Modify: `src/server/routes/admin.routes.ts`

**Interfaces:**
- Consumes: skema `consultations` baru (Task 1).
- Produces: `POST /api/consultations` body `{ topic, scheduledDate, notes? }` → `{ consultation }` (status `PENDING`); `GET /api/consultations` tanpa field specialist; `GET /api/consultations/specialists` dihapus; route admin `GET/POST/PUT/DELETE /api/admin/specialists` dihapus.

- [ ] **Step 1: Hapus specialist route + konstan**

Di `parent.routes.ts`: hapus import `medicalPersonnel`, hapus konstanta `SPECIALISTS` (baris ~2734–2783) dan `GET /consultations/specialists` (baris ~2785–2856).

- [ ] **Step 2: Ubah schema & POST konsultasi**

Ganti `createConsultationSchema` menjadi `z.object({ topic: z.string().trim().min(3).max(200), scheduledDate: z.string().regex(/^\d{4}-\d{2}-\d{2}$/), notes: z.string().trim().max(1000).optional() })`. Pada `POST /consultations`, insert `{ guardianId, topic, scheduledDate, notes, status: "PENDING" }`; ubah pesan notifikasi tanpa nama tenaga medis.

- [ ] **Step 3: Hapus CRUD specialist di admin**

Di `admin.routes.ts`: hapus import `medicalPersonnel`, hapus `specialistSchema`, `specialistToJson`, dan route `GET/POST/PUT/DELETE /specialists` (baris ~838–1089).

- [ ] **Step 4: Perbarui dokumentasi API**

Di `API_DOCUMENTATION.md` dan `src/app/api-docs/page.tsx`: hapus contoh `specialistType`/`specialistName`/`/consultations/specialists`; tambah `scheduledDate` pada contoh `POST /api/consultations`.

- [ ] **Step 5: Typecheck**

Run: `bun run typecheck`
Expected: tidak ada referensi `medicalPersonnel`/`SPECIALISTS`/`specialistSchema` tersisa.

- [ ] **Step 6: Commit**

```bash
git add src/server/routes/parent.routes.ts src/server/routes/admin.routes.ts API_DOCUMENTATION.md src/app/api-docs/page.tsx
git commit -m "feat(api): simplify consultation endpoints, remove specialist CRUD"
```

### Task 3: Target gizi dari TB/BB

**Files:**
- Modify: `src/server/services/nutrition.ts`
- Modify: `src/server/routes/nutrition.routes.ts`
- Test: `src/server/__tests__/nutrition.test.ts`

**Interfaces:**
- Produces: `getTargetFromMeasurement(weightKg: number, heightCm: number, ageYears: number): NutritionValues`; `getOrCreateNutritionTarget(childId)` kini memperhitungkan pengukuran terakhir dan `source: "ANTROPOMETRI"` (tidak menimpa `MANUAL`).

- [ ] **Step 1: Tulis test gagal**

```ts
// nutrition.test.ts
expect(getTargetFromMeasurement(20, 110, 5).caloriesKkal).toBe(1700); // 20*85
expect(getTargetFromMeasurement(25, 120, 8).caloriesKkal).toBe(1875); // 25*75
```

- [ ] **Step 2: Jalankan test → gagal**

Run: `bun test src/server/__tests__/nutrition.test.ts`
Expected: FAIL (fungsi belum ada).

- [ ] **Step 3: Implement `getTargetFromMeasurement` di `services/nutrition.ts`**

`kcalPerKg`: 85 (<7), 75 (7–9), 65 (10–12), 55 (≥13). `caloriesKkal = Math.round(weightKg * kcalPerKg)`. Protein = 20% kalori ÷ 4; Lemak = 30% ÷ 9; Karbo = 50% ÷ 4 (pakai `round1`). `sugarGram = 25`. `fiberGram = getDefaultTarget(age).fiberGram`.

- [ ] **Step 4: Ubah `getOrCreateNutritionTarget` di `nutrition.routes.ts`**

Ambil `growthMeasurements` terakhir (weightKg, heightCm) + `children.birthDate`. Bila ada pengukuran dan existing target tidak ber-`source === "MANUAL"`, hitung via `getTargetFromMeasurement` dan upsert `{ source: "ANTROPOMETRI" }`. Bila tidak ada pengukuran, pertahankan `getDefaultTarget(age)` dengan `source: "AKG"`.

- [ ] **Step 5: Jalankan test → lulus**

Run: `bun test src/server/__tests__/nutrition.test.ts`
Expected: PASS.

- [ ] **Step 6: Commit**

```bash
git add src/server/services/nutrition.ts src/server/routes/nutrition.routes.ts src/server/__tests__/nutrition.test.ts
git commit -m "feat(nutrition): derive target from weight/height measurement"
```

### Task 4: Endpoint analisis foto (AI vision)

**Files:**
- Create: `src/server/services/vision.ts`
- Modify: `src/server/routes/nutrition.routes.ts`
- Modify: `src/server/env.ts`

**Interfaces:**
- Consumes: `getResolvedBotConfig()` (dari `services/bot-config.ts`), `resolveFoodItem`, `scaleNutrition`, `sumNutrition`, `normalizeNutritionTotals`, `getOrCreateNutritionTarget`, `percentOf`.
- Produces: `analyzeFoodPhoto(imageBase64: string, opts: { childId?: string }): Promise<{ items, totals, target?, percent?, note }>`; route `POST /api/nutrition/analyze-photo`.

- [ ] **Step 1: Tambah `VISION_MODEL` di `env.ts`**

Tambahkan `VISION_MODEL: z.string().optional().default("gpt-4o-mini")` ke `serverEnvSchema`.

- [ ] **Step 2: Buat `services/vision.ts`**

`analyzeFoodPhoto`: baca `getResolvedBotConfig()`; model = `process.env.VISION_MODEL || config.model`. Kirim `POST {baseUrl}/chat/completions` dengan konten multimodal (image_url base64 + prompt meminta JSON `[{ "name": string, "weightGram": number }]`). Bila `!config.isApiKeySet` atau fetch gagal → throw `new VisionUnavailableError()`. Parsing JSON; untuk tiap item panggil `resolveFoodItem({ foodName })` → `scaleNutrition` (atau `GENERIC_FOOD` dengan `isEstimate: true` bila tak cocok). Hitung `totals`; bila `childId`, hitung `target` (via `getOrCreateNutritionTarget`) + `percent`.

- [ ] **Step 3: Tambah route `POST /nutrition/analyze-photo`**

Body `{ imageBase64: z.string().min(1), childId: z.string().uuid().optional() }`, auth `getSession`. Tangkap `VisionUnavailableError` → `c.json({ error: { message: "Analisis foto tidak tersedia saat ini." } }, 503)`. Sukses → `{ items, totals, target?, percent?, note: "Perkiraan dari foto..." }`.

- [ ] **Step 4: Typecheck**

Run: `bun run typecheck`
Expected: PASS.

- [ ] **Step 5: Commit**

```bash
git add src/server/services/vision.ts src/server/routes/nutrition.routes.ts src/server/env.ts
git commit -m "feat(nutrition): add AI photo analysis endpoint"
```

---

## Bagian B — Web Admin (repo `Si-Cehat`)

### Task 5: Bersihkan UI tenaga medis di admin

**Files:**
- Modify: `src/app/admin/AdminDashboardClient.tsx`

**Interfaces:**
- Consumes: endpoint admin specialist dihapus (Task 2).
- Produces: tipe `Consultation` tanpa `specialistType`/`specialistName`, ada `scheduledDate`; daftar telekonsultasi menampilkan `topic` + `scheduledDate` + status.

- [ ] **Step 1: Hapus state & handler specialist**

Hapus tipe `SpecialistItem`, state `specialists`/`specialistForm`/`editingSpecialistId`, fungsi fetch/save/delete specialist, dan seksi UI "Master Tenaga Medis" + "Petugas / Tenaga Medis" + form modal.

- [ ] **Step 2: Update tipe & tampilan Consultation**

Hapus `specialistType`/`specialistName` dari tipe `Consultation`, tambah `scheduledDate`. Di daftar telekonsultasi, ganti `{c.specialistType} - {c.specialistName}` → `{c.topic}` + `{c.scheduledDate}`.

- [ ] **Step 3: Typecheck + build client**

Run: `bun run typecheck && bun run build:client`
Expected: PASS.

- [ ] **Step 4: Commit**

```bash
git add src/app/admin/AdminDashboardClient.tsx
git commit -m "feat(admin): remove medical personnel management UI"
```

---

## Bagian C — Mobile (repo `Si-Cehat-mobile`)

### Task 6: Endpoint + model nutrisi

**Files:**
- Modify: `lib/core/api/api_constants.dart`
- Modify: `lib/data/models/nutrition_model.dart`

**Interfaces:**
- Consumes: endpoint `POST /api/nutrition/analyze-photo` (Task 4).
- Produces: `ApiConstants.nutritionAnalyzePhoto = '/api/nutrition/analyze-photo'`; kelas `PhotoAnalysisResult` (items + totals + target + percent) dan `PhotoAnalysisItem` (foodName, weightGram, values, isEstimate).

- [ ] **Step 1: Tambah konstanta endpoint**

Di `api_constants.dart`: tambah `static const String nutritionAnalyzePhoto = '/api/nutrition/analyze-photo';` dan hapus `static const String specialists`.

- [ ] **Step 2: Tambah model `PhotoAnalysisItem` + `PhotoAnalysisResult`**

`PhotoAnalysisItem` berisi `foodName`, `weightGram`, `NutritionValues values`, `bool isEstimate`. `PhotoAnalysisResult` berisi `List<PhotoAnalysisItem> items`, `NutritionValues totals`, `NutritionValues? target`, `Map<String,int?>? percent`, `String? note`. Keduanya punya `fromJson`.

- [ ] **Step 3: Format + analyze**

Run: `dart format lib/core/api/api_constants.dart lib/data/models/nutrition_model.dart && flutter analyze`
Expected: no issues.

- [ ] **Step 4: Commit**

```bash
git add lib/core/api/api_constants.dart lib/data/models/nutrition_model.dart
git commit -m "feat(nutrition): add photo analysis endpoint + models"
```

### Task 7: Provider analisis foto + simpan diary

**Files:**
- Modify: `lib/providers/nutrition_provider.dart`

**Interfaces:**
- Consumes: `ApiConstants.nutritionAnalyzePhoto`, `ApiConstants.foodDiaryBatch`, `PhotoAnalysisResult` (Task 6).
- Produces: `NutritionProvider.analyzePhoto(String imageBase64, String childId) -> Future<PhotoAnalysisResult?>`; state `isAnalyzingPhoto`, `photoResult`; `savePhotoResultToDiary({childId, date, mealSlot, items}) -> Future<bool>`.

- [ ] **Step 1: Tambah state + `analyzePhoto`**

Tambah `bool _isAnalyzingPhoto`, `PhotoAnalysisResult? _photoResult` + getter. `analyzePhoto` POST `nutritionAnalyzePhoto` body `{ imageBase64, childId }`; sukses → set `_photoResult` dari `PhotoAnalysisResult.fromJson`, `notifyListeners`, return hasil; gagal/503 → return null.

- [ ] **Step 2: Tambah `savePhotoResultToDiary`**

Bangun payload `foodDiaryBatch` dari `items` (map `foodName`, `portion: "${weightGram} g"`, `weightGram`, `...values.toJson()`), POST, lalu `loadSummary`.

- [ ] **Step 3: Format + analyze + test**

Run: `dart format lib/providers/nutrition_provider.dart && flutter analyze && flutter test test/nutrition_provider_test.dart`
Expected: PASS.

- [ ] **Step 4: Commit**

```bash
git add lib/providers/nutrition_provider.dart
git commit -m "feat(nutrition): add photo analysis provider flow"
```

### Task 8: UI kalkulator foto + form konsultasi sederhana

**Files:**
- Modify: `lib/screens/nutrition/nutrition_calculator_screen.dart`
- Modify: `lib/screens/consultation/consultation_screen.dart`

**Interfaces:**
- Consumes: `NutritionProvider.analyzePhoto`/`savePhotoResultToDiary` (Task 7); endpoint konsultasi baru (Task 2).
- Produces: tab/aksi utama "Analisis Foto" (image_picker kamera/gallery → base64 → hasil → simpan diary) dengan manual tetap fallback; form konsultasi `{ topic, scheduledDate, notes }` + riwayat tanpa nama tenaga medis.

- [ ] **Step 1: Alur foto di `nutrition_calculator_screen.dart`**

Tambah tombol/aksi utama "Analisis Foto" menggunakan `image_picker` (param `maxWidth: 1280, imageQuality: 70`), baca bytes → base64 → `provider.analyzePhoto` → tampilkan `photoResult` (daftar item + total vs target + label "Perkiraan dari foto") → tombol "Simpan ke Diary" (pilih tanggal + meal slot) memanggil `savePhotoResultToDiary`.

- [ ] **Step 2: Sederhanakan `consultation_screen.dart`**

Hapus kartu role, picker, sheet detail, dan `_fetchSpecialists`. Ganti dengan satu form: `topik` (TextField), `tanggal` (date picker `showDatePicker`), `catatan` (opsional). POST `{ topic, scheduledDate: 'yyyy-MM-dd', notes }`. Riwayat menampilkan `topic` + `scheduledDate` + status.

- [ ] **Step 3: Format + analyze + test**

Run: `dart format lib/screens/nutrition/nutrition_calculator_screen.dart lib/screens/consultation/consultation_screen.dart && flutter analyze && flutter test`
Expected: PASS.

- [ ] **Step 4: Commit**

```bash
git add lib/screens/nutrition/nutrition_calculator_screen.dart lib/screens/consultation/consultation_screen.dart
git commit -m "feat(ui): add photo nutrition flow and simplify consultation form"
```

---

## Urutan Eksekusi & Verifikasi Akhir

1. Task 1 → 2 → 3 → 4 (backend), lalu Task 5 (web), lalu Task 6 → 7 → 8 (mobile).
2. Verifikasi akhir backend: `bun run lint && bun run typecheck && bun run build`.
3. Verifikasi akhir mobile: `flutter analyze && flutter test`.
4. Pastikan tidak ada referensi tersisa ke `specialistType`/`specialistName`/`medicalPersonnel`/`/consultations/specialists` (grep).
