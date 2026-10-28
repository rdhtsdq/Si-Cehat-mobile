# Firebase / FCM Setup

Konfigurasi FlutterFire untuk project `si-cehat` sudah dibuat:

- `lib/firebase_options.dart`
- `android/app/google-services.json`
- `firebase.json`
- Plugin Gradle `com.google.gms.google-services` terpasang.

Android package yang terdaftar: `com.example.si_cehat_mobile`.

## Jika perlu generate ulang

Pastikan `flutterfire` ada di PATH (User PATH):

```text
%LOCALAPPDATA%\Pub\Cache\bin
```

Lalu dari root project Flutter:

```powershell
flutterfire configure --project=si-cehat --platforms=android --yes
```

`flutterfire` membutuhkan Firebase CLI yang sudah login:

```powershell
npm install -g firebase-tools
firebase login
firebase projects:list
```

## Backend push

Tambahkan salah satu credential berikut ke `.env` backend (jangan commit nilai asli):

```env
FIREBASE_SERVICE_ACCOUNT_JSON='{"type":"service_account",...}'
# atau
GOOGLE_APPLICATION_CREDENTIALS="C:\path\service-account.json"
```

Ambil service account dari Firebase Console → Project Settings → Service
Accounts → Generate new private key.

Tanpa credential, API tetap berjalan dan push dilewati (no-op).

## Alur token

Firebase Messaging 17 memakai **Firebase Installation ID (FID)**, bukan
registration token lama. Mobile mengirim FID ke:

```text
POST /api/notifications/devices
{ "token": "<FID>", "platform": "android" }
```

Backend menyimpannya di tabel `DeviceToken` dan mengirim push memakai
`sendEachForMulticast({ fids: [...] })` dari `firebase-admin`.

Logout mobile memanggil:

```text
DELETE /api/notifications/devices?token=<FID>
```

## Uji cepat

1. Login di app, buka tab Reminder, izinkan notifikasi.
2. Pastikan baris `DeviceToken` muncul di database.
3. Buat reminder baru atau selesaikan PlayLab.
4. Push masuk ke notification tray (background) atau ditampilkan lewat channel
   `general` (foreground).
5. Tap notifikasi membuka pusat notifikasi / layar Reminder.

## Catatan

- `google-services.json` dan `firebase_options.dart` berisi client API key
  Firebase (bukan server secret). File service account **tidak boleh** masuk
  repo.
- Jika `flutterfire configure` dijalankan ulang, ia mungkin menurunkan versi
  plugin Google Services ke 4.3.15; naikkan kembali ke `4.5.0` agar cocok dengan
  AGP 9.
