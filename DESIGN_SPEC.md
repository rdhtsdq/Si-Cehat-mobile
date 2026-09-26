# Spesifikasi Desain Deskriptif Si Cehat Mobile

Versi 1.0 | 26 September 2026 | Referensi utama S1 halaman 1-17.

## Cara membaca spesifikasi

`PDF` = elemen yang terlihat pada halaman sumber. `BLUEPRINT` = pelengkap DOCX. `PROPOSED` = keputusan implementasi untuk perilaku yang belum digambar. `SAFETY` = penyesuaian agar UI tidak menyampaikan kondisi kesehatan palsu. Agent wajib membedakan keempatnya.

Desain ini merekonstruksi referensi yang diberikan, bukan merancang ulang. Tidak ada mascot besar, peta petualangan, XP, glassmorphism, gradient, tema gelap atau menu samping. Bingkai hitam di sekeliling gambar adalah bingkai wireframe, bukan border layar aplikasi. Gambar halaman tidak boleh dijadikan satu bitmap interaktif; bangun komponen asli.

## Tata visual bersama

| Aspek | Spesifikasi implementasi | Status asal |
|---|---|---|
| Latar | Putih dominan; panel/field abu sangat muda | PDF |
| Hijau utama | `#4CAF50`; hijau muda `#8BC34A` | BLUEPRINT, palet eksplisit pada gambar volume II |
| Aksen tambahan | `#FFC107`, `#2196F3`; tidak ditambahkan bila tidak terlihat pada layar PDF | BLUEPRINT |
| Teks | Gelap/nyaris hitam; sekunder abu | PDF; nilai hex terinci PROPOSED |
| Font | Poppins bundled untuk heading/body, fallback sans-serif | BLUEPRINT; identitas font PDF raster tidak dapat dipastikan |
| Bobot | Heading tebal, label utama medium/bold, input reguler | PDF; angka weight PROPOSED |
| Tombol utama | Hijau, teks tengah; lebar mengikuti area konten | PDF |
| Form | Field lebar, latar abu muda, jarak vertikal lapang | PDF |
| Card | Putih/abu muda, radius ringan, beberapa memakai bayangan tipis | PDF; nilai radius PROPOSED |
| Navigasi bawah | Beranda, Tracker, Edukasi, Profil; empat item berukuran seimbang | PDF |
| Ikon aktif | Hijau; item lain hitam/abu gelap | PDF |

### Ukuran yang diusulkan

Angka berikut bukan ukuran asli PDF: basis desain 390 × 844 logical pixels, horizontal gutter 24 dp, spacing 8/12/16/24/32, radius input 4-8 dp, card 12 dp, tombol 52 dp tinggi, field minimum 56 dp, bottom navigation 72 dp di luar safe inset. Heading layar 26-30 sp, heading splash 36 sp, body/field 16 sp, label navigasi 12 sp. Layar login menggunakan heading 30 sp, tombol 18 sp. Jangan menskalakan satu screenshot penuh secara paksa untuk semua perangkat.

Pakai `SafeArea`, konten yang dapat scroll, dan hindari fixed height yang memotong teks. Pada layar kecil/keyboard terbuka, ruang kosong boleh berkurang sebelum mengecilkan teks. Elemen sentuh minimum 48 dp, semantik field dan ikon tersedia. Header besar boleh membungkus sesuai contoh. White-on-green dari referensi harus diuji kontras; pilot harus menggunakan pasangan warna yang lulus, misalnya tombol hijau lebih gelap `#2E7D32` dengan putih. Catat penyesuaian aksesibilitas ini sebagai deviasi yang disetujui, jangan mengklaim identik piksel.

### Bottom navigation dan tombol kembali

Navigasi bawah terlihat pada S05, S06, S07, S08, S12, S15. Jangan otomatis menampilkannya pada seluruh detail karena PDF tidak demikian. S11 Tracker tidak menampilkan bottom bar dalam PDF; pertahankan dan sediakan back sistem Android. Back affordance tambahan hanya bila diperlukan untuk aksesibilitas, diberi label PROPOSED. Layar detail yang memperlihatkan chevron kiri menggunakan app bar putih tanpa elevasi tebal.

### State umum

