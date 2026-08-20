import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:search_ugm_mobile/src/app.dart';
import 'package:search_ugm_mobile/src/api_client.dart';
import 'package:search_ugm_mobile/src/models.dart';

/// Scroll Beranda (satu-satunya CustomScrollView di IndexedStack) ke bawah.
Future<void> scrollHome(WidgetTester tester, double dy) async {
  await tester.drag(find.byType(CustomScrollView), Offset(0, dy), warnIfMissed: false);
  await tester.pump();
}

/// Tutup bottom sheet secara deterministik via Navigator.pop.
Future<void> closeSheet(WidgetTester tester) async {
  tester.state<NavigatorState>(find.byType(Navigator)).pop();
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('Beranda: 6 kategori utama, DSH card contoh prompt, Rekomendasi (Sprint 3.1)', (tester) async {
    await tester.pumpWidget(const SearchUgmApp());

    // Hanya 6 kategori utama yang tampil; sisanya lewat bottom sheet
    expect(find.text('Akses Cepat'), findsOneWidget);
    expect(find.text('Lihat semua (13)'), findsOneWidget);
    expect(find.text('Video'), findsNothing); // kategori ke-13 tidak di grid utama
    expect(find.text('Fasilitas Kampus'), findsNothing);

    // Bottom sheet kategori lengkap
    await tester.tap(find.text('Lihat semua (13)'));
    await tester.pumpAndSettle();
    expect(find.text('Semua Kategori'), findsOneWidget);
    expect(find.text('Video'), findsOneWidget);
    expect(find.text('Fasilitas Kampus'), findsOneWidget);

    // Tutup sheet, lalu scroll ke bawah
    await closeSheet(tester);
    await scrollHome(tester, -600);
    await scrollHome(tester, -600);
    await scrollHome(tester, -600);
    expect(find.text('DSH Menjawab — Smart'), findsOneWidget);
    expect(find.text('Apa tugas mahasiswa KKN?'), findsOneWidget);
    expect(find.text('Bagaimana cara daftar SIMASTER?'), findsOneWidget);

    await scrollHome(tester, -600);
    expect(find.text('Rekomendasi untuk Anda'), findsOneWidget);
    expect(find.text('Populer Minggu Ini'), findsNothing);

    expect(tester.takeException(), isNull);
  });

  testWidgets('AiScreen: initialPrompt terisi & auto-kirim (Sprint 3.1)', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: AiScreen(api: ApiClient(), initialPrompt: 'Apa tugas mahasiswa KKN?'),
        ),
      ),
    );
    // post-frame send() → bubble user segera muncul (HTTP ditolak di test = 400)
    await tester.pump();
    await tester.pump();

    expect(find.bySemanticsLabel('Tanya lebih lanjut'), findsOneWidget);
    expect(find.textContaining('Apa tugas mahasiswa KKN'), findsOneWidget);

    expect(tester.takeException(), isNull);
  });

  testWidgets('Cari: empty state menampilkan histori + suggestion (Sprint 3.2)', (tester) async {
    await tester.pumpWidget(const SearchUgmApp());

    expect(find.text('Coba cari', skipOffstage: false), findsOneWidget);
    expect(find.text('Beasiswa', skipOffstage: false), findsOneWidget);
    // SIMASTER ada di suggestion Cari DAN di list Layanan (2 widget)
    expect(find.text('SIMASTER', skipOffstage: false), findsWidgets);
    expect(find.text('Kalender akademik', skipOffstage: false), findsOneWidget);

    expect(tester.takeException(), isNull);
  });

  testWidgets('Cari: autocomplete mulai setelah minimal 2 karakter (Sprint 3.2)', (tester) async {
    await tester.pumpWidget(const SearchUgmApp());

    // Buka tab Cari
    await tester.tap(find.text('Cari'));
    await tester.pumpAndSettle();

    // 1 karakter: tidak memicu pencarian, empty state tetap tampil
    await tester.enterText(find.byType(TextField), 'a');
    await tester.pump(const Duration(milliseconds: 400));
    expect(find.text('Coba cari'), findsOneWidget);

    // 2 karakter: memicu pencarian — empty state digantikan (loading/error/hasil)
    await tester.enterText(find.byType(TextField), 'be');
    await tester.pump(const Duration(milliseconds: 400));
    await tester.pump();
    expect(find.text('Coba cari'), findsNothing);

    expect(tester.takeException(), isNull);
  });

  testWidgets('ResultCard compact + highlight keyword tanpa error (Sprint 3.3)', (tester) async {
    const item = SearchItem(
      id: '1',
      title: 'Pendaftaran Beasiswa S2 Dalam Negeri',
      description: 'Informasi lengkap tentang pendaftaran beasiswa.',
      type: 'news',
      url: 'https://ugm.ac.id',
      source: 'ugm.ac.id',
      dharma: 'Pendidikan',
    );

    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: ResultCard(item: item, query: 'beasiswa'),
        ),
      ),
    );

    expect(find.text('Pendaftaran Beasiswa S2 Dalam Negeri'), findsOneWidget);
    expect(find.text('NEWS'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
