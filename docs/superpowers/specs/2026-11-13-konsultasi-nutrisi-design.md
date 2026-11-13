# Design — Sederhanakan Konsultasi & Nutrisi Berbasis AI

Tanggal: 2026-11-13
Status: Draft (menunggu persetujuan)
Repositori terdampak: `Si-Cehat-mobile` (Flutter) dan `Si-Cehat` (Bun/Hono backend + web admin)

---

## 1. Intent & Alasan (Why)

Dua perubahan produk yang diputuskan bersama tim:

1. **Konsultasi disederhanakan.** Pemilihan tenaga medis per kategori (Bidan / Ahli Gizi / Dokter) dihilangkan. Di mobile, pengguna cukup mengisi formulir (topik + tanggal + catatan) tanpa memilih tenaga medis. Di web admin, fitur menambah/mengelola tenaga medis (master data) dihapus.
2. **Kalkulator nutrisi berbasis AI.** Input manual diganti alur utama "foto → AI analisis → hasil asupan". Target gizi harian tidak lagi dari umur saja, melainkan diturunkan dari data pengukuran TB/BB anak (dengan asumsi edukatif).

Tujuan produk: mengurangi beban input ibu, menghilangkan kompleksitas direktori tenaga medis yang belum punya operasi nyata, dan memanfaatkan foto untuk pencatatan asupan yang lebih mudah.

## 2. Goals / Non-goals / Anti-goals

**Goals**
- Mobile: form konsultasi menjadi 1 alur sederhana (topik, tanggal, catatan) + riwayat.
- Web admin: tidak ada lagi CRUD "Tenaga Medis"; daftar telekonsultasi tetap terlihat.
- Mobile: kalkulator nutrisi punya alur utama foto → hasil (food items + total vs target), bisa disimpan ke diary.
- Backend: endpoint analisis foto + target gizi dari TB/BB.
- Migrasi DB bersih (kolom & tabel yang tidak terpakai dihapus), data lama tetap valid.

**Non-goals**
- Tidak membangun fitur telekonsultasi real-time / penjadwalan dengan tenaga medis.
- Tidak membangun model AI custom / training sendiri (pakai provider vision yang ada).
- Tidak mengganti manual input sepenuhnya (tetap fallback).
- Tidak mengklaim target gizi/AI sebagai angka klinis.

**Anti-goals (dianggap gagal walau teknis jalan)**
- Data konsultasi lama rusak/terhapus saat migrasi.
- Aplikasi menjadi wajib-online untuk pencatatan (manual fallback harus tetap jalan offline).
- Angka AI/target tampil seolah diagnosis medis tanpa label edukatif.
- API lama yang masih dipakai klien lain rusak diam-diam (harus ada kontrak baru yang jelas).

## 3. Constraints

- **Dua repo terpisah**; perubahan backend + web dan mobile harus dirilis selaras (mobile bergantung kontrak API baru).
- **AI saat ini teks-only** OpenAI-compatible (`/chat/completions`, model `gpt-4o-mini`). Analisis foto butuh model vision. Provider harus mendukung input gambar; bila tidak, fitur foto harus gagal dengan pesan jelas dan mobile fallback ke manual.
- **Tanpa standar klinis** di repo untuk target gizi dari TB/BB → wajib memakai asumsi edukatif yang eksplisit dan berlabel.
- **Migrasi**: Drizzle ORM (`drizzle-kit generate` ke `./drizzle`, `drizzle-kit push`/migrate). Kolom yang di-drop harus dipastikan tidak dipakai di tempat lain dulu.
- **NFR-09** (PRD mobile): tanggal kalender tidak boleh bergeser karena konversi zona waktu → `scheduledDate` disimpan sebagai teks `YYYY-MM-DD` (date-only, bukan timestamp UTC).
- **Keamanan/privasi**: foto makanan anak adalah data sensitif; jangan di-log, dikirim hanya ke endpoint sendiri via base64 (pola sama seperti avatar), dan jangan masuk analytics/crash/APK.

## 4. Approaches (yang dipertimbangkan & dipilih)

