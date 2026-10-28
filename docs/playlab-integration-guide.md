# Panduan Integrasi Si-Cehat PlayLab pada Flutter Mobile

> **Versi Dokumen:** 1.0.0  
> **Terakhir Diperbarui:** Oktober 2026  
> **Target SDK:** Flutter 3.12+ / Dart 3.0+  
> **Komponen Terkait:** `Si-Cehat-mobile`, `si-cehat-game-web`, `Si-Cehat` (Backend)

Panduan ini mendokumentasikan implementasi lengkap integrasi mini-game edukasi **Si-Cehat PlayLab ("Piring Sehat Nimbo")** ke dalam aplikasi Flutter mobile `Si-Cehat-mobile`.

---

## 1. Arsitektur & Gambaran Umum

Mini-game edukasi PlayLab dijalankan sebagai aplikasi web interaktif mandiri yang disematkan ke dalam aplikasi Flutter melalui `webview_flutter` dengan jalur komunikasi JavaScript Bridge dua arah (`PlayLabBridge`).

```
┌─────────────────────────────────────────────────────────────┐
│                   Flutter Mobile Host                       │
│  ┌───────────────────────┐       ┌───────────────────────┐  │
│  │    EducationScreen    │       │  PlayLabGameScreen    │  │
│  │   (Banner & Riwayat)  │       │  (WebView Container)  │  │
│  └──────────┬────────────┘       └──────────┬────────────┘  │
│             │                               │               │
│             ▼                               ▼               │
│  ┌───────────────────────┐       ┌───────────────────────┐  │
│  │ PlayLabStorageService │       │     PlayLabBridge     │  │
│  │ (Prefs & SQLite Log)  │       │  (JavascriptChannel)  │  │
│  └───────────────────────┘       └──────────▲────────────┘  │
└─────────────────────────────────────────────┼───────────────┘
                                              │ postMessage (JSON)
                                              ▼
┌─────────────────────────────────────────────────────────────┐
│            Web Mini-Game (si-cehat-game-web)                │
│  - React 18 + Vite + TypeScript + Tailwind CSS              │
│  - 3 Babak Gameplay Praktik Gizi Seimbang                   │
│  - 2 Soal Kuis Evaluasi Pengetahuan                         │
│  - Aset Vektor SVG Maskot Nimbo & 14 Ikon Bahan Makanan     │
└─────────────────────────────────────────────▲───────────────┘
                                              │ REST API
                                              ▼
┌─────────────────────────────────────────────────────────────┐
│                 Si-Cehat Bun/Hono Backend                   │
│  - POST /api/game-sessions (Handshake Bootstrap Token)      │
│  - POST /api/game-sessions/bootstrap/exchange               │
│  - POST /api/game-sessions/:id/complete (Kalkulasi Skor)    │
│  - GET  /api/game-sessions/:id/result (Verifikasi Kanonikal)│
└─────────────────────────────────────────────────────────────┘
```

---

## 2. Konfigurasi Lingkungan (Environment & Networking)

### 2.1 URL Endpoint & Base Constants

Konfigurasi URL didefinisikan pada [`lib/core/api/api_constants.dart`](lib/core/api/api_constants.dart):

```dart
class ApiConstants {
  // Production backend & web game host (default for every build)
  static const String productionUrl = 'https://sicehat.id';

  static String get baseUrl {
    // Optional local override (--dart-define or saved custom URL)
    const definedUrl = String.fromEnvironment('API_BASE_URL');
    if (definedUrl.isNotEmpty) return _normalizeUrl(definedUrl);
    return productionUrl;
  }

  // The web game is served by the same host. PlayLabGameScreen appends /playlab.
  static String get gameWebUrl {
    final baseUri = Uri.tryParse(baseUrl);
    if (baseUri != null && baseUri.hasAuthority) {
      final portPart = baseUri.hasPort ? ':${baseUri.port}' : '';
      return '${baseUri.scheme}://${baseUri.host}$portPart';
    }
    return baseUrl;
  }

  static const String gameSessions = '/api/game-sessions';
  static String gameSessionResult(String sessionId) => '/api/game-sessions/$sessionId/result';
}
```

Untuk pengujian lokal tanpa mengubah source:

```powershell
flutter run --dart-define=API_BASE_URL=http://10.0.2.2:3000
```

Web game harus dilayani pada host yang sama dengan path `/playlab`.

