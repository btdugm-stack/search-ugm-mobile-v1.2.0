import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'api_client.dart';
import 'device_bridge.dart';
import 'models.dart';

const ugmBlue = Color(0xFF003F88);
const navy = Color(0xFF071D49);
const surface = Color(0xFFF5F7FB);

// Design token Sprint 2 — teks sekunder aksesibel (WCAG AA 6.19:1 vs putih).
const textSecondary = Color(0xFF616161);
const textTertiary = Color(0xFF554E46);

class SearchUgmApp extends StatelessWidget {
  const SearchUgmApp({super.key});

  @override
  Widget build(BuildContext context) => MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Search UGM',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: ugmBlue, surface: surface),
          scaffoldBackgroundColor: surface,
          useMaterial3: true,
          fontFamily: 'Roboto',
          cardTheme: const CardThemeData(
            elevation: 0,
            margin: EdgeInsets.zero,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(16))),
          ),
          inputDecorationTheme: const InputDecorationTheme(
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(16)), borderSide: BorderSide.none),
          ),
        ),
        home: const MainShell(),
        locale: const Locale('id'),
        supportedLocales: const [Locale('id'), Locale('en')],
        localizationsDelegates: const [
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
      );
}

class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  final ApiClient api = ApiClient();
  int index = 0;
  String initialQuery = '';
  String initialType = 'all';
  String initialAiPrompt = '';

  void openSearch({String query = '', String type = 'all'}) {
    setState(() {
      initialQuery = query;
      initialType = type;
      index = 1;
    });
  }

  void openAi({String prompt = ''}) {
    setState(() {
      initialAiPrompt = prompt;
      index = 2;
    });
  }

  Future<void> push(Widget page) => Navigator.of(context).push(MaterialPageRoute(builder: (_) => page));

  @override
  Widget build(BuildContext context) {
    final pages = <Widget>[
      HomeScreen(
        onSearch: (query) => openSearch(query: query),
        onBrowse: (type) => openSearch(type: type),
        onAi: (prompt) => openAi(prompt: prompt),
        onTools: () => push(const ToolsAiScreen()),
        onMap: () => push(FacilityMapScreen(api: api)),
      ),
      SearchScreen(key: ValueKey('$initialQuery-$initialType'), api: api, initialQuery: initialQuery, initialType: initialType),
      AiScreen(key: ValueKey('ai-$initialAiPrompt'), api: api, initialPrompt: initialAiPrompt),
      const ServicesScreen(),
    ];
    return Scaffold(
      body: SafeArea(child: IndexedStack(index: index, children: pages)),
      bottomNavigationBar: NavigationBar(
        selectedIndex: index,
        onDestinationSelected: (value) => setState(() => index = value),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.home_outlined), selectedIcon: Icon(Icons.home), label: 'Beranda'),
          NavigationDestination(icon: Icon(Icons.search), label: 'Cari'),
          NavigationDestination(icon: Icon(Icons.auto_awesome_outlined), selectedIcon: Icon(Icons.auto_awesome), label: 'AI'),
          NavigationDestination(icon: Icon(Icons.apps_outlined), selectedIcon: Icon(Icons.apps), label: 'Layanan'),
        ],
      ),
    );
  }
}

