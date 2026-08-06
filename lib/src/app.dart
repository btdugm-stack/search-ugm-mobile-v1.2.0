import 'dart:math' as math;

import 'package:flutter/material.dart';

import 'api_client.dart';
import 'device_bridge.dart';
import 'models.dart';

const ugmBlue = Color(0xFF003F88);
const navy = Color(0xFF071D49);
const surface = Color(0xFFF5F7FB);

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

  void openSearch({String query = '', String type = 'all'}) {
    setState(() {
      initialQuery = query;
      initialType = type;
      index = 1;
    });
  }

  Future<void> push(Widget page) => Navigator.of(context).push(MaterialPageRoute(builder: (_) => page));

  @override
  Widget build(BuildContext context) {
    final pages = <Widget>[
      HomeScreen(
        onSearch: (query) => openSearch(query: query),
        onBrowse: (type) => openSearch(type: type),
        onAi: () => setState(() => index = 2),
        onTools: () => push(const ToolsAiScreen()),
        onMap: () => push(FacilityMapScreen(api: api)),
      ),
      SearchScreen(key: ValueKey('$initialQuery-$initialType'), api: api, initialQuery: initialQuery, initialType: initialType),
      AiScreen(api: api),
      const ServicesScreen(),
      const HistoryScreen(),
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
          NavigationDestination(icon: Icon(Icons.history), label: 'Histori'),
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
  final VoidCallback onAi;
  final VoidCallback onTools;
  final VoidCallback onMap;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final controller = TextEditingController();
  bool expanded = false;

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
  ];

  @override
  Widget build(BuildContext context) {
    Widget quickAccessGrid(List<({String label, String type, IconData icon})> items) {
      return GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: items.length,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 4,
          crossAxisSpacing: 8,
          mainAxisSpacing: 8,
          childAspectRatio: .82,
        ),
        itemBuilder: (_, i) {
          final item = items[i];
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
        },
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
              TextField(
                controller: controller,
                textInputAction: TextInputAction.search,
                onSubmitted: widget.onSearch,
                decoration: InputDecoration(
                  hintText: 'Cari apa saja di UGM…',
                  prefixIcon: const Icon(Icons.search),
                  suffixIcon: IconButton(icon: const Icon(Icons.arrow_forward), onPressed: () => widget.onSearch(controller.text)),
                ),
              ),
            ]),
          ),
        ),
        SliverPadding(
          padding: const EdgeInsets.all(18),
          sliver: SliverList.list(children: [
            SectionTitle('Akses Cepat', trailing: TextButton.icon(
              onPressed: () => setState(() => expanded = !expanded),
              icon: AnimatedRotation(
                turns: expanded ? .5 : 0,
                duration: const Duration(milliseconds: 380),
                curve: Curves.easeInOutCubic,
                child: const Icon(Icons.expand_more),
              ),
              label: AnimatedSwitcher(
                duration: const Duration(milliseconds: 220),
                child: Text(
                  expanded ? 'Ringkas' : 'Lihat semua (${explore.length})',
                  key: ValueKey(expanded),
                ),
              ),
            )),
            const SizedBox(height: 10),
            AnimatedCrossFade(
              firstChild: quickAccessGrid(explore.take(8).toList()),
              secondChild: quickAccessGrid(explore),
              crossFadeState: expanded
                  ? CrossFadeState.showSecond
                  : CrossFadeState.showFirst,
              duration: const Duration(milliseconds: 420),
              reverseDuration: const Duration(milliseconds: 360),
              firstCurve: Curves.easeOutCubic,
              secondCurve: Curves.easeInCubic,
              sizeCurve: Curves.easeInOutCubicEmphasized,
              alignment: Alignment.topCenter,
            ),
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
              child: ListTile(
                onTap: widget.onAi,
                leading: const CircleAvatar(backgroundColor: ugmBlue, child: Icon(Icons.auto_awesome, color: Colors.white)),
                title: const Text('DSH Menjawab — Smart', style: TextStyle(fontWeight: FontWeight.w800)),
                subtitle: const Text('Jawaban ringkas dari sumber UGM terpercaya.'),
                trailing: const Icon(Icons.chevron_right),
              ),
            ),
            const SizedBox(height: 24),
            const SectionTitle('Populer Minggu Ini'),
            const SizedBox(height: 10),
            Card(child: ListTile(onTap: () => widget.onSearch('beasiswa S2'), leading: const Icon(Icons.school_outlined, color: ugmBlue), title: const Text('Beasiswa S2 Dalam Negeri'), subtitle: const Text('Temukan informasi dan tenggat terbaru'), trailing: const Icon(Icons.arrow_forward_ios, size: 16))),
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
              Text(subtitle, style: TextStyle(color: Colors.grey.shade600, fontSize: 12)),
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

  static const types = <String, String>{
    'all': 'Semua', 'service': 'Layanan', 'news': 'Berita', 'product': 'Produk', 'people': 'Dosen',
    'publication': 'Publikasi', 'patent': 'HKI', 'tech4disaster': 'Tech4disaster', 'legal': 'Hukum',
    'pidato': 'Pidato', 'facility': 'Fasilitas', 'event': 'Agenda',
  };

  int get activeFilters => (dharma.isNotEmpty ? 1 : 0) + (year.isNotEmpty ? 1 : 0);

  @override
  void initState() {
    super.initState();
    controller = TextEditingController(text: widget.initialQuery);
    type = widget.initialType;
    if (controller.text.isNotEmpty || type != 'all') search();
  }

  Future<void> search() async {
    if (controller.text.trim().isEmpty && type == 'all') return;
    setState(() { loading = true; error = null; });
    try {
      if (controller.text.trim().isNotEmpty) {
        final old = await DeviceBridge.getHistory();
        await DeviceBridge.saveHistory([controller.text.trim(), ...old.where((item) => item != controller.text.trim())]);
      }
      final result = await widget.api.search(query: controller.text, type: type, dharma: dharma, year: year);
      if (mounted) setState(() => response = result);
    } catch (e) {
      if (mounted) setState(() => error = '$e');
    } finally {
      if (mounted) setState(() => loading = false);
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
            Expanded(child: TextField(controller: controller, textInputAction: TextInputAction.search, onSubmitted: (_) => search(), decoration: InputDecoration(hintText: 'Cari apa saja di UGM…', prefixIcon: const Icon(Icons.search), suffixIcon: IconButton(icon: const Icon(Icons.close), onPressed: () => controller.clear())))),
            const SizedBox(width: 8),
            Badge(isLabelVisible: activeFilters > 0, label: Text('$activeFilters'), child: IconButton.filledTonal(onPressed: showFilters, icon: const Icon(Icons.tune))),
          ]),
        ),
        SizedBox(height: 42, child: ListView.separated(
          padding: const EdgeInsets.symmetric(horizontal: 16), scrollDirection: Axis.horizontal, itemCount: types.length, separatorBuilder: (_, _) => const SizedBox(width: 7),
          itemBuilder: (_, i) { final entry = types.entries.elementAt(i); return ChoiceChip(label: Text(entry.value), selected: type == entry.key, onSelected: (_) { setState(() => type = entry.key); if (controller.text.isNotEmpty || type != 'all') search(); }); },
        )),
        if (dharma.isNotEmpty || year.isNotEmpty) Padding(padding: const EdgeInsets.fromLTRB(16, 8, 16, 0), child: Align(alignment: Alignment.centerLeft, child: Text('Filter aktif: ${[if (dharma.isNotEmpty) dharma, if (year.isNotEmpty) year].join(' • ')}', style: const TextStyle(color: ugmBlue, fontWeight: FontWeight.w600)))),
        const SizedBox(height: 8),
        Expanded(child: _searchBody()),
      ]);

  Widget _searchBody() {
    if (loading) return const Center(child: CircularProgressIndicator());
    if (error != null) return _ErrorView(message: error!, retry: search);
    if (response == null) return const _EmptyState(icon: Icons.manage_search, title: 'Cari informasi UGM', subtitle: 'Gunakan kata kunci, kategori, dan filter untuk hasil yang lebih tepat.');
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
                    color: Colors.grey,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          );
        }
        return ResultCard(item: response!.items[i - 1]);
      },
    );
  }
}