### 2.2 Izin Akses Android (`AndroidManifest.xml`)

Build produksi hanya mengizinkan HTTPS (`android:usesCleartextTraffic="false"` di `android/app/src/main/AndroidManifest.xml`). Untuk pengembangan lokal dengan HTTP, override hanya ada di `android/app/src/debug/AndroidManifest.xml`:

```xml
<manifest xmlns:android="http://schemas.android.com/apk/res/android"
    xmlns:tools="http://schemas.android.com/tools">
    <uses-permission android:name="android.permission.INTERNET"/>

    <application
        android:usesCleartextTraffic="true"
        tools:replace="android:usesCleartextTraffic" />
</manifest>
```

### 2.3 Konfigurasi iOS (`Info.plist`)

Untuk menjalankan web game lokal pada simulator iOS, tambahkan konfigurasi App Transport Security pada `ios/Runner/Info.plist`:

```xml
<key>NSAppTransportSecurity</key>
<dict>
    <key>NSAllowsArbitraryLoadsInWebContent</key>
    <true/>
    <key>NSAllowsLocalNetworking</key>
    <true/>
</dict>
```

---

## 3. Siklus Sesi & Autentikasi Bootstrap Handshake

Untuk menjaga privasi anak dan kepatuhan HIPAA/COPPA, **JWT token orang tua tidak pernah dikirim melalui query parameter URL WebView**. Sebagai gantinya, digunakan sistem tiket sekali pakai (*ephemeral bootstrap token*):

1. **Inisiasi Sesi dari Flutter**:
   Flutter memanggil endpoint backend dengan autentikasi `Bearer <Guardian_JWT>`:
   ```http
   POST /api/game-sessions
   Content-Type: application/json

   {
     "gameSlug": "piring-sehat-nimbo",
     "childId": "1"
   }
   ```
2. **Respon Backend**:
   Backend membuat entitas sesi dan mengembalikan `sessionId` serta `bootstrapToken` berumur pendek (**TTL: 60 detik**):
   ```json
   {
     "success": true,
     "session": { "id": "sess_abc123", "status": "IN_PROGRESS" },
     "bootstrapToken": "bt_xyz789"
   }
   ```
3. **Pemuatan WebView**:
   Flutter memuat URL game dengan query parameter token sementara:
   ```
   https://sicehat.id/playlab?bootstrap=bt_xyz789&sessionId=sess_abc123
   ```
4. **Penukaran Token oleh Web Game**:
   Web game memanggil `POST /api/game-sessions/bootstrap/exchange` untuk memvalidasi token dan memperoleh token otorisasi sesi lokal.

---

## 4. Protokol Komunikasi JavaScript Bridge (`PlayLabBridge`)

Flutter menyuntikkan `JavascriptChannel` bernama `PlayLabBridge` ke dalam `WebViewController`:

```dart
final controller = WebViewController()
  ..setJavaScriptMode(JavaScriptMode.unrestricted)
  ..addJavaScriptChannel(
    'PlayLabBridge',
    onMessageReceived: (JavaScriptMessage msg) {
      _handleBridgeMessage(msg.message);
    },
  );
```

### 4.1 Spesifikasi Pesan Masuk (`GameToAppMessage`)

| Tipe Pesan | Payload JSON | Aksi Host Flutter |
| :--- | :--- | :--- |
| `GAME_READY` | `{"type":"GAME_READY","protocolVersion":1}` | Menyembunyikan indikator loading native; WebView siap tampil. |
| `GAME_COMPLETED` | `{"type":"GAME_COMPLETED","sessionId":"...","scores":{...}}` | Menerima data skor evaluasi, menyimpan ke storage lokal & SQLite, serta menampilkan dialog hasil. |
| `EXIT_GAME` | `{"type":"EXIT_GAME"}` | Menutup layar game secara mulus dan kembali ke menu Si-Cehat. |

### 4.2 Struktur Data `scores` pada `GAME_COMPLETED`

```json
{
  "type": "GAME_COMPLETED",
  "sessionId": "sess_abc123",
  "scores": {
    "gameplayScore": 100,
    "knowledgeScore": 100,
    "totalScore": 100,
    "starsEarned": 3,
    "xpAwarded": 75
  }
}
```

---

## 5. Manajemen Skor, Persistensi & Catatan Aktivitas Anak

