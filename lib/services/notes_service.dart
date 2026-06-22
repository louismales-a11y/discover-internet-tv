import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class NotesService {
  static const String _key = 'provider_notes';

  static Future<Map<String, String>> getAllNotes() async {
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getString(_key);
    if (data == null) return {};
    final decoded = jsonDecode(data) as Map<String, dynamic>;
    return decoded.map((k, v) => MapEntry(k, v as String));
  }

  static Future<String?> getNote(String providerName) async {
    final notes = await getAllNotes();
    return notes[providerName];
  }

  static Future<void> setNote(String providerName, String note) async {
    final notes = await getAllNotes();
    if (note.trim().isEmpty) {
      notes.remove(providerName);
    } else {
      notes[providerName] = note;
    }
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_key, jsonEncode(notes));
  }

  static Future<bool> hasNote(String providerName) async {
    final note = await getNote(providerName);
    return note != null && note.isNotEmpty;
  }
}
