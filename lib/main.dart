import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher_string.dart';
import 'services/favorites_service.dart';
import 'services/notes_service.dart';
import 'screens/provider_details.dart';
import 'screens/onboarding_screen.dart';
import 'services/update_service.dart';
import 'dart:async';
import 'services/favorites_service.dart';
import 'screens/provider_details.dart';
import 'package:url_launcher/url_launcher_string.dart';
import 'models/iptv_provider.dart';
import 'services/scraper_service.dart';

void main() => runApp(const DiscoverInternetTV());

class DiscoverInternetTV extends StatelessWidget {
  const DiscoverInternetTV({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Discover Internet TV',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.dark(
          primary: const Color(0xFFFFC107),
          secondary: const Color(0xFF2196F3),
          surface: const Color(0xFF1A1A2E),
        ),
        scaffoldBackgroundColor: const Color(0xFF0D0D1A),
        appBarTheme: const AppBarTheme(backgroundColor: Color(0xFF1A1A2E), foregroundColor: Color(0xFFFFC107), elevation: 0),
        useMaterial3: true,
      ),
      home: FutureBuilder<bool>(
        future: OnboardingScreen.shouldShow(),
        builder: (ctx, snap) {
          if (snap.connectionState == ConnectionState.waiting) {
            return const Scaffold(body: Center(child: CircularProgressIndicator(color: Color(0xFFFFC107))));
          }
          return snap.data == true ? OnboardingScreen(home: const HomeScreen()) : const HomeScreen();
        },
      ),
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController _searchCtrl = TextEditingController();
  List<IptvProvider> _providers = [];
  List<IptvProvider> _filtered = [];
  List<IptvProvider> get _displayList => _filtered;
  bool _isLoading = false;
  String? _error;
  String _sortBy = 'Name';
  Set<String> _favorites = {};
  bool _showFavoritesOnly = false;

  @override
  void initState() { super.initState(); _loadFavorites(); _loadDefault(); _checkUpdate(); }