- Loading: placeholder sesuai ukuran konten, bukan spinner penuh tanpa batas.
- Empty: satu pesan jelas serta CTA bila ada tindakan yang benar-benar bisa dilakukan.
- Error: pesan Indonesia yang tidak membocorkan detail server, tombol coba lagi bila relevan.
- Offline: badge ringkas `Offline · data tersimpan di perangkat`; konten lokal tetap dapat dibuka.
- Demo: indikator tetap `DEMO · Data contoh` pada shell yang menampilkan data kesehatan, bukan toast sesaat.
- Unavailable: jelaskan fitur belum aktif; tidak mengarahkan ke chat kosong seolah ada petugas.
- Save: feedback singkat, invalid input dijelaskan pada field; cegah submit berulang.

## Indeks 17 layar

| ID | Nama | Halaman S1 | Referensi |
|---|---|---:|---|
| S01 | Splash | 1 | [Gambar](../references/screens/design-01.jpg) |
| S02 | Onboarding | 2 | [Gambar](../references/screens/design-02.jpg) |
| S03 | Login | 3 | [Gambar](../references/screens/design-03.jpg) |
| S04 | Daftar akun | 4 | [Gambar](../references/screens/design-04.jpg) |
| S05 | Beranda | 5 | [Gambar](../references/screens/design-05.jpg) |
| S06 | Pilihan profil | 6 | [Gambar](../references/screens/design-06.jpg) |
| S07 | Profil ibu | 7 | [Gambar](../references/screens/design-07.jpg) |
| S08 | Profil anak | 8 | [Gambar](../references/screens/design-08.jpg) |
| S09 | Skrining langkah pertama | 9 | [Gambar](../references/screens/design-09.jpg) |
| S10 | Hasil skrining | 10 | [Gambar](../references/screens/design-10.jpg) |
| S11 | Tracker | 11 | [Gambar](../references/screens/design-11.jpg) |
| S12 | Menu tradisional | 12 | [Gambar](../references/screens/design-12.jpg) |
| S13 | Detail menu | 13 | [Gambar](../references/screens/design-13.jpg) |
| S14 | Reminder | 14 | [Gambar](../references/screens/design-14.jpg) |
| S15 | Edukasi | 15 | [Gambar](../references/screens/design-15.jpg) |
| S16 | Konsultasi | 16 | [Gambar](../references/screens/design-16.jpg) |
| S17 | Komunitas | 17 | [Gambar](../references/screens/design-17.jpg) |

## S01 Splash

**PDF.** Latar putih polos. Satu kelompok teks berada mendekati pusat layar: `Si Cehat` hijau, besar dan tebal. Di bawahnya judul hitam tebal dua baris `Sistem Cerdas Anak Sehat` dan `Anti Diabetes`. Seluruh teks center; area atas/bawah sangat lapang. Tidak ada ilustrasi, progress bar, tombol, bottom bar atau logo ibu-anak pada versi PDF ini.

**PROPOSED.** Pusat kelompok teks sekitar separuh tinggi area aman; width maksimum 320 dp. Saat local initialization selesai, arahkan first launch ke S02 atau sesi demo aktif ke S05. Jangan menambah delay buatan yang menghambat cold start. Jika database gagal dibuka, tampilkan error dan tindakan retry; jangan membeku pada splash.

**SAFETY.** Nama adalah identitas sumber, bukan klaim bahwa aplikasi menjamin bebas diabetes. Penjelasan tujuan ditempatkan pada onboarding/bantuan, tanpa mengubah susunan utama splash.

**Kriteria visual:** tiga baris blok judul sumber, hijau pada nama saja, tidak ada mascot/animasi petualangan baru.

## S02 Onboarding

**PDF.** Halaman putih. Headline hitam besar, bold, center pada bagian atas-tengah dengan tiga baris: `Jaga Anak,` / `Cegah Diabetes` / `Sejak Dini`. Di bawahnya ruang kosong luas. PDF tidak memperlihatkan tombol, dots pagination, foto, maupun carousel.

