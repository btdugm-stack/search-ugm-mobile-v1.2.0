# Laporan Build Search UGM Mobile v1.2.0

## 1. Ringkasan

| Atribut | Nilai |
|---|---|
| Produk | Search UGM Mobile |
| Versi aplikasi | `1.2.0+3` |
| Package / application ID | `id.ac.ugm.search` |
| Framework | Flutter `3.44.8` |
| Dart | `3.12.2` |
| Android Gradle Plugin | `8.12.0` |
| Gradle Wrapper | `8.13` |
| Kotlin | `2.2.0` |
| Java | JDK `17` |
| Compile SDK | API `36` |
| Target SDK | API `36` |
| Minimum SDK | API `24` / Android 7.0 |
| Mode build | Release optimized |
| Tanggal build | 31 Juli 2026 |

Build ini merupakan kelanjutan versi 1.1.0 dengan perbaikan konteks Jelajahi, animasi akses cepat, serta pengalaman peta fasilitas.

## 2. Ruang lingkup implementasi

### 2.1 Navigasi utama

- Beranda
- Cari
- AI
- Layanan
- Histori

Aplikasi tidak mewajibkan autentikasi. Histori pencarian disimpan lokal pada perangkat melalui native Android method channel.

### 2.2 Jelajahi dan akses cepat

- Layanan
- Berita
- Produk
- Dosen / Staff
- Publikasi
- HKI / Paten
- Tech4disaster
- Produk Hukum
- Pidato & Laporan
- Fasilitas Kampus
- Agenda / Acara

Mode browse menggunakan parameter yang sama dengan implementasi web saat build dilakukan:

```text
action=browse&type=<entity_type>&page=1&limit=30
```

Tech4disaster menggunakan pemetaan khusus:

```text
type=publication&publication_gok=Tech4disaster
```

Mobile client juga memvalidasi `entity_type` pada setiap hasil agar data lintas kategori tidak ikut ditampilkan.

### 2.3 Peta fasilitas

- Sumber data: aksi API `facility_locations`.
- Peta dasar: OpenStreetMap tile service dengan atribusi.
- Pencarian berdasarkan nama fasilitas dan pemilik.
- Filter kategori fasilitas.
- Full-screen map dengan floating search bar dan category chips.
- Draggable location sheet.
- Pemilihan marker dan pemusatan lokasi.
- Drag/pan, tombol zoom, double-tap, dan pinch-to-zoom kontinu.
- Tautan detail dan petunjuk arah eksternal.

## 3. Endpoint runtime

```text
https://search.ugm.ac.id/ai/search%26dsh/api/api.php
```

Operasi yang digunakan antara lain:

- `smart_search`
- `browse`
- `facility_locations`
- `rag_answer` dengan `smart_mode=1`

Tidak ada API key atau password yang ditanamkan pada source code.

## 4. Hasil quality gate

| Pemeriksaan | Hasil |
|---|---|
| `flutter analyze` | Lulus — tidak ada issue |
| Widget test navigasi tanpa Profil | Lulus |
| Unit test parameter Jelajahi | Lulus |
| Widget test expand/collapse | Lulus |
| Widget test pinch-to-zoom | Lulus |
| Smoke test API Berita | Lulus — hanya `news` |
| Smoke test API Tech4disaster | Lulus — 31 publikasi saat pengujian |
| Verifikasi signature APK | Lulus — APK Signature Scheme v2 |

Total automated test pada build ini: **3 test, seluruhnya lulus**.

## 5. Artefak APK

| Atribut | Nilai |
|---|---|
| Nama file | `Search-UGM-Mobile-v1.2.0.apk` |
| Ukuran | `50.496.218 bytes` |
| SHA-256 | `0b7e159b49595ba86acefa634e7a7cdd8570afb7b0874d70a444224120b5fd0e` |
| Version code | `3` |
| Version name | `1.2.0` |

## 6. Struktur source code

```text
lib/
├── main.dart
└── src/
    ├── app.dart           # UI, navigasi, search, AI, layanan, histori, maps
    ├── api_client.dart    # HTTP client dan parameter API
    ├── device_bridge.dart # Method channel URL launcher dan histori lokal
    └── models.dart        # Model hasil pencarian, fasilitas, dan jawaban AI

android/
├── app/
│   ├── build.gradle.kts
│   └── src/main/kotlin/.../MainActivity.kt
├── gradle/wrapper/
└── settings.gradle.kts

test/
└── widget_test.dart
```

## 7. Catatan teknis dan risiko

1. APK pengujian ditandatangani menggunakan debug certificate. APK tersebut tidak boleh langsung dijadikan artefak Play Store.
2. Release signing resmi belum dikonfigurasi karena upload keystore UGM belum diberikan.
3. Ketergantungan aplikasi pada endpoint produksi dan tile OpenStreetMap memerlukan koneksi internet.
4. Riwayat pencarian bersifat lokal dan dapat hilang ketika data aplikasi dihapus.
5. Tools AI tertentu membuka layanan web resmi dan dapat meminta autentikasi sesuai kebijakan masing-masing layanan.
6. Project Android sudah tersedia. Project iOS perlu dibuat dan diuji pada macOS/Xcode sebelum distribusi App Store.
7. Parameter API perlu masuk regression test ketika backend Search UGM diperbarui.

## 8. Rekomendasi tahap berikutnya

- Memecah `app.dart` menjadi feature modules dan menerapkan repository/state-management layer.
- Menambahkan pagination/infinite scrolling pada Jelajahi dan pencarian.
- Menambahkan cache fasilitas dan search result untuk koneksi tidak stabil.
- Menggunakan marker clustering ketika seluruh fasilitas tampil pada zoom rendah.
- Menambahkan observability: crash reporting, performance monitoring, dan privacy-safe analytics.
- Menyiapkan CI/CD Android dan iOS dengan quality gate otomatis.
- Menyiapkan release keystore, Play Console internal testing, privacy policy, dan data safety declaration.
- Menambahkan integration test pada perangkat fisik untuk multi-touch, deep link, dan external URL.
