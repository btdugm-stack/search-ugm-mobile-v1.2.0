# Script Setup Environment untuk Search UGM Mobile
# Jalankan dengan: .\setup-environment.ps1

Write-Host "============================================" -ForegroundColor Cyan
Write-Host "  Search UGM Mobile - Environment Setup" -ForegroundColor Cyan
Write-Host "============================================" -ForegroundColor Cyan
Write-Host ""

# Function untuk check command
function Test-CommandExists {
    param($command)
    $null = Get-Command $command -ErrorAction SilentlyContinue
    return $?
}

# Function untuk display status
function Show-Status {
    param(
        [string]$name,
        [bool]$exists,
        [string]$version = ""
    )
    
    if ($exists) {
        Write-Host "  [" -NoNewline
        Write-Host "✓" -ForegroundColor Green -NoNewline
        Write-Host "] $name" -NoNewline
        if ($version) {
            Write-Host " - $version" -ForegroundColor Gray
        } else {
            Write-Host ""
        }
    } else {
        Write-Host "  [" -NoNewline
        Write-Host "✗" -ForegroundColor Red -NoNewline
        Write-Host "] $name - BELUM TERINSTAL" -ForegroundColor Yellow
    }
}

Write-Host "[OK] Memeriksa Environment..." -ForegroundColor Yellow
Write-Host ""

# Check Git
$gitExists = Test-CommandExists "git"
if ($gitExists) {
    $gitVersion = (git --version) -replace "git version ", ""
    Show-Status "Git" $gitExists $gitVersion
} else {
    Show-Status "Git" $gitExists
}

# Check Java
$javaExists = Test-CommandExists "java"
if ($javaExists) {
    $javaVersionRaw = java -version 2>&1 | Select-String "version" | Select-Object -First 1
    $javaVersionStr = $javaVersionRaw.ToString()
    $javaVersionNumber = "Unknown"
    if ($javaVersionStr -match 'version "([^"]+)"') {
        $javaVersionNumber = $matches[1]
    }
    Show-Status "Java" $javaExists $javaVersionNumber
    
    # Check if Java 17+
    if ($javaVersionNumber -like "17.*" -or $javaVersionNumber -like "1[8-9].*" -or $javaVersionNumber -like "2*.*") {
        Write-Host "      [OK] Java version sudah sesuai (17+)" -ForegroundColor Green
    } else {
        Write-Host "      [!] PERLU UPGRADE ke JDK 17!" -ForegroundColor Red
        Write-Host "      Download: https://adoptium.net/" -ForegroundColor Yellow
    }
} else {
    Show-Status "Java" $javaExists
    Write-Host "      Download: https://adoptium.net/" -ForegroundColor Yellow
}

# Check Flutter
$flutterExists = Test-CommandExists "flutter"
if ($flutterExists) {
    $flutterVersion = (flutter --version 2>&1 | Select-String "Flutter" | Select-Object -First 1) -replace "Flutter ", ""
    Show-Status "Flutter" $flutterExists $flutterVersion
} else {
    Show-Status "Flutter" $flutterExists
    Write-Host "      Download: https://docs.flutter.dev/get-started/install/windows" -ForegroundColor Yellow
}

# Check Android SDK
$androidSdkPath = $env:ANDROID_HOME
if (-not $androidSdkPath) {
    $androidSdkPath = "$env:LOCALAPPDATA\Android\Sdk"
}

if (Test-Path $androidSdkPath) {
    Show-Status "Android SDK" $true $androidSdkPath
} else {
    Show-Status "Android SDK" $false
    Write-Host "      Install via Android Studio: https://developer.android.com/studio" -ForegroundColor Yellow
}

Write-Host ""
Write-Host "============================================" -ForegroundColor Cyan
Write-Host ""

