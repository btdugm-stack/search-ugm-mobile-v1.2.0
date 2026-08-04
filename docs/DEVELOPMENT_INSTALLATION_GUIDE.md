# Panduan Instalasi dan Development Search UGM Mobile

Dokumen ini digunakan untuk menyiapkan workstation developer, menjalankan aplikasi, membuat APK, dan meneruskan pengembangan Search UGM Mobile v1.2.0.

## 1. Prasyarat

### Minimum workstation

- Sistem operasi: Windows 11, macOS, atau Linux 64-bit.
- RAM: minimum 8 GB, disarankan 16 GB.
- Storage kosong: minimum 15 GB.
- Git.
- Flutter stable `3.44.8` atau versi stable yang kompatibel.
- Dart mengikuti Flutter SDK.
- Android Studio dan Android SDK.
- JDK 17.
- Perangkat Android API 24+ atau Android Emulator.

Untuk development iOS diperlukan:

- macOS.
- Xcode versi terbaru yang kompatibel dengan Flutter.
- CocoaPods.
- Apple Developer account untuk signing dan distribusi.

## 2. Ekstraksi source code

Ekstrak paket source:

```bash
unzip Search-UGM-Mobile-Source-v1.2.0.zip
cd search_ugm_mobile
```

Jika source ditempatkan di Git:

```bash
git clone <repository-url>
cd search_ugm_mobile
```

## 3. Instalasi Flutter

Unduh Flutter stable dari dokumentasi resmi, tambahkan folder `flutter/bin` ke `PATH`, lalu validasi:

```bash
flutter --version
dart --version
flutter doctor -v
```

Target baseline build:

```text
Flutter 3.44.8
Dart 3.12.2
Java 17
Android SDK API 36
```

Versi Flutter yang lebih baru boleh digunakan setelah seluruh test dan build divalidasi ulang.

## 4. Konfigurasi Android

### 4.1 Android Studio

Instal komponen berikut melalui SDK Manager:

- Android SDK Platform 36
- Android SDK Build-Tools
- Android SDK Platform-Tools
- Android SDK Command-line Tools
- Android Emulator, bila diperlukan
- NDK `28.2.13676358`
- CMake `3.22.1`

Terima Android SDK licenses:

```bash
flutter doctor --android-licenses
```

### 4.2 Android SDK path

Konfigurasikan lokasi SDK:

```bash
flutter config --android-sdk <path-android-sdk>
```

Flutter biasanya membuat `android/local.properties` secara otomatis saat build pertama. Jika diperlukan, salin template:

```bash
cp android/local.properties.example android/local.properties
```

Pada Windows, lakukan copy melalui File Explorer atau PowerShell:

```powershell
Copy-Item android/local.properties.example android/local.properties
```

Sesuaikan `sdk.dir` dan `flutter.sdk` dengan path absolut workstation. File `android/local.properties` tidak boleh di-commit.

## 5. Mengambil dependency

Dari root project:

```bash
flutter clean
flutter pub get
```

Dependency runtime dibuat minimal dan menggunakan Flutter SDK. Lock file tetap disertakan agar resolusi dependency konsisten.

## 6. Quality gate sebelum menjalankan aplikasi

```bash
flutter analyze
flutter test
```

Expected result:

```text
No issues found!
All tests passed!
```

Tes yang tersedia mencakup:

- Navigasi tanpa halaman Profil.
- Animasi expand/collapse akses cepat.
- Parameter API Jelajahi.
- Gesture pinch-to-zoom pada peta.

## 7. Menjalankan aplikasi

Lihat perangkat yang tersedia:

```bash
flutter devices
```

Jalankan mode debug:

```bash
flutter run
```

Menjalankan pada device tertentu:

```bash
flutter run -d <device-id>
```

Untuk menguji performa mendekati release:

```bash
flutter run --profile
```

## 8. Konfigurasi API

Endpoint berada pada:

```dart
// lib/src/api_client.dart
static const _endpoint =
    'https://search.ugm.ac.id/ai/search%26dsh/api/api.php';
```

Parameter Jelajahi mengikuti implementasi web:

```text
action=browse&type=<category>&page=1&limit=30
```

Jangan mengubah parameter `type` kembali menjadi `entity_type`, karena hal tersebut menyebabkan respons kategori bercampur pada kontrak API saat v1.2.0 dibangun.

Untuk environment development/staging, rekomendasinya memindahkan endpoint ke `--dart-define`:

```bash
flutter run --dart-define=API_BASE_URL=https://staging.example/api.php
```

Implementasi `dart-define` belum diterapkan pada v1.2.0 dan menjadi backlog yang direkomendasikan.

## 9. Build APK

Build release APK:

```bash
flutter build apk --release
```

Output default:

```text
build/app/outputs/flutter-apk/app-release.apk
```

Build APK per arsitektur untuk ukuran file lebih kecil:

```bash
flutter build apk --release --split-per-abi
```

Output akan dipisah untuk `arm64-v8a`, `armeabi-v7a`, dan `x86_64` sesuai dukungan build.