class ResultCard extends StatelessWidget {
  const ResultCard({super.key, required this.item});
  final SearchItem item;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: Card(child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () => DeviceBridge.openUrl(item.url),
          child: Padding(padding: const EdgeInsets.all(14), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [
              Chip(label: Text(item.type.toUpperCase(), style: const TextStyle(fontSize: 10)), visualDensity: VisualDensity.compact, side: BorderSide.none, backgroundColor: const Color(0xFFEAF1FF)),
              if (item.dharma.isNotEmpty) ...[const SizedBox(width: 7), Expanded(child: Text(item.dharma, style: const TextStyle(fontSize: 11, color: ugmBlue)))],
            ]),
            const SizedBox(height: 5),
            Text(item.title, maxLines: 3, overflow: TextOverflow.ellipsis, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16)),
            if (item.description.isNotEmpty) ...[const SizedBox(height: 7), Text(item.description, maxLines: 3, overflow: TextOverflow.ellipsis, style: TextStyle(color: Colors.grey.shade700, height: 1.35))],
            const SizedBox(height: 9),
            Row(children: [const Icon(Icons.verified_outlined, size: 15, color: ugmBlue), const SizedBox(width: 5), Expanded(child: Text(item.source, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 12, color: ugmBlue))), const Icon(Icons.open_in_new, size: 16)]),
          ])),
        )),
      );
}

