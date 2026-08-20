import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:search_ugm_mobile/src/app.dart';
import 'package:search_ugm_mobile/src/api_client.dart';

void main() {
  testWidgets('AI empty state: 4 starter prompts + tombol kirim disabled saat kosong (Sprint 4)', (tester) async {
    await tester.pumpWidget(
      MaterialApp(home: Scaffold(body: AiScreen(api: ApiClient()))),
    );

    // Empty state dengan 4 starter prompts
    expect(find.text('Tanyakan apa saja tentang UGM'), findsOneWidget);
    expect(find.text('Apa tugas mahasiswa KKN?'), findsOneWidget);
    expect(find.text('Bagaimana cara daftar SIMASTER?'), findsOneWidget);
    expect(find.text('Kapan pendaftaran beasiswa dibuka?'), findsOneWidget);
    expect(find.text('Apa saja fasilitas di UGM?'), findsOneWidget);

    // Tombol kirim disabled saat input kosong
    final sendBtn = tester.widget<IconButton>(find.widgetWithIcon(IconButton, Icons.send));
    expect(sendBtn.onPressed, isNull);

    // Mengetik mengaktifkan tombol kirim
    await tester.enterText(find.byType(TextField), 'tes');
    await tester.pump();
    final sendBtn2 = tester.widget<IconButton>(find.widgetWithIcon(IconButton, Icons.send));
    expect(sendBtn2.onPressed, isNotNull);

    expect(tester.takeException(), isNull);
  });

  testWidgets('AI: segmented mode Smart/Search + status composer (Sprint 4)', (tester) async {
    await tester.pumpWidget(
      MaterialApp(home: Scaffold(body: AiScreen(api: ApiClient()))),
    );

    // Segmented control 2 mode + penjelasan
    expect(find.text('Smart'), findsOneWidget);
    expect(find.text('Search'), findsOneWidget);
    expect(find.textContaining('jawaban ringkas berbasis sumber'), findsOneWidget);

    // Toggle ke Search → penjelasan berubah
    await tester.tap(find.text('Search'));
    await tester.pump();
    expect(find.textContaining('daftar hasil pencarian'), findsOneWidget);

    // Kirim query → mode Search memanggil API (di test HTTP ditolak → bubble error)
    await tester.enterText(find.byType(TextField), 'beasiswa');
    await tester.pump();
    await tester.tap(find.widgetWithIcon(IconButton, Icons.send));
    await tester.pump();
    await tester.pump();
    expect(find.textContaining('Maaf, DSH belum dapat menjawab'), findsOneWidget);

    expect(tester.takeException(), isNull);
  });

  test('domainOf mengekstrak domain dari URL (Sprint 4)', () {
    expect(domainOf('https://www.youtube.com/watch?v=x'), 'youtube.com');
    expect(domainOf('https://ugm.ac.id/berita'), 'ugm.ac.id');
    expect(domainOf('https://search.ugm.ac.id/ai/'), 'search.ugm.ac.id');
    expect(domainOf(''), '');
    expect(domainOf('bukan-url'), '');
  });

  testWidgets('Tools AI: label Buka situs UGM pada tiap card (Sprint 4)', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: ToolsAiScreen()));

    // 3 card pertama terlihat; label ada di tiap card
    expect(find.text('Buka situs UGM'), findsNWidgets(3));
    expect(find.text('Tools AI'), findsOneWidget);

    // Scroll ke card terakhir (English with AI) — label juga ada
    await tester.drag(find.byType(ListView), const Offset(0, -400));
    await tester.pump();
    expect(find.text('English with AI'), findsOneWidget);
    expect(find.text('Buka situs UGM'), findsWidgets);

    expect(tester.takeException(), isNull);
  });
}
