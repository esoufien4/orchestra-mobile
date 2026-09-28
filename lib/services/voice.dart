import 'package:flutter_tts/flutter_tts.dart';
import 'package:speech_to_text/speech_to_text.dart';

class VoiceEngine {
  static final FlutterTts tts = FlutterTts();
  static final SpeechToText speech = SpeechToText();
  static String debugStatus = "Init audio...";

  static Future<void> init(Function() onUpdate) async {
    try {
      await tts.setLanguage("fr-FR");
      await tts.setPitch(0.95);
      await tts.setSpeechRate(0.5);
      await tts.setVolume(1.0);
      
      bool sttAvailable = await speech.initialize(
        onError: (e) { debugStatus = "Erreur Micro: ${e.errorMsg}"; onUpdate(); },
        onStatus: (s) { debugStatus = "Micro statut: $s"; onUpdate(); }
      );
      
      debugStatus = "TTS Prêt · Micro: ${sttAvailable ? 'Actif' : 'Bloqué'}";
      onUpdate();
    } catch (e) {
      debugStatus = "Erreur init voice: $e";
      onUpdate();
    }
  }

  static Future<void> speak(String text) async {
    await tts.stop();
    await tts.speak(text);
  }
}