**PROPOSED.** Tambahkan tombol aksesibel `Lanjut` di bagian bawah agar alur tidak buntu; tambahan ini tidak dianggap elemen asli. Satu paragraf pendek di bawah headline menjelaskan `Pendamping edukasi dan kebiasaan sehat keluarga. Bukan alat diagnosis.` Tombol menuju S03. Back sistem kembali atau keluar, tidak mengulang splash tanpa akhir. Jangan membuat empat slide baru.

**State:** set `onboardingSeen` setelah pengguna menekan lanjut, bukan sebelum terlihat. Dapat dibuka ulang melalui bantuan tambahan pada profil.

**Kriteria visual:** headline tetap dominan, tidak berubah menjadi halaman marketing berisi banyak card; tambahan CTA/penjelasan diberi status deviasi yang disengaja.

## S03 Login

**PDF.** Judul center besar dua baris `Selamat Datang` / `Kembali!`. Setelah ruang vertikal, field `Email / No. HP`; di bawahnya field `Password`. Tombol hijau lebar `Masuk`. Teks `Lupa Password?` di bawah tombol, rata kanan. Bagian bawah memuat teks center `Belum punya akun?`, disusul `Daftar` berwarna hijau. Tidak ada login sosial atau bottom bar.

**PROPOSED.** Field bukan teks dekoratif. Identifier keyboard mengikuti input; password masked dan dapat diberi toggle visibility aksesibel. Link lupa password membuka E01; daftar membuka S04. Masuk valid menuju S05 atau E02 bila belum ada profil anak. Pertahankan input saat error; tombol disabled/loading saat request berjalan. Validasi format identifier dan field kosong, bukan memaksa format email pada nomor HP.

**DEMO.** Banner `Mode demo · tidak terhubung ke akun nyata`. Gunakan identifier contoh, bukan meminta password nyata. Tombol boleh membuka sesi dummy hanya dalam mode demo; tidak menyimpan atau mengirim password yang diketik. Tampilkan penjelasan autentikasi simulasi.

**D1.** Gagal login menggunakan pesan generik; jangan membedakan akun ada/tidak. Tidak menyimpan token di preferences biasa. Nomor HP hanya berfungsi jika alur verifikasi/reset disetujui tim; UI tidak boleh berjanji tanpa backend.

## S04 Daftar akun

**PDF.** Judul center `Daftar Akun`, subjudul `Isi data berikut`. Empat field abu muda berurutan: `Nama Ibu`, `No. HP`, `Email`, `Password`. Tombol hijau `Daftar` di bawah. Tidak ada confirm password, login sosial, dekorasi atau bottom bar.

**PROPOSED.** Form scroll ketika keyboard tampil. Nama mandatory, setidaknya satu kanal kontak terverifikasi sesuai keputusan auth; kebutuhan wajib nomor/email tidak dapat diambil dari screenshot saja. Password D1 minimum 12 karakter dan mendukung paste/password manager; ini kebijakan usulan, bukan persyaratan sumber. Tampilkan kriteria sebelum submit. Setelah daftar demo lanjut E02/profil dummy; daftar nyata mengikuti kontrak verifikasi.

**SAFETY.** Informasi privasi dan consent yang disetujui ditampilkan sebelum pengumpulan data anak nyata, melalui E03. Checkbox tidak tercentang otomatis. Demo menampilkan identitas fiktif dan tidak mencatat password. Jangan menambah pertanyaan kesehatan ke halaman registrasi.

**State:** duplicate-account response tidak mengungkap data anak, network error mempertahankan field non-password sesuai kebijakan; tidak mencetak password pada log.

## S05 Beranda

**PDF.** Sapaan `Halo, Ibu Rina!` besar rata kiri, diikuti `Selamat Pagi`. Bagian isi menggunakan bidang hijau sangat pucat. Card paling atas berlabel `Diabetes Risk Meter`, status besar hijau `Risiko Rendah`, dan kalimat `Pertahankan pola hidup sehat anak setiap hari!`. Pada PDF halaman 5 tidak ada lingkaran persentase di card ini, walaupun gambar DOCX memilikinya.

Di bawah terdapat panel putih `Menu Utama`. Grid dua baris: baris pertama tiga kotak `Skrining`, `Menu`, `Reminder`; baris kedua dua kotak `Konsultasi`, `Komunitas` rata kiri pada kolom yang sama. Ikon besar: clipboard, mangkuk, lonceng, gelembung percakapan, kelompok orang. Card menu mempunyai radius dan shadow lembut. Bottom bar urutan `Beranda`, `Tracker`, `Edukasi`, `Profil`; Beranda hijau.