class SectionTitle extends StatelessWidget {
  const SectionTitle(this.title, {super.key, this.trailing});
  final String title;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) => Row(
        children: [
          Expanded(child: Text(title, style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w800, color: navy))),
          ?trailing,
        ],
      );
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({
    super.key,
    required this.onSearch,
    required this.onBrowse,
    required this.onAi,
    required this.onTools,
    required this.onMap,
  });
  final ValueChanged<String> onSearch;
  final ValueChanged<String> onBrowse;
  final ValueChanged<String> onAi;
  final VoidCallback onTools;
  final VoidCallback onMap;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final controller = TextEditingController();

  static const explore = <({String label, String type, IconData icon})>[
    (label: 'Layanan', type: 'service', icon: Icons.apps),
    (label: 'Berita', type: 'news', icon: Icons.newspaper_outlined),
    (label: 'Produk', type: 'product', icon: Icons.shopping_bag_outlined),
    (label: 'Dosen / Staff', type: 'people', icon: Icons.people_outline),
    (label: 'Publikasi', type: 'publication', icon: Icons.article_outlined),
    (label: 'HKI / Paten', type: 'patent', icon: Icons.workspace_premium_outlined),
    (label: 'Tech4disaster', type: 'tech4disaster', icon: Icons.emergency_outlined),
    (label: 'Produk Hukum', type: 'legal', icon: Icons.gavel_outlined),
    (label: 'Pidato & Laporan', type: 'pidato', icon: Icons.record_voice_over_outlined),
    (label: 'Fasilitas Kampus', type: 'facility', icon: Icons.apartment_outlined),
    (label: 'Agenda / Acara', type: 'event', icon: Icons.event_outlined),
    (label: 'Karir', type: 'karir', icon: Icons.work_outline),
    (label: 'Video', type: 'video', icon: Icons.play_circle_outline),
  ];

  // Contoh pertanyaan untuk card DSH Menjawab (Sprint 3.1).
  static const aiStarterPrompts = [
    'Apa tugas mahasiswa KKN?',
    'Bagaimana cara daftar SIMASTER?',
    'Kapan pendaftaran beasiswa dibuka?',
  ];

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  void showAllCategories() {
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      isScrollControlled: true,
      builder: (context) => SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 4, 20, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Semua Kategori', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900)),
              const SizedBox(height: 16),
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: explore.length,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  crossAxisSpacing: 8,
                  mainAxisSpacing: 8,
                  childAspectRatio: 1.15,
                ),
                itemBuilder: (_, i) => _categoryTile(explore[i]),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _categoryTile(({String label, String type, IconData icon}) item) {
    return InkWell(
      borderRadius: BorderRadius.circular(14),
      onTap: item.type == 'facility'
          ? widget.onMap
          : () => widget.onBrowse(item.type),
      child: Ink(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: const Color(0xFFE6EAF1)),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 9),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(item.icon, color: ugmBlue, size: 25),
              const SizedBox(height: 7),
              Text(
                item.label,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    Widget quickAccessGrid(List<({String label, String type, IconData icon})> items) {
      return GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: items.length,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          crossAxisSpacing: 8,
          mainAxisSpacing: 8,
          childAspectRatio: .95,
        ),
        itemBuilder: (_, i) => _categoryTile(items[i]),
      );
    }

    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(
          child: Container(
            padding: const EdgeInsets.fromLTRB(20, 22, 20, 28),
            decoration: const BoxDecoration(
              gradient: LinearGradient(colors: [navy, ugmBlue], begin: Alignment.topLeft, end: Alignment.bottomRight),
              borderRadius: BorderRadius.vertical(bottom: Radius.circular(28)),
            ),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const Row(children: [
                CircleAvatar(backgroundColor: Colors.white, child: Icon(Icons.school, color: ugmBlue)),
                SizedBox(width: 12),
                Expanded(child: Text('SEARCH UGM', style: TextStyle(color: Colors.white, fontSize: 21, fontWeight: FontWeight.w900))),
                Chip(label: Text('DSH'), side: BorderSide.none),
              ]),
              const SizedBox(height: 25),
              const Text('Ada yang bisa kami bantu hari ini?', style: TextStyle(color: Colors.white, fontSize: 19, fontWeight: FontWeight.w700)),
              const SizedBox(height: 12),
              Semantics(
                textField: true,
                label: 'Cari apa saja di UGM',
                child: TextField(
                  controller: controller,
                  textInputAction: TextInputAction.search,
                  onSubmitted: (value) {
                    FocusManager.instance.primaryFocus?.unfocus();
                    widget.onSearch(value);
                  },
                  decoration: InputDecoration(
                    hintText: 'Cari apa saja di UGM…',
                    prefixIcon: const Icon(Icons.search),
                    suffixIcon: IconButton(
                      tooltip: 'Cari',
                      icon: const Icon(Icons.arrow_forward),
                      onPressed: () {
                        FocusManager.instance.primaryFocus?.unfocus();
                        widget.onSearch(controller.text);
                      },
                    ),
                  ),
                ),
              ),
            ]),
          ),
        ),
        SliverPadding(
          padding: const EdgeInsets.all(18),
          sliver: SliverList.list(children: [
            SectionTitle('Akses Cepat', trailing: TextButton(
              onPressed: showAllCategories,
              child: Text('Lihat semua (${explore.length})'),
            )),
            const SizedBox(height: 10),
            quickAccessGrid(explore.take(6).toList()),
            const SizedBox(height: 22),
            const SectionTitle('Fitur Khusus'),
            const SizedBox(height: 10),
            Row(children: [
              Expanded(child: _FeatureCard(icon: Icons.auto_fix_high, title: 'Tools AI', subtitle: 'Empat alat AI UGM', onTap: widget.onTools)),
              const SizedBox(width: 10),
              Expanded(child: _FeatureCard(icon: Icons.map_outlined, title: 'Peta Fasilitas', subtitle: 'Jelajahi lokasi kampus', onTap: widget.onMap)),
            ]),
            const SizedBox(height: 14),
            Card(
              color: const Color(0xFFEAF1FF),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 14, 16, 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(children: [
                      CircleAvatar(backgroundColor: ugmBlue, child: Icon(Icons.auto_awesome, color: Colors.white)),
                      SizedBox(width: 10),
                      Expanded(child: Text('DSH Menjawab — Smart', style: TextStyle(fontWeight: FontWeight.w800))),
                    ]),
                    const SizedBox(height: 4),
                    const Text('Jawaban ringkas dari sumber UGM terpercaya.', style: TextStyle(fontSize: 13, color: textSecondary)),
                    const SizedBox(height: 10),
                    Wrap(spacing: 8, runSpacing: 8, children: [
                      for (final prompt in aiStarterPrompts)
                        ActionChip(
                          label: Text(prompt, style: const TextStyle(fontSize: 12)),
                          onPressed: () => widget.onAi(prompt),
                        ),
                    ]),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            const SectionTitle('Rekomendasi untuk Anda'),
            const SizedBox(height: 10),
            Card(child: ListTile(onTap: () => widget.onSearch('beasiswa S2'), leading: const Icon(Icons.school_outlined, color: ugmBlue), title: const Text('Beasiswa S2 Dalam Negeri'), subtitle: const Text('Temukan informasi dan tenggat terbaru'), trailing: const Icon(Icons.arrow_forward_ios, size: 16))),
            Card(child: ListTile(onTap: () => widget.onSearch('KKN'), leading: const Icon(Icons.groups_outlined, color: ugmBlue), title: const Text('Program KKN UGM'), subtitle: const Text('Informasi pendaftaran dan laporan KKN'), trailing: const Icon(Icons.arrow_forward_ios, size: 16))),
            Card(child: ListTile(onTap: () => widget.onSearch('e-learning'), leading: const Icon(Icons.school_outlined, color: ugmBlue), title: const Text('E-Learning UGM'), subtitle: const Text('Akses pembelajaran daring UGM'), trailing: const Icon(Icons.arrow_forward_ios, size: 16))),
            const SizedBox(height: 30),
          ]),
        ),
      ],
    );
  }
}