# Check local.properties
$localPropsPath = "android\local.properties"
if (Test-Path $localPropsPath) {
    Write-Host "[OK] File local.properties sudah ada" -ForegroundColor Green
    
    # Read and check if paths are set
    $content = Get-Content $localPropsPath -Raw
    if ($content -match "/path/to/") {
        Write-Host "  [!] Path masih menggunakan placeholder!" -ForegroundColor Yellow
        Write-Host "  Edit file: $localPropsPath" -ForegroundColor Yellow
    }
} else {
    if (Test-Path "android\local.properties.example") {
        Write-Host "[!] File local.properties belum ada" -ForegroundColor Yellow
        $create = Read-Host "Buat dari template? (Y/N)"
        if ($create -eq "Y" -or $create -eq "y") {
            Copy-Item "android\local.properties.example" $localPropsPath
            Write-Host "[OK] File local.properties berhasil dibuat" -ForegroundColor Green
            Write-Host "  Edit file dan sesuaikan path: $localPropsPath" -ForegroundColor Yellow
        }
    }
}

Write-Host ""

# Run flutter doctor if Flutter exists
if ($flutterExists) {
    Write-Host "[CHECK] Menjalankan Flutter Doctor..." -ForegroundColor Yellow
    Write-Host ""
    flutter doctor
    Write-Host ""
}

# Summary dan next steps
Write-Host "============================================" -ForegroundColor Cyan
Write-Host "  [SUMMARY] Ringkasan & Langkah Selanjutnya" -ForegroundColor Cyan
Write-Host "============================================" -ForegroundColor Cyan
Write-Host ""

$allReady = $gitExists -and $flutterExists -and $javaExists -and (Test-Path $androidSdkPath)

if ($allReady) {
    Write-Host "[OK] Semua komponen utama sudah terinstal!" -ForegroundColor Green
    Write-Host ""
    Write-Host "Langkah selanjutnya:" -ForegroundColor Yellow
    Write-Host "  1. Pastikan local.properties sudah dikonfigurasi dengan benar" -ForegroundColor White
    Write-Host "  2. Jalankan: flutter pub get" -ForegroundColor White
    Write-Host "  3. Jalankan: flutter analyze" -ForegroundColor White
    Write-Host "  4. Jalankan: flutter test" -ForegroundColor White
    Write-Host "  5. Buka emulator atau hubungkan device" -ForegroundColor White
    Write-Host "  6. Jalankan: flutter run" -ForegroundColor White
} else {
    Write-Host "[!] Beberapa komponen masih perlu diinstal" -ForegroundColor Yellow
    Write-Host ""
    Write-Host "Yang perlu dilakukan:" -ForegroundColor Yellow
    
    if (-not $gitExists) {
        Write-Host "  • Install Git: https://git-scm.com/downloads" -ForegroundColor White
    }
    
    if (-not $javaExists) {
        Write-Host "  • Install JDK 17: https://adoptium.net/" -ForegroundColor White
    } elseif ($javaVersionNumber -notlike "17.*") {
        Write-Host "  • Upgrade ke JDK 17: https://adoptium.net/" -ForegroundColor White
    }
    
    if (-not $flutterExists) {
        Write-Host "  • Install Flutter SDK: https://docs.flutter.dev/get-started/install/windows" -ForegroundColor White
    }
    
    if (-not (Test-Path $androidSdkPath)) {
        Write-Host "  • Install Android Studio: https://developer.android.com/studio" -ForegroundColor White
    }
    
    Write-Host ""
    Write-Host "Lihat panduan lengkap di: SETUP_ENVIRONMENT.md" -ForegroundColor Cyan
}

Write-Host ""
Write-Host "============================================" -ForegroundColor Cyan
Write-Host ""

# Offer to edit local.properties
if (Test-Path $localPropsPath) {
    $edit = Read-Host "Edit local.properties sekarang? (Y/N)"
    if ($edit -eq "Y" -or $edit -eq "y") {
        # Try to open with default text editor
        if (Test-CommandExists "code") {
            code $localPropsPath
        } elseif (Test-CommandExists "notepad++") {
            notepad++ $localPropsPath
        } else {
            notepad $localPropsPath
        }
    }
}

Write-Host ""
Write-Host "Script selesai. Selamat coding!" -ForegroundColor Green