**PROPOSED.** Grid 3 kolom tetap pada lebar minimum yang diuji; card minimum tap target 48 dp, label tidak dipotong. Sapaan sesuai nama/waktu lokal. Nama anak aktif dapat berupa chip kecil di header ketika ada lebih dari satu anak; chip tambahan, bukan desain asli. Klik menu menuju S09/S12/S14/S16/S17; bottom bar ke S05/S11/S15/S06.

**SAFETY.** Default card berbunyi `Skrining belum tersedia` dengan penjelasan singkat; bukan risiko rendah karena belum ada data. Dalam fixture visual terisolasi boleh menampilkan contoh `Risiko Rendah` dengan badge `Contoh tampilan · bukan hasil anak`. Jangan mengubah skor keterlibatan menjadi risk meter.

**State:** tanpa anak arahkan pengisian E02; offline tidak menampilkan data akun lain; skeleton hanya ketika benar-benar memuat, bukan placeholder permanen.

## S06 Pilihan profil

**PDF.** Ilustrasi siluet ibu menggendong anak berwarna hitam di tengah area atas. Setelah ruang kosong, dua bidang abu muda lebar: `Profil Ibu`, kemudian `Profil Anak`, teks besar rata kiri. Bottom bar empat item, Profil hijau. Tidak ada heading Profil Saya, avatar buah atau statistik.

**PROPOSED.** Dua bidang berfungsi sebagai menu S07 dan S08. Bila beberapa anak, `Profil Anak` membuka E02 pemilih anak terlebih dahulu. Gunakan aset siluet berizin yang sama atau pengganti yang secara semantik setara dengan status placeholder. Jangan mengekstrak dan menganggap gambar raster referensi sebagai aset produksi otomatis.

**Tambahan operasional:** logout, reset demo dan informasi privasi ditempatkan sebagai section tambahan di bawah dua menu, dapat scroll; tidak menggantikan dua menu utama. Reset membutuhkan konfirmasi dan hanya menghapus database demo, bukan data pilot.

## S07 Profil ibu

**PDF.** Judul center `Profil Ibu`; di bawahnya avatar generik orang hitam/abu dalam lingkaran abu. Empat baris/field abu muda: `Nama Ibu`, `Pendidikan`, `Pekerjaan`, `Alamat`. Bottom bar Profil aktif. Terdapat duplikasi teks pada area bar navigasi gambar; ini artefak, jangan direplikasi.

**PROPOSED.** Avatar tidak otomatis meminta kamera. Baris menampilkan label dan nilai atau placeholder. Tap membuka form E04 atau mode edit sederhana; tombol simpan muncul hanya dalam mode edit. Pendidikan berupa pilihan yang dapat diperbarui tim; jangan mengarang klasifikasi penelitian final. Nama wajib untuk sapaan; field lain optional sampai protokol menetapkan kebutuhan.

**SAFETY.** Minimalkan alamat dan demografi pada pilot. Jangan mengumpulkan alamat rinci hanya karena desain menyediakan baris; kebutuhan serta retensinya harus disetujui. Demo menggunakan nilai fiktif.

**State:** perubahan tersimpan setelah restart; cancel tidak menyimpan; error validasi terikat field. Scroll tidak menindih bottom bar.

## S08 Profil anak

**PDF.** Judul center `Profil Anak`, avatar orang generik dalam lingkaran abu. Empat baris: `Nama Anak`, `Tanggal Lahir`, `Riwayat Kesehatan`, `Riwayat Pengukuran`. Bottom bar Profil aktif. Tidak ada kartu level atau aktivitas harian.

**BLUEPRINT.** Profil anak juga memerlukan jenis kelamin untuk referensi pertumbuhan serta data berat/tinggi. Tambahkan dalam E02/E04, bukan memaksakan field baru pada susunan empat baris utama tanpa persetujuan.

**PROPOSED.** Nama/tanggal lahir membuka edit; riwayat kesehatan membuka catatan terstruktur yang disetujui atau text note terbatas tanpa interpretasi otomatis; riwayat pengukuran menuju S11 dalam konteks anak aktif. Pemilih anak tidak menukar cache antarprofil. Tanggal lahir adalah date-only, bukan UTC timestamp.