class _FeatureCard extends StatelessWidget {
  const _FeatureCard({required this.icon, required this.title, required this.subtitle, required this.onTap});
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => Card(
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Icon(icon, color: ugmBlue, size: 30),
              const SizedBox(height: 10),
              Text(title, style: const TextStyle(fontWeight: FontWeight.w800)),
              const SizedBox(height: 3),
              Text(subtitle, style: const TextStyle(color: textSecondary, fontSize: 12)),
            ]),
          ),
        ),
      );
}

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key, required this.api, this.initialQuery = '', this.initialType = 'all'});
  final ApiClient api;
  final String initialQuery;
  final String initialType;

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  late final TextEditingController controller;
  late String type;
  String dharma = '';
  String year = '';
  SearchResponse? response;
  String? error;
  bool loading = false;
  Timer? _debounce;
  int _requestSeq = 0;
  List<String> history = const [];

  static const types = <String, String>{
    'all': 'Semua', 'service': 'Layanan', 'news': 'Berita', 'product': 'Produk', 'people': 'Dosen',
    'publication': 'Publikasi', 'patent': 'HKI', 'tech4disaster': 'Tech4disaster', 'legal': 'Hukum',
    'pidato': 'Pidato', 'facility': 'Fasilitas', 'event': 'Agenda', 'karir': 'Karir', 'video': 'Video',
  };

  static const suggestions = ['Beasiswa', 'SIMASTER', 'Kalender akademik', 'Perpustakaan', 'Kartu mahasiswa'];

  int get activeFilters => (dharma.isNotEmpty ? 1 : 0) + (year.isNotEmpty ? 1 : 0);

  @override
  void initState() {
    super.initState();
    controller = TextEditingController(text: widget.initialQuery);
    type = widget.initialType;
    _loadHistory();
    if (controller.text.isNotEmpty || type != 'all') search();
  }

  @override
  void dispose() {
    _debounce?.cancel();
    controller.dispose();
    super.dispose();
  }

  Future<void> _loadHistory() async {
    final result = await DeviceBridge.getHistory();
    if (mounted) setState(() => history = result);
  }

  void _onQueryChanged(String value) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 300), () {
      if (mounted) search();
    });
  }

  Future<void> search() async {
    if (controller.text.trim().isEmpty && type == 'all') {
      if (mounted) setState(() { response = null; error = null; loading = false; });
      return;
    }
    final seq = ++_requestSeq;
    setState(() { loading = true; error = null; });
    try {
      if (controller.text.trim().isNotEmpty) {
        final old = await DeviceBridge.getHistory();
        await DeviceBridge.saveHistory([controller.text.trim(), ...old.where((item) => item != controller.text.trim())]);
        await _loadHistory();
      }
      final result = await widget.api.search(query: controller.text, type: type, dharma: dharma, year: year);
      if (!mounted || seq != _requestSeq) return;
      setState(() => response = result);
    } catch (e) {
      if (!mounted || seq != _requestSeq) return;
      setState(() => error = '$e');
    } finally {
      if (mounted && seq == _requestSeq) setState(() => loading = false);
    }
  }

  Future<void> showFilters() async {
    var draftDharma = dharma;
    var draftYear = year;
    final applied = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      builder: (context) => StatefulBuilder(builder: (context, setModal) => Padding(
        padding: EdgeInsets.fromLTRB(20, 18, 20, MediaQuery.viewInsetsOf(context).bottom + 24),
        child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text('Filter Pencarian', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900)),
          const SizedBox(height: 18),
          const Text('Tri Dharma', style: TextStyle(fontWeight: FontWeight.w700)),
          const SizedBox(height: 8),
          Wrap(spacing: 8, children: ['', 'Pendidikan', 'Penelitian', 'Pengabdian'].map((value) => ChoiceChip(label: Text(value.isEmpty ? 'Semua' : value), selected: draftDharma == value, onSelected: (_) => setModal(() => draftDharma = value))).toList()),
          const SizedBox(height: 18),
          DropdownButtonFormField<String>(
            initialValue: draftYear,
            decoration: const InputDecoration(labelText: 'Tahun publikasi'),
            items: ['', ...List.generate(12, (i) => '${DateTime.now().year - i}')].map((value) => DropdownMenuItem(value: value, child: Text(value.isEmpty ? 'Semua tahun' : value))).toList(),
            onChanged: (value) => setModal(() => draftYear = value ?? ''),
          ),
          const SizedBox(height: 18),
          Row(children: [
            Expanded(child: OutlinedButton(onPressed: () => setModal(() { draftDharma = ''; draftYear = ''; }), child: const Text('Reset'))),
            const SizedBox(width: 10),
            Expanded(child: FilledButton(onPressed: () => Navigator.pop(context, true), child: const Text('Terapkan'))),
          ]),
        ]),
      )),
    );
    if (applied == true) {
      setState(() { dharma = draftDharma; year = draftYear; });
      search();
    }
  }

  @override
  Widget build(BuildContext context) => Column(children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 14, 16, 8),
          child: Row(children: [
            Expanded(
              child: Semantics(
                textField: true,
                label: 'Cari apa saja di UGM',
                child: TextField(
                  controller: controller,
                  textInputAction: TextInputAction.search,
                  onChanged: _onQueryChanged,
                  onSubmitted: (_) {
                    FocusManager.instance.primaryFocus?.unfocus();
                    search();
                  },
                  decoration: InputDecoration(
                    hintText: 'Cari apa saja di UGM…',
                    prefixIcon: const Icon(Icons.search),
                    suffixIcon: IconButton(
                      tooltip: 'Hapus teks',
                      icon: const Icon(Icons.close),
                      onPressed: () {
                        controller.clear();
                        _onQueryChanged('');
                      },
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),
            Badge(
              isLabelVisible: activeFilters > 0,
              label: Text('$activeFilters'),
              child: IconButton.filledTonal(
                tooltip: 'Filter',
                onPressed: showFilters,
                icon: const Icon(Icons.tune),
              ),
            ),
          ]),
        ),
        SizedBox(
          height: 42,
          child: Stack(children: [
            Positioned.fill(
              child: ListView.separated(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                scrollDirection: Axis.horizontal,
                itemCount: types.length,
                separatorBuilder: (_, _) => const SizedBox(width: 7),
                itemBuilder: (_, i) {
                  final entry = types.entries.elementAt(i);
                  return ChoiceChip(
                    label: Text(entry.value),
                    selected: type == entry.key,
                    onSelected: (_) {
                      setState(() => type = entry.key);
                      if (controller.text.isNotEmpty || type != 'all') search();
                    },
                  );
                },
              ),
            ),
            // Edge fade kanan — indikasi chip masih bisa digeser (Sprint 3.2).
            Positioned(
              right: 0,
              top: 0,
              bottom: 0,
              width: 36,
              child: IgnorePointer(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [surface.withValues(alpha: 0), surface],
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                    ),
                  ),
                ),
              ),
            ),
          ]),
        ),
        if (dharma.isNotEmpty || year.isNotEmpty) Padding(padding: const EdgeInsets.fromLTRB(16, 8, 16, 0), child: Align(alignment: Alignment.centerLeft, child: Text('Filter aktif: ${[if (dharma.isNotEmpty) dharma, if (year.isNotEmpty) year].join(' • ')}', style: const TextStyle(color: ugmBlue, fontWeight: FontWeight.w600)))),
        const SizedBox(height: 8),
        Expanded(child: _searchBody()),
      ]);

  Widget _searchBody() {
    if (loading) return const Center(child: CircularProgressIndicator());
    if (error != null) return _ErrorView(message: error!, retry: search);
    if (response == null) {
      // Empty state dengan tindakan lanjutan: histori + suggestion (Sprint 3.2).
      return ListView(
        padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
        children: [
          if (history.isNotEmpty) ...[
            const Text('Pencarian Terakhir', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: navy)),
            const SizedBox(height: 4),
            ...history.take(8).map((h) => ListTile(
                  dense: true,
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(Icons.history, size: 19, color: textSecondary),
                  title: Text(h, maxLines: 1, overflow: TextOverflow.ellipsis),
                  onTap: () {
                    controller.text = h;
                    search();
                  },
                )),
            const SizedBox(height: 14),
          ],
          const Text('Coba cari', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: navy)),
          const SizedBox(height: 8),
          Wrap(spacing: 8, runSpacing: 8, children: [
            for (final s in suggestions)
              ActionChip(
                label: Text(s),
                onPressed: () {
                  controller.text = s;
                  search();
                },
              ),
          ]),
        ],
      );
    }
    if (response!.items.isEmpty) return const _EmptyState(icon: Icons.search_off, title: 'Tidak ada hasil', subtitle: 'Coba kata kunci atau filter yang berbeda.');
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
      itemCount: response!.items.length + 1,
      itemBuilder: (_, i) {
        if (i == 0) {
          final browseLabel = types[type] ?? 'Konten';
          return Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: Row(
              children: [
                if (controller.text.trim().isEmpty) ...[
                  const Icon(Icons.explore_outlined, size: 19, color: ugmBlue),
                  const SizedBox(width: 7),
                  Text(
                    'Jelajahi $browseLabel',
                    style: const TextStyle(fontWeight: FontWeight.w900),
                  ),
                  const Spacer(),
                ],
                Text(
                  '${response!.total} hasil',
                  style: const TextStyle(
                    color: textSecondary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          );
        }
        return ResultCard(item: response!.items[i - 1], query: controller.text);
      },
    );
  }
}

class ResultCard extends StatelessWidget {
  const ResultCard({super.key, required this.item, this.query = ''});
  final SearchItem item;
  final String query;

