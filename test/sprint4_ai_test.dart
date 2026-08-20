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
