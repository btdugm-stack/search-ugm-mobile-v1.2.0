# Search UGM Mobile

Aplikasi Flutter untuk Search UGM — Digital Services Hub. Aplikasi dapat digunakan tanpa login dan menyediakan pencarian terpadu, Jelajahi per kategori, DSH Menjawab Smart, direktori layanan, histori lokal, Tools AI, serta peta fasilitas UGM.

## Versi

- Application version: `1.2.0+3`
- Android application ID: `id.ac.ugm.search`
- Minimum Android: API 24
- Target Android: API 36
- Bahasa antarmuka: Indonesia

## Fitur utama

- Beranda dengan akses cepat yang dapat diperluas dan diringkas.
- Jelajahi berdasarkan kategori yang mengikuti parameter versi web Search UGM.
- Pencarian dengan filter jenis konten, Tri Dharma, dan tahun publikasi.
- DSH Menjawab dengan `smart_mode=1`.
- Peta fasilitas full-screen dengan pencarian, filter, marker, daftar lokasi, drag, double-tap, dan pinch-to-zoom.
- Tools AI UGM.
- Direktori layanan digital.
- Histori pencarian tersimpan lokal tanpa akun pengguna.

## Mulai development

Lihat [Panduan Instalasi dan Development](docs/DEVELOPMENT_INSTALLATION_GUIDE.md).

## Laporan build

Lihat [Laporan Build v1.2.0](docs/BUILD_REPORT_v1.2.0.md).

## Catatan release

Konfigurasi saat ini menggunakan debug signing untuk APK pengujian internal. Sebelum distribusi melalui Play Store, tim UGM wajib menggantinya dengan upload/release keystore resmi dan menyimpan kredensial signing di secret manager atau CI/CD variables.