  /// Menyorot kata kunci yang cocok dengan query (case-insensitive).
  TextSpan _highlight(String text, TextStyle style) {
    final q = query.trim().toLowerCase();
    if (q.isEmpty) return TextSpan(text: text, style: style);
    final lower = text.toLowerCase();
    final spans = <TextSpan>[];
    var start = 0;
    while (true) {
      final idx = lower.indexOf(q, start);
      if (idx < 0) {
        spans.add(TextSpan(text: text.substring(start), style: style));
        break;
      }
      if (idx > start) spans.add(TextSpan(text: text.substring(start, idx), style: style));
      spans.add(TextSpan(
        text: text.substring(idx, idx + q.length),
        style: style.copyWith(color: ugmBlue, fontWeight: FontWeight.w800),
      ));
      start = idx + q.length;
    }
    return TextSpan(children: spans);
  }

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: Card(child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () => DeviceBridge.openUrl(item.url),
          child: Padding(padding: const EdgeInsets.all(12), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [
              Chip(label: Text(item.type.toUpperCase(), style: const TextStyle(fontSize: 10)), visualDensity: VisualDensity.compact, side: BorderSide.none, backgroundColor: const Color(0xFFEAF1FF)),
              if (item.dharma.isNotEmpty) ...[const SizedBox(width: 7), Expanded(child: Text(item.dharma, style: const TextStyle(fontSize: 11, color: ugmBlue)))],
            ]),
            const SizedBox(height: 5),
            Text.rich(
              _highlight(item.title, const TextStyle(fontWeight: FontWeight.w800, fontSize: 15, height: 1.3)),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            if (item.description.isNotEmpty) ...[const SizedBox(height: 5), Text(item.description, maxLines: 2, overflow: TextOverflow.ellipsis, style: const TextStyle(color: textSecondary, height: 1.35, fontSize: 13))],
            const SizedBox(height: 8),
            Row(children: [const Icon(Icons.verified_outlined, size: 15, color: ugmBlue), const SizedBox(width: 5), Expanded(child: Text(item.source, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 12, color: ugmBlue))), const Icon(Icons.open_in_new, size: 16)]),
          ])),
        )),
      );
}

class AiScreen extends StatefulWidget {
  const AiScreen({super.key, required this.api, this.initialPrompt = ''});
  final ApiClient api;
  final String initialPrompt;

  @override
  State<AiScreen> createState() => _AiScreenState();
}

class _AiScreenState extends State<AiScreen> {
  late final TextEditingController controller;
  final sessionId = 'mobile-${DateTime.now().millisecondsSinceEpoch}';
  final messages = <({bool user, String text, List<SearchItem> sources})>[];
  bool loading = false;
  bool _canSend = false;

  static const starterPrompts = [
    'Apa tugas mahasiswa KKN?',
    'Bagaimana cara daftar SIMASTER?',
    'Kapan pendaftaran beasiswa dibuka?',
    'Apa saja fasilitas di UGM?',
  ];

  @override
  void initState() {
    super.initState();
    controller = TextEditingController(text: widget.initialPrompt);
    _canSend = widget.initialPrompt.trim().isNotEmpty;
    if (widget.initialPrompt.isNotEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) send();
      });
    }
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  Future<void> send() async {
    final question = controller.text.trim();
    if (question.isEmpty || loading) return;
    controller.clear();
    setState(() => _canSend = false);
    FocusManager.instance.primaryFocus?.unfocus();
    setState(() { messages.add((user: true, text: question, sources: const [])); loading = true; });
    try {
      final answer = await widget.api.askSmart(question, sessionId);
      if (mounted) setState(() => messages.add((user: false, text: answer.answer, sources: answer.sources)));
    } catch (e) {
      if (mounted) setState(() => messages.add((user: false, text: 'Maaf, DSH belum dapat menjawab. $e', sources: const [])));
    } finally {
      if (mounted) setState(() => loading = false);
    }
  }

  void _submitPrompt(String prompt) {
    controller.text = prompt;
    send();
  }

  Future<void> _copyAnswer(String text) async {
    await Clipboard.setData(ClipboardData(text: text));
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Jawaban disalin ke papan klip')));
    }
  }

  void _feedback() {
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Terima kasih atas masukannya.')));
  }

  @override
  Widget build(BuildContext context) => Column(children: [
        Container(
          padding: const EdgeInsets.all(16),
          color: Colors.white,
          child: const Row(children: [Icon(Icons.auto_awesome, color: ugmBlue), SizedBox(width: 10), Expanded(child: Text('DSH Menjawab', style: TextStyle(fontSize: 19, fontWeight: FontWeight.w900))), Chip(label: Text('SMART'), side: BorderSide.none, backgroundColor: Color(0xFFEAF1FF))]),
        ),
        Expanded(child: messages.isEmpty
            ? ListView(
                padding: const EdgeInsets.all(20),
                children: [
                  const SizedBox(height: 20),
                  const Icon(Icons.auto_awesome, size: 54, color: ugmBlue),
                  const SizedBox(height: 14),
                  const Text('Tanyakan apa saja tentang UGM', textAlign: TextAlign.center, style: TextStyle(fontSize: 19, fontWeight: FontWeight.w900)),
                  const SizedBox(height: 7),
                  const Text('Mode Smart menggabungkan penelusuran semantik dan sumber UGM terpercaya.', textAlign: TextAlign.center, style: TextStyle(color: textSecondary, height: 1.4)),
                  const SizedBox(height: 24),
                  Wrap(
                    alignment: WrapAlignment.center,
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      for (final prompt in starterPrompts)
                        ActionChip(
                          label: Text(prompt, style: const TextStyle(fontSize: 12)),
                          onPressed: () => _submitPrompt(prompt),
                        ),
                    ],
                  ),
                ],
              )
            : ListView.builder(padding: const EdgeInsets.all(16), itemCount: messages.length, itemBuilder: (_, i) {
                final message = messages[i];
                return Align(
                  alignment: message.user ? Alignment.centerRight : Alignment.centerLeft,
                  child: Container(
                    constraints: const BoxConstraints(maxWidth: 600),
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(color: message.user ? const Color(0xFFDCE8FF) : Colors.white, borderRadius: BorderRadius.circular(16)),
                    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Text(message.text, style: const TextStyle(height: 1.45)),
                      if (message.sources.isNotEmpty) ...[
                        const Divider(height: 24),
                        const Text('Sumber', style: TextStyle(fontWeight: FontWeight.w800)),
                        const SizedBox(height: 4),
                        ...message.sources.take(4).map((source) => Padding(
                          padding: const EdgeInsets.only(bottom: 6),
                          child: Material(
                            color: const Color(0xFFEDF2F8),
                            borderRadius: BorderRadius.circular(12),
                            child: InkWell(
                              borderRadius: BorderRadius.circular(12),
                              onTap: () => DeviceBridge.openUrl(source.url),
                              child: Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                                child: Row(children: [
                                  const Icon(Icons.link, size: 16, color: ugmBlue),
                                  const SizedBox(width: 8),
                                  Expanded(child: Text(source.title, maxLines: 2, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600))),
                                  const SizedBox(width: 6),
                                  const Icon(Icons.open_in_new, size: 15, color: ugmBlue),
                                ]),
                              ),
                            ),
                          ),
                        )),
                      ],
                      if (!message.user) ...[
                        const SizedBox(height: 6),
                        Wrap(spacing: 2, children: [
                          TextButton.icon(
                            style: TextButton.styleFrom(visualDensity: VisualDensity.compact, padding: const EdgeInsets.symmetric(horizontal: 8)),
                            onPressed: () => _copyAnswer(message.text),
                            icon: const Icon(Icons.copy, size: 15),
                            label: const Text('Salin', style: TextStyle(fontSize: 12)),
                          ),
                          TextButton.icon(
                            style: TextButton.styleFrom(visualDensity: VisualDensity.compact, padding: const EdgeInsets.symmetric(horizontal: 8)),
                            onPressed: _feedback,
                            icon: const Icon(Icons.thumb_up_outlined, size: 15),
                            label: const Text('Membantu', style: TextStyle(fontSize: 12)),
                          ),
                        ]),
                      ],
                    ]),
                  ),
                );
              })),
        if (loading) const LinearProgressIndicator(),
        Padding(
          padding: const EdgeInsets.all(12),
          child: Row(children: [
            Expanded(
              child: Semantics(
                textField: true,
                label: 'Tanya lebih lanjut',
                child: TextField(
                  controller: controller,
                  maxLines: 4,
                  minLines: 1,
                  onChanged: (value) => setState(() => _canSend = value.trim().isNotEmpty),
                  onSubmitted: (_) => send(),
                  decoration: const InputDecoration(hintText: 'Tanya lebih lanjut…', prefixIcon: Icon(Icons.mic_none)),
                ),
              ),
            ),
            const SizedBox(width: 8),
            IconButton.filled(
              tooltip: 'Kirim',
              onPressed: _canSend ? send : null,
              icon: const Icon(Icons.send),
            ),
          ]),
        ),
        const Padding(padding: EdgeInsets.only(bottom: 7), child: Text('Jawaban AI dapat tidak 100% akurat.', style: TextStyle(fontSize: 12, color: textSecondary))),
      ]);
}

