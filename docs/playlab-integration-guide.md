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

Konfigurasi URL didefinisikan pada [`lib/core/api/api_constants.dart`](file:///c:/laragon/www/Si-Cehat-mobile/lib/core/api/api_constants.dart):

```dart
class ApiConstants {
  // Backend API Base URL
  static String get baseUrl {
    if (kIsWeb) return 'http://localhost:3000';
    if (defaultTargetPlatform == TargetPlatform.android) return 'http://10.0.2.2:3000';
    return 'http://localhost:3000';
  }

  // Web Mini-Game Base URL
  static String get gameWebUrl {
    if (kIsWeb) return 'http://localhost:5173';
    if (defaultTargetPlatform == TargetPlatform.android) return 'http://10.0.2.2:5173';
    return 'http://localhost:5173';
  }

  static const String gameSessions = '/api/game-sessions';
  static String gameSessionResult(String sessionId) => '/api/game-sessions/$sessionId/result';
}
```

### 2.2 Izin Akses Android (`AndroidManifest.xml`)

Untuk pengembangan lokal menggunakan HTTP (non-HTTPS), pastikan atribut `usesCleartextTraffic` diaktifkan pada `android/app/src/main/AndroidManifest.xml`:

```xml
<manifest xmlns:android="http://schemas.android.com/apk/res/android">
    <uses-permission android:name="android.permission.INTERNET"/>

    <application
        android:label="Si-Cehat"
        android:usesCleartextTraffic="true"
        android:icon="@mipmap/ic_launcher">
        <!-- ... -->
    </application>
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
   http://10.0.2.2:5173/?token=bt_xyz789
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

### 5.1 Model Skor ([`PlayLabScoreResult`](file:///c:/laragon/www/Si-Cehat-mobile/lib/data/models/playlab_score_model.dart))

Menyimpan metrik lengkap pencapaian anak:
- `gameplayScore`: Skor praktik piring sehat (0–100).
- `knowledgeScore`: Skor kuis evaluasi gizi (0–100).
- `totalScore`: Total skor terbobot (0–100).
- `starsEarned`: Jumlah bintang yang diraih (1–3 bintang).
- `xpAwarded`: Tambahan XP Si-Cehat (+50 s.d. +75 XP).
- `feedbackSummary`: Rekomendasi gizi dari maskot Nimbo.

### 5.2 Layanan Persistensi ([`PlayLabStorageService`](file:///c:/laragon/www/Si-Cehat-mobile/lib/core/services/playlab_storage_service.dart))

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

### 5.3 Dialog Perayaan Nilai Anak ([`PlayLabScoreDialog`](file:///c:/laragon/www/Si-Cehat-mobile/lib/screens/education/widgets/playlab_score_dialog.dart))

Dialog modal bottom sheet ramah anak menampilkan:
- Bintang emas animasi (`Icons.star_rounded`).
- Sapaan personal: *"Hebat Sekali, [Nama Anak]!"*.
- Pembagian nilai transparan:
  - **Praktik Piring Sehat**: `100 / 100` (Ikon sendok & garpu)
  - **Kuis Evaluasi Gizi**: `100 / 100` (Ikon edukasi)
- Lencana hadiah XP: `+75 XP Edukasi Berhasil Diraih`.
- Tombol aksi: *"Kembali ke Si-Cehat"* atau *"Susun Piring Lainnya"*.

### 5.4 Banner Interaktif pada [`EducationScreen`](file:///c:/laragon/www/Si-Cehat-mobile/lib/screens/education/education_screen.dart)

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

Jalankan test suite PlayLab untuk memvalidasi parser protokol bridge dan persistensi skor:

```powershell
cd c:\laragon\www\Si-Cehat-mobile
flutter test test/playlab_score_test.dart test/playlab_bridge_test.dart
```

Hasil verifikasi:
```text
00:00 +0: PlayLabScoreResult Model Tests serializes and deserializes score result correctly
00:00 +1: PlayLabScoreResult Model Tests saves and retrieves latest score from storage service
00:00 +2: PlayLabBridge Message Protocol parses GAME_READY message payload
00:00 +3: PlayLabBridge Message Protocol parses GAME_COMPLETED message with decoupled scores
00:00 +4: PlayLabBridge Message Protocol parses EXIT_GAME message cleanly
00:00 +5: PlayLabBridge Message Protocol safely discards malformed or unknown bridge messages
00:00 +6: All tests passed!
```

### 8.2 Menjalankan Analisis Statis Kode

```powershell
flutter analyze lib/screens/education/ lib/core/services/playlab_storage_service.dart lib/data/models/playlab_score_model.dart
```

Hasil verifikasi:
```text
Analyzing 5 items...
No issues found!
```

---

## 9. Panduan Pemecahan Masalah (Troubleshooting)

| Masalah | Kemungkinan Penyebab | Solusi |
| :--- | :--- | :--- |
| **WebView putih / net::ERR_CONNECTION_REFUSED** | URL menggunakan `localhost` pada emulator Android. | Gunakan `http://10.0.2.2:5173` untuk Android emulator (sudah ditangani otomatis oleh `ApiConstants.gameWebUrl`). |
| **CLEARTEXT communication not permitted** | Android 9+ memblokir HTTP non-TLS secara default. | Pastikan `android:usesCleartextTraffic="true"` terpasang pada `AndroidManifest.xml` untuk lingkungan development. |
| **Null pointer pada WebViewPlatform.instance** | Dijalankan pada Windows desktop tanpa platform WebView. | `PlayLabGameScreen` telah dilengkapi deteksi otomatis platform desktop dengan fallback browser launcher. |
| **Skor tidak tersimpan setelah main** | Sesi ID tidak terdeteksi saat game selesai. | `PlayLabStorageService` menyimpan fallback skor global dan otomatis mengaitkan dengan `activeChild` yang sedang aktif di `ProfileProvider`. |
