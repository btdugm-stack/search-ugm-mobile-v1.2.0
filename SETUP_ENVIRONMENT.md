# 🚀 Panduan Setup Environment - Search UGM Mobile

Panduan ini akan membantu Anda mempersiapkan environment untuk menjalankan aplikasi Search UGM Mobile di emulator/simulator.

## 📊 Status Environment Saat Ini

Berdasarkan pemeriksaan:
- ✅ Git v2.52.0 - Sudah terinstal
- ⚠️ Java 1.8.0 - **PERLU UPGRADE ke JDK 17**
- ❌ Flutter - Belum terinstal
- ❓ Android Studio - Perlu instalasi

## 🔧 Langkah-langkah Instalasi

### 1️⃣ Install/Upgrade JDK 17

Aplikasi ini memerlukan **Java JDK 17** (saat ini Anda menggunakan Java 8).

#### Download JDK 17:
- **Recommended**: [Eclipse Temurin (OpenJDK 17)](https://adoptium.net/temurin/releases/?version=17)
  - Pilih: Windows x64, JDK, .msi installer
- **Alternatif**: [Oracle JDK 17](https://www.oracle.com/java/technologies/javase/jdk17-archive-downloads.html)

#### Instalasi:
1. Jalankan installer `.msi` yang sudah didownload
2. Ikuti wizard instalasi (gunakan path default)
3. Setelah selesai, buka **PowerShell sebagai Administrator** dan jalankan:

```powershell
# Set JAVA_HOME environment variable (sesuaikan path jika berbeda)
[System.Environment]::SetEnvironmentVariable('JAVA_HOME', 'C:\Program Files\Eclipse Adoptium\jdk-17.0.13.11-hotspot', 'Machine')

# Update PATH
$currentPath = [System.Environment]::GetEnvironmentVariable('Path', 'Machine')
$newPath = $currentPath + ';C:\Program Files\Eclipse Adoptium\jdk-17.0.13.11-hotspot\bin'
[System.Environment]::SetEnvironmentVariable('Path', $newPath, 'Machine')
```

4. **Restart PowerShell** dan verifikasi:
```powershell
java -version
# Harus menampilkan: openjdk version "17.0.x"
```

---

### 2️⃣ Install Flutter SDK

#### Opsi A - Manual Download (Recommended):

1. **Download Flutter SDK**:
   - Kunjungi: https://docs.flutter.dev/get-started/install/windows
   - Download Flutter SDK versi stable (minimal 3.44.8)
   - File: `flutter_windows_3.x.x-stable.zip`

2. **Ekstrak ke folder**:
   ```powershell
   # Buat folder untuk Flutter
   New-Item -ItemType Directory -Force -Path "C:\src"
   
   # Ekstrak flutter_windows_xxx-stable.zip ke C:\src\flutter
   # Gunakan File Explorer atau:
   Expand-Archive -Path "Downloads\flutter_windows_*-stable.zip" -DestinationPath "C:\src"
   ```

3. **Tambahkan Flutter ke PATH**:
   ```powershell
   # Buka PowerShell sebagai Administrator
   
   # Tambahkan Flutter ke PATH
   $currentPath = [System.Environment]::GetEnvironmentVariable('Path', 'User')
   $newPath = $currentPath + ';C:\src\flutter\bin'
   [System.Environment]::SetEnvironmentVariable('Path', $newPath, 'User')
   ```

4. **Restart PowerShell** dan verifikasi:
   ```powershell
   flutter --version
   # Harus menampilkan versi Flutter
   ```

#### Opsi B - Via Git Clone:

```powershell
cd C:\src
git clone https://github.com/flutter/flutter.git -b stable
$env:Path += ";C:\src\flutter\bin"
flutter --version
```

---

### 3️⃣ Install Android Studio

1. **Download Android Studio**:
   - Kunjungi: https://developer.android.com/studio
   - Download versi terbaru (minimal 2024.x)

2. **Instalasi**:
   - Jalankan installer `.exe`
   - Pilih **Standard Installation**
   - Ikuti wizard sampai selesai

3. **Setup Android SDK** (via Android Studio):
   - Buka Android Studio
   - Klik **More Actions** → **SDK Manager** atau
   - **Tools** → **SDK Manager**
   
4. **Install SDK Components**:
   
   **Tab "SDK Platforms"**:
   - ✅ Android 14.0 (API 34)
   - ✅ Android 15.0 (API 36) atau yang terbaru
   
   **Tab "SDK Tools"**:
   - ✅ Android SDK Build-Tools (versi terbaru)
   - ✅ Android SDK Command-line Tools (latest)
   - ✅ Android SDK Platform-Tools
   - ✅ Android Emulator
   - ✅ NDK (Side by side) - pilih versi 28.2.13676358
   - ✅ CMake - pilih versi 3.22.1
   
   Klik **Apply** untuk menginstall.

5. **Catat lokasi Android SDK**:
   - Biasanya di: `C:\Users\[Username]\AppData\Local\Android\Sdk`
   - Lihat di bagian atas jendela SDK Manager

---

### 4️⃣ Konfigurasi Flutter dengan Android

1. **Setup Flutter doctor**:
   ```powershell
   # Jalankan flutter doctor
   flutter doctor
   
   # Accept Android licenses
   flutter doctor --android-licenses
   # Ketik 'y' untuk menerima semua license
   ```

2. **Edit file local.properties**:
   
   File sudah dibuat di: `android\local.properties`
   
   Edit dengan path yang sesuai:
   ```properties
   # Ganti dengan path sebenarnya di komputer Anda
   sdk.dir=C:\\Users\\[YourUsername]\\AppData\\Local\\Android\\Sdk
   flutter.sdk=C:\\src\\flutter
   flutter.buildMode=debug
   flutter.versionName=1.2.0
   flutter.versionCode=3
   ```
   
   **Penting**: Gunakan double backslash `\\` atau forward slash `/`

---

### 5️⃣ Buat Android Virtual Device (Emulator)

1. **Via Android Studio**:
   - Buka Android Studio
   - **Tools** → **Device Manager** (atau icon ponsel di toolbar)
   - Klik **Create Device**
   
2. **Pilih Device**:
   - Category: **Phone**
   - Device: **Pixel 7** atau **Pixel 8** (recommended)
   - Klik **Next**

3. **Pilih System Image**:
   - Release Name: **UpsideDownCake** (API 34) atau **VanillaIceCream** (API 35/36)
   - ABI: **x86_64**
   - Klik **Download** jika belum ada
   - Setelah download selesai, klik **Next**

4. **Verify Configuration**:
   - AVD Name: (biarkan default atau beri nama)
   - Startup orientation: Portrait
   - Graphics: **Hardware - GLES 2.0** (atau Automatic)
   - Klik **Finish**

5. **Launch Emulator**:
   - Klik tombol **Play** (▶) di Device Manager
   - Tunggu emulator booting (pertama kali agak lama)

---

### 6️⃣ Instalasi Dependencies dan Running App

1. **Clean dan Get Dependencies**:
   ```powershell
   # Pastikan Anda di folder project
   cd C:\laragon\www\Search-UGM-Mobile-Source-v1.2.0
   
   # Clean project
   flutter clean
   
   # Get dependencies
   flutter pub get
   ```

2. **Quality Gate (Optional tapi Recommended)**:
   ```powershell
   # Analyze code
   flutter analyze
   
   # Run tests
   flutter test
   ```

3. **Check Available Devices**:
   ```powershell
   # Lihat device yang tersedia
   flutter devices
   
   # Harus muncul emulator yang sudah dibuat
   ```

4. **Run Application**:
   ```powershell
   # Run di emulator (pastikan emulator sudah berjalan)
   flutter run
   
   # Atau specify device tertentu
   flutter run -d emulator-5554
   
   # Untuk performance testing
   flutter run --profile
   ```

---

## 🔍 Troubleshooting

### Problem: `flutter: command not found`
**Solusi**: 
- Restart PowerShell setelah menambahkan PATH
- Atau tutup semua terminal dan buka yang baru
- Verifikasi PATH: `$env:Path -split ';' | Select-String flutter`

### Problem: `Android SDK not found`
**Solusi**:
```powershell
# Set Android SDK path
flutter config --android-sdk C:\Users\[YourUsername]\AppData\Local\Android\Sdk
```

### Problem: `cmdline-tools not found`
**Solusi**:
- Buka Android Studio → SDK Manager
- Tab "SDK Tools" → centang "Android SDK Command-line Tools (latest)"
- Klik Apply

### Problem: `Gradle build failed`
**Solusi**:
```powershell
# Update gradle wrapper
cd android
.\gradlew wrapper --gradle-version 8.13
cd ..

# Clean dan rebuild
flutter clean
flutter pub get
```

### Problem: Java version mismatch
**Solusi**:
```powershell
# Set JDK untuk Flutter
flutter config --jdk-dir "C:\Program Files\Eclipse Adoptium\jdk-17.0.13.11-hotspot"

# Verifikasi
flutter doctor -v
```

### Problem: Emulator sangat lambat
**Solusi**:
- Pastikan Hyper-V atau HAXM sudah enabled
- Gunakan x86_64 image (bukan ARM)
- Kurangi RAM emulator jika PC terbatas
- Atau gunakan perangkat fisik via USB debugging

---

## ✅ Verifikasi Final

Jalankan perintah ini untuk memastikan semua sudah siap:

```powershell
# Check Flutter
flutter doctor -v

# Output yang diharapkan:
# [✓] Flutter (Channel stable, 3.x.x)
# [✓] Android toolchain - develop for Android devices (Android SDK version 34.x)
# [✓] Android Studio (version 2024.x)
# [✓] Connected device (1 available)

# Check devices
flutter devices

# Check dependencies
flutter pub get

# Run tests
flutter test
```

Jika semua menampilkan ✓ (checkmark), environment Anda sudah siap!

---

## 📱 Alternatif: Menggunakan Perangkat Fisik

Jika emulator terlalu berat untuk PC Anda:

1. **Enable Developer Options** di Android:
   - Settings → About phone → Tap "Build number" 7x
   
2. **Enable USB Debugging**:
   - Settings → System → Developer options → USB debugging

3. **Connect via USB**:
   ```powershell
   # Check device connected
   flutter devices
   
   # Run on physical device
   flutter run
   ```

---

## 📚 Resources

- [Flutter Documentation](https://docs.flutter.dev/)
- [Android Studio Setup](https://developer.android.com/studio/install)
- [Flutter Windows Setup](https://docs.flutter.dev/get-started/install/windows)
- Dokumentasi Project: `docs/DEVELOPMENT_INSTALLATION_GUIDE.md`

---

## 🆘 Butuh Bantuan?

Jika mengalami kendala:
1. Check `flutter doctor -v` untuk detail error
2. Lihat dokumentasi di folder `docs/`
3. Pastikan semua environment variable sudah di-set dengan benar
4. Restart komputer setelah instalasi major components

**Target Versions**:
- Flutter: 3.44.8 atau lebih baru
- Dart: 3.12.2 (bundled dengan Flutter)
- Android SDK: API 24-36
- JDK: 17
- Gradle: 8.13
- Kotlin: 2.2.0