class ServicesScreen extends StatefulWidget {
  const ServicesScreen({super.key});

  @override
  State<ServicesScreen> createState() => _ServicesScreenState();
}

class _ServicesScreenState extends State<ServicesScreen> {
  final controller = TextEditingController();

  static const services = [
    ('SIMASTER', 'Sistem informasi akademik UGM', 'https://simaster.ugm.ac.id'),
    ('ULT', 'Unit Layanan Terpadu', 'https://ult.ugm.ac.id/eservices/portal/'),
    ('Dashboard UGM', 'UGM Dalam Angka', 'https://dashboard.ugm.ac.id/public/ugm_dalam_angka/view'),
    ('E-Learning UGM', 'Pembelajaran daring UGM', 'https://elok.ugm.ac.id'),
    ('PIONIR', 'PIONIR Gadjah Mada 2026', 'https://pionir.ugm.ac.id/'),
  ];

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final query = controller.text.trim().toLowerCase();
    final filtered = query.isEmpty
        ? services
        : services
              .where((item) =>
                  item.$1.toLowerCase().contains(query) ||
                  item.$2.toLowerCase().contains(query))
              .toList();
    return ListView(padding: const EdgeInsets.all(16), children: [
      const Text('Layanan', style: TextStyle(fontSize: 24, fontWeight: FontWeight.w900, color: navy)),
      const SizedBox(height: 6),
      const Text('Direktori layanan digital UGM', style: TextStyle(color: textSecondary)),
      const SizedBox(height: 18),
      Semantics(
        textField: true,
        label: 'Cari layanan',
        child: TextField(
          controller: controller,
          onChanged: (_) => setState(() {}),
          decoration: const InputDecoration(prefixIcon: Icon(Icons.search), hintText: 'Cari layanan…'),
        ),
      ),
      const SizedBox(height: 18),
      const SectionTitle('Layanan Populer'),
      const SizedBox(height: 10),
      if (filtered.isEmpty)
        const Padding(
          padding: EdgeInsets.symmetric(vertical: 24),
          child: Center(child: Text('Tidak ada layanan yang cocok dengan pencarian.')),
        )
      else
        ...filtered.map((item) => Padding(padding: const EdgeInsets.only(bottom: 9), child: Card(child: ListTile(onTap: () => DeviceBridge.openUrl(item.$3), leading: CircleAvatar(backgroundColor: const Color(0xFFEAF1FF), child: Text(item.$1.characters.first, style: const TextStyle(color: ugmBlue, fontWeight: FontWeight.w900))), title: Text(item.$1, style: const TextStyle(fontWeight: FontWeight.w800)), subtitle: Text(item.$2), trailing: const Icon(Icons.open_in_new, size: 18))))),
    ]);
  }
}

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  List<String> items = const [];

  @override
  void initState() { super.initState(); load(); }
  Future<void> load() async { final result = await DeviceBridge.getHistory(); if (mounted) setState(() => items = result); }
  Future<void> clear() async { await DeviceBridge.saveHistory(const []); await load(); }

  @override
  Widget build(BuildContext context) => Column(children: [
        Padding(padding: const EdgeInsets.fromLTRB(16, 16, 8, 10), child: Row(children: [const Expanded(child: Text('Histori Pencarian', style: TextStyle(fontSize: 23, fontWeight: FontWeight.w900, color: navy))), TextButton(onPressed: items.isEmpty ? null : clear, child: const Text('Hapus semua'))])),
        Expanded(child: items.isEmpty
            ? const _EmptyState(icon: Icons.history, title: 'Belum ada histori', subtitle: 'Pencarian terbaru Anda akan tersimpan lokal di perangkat.')
            : ListView.separated(padding: const EdgeInsets.all(16), itemCount: items.length, separatorBuilder: (_, _) => const Divider(), itemBuilder: (_, i) => ListTile(leading: const Icon(Icons.history), title: Text(items[i]), trailing: const Icon(Icons.north_west, size: 17)))),
      ]);
}

