# Design — Modul Nutrisi & Notifikasi Aplikasi

> **Tanggal:** 28 Oktober 2026
> **Status:** Draft — menunggu approval
> **Repo utama:** `si_cehat_mobile` (Flutter)
> **Repo terkait:** `../Si-Cehat` (Bun + Hono + Drizzle, web admin)
> **Topik:** modul kalkulasi nutrisi + local reminder + FCM

---

## 1. Intent & Why

Aplikasi sudah punya kalkulator nutrisi satu-bahan dan pusat notifikasi in-app,
tetapi:

- Kalkulasi tidak bisa menggabungkan beberapa makanan menjadi total asupan.
- Tidak ada target harian anak, riwayat, atau integrasi simpan ke food diary.
- Data makanan terduplikasi di mobile (22 item hardcoded) dan backend (±25 item
  hardcoded), tanpa endpoint katalog.
- Pengingat hanya dicek `Timer` selama aplikasi terbuka; tidak ada notifikasi OS.
- Belum ada push dari server (FCM), sehingga event seperti konsultasi/PlayLab
  hanya terlihat saat aplikasi dibuka.

Tujuan: satu modul nutrisi yang fleksibel (satu bahan maupun banyak item),
target AKG manual, ringkasan harian, dan notifikasi dua lapis (local reminder +
FCM) yang menyatu dengan pusat notifikasi yang sudah ada.

---

## 2. Goals

1. Katalog makanan tunggal di backend, bisa dicari dan dipakai mobile.
2. Kalkulasi satu item **dan** batch item (satu kali makan / total harian).
3. Target harian per anak berbasis AKG umum, dapat diedit manual.
4. Ringkasan harian: total asupan vs target + sisa + persentase.
5. Simpan hasil batch ke food diary (atomik, per meal slot).
6. Local OS notification untuk reminder, tetap muncul walau app ditutup.
7. FCM push untuk event server, masuk ke pusat notifikasi in-app.
8. Fallback offline: kalkulasi lokal dan cache notifikasi tetap bekerja.

## 3. Non-goals

- Diagnosis medis, resep, atau klaim terapi.
- Perhitungan target otomatis dari antropometri (BB/TB/usia) — user memilih
  target AKG manual.
- Scan barcode / foto makanan.
- Manajemen katalog makanan lewat web admin (fase berikutnya; sekarang seed).
- iOS (repo belum punya folder `ios/`).
- Penjadwal cloud untuk reminder (local scheduling cukup).

## 4. Anti-goals

- Menimpa XP/streak atau food log yang ditulis fitur lain.
- Mengirim notifikasi ganda (OS + in-app + push untuk event yang sama).
- Mewajibkan jaringan untuk reminder harian.
- Menyimpan kredensial Firebase di repo.
- Mengklaim angka AKG sebagai preskripsi medis.

---

## 5. Current State (yang sudah ada)

### Mobile
- `lib/screens/nutrition/nutrition_calculator_screen.dart` (1.278 baris):
  - Dua mode UI: input manual dan daftar makanan.
  - 22 item `_defaultFoods` (nama, kategori, kalori, karbo, protein, lemak,
    serat, gula, emoji, porsi).
  - Unit: gram, porsi (150 g), potong/butir (60 g), gelas (200 g).
  - `POST /api/nutrition/calculate` dengan fallback kalkulasi lokal.
  - Tidak menyimpan hasil, tidak ada target/riwayat.
- `lib/screens/diary/food_diary_screen.dart`: `GET/POST /api/food-diary`,
  item nutrisi opsional; belum mengirim gula/serat.
- `lib/providers/reminder_provider.dart` + `lib/core/services/reminder_service.dart`:
  - Timer 20 detik, hanya saat app hidup; menulis ke notification center lokal.
  - Stream `onReminderTriggered` tidak punya listener.
- `NotificationProvider` sudah sinkron ke `GET/PATCH/DELETE /api/notifications`
  dan `POST /api/notifications/read-all`, dengan cache SQLite.
- `pubspec.yaml` belum punya `flutter_local_notifications`, `timezone`,
  `firebase_core`, atau `firebase_messaging`.

