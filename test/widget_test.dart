import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:search_ugm_mobile/src/app.dart';
import 'package:search_ugm_mobile/src/api_client.dart';
import 'package:search_ugm_mobile/src/models.dart';

void main() {
  testWidgets('app menampilkan navigasi utama tanpa profil', (tester) async {
    await tester.pumpWidget(const SearchUgmApp());

    expect(find.text('SEARCH UGM'), findsOneWidget);
    expect(find.text('Histori'), findsNothing); // tab Histori dihapus (pindah ke Cari, Sprint 5)
    expect(find.text('Profil'), findsNothing);
    expect(find.text('Akses Cepat'), findsOneWidget);
    expect(find.text('Lihat semua (13)'), findsOneWidget);

    // 'Lihat semua' membuka bottom sheet kategori lengkap
    await tester.tap(find.text('Lihat semua (13)'));
    await tester.pumpAndSettle();
    expect(find.text('Semua Kategori'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  test('browse menggunakan parameter kategori yang sama dengan versi web', () {
    final news = buildSearchParameters(query: '', type: 'news');
    expect(news['action'], 'browse');
    expect(news['type'], 'news');
    expect(news.containsKey('entity_type'), isFalse);

    final tech = buildSearchParameters(query: '', type: 'tech4disaster');
    expect(tech['type'], 'publication');
    expect(tech['publication_gok'], 'Tech4disaster');
  });

  test('buildSearchParameters mendukung pagination page (Sprint 3)', () {
    expect(buildSearchParameters(query: 'beasiswa')['page'], '1');
    expect(buildSearchParameters(query: 'beasiswa', page: 2)['page'], '2');
    expect(buildSearchParameters(query: '', type: 'news', page: 3)['page'], '3');
  });

  test('SearchItem.fromJson membaca publish_date_text (Sprint 3)', () {
    final item = SearchItem.fromJson({
      'id': '1',
      'name': 'Judul Berita',
      'publish_date_text': '12 Agustus 2026',
    });
    expect(item.title, 'Judul Berita');
    expect(item.publishDate, '12 Agustus 2026');
  });

  test('facilityCategoryColor konsisten per kategori (Sprint 5)', () {
    final a1 = facilityCategoryColor('Fasilitas Olahraga');
    final a2 = facilityCategoryColor('Fasilitas Olahraga');
    final b = facilityCategoryColor('Kesehatan');
    expect(a1, a2);
    expect(a1 == b, isFalse);
    expect(facilityCategoryColor(''), ugmBlue);
  });

  test('Service.fromJson membaca guide_url & is_external (Sprint 5)', () {
    final s = Service.fromJson({
      'id': '1',
      'name': 'Layanan X',
      'is_external': 0,
      'guide_url': 'https://ugm.ac.id/panduan',
    });
    expect(s.isExternal, isFalse);
    expect(s.guideUrl, 'https://ugm.ac.id/panduan');
  });

  testWidgets('peta menerima gesture pinch-to-zoom tanpa error', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: UgmTileMap(
            facilities: const [],
            selected: null,
            onSelect: (_) {},
          ),
        ),
      ),
    );

    final first = await tester.createGesture(pointer: 1);
    final second = await tester.createGesture(pointer: 2);
    await first.down(const Offset(160, 360));
    await second.down(const Offset(240, 360));
    await first.moveTo(const Offset(110, 360));
    await second.moveTo(const Offset(290, 360));
    await tester.pump();
    await first.up();
    await second.up();
    await tester.pump(const Duration(milliseconds: 100));

    expect(tester.takeException(), isNull);
    expect(find.byType(UgmTileMap), findsOneWidget);
  });
}
