import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:search_ugm_mobile/src/app.dart';
import 'package:search_ugm_mobile/src/models.dart';

/// Mencari widget Semantics dengan label eksak.
/// bySemanticsLabel tidak konsisten tanpa semantics tree yang aktif
/// (perlu tester.ensureSemantics()); predicate ini memeriksa struktur
/// widget yang sama yang terekspos ke screen reader saat runtime.
/// skipOffstage:false — tab non-aktif di IndexedStack tetap harus
/// memenuhi standar aksesibilitas, jadi ikut diverifikasi.
Finder bySemanticsWidget(String label) => find.byWidgetPredicate(
      (w) => w is Semantics && w.properties.label == label,
      skipOffstage: false,
    );

/// byTooltip dengan skipOffstage:false (tab AI/Layanan offstage di IndexedStack).
Finder byTooltipAll(String tooltip) => find.byTooltip(tooltip, skipOffstage: false);

void main() {
  testWidgets('field dan tombol utama punya label aksesibilitas (Sprint 2)', (tester) async {
    await tester.pumpWidget(const SearchUgmApp());

    // Field pencarian Beranda & Cari sama-sama berlabel 'Cari apa saja di UGM'
    expect(bySemanticsWidget('Cari apa saja di UGM'), findsNWidgets(2));
    expect(bySemanticsWidget('Tanya lebih lanjut'), findsOneWidget);
    expect(bySemanticsWidget('Cari layanan'), findsOneWidget);

    // Tooltip tombol ikon (Bahasa Indonesia) — Tooltip + RawTooltip = 2 node
    expect(byTooltipAll('Cari'), findsWidgets);
    expect(byTooltipAll('Hapus teks'), findsWidgets);
    expect(byTooltipAll('Filter'), findsWidgets);
    expect(byTooltipAll('Kirim'), findsWidgets);

    expect(tester.takeException(), isNull);
  });

  testWidgets('search Layanan melakukan live filter (Sprint 2)', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(home: Scaffold(body: ServicesScreen())),
    );

    expect(find.text('SIMASTER'), findsOneWidget);
    expect(find.text('ULT'), findsOneWidget);

    await tester.enterText(find.byType(TextField), 'sim');
    await tester.pump();
    expect(find.text('SIMASTER'), findsOneWidget);
    expect(find.text('ULT'), findsNothing);

    await tester.enterText(find.byType(TextField), 'zzz');
    await tester.pump();
    expect(find.text('Tidak ada layanan yang cocok dengan pencarian.'), findsOneWidget);
    expect(find.text('SIMASTER'), findsNothing);

    expect(tester.takeException(), isNull);
  });

  testWidgets('peta meng-cluster marker berdekatan, tidak menampilkan pin individu (Sprint 2)', (tester) async {
    final facilities = List.generate(5, (i) => Facility(
          id: 'f$i',
          name: 'Fasilitas $i',
          category: 'Layanan',
          owner: 'UGM',
          description: '',
          latitude: -7.7707 + i * 0.0001,
          longitude: 110.3776 + i * 0.0001,
          webUrl: '',
          routeUrl: '',
        ));

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SizedBox(
            width: 800,
            height: 1200,
            child: UgmTileMap(
              facilities: facilities,
              selected: null,
              onSelect: (_) {},
            ),
          ),
        ),
      ),
    );
    await tester.pump();

    // 5 fasilitas berdekatan -> satu cluster berisi 5, bukan 5 pin bernama
    expect(bySemanticsWidget('5 fasilitas di area ini'), findsOneWidget);
    expect(bySemanticsWidget('Fasilitas 0'), findsNothing);

    expect(tester.takeException(), isNull);
  });

  testWidgets('marker tunggal tetap punya label nama fasilitas (Sprint 2)', (tester) async {
    final facilities = [
      Facility(
        id: 'a',
        name: 'Perpustakaan UGM',
        category: 'Fasilitas',
        owner: 'UGM',
        description: '',
        latitude: -7.7746,
        longitude: 110.3747,
        webUrl: '',
        routeUrl: '',
      ),
    ];

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SizedBox(
            width: 800,
            height: 1200,
            child: UgmTileMap(
              facilities: facilities,
              selected: null,
              onSelect: (_) {},
            ),
          ),
        ),
      ),
    );
    await tester.pump();

    expect(bySemanticsWidget('Perpustakaan UGM'), findsOneWidget);

    expect(tester.takeException(), isNull);
  });
}
