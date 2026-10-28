# Modul Nutrisi

Modul nutrisi menghitung satu makanan maupun beberapa item sekaligus,
membandingkannya dengan target harian anak, dan menyimpan hasilnya ke food
diary. Katalog makanan berasal dari backend; 22 makanan lokal dipakai sebagai
fallback offline.

## Endpoint

| Method | Endpoint | Auth | Fungsi |
| :--- | :--- | :--- | :--- |
| `GET` | `/api/nutrition/foods?search=&category=&limit=` | Publik | Katalog makanan (nilai per 100 g). |
| `POST` | `/api/nutrition/calculate` | Publik | Hitung satu makanan (`foodId` atau `foodName`, `weightGram`). |
| `POST` | `/api/nutrition/calculate-batch` | Publik / opsional login | Hitung banyak item; `childId` opsional untuk target & persentase. |
| `GET` | `/api/nutrition/target?childId=` | Login | Target harian anak (dibuat dari default AKG bila belum ada). |
| `PUT` | `/api/nutrition/target` | Login | Simpan target manual. |
| `GET` | `/api/nutrition/summary?childId=&date=` | Login | Total asupan hari itu vs target. |
| `POST` | `/api/food-diary/batch` | Login | Simpan beberapa item ke diary dalam satu transaksi. |

## Perilaku mobile

- **Hitung Cepat**: pilih makanan, jumlah/satuan, cara pengolahan; hasil
  langsung dihitung dari katalog (fallback lokal).
- **Susun Asupan**: tambah beberapa makanan, ubah berat, lihat total vs target,
  pilih tanggal + meal slot, lalu simpan ke diary.
- **Target**: default AKG per kelompok usia (4–6, 7–9, 10–12), dapat diedit.
  Angka bersifat edukatif, bukan preskripsi.
- **Offline**: katalog memakai 22 item lokal; target/ringkasan di-cache di
  `SharedPreferences`; batch yang gagal disimpan masuk antrean
  `pending_nutrition_batches` dan dicoba lagi saat layar dibuka.
- **Satuan**: gram = apa adanya, porsi = 150 g, potong/butir = 60 g,
  gelas = 200 g.

## Tanggal

Mobile mengirim `yyyy-MM-dd` berdasarkan tanggal lokal; backend mem-parse
sebagai UTC midnight agar konsisten dengan tracker dan food diary yang sudah
ada.

## Catatan medis

Nilai gizi berasal dari dataset katalog internal (nilai per 100 g). Angka
target AKG adalah default edukatif dan wajib ditinjau tenaga kesehatan sebelum
dipakai sebagai acuan klinis.
