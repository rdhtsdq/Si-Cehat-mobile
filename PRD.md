# PRD Si Cehat Mobile

Versi 1.0 | 26 September 2026 | Pemilik keputusan: Radit dan tim penelitian | Status: usulan untuk disepakati.

## Ringkasan keputusan produk

Si Cehat Mobile adalah pendamping keluarga untuk edukasi kebiasaan sehat, pencatatan anak, menu tradisional, pengingat, dan tindak lanjut kesehatan. Aplikasi baru ini mengikuti desain mobile dalam dokumen, bukan tampilan permainan di repositori web. Pengguna utama adalah ibu/orang tua dengan anak usia 6-12 tahun. Target awal adalah demonstrasi Android yang jujur tentang fitur lokal, simulasi, dan bagian belum siap.

Tujuan produk tidak sama dengan bukti efektivitas klinis. Aplikasi tidak boleh menjanjikan mencegah semua jenis diabetes, mendiagnosis anak, atau menggantikan tenaga kesehatan.

## Sumber dan prioritas

- S1: PDF desain 17 halaman adalah acuan layout dan label layar.
- S2: DOCX blueprint adalah acuan sasaran, fungsi dan informasi tambahan yang tidak bertentangan dengan S1.
- S3: FGD adalah acuan kebutuhan pengguna; ia tidak menyediakan instrumen klinis tervalidasi.
- S4: Repositori web pada commit 256d682 adalah referensi reuse dan risiko integrasi, bukan spesifikasi UI mobile.
- Keputusan baru yang disetujui tim dicatat dalam `DECISIONS.md`. Konflik dan tambahan agent harus terlihat.

## Masalah yang ditangani

Keluarga membutuhkan informasi kesehatan yang sederhana, contoh makanan lokal yang praktis, pencatatan yang tidak membebani, dan penjelasan tindak lanjut. FGD menekankan keterbatasan kuota, istilah yang sulit dipahami, serta perlunya contoh konkret. Pengembangan tidak boleh membuat pengguna mengisi banyak form hanya untuk membaca satu materi.

## Persona dan hak penggunaan

| Peran | Kebutuhan | Akses target |
|---|---|---|
| Ibu/orang tua | Membaca edukasi, mengelola anak, mencatat dan mengingat kegiatan | Data anak yang berada dalam akun sendiri |
| Anak 6-12 tahun | Memahami informasi dan mencoba kuis dengan pendampingan | Konten sesuai usia; bukan akses akun dewasa mandiri |
| Tenaga kesehatan/kader | Meninjau konten dan mendampingi keluarga | Tidak otomatis dapat membaca semua data keluarga |
| Admin penelitian | Mengelola konten dan evaluasi terotorisasi | Admin web terpisah; akses berbasis kebutuhan dan audit |

Guru/UKS dan tenaga kesehatan adalah sasaran pendukung dari blueprint. Dashboard mobile khusus peran tersebut bukan scope demo pertama.

## Luaran dan definisi kesiapan

### D0 Demo lokal

APK demo dapat dijelajahi di perangkat Android, mencakup 17 layar referensi dengan status fitur transparan. Alur profil dummy, materi, menu dan catatan lokal berfungsi. Skrining, layanan nakes dan komunitas boleh berupa simulasi/preview sesuai spesifikasi, bukan layanan nyata. Rute klinis hanya menampilkan contoh atau unavailable state. Login demo tidak dianggap autentikasi server. Seluruh payload sintetis tetap lokal.

### D1 Pilot terkontrol

Membutuhkan persetujuan scope/etik dan konten, akun nyata, isolasi data, penyimpanan yang sesuai risiko, API aman, QA perangkat, aturan retensi dan proses dukungan. Fitur klinis tetap nonaktif bila instrumen belum disetujui. Bila skrining merupakan luaran wajib, D1 tidak dapat dinyatakan lengkap sebelum bagian itu siap.

### D2 Cakupan produk penuh