**State:** tanggal masa depan ditolak; usia di luar 6-12 tahun mendapat keterangan sasaran prototipe, tidak otomatis dinyatakan berisiko. Catatan kosong menampilkan `Belum ada catatan`, bukan `Tidak memiliki penyakit`.

## S09 Skrining risiko diabetes langkah pertama

**PDF.** App bar putih dengan chevron kembali di kiri dan judul `Skrining Risiko Diabetes`. Teks kecil `Langkah 1 dari 3`. Label bold `Usia Anak (Tahun)`, kontrol dropdown contoh `8`; `Berat Badan (Kg)`, contoh `25`; `Tinggi Badan (Cm)`, contoh `120`. Kontrol putih dengan outline/bayangan halus, chevron di kanan. Area bawah lapang; tombol hijau lebar `Selanjutnya` dekat dasar. Tidak ada bottom bar.

**PROPOSED.** Field usia dapat diturunkan dari DOB; pengguna mengonfirmasi nilai. Berat/tinggi membuka numeric bottom sheet dengan unit, mendukung desimal koma dan titik. Validasi nilai positif, unit dan kelengkapan; batas biologis rinci menunggu ahli. Tombol bawah mengikuti safe inset dan terangkat saat keyboard tampil.

**GAP SUMBER.** PDF tidak menggambar langkah 2 dan 3, pertanyaan, bobot, cut-off atau model risiko. Jangan mengarang kuesioner agar indikator 1/3 terlihat lengkap.

**DEMO/SAFETY.** Setelah Selanjutnya, tampilkan E05: `Instrumen skrining belum ditetapkan. Data ini tidak menghasilkan penilaian risiko.` Pilihan `Kembali` atau `Lihat contoh hasil`. Pilihan kedua menuju S10 fixture berlabel, terlepas dari angka yang diinput. Nilai form tidak menjadi argumen model risiko. Tampilan 1/3 dipertahankan hanya pada demo referensi; pilot memakai instrumen/version dan jumlah langkah sesungguhnya setelah disetujui.

## S10 Hasil skrining

**PDF.** App bar dengan back dan judul `Hasil Skrining`. Di area atas ada lingkaran/donut besar, separuh hijau pekat dan separuh hijau muda, teks hijau `50%` di tengah. Di bawahnya kalimat center `Anda memiliki risiko sedang terhadap diabetes melitus`. Selanjutnya heading kiri bold `Rekomendasi untuk Anda`, diikuti tiga baris: `Perbanyak sayur & buah`, `Batasi minuman manis`, `Ajak anak aktif bergerak`, masing-masing dengan penanda panah/chevron. Tombol hijau `Selanjutnya` lebar di bawah; tanpa bottom bar.

**SAFETY.** Frame contoh harus memiliki label permanen dekat donut: `SIMULASI · 50% hanya contoh desain, bukan risiko anak`. Jangan mengandalkan disclaimer pada halaman lain. Di mode pilot tanpa instrumen, donut/angka dihilangkan dan diganti `Belum ada hasil skrining yang dapat ditampilkan`, dengan CTA edukasi atau kembali. Tidak ada default risiko rendah/sedang.

**PROPOSED.** Selanjutnya menuju S12 Menu Tradisional sesuai alur edukasi/menu pada FGD. Back kembali ke form tanpa menulis hasil palsu ke riwayat. Bila suatu hari ada instrumen resmi, tampilkan versi, tanggal, arti skor, keterbatasan dan tindak lanjut yang disetujui; persentase tidak diasumsikan probabilitas penyakit. Tidak membuat rekomendasi diet berdasarkan angka demo.

**Kriteria:** layout contoh setia tetapi sifat simulasi tidak dapat disembunyikan; data nyata tidak menggunakan `50` sebagai fallback.

## S11 Tracker

