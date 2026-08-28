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
    expect(find.text('Daftar Informasi'), findsOneWidget);

    // 'Lihat semua' = tombol di akhir carousel 2 baris (geser horizontal dulu).
    await tester.drag(find.text('Daftar Informasi'), const Offset(-500, 0));
    await tester.pumpAndSettle();
    expect(find.text('Lihat semua'), findsOneWidget);

    // 'Lihat semua' membuka bottom sheet kategori lengkap
    await tester.tap(find.text('Lihat semua'));
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

  test('parseHistItem memisahkan query dan timestamp (Sprint 5.5)', () {
    final ts = DateTime(2026, 8, 20, 9).millisecondsSinceEpoch;
    final (query, time) = parseHistItem('beasiswa\u0002$ts');
    expect(query, 'beasiswa');
    expect(time, DateTime(2026, 8, 20, 9));
    // backward compat: item lama tanpa timestamp
    final (q2, t2) = parseHistItem('KKN');
    expect(q2, 'KKN');
    expect(t2, isNull);
  });

  test('webMercator konsisten dengan world() peta (Sprint 5.5)', () {
    final p = webMercator(-7.7707, 110.3776, 15);
    expect(p.x, greaterThan(0));
    expect(p.y, greaterThan(0));
    // zoom naik → koordinat membesar
    final p2 = webMercator(-7.7707, 110.3776, 16);
    expect(p2.x, closeTo(p.x * 2, 1));
  });

  test('Analytics.fire menerima semua event terdaftar (Sprint 6)', () {
    // 13 event: 12 per planner + load_more
    expect(Analytics.events.length, greaterThanOrEqualTo(12));
    for (final e in Analytics.events) {
      Analytics.fire(e); // tidak melempar assert di debug
    }
    expect(
      () => Analytics.fire('event_tidak_terdaftar'),
      throwsA(isA<AssertionError>()),
    );
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

  test('aiAnswerBlocks memisahkan paragraf dan poin (Fase 6)', () {
    final blocks = aiAnswerBlocks(
      'KKN adalah kegiatan pengabdian masyarakat.\n\n• Persiapan administrasi\n• Koordinasi dengan desa\n\nDaftar ulang dilakukan online.',
    );
    expect(blocks.length, 3);
    expect(blocks[0].heading, isNull);
    expect(blocks[1].heading, 'Poin utama');
    expect(blocks[1].lines.length, 2);
    expect(blocks[2].heading, isNull);
  });

  test('AdaptivePageBackground opacity mapping per state (Fase 1)', () {
    expect(AdaptivePageBackground.opacityFor(PageVisualState.empty), 0.10);
    expect(AdaptivePageBackground.opacityFor(PageVisualState.idle), 0.05);
    expect(AdaptivePageBackground.opacityFor(PageVisualState.loading), 0.04);
    expect(AdaptivePageBackground.opacityFor(PageVisualState.content), 0);
    expect(AdaptivePageBackground.opacityFor(PageVisualState.error), 0);
  });

  testWidgets('Beranda tidak overflow pada text scale 200% (Fase 9)', (tester) async {
    tester.view.physicalSize = const Size(360, 800);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);
    final prevOnError = FlutterError.onError;
    FlutterError.onError = (details) {
      debugPrint('F9 DETAILS:\n${details.toString()}');
      prevOnError?.call(details);
    };
    addTearDown(() => FlutterError.onError = prevOnError);
    await tester.pumpWidget(
      MaterialApp(
        builder: (context, child) =>
            MediaQuery(data: MediaQuery.of(context).copyWith(textScaler: const TextScaler.linear(2.0)), child: child!),
        home: Scaffold(
          body: HomeScreen(
            api: ApiClient(),
            onSearch: (_) {},
            onBrowse: (_) {},
            onAi: (_) {},
            onTools: () {},
            onMap: () {},
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
  });
}