### 4.1 Konsultasi — skema data
- **A. Drop kolom `specialistType` + `specialistName`** (DIPILIH). Bersih, konsisten dengan penghapusan fitur pemilihan tenaga medis. Konsekuensi: list admin "Manajemen Telekonsultasi" harus di-update (tidak lagi menampilkan keduanya).
- B. Jadikan nullable + stop tulis. Lebih aman jangka pendek tapi menyisakan data placeholder dan kolom mati.
- C. Isi 'UMUM'. Tanpa migrasi struktural tapi data tidak jujur.

### 4.2 Konsultasi — tabel `medicalPersonnel`
Setelah pemilihan tenaga medis dihapus, tabel ini tidak dipakai siapa pun. DIPILIH: **drop tabel `medicalPersonnel` + relasinya + route admin specialists + `GET /api/consultations/specialists` + konstanta fallback `SPECIALISTS`**. Ini keputusan builder (bukan keputusan produk terpisah) karena konsisten dengan pilihan "drop kolom". Catatan: bila tim ingin menyimpan data ini untuk dipakai lagi nanti, tabel bisa dibiarkan dormant — sampaikan saat review.

### 4.3 Nutrisi — pipeline AI foto
- **A. AI vision → daftar makanan + estimasi porsi → petakan ke katalog (`matchFoodName`) → hitung makro via `scaleNutrition` → total vs target** (DIPILIH). Konsisten dengan katalog & perhitungan yang sudah ada; hasil deterministik dan bisa disimpan ke diary.
- B. AI langsung keluarkan makro penuh (tanpa katalog). Lebih sederhana di backend tapi tidak konsisten dengan data katalog dan lebih sulit diaudit.
- C. Hybrid (AI + katalog bila cocok, else estimasi AI). Sebenarnya A sudah menyertakan fallback generik saat tidak cocok, jadi C ≈ A.

### 4.4 Nutrisi — target dari TB/BB
- **A. Kalori dari berat badan (kcal/kg/hari per kelompok umur) + makro dari pembagian % baku** (DIPILIH, sesuai jawaban).
- B. Berbasis BMI. Lebih "relevan" tapi lebih kompleks dan tetap asumsi.
- C. TB/BB bila ada, else AKG-umur. (Ini jadi perilaku fallback di dalam A, bukan pendekatan terpisah.)

## 5. Keputusan yang disepakati (dari diskusi)

| # | Keputusan | Pilihan |
|---|---|---|
| 1 | Kolom `specialistType`/`specialistName` | Drop |
| 2 | Format tanggal konsultasi | Tanggal saja (`YYYY-MM-DD`) |
| 3 | Cakupan web admin | Hapus CRUD + UI master tenaga medis; sisakan daftar telekonsultasi |
| 4 | Input manual nutrisi | Foto utama, manual fallback |
| 5 | Asumsi target gizi | Kalori dari berat badan |

## 6. Detail Implementasi (yang sudah diputuskan)

### 6.1 Backend — Konsultasi

**Skema (`src/server/db/schema.ts`)**
- `consultations`: hapus `specialistType`, `specialistName`; tambah `scheduledDate: text("scheduledDate").notNull()`.
- Hapus `medicalPersonnel` beserta relasi `medicalPersonnel` (tidak ada relasi eksplisit; hanya tabel berdiri).
- `Consultation.status` default tetap `"PENDING"`; pada create set `"PENDING"`.

**Route (`parent.routes.ts`)**
- `createConsultationSchema` baru: `{ topic: string (3–200), scheduledDate: string YYYY-MM-DD (wajib), notes: string (opsional, ≤1000) }`.
- `POST /api/consultations`: insert `{ guardianId, topic, scheduledDate, notes, status: "PENDING" }`; notifikasi `createNotification` tetap dibuat (tanpa nama tenaga medis).
- `GET /api/consultations`: tetap (baris tidak lagi punya specialistType/Name).
- Hapus `GET /api/consultations/specialists` dan konstanta `SPECIALISTS`.

**Route admin (`admin.routes.ts`)**
- Hapus `specialistSchema` + `GET/POST/PUT/DELETE /api/admin/specialists`.
- `GET /api/admin/metrics`: groupBy `consultations.status` tetap aman (tidak menyentuh specialistType).

**Seed (`db/seed.ts`)**: hapus penyisipan `medicalPersonnel` **dan** baris seed `consultations` yang memakai `specialistType`/`specialistName` (baris ~212–230); ganti dengan `scheduledDate`.

