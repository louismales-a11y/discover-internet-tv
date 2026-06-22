// Run this file to generate launcher icons
// flutter run lib/logo_generator.dart
import 'package:flutter/material.dart';
import 'dart:ui' as ui;
import 'dart:typed_data';
import 'dart:io';
import 'package:flutter/services.dart';

void main() => runApp(const LogoGenerator());

class LogoGenerator extends StatelessWidget {
  const LogoGenerator({super.key});
  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: LogoPage(),
    );
  }
}

class LogoPage extends StatelessWidget {
  const LogoPage({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1A1A2E),
      body: Center(
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          Container(
            width: 200, height: 200,
            decoration: BoxDecoration(
              gradient: const LinearGradient(colors: [Color(0xFFFFC107), Color(0xFFFF8F00)]),
              borderRadius: BorderRadius.circular(40),
              boxShadow: [BoxShadow(color: Color(0xFFFFC107).withOpacity(0.4), blurRadius: 20, spreadRadius: 5)],
            ),
            child: const Icon(Icons.live_tv, size: 100, color: Colors.black),
          ),
          const SizedBox(height: 20),
          const Text('Discover', style: TextStyle(color: Color(0xFFFFC107), fontSize: 28, fontWeight: FontWeight.bold, letterSpacing: 2)),
          const Text('Internet TV', style: TextStyle(color: Color(0xFF2196F3), fontSize: 16, letterSpacing: 4)),
          const SizedBox(height: 30),
          const Text('Screenshot this screen', style: TextStyle(color: Colors.grey, fontSize: 12)),
          const Text('Then crop to 1024x1024', style: TextStyle(color: Colors.grey, fontSize: 12)),
        ]),
      ),
    );
  }
}
