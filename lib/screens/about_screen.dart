import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher_string.dart';

class Feature {
  final String name;
  final String description;
  final IconData icon;
  final Color color;
  final String howToUse;
  Feature(this.name, this.description, this.icon, this.color, this.howToUse);
}

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  static const features = [
    Feature('150+ Providers', 'Browse a large directory of IPTV providers', Icons.live_tv, Color(0xFFFFC107),
      'Open the app and scroll through the list. Use the search bar to find specific providers. Tap any provider card to see full details.'),
    Feature('Search', 'Find providers by name or keyword', Icons.search, Color(0xFF2196F3),
      'Tap the search bar at the top of the home screen. Type a provider name or keyword. Results update as you type.'),
    Feature('Favorites', 'Star providers for quick access', Icons.star, Color(0xFFFFC107),
      'Tap the star icon on any provider card to favorite it. Tap the "Favorites" button at the top to show only your starred providers.'),
    Feature('Sort', 'Order by Name, Price, or Channels', Icons.sort, Color(0xFF4CAF50),
      'Tap the sort dropdown at the top of the list. Choose Name, Price, or Channels to reorder the list.'),
    Feature('Categories', 'Filter by Sports, Movies, 4K, and more', Icons.category, Color(0xFF9C27B0),
      'Scroll through the category chips at the top. Tap any category (Sports, Movies, 4K, etc.) to filter providers.'),
    Feature('Provider Details', 'View full info about any provider', Icons.info_outline, Color(0xFFFF9800),
      'Tap any provider card to open the details screen. See pricing, channels, trial info, and website.'),
    Feature('User Notes', 'Add private notes to any provider', Icons.edit_note, Color(0xFFFFC107),
      'Open a provider details screen. Tap the notes icon (top-right) or the "My Notes" section. Type your note and tap Save.'),
    Feature('Visit Website', 'Open provider website directly', Icons.open_in_new, Color(0xFFFFC107),
      'Open a provider details screen. Tap the "Visit Website" button to open their site in your browser.'),
    Feature('Search Reviews', 'Find user reviews on the web', Icons.star, Color(0xFF2196F3),
      'Open a provider details screen. Tap "Search Reviews" to search DuckDuckGo for user reviews of that provider.'),
    Feature('Update Checker', 'Know when a new version is available', Icons.system_update, Color(0xFF4CAF50),
      'The app automatically checks for updates on startup. If a new version is found, a dialog will appear with download options.'),
  ];

  static const tools = [
    ('Flutter 3.44.2', 'Cross-platform framework', 'https://flutter.dev', Icons.code, Color(0xFF00BCD4)),
    ('Dart 3.12.2', 'Programming language', 'https://dart.dev', Icons.terminal, Color(0xFF0175C2)),
    ('Android SDK 36', 'Android build tools', 'https://developer.android.com', Icons.android, Color(0xFF4CAF50)),
    ('SharedPreferences', 'Local data storage', 'https://pub.dev/packages/shared_preferences', Icons.storage, Color(0xFF9E9E9E)),
    ('url_launcher', 'Open web links', 'https://pub.dev/packages/url_launcher', Icons.link, Color(0xFF2196F3)),
    ('Visual Studio Code', 'Code editor', 'https://code.visualstudio.com', Icons.code, Color(0xFF007ACC)),
    ('pi Coding Agent', 'AI coding assistant', 'https://pi.ai', Icons.auto_awesome, Color(0xFF7C4DFF)),
    ('DuckDuckGo', 'Web search API', 'https://duckduckgo.com', Icons.search, Color(0xFFFF6D00)),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D0D1A),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1A1A2E),
        leading: IconButton(icon: const Icon(Icons.arrow_back, color: Color(0xFFFFC107)), onPressed: () => Navigator.pop(context)),
        title: const Text('About', style: TextStyle(color: Colors.white, fontSize: 18)),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Logo + Title
          Center(child: Column(children: [
            Container(
              width: 80, height: 80,
              decoration: BoxDecoration(gradient: const LinearGradient(colors: [Color(0xFFFFC107), Color(0xFFFF8F00)]), borderRadius: BorderRadius.circular(20)),
              child: const Icon(Icons.live_tv, size: 40, color: Colors.black),
            ),
            const SizedBox(height: 12),
            const Text('Discover Internet TV', style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold)),
            const Text('v1.0.0+18', style: TextStyle(color: Colors.grey, fontSize: 12)),
            const SizedBox(height: 4),
            const Text('Created by LittleLouis aka Louis Males', style: TextStyle(color: Color(0xFF8888AA), fontSize: 11)),
            const SizedBox(height: 20),
          ])),

          // Features section
          _sectionHeader(Icons.star, 'FEATURES', const Color(0xFFFFC107)),
          const SizedBox(height: 8),
          ...features.map((f) => _featureCard(context, f)),

          const SizedBox(height: 24),
          // Tools section
          _sectionHeader(Icons.code, 'BUILT WITH', const Color(0xFF2196F3)),
          const SizedBox(height: 8),
          ...tools.map((t) => _toolCard(context, t)),

          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _sectionHeader(IconData icon, String title, Color color) {
    return Row(children: [
      Icon(icon, size: 16, color: color),
      const SizedBox(width: 8),
      Text(title, style: TextStyle(color: color, fontSize: 13, letterSpacing: 2)),
      const SizedBox(width: 10),
      Expanded(child: Container(height: 0.5, color: const Color(0xFF2A2A4E))),
    ]);
  }

  Widget _featureCard(BuildContext context, Feature f) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      child: Material(
        color: const Color(0xFF1A1A2E),
        borderRadius: BorderRadius.circular(10),
        child: InkWell(
          borderRadius: BorderRadius.circular(10),
          onTap: () => _showHowToUse(context, f),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(color: f.color.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
                child: Icon(f.icon, size: 18, color: f.color),
              ),
              const SizedBox(width: 12),
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(f.name, style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w500)),
                Text(f.description, style: const TextStyle(color: Colors.grey, fontSize: 11)),
              ])),
              const Icon(Icons.chevron_right, color: Colors.grey, size: 18),
            ]),
          ),
        ),
      ),
    );
  }

  Widget _toolCard(BuildContext context, (String, String, String, IconData, Color) t) {
    return Container(
      margin: const EdgeInsets.only(bottom: 6),
      child: Material(
        color: const Color(0xFF1A1A2E),
        borderRadius: BorderRadius.circular(8),
        child: InkWell(
          borderRadius: BorderRadius.circular(8),
          onTap: () async {
            try { await launchUrlString(t.$3); } catch (_) {}
          },
          child: Padding(
            padding: const EdgeInsets.all(10),
            child: Row(children: [
              Icon(t.$4, size: 16, color: t.$5),
              const SizedBox(width: 10),
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(t.$1, style: const TextStyle(color: Colors.white, fontSize: 13)),
                Text(t.$2, style: const TextStyle(color: Colors.grey, fontSize: 10)),
              ])),
              const Icon(Icons.open_in_new, size: 12, color: Colors.grey),
            ]),
       
