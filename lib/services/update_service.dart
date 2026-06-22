import 'dart:convert';
import 'package:http/http.dart' as http;

class UpdateInfo {
  final String version;
  final int buildNumber;
  final String downloadUrl;
  final String notes;
  UpdateInfo({required this.version, required this.buildNumber, required this.downloadUrl, required this.notes});
  bool get isNewer {
    final current = _parseVersion('1.0.0+13');
    final remote = _parseVersion(version);
    if (remote == null) return false;
    if (current == null) return true;
    for (int i = 0; i < 3; i++) {
      if ((remote[i] ?? 0) > (current[i] ?? 0)) return true;
      if ((remote[i] ?? 0) < (current[i] ?? 0)) return false;
    }
    return buildNumber > 12;
  }
  List<int>? _parseVersion(String v) {
    final parts = v.split('+')[0].split('.').map((e) => int.tryParse(e)).toList();
    if (parts.any((p) => p == null)) return null;
    return parts.cast<int>();
  }
}

class UpdateService {
  static Future<UpdateInfo?> check() async {
    try {
      final res = await http.get(
        Uri.parse('https://raw.githubusercontent.com/louismales-a11y/discover-internet-tv/main/version.json'),
      ).timeout(const Duration(seconds: 8));
      if (res.statusCode == 200) {
        final d = jsonDecode(res.body);
        return UpdateInfo(
          version: d['version'] ?? '1.0.0',
          buildNumber: d['build'] ?? 0,
          downloadUrl: d['download_url'] ?? '',
          notes: d['notes'] ?? '',
        );
      }
    } catch (_) {}
    return null;
  }
}