### Backend (`../Si-Cehat`)
- `POST /api/nutrition/calculate` memakai `FOOD_NUTRITION_DB` hardcoded,
  fuzzy match sederhana, fallback 120 kkal. Tidak ada GET katalog.
- Tabel `DetailedFoodLog`: `caloriesKkal`, `carbsGram`, `proteinGram`,
  `fatGram` (belum ada gula/serat, belum ada `foodItemId`).
- `Notification` table + route notifikasi + `createNotification` sudah ada.
- Belum ada `FoodItem`, `NutritionTarget`, atau `DeviceToken`.
- Belum ada dependency `firebase-admin` atau konfigurasi Firebase.
- Web admin memakai endpoint `/api/admin/*` yang sudah ada; tidak diubah.

---

## 6. Approaches (sudah dipilih)

### Nutrisi
- **A. Perluas kalkulator lokal saja** — cepat, tetapi data terduplikasi dan
  tidak sinkron. Ditolak.
- **B. Modul penuh di server + cache mobile (DIPILIH)** — satu sumber data,
  batch, target per anak, integrasi diary. Lebih banyak kerja tetapi memenuhi
  "fleksibel".
- **C. Hybrid offline-first dengan katalog JSON** — ringan, tetapi update data
  harus lewat rilis app. Ditolak.

### Notifikasi
- **A. Local-only** — cukup untuk reminder, tanpa push server. Ditolak karena
  user butuh FCM.
- **B. FCM-only** — reminder bergantung jaringan. Ditolak.
- **C. Hybrid local + FCM (DIPILIH)** — local untuk jadwal, FCM untuk event.

---

## 7. Nutrition Module

### 7.1 UX Mobile

`NutritionCalculatorScreen` tetap menjadi entry point (dipanggil dari Home),
tetapi dipecah menjadi dua tab utama + satu kartu ringkasan:

1. **Hitung Cepat**
   - Pilih makanan (search/autocomplete dari katalog).
   - Jumlah + satuan (gram/porsi/potong/butir/gelas) + cara pengolahan.
   - Hasil: kalori, karbo, protein, lemak, serat, gula.
   - Tombol "Tambahkan ke Asupan" (memindahkan item ke tab Susun Asupan).
2. **Susun Asupan**
   - Daftar item yang ditambahkan (bisa ubah berat/hapus).
   - Pilih tanggal dan meal slot (sarapan/siang/camilan/malam).
   - Total asupan berjalan.
   - Perbandingan dengan target harian (progress bar per nutrien).
   - Tombol "Simpan ke Diary" (batch).
   - Tombol "Atur Target" membuka editor.
3. **Kartu Ringkasan Harian**
   - Total hari ini vs target (kalori + 5 nutrien).
   - Sisa/kelebihan dan persentase.
   - Sumber: entri food diary tanggal tersebut.

Empty/offline state: jika katalog gagal dimuat, gunakan 22 item lokal sebagai
fallback dan tampilkan banner "Data katalog offline".

### 7.2 Data Model (backend)

Tambahan di `src/server/db/schema.ts`:

```ts
export const foodItems = pgTable("FoodItem", {
  id: text("id").primaryKey().$defaultFn(uuidDefault),
  name: text("name").notNull(),
  aliases: text("aliases"), // dipisah koma, untuk pencarian
  category: text("category").notNull(), // makanan_pokok|lauk_pauk|sayuran|buah|minuman_camilan
  caloriesKkal: integer("caloriesKkal").notNull(), // per 100 g
  carbsGram: doublePrecision("carbsGram").notNull().default(0),
  proteinGram: doublePrecision("proteinGram").notNull().default(0),
  fatGram: doublePrecision("fatGram").notNull().default(0),
  sugarGram: doublePrecision("sugarGram").notNull().default(0),
  fiberGram: doublePrecision("fiberGram").notNull().default(0),
  portionDescription: text("portionDescription").notNull().default("100 g"),
  isActive: boolean("isActive").notNull().default(true),
  createdAt: timestamp("createdAt", { mode: "date" }).notNull().defaultNow(),
});

export const nutritionTargets = pgTable("NutritionTarget", {
  id: text("id").primaryKey().$defaultFn(uuidDefault),
  childId: text("childId")
    .notNull()
    .unique()
    .references(() => children.id, { onDelete: "cascade", onUpdate: "cascade" }),
  caloriesKkal: integer("caloriesKkal").notNull(),
  carbsGram: doublePrecision("carbsGram").notNull(),
  proteinGram: doublePrecision("proteinGram").notNull(),
  fatGram: doublePrecision("fatGram").notNull(),
  sugarGram: doublePrecision("sugarGram").notNull(),
  fiberGram: doublePrecision("fiberGram").notNull(),
  source: text("source").notNull().default("AKG"), // AKG | MANUAL
  updatedAt: timestamp("updatedAt", { mode: "date" })
    .notNull()
    .$defaultFn(() => new Date()),
});
```

