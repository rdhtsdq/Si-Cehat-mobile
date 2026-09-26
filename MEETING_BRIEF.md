# Ringkasan Diskusi Si Cehat Mobile

26 September 2026 — baseline usulan, belum menjadi keputusan tim.

## Keputusan yang disarankan

Fokuskan pengerjaan dekat deadline pada **satu aplikasi mobile Android untuk ibu/orang tua**, mengikuti 17 layar PDF. Simpan proyek web; jangan menghapusnya dan jangan mengembangkan dua antarmuka penuh sekaligus saat waktu sempit. Peran web sebagai portal/admin/pendamping anak dapat diputuskan setelah demo mobile stabil.

Target awal paling aman adalah APK demo lokal. Flutter merupakan asumsi teknis, bukan keputusan yang sudah disetujui. Blueprint menargetkan anak 6-12 tahun dengan ibu sebagai pengguna utama; bukan langsung menyalin desain permainan dari repo web.

## Yang dapat didemokan lebih dahulu

Profil dummy ibu/anak, beranda, grafik pengukuran lokal, katalog/detail menu, pratinjau edukasi, kuis penggunaan aplikasi, settings reminder, serta seluruh layar referensi yang dapat dijelajahi. Data lokal tetap tersimpan setelah restart. Notifikasi perangkat menjadi prioritas berikutnya setelah core stabil dan dapat diuji.

## Yang harus disebut belum siap

Persentase/kategori risiko nyata, interpretasi pertumbuhan, media/resep final tanpa reviewer, akun/backend pilot, konsultasi dengan nakes dan komunitas publik. Angka 50% di PDF hanya contoh desain. Tiga field langkah pertama bukan instrumen skrining lengkap. UI tersedia tidak sama dengan layanan siap.

## Lima keputusan yang dibutuhkan hari ini

1. Tanggal/jam tepat awal Oktober dan bentuk luaran: demo, APK lokal atau pilot responden?
2. Apakah PDF 17 layar disepakati sebagai visual master?
3. Apakah Android + Flutter disetujui, atau sudah ada source mobile lain?
4. Siapa pemilik instrumen klinis, review gizi/edukasi, dan aset media? Kapan tersedia?
5. Apakah integrasi backend ditunda sampai demo stabil, dan siapa menangani keamanan/consent sebelum data nyata?

## Usulan batas komitmen

Selesaikan demo core dan QA lebih dahulu. Jangan menjanjikan skrining tervalidasi atau pilot hanya karena tanggal dekat. Jika instrumen/izin belum tersedia, rilis terbatas edukasi/pencatatan hanya dapat dipertimbangkan bila tim menyetujui perubahan scope penelitian.

Rencana kerja: T00-T07 untuk demo, T08 untuk tambahan kebiasaan/notifikasi, T09-T10 untuk pilot aman, T11-T12 untuk klinis/layanan. Tanggal 1 Oktober adalah kandidat demo internal; 5 Oktober adalah kandidat buffer, keduanya masih perlu konfirmasi.

## Langkah setelah diskusi

Isi `DECISIONS.md`, masukkan paket ke proyek mobile baru, lalu berikan `AGENT_KICKOFF.md`. Mulai T00-T01 saja, review empat layar pertama, kemudian lanjut satu task setiap sesi. Jangan meminta agent 'membuat semua fitur siap produksi' tanpa gate dan uji.