### 5.1 Model Skor ([`PlayLabScoreResult`](lib/data/models/playlab_score_model.dart))

Menyimpan metrik lengkap pencapaian anak:
- `gameplayScore`: Skor praktik piring sehat (0–100).
- `knowledgeScore`: Skor kuis evaluasi gizi (0–100).
- `totalScore`: Total skor terbobot (0–100).
- `starsEarned`: Jumlah bintang yang diraih (1–3 bintang).
- `xpAwarded`: Tambahan XP Si-Cehat (+50 s.d. +75 XP).
- `feedbackSummary`: Rekomendasi gizi dari maskot Nimbo.

### 5.2 Layanan Persistensi ([`PlayLabStorageService`](lib/core/services/playlab_storage_service.dart))

Setiap kali sesi permainan selesai, layanan ini melakukan tiga hal:
1. Menyimpan skor terbaru anak ke dalam `SharedPreferences` (`playlab_latest_score_<childId>`).
2. Menyimpan daftar riwayat (hingga 10 sesi terakhir).
3. **Mencatat Otomatis ke SQLite `activity_logs`**:
   Data permainan otomatis tercatat pada diari kesehatan anak di bawah kategori **Gizi Seimbang**:
   ```dart
   final log = ActivityLogModel(
     childId: parsedChildId,
     date: dateStr,
     title: 'Edukasi PlayLab: Piring Sehat Nimbo (${result.totalScore} Poin)',
     category: 'Gizi Seimbang',
     durationMinutes: 10,
     intensity: 'Ringan',
     notes: 'Meraih ${result.starsEarned} Bintang & +${result.xpAwarded} XP. ${result.feedbackSummary}',
   );
   await DatabaseHelper.instance.insertActivity(log);
   ```

### 5.3 Dialog Perayaan Nilai Anak ([`PlayLabScoreDialog`](lib/screens/education/widgets/playlab_score_dialog.dart))

Dialog modal bottom sheet ramah anak menampilkan:
- Bintang emas animasi (`Icons.star_rounded`).
- Sapaan personal: *"Hebat Sekali, [Nama Anak]!"*.
- Pembagian nilai transparan:
  - **Praktik Piring Sehat**: `100 / 100` (Ikon sendok & garpu)
  - **Kuis Evaluasi Gizi**: `100 / 100` (Ikon edukasi)
- Lencana hadiah XP: `+75 XP Edukasi Berhasil Diraih`.
- Tombol aksi: *"Kembali ke Si-Cehat"* atau *"Susun Piring Lainnya"*.

### 5.4 Banner Interaktif pada [`EducationScreen`](lib/screens/education/education_screen.dart)

Banner edukasi PlayLab mendeteksi riwayat bermain anak:
- **Jika belum pernah main**: Menampilkan ajakan *"Susun variasi makanan seimbang & kuis!"* dan tombol **"Main Sekarang"**.
- **Jika sudah ada skor**: Menampilkan bintang perolehan anak, skor terakhir (`100/100`), tombol **"Lihat Nilai"** (membuka kembali dialog evaluasi lengkap), dan tombol **"Main Lagi"**.

---

## 6. Kompatibilitas Multi-Platform (Desktop vs Mobile)

Paket `webview_flutter` berbasis native platform Android dan iOS. Saat aplikasi dijalankan pada lingkungan desktop Windows (`flutter run -d windows`):

1. Flutter secara otomatis mendeteksi platform:
   ```dart
   final isDesktop = defaultTargetPlatform != TargetPlatform.android &&
                     defaultTargetPlatform != TargetPlatform.iOS;
   ```
2. Pada desktop Windows:
   - Tampilan beralih ke kartu launcher desktop.
   - Tombol **"Buka Game di Browser"** membuka browser default (Chrome/Edge) melalui `url_launcher`.
   - Tombol **"Simulasi Selesai"** memungkinkan pengujian alur skor dan persistensi tanpa memerlukan emulator mobile.

---

## 7. Standar Desain Bebas Emotikon (Zero-Emoticon Policy)

