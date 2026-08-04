# Script Setup Environment untuk Search UGM Mobile
# Jalankan dengan: .\check-environment.ps1

Write-Host "============================================" -ForegroundColor Cyan
Write-Host "  Search UGM Mobile - Environment Check" -ForegroundColor Cyan
Write-Host "============================================" -ForegroundColor Cyan
Write-Host ""

Write-Host "[OK] Memeriksa Environment..." -ForegroundColor Yellow
Write-Host ""

# Check Git
Write-Host "Memeriksa Git..." -NoNewline
try {
    $gitVersion = git --version 2>&1
    Write-Host " OK" -ForegroundColor Green
    Write-Host "  Version: $gitVersion" -ForegroundColor Gray
} catch {
    Write-Host " TIDAK DITEMUKAN" -ForegroundColor Red
    Write-Host "  Download: https://git-scm.com/downloads" -ForegroundColor Yellow
}

Write-Host ""

# Check Java
Write-Host "Memeriksa Java..." -NoNewline
try {
    $javaVersionOutput = java -version 2>&1 | Out-String
    Write-Host " OK" -ForegroundColor Green
    Write-Host $javaVersionOutput -ForegroundColor Gray
    
    if ($javaVersionOutput -match "17\." -or $javaVersionOutput -match "1[8-9]\." -or $javaVersionOutput -match "2[0-9]\.") {
        Write-Host "  [OK] Java version 17+ terdeteksi" -ForegroundColor Green
    } else {
        Write-Host "  [PERHATIAN] Perlu upgrade ke JDK 17" -ForegroundColor Yellow
        Write-Host "  Download: https://adoptium.net/" -ForegroundColor Yellow
    }
} catch {
    Write-Host " TIDAK DITEMUKAN" -ForegroundColor Red
    Write-Host "  Download JDK 17: https://adoptium.net/" -ForegroundColor Yellow
}

Write-Host ""

# Check Flutter
Write-Host "Memeriksa Flutter..." -NoNewline
try {
    $flutterVersion = flutter --version 2>&1 | Select-Object -First 1
    Write-Host " OK" -ForegroundColor Green
    Write-Host "  $flutterVersion" -ForegroundColor Gray
    $flutterInstalled = $true
} catch {
    Write-Host " TIDAK DITEMUKAN" -ForegroundColor Red
    Write-Host "  Download: https://docs.flutter.dev/get-started/install/windows" -ForegroundColor Yellow
    $flutterInstalled = $false
}

Write-Host ""

# Check Android SDK
Write-Host "Memeriksa Android SDK..." -NoNewline
$androidSdkPath = $env:ANDROID_HOME
if (-not $androidSdkPath) {
    $androidSdkPath = "$env:LOCALAPPDATA\Android\Sdk"
}

if (Test-Path $androidSdkPath) {
    Write-Host " OK" -ForegroundColor Green
    Write-Host "  Path: $androidSdkPath" -ForegroundColor Gray
} else {
    Write-Host " TIDAK DITEMUKAN" -ForegroundColor Red
    Write-Host "  Install via Android Studio: https://developer.android.com/studio" -ForegroundColor Yellow
}

Write-Host ""
Write-Host "============================================" -ForegroundColor Cyan
Write-Host ""

# Check local.properties
$localPropsPath = "android\local.properties"
Write-Host "Memeriksa konfigurasi lokal..." -NoNewline

if (Test-Path $localPropsPath) {
    Write-Host " OK" -ForegroundColor Green
    Write-Host "  File: $localPropsPath" -ForegroundColor Gray
    
    $content = Get-Content $localPropsPath -Raw
    if ($content -match "/path/to/") {
        Write-Host "  [PERHATIAN] File masih menggunakan placeholder!" -ForegroundColor Yellow
        Write-Host "  Silakan edit file dan sesuaikan path SDK" -ForegroundColor Yellow
    }
} else {
    Write-Host " BELUM ADA" -ForegroundColor Yellow
    if (Test-Path "android\local.properties.example") {
        Write-Host "  Membuat dari template..." -NoNewline
        Copy-Item "android\local.properties.example" $localPropsPath
        Write-Host " OK" -ForegroundColor Green
        Write-Host "  [PERHATIAN] Silakan edit: $localPropsPath" -ForegroundColor Yellow
    }
}

Write-Host ""

# Run flutter doctor if available
if ($flutterInstalled) {
    Write-Host "============================================" -ForegroundColor Cyan
    Write-Host "  Flutter Doctor Output" -ForegroundColor Cyan
    Write-Host "============================================" -ForegroundColor Cyan
    Write-Host ""
    flutter doctor
    Write-Host ""
}

# Summary
Write-Host "============================================" -ForegroundColor Cyan
Write-Host "  Ringkasan" -ForegroundColor Cyan
Write-Host "============================================" -ForegroundColor Cyan
Write-Host ""

Write-Host "Komponen yang HARUS diinstal:" -ForegroundColor Yellow
Write-Host "  1. JDK 17 (https://adoptium.net/)" -ForegroundColor White
Write-Host "  2. Flutter SDK 3.44.8+ (https://docs.flutter.dev/)" -ForegroundColor White
Write-Host "  3. Android Studio (https://developer.android.com/studio)" -ForegroundColor White
Write-Host ""

Write-Host "Setelah semua terinstal:" -ForegroundColor Yellow
Write-Host "  1. Edit: android\local.properties (sesuaikan path SDK)" -ForegroundColor White
Write-Host "  2. flutter doctor --android-licenses" -ForegroundColor White
Write-Host "  3. flutter pub get" -ForegroundColor White
Write-Host "  4. flutter analyze" -ForegroundColor White
Write-Host "  5. flutter test" -ForegroundColor White
Write-Host "  6. Buka emulator atau hubungkan device" -ForegroundColor White
Write-Host "  7. flutter run" -ForegroundColor White
Write-Host ""

Write-Host "Panduan lengkap: SETUP_ENVIRONMENT.md" -ForegroundColor Cyan
Write-Host ""
Write-Host "Script selesai!" -ForegroundColor Green