## 10. Build Android App Bundle

Play Store menggunakan AAB:

```bash
flutter build appbundle --release
```

Output:

```text
build/app/outputs/bundle/release/app-release.aab
```

Jangan mengunggah AAB sebelum release signing resmi dikonfigurasi.

## 11. Release signing Android

Konfigurasi v1.2.0 saat ini masih menggunakan debug signing pada build release untuk pengujian internal.

Sebelum Play Store:

1. Buat atau terima upload keystore resmi UGM.
2. Simpan keystore di lokasi aman di luar repository.
3. Simpan alias dan password pada secret manager/CI variables.
4. Tambahkan `key.properties` ke `.gitignore`.
5. Perbarui `android/app/build.gradle.kts` agar release menggunakan signing config resmi.
6. Build AAB dan verifikasi certificate fingerprint.
7. Aktifkan Play App Signing.

Contoh membuat keystore baru, hanya jika kebijakan UGM mengizinkan:

```bash
keytool -genkeypair -v \
  -keystore ugm-search-upload.jks \
  -keyalg RSA -keysize 2048 -validity 10000 \
  -alias ugm-search-upload
```

Jangan menyimpan file keystore, password, atau `key.properties` dalam Git.

## 12. Instalasi APK pada perangkat uji

Aktifkan Developer Options dan USB debugging, lalu:

```bash
adb install -r Search-UGM-Mobile-v1.2.0.apk
```

Atau kirim APK ke perangkat, izinkan instalasi dari sumber yang digunakan, lalu buka file APK.

Jika signature berbeda dengan versi sebelumnya, Android dapat menolak update. Uninstall versi lama khusus pada perangkat uji:

```bash
adb uninstall id.ac.ugm.search
adb install Search-UGM-Mobile-v1.2.0.apk
```

Uninstall akan menghapus histori lokal aplikasi.

## 13. Persiapan iOS

Project v1.2.0 yang diserahkan berfokus pada Android. Untuk menambahkan platform iOS, jalankan pada macOS dari root project:

```bash
flutter create --platforms=ios .
cd ios
pod install
cd ..
flutter run -d ios
```

Setelah itu:

- Tentukan bundle identifier resmi UGM.
- Konfigurasikan Team dan signing di Xcode.
- Tambahkan privacy usage descriptions jika fitur native baru memerlukannya.
- Uji external URL, jaringan, local history, peta, dan multi-touch pada perangkat fisik.
- Jalankan archive melalui Xcode atau `flutter build ipa`.

## 14. Struktur pengembangan

File utama:

| File | Fungsi |
|---|---|
| `lib/main.dart` | Entry point aplikasi |
| `lib/src/app.dart` | UI, navigasi, search, AI, maps, layanan, histori |
| `lib/src/api_client.dart` | HTTP client dan parameter API |
| `lib/src/models.dart` | Model domain sederhana |
| `lib/src/device_bridge.dart` | Integrasi native Android |
| `android/.../MainActivity.kt` | Open URL dan local history melalui method channel |
| `test/widget_test.dart` | Automated regression tests |

Untuk pengembangan skala tim, pecah `app.dart` menjadi modul per feature dan tambahkan layer repository/state management secara bertahap tanpa mengubah kontrak API yang sudah diuji.

## 15. Troubleshooting

### `flutter doctor` menunjukkan Android licenses belum diterima

```bash
flutter doctor --android-licenses
```

### Gradle menggunakan Java yang salah

```bash
flutter config --jdk-dir <path-jdk-17>
flutter doctor -v
```

### Dependency bermasalah

```bash
flutter clean
rm -rf .dart_tool
flutter pub get
```

PowerShell:

```powershell
flutter clean
Remove-Item .dart_tool -Recurse -Force
flutter pub get
```

### Aplikasi gagal mengakses API

- Pastikan perangkat memiliki internet.
- Uji endpoint melalui browser atau `curl`.
- Pastikan waktu perangkat benar dan sertifikat HTTPS dapat divalidasi.
- Periksa perubahan kontrak API backend.

### Tile peta tidak muncul

- Pastikan internet tersedia.
- Pastikan domain OpenStreetMap tidak diblokir jaringan.
- Periksa log `flutter run`.
- Tetap tampilkan atribusi OpenStreetMap ketika mengganti implementasi map.

### Update APK ditolak karena signature tidak sama

Versi sebelumnya ditandatangani certificate berbeda. Gunakan keystore yang sama untuk seluruh build berkelanjutan atau uninstall versi pengujian lama terlebih dahulu.

## 16. Definition of Done pengembangan berikutnya

Sebelum menyerahkan versi baru:

- `flutter analyze` tanpa issue.
- Seluruh automated test lulus.
- Smoke test API setiap kategori Jelajahi.
- Uji pinch, drag, marker, filter, dan direction pada perangkat fisik.
- Uji tanpa login dan histori lokal.
- Verifikasi package ID, version code, version name, signature, ukuran, dan SHA-256.
- Dokumentasikan perubahan pada build report dan release notes.
