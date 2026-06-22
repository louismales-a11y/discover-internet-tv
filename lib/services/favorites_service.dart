import 'package:shared_preferences/shared_preferences.dart';

class FavoritesService {
  static const String _key = 'favorite_providers';

  static Future<Set<String>> getFavorites() async {
    final prefs = await SharedPreferences.getInstance();
    return (prefs.getStringList(_key) ?? []).toSet();
  }

  static Future<void> toggle(String name) async {
    final prefs = await SharedPreferences.getInstance();
    final list = prefs.getStringList(_key) ?? [];
    if (list.contains(name)) {
      list.remove(name);
    } else {
      list.add(name);
    }
    await prefs.setStringList(_key, list);
  }

  static Future<bool> isFavorite(String name) async {
    final favs = await getFavorites();
    return favs.contains(name);
  }
}