`DetailedFoodLog` ditambah:
- `foodItemId text` (nullable, tanpa FK ketat agar seed/legacy tidak rusak)
- `sugarGram doublePrecision`
- `fiberGram doublePrecision`

`DeviceToken` (lihat bagian notifikasi).

### 7.3 Data Seed

- Pindahkan `FOOD_NUTRITION_DB` backend + 22 item mobile ke satu array
  `src/server/services/food-data.ts` (versi `1.0.0`).
- Aturan merge: nilai **backend menjadi kanonik**; item mobile yang belum ada
  ditambahkan. Duplikasi dideteksi dari nama ternormalisasi (lowercase, trim).
  Jika ada konflik nilai, backend menang dan konflik dicatat di log seed.
- Seed idempotent berdasarkan `name` (upsert), dijalankan lewat
  `bun run db:seed`.
- Kategori ditentukan dari mapping eksplisit per item; item tanpa mapping
  masuk `makanan_pokok`.
- Tidak memakai emoji (kebijakan zero-emoticon); mobile memilih ikon Material
  berdasarkan kategori.

### 7.4 API Contracts

Semua endpoint nutrisi memakai prefix `/api/nutrition`.

#### `GET /api/nutrition/foods`
- Auth: publik (katalog).
- Query: `search?`, `category?`, `limit?` (default 100, max 200).
- Response:
```json
{
  "foods": [
    {
      "id": "uuid",
      "name": "Nasi Putih",
      "aliases": "nasi, beras putih",
      "category": "makanan_pokok",
      "caloriesKkal": 130,
      "carbsGram": 28,
      "proteinGram": 2.7,
      "fatGram": 0.3,
      "sugarGram": 0.1,
      "fiberGram": 0.4,
      "portionDescription": "1 centong (100g)"
    }
  ]
}
```

#### `POST /api/nutrition/calculate` (backward compatible)
- Body:
  - `foodId?` (prioritas), `foodName?`, `weightGram?` (default 100).
  - Konversi satuan dilakukan di mobile; server hanya menerima gram.
- Response: field lama tetap ada (`foodName`, `weightGram`, `caloriesKkal`,
  `carbsGram`, `proteinGram`, `fatGram`, `sugarGram`, `fiberGram`, `note`)
  + `foodId?`.
- Jika `foodId`/nama tidak ditemukan: fallback data generik (perilaku lama)
  dengan `isEstimate: true`.

#### `POST /api/nutrition/calculate-batch`
- Auth: publik untuk kalkulasi murni. `childId` hanya dipakai bila ada sesi
  login yang valid dan anak itu milik guardian; tanpa sesi, `childId`
  diabaikan (tidak ada `target`/`percent` di respons).
- Body:
```json
{
  "childId": "uuid-opsional",
  "items": [
    { "foodId": "uuid", "weightGram": 150 },
    { "foodName": "Tempe Goreng", "weightGram": 50 }
  ]
}
```
- Response:
```json
{
  "items": [{ "foodId": "...", "foodName": "...", "weightGram": 150,
              "caloriesKkal": 195, "carbsGram": 42, "proteinGram": 4.1,
              "fatGram": 0.5, "sugarGram": 0.2, "fiberGram": 0.6 }],
  "totals": { "caloriesKkal": 305, "carbsGram": 49, "proteinGram": 13,
              "fatGram": 8, "sugarGram": 1, "fiberGram": 2 },
  "target": { ... } | null,
  "percent": { "caloriesKkal": 18, ... } | null
}
```
- Pembulatan: kalori integer; makro 1 desimal.