class ToolsAiScreen extends StatelessWidget {
  const ToolsAiScreen({super.key});
  static const tools = [
    ('Berita SDGs', 'Temukan dan kelola berita terkait Sustainable Development Goals.', Icons.public, 'https://transformasidigital.ugm.ac.id/sdgs-2/'),
    ('Progres Report KKN', 'Bantu menyusun dan memantau laporan kemajuan kegiatan KKN.', Icons.groups_outlined, 'https://search.ugm.ac.id/ai/index-ai.php'),
    ('Grammar Correction', 'Periksa tata bahasa dan perbaiki penulisan dengan bantuan AI.', Icons.spellcheck, 'https://search.ugm.ac.id/ai/index-ai.php'),
    ('English with AI', 'Latihan bahasa Inggris melalui fitur AI UGM.', Icons.translate, 'https://search.ugm.ac.id/ai/language/'),
  ];

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(title: const Text('Tools AI'), backgroundColor: Colors.white),
        body: ListView(padding: const EdgeInsets.all(16), children: [
          Container(padding: const EdgeInsets.all(18), decoration: BoxDecoration(gradient: const LinearGradient(colors: [navy, ugmBlue]), borderRadius: BorderRadius.circular(20)), child: const Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Icon(Icons.auto_fix_high, color: Colors.white, size: 34), SizedBox(height: 12), Text('AI Tools UGM', style: TextStyle(color: Colors.white, fontSize: 23, fontWeight: FontWeight.w900)), SizedBox(height: 5), Text('Akses kumpulan alat AI pada versi web Search UGM.', style: TextStyle(color: Colors.white70))])),
          const SizedBox(height: 16),
          ...tools.map((tool) => Padding(padding: const EdgeInsets.only(bottom: 10), child: Card(child: ListTile(contentPadding: const EdgeInsets.all(12), leading: CircleAvatar(backgroundColor: const Color(0xFFEAF1FF), child: Icon(tool.$3, color: ugmBlue)), title: Text(tool.$1, style: const TextStyle(fontWeight: FontWeight.w800)), subtitle: Padding(padding: const EdgeInsets.only(top: 5), child: Text(tool.$2)), trailing: Column(mainAxisAlignment: MainAxisAlignment.center, mainAxisSize: MainAxisSize.min, children: [const Icon(Icons.open_in_new, size: 18), const SizedBox(height: 2), const Text('Buka situs UGM', style: TextStyle(fontSize: 9, color: textSecondary))]), onTap: () => DeviceBridge.openUrl(tool.$4))))),
          const Padding(padding: EdgeInsets.only(top: 5), child: Text('Beberapa Tools AI dibuka pada situs resmi UGM dan dapat meminta autentikasi sesuai kebijakan layanannya.', style: TextStyle(fontSize: 12, color: textSecondary))),
        ]),
      );
}

class FacilityMapScreen extends StatefulWidget {
  const FacilityMapScreen({super.key, required this.api});
  final ApiClient api;

  @override
  State<FacilityMapScreen> createState() => _FacilityMapScreenState();
}

class _FacilityMapScreenState extends State<FacilityMapScreen> {
  List<Facility> facilities = const [];
  bool loading = true;
  String? error;
  String query = '';
  String category = '';
  Facility? selected;
  bool showGestureHint = true;
  final searchController = TextEditingController();

  List<Facility> get filtered => facilities.where((item) {
    final q = query.toLowerCase();
    return (q.isEmpty || item.name.toLowerCase().contains(q) || item.owner.toLowerCase().contains(q)) && (category.isEmpty || item.category == category);
  }).toList();