class AiScreen extends StatefulWidget {
  const AiScreen({super.key, required this.api});
  final ApiClient api;

  @override
  State<AiScreen> createState() => _AiScreenState();
}

class _AiScreenState extends State<AiScreen> {
  final controller = TextEditingController();
  final sessionId = 'mobile-${DateTime.now().millisecondsSinceEpoch}';
  final messages = <({bool user, String text, List<SearchItem> sources})>[];
  bool loading = false;

  Future<void> send() async {
    final question = controller.text.trim();
    if (question.isEmpty || loading) return;
    controller.clear();
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

  @override
  Widget build(BuildContext context) => Column(children: [
        Container(
          padding: const EdgeInsets.all(16),
          color: Colors.white,
          child: const Row(children: [Icon(Icons.auto_awesome, color: ugmBlue), SizedBox(width: 10), Expanded(child: Text('DSH Menjawab', style: TextStyle(fontSize: 19, fontWeight: FontWeight.w900))), Chip(label: Text('SMART'), side: BorderSide.none, backgroundColor: Color(0xFFEAF1FF))]),
        ),
        Expanded(child: messages.isEmpty
            ? const _EmptyState(icon: Icons.auto_awesome, title: 'Tanyakan apa saja tentang UGM', subtitle: 'Mode Smart menggabungkan penelusuran semantik dan sumber UGM terpercaya.')
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
                        ...message.sources.take(4).map((source) => ListTile(contentPadding: EdgeInsets.zero, dense: true, leading: const Icon(Icons.link, size: 18), title: Text(source.title, maxLines: 2), onTap: () => DeviceBridge.openUrl(source.url))),
                      ],
                    ]),
                  ),
                );
              })),
        if (loading) const LinearProgressIndicator(),
        Padding(
          padding: const EdgeInsets.all(12),
          child: Row(children: [Expanded(child: TextField(controller: controller, maxLines: 3, minLines: 1, onSubmitted: (_) => send(), decoration: const InputDecoration(hintText: 'Tanya lebih lanjut…', prefixIcon: Icon(Icons.mic_none)))), const SizedBox(width: 8), IconButton.filled(onPressed: send, icon: const Icon(Icons.send))]),
        ),
        const Padding(padding: EdgeInsets.only(bottom: 7), child: Text('Jawaban AI dapat tidak 100% akurat.', style: TextStyle(fontSize: 10, color: Colors.grey))),
      ]);
}

class ServicesScreen extends StatelessWidget {
  const ServicesScreen({super.key});
  static const services = [
    ('SIMASTER', 'Sistem informasi akademik UGM', 'https://simaster.ugm.ac.id'),
    ('ULT', 'Unit Layanan Terpadu', 'https://ult.ugm.ac.id/eservices/portal/'),
    ('Dashboard UGM', 'UGM Dalam Angka', 'https://dashboard.ugm.ac.id/public/ugm_dalam_angka/view'),
    ('E-Learning UGM', 'Pembelajaran daring UGM', 'https://elok.ugm.ac.id'),
    ('PIONIR', 'PIONIR Gadjah Mada 2026', 'https://pionir.ugm.ac.id/'),
  ];