Mencakup kebutuhan master, termasuk skrining tervalidasi dan layanan operasional yang disetujui. Komunitas dan konsultasi membutuhkan personel, moderasi dan tata kelola; bukan hanya tombol chat.

## Prioritas

P0 adalah wajib pada demo; P1 adalah prioritas berikutnya setelah P0 stabil; P2 adalah pengembangan lanjutan. `GATED` bukan prioritas rendah, melainkan tidak boleh aktif tanpa prasyarat. Semua fitur yang ditunda tetap ada di master requirement.

## Functional requirements

| ID | Requirement | Target awal dan batas |
|---|---|---|
| FR-01 | Splash dan onboarding sesuai PDF | P0; tanpa permintaan permission saat splash |
| FR-02 | Login email/nomor HP, daftar dan pemulihan akses | P0 UI demo; D1 auth nyata. Kanal email/HP aktual harus diputuskan |
| FR-03 | Profil ibu dan pemilihan/profil anak | P0 lokal dummy; nama, tanggal lahir, riwayat serta pengukuran. Field tambahan diberi asal |
| FR-04 | Beranda dengan ringkasan risiko dan lima menu utama | P0; default risiko belum tersedia, bukan otomatis rendah |
| FR-05 | Pengumpulan data awal skrining dan hasil dengan penjelasan | P0 demo visual; GATED untuk skor/klasifikasi nyata |
| FR-06 | Tracker BB/TB dan riwayat pengukuran | P0 grafik nilai terukur/dummy; interpretasi status gizi GATED |
| FR-07 | Catatan aktivitas, makanan berbasis URT, dan air minum | P1 form tambahan. Tidak membuat kalkulasi kalori tanpa data tervalidasi |
| FR-08 | Menu tradisional terfilter dan detail resep | P0 katalog lokal; bahan, porsi, cara masak, substitusi; gizi hanya jika disetujui |
| FR-09 | Edukasi Video, Podcast, Quiz | P0 shell, materi lokal singkat dan kuis contoh; media nyata memerlukan aset berizin |
| FR-10 | Reminder tambah/edit, waktu dan switch | P0 penyimpanan jadwal; P1 notifikasi perangkat yang diuji |
| FR-11 | Pilihan konsultasi Bidan, Ahli Gizi, Dokter | P0 UI unavailable; D2 layanan setelah nakes dan saluran disetujui |
| FR-12 | Komunitas Semua, Populer, Saya dan buat postingan | P0 preview berlabel; D2 publikasi setelah moderasi dan aturan privasi |
| FR-13 | Konten dan catatan dasar dapat dibuka offline | P0 untuk demo lokal; D1 outbox/sync, retry dan konflik terkendali |
| FR-14 | Persetujuan dan transparansi data | Label dummy wajib P0; consent wali, tata kelola dan retensi wajib sebelum D1 |
| FR-15 | Akses aman dan pemisahan anak/akun | Wajib D1; auth server dan ownership setiap operasi, bukan UUID saja |
| FR-16 | Pemilihan anak aktif, logout dan penghapusan lokal | P0 demo reset; D1 membersihkan data/sesi tanpa menukar profil |
| FR-17 | Tindak lanjut bila perlu tenaga kesehatan | P0 penjelasan umum; keputusan otomatis klinis GATED |
| FR-18 | Riwayat evaluasi edukasi dan pengukuran penelitian | P1 hanya setelah instrumen dan consent disetujui; XP bukan hasil klinis |
| FR-19 | Konsistensi konten admin dan mobile | D1 distribusi konten berstatus approved, versioned dan read-only bagi orang tua |
| FR-20 | Kesiapan, error dan empty state jujur | P0 seluruh layar; tidak ada button diam atau indikator sukses palsu |

## Alur utama demo

Splash → onboarding → login demo berlabel → beranda → profil ibu/anak → kembali beranda → buka menu/detail → edukasi/kuis → tracker/tambah pengukuran → tutup aplikasi → buka lagi → data lokal tetap ada.