**PDF.** Judul `Tracker` rata kiri. Dua tab horizontal: `Tumbuh Kembang` aktif hijau, `Aktivitas` abu muda. Di bawahnya heading `Grafik BB (Kg)`. Grafik garis toska dengan titik bulat pada kartu putih berbayang; sumbu bulan Jan-Mei dan skala berat. Bagian bawah kartu informasi berisi `Berat Badan Terakhir` dengan `20,5 kg`, lalu `Tinggi Badan Terakhir` dengan `118 cm`. Tidak terlihat bottom bar pada halaman ini.

**PROPOSED.** Grafik berasal dari measurement history anak aktif, urut tanggal naik, nilai terakhir identik dengan kartu ringkasan. Gambar sumber memiliki ketidakjelasan jumlah titik/nilai akhir dibanding angka ringkasan; jangan meniru ketidakkonsistenan data. Pada fixture fungsional, titik terakhir 20,5 kg sesuai kartu. Judul grafik tetap BB, bukan kurva diagnostik.

**Tambahan diperlukan:** tombol `Tambah Pengukuran` di bawah kartu membuka E06; field tanggal, BB, TB, sumber pengukuran dan catatan optional. Tab Aktivitas yang tidak dirinci PDF memakai E07: daftar catatan aktivitas, makanan dan air serta CTA tambah sederhana. Ini rancangan usulan dari kebutuhan FGD, bukan layar asli yang diklaim ada.

**SAFETY.** Tidak memakai garis batas IMT dewasa atau memberi status normal/obesitas otomatis. Interpretasi IMT menurut umur/jenis kelamin menunggu standar, data referensi dan validasi. Nol entri menampilkan ajakan mencatat; satu entri menampilkan satu titik, bukan garis tren buatan.

## S12 Menu tradisional sehat

**PDF.** App bar dengan back dan judul `Menu Tradisional Sehat`. Empat chip/tab satu baris: `Semua` hijau aktif, `Makanan`, `Minuman`, `Cemilan` abu muda. Di bawahnya tiga card horizontal; foto makanan persegi di kiri, judul bold dan deskripsi di kanan. Contoh: `Sayur Asem` / `Tinggi serat, rendah gula`; `Pepes Ikan` / `Sumber protein yang berkualitas`; `Nasi Tutuk Oncom` / `Sumber Energi yang lengkap`. Bottom bar Beranda aktif.

**PROPOSED.** Card full-width, image crop cover dengan radius ringan, jarak antarcard 16 dp. Filter tidak mengganti nama kategori; bar boleh horizontal-scroll bila teks scale besar. Tap card membuka S13 menurut menuId. Tidak menambah search bar atau carousel di baseline PDF; search dapat menjadi perubahan terpisah.

**Konten:** ejaan `Nasi Tutuk Oncom` ditranskripsikan dari PDF; ejaan final perlu reviewer (umum dikenal sebagai nasi tutug oncom). Jangan membetulkan diam-diam dalam screenshot acceptance sebelum keputusan dicatat. Klaim gizi contoh adalah copy referensi, bukan hasil perhitungan; hanya disiarkan ke pilot setelah reviewer menyetujui resep dan porsinya.

**State:** kategori kosong menampilkan `Belum ada menu pada kategori ini`; foto tidak ada memakai placeholder bermakna, bukan gambar makanan yang salah. Konten yang sudah bundled dapat dibuka offline.

## S13 Detail menu

**PDF.** App bar back, judul `Sayur Asem`. Foto hero makanan lebar, hampir persegi, ber-radius di bawah app bar. Setelah gap terdapat tiga bidang kecil abu muda berjajar. Bagian bawah masih kosong dengan ikon api hitam. PDF tidak memberikan label lengkap pada tiga bidang, bahan, langkah masak maupun nilai gizi.

**BLUEPRINT.** Gambar DOCX melengkapi tujuan detail: informasi gizi, bahan-bahan dan cara membuat. Maka bagian bawah dapat diisi secara scroll, dengan tetap mempertahankan hero dan tiga ringkasan di atas. Label yang diusulkan untuk ringkasan adalah energi, serat, protein; jangan menganggapnya terbaca di S1.

**PROPOSED.** Urutan halaman: hero → tiga ringkasan → porsi → bahan → cara membuat → alternatif bahan/catatan → sumber/reviewer. Jika nilai gizi belum ditinjau, tampilkan `Belum tersedia`, bukan `0` atau angka contoh. Unit energi kkal per porsi, serat/protein gram per porsi setelah validasi. Ikon api mewakili energi, tidak menjadi tombol tanpa fungsi.