Seluruh komponen Flutter dan web game mematuhi pedoman visual resmi Si-Cehat:
- **Tanpa Emotikon Unicode**: Tidak menggunakan emoji mentah (seperti 🍽️, ⭐, 🥗, 🎮).
- **Menggunakan Material Icons / Vektor**:
  - Rating Bintang: `Icon(Icons.star_rounded, color: Color(0xFFF59E0B))`
  - Makanan & Menu: `Icon(Icons.restaurant_menu_rounded, color: AppColors.primaryGreen)`
  - Edukasi & Kuis: `Icon(Icons.school_rounded, color: Color(0xFF2563EB))`
  - Hadiah XP: `Icon(Icons.stars_rounded, color: Color(0xFF15803D))`
  - Status Jaringan: `Icon(Icons.wifi_off_rounded, color: Color(0xFFE53935))`

---

## 8. Verifikasi & Pengujian Otomatis

### 8.1 Menjalankan Pengujian Unit Flutter

Jalankan seluruh test suite. Test PlayLab saat ini berada di `test/playlab_storage_test.dart` dan memverifikasi deduplikasi riwayat serta activity log per sesi:

```powershell
flutter test
```

Hasil verifikasi terakhir: **21 test lulus** (`00:05 +21: All tests passed!`).

### 8.2 Menjalankan Analisis Statis Kode

```powershell
flutter analyze
```

Hasil verifikasi:
```text
No issues found!
```

---

## 9. Panduan Pemecahan Masalah (Troubleshooting)

| Masalah | Kemungkinan Penyebab | Solusi |
| :--- | :--- | :--- |
| **WebView putih / net::ERR_CONNECTION_REFUSED** | Host game tidak dapat dijangkau dari perangkat/emulator. | `ApiConstants.gameWebUrl` menurunkan host dari `baseUrl`, lalu `PlayLabGameScreen` menambahkan path `/playlab`. Pastikan host tersebut melayani halaman game. |
| **CLEARTEXT communication not permitted** | Android 9+ memblokir HTTP non-TLS; build release memang menonaktifkan cleartext. | Gunakan HTTPS (produksi). Untuk backend lokal, jalankan build debug yang meng-override `usesCleartextTraffic` di `android/app/src/debug/AndroidManifest.xml`. |
| **Null pointer pada WebViewPlatform.instance** | Dijalankan pada Windows desktop tanpa platform WebView. | `PlayLabGameScreen` telah dilengkapi deteksi otomatis platform desktop dengan fallback browser launcher. |
| **Skor tidak tersimpan setelah main** | Sesi ID tidak terdeteksi saat game selesai. | `PlayLabStorageService` menyimpan fallback skor global dan mengaitkannya dengan `activeChild` dari `profileProvider` (Riverpod). |
| **Dialog skor ganda / entri diary dobel** | `GAME_COMPLETED`, `EXIT_GAME`, dan app-resume meminta skor untuk sesi yang sama. | `PlayLabGameScreen` memakai single-flight fetch dan `PlayLabStorageService` menyimpan daftar `playlab_saved_session_ids` untuk deduplikasi. |

---

## 10. Catatan Implementasi Terkini

- Entry PlayLab dari Beranda maupun layar Edukasi sama-sama menampilkan `PlayLabScoreDialog` setelah sesi selesai.
- Keluar di tengah permainan tidak lagi menampilkan skor sesi sebelumnya; skor hanya dikembalikan bila sesi tersebut benar-benar selesai.
- Implementasi WebView ganda (`lib/screens/game/game_webview_screen.dart`) sudah dihapus; satu-satunya host adalah `PlayLabGameScreen`.
- Pusat notifikasi disinkronkan ke backend (`GET/PATCH/DELETE /api/notifications`, `POST /api/notifications/read-all`) dengan cache SQLite sebagai fallback offline. Backend membuat notifikasi otomatis untuk registrasi, pengingat baru, konsultasi, dan penyelesaian PlayLab.
- Pengingat lokal dijadwalkan lewat `flutter_local_notifications` dan tetap muncul saat aplikasi ditutup. FCM disiapkan sebagai lapisan fase 2: endpoint `POST/DELETE /api/notifications/devices` dan push service backend sudah ada, sedangkan plugin Firebase mobile diaktifkan setelah `google-services.json` tersedia.
- XP PlayLab disimpan pada `DailyProgress` dengan kunci tanggal UTC yang sama dengan `GET /api/progress`. `POST /api/progress` bersifat parsial, sehingga mencatat air minum atau aktivitas tidak mereset XP/streak.
- `ApiClient` menolak respons HTML dari route yang tidak dikenal agar fallback SPA tidak dianggap sukses.