#### `GET /api/nutrition/target?childId=`
- Auth: wajib.
- Validasi anak milik guardian.
- Jika target belum ada: buat default AKG sesuai kelompok usia anak
  (lihat 7.6), simpan, kembalikan.
- Response: `{ "target": {...}, "defaults": {...} }`.

#### `PUT /api/nutrition/target`
- Auth: wajib.
- Body: `childId` + 6 nilai target (angka ≥ 0, kalori ≤ 5000).
- Menyimpan `source = "MANUAL"` dan `updatedAt`.
- Response: `{ "success": true, "target": {...} }`.

#### `GET /api/nutrition/summary?childId=&date=`
- Auth: wajib.
- Menjumlahkan `DetailedFoodLog` pada tanggal tersebut.
- Response: `{ date, childId, entries, totals, target, remaining, percent }`.
- Tanggal: mobile mengirim `yyyy-MM-dd` berdasarkan tanggal **lokal**
  pengguna; backend mem-parse sebagai UTC midnight agar konsisten dengan
  penyimpanan tracker/food diary yang sudah ada. Jika `date` kosong, backend
  memakai tanggal UTC hari ini.

#### `POST /api/food-diary/batch`
- Auth: wajib.
- Body: `{ childId, date?, mealSlot, items: [{ foodItemId?, foodName,
  portion?, weightGram?, caloriesKkal?, carbsGram?, proteinGram?, fatGram?,
  sugarGram?, fiberGram? }] }`.
- Simpan semua item dalam satu transaksi; response `{ success, items }`.
- `POST /api/food-diary` lama tetap dipertahankan.

### 7.5 Kalkulasi & Aturan

- Sumber nutrisi per 100 g; hasil = nilai × `weightGram / 100`.
- Konversi satuan di mobile (sama dengan perilaku sekarang):
  - gram = nilai apa adanya
  - porsi = 150 g
  - potong/butir = 60 g
  - gelas = 200 g
- Batch = penjumlahan item; tidak ada pembobotan tambahan.
- Persentase target = `min(999, round(total / target * 100))`; target 0
  menghasilkan `null` (hindari divide by zero).
- Fuzzy match nama: exact → alias exact → contains (case-insensitive) →
  fallback generik. Dipertahankan dari implementasi lama.

### 7.6 Default Target AKG (edukatif, dapat diedit)

Disimpan sebagai konstanta berversi di backend, bukan angka medis final:

| Kelompok usia | Kalori | Protein | Lemak | Karbo | Serat | Gula |
|---|---|---|---|---|---|---|
| 4–6 | 1600 kkal | 40 g | 55 g | 220 g | 22 g | 25 g |
| 7–9 | 1650 kkal | 45 g | 55 g | 250 g | 23 g | 25 g |
| 10–12 | 2000 kkal | 50 g | 65 g | 300 g | 28 g | 25 g |

- Sumber acuan: AKG umum (edukatif), bukan preskripsi.
- UI menampilkan disclaimer: "Angka target bersifat edukatif dan dapat
  disesuaikan. Konsultasikan dengan tenaga kesehatan."
- Usia dihitung dari `birthDate`; jika kosong, default 7–9.
- Builder wajib memverifikasi angka dengan ahli gizi sebelum rilis produksi;
  nilai di atas adalah default yang dapat diubah tanpa migrasi.

### 7.7 Mobile Architecture

Mengikuti struktur repo yang ada (bukan feature-folder baru):

| File | Isi |
|---|---|
| `lib/data/models/nutrition_model.dart` | `FoodItem`, `NutritionTarget`, `NutritionTotals`, `NutritionSummary`, `NutritionCalculation` |
| `lib/providers/nutrition_provider.dart` | katalog, target, ringkasan, draft batch, save |
| `lib/screens/nutrition/nutrition_calculator_screen.dart` | dua tab + ringkasan (refactor dari file lama) |
| `lib/screens/nutrition/widgets/` | food picker, target editor, summary card, batch list |
| `lib/core/api/api_constants.dart` | endpoint baru |
| `lib/providers/app_providers.dart` | daftarkan `nutritionProvider` |