**Asset:** gunakan foto yang sama antara list dan detail untuk menuId sama; placeholder sampai aset disetujui. Simpan favorit bukan kebutuhan P0.

**State:** detail hilang menampilkan error/return to list. Jangan menampilkan contoh resep buatan agent seolah sudah disetujui ahli gizi.

## S14 Reminder

**PDF.** App bar dengan chevron kembali dan judul `Reminder`. Teks aksi hijau `+ Tambah Reminder` di bawahnya. Empat card putih dengan shadow tipis dan radius: jam kiri, nama kegiatan tengah, switch hijau kanan. Urutan contoh: `07:00 Sarapan Pagi`, `10:00 Minum air putih`, `16:00 Aktivitas Fisik`, `20:00 Waktu tidur`. Tidak ada bottom bar.

**PROPOSED.** Aksi tambah/tap row membuka E08 berisi judul, waktu lokal, hari pengulangan dan profil anak bila perlu. Persist enabled state terpisah dari scheduling state. Switch off membatalkan notification ID terkait; edit membatalkan jadwal lama sebelum menjadwalkan pengganti. Tampilkan keterangan `Jadwal tersimpan; notifikasi belum aktif` ketika izin atau implementasi scheduling belum siap.

**Permission:** minta izin setelah pengguna mengaktifkan pengingat, bukan pada splash. Penolakan izin tidak menyebabkan crash atau switch berbohong. Gunakan scheduling non-exact bila memadai; jam pengingat bukan alarm medis. Jangan menjanjikan delivery presisi ketika OS membatasi background/battery. Uji restart/reboot/timezone pada P1 sebelum klaim berfungsi.

**State:** tanpa jadwal, CTA tambah tetap ada. Contoh empat jadwal hanyalah seed dummy, tidak mengeklaim anjuran individual.

## S15 Edukasi

**PDF.** Judul `Edukasi` rata kiri. Tiga tab: `Video` aktif hijau, `Podcast`, `Quiz`. Daftar tiga card horizontal: thumbnail kiri, judul bold kanan, durasi abu di bawah. Judul contoh: `Apa Itu Diabetes pada Anak?`, `Bahaya Minuman Manis pada Anak`, `Bekal Sekolah Sehat dan Praktis`. Durasi terlihat sebagai contoh sekitar `5.03 menit`, `4.12 menit`, `12.10 menit`; tidak dianggap metadata media nyata. Bottom bar Edukasi aktif.

**Konflik:** DOCX juga menyebut booklet/infografis dan variasi tab lain. Untuk baseline, pertahankan tiga tab S1. Jenis konten lain boleh ditambahkan kemudian melalui revisi, bukan dicampur otomatis.

**PROPOSED.** Video/Podcast membuka E09 detail/player; Quiz membuka E10 kuis singkat. Judul dan media terkait harus sama. Jika aset belum ada, card demo membuka ringkasan teks berlabel `Pratinjau materi · video belum tersedia`, bukan tombol play palsu. Jangan memakai durasi contoh sebagai durasi riil.

**Quiz:** satu soal per layar, pilihan jawaban besar, feedback penjelasan, tombol lanjut dan hasil belajar. Soal/answer/version disetujui untuk pilot. Persentase kuis selalu berlabel `Jawaban benar`, tidak dipakai sebagai risiko diabetes. Progress tertaut ke childId dan contentVersion, bukan boolean global.

**State:** offline dapat membaca konten bundled; media remote menampilkan kebutuhan internet bila belum diunduh; retry tidak menggandakan attempt tersimpan.

## S16 Konsultasi

**PDF.** App bar back dan judul `Konsultasi`. Ruang atas lapang, diikuti tiga card abu muda besar tersusun vertikal, tiap card berikon gelembung chat hitam di kiri dan teks bold: `Bidan`, `Ahli Gizi`, `Dokter`. Tidak ada daftar nama dokter, rating, harga, foto profil, badge online atau bottom bar.

