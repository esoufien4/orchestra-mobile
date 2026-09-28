import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_tts/flutter_tts.dart';

class OrchestraApi {
  static const String serverUrl = "http://100.74.222.16:9090";
  static final FlutterTts tts = FlutterTts();

  static void initTts() {
    tts.setLanguage("fr-FR");
    tts.setPitch(0.95);
    tts.setSpeechRate(0.5);
  }

  static Future<Map<String, dynamic>?> fetchState() async {
    try {
      final res = await http.get(Uri.parse('$serverUrl/api/orchestra/state')).timeout(const Duration(seconds: 2));
      if (res.statusCode == 200) return json.decode(res.body);
    } catch (_) {}
    return null;
  }

  static Future<Map<String, dynamic>?> sendCommand(String text) async {
    try {
      final res = await http.post(
        Uri.parse('$serverUrl/api/orchestra/voice-dispatch'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'command': text}),
      ).timeout(const Duration(seconds: 4));
      if (res.statusCode == 200) return json.decode(res.body);
    } catch (_) {}
    return null;
  }

  static Future<void> speak(String text) async {
    await tts.speak(text);
  }
}