Perilaku:
- Load katalog remote; fallback ke 22 item lokal.
- Target & ringkasan di-cache di `SharedPreferences` per child + tanggal.
- Simpan batch: panggil `POST /api/food-diary/batch`. Tombol dinonaktifkan
  selama request berjalan (mencegah double-submit); v1 tidak memakai
  idempotency key di server.
- Jika offline: simpan batch sebagai JSON di `SharedPreferences`
  (`pending_nutrition_batches`), tampilkan status "menunggu sinkronisasi".
  Retry saat layar dibuka dan setelah katalog/target berhasil dimuat;
  entri bersifat append-only (tidak ada resolusi konflik).
- Setelah simpan: refresh ringkasan + diary.
- `GET /api/food-diary` harus mengembalikan `sugarGram`/`fiberGram` agar
  tampilan diary bisa menampilkan data baru.

---

## 8. Notifications

### 8.1 Local Reminder (flutter_local_notifications)

- Package: `flutter_local_notifications` + `timezone` + `flutter_timezone`.
- Inisialisasi di `main.dart` sebelum `runApp`:
  `tz.initializeTimeZones()`, lalu set lokasi dari `flutter_timezone`
  (`getLocalTimezone()`), fallback ke `tz.local` bila gagal.
- Channel Android:
  - `reminders` (importance high, sound default)
  - `general` (importance default, untuk FCM foreground)
- Penjadwalan:
  - Satu notifikasi per reminder aktif.
  - `zonedSchedule` harian dengan `matchDateTimeComponents:
    DateTimeComponents.time`.
  - `AndroidScheduleMode.inexactAllowWhileIdle` (tanpa izin exact alarm;
    toleransi beberapa menit dapat diterima untuk pengingat harian).
  - Notification ID stabil: `reminder.id.toString().hashCode & 0x7fffffff`
    agar cancel/reschedule konsisten (collision sangat kecil; dicatat di
    debug log bila terjadi).
- Reschedule:
  - Saat app start (`loadReminders` selesai).
  - Setelah create/update/toggle/delete reminder.
  - `cancelAll()` lalu jadwalkan ulang seluruh reminder aktif (idempotent).
- Timer `ReminderService` lama:
  - Dihentikan sebagai penjadwal notifikasi OS.
  - Stream `onReminderTriggered` tetap ada untuk banner in-app opsional,
    tetapi tidak menulis notifikasi OS (hindari duplikasi).
  - Notification center tetap menerima notifikasi server; reminder lokal
    tidak membuat entri baru di DB notification center.
- Tap handling:
  - Payload `{ "type": "REMINDER", "reminderId": "..." }`.
  - Global `navigatorKey` di `SiCehatApp`; tap membuka `ReminderScreen`.
- Android config:
  - `POST_NOTIFICATIONS` permission (Android 13+). Permintaan izin dipicu
    saat pengguna pertama kali membuka tab Reminder (bukan saat cold start),
    dengan penjelasan singkat. Jika ditolak, tampilkan banner "Aktifkan
    notifikasi di pengaturan" dan jangan blokir fitur reminder.
  - `RECEIVE_BOOT_COMPLETED` + receiver plugin untuk reschedule setelah reboot.
  - Desugaring: `coreLibraryDesugaringEnabled = true` +
    `com.android.tools:desugar_jdk_libs`.
  - Cek `areNotificationsEnabled()` sebelum menjadwalkan; log peringatan
    bila izin belum diberikan.
- iOS tidak diimplementasikan (tidak ada folder `ios/`).

### 8.2 FCM Push

#### Backend
- Dependency: `firebase-admin`.
- Env baru (opsional; jika kosong, push dinonaktifkan tanpa memecahkan API):
  - `FIREBASE_SERVICE_ACCOUNT_JSON` (JSON string), **atau**
  - `GOOGLE_APPLICATION_CREDENTIALS` (path file).