**PROPOSED/SAFETY.** Dalam D0, tap menampilkan `Layanan konsultasi belum aktif pada prototipe ini` dan penjelasan umum untuk menghubungi fasilitas kesehatan. Jangan menghubungi siapa pun, membuka nomor random, menambahkan nakes fiktif, atau menampilkan chatbot sebagai tenaga kesehatan. D2 membutuhkan partner, jadwal layanan, consent berbagi data dan prosedur tindak lanjut yang terpisah.

**State:** jika suatu hari layanan nyata diaktifkan, offline/unavailable tetap jujur; nomor/link kontak wajib disahkan pemilik layanan. Fitur ini tidak diposisikan sebagai layanan darurat.

## S17 Komunitas

**PDF.** App bar back dan judul `Komunitas`. Tab `Semua` aktif hijau, `Populer`, `Saya` abu muda. Dua bidang besar abu muda di area feed sebagai placeholder. Tombol hijau lebar `+ Buat Postingan` dekat bawah. Tidak ada bottom bar dan tidak ada avatar/like/comments lengkap pada S1.

**PROPOSED.** D0 menampilkan feed contoh berlabel atau empty state `Komunitas belum tersedia pada versi demo`. Dua placeholder tidak boleh menjadi loading tanpa akhir. Tap Buat Postingan membuka penjelasan fitur belum aktif atau editor draft lokal berlabel yang tidak mempunyai aksi publish nyata. Baseline P0 memilih penjelasan unavailable, bukan membangun moderasi.

**D2.** Postingan dan komentar memerlukan pemilik konten, pelaporan, moderasi, aturan identitas anak, penghapusan dan pembatasan spam. Jangan mengaktifkan publish hanya karena UI berhasil dibuat. Tab Saya hanya memuat milik akun sendiri; Populer memerlukan definisi ranking terpisah.

## Layar pelengkap yang tidak digambar pada PDF

Semua extension menggunakan bahasa visual yang sama: app bar putih, heading gelap, field abu, CTA hijau, tanpa dekorasi baru. Mereka tidak dihitung sebagai 17 layar sumber.

| ID | Fungsi | Komponen dan batas |
|---|---|---|
| E01 | Pemulihan password | Identifier, kirim, konfirmasi generik; demo tidak mengirim email/SMS |
| E02 | Pilih/tambah anak | Daftar nama; form nama, DOB, jenis kelamin sesuai standar; empty state; tidak lintas akun |
| E03 | Privasi/consent | Tujuan, data, penerima, retensi, hak; versi; persetujuan terpisah sesuai kebutuhan |
| E04 | Edit profil | Form fields relevan, simpan/cancel; optionalitas sesuai kebutuhan penelitian |
| E05 | Batas demo skrining | Penjelasan instrumen belum ada; lihat contoh atau kembali; tanpa perhitungan |
| E06 | Tambah pengukuran | Tanggal, BB, TB, sumber/catatan; konfirmasi; grafik rerender |
| E07 | Catatan kebiasaan | Aktivitas/durasi, makanan/porsi URT, air/volume optional; tanpa kalori otomatis |
| E08 | Editor reminder | Judul, waktu, hari, status izin/scheduling; simpan dan hapus |
| E09 | Detail edukasi | Judul, konten/media, sumber, status offline; tidak autoplay |
| E10 | Kuis dan hasil | Soal, pilihan, feedback, hasil pengetahuan; attempt/version tersimpan |

## Checklist kesetiaan sebelum menerima hasil agent

Periksa seluruh 17 screenshot secara berdampingan dengan referensi: struktur, urutan field, label menu, warna dominan, pilihan tab, posisi CTA, keberadaan/tidak adanya bottom bar, ikon dan foto. Jangan menetapkan ambang pixel-diff ketat sebelum aset/font final dan viewport sumber disepakati. Isi data dinamis, status keselamatan, aksesibilitas, cropped frame dan keyboard adalah deviasi yang dijelaskan, bukan kegagalan meniru sumber.

Nilai `50%`, status `Risiko Rendah`, menu/nilai gizi dan grafik pada sumber bukan data pengguna. Fitur yang belum digambar tidak boleh dipresentasikan sebagai desain asli. Bila stakeholder memilih gambar DOCX sebagai acuan visual menggantikan S1, buat revisi baseline seluruh screen mapping terlebih dahulu.
