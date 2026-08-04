# 🚀 Quick Start - Setup Environment

## Status Environment Anda Saat Ini

Berdasarkan pemeriksaan:
- ✅ **Git**: Terinstal (v2.52.0)
- ⚠️ **Java**: Terinstal tapi versi 1.8 (PERLU UPGRADE ke 17)
- ❌ **Flutter**: Belum terinstal  
- ✅ **Android SDK**: Terdeteksi di `C:\Users\muham\AppData\Local\Android\Sdk`
- ✅ **local.properties**: Sudah dikonfigurasi

---

## ⚡ Yang Harus Dilakukan Sekarang

### 1. Install JDK 17 (PENTING!)
1. Download: **https://adoptium.net/temurin/releases/?version=17**
2. Pilih: **Windows x64**, **JDK**, **.msi installer**
3. Install dengan klik 2x file .msi
4. Restart PowerShell setelah install

### 2. Install Flutter SDK (PENTING!)
1. Download: **https://docs.flutter.dev/get-started/install/windows**
2. Download file: `flutter_windows_xxx-stable.zip`
3. Ekstrak ke: `C:\src\flutter`
4. Tambah ke PATH:
   ```powershell
   # Buka PowerShell sebagai Administrator
   $path = [System.Environment]::GetEnvironmentVariable('Path', 'User')
   [System.Environment]::SetEnvironmentVariable('Path', $path + ';C:\src\flutter\bin', 'User')
   ```
5. Restart PowerShell
6. Test: `flutter --version`

### 3. Setup Android Studio & SDK
1. Download: **https://developer.android.com/studio**
2. Install Android Studio
3. Buka Android Studio → **SDK Manager**
4. Install components:
   - ✅ Android SDK Platform 36 (atau terbaru)
   - ✅ Android SDK Build-Tools
   - ✅ Android SDK Command-line Tools (latest)
   - ✅ Android Emulator
   - ✅ NDK (pilih versi 28.2.13676358)
   - ✅ CMake (pilih versi 3.22.1)

### 4. Accept Android Licenses
```powershell
flutter doctor --android-licenses
# Ketik 'y' untuk menerima semua
```

### 5. Buat Android Virtual Device (Emulator)
1. Android Studio → **Device Manager** (icon ponsel)
2. **Create Device** → Pilih **Pixel 7** atau **Pixel 8**
3. System Image → Pilih **API 34** atau **36** (download jika perlu)
4. **Finish**
5. Klik **Play** untuk start emulator

---

## 🏃 Menjalankan Aplikasi

### Persiapan Project
```powershell
# Di folder project
cd C:\laragon\www\Search-UGM-Mobile-Source-v1.2.0

# Clean & get dependencies
flutter clean
flutter pub get

# Quality check (optional)
flutter analyze
flutter test
```

### Jalankan di Emulator
```powershell
# Pastikan emulator sudah jalan
flutter devices

# Run aplikasi
flutter run

# Atau dalam mode profile (lebih cepat)
flutter run --profile
```

---

## 🔧 Tools & Scripts yang Tersedia

1. **`check-environment.ps1`** - Cek status environment
   ```powershell
   .\check-environment.ps1
   ```

2. **`SETUP_ENVIRONMENT.md`** - Panduan lengkap & troubleshooting

3. **`docs/DEVELOPMENT_INSTALLATION_GUIDE.md`** - Dokumentasi teknis lengkap

---

## ✅ Checklist Setup

- [ ] Install JDK 17 dari https://adoptium.net/
- [ ] Install Flutter SDK dari https://docs.flutter.dev/
- [ ] Install Android Studio dari https://developer.android.com/studio
- [ ] Setup Android SDK components
- [ ] Run `flutter doctor --android-licenses`
- [ ] File `android/local.properties` sudah dikonfigurasi (✅ done)
- [ ] Buat Android Virtual Device (emulator)
- [ ] Test: `flutter doctor` (semua harus centang hijau)
- [ ] Test: `flutter pub get`
- [ ] Test: `flutter run`

---

## 🆘 Troubleshooting Cepat

**Flutter command not found?**
```powershell
# Tambah ke PATH (ganti dengan path instalasi Flutter Anda)
$path = [System.Environment]::GetEnvironmentVariable('Path', 'User')
[System.Environment]::SetEnvironmentVariable('Path', $path + ';C:\src\flutter\bin', 'User')
# Restart PowerShell
```

**Gradle error?**
```powershell
flutter clean
flutter pub get
```

**Emulator lambat?**
- Gunakan perangkat fisik via USB (enable Developer Mode & USB Debugging)
- Atau kurangi RAM emulator di AVD settings

---

## 📞 Next Steps

1. Jalankan `check-environment.ps1` untuk verifikasi
2. Install komponen yang belum ada (JDK 17 & Flutter)
3. Restart PowerShell setelah instalasi
4. Run `flutter doctor` untuk final check
5. Buat emulator di Android Studio
6. `flutter run` untuk menjalankan app!

**Dokumentasi lengkap**: `SETUP_ENVIRONMENT.md`
