import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class OnboardingScreen extends StatefulWidget {
  final Widget home;
  static const String _key = 'onboarding_done';

  static Future<bool> shouldShow() async {
    final prefs = await SharedPreferences.getInstance();
    return !(prefs.getBool(_key) ?? false);
  }

  static Future<void> markDone() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_key, true);
  }

  const OnboardingScreen({super.key, required this.home});
  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _ctrl = PageController();
  int _page = 0;

  final _pages = [
    _Page(Icons.live_tv, 'Discover Internet TV', 'Browse 150+ IPTV providers.\nSearch, sort, and find the perfect\nstreaming service for your needs.', const Color(0xFFFFC107)),
    _Page(Icons.search, 'Search & Browse', 'Search for any provider.\nSort by Name, Price, or Channels.\nFilter by Favorites or All.', const Color(0xFF2196F3)),
    _Page(Icons.star, 'Favorites & Notes', 'Star your favorite providers.\nAdd private notes to each one.\nQuick access anytime.', const Color(0xFFFFC107)),
    _Page(Icons.thumb_up, 'Get Started!', 'Tap any provider to see details.\nVisit websites, read reviews,\nand find your ideal IPTV service!', const Color(0xFF4CAF50)),
  ];

  @override
  void dispose() { _ctrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D0D1A),
      body: SafeArea(
        child: Column(children: [
          Align(
            alignment: Alignment.topRight,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: GestureDetector(
                onTap: () async { await OnboardingScreen.markDone(); Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => widget.home)); },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(border: Border.all(color: const Color(0xFF2A2A4E)), borderRadius: BorderRadius.circular(8)),
                  child: const Text('SKIP', style: TextStyle(color: Colors.grey, fontSize: 11, letterSpacing: 2)),
                ),
              ),
            ),
          ),
          Expanded(
            child: PageView(
              controller: _ctrl,
              onPageChanged: (i) => setState(() => _page = i),
              children: _pages.map((p) => Padding(
                padding: const EdgeInsets.symmetric(horizontal: 40),
                child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(color: p.color.withOpacity(0.1), shape: BoxShape.circle, border: Border.all(color: p.color.withOpacity(0.2))),
                    child: Icon(p.icon, color: p.color, size: 56),
                  ),
                  const SizedBox(height: 32),
                  Text(p.title, style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold, letterSpacing: 1), textAlign: TextAlign.center),
                  const SizedBox(height: 16),
                  Text(p.desc, style: const TextStyle(color: Color(0xFF8888AA), fontSize: 14, height: 1.5), textAlign: TextAlign.center),
                ]),
              )).toList(),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(24),
            child: Column(children: [
              Row(mainAxisAlignment: MainAxisAlignment.center, children:
                List.generate(_pages.length, (i) => AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  width: _page == i ? 24 : 8, height: 8,
                  decoration: BoxDecoration(color: _page == i ? _pages[_page].color : const Color(0xFF2A2A4E), borderRadius: BorderRadius.circular(4)),
                )),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity, height: 50,
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(colors: [_pages[_page].color, _pages[_page].color.withOpacity(0.6)]),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: ElevatedButton(
                    onPressed: () async {
                      if (_page < _pages.length - 1) {
                        _ctrl.nextPage(duration: const Duration(milliseconds: 300), curve: Curves.easeOut);
                      } else {
                        await OnboardingScreen.markDone();
                        Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => widget.home));
                      }
                    },
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.transparent, shadowColor: Colors.transparent, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                    child: Text(_page < _pages.length - 1 ? 'NEXT' : 'GET STARTED', style: const TextStyle(color: Colors.black, fontSize: 14, fontWeight: FontWeight.w600, letterSpacing: 2)),
                  ),
                ),
              ),
            ]),
          ),
        ]),
      ),
    );
  }
}

class _Page {
  final IconData icon;
  final String title;
  final String desc;
  final Color color;
  _Page(this.icon, this.title, this.desc, this.color);
}