- Tabel:
```ts
export const deviceTokens = pgTable("DeviceToken", {
  id: text("id").primaryKey().$defaultFn(uuidDefault),
  guardianId: text("guardianId").notNull()
    .references(() => guardians.id, { onDelete: "cascade", onUpdate: "cascade" }),
  token: text("token").notNull().unique(),
  platform: text("platform").notNull().default("android"),
  createdAt: timestamp("createdAt", { mode: "date" }).notNull().defaultNow(),
  lastSeenAt: timestamp("lastSeenAt", { mode: "date" }).notNull().defaultNow(),
});
```
- Endpoint:
  - `POST /api/notifications/devices` — auth, body `{ token, platform? }`,
    upsert berdasarkan token.
  - `DELETE /api/notifications/devices` — auth, body `{ token }`.
- `src/server/services/push.ts`:
  - `initPush()` lazy; return `null` jika credential tidak ada.
  - `sendPushToGuardian(guardianId, { title, body, data })`.
  - Hapus token yang invalid (`messaging/registration-token-not-registered`).
- `createNotification()` memicu `sendPushToGuardian` setelah insert secara
  fire-and-forget (`void` + catch), sehingga latensi FCM tidak menahan
  respons API. Error tidak menggagalkan operasi utama.
- Data payload push: `{ "type": "<NotificationType>", "referenceId": "..." }`.
- Web admin tidak berubah; push otomatis untuk event yang sudah ada
  (registrasi, reminder, konsultasi, PlayLab).

#### Mobile (fase 2, setelah config Firebase tersedia)
- Package: `firebase_core`, `firebase_messaging`.
- `google-services.json` (Android) tidak di-commit jika mengandung rahasia;
  tempatkan sesuai kebijakan repo/deploy.
- `PushNotificationService`:
  - `initialize()`: `Firebase.initializeApp()`, request permission,
    ambil token, kirim ke `POST /api/notifications/devices`, dengarkan
    `onTokenRefresh`.
  - Foreground: tampilkan via local notification channel `general`.
  - Background: sistem menampilkan notifikasi; handler data untuk refresh.
  - Tap saat app hidup: buka `NotificationCenterScreen` dan refresh.
  - Tap saat app terminated: tangani `getInitialMessage()` setelah
    `runApp`/navigator siap.
  - Logout: `DELETE /api/notifications/devices` + hapus token lokal.
- **Fase 1 (sekarang)** tidak menambahkan plugin Firebase ke build karena
  `google-services.json` belum ada. Yang dibuat sekarang:
  - Tabel + endpoint device token.
  - `push.ts` no-op tanpa credential.
  - Interface `PushNotificationService` dengan implementasi no-op.
  Ini menjaga `flutter build apk` tetap hijau. Fase 2 mengaktifkan
  implementasi Firebase setelah config tersedia.

### 8.3 Integrasi Pusat Notifikasi

- `NotificationProvider.loadNotifications()` tetap memuat dari server dan
  cache SQLite.
- FCM foreground/background yang masuk tetap ditampilkan OS; saat user
  membuka pusat notifikasi, data server sudah tersedia.
- Hindari duplikasi: event server hanya dikirim via FCM, bukan local
  notification; reminder lokal tidak membuat notifikasi server.

---

## 9. Cross-cutting

### Error Handling
- Endpoint nutrisi mengembalikan `{ error: { message } }` dengan status
  400/401/403/404/500 konsisten.
- Mobile: fallback katalog lokal, target default, dan kalkulasi lokal bila
  API gagal; tampilkan banner offline, jangan blokir UI.
- Push/gagal kirim tidak menggagalkan create notification.

### Security & Privacy
- Semua data anak/target hanya untuk guardian pemilik (`getSession` +
  validasi `guardianId`).
- Katalog makanan publik (tanpa data pribadi).
- Token FCM disimpan per guardian; hapus saat logout.
- Tidak ada kredensial Firebase di repo; gunakan env/secret manager.

### Observability
- Log `[Nutrition]`, `[Push]`, `[LocalNotification]` dengan level debug.
- Tidak mencatat isi token FCM penuh (mask 8 karakter terakhir).

---

## 10. Migration & Rollout

1. Backend schema: `FoodItem`, `NutritionTarget`, `DeviceToken`,
   `DetailedFoodLog.sugarGram/fiberGram/foodItemId`.
2. Backup database produksi, lalu jalankan `bunx drizzle-kit push` di dev
   dan `bun run db:migrate` di produksi.
