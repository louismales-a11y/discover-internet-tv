import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher_string.dart';
import 'dart:math';
import '../models/iptv_provider.dart';
import '../services/notes_service.dart';

class ProviderDetailsScreen extends StatefulWidget {
  final IptvProvider provider;
  const ProviderDetailsScreen({super.key, required this.provider});

  @override
  State<ProviderDetailsScreen> createState() => _ProviderDetailsScreenState();
}

class _ProviderDetailsScreenState extends State<ProviderDetailsScreen> {
  String? _note;
  bool _loadingNote = true;

  @override
  void initState() {
    super.initState();
    _loadNote();
  }

  Future<void> _loadNote() async {
    final n = await NotesService.getNote(widget.provider.name);
    if (mounted) setState(() { _note = n; _loadingNote = false; });
  }

  Future<void> _editNote() async {
    final ctrl = TextEditingController(text: _note ?? '');
    final result = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1A1A2E),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16), side: const BorderSide(color: Color(0xFF2A2A4E))),
        title: const Text('My Notes', style: TextStyle(color: Color(0xFFFFC107))),
        content: TextField(
          controller: ctrl,
          maxLines: 5,
          style: const TextStyle(color: Colors.white),
          decoration: InputDecoration(
            hintText: 'Add your notes about this provider...',
            filled: true, fillColor: const Color(0xFF0D0D1A),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none),
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel', style: TextStyle(color: Colors.grey))),
          TextButton(onPressed: () => Navigator.pop(ctx, ctrl.text), child: const Text('Save', style: TextStyle(color: Color(0xFFFFC107)))),
        ],
      ),
    );
    if (result != null) {
      await NotesService.setNote(widget.provider.name, result);
      await _loadNote();
    }
  }

  @override
  Widget build(BuildContext context) {
    final p = widget.provider;
    final hasNote = _note != null && _note!.isNotEmpty;

    return Scaffold(
      backgroundColor: const Color(0xFF0D0D1A),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1A1A2E),
        leading: IconButton(icon: const Icon(Icons.arrow_back, color: Color(0xFFFFC107)), onPressed: () => Navigator.pop(context)),
        title: Text(p.name, style: const TextStyle(color: Colors.white, fontSize: 16)),
        actions: [
          IconButton(
            icon: Icon(hasNote ? Icons.sticky_note_2 : Icons.sticky_note_2_outlined, color: hasNote ? Color(0xFFFFC107) : Colors.grey),
            onPressed: _editNote,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Center(child: Column(children: [
            Container(
              width: 100, height: 100,
              decoration: BoxDecoration(gradient: const LinearGradient(colors: [Color(0xFFFFC107), Color(0xFFFF8F00)]), borderRadius: BorderRadius.circular(24)),
              child: const Icon(Icons.live_tv, size: 50, color: Colors.black),
            ),
            const SizedBox(height: 16),
            Text(p.name, style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            Row(mainAxisAlignment: MainAxisAlignment.center, children: [
              const Icon(Icons.star, size: 18, color: Color(0xFFFFC107)),
              const SizedBox(width: 4),
              Text(p.rating ?? "N/A", style: const TextStyle(color: Color(0xFFFFC107), fontSize: 16)),
              const SizedBox(width: 8),
              Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2), decoration: BoxDecoration(color: const Color(0xFFFFC107).withOpacity(0.15), borderRadius: BorderRadius.circular(4)),
                child: Text(p.source, style: const TextStyle(color: Color(0xFFFFC107), fontSize: 10))),
            ]),
          ])),
          const SizedBox(height: 24),

          // Notes section
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: hasNote ? const Color(0xFFFFC107).withOpacity(0.05) : const Color(0xFF1A1A2E),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: hasNote ? const Color(0xFFFFC107).withOpacity(0.3) : const Color(0xFF2A2A4E)),
            ),
            child: InkWell(
              borderRadius: BorderRadius.circular(12),
              onTap: _editNote,
              child: Row(children: [
                Icon(Icons.edit_note, size: 20, color: hasNote ? const Color(0xFFFFC107) : Colors.grey),
                const SizedBox(width: 10),
                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text('My Notes', style: TextStyle(color: hasNote ? const Color(0xFFFFC107) : Colors.grey, fontSize: 11)),
                  const SizedBox(height: 2),
                  Text(_loadingNote ? 'Loading...' : (hasNote ? _note! : 'Tap to add a note...'), style: TextStyle(color: hasNote ? Colors.white : Colors.grey, fontSize: 13)),
                ])),
                Icon(Icons.edit, size: 14, color: Colors.grey),
              ]),
            ),
          ),
          const SizedBox(height: 12),

          _ic(Icons.description, 'About', p.description ?? 'No description available'),
          const SizedBox(height: 12),
          _ic(Icons.attach_money, 'Pricing', p.pricing ?? 'Contact for pricing'),
          const SizedBox(height: 12),
          _ic(Icons.list, 'Channels', p.channels ?? 'N/A'),
          const SizedBox(height: 12),
          _ic(Icons.free_breakfast, 'Trial', p.trialInfo ?? 'Check website'),
          const SizedBox(height: 12),
          _ic(Icons.language, 'Website', p.website.isNotEmpty ? p.website : 'Not listed'),
          const SizedBox(height: 24),

          Row(children: [
            Expanded(child: _btn(Icons.open_in_new, 'Visit Website', const Color(0xFFFFC107), () async {
              if (p.website.contains('.')) { try { await launchUrlString(p.website); } catch (_) {} }
            })),
            const SizedBox(width: 12),
            Expanded(child: _btn(Icons.search, 'Search Reviews', const Color(0xFF2196F3), () async {
              final q = Uri.encodeComponent('${p.name} IPTV reviews');
              try { await launchUrlString('https://duckduckgo.com/?q=$q'); } catch (_) {}
            })),
          ]),
        ]),
      ),
    );
  }

  Widget _ic(IconData icon, String label, String value) {
    return Container(
      width: double.infinity, padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(color: const Color(0xFF1A1A2E), borderRadius: BorderRadius.circular(12), border: Border.all(color: const Color(0xFF2A2A4E))),
      child: Row(children: [
        Container(padding: const EdgeInsets.all(8), decoration: BoxDecoration(color: const Color(0xFFFFC107).withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
          child: Icon(icon, size: 18, color: const Color(0xFFFFC107))),
        const SizedBox(width: 12),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(label, style: const TextStyle(color: Colors.grey, fontSize: 11)),
          const SizedBox(height: 2),
          Text(value, style: const TextStyle(color: Colors.white, fontSize: 14)),
        ])),
      ]),
    );
  }

  Widget _btn(IconData icon, String label, Color color, VoidCallback onTap) {
    return Container(
      decoration: BoxDecoration(border: Border.all(color: color.withOpacity(0.4)), borderRadius: BorderRadius.circular(10)),
      chil
      child: Material(color: Colors.transparent, child: InkWell(
        borderRadius: BorderRadius.circular(10), onTap: onTap,
        child: Padding(padding: const EdgeInsets.symmetric(vertical: 12), child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
          Icon(icon, size: 16, color: color), const SizedBox(width: 6), Text(label, style: TextStyle(color: color, fontSize: 13)),
        ])),
      )),
    );
  }
}
