import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class ProviderNotes {
  String text;
  bool trialUsed;
  String trialEmail;
  double rating;
  DateTime? lastUpdated;

  ProviderNotes({
    this.text = '',
    this.trialUsed = false,
    this.trialEmail = '',
    this.rating = 0,
    this.lastUpdated,
  });

  Map<String, dynamic> toJson() => {
    'text': text, 'trialUsed': trialUsed,
    'trialEmail': trialEmail, 'rating': rating,
    'lastUpdated': lastUpdated?.toIso8601String(),
  };

  factory ProviderNotes.fromJson(Map<String, dynamic> j) => ProviderNotes(
    text: j['text'] as String? ?? '',
    trialUsed: j['trialUsed'] as bool? ?? false,
    trialEmail: j['trialEmail'] as String? ?? '',
    rating: (j['rating'] as num?)?.toDouble() ?? 0,
    lastUpdated: j['lastUpdated'] != null ? DateTime.tryParse(j['lastUpdated'] as String) : null,
  );
}

class NotesService {
  static const String _key = 'provider_notes_v2';

  static Future<Map<String, ProviderNotes>> getAll() async {
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getString(_key);
    if (data == null) return {};
    final decoded = jsonDecode(data) as Map<String, dynamic>;
    return decoded.map((k, v) => MapEntry(k, ProviderNotes.fromJson(v as Map<String, dynamic>)));
  }

  static Future<ProviderNotes?> get(String name) async {
    final all = await getAll();
    return all[name];
  }

  static Future<void> save(String name, ProviderNotes notes) async {
    notes.lastUpdated = DateTime.now();
    final all = await getAll();
    all[name] = notes;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_key, jsonEncode(all.map((k, v) => MapEntry(k, v.toJson()))));
  }
}