**Migrasi**: `bun run db:generate` (SQL di `./drizzle`), lalu `drizzle-kit push`/migrate.

### 6.2 Mobile — Konsultasi

**`lib/screens/consultation/consultation_screen.dart`**
- Hapus 3 kartu role, picker spesialis, sheet detail, dan `_fetchSpecialists`.
- Ganti dengan 1 form: `topik` (TextField), `tanggal konsultasi` (date picker), `catatan` (opsional).
- `_requestConsultation` → POST `{ topic, scheduledDate, notes }`.
- Riwayat: tampilkan `topic` + `scheduledDate` + status; hapus pemakaian `specialistName`.
- Hapus fallback lokal yang menyebut nama tenaga medis.

**`lib/core/api/api_constants.dart`**: hapus `specialists`.

### 6.3 Web admin — Konsultasi

**`src/app/admin/AdminDashboardClient.tsx`**
- Hapus seksi "Master Tenaga Medis" + form modal + `SpecialistItem` type + seluruh state/handler specialist.
- Hapus seksi "Petugas / Tenaga Medis".
- Update tipe `Consultation`: hapus `specialistType`/`specialistName`, tambah `scheduledDate`.
- Update "Manajemen Telekonsultasi": ganti tampilan `c.specialistType - c.specialistName` → `c.topic` + `c.scheduledDate` + status.

**Dokumentasi API**: perbarui `API_DOCUMENTATION.md` dan `src/app/api-docs/page.tsx` (hapus contoh `specialistType`/`specialistName`/`/consultations/specialists`; tambah `scheduledDate`).

### 6.4 Backend — Nutrisi AI

**Service vision baru (`src/server/services/vision.ts`)**
- Fungsi `analyzeFoodPhoto({ imageBase64, childId })`:
  1. Ambil `getResolvedBotConfig()`; pakai `VISION_MODEL` env (fallback `AI_MODEL`/`gpt-4o-mini`).
  2. Kirim ke `${baseUrl}/chat/completions` dengan konten multimodal (image_url base64 + prompt terstruktur JSON).
  3. Parsing JSON → `[{ name, weightGram }]`. Bila gagal/`mock`/tanpa apiKey → lempar error bertipe khusus agar route mengembalikan 503.
  4. Untuk tiap item: `resolveFoodItem`/`matchFoodName` ke katalog → `scaleNutrition`; bila tidak cocok → estimasi generik (`GENERIC_FOOD`) dengan `isEstimate: true`.
  5. Hitung `totals`; bila `childId` diberikan, hitung `target` + `percent`.
- Prompt wajib memuat batas keamanan (estimasi, bukan diagnosis) dan meminta output JSON ketat.

**Route (`nutrition.routes.ts`)**
- `POST /api/nutrition/analyze-photo` (auth): body `{ imageBase64: string, childId?: uuid }`. Validasi ukuran base64 (batas mis. ~8 MB). Return `{ items, totals, target?, percent?, note }`.
- Rate-limit: tambahkan ke `aiChatRateLimiter`-like (opsional; setidaknya jangan lebih longgar dari chat).

**Target dari TB/BB**
- Tambah `getTargetFromMeasurement(weightKg, heightCm, ageYears)` di `services/nutrition.ts` (tanpa gender agar sederhana):
  - `kcalPerKg`: 85 (umur <7), 75 (7–9), 65 (10–12), 55 (≥13).
  - `caloriesKkal = round(weightKg * kcalPerKg)`.
  - Makro: protein 20%, lemak 30%, karbohidrat 50% kalori (4/4/9 kcal/g). `sugarGram` tetap 25 (maks edukatif). `fiberGram` ambil dari `getDefaultTarget(age)`.
- Ubah `getOrCreateNutritionTarget(childId)`:
  - Ambil pengukuran terakhir `growthMeasurements` (weightKg, heightCm) + `children.birthDate`/`gender`.
  - Bila ada pengukuran → hitung target TB/BB dengan `source: "ANTROPOMETRI"`, upsert ke `nutritionTargets` (kecuali `source === "MANUAL"` tidak ditimpa).
  - Bila tidak ada pengukuran → fallback `getDefaultTarget(age)` dengan `source: "AKG"` (perilaku lama).