Alur contoh skrining terpisah: beranda → form langkah 1 → penjelasan instrumen belum tersedia → opsi eksplisit lihat hasil contoh → layar hasil dengan label simulasi. Input tidak menghasilkan persentase medis.

## Nonfunctional requirements

| ID | Persyaratan dan cara verifikasi |
|---|---|
| NFR-01 | Tampilan Bahasa Indonesia, label singkat, error pada field terkait; usability test menyusul, bukan diasumsikan lulus |
| NFR-02 | Uji layout lebar 360, 390, 412 dp dan text scale 1.0/1.3; tidak ada overflow atau CTA tertutup keyboard |
| NFR-03 | Target awal cold start demo ≤3 detik, perpindahan konten lokal ≤300 ms pada perangkat uji yang dicatat; target engineering, bukan hasil ukur |
| NFR-04 | Simpan lokal atomik; child/account scoping; migrasi database tidak menghapus data diam-diam |
| NFR-05 | Tidak perlu internet untuk konten bundled dan CRUD dummy setelah instalasi; media remote dan layanan nakes boleh unavailable |
| NFR-06 | Isi klinis tidak ditentukan agent; review content/version dan feature gate diuji |
| NFR-07 | Data sensitif tidak masuk log, analytics, crash attachment atau APK; kanal jaringan HTTPS pada pilot |
| NFR-08 | Target sentuh minimal 48 dp, semantik pembaca layar, informasi tidak hanya warna; perubahan visual untuk aksesibilitas dicatat |
| NFR-09 | Tanggal aktivitas berdasarkan Asia/Jakarta; timestamp audit UTC; date-only lahir/pengukuran tidak dikonversi sehingga bergeser tanggal |
| NFR-10 | Unit, widget, integration dan visual QA; build berhasil tidak menggantikan pemeriksaan alur |

## Tidak termasuk demo awal

AI avatar/chat sebagai fitur utama mobile, skor medis buatan, diagnosis, telemedicine aktif, forum publik, integrasi rekam medis, AI estimasi foto makanan, pembayaran, live tracking, multi-tenant klinik, dan migrasi data produksi. Fitur gamifikasi pada web tetap dapat dipertahankan dalam proyek web, tetapi tidak disalin ke baseline visual mobile ini.

## Keputusan dan prasyarat konten

Tim harus memastikan tanggal awal Oktober yang tepat, bentuk luaran (demo/APK/pilot), instrumen skrining yang sah untuk sasaran, standar pertumbuhan, pemilik validasi gizi, ketersediaan video/audio/aset dan dukungan nakes. Dokumen ini tidak menjadikan syarat yang belum ada seolah-olah terpenuhi.

## Acceptance dan ukuran keberhasilan

D0 selesai bila skenario utama lokal lulus, seluruh 17 layar dapat diakses dengan status benar, visual telah dibandingkan, data tetap ada setelah restart, mode demo tidak mengakses backend nyata, dan tidak ada angka risiko yang diklaim hasil pengguna. Gunakan AC-01 sampai AC-30 dengan applicability yang tertulis.

D1 memerlukan tes kepemilikan, izin/consent, offline-sync, review konten, QA perangkat dan persetujuan tim; screening enabled memerlukan gerbang tambahan tersendiri. Ukuran evaluasi yang disarankan: keberhasilan tugas, jumlah bantuan, keterpahaman, kemudahan, error dan hasil kuis terukur. Tidak menyimpulkan penurunan risiko diabetes dari engagement aplikasi.

## Batas waktu

Awal Oktober belum menjadi tanggal pasti. Rencana dalam `IMPLEMENTATION_PLAN.md` menyediakan jalur demo minimum jika target 1 Oktober dan jalur QA tambahan bila 5 Oktober disetujui. Estimasi bukan janji penyelesaian; agent mengurangi fitur tambahan lebih dahulu, bukan label keselamatan atau pemeriksaan akses.