  @override
  Widget build(BuildContext context) => ListView(padding: const EdgeInsets.all(16), children: [
        const Text('Layanan', style: TextStyle(fontSize: 24, fontWeight: FontWeight.w900, color: navy)),
        const SizedBox(height: 6),
        const Text('Direktori layanan digital UGM'),
        const SizedBox(height: 18),
        TextField(decoration: const InputDecoration(prefixIcon: Icon(Icons.search), hintText: 'Cari layanan…'), onChanged: (_) {}),
        const SizedBox(height: 18),
        const SectionTitle('Layanan Populer'),
        const SizedBox(height: 10),
        ...services.map((item) => Padding(padding: const EdgeInsets.only(bottom: 9), child: Card(child: ListTile(onTap: () => DeviceBridge.openUrl(item.$3), leading: CircleAvatar(backgroundColor: const Color(0xFFEAF1FF), child: Text(item.$1.characters.first, style: const TextStyle(color: ugmBlue, fontWeight: FontWeight.w900))), title: Text(item.$1, style: const TextStyle(fontWeight: FontWeight.w800)), subtitle: Text(item.$2), trailing: const Icon(Icons.open_in_new, size: 18))))),
      ]);
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
          ...tools.map((tool) => Padding(padding: const EdgeInsets.only(bottom: 10), child: Card(child: ListTile(contentPadding: const EdgeInsets.all(12), leading: CircleAvatar(backgroundColor: const Color(0xFFEAF1FF), child: Icon(tool.$3, color: ugmBlue)), title: Text(tool.$1, style: const TextStyle(fontWeight: FontWeight.w800)), subtitle: Padding(padding: const EdgeInsets.only(top: 5), child: Text(tool.$2)), trailing: const Icon(Icons.open_in_new), onTap: () => DeviceBridge.openUrl(tool.$4))))),
          const Padding(padding: EdgeInsets.only(top: 5), child: Text('Beberapa Tools AI dibuka pada situs resmi UGM dan dapat meminta autentikasi sesuai kebijakan layanannya.', style: TextStyle(fontSize: 12, color: Colors.grey))),
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
                                                  color: Colors.grey,
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
        for (final item in widget.facilities)
          Builder(builder: (_) {
            final point = world(item.latitude, item.longitude);
            final left = point.x - center.x + size.maxWidth / 2;
            final top = point.y - center.y + size.maxHeight / 2;
            if (left < -40 || top < -40 || left > size.maxWidth + 40 || top > size.maxHeight + 40) return const SizedBox.shrink();
            return Positioned(left: left - 19, top: top - 38, child: Semantics(label: item.name, button: true, child: GestureDetector(onTap: () => widget.onSelect(item), child: Icon(Icons.location_pin, color: widget.selected?.id == item.id ? Colors.orange : ugmBlue, size: widget.selected?.id == item.id ? 46 : 38))));
          }),
        Positioned(right: 12, bottom: 150, child: Column(children: [
          FloatingActionButton.small(heroTag: 'zoomIn', onPressed: zoom < 19 ? () => changeZoom(1) : null, child: const Icon(Icons.add)),
          const SizedBox(height: 7),
          FloatingActionButton.small(heroTag: 'zoomOut', onPressed: zoom > 11 ? () => changeZoom(-1) : null, child: const Icon(Icons.remove)),
          const SizedBox(height: 7),
          FloatingActionButton.small(heroTag: 'resetMap', onPressed: () => setState(() { latitude = -7.7707; longitude = 110.3776; zoom = 15; }), child: const Icon(Icons.my_location)),
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
  Widget build(BuildContext context) => Center(child: Padding(padding: const EdgeInsets.all(32), child: Column(mainAxisSize: MainAxisSize.min, children: [Icon(icon, size: 54, color: ugmBlue), const SizedBox(height: 14), Text(title, textAlign: TextAlign.center, style: const TextStyle(fontSize: 19, fontWeight: FontWeight.w900)), const SizedBox(height: 7), Text(subtitle, textAlign: TextAlign.center, style: const TextStyle(color: Colors.grey, height: 1.4))])));
}

class _ErrorView extends StatelessWidget {
  const _ErrorView({required this.message, required this.retry});
  final String message;
  final VoidCallback retry;

  @override
  Widget build(BuildContext context) => Center(child: Padding(padding: const EdgeInsets.all(28), child: Column(mainAxisSize: MainAxisSize.min, children: [const Icon(Icons.cloud_off, size: 48, color: ugmBlue), const SizedBox(height: 12), const Text('Data belum dapat dimuat', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800)), const SizedBox(height: 6), Text(message, textAlign: TextAlign.center, maxLines: 3, overflow: TextOverflow.ellipsis), const SizedBox(height: 16), FilledButton.icon(onPressed: retry, icon: const Icon(Icons.refresh), label: const Text('Coba lagi'))])));
}