- `GET /api/nutrition/target` juga mengembalikan `source` dan (opsional) `basis` (berat/tinggi yang dipakai) agar mobile bisa menampilkan label. `defaults` yang ikut dikembalikan harus mencerminkan basis yang sama (TB/BB bila ada, else AKG-umur).

**Env/config**
- Tambah `VISION_MODEL` opsional di `env.ts` (default `gpt-4o-mini`).
- `bot-config.ts` tidak wajib diubah; `vision.ts` membaca `VISION_MODEL || model`.

### 6.5 Mobile — Nutrisi AI

**`lib/core/api/api_constants.dart`**: tambah `nutritionAnalyzePhoto = '/api/nutrition/analyze-photo'`.

**`lib/providers/nutrition_provider.dart`**
- Tambah state `isAnalyzingPhoto`, `photoResult` (model baru), dan method `analyzePhoto(String imageBase64, String childId)` → POST endpoint, parse `{ items, totals, target, percent }`.
- Tambah `savePhotoResultToDiary(childId, date, mealSlot, items)` → reuse `POST /api/food-diary/batch` (payload per item sudah kompatibel: `foodName`, `portion`, `weightGram`, makro).

**`lib/data/models/nutrition_model.dart`**
- Tambah `PhotoAnalysisResult` (items: `List<NutritionEntry>`/daftar makanan + total + target). Reuse `NutritionValues`.

**`lib/screens/nutrition/nutrition_calculator_screen.dart`**
- Tambah tab/aksi utama "Analisis Foto" (di atas atau sebagai tab pertama): tombol ambil foto (kamera/gallery via `image_picker`), tampilkan loading, hasil (daftar makanan terdeteksi + estimasi berat + total vs target), tombol "Simpan ke Diary" (pilih tanggal + meal slot).
- Kompresi foto memakai parameter bawaan `image_picker` (`maxWidth`, `imageQuality`) agar payload kecil — tidak menambah dependency.
- Pertahankan tab "Hitung Cepat" & "Susun Asupan" sebagai fallback manual.
- Label target: tampilkan sumber target ("dari data pengukuran" vs "AKG") + disclaimer edukatif.

**`lib/data/local_food_catalog.dart`**: tidak wajib berubah.

## 7. Batas Keamanan & Label

- Hasil AI foto = **estimasi**, bukan diagnosis; wajib ditampilkan dengan label "Perkiraan dari foto, bukan nilai pasti gizi".
- Target dari TB/BB = asumsi edukatif; label "Target edukatif, konsultasikan dengan tenaga kesehatan".
- Foto tidak di-log dan tidak disimpan permanen di server (hanya diproses transien); bila nanti ingin menyimpan, itu keputusan baru (butuh consent/retensi).

## 8. Risiko & Catatan Platform

- **Provider vision**: `gpt-4o-mini` mendukung input gambar, tapi provider OpenAI-compatible lain mungkin tidak. Fitur foto harus menangani 503 → mobile fallback manual. (Follow-up: verifikasi provider produksi mendukung vision.)
- **Migrasi drop kolom/tabel**: pastikan `drizzle-kit generate` tidak menghapus data lain; `scheduledDate` diisi untuk baris lama → pakai default tanggal sekarang atau migrasi backfill. (Builder call: backfill `scheduledDate` = `createdAt` saat baris lama null.)
- **Rilis selaras**: mobile lama mengirim `specialistType` ke endpoint baru → backend mengabaikan field asing (zod `safeParse` default strip? tidak — zod strict? gunakan `z.object` non-strict sehingga field tambahan diabaikan) untuk menghindari 400 pada klien lama.
- **Test**: update test mobile yang menyentuh konsultasi/nutrisi; tambah test untuk `getTargetFromMeasurement` dan parsing hasil vision (mock).

## 9. Yang diserahkan ke builder (belum final, keputusan minor)

- Nama kolom/endpoint final (`scheduledDate`, `/analyze-photo`).
- Batas ukuran base64 (≈8 MB) dan strategi kompresi mobile.
- Detail prompt vision (struktur JSON persis).
- `status` konsultasi create = `PENDING` (sebelumnya `ACTIVE`).
- Backfill `scheduledDate` untuk baris lama.