3. Seed katalog makanan (`bun run db:seed`).
4. Mobile fase 1: modul nutrisi + local notification; build & test.
5. Mobile fase 2: Firebase config + FCM.
6. Flag `PUSH_ENABLED` (compile-time `bool.fromEnvironment`) hanya untuk
   FCM fase 2; modul nutrisi dan local reminder langsung aktif setelah
   diuji (tanpa flag tambahan).

Backward compatibility:
- `POST /api/nutrition/calculate` dan `POST /api/food-diary` lama tetap.
- Entri diary lama memiliki gula/serat `null` → dianggap 0 saat agregasi.

---

## 11. Testing & Verification

### Backend
- Unit test kalkulasi: exact/alias/fuzzy/fallback, pembulatan, batch totals.
- Unit test default target per kelompok usia.
- Integration live (DB lokal):
  - katalog search/category.
  - calculate single + batch vs target.
  - GET/PUT target (ownership).
  - save batch → summary.
  - device token register/delete; push no-op tanpa credential.
- `bun run typecheck`, `bun test`.

### Mobile
- Unit test model parsing + total/percent + konversi satuan + reminder ID hash.
- Widget test dua tab, target editor, ringkasan, empty/offline state.
- Manual:
  - Jadwalkan reminder 1–2 menit ke depan, tutup app, verifikasi notifikasi OS.
  - Reboot emulator, verifikasi reschedule.
  - Tap notifikasi membuka ReminderScreen.
  - FCM: kirim test message dari Firebase Console (fase 2).
- `flutter analyze`, `flutter test`, `flutter build apk --debug` dan
  `--release`.

---

## 12. Risks & Mitigations

| Risiko | Mitigasi |
|---|---|
| Angka AKG tidak akurat untuk klinis | Label edukatif + disclaimer + editable; review ahli gizi sebelum rilis |
| Firebase config belum ada | Fase 2 terpisah; backend push no-op tanpa credential |
| Notifikasi tidak tepat waktu di OEM tertentu | Gunakan `inexactAllowWhileIdle`, jelaskan toleransi; opsi exact alarm ditunda |
| Duplikasi notifikasi | Satu sumber per event; reminder lokal tidak membuat entri server |
| Data makanan tidak lengkap | Seed dari data lama + fallback estimasi ditandai `isEstimate` |
| iOS belum ada | Non-goal sampai platform iOS ditambahkan |
| Build Android gagal karena plugin | Fase 1 tanpa plugin Firebase; local notification diuji di debug/release |
| Offline save batch | Antrean `pending_nutrition_batches` + retry saat layar dibuka |

---

## 13. Decisions Made

- Modul nutrisi: server-backed dengan cache lokal (Approach B).
- Notifikasi: local + FCM hybrid (Approach C).
- Target: AKG umum manual, editable, bukan antropometri.
- Sumber kebenaran katalog: tabel `FoodItem` backend; backend menang saat
  merge data seed.
- Riwayat asupan: `DetailedFoodLog` (bukan tabel log baru), dengan tambahan
  `sugarGram`, `fiberGram`, dan referensi lunak `foodItemId`.
- Tanggal ringkasan dikirim mobile sebagai tanggal lokal `yyyy-MM-dd` dan
  diparse backend sebagai UTC midnight, konsisten dengan tracker.
- Batch save memakai tombol anti double-submit; offline memakai antrean
  `SharedPreferences` append-only.
- FCM mobile ditunda ke fase 2 sampai config Firebase tersedia; backend
  device token + push service disiapkan sekarang dan no-op tanpa credential.
- Tidak memakai emoji di UI modul baru.
- Tidak ada feature flag untuk modul nutrisi; hanya `PUSH_ENABLED` untuk FCM.

## 14. Left to the Builder

- Angka default AKG final (verifikasi ahli gizi).
- Detail visual/ikon per kategori dan copy microcopy.
- Pemilihan versi package (`flutter_local_notifications`, `timezone`,
  `flutter_timezone`, `firebase_*`) yang kompatibel dengan Flutter SDK.
- Apakah editor target perlu riwayat perubahan (sekarang: overwrite + `updatedAt`).
- Format respons error yang lebih kaya (field-level) bila diperlukan.