  @override
  void initState() {
    super.initState();
    load();
    Future<void>.delayed(const Duration(seconds: 4), () {
      if (mounted) setState(() => showGestureHint = false);
    });
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  Future<void> load() async {
    setState(() { loading = true; error = null; });
    try { final result = await widget.api.facilities(); if (mounted) setState(() => facilities = result); }
    catch (e) { if (mounted) setState(() => error = '$e'); }
    finally { if (mounted) setState(() => loading = false); }
  }

  Future<void> selectCategory(List<String> categories) async {
    final value = await showModalBottomSheet<String>(
      context: context,
      showDragHandle: true,
      isScrollControlled: true,
      builder: (context) => SafeArea(
        child: SizedBox(
          height: MediaQuery.sizeOf(context).height * .66,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Padding(
                padding: EdgeInsets.fromLTRB(20, 4, 20, 10),
                child: Text(
                  'Filter Kategori Fasilitas',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900),
                ),
              ),
              Expanded(
                child: RadioGroup<String>(
                  groupValue: category,
                  onChanged: (item) {
                    if (item != null) Navigator.pop(context, item);
                  },
                  child: ListView(
                    children: [
                      const RadioListTile<String>(
                        value: '',
                        title: Text('Semua kategori'),
                      ),
                      ...categories.map(
                        (item) => RadioListTile<String>(
                          value: item,
                          title: Text(item),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
    if (value != null && mounted) {
      setState(() {
        category = value;
        selected = null;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final categories = facilities.map((e) => e.category).where((e) => e.isNotEmpty).toSet().toList()..sort();
    return Scaffold(
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : error != null
              ? _ErrorView(message: error!, retry: load)
              : Stack(
                  children: [
                    Positioned.fill(
                      child: UgmTileMap(
                        facilities: filtered,
                        selected: selected,
                        onSelect: (value) => setState(() => selected = value),
                      ),
                    ),
                    SafeArea(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(12, 10, 12, 0),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Material(
                              elevation: 8,
                              shadowColor: Colors.black26,
                              borderRadius: BorderRadius.circular(24),
                              color: Colors.white,
                              child: Row(
                                children: [
                                  IconButton(
                                    tooltip: 'Kembali',
                                    onPressed: () => Navigator.pop(context),
                                    icon: const Icon(Icons.arrow_back),
                                  ),
                                  Expanded(
                                    child: TextField(
                                      controller: searchController,
                                      onChanged: (value) => setState(() {
                                        query = value;
                                        selected = null;
                                      }),
                                      decoration: const InputDecoration(
                                        hintText: 'Cari fasilitas di UGM',
                                        fillColor: Colors.transparent,
                                        contentPadding: EdgeInsets.symmetric(vertical: 14),
                                      ),
                                    ),
                                  ),
                                  if (query.isNotEmpty)
                                    IconButton(
                                      tooltip: 'Hapus pencarian',
                                      onPressed: () {
                                        searchController.clear();
                                        setState(() => query = '');
                                      },
                                      icon: const Icon(Icons.close),
                                    ),
                                  Badge(
                                    isLabelVisible: category.isNotEmpty,
                                    child: IconButton(
                                      tooltip: 'Filter kategori',
                                      onPressed: () => selectCategory(categories),
                                      icon: const Icon(Icons.tune),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 10),
                            SizedBox(
                              height: 40,
                              child: ListView(
                                scrollDirection: Axis.horizontal,
                                children: [
                                  _MapFilterChip(
                                    label: 'Semua',
                                    selected: category.isEmpty,
                                    onTap: () => setState(() => category = ''),
                                  ),
                                  ...categories.take(5).map(
                                    (item) => _MapFilterChip(
                                      label: item,
                                      selected: category == item,
                                      onTap: () => setState(() => category = item),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    Positioned(
                      top: MediaQuery.paddingOf(context).top + 108,
                      left: 0,
                      right: 0,
                      child: IgnorePointer(
                        child: AnimatedOpacity(
                          opacity: showGestureHint ? 1 : 0,
                          duration: const Duration(milliseconds: 450),
                          child: Center(
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 7,
                              ),
                              decoration: BoxDecoration(
                                color: navy.withValues(alpha: .84),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: const Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(Icons.pinch, color: Colors.white, size: 17),
                                  SizedBox(width: 7),
                                  Text(
                                    'Cubit untuk zoom • Geser untuk menjelajah',
                                    style: TextStyle(color: Colors.white, fontSize: 12),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    Positioned(
                      left: 8,
                      bottom: MediaQuery.sizeOf(context).height * .17,
                      child: InkWell(
                        onTap: () => DeviceBridge.openUrl(
                          'https://www.openstreetmap.org/copyright',
                        ),
                        child: Container(
                          color: Colors.white.withValues(alpha: .88),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 5,
                            vertical: 2,
                          ),
                          child: const Text(
                            '© OpenStreetMap contributors',
                            style: TextStyle(fontSize: 10),
                          ),
                        ),
                      ),
                    ),
                    DraggableScrollableSheet(
                      initialChildSize: .17,
                      minChildSize: .13,
                      maxChildSize: .58,
                      snap: true,
                      snapSizes: const [.17, .58],
                      builder: (context, scrollController) => Material(
                        elevation: 18,
                        color: Colors.white,
                        borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(24),
                        ),
                        clipBehavior: Clip.antiAlias,
                        child: ListView.builder(
                          controller: scrollController,
                          padding: EdgeInsets.zero,
                          itemCount: filtered.length + 1,
                          itemBuilder: (context, index) {
                            if (index == 0) {
                              return Column(
                                children: [
                                  const SizedBox(height: 8),
                                  Container(
                                    width: 42,
                                    height: 4,
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFD6DAE1),
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.fromLTRB(18, 11, 10, 10),
                                    child: Row(
                                      children: [
                                        const CircleAvatar(
                                          backgroundColor: Color(0xFFEAF1FF),
                                          child: Icon(Icons.place, color: ugmBlue),
                                        ),
                                        const SizedBox(width: 10),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                selected?.name ?? 'Jelajahi Fasilitas UGM',
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                                style: const TextStyle(
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.w900,
                                                ),
                                              ),
                                              Text(
                                                selected == null
                                                    ? '${filtered.length} lokasi tersedia'
                                                    : '${selected!.category} • ${selected!.owner}',
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                                style: const TextStyle(
                                                  fontSize: 12,
                                                  color: textSecondary,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        if (selected != null) ...[
                                          IconButton.filledTonal(
                                            tooltip: 'Petunjuk arah',
                                            onPressed: () => DeviceBridge.openUrl(
                                              selected!.routeUrl.isNotEmpty
                                                  ? selected!.routeUrl
                                                  : 'https://www.google.com/maps/search/?api=1&query=${selected!.latitude},${selected!.longitude}',
                                            ),
                                            icon: const Icon(Icons.directions),
                                          ),
                                          if (selected!.webUrl.isNotEmpty)
                                            IconButton(
                                              tooltip: 'Buka detail',
                                              onPressed: () => DeviceBridge.openUrl(
                                                selected!.webUrl,
                                              ),
                                              icon: const Icon(Icons.open_in_new),
                                            ),
                                        ],
                                      ],
                                    ),
                                  ),
                                  const Divider(height: 1),
                                ],
                              );
                            }
                            final item = filtered[index - 1];
                            return ListTile(
                              selected: selected?.id == item.id,
                              leading: const Icon(Icons.location_on_outlined, color: ugmBlue),
                              title: Text(
                                item.name,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(fontWeight: FontWeight.w700),
                              ),
                              subtitle: Text(
                                '${item.category} • ${item.owner}',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              onTap: () => setState(() => selected = item),
                            );
                          },
                        ),
                      ),
                    ),
                  ],
                ),
    );
  }
}

class _MapFilterChip extends StatelessWidget {
  const _MapFilterChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(right: 8),
        child: Material(
          elevation: selected ? 5 : 2,
          color: selected ? ugmBlue : Colors.white,
          borderRadius: BorderRadius.circular(20),
          child: InkWell(
            borderRadius: BorderRadius.circular(20),
            onTap: onTap,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
              child: Text(
                label,
                style: TextStyle(
                  color: selected ? Colors.white : navy,
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
        ),
      );
}

class UgmTileMap extends StatefulWidget {
  const UgmTileMap({super.key, required this.facilities, required this.selected, required this.onSelect});
  final List<Facility> facilities;
  final Facility? selected;
  final ValueChanged<Facility> onSelect;

  @override
  State<UgmTileMap> createState() => _UgmTileMapState();
}

class _UgmTileMapState extends State<UgmTileMap> {
  double latitude = -7.7707;
  double longitude = 110.3776;
  double zoom = 15;
  static const tileSize = 256.0;
  Size viewportSize = Size.zero;
  double gestureStartZoom = 15;
  math.Point<double> gestureAnchor = const math.Point<double>(0, 0);

  @override
  void didUpdateWidget(covariant UgmTileMap oldWidget) {
    super.didUpdateWidget(oldWidget);
    final next = widget.selected;
    if (next != null && next.id != oldWidget.selected?.id) {
      setState(() {
        latitude = next.latitude;
        longitude = next.longitude;
        zoom = math.max(zoom, 17);
      });
    }
  }

  math.Point<double> world(double lat, double lon, [double? atZoom]) {
    final scale = math.pow(2, atZoom ?? zoom).toDouble() * tileSize;
    final x = (lon + 180) / 360 * scale;
    final sinLat = math.sin(lat * math.pi / 180).clamp(-0.9999, 0.9999);
    final y = (0.5 - math.log((1 + sinLat) / (1 - sinLat)) / (4 * math.pi)) * scale;
    return math.Point(x, y);
  }

  void setCenterFromWorld(math.Point<double> center, double atZoom) {
    final scale = math.pow(2, atZoom).toDouble() * tileSize;
    longitude = center.x / scale * 360 - 180;
    final n = math.pi - 2 * math.pi * center.y / scale;
    latitude = 180 / math.pi * math.atan(
      .5 * (math.exp(n) - math.exp(-n)),
    );
  }

  void onScaleStart(ScaleStartDetails details) {
    gestureStartZoom = zoom;
    final scale = math.pow(2, gestureStartZoom).toDouble() * tileSize;
    final center = world(latitude, longitude, gestureStartZoom);
    gestureAnchor = math.Point(
      (center.x + details.localFocalPoint.dx - viewportSize.width / 2) / scale,
      (center.y + details.localFocalPoint.dy - viewportSize.height / 2) / scale,
    );
  }

  void onScaleUpdate(ScaleUpdateDetails details) {
    final nextZoom = (gestureStartZoom +
            math.log(details.scale) / math.ln2)
        .clamp(11.0, 19.0)
        .toDouble();
    final scale = math.pow(2, nextZoom).toDouble() * tileSize;
    final center = math.Point(
      gestureAnchor.x * scale -
          details.localFocalPoint.dx +
          viewportSize.width / 2,
      gestureAnchor.y * scale -
          details.localFocalPoint.dy +
          viewportSize.height / 2,
    );
    setState(() {
      zoom = nextZoom;
      setCenterFromWorld(center, nextZoom);
    });
  }

  void changeZoom(double delta) {
    setState(() => zoom = (zoom + delta).clamp(11.0, 19.0).toDouble());
  }

  /// Grid-based marker clustering: marker yang jatuh di sel grid yang sama
  /// (72 px layar) dirender sebagai satu cluster berisi jumlah, sehingga
  /// peta awal tidak menampilkan ratusan pin individu (UX-04).
  static const _clusterGrid = 72.0;

  List<Widget> _buildMarkers(BoxConstraints size, math.Point<double> center) {
    final cells = <String, List<({Facility item, math.Point<double> pos})>>{};
    for (final item in widget.facilities) {
      final point = world(item.latitude, item.longitude);
      final left = point.x - center.x + size.maxWidth / 2;
      final top = point.y - center.y + size.maxHeight / 2;
      if (left < -40 || top < -40 || left > size.maxWidth + 40 || top > size.maxHeight + 40) continue;
      final key = '${(left / _clusterGrid).floor()}:${(top / _clusterGrid).floor()}';
      cells.putIfAbsent(key, () => []).add((item: item, pos: math.Point(left, top)));
    }
    final widgets = <Widget>[];
    for (final group in cells.values) {
      if (group.length == 1) {
        final item = group.first.item;
        final p = group.first.pos;
        widgets.add(Positioned(
          left: p.x - 19,
          top: p.y - 38,
          child: Semantics(
            label: item.name,
            button: true,
            child: GestureDetector(
              onTap: () => widget.onSelect(item),
              child: Icon(
                Icons.location_pin,
                color: widget.selected?.id == item.id ? Colors.orange : ugmBlue,
                size: widget.selected?.id == item.id ? 46 : 38,
              ),
            ),
          ),
        ));
      } else {
        final avgX = group.map((e) => e.pos.x).reduce((a, b) => a + b) / group.length;
        final avgY = group.map((e) => e.pos.y).reduce((a, b) => a + b) / group.length;
        final lat = group.map((e) => e.item.latitude).reduce((a, b) => a + b) / group.length;
        final lon = group.map((e) => e.item.longitude).reduce((a, b) => a + b) / group.length;
        widgets.add(Positioned(
          left: avgX - 24,
          top: avgY - 24,
          child: Semantics(
            label: '${group.length} fasilitas di area ini',
            button: true,
            child: GestureDetector(
              onTap: () => setState(() {
                latitude = lat;
                longitude = lon;
                zoom = math.min(zoom + 2, 19);
              }),
              child: Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: ugmBlue,
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 2.5),
                  boxShadow: const [
                    BoxShadow(color: Colors.black26, blurRadius: 6, offset: Offset(0, 2)),
                  ],
                ),
                alignment: Alignment.center,
                child: Text(
                  '${group.length}',
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 15),
                ),
              ),
            ),
          ),
        ));
      }
    }
    return widgets;
  }

  @override
  Widget build(BuildContext context) => LayoutBuilder(builder: (context, size) {
    viewportSize = Size(size.maxWidth, size.maxHeight);
    final center = world(latitude, longitude);
    final tileZoom = zoom.floor();
    final displayTileSize = tileSize * math.pow(2, zoom - tileZoom);
    final minX = ((center.x - size.maxWidth / 2) / displayTileSize).floor();
    final maxX = ((center.x + size.maxWidth / 2) / displayTileSize).floor();
    final minY = ((center.y - size.maxHeight / 2) / displayTileSize).floor();
    final maxY = ((center.y + size.maxHeight / 2) / displayTileSize).floor();
    final count = math.pow(2, tileZoom).toInt();
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onScaleStart: onScaleStart,
      onScaleUpdate: onScaleUpdate,
      onDoubleTap: () => changeZoom(1),
      child: ClipRect(child: Stack(children: [
        Container(color: const Color(0xFFDDE5D7)),
        for (var x = minX; x <= maxX; x++) for (var y = minY; y <= maxY; y++)
          Positioned(
            left: x * displayTileSize - center.x + size.maxWidth / 2,
            top: y * displayTileSize - center.y + size.maxHeight / 2,
            width: displayTileSize + .5,
            height: displayTileSize + .5,
            child: (y >= 0 && y < count)
                ? Image.network(
                    'https://tile.openstreetmap.org/$tileZoom/${x % count}/$y.png',
                    fit: BoxFit.cover,
                    filterQuality: FilterQuality.medium,
                    errorBuilder: (_, _, _) => const ColoredBox(
                      color: Color(0xFFE8EDE5),
                    ),
                  )
                : const SizedBox.shrink(),
          ),
        ..._buildMarkers(size, center),
        Positioned(right: 12, bottom: 150, child: Column(children: [
          FloatingActionButton.small(heroTag: 'zoomIn', tooltip: 'Perbesar', onPressed: zoom < 19 ? () => changeZoom(1) : null, child: const Icon(Icons.add)),
          const SizedBox(height: 7),
          FloatingActionButton.small(heroTag: 'zoomOut', tooltip: 'Perkecil', onPressed: zoom > 11 ? () => changeZoom(-1) : null, child: const Icon(Icons.remove)),
          const SizedBox(height: 7),
          FloatingActionButton.small(heroTag: 'resetMap', tooltip: 'Lokasi saya', onPressed: () => setState(() { latitude = -7.7707; longitude = 110.3776; zoom = 15; }), child: const Icon(Icons.my_location)),
        ])),
      ])),
    );
  });
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.icon, required this.title, required this.subtitle});
  final IconData icon;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) => Center(child: Padding(padding: const EdgeInsets.all(32), child: Column(mainAxisSize: MainAxisSize.min, children: [Icon(icon, size: 54, color: ugmBlue), const SizedBox(height: 14), Text(title, textAlign: TextAlign.center, style: const TextStyle(fontSize: 19, fontWeight: FontWeight.w900)), const SizedBox(height: 7), Text(subtitle, textAlign: TextAlign.center, style: const TextStyle(color: textSecondary, height: 1.4))])));
}

class _ErrorView extends StatelessWidget {
  const _ErrorView({required this.message, required this.retry});
  final String message;
  final VoidCallback retry;

  @override
  Widget build(BuildContext context) => Center(child: Padding(padding: const EdgeInsets.all(28), child: Column(mainAxisSize: MainAxisSize.min, children: [const Icon(Icons.cloud_off, size: 48, color: ugmBlue), const SizedBox(height: 12), const Text('Data belum dapat dimuat', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800)), const SizedBox(height: 6), Text(message, textAlign: TextAlign.center, maxLines: 3, overflow: TextOverflow.ellipsis), const SizedBox(height: 16), FilledButton.icon(onPressed: retry, icon: const Icon(Icons.refresh), label: const Text('Coba lagi'))])));
}