  Widget _featureItem(BuildContext ctx, IconData ic, String title, String desc) {
    return GestureDetector(
      onTap: () => showDialog(context: ctx, builder: (c2) => AlertDialog(
        backgroundColor: const Color(0xFF1A1A2E),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12), side: BorderSide(color: Color(0xFF2A2A4E))),
        title: Row(children: [Icon(ic, size: 18, color: Color(0xFFFFC107)), const SizedBox(width: 8), Text(title, style: const TextStyle(color: Color(0xFFFFC107), fontSize: 16))]),
        content: Text(desc, style: const TextStyle(color: Color(0xFFB0B0B0), fontSize: 13, height: 1.4)),
        actions: [TextButton(onPressed: () => Navigator.pop(c2), child: const Text("Got it", style: TextStyle(color: Color(0xFFFFC107))))],
      )),
      child: Padding(padding: const EdgeInsets.only(bottom: 8), child: Row(children: [
        Icon(ic, size: 16, color: Color(0xFFFFC107)),
        const SizedBox(width: 10),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(title, style: const TextStyle(color: Colors.white, fontSize: 13)),
          const SizedBox(height: 1),
          Text("Tap for how-to", style: const TextStyle(color: Color(0xFF8888AA), fontSize: 9)),
        ])),
        const Icon(Icons.chevron_right, size: 16, color: Colors.grey),
      ])),
    );
  }

  void _about(BuildContext c) {
    showDialog(
      context: c,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1A1A2E),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16), side: BorderSide(color: Color(0xFF2A2A4E))),
        title: const Text("About", style: TextStyle(color: Color(0xFFFFC107), fontSize: 18)),
        content: SingleChildScrollView(child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisSize: MainAxisSize.min, children: [
          Text("Discover Internet TV", style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
          Text("v1.0.0+15", style: TextStyle(color: Colors.grey, fontSize: 12)),
          SizedBox(height: 4),
          Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text("Created by LittleLouis", style: TextStyle(color: Color(0xFF8888AA), fontSize: 11)),
          GestureDetector(
            onTap: () async { try { await launchUrlString("mailto:louis.males@gmail.com"); } catch (_) {} },
            child: const Text("louis.males@gmail.com", style: TextStyle(color: Color(0xFFFFC107), fontSize: 11, decoration: TextDecoration.underline)),
          ),
        ]),
          SizedBox(height: 16),
          Text("FEATURES", style: TextStyle(color: Color(0xFFFFC107), fontSize: 11, letterSpacing: 2)),
          SizedBox(height: 8),
          _featureItem(ctx, Icons.live_tv, "150+ Providers", "Browse and search IPTV providers. Use the search bar to find specific ones."),
          _featureItem(ctx, Icons.star, "Favorites", "Tap the star icon on any provider to favorite it."),
          _featureItem(ctx, Icons.sort, "Sort", "Tap the sort dropdown to reorder the list."),
          _featureItem(ctx, Icons.category, "Categories", "Tap a category chip to filter providers."),
          _featureItem(ctx, Icons.edit_note, "Notes", "Open any provider and tap the notes section."),
          _featureItem(ctx, Icons.system_update, "Updates", "Auto-checks on startup. Tap Check Update in the menu."),
          SizedBox(height: 16),
          Text("BUILT WITH", style: TextStyle(color: Color(0xFF2196F3), fontSize: 11, letterSpacing: 2)),
          SizedBox(height: 8),
          Text("  Flutter 3.44.2  |  Dart 3.12.2  |  Android SDK 36", style: TextStyle(color: Colors.grey, fontSize: 11)),
          Text("  VS Code  |  pi Coding Agent  |  DuckDuckGo", style: TextStyle(color: Colors.grey, fontSize: 11)),
        ])),
        actions: [TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("Close", style: TextStyle(color: Color(0xFFFFC107))))],
      ),
    );
  }

  Future<void> _searchNotes(BuildContext context) async {
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Add notes to providers first!"), backgroundColor: Color(0xFF2A2A4E)));
  }

  Future<void> _checkUpdate() async {
    final update = await UpdateService.check();
    if (update != null && update.isNewer && mounted) {
      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          backgroundColor: const Color(0xFF1A1A2E),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16), side: const BorderSide(color: Color(0xFF2A2A4E))),
          title: const Row(children: [
            Icon(Icons.system_update, color: Color(0xFFFFC107)),
            SizedBox(width: 10),
            Text("Update Available", style: TextStyle(color: Color(0xFFFFC107), fontSize: 18)),
          ]),
          content: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text("Version " + update.version + " is available", style: const TextStyle(color: Colors.white, fontSize: 15)),
            const SizedBox(height: 4),
            Text("You have v1.0.0+12", style: const TextStyle(color: Colors.grey, fontSize: 12)),
            if (update.notes.isNotEmpty) ...[const SizedBox(height: 12), Text(update.notes, style: const TextStyle(color: Color(0xFFB0B0B0), fontSize: 12))],
          ]),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("Later", style: TextStyle(color: Colors.grey))),
            if (update.downloadUrl.isNotEmpty)
              TextButton(onPressed: () async {
                Navigator.pop(ctx);
                try { await launchUrlString(update.downloadUrl); } catch (_) {}
              }, child: const Text("Update", style: TextStyle(color: Color(0xFFFFC107)))),
          ],
        ),
      );
    }
  }

  Future<void> _loadFavorites() async {
    final favs = await FavoritesService.getFavorites();
    if (mounted) setState(() { _favorites = favs; });
  }
  @override
  void dispose() { _searchCtrl.dispose(); super.dispose(); }

  Future<void> _loadDefault() async {
    setState(() { _isLoading = true; _error = null; });
    try {
      final results = await ScraperService.search('best IPTV providers 2025');
      if (mounted) setState(() { _providers = results; _filtered = results; _isLoading = false; });
      _applySort();
    } catch (e) {
      if (mounted) setState(() { _error = e.toString(); _isLoading = false; });
    }
  }

  Future<void> _search() async {
    final query = _searchCtrl.text.trim();
    if (query.isEmpty) return;
    setState(() { _isLoading = true; _error = null; });
    try {
      final results = await ScraperService.search(query);
      if (mounted) setState(() { _providers = results; _filtered = results; _isLoading = false; });
      _applySort();
    } catch (e) {
      if (mounted) setState(() { _error = e.toString(); _isLoading = false; });
    }
  }

  void _applySort() {
    setState(() {
      _filtered.sort((a, b) {
        switch (_sortBy) {
          case 'Name': return a.name.compareTo(b.name);
          case 'Price':
            final aP = double.tryParse((a.pricing ?? '0').replaceAll(RegExp(r'[^0-9.]'), '')) ?? 999;
            final bP = double.tryParse((b.pricing ?? '0').replaceAll(RegExp(r'[^0-9.]'), '')) ?? 999;
            return aP.compareTo(bP);
          case 'Channels':
            final aC = int.tryParse((a.channels ?? '0').replaceAll(RegExp(r'[^0-9]'), '')) ?? 0;
            final bC = int.tryParse((b.channels ?? '0').replaceAll(RegExp(r'[^0-9]'), '')) ?? 0;
            return bC.compareTo(aC);
          case "Favorites":
            final aFav = _favorites.contains(a.name) ? 0 : 1;
            final bFav = _favorites.contains(b.name) ? 0 : 1;
            if (aFav != bFav) return aFav.compareTo(bFav);
            return a.name.compareTo(b.name);
          default: return 0;
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(children: [
          Image.asset("assets/logo.png", width: 32, height: 32, fit: BoxFit.contain),
          SizedBox(width: 10),
          Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('Discover', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFFFFC107))),
            Text('Internet TV', style: TextStyle(fontSize: 11, color: Color(0xFF2196F3), letterSpacing: 2)),
          ]),
        ]),
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert, color: Color(0xFFFFC107)),
            color: const Color(0xFF1A1A2E),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12), side: BorderSide(color: Color(0xFF2A2A4E))),
            onSelected: (v) {
              if (v == "refresh") { _searchCtrl.clear(); _loadDefault(); }
              else if (v == "about") _about(context);
              else if (v == "notes") _searchNotes(context);
              else if (v == "update") _checkUpdate();
            },
            itemBuilder: (ctx) => [
              PopupMenuItem(value: "refresh", child: ListTile(leading: Icon(Icons.refresh, color: Color(0xFFFFC107)), title: Text("Refresh", style: TextStyle(color: Colors.white)), contentPadding: EdgeInsets.zero, dense: true)),
              PopupMenuItem(value: "notes", child: ListTile(leading: Icon(Icons.search, color: Color(0xFFFFC107)), title: Text("Search Notes", style: TextStyle(color: Colors.white)), contentPadding: EdgeInsets.zero, dense: true)),
              PopupMenuItem(value: "about", child: ListTile(leading: Icon(Icons.info_outline, color: Color(0xFFFFC107)), title: Text("About", style: TextStyle(color: Colors.white)), contentPadding: EdgeInsets.zero, dense: true)),
              PopupMenuItem(value: "update", child: ListTile(leading: Icon(Icons.system_update, color: Color(0xFFFFC107)), title: Text("Check Update", style: TextStyle(color: Colors.white)), contentPadding: EdgeInsets.zero, dense: true)),
            ],
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(56),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
            child: TextField(
              controller: _searchCtrl,
              onSubmitted: (_) => _search(),
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: 'Search TV providers...',
                filled: true, fillColor: const Color(0xFF12122A),
                prefixIcon: const Icon(Icons.search, color: Color(0xFFFFC107)),
                suffixIcon: _searchCtrl.text.isNotEmpty
                  ? IconButton(icon: const Icon(Icons.clear, color: Color(0xFFFFC107)), onPressed: () { _searchCtrl.clear(); _loadDefault(); })
                  : null,
                focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFFFFC107))),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
              ),
            ),
          ),
        ),
      ),
      body: _isLoading
        ? const Center(child: CircularProgressIndicator(color: Color(0xFFFFC107)))
        : _error != null
          ? Center(child: Text('Error: $_error', style: const TextStyle(color: Colors.red)))
          : _displayList.isEmpty
            ? const Center(child: Text('No providers found', style: TextStyle(color: Colors.grey)))
            : RefreshIndicator(
                color: const Color(0xFFFFC107),
                onRefresh: _loadDefault,
                child: ListView.builder(
                  padding: const EdgeInsets.all(12),
                  itemCount: _displayList.length + 1,
                  itemBuilder: (ctx, i) {
                    if (i == 0) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: Row(children: [
                          Text('${_displayList.length} providers', style: const TextStyle(color: Colors.grey, fontSize: 12)),
                          const Spacer(),
                          _sortDropdown(),
                        ]),
                      );
                    }
                    return _buildCard(_displayList[i - 1]);
                  },
                ),
              ),
    );
  }

  Widget _sortDropdown() {
    final options = ['Name', 'Price', 'Channels', 'Favorites'];
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(border: Border.all(color: const Color(0xFFFFC107).withOpacity(0.3)), borderRadius: BorderRadius.circular(6)),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: _sortBy,
          dropdownColor: const Color(0xFF1A1A2E),
          style: const TextStyle(color: Color(0xFFFFC107), fontSize: 11),
          icon: const Icon(Icons.sort, size: 14, color: Color(0xFFFFC107)),
          items: options.map((s) => DropdownMenuItem(value: s, child: Text(s))).toList(),
          onChanged: (v) { _sortBy = v ?? 'Name'; _applySort(); },
        ),
      ),
    );
  }

  Widget _buildCard(IptvProvider p) {
    return GestureDetector(
    onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => ProviderDetailsScreen(provider: p))),
    child: Card(
      margin: const EdgeInsets.only(bottom: 10),
      color: const Color(0xFF1A1A2E),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12), side: const BorderSide(color: Color(0xFF2A2A4E))),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(gradient: const LinearGradient(colors: [Color(0xFFFFC107), Color(0xFFFF8F00)]), borderRadius: BorderRadius.circular(8)),
              child: const Icon(Icons.tv, color: Colors.black, size: 18),
            ),
            const SizedBox(width: 12),
            Expanded(child: Text(p.name, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 15))),
            GestureDetector(
              onTap: () { FavoritesService.toggle(p.name); setState(() { _favorites.contains(p.name) ? _favorites.remove(p.name) : _favorites.add(p.name); }); },
              child: Icon(_favorites.contains(p.name) ? Icons.star : Icons.star_border, size: 18, color: Color(0xFFFFC107)),
            ),
            if (p.rating != null)
              GestureDetector(
                onTap: () async {
                  final query = Uri.encodeComponent(p.name + " review");
                  try { await launchUrlString("https://duckduckgo.com/?q=" + query); } catch (_) {}
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(color: const Color(0xFFFFC107).withOpacity(0.15), borderRadius: BorderRadius.circular(6)),
                  child: Row(mainAxisSize: MainAxisSize.min, children: [
                    Icon(Icons.star, size: 11, color: Color(0xFFFFC107)),
                    SizedBox(width: 3),
                    Text(p.rating!, style: TextStyle(color: Color(0xFFFFC107), fontSize: 11)),
                    SizedBox(width: 3),
                    Text("Reviews", style: TextStyle(color: Color(0xFFFFC107), fontSize: 8)),
                  ]),
                ),
              ),
          ]),
          if (p.description != null) ...[const SizedBox(height: 6), Text(p.description!, style: const TextStyle(color: Colors.grey, fontSize: 13))],
          Row(children: [
            Icon(Icons.info_outline, size: 10, color: Colors.grey),
            SizedBox(width: 4),
            Text("Source: " + p.source, style: TextStyle(color: Colors.grey, fontSize: 9)),
            Spacer(),
            Text("#" + (_displayList.indexOf(p) + 1).toString(), style: TextStyle(color: Color(0xFF2A2A4E), fontSize: 9)),
          ]),
          const SizedBox(height: 8),
          Row(children: [
            if (p.pricing != null) ...[Icon(Icons.attach_money, size: 14, color: Color(0xFF4CAF50)), SizedBox(width: 4), Text(p.pricing!, style: TextStyle(color: Color(0xFF4CAF50), fontSize: 12))],
            if (p.channels != null) ...[SizedBox(width: 12), Icon(Icons.list, size: 14, color: Color(0xFF2196F3)), SizedBox(width: 4), Text(p.channels!, style: TextStyle(color: Color(0xFF2196F3), fontSize: 12))],
            if (p.trialInfo != null) ...[SizedBox(width: 12), Icon(Icons.free_breakfast, size: 14, color: Color(0xFFFF9800)), SizedBox(width: 4), Text(p.trialInfo!, style: TextStyle(color: Color(0xFFFF9800), fontSize: 12))],
          const SizedBox(height: 6),
          GestureDetector(
            onTap: () async {
              final query = Uri.encodeComponent(p.name + " IPTV reviews");
              try { await launchUrlString("https://duckduckgo.com/?q=" + query); } catch (_) {}
            },
            child: Row(children: [
              Icon(Icons.star, size: 12, color: Color(0xFFFFC107).withOpacity(0.6)),
              SizedBox(width: 4),
              Text("Read " + (p.rating ?? "") + " reviews", style: TextStyle(color: Color(0xFFFFC107).withOpacity(0.7), fontSize: 11, decoration: TextDecoration.underline)),
            ]),
          ),
          ]),
          const SizedBox(height: 10),
          Row(children: [
            Icon(Icons.language, size: 12, color: Colors.grey),
            const SizedBox(width: 4),
            Expanded(child: Text(p.website, style: const TextStyle(color: Color(0xFF2196F3), fontSize: 11), overflow: TextOverflow.ellipsis)),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(border: Border.all(color: const Color(0xFFFFC107).withOpacity(0.4)), borderRadius: BorderRadius.circular(6)),
              child: p.website.contains('.') && !p.website.contains('example')
                  ? GestureDetector(
                      onTap: () async {
                        try { await launchUrlString(p.website); } catch (_) {}
                      },
                      child: const Row(mainAxisSize: MainAxisSize.min, children: [
                        Icon(Icons.open_in_new, size: 12, color: Color(0xFFFFC107)),
                        SizedBox(width: 4),
                        Text('Visit', style: TextStyle(color: Color(0xFFFFC107), fontSize: 11)),
                      ]),
                    )
                  : GestureDetector(
                        onTap: () async {
                          final query = Uri.encodeComponent(p.name + ' IPTV');
                          try { await launchUrlString('https://duckduckgo.com/?q=' + query); } catch (_) {}
                        },
                        child: Row(mainAxisSize: MainAxisSize.min, children: [
                          Icon(Icons.search, size: 12, color: Color(0xFFFFC107)),
                          SizedBox(width: 3),
                          Text('Search', style: TextStyle(color: Color(0xFFFFC107), fontSize: 10)),
                        ]),
                      ),
            ),
          ]),
        ]),
      ),
    ));
  }
}
