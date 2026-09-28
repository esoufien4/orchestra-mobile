import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'services/api.dart';
import 'services/voice.dart';
import 'widgets/sphere.dart';
import 'widgets/top_bar.dart';
import 'widgets/agent_bar.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MaterialApp(debugShowCheckedModeBanner: false, home: OrchestraApp()));
}

class OrchestraApp extends StatefulWidget {
  const OrchestraApp({super.key});
  @override
  State<OrchestraApp> createState() => _OrchestraAppState();
}

class _OrchestraAppState extends State<OrchestraApp> with SingleTickerProviderStateMixin {
  Map<String, dynamic>? data;
  String transcript = "Touchez le micro pour parler ou un agent ci-dessus";
  String activeAgent = "atlas";
  bool isListening = false;
  bool isSpeaking = false;
  late AnimationController _ctrl;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: const Duration(seconds: 4))..repeat();
    VoiceEngine.init(() => setState(() {}));
    _refresh();
    _timer = Timer.periodic(const Duration(seconds: 3), (_) => _refresh());
    VoiceEngine.tts.setStartHandler(() => setState(() => isSpeaking = true));
    VoiceEngine.tts.setCompletionHandler(() => setState(() => isSpeaking = false));
  }

  @override
  void dispose() {
    _ctrl.dispose();
    _timer?.cancel();
    super.dispose();
  }

  void _refresh() async {
    final res = await OrchestraApi.fetchState();
    if (res != null && mounted) setState(() => data = res);
  }

  void _order(String text, String target) async {
    HapticFeedback.mediumImpact();
    setState(() { transcript = "« $text »..."; activeAgent = target; });
    final res = await OrchestraApi.sendCommand(text);
    if (res != null && mounted) {
      final speech = res['speech'] ?? 'Ordre reçu.';
      setState(() { transcript = speech; activeAgent = res['target'] ?? target; });
      await VoiceEngine.speak(speech);
    }
  }

  void _toggleMic() async {
    if (isListening) {
      await VoiceEngine.speech.stop();
      setState(() => isListening = false);
      return;
    }
    setState(() => isListening = true);
    await VoiceEngine.speech.listen(
      localeId: "fr_FR",
      onResult: (val) {
        if (val.finalResult && val.recognizedWords.isNotEmpty) {
          setState(() => isListening = false);
          _order(val.recognizedWords, activeAgent);
        }
      },
    );
  }

  Color _getColor(String a) {
    if (a == 'cipher') return const Color(0xFF06B6D4);
    if (a == 'vesper') return const Color(0xFF10B981);
    if (a == 'aura') return const Color(0xFFC084FC);
    if (a == 'nexus') return const Color(0xFF3B82F6);
    return const Color(0xFFFBBF24);
  }

  @override
  Widget build(BuildContext context) {
    final isOnline = data != null;
    return Scaffold(
      backgroundColor: const Color(0xFF04060A),
      appBar: AppBar(
        backgroundColor: const Color(0xFF090D16),
        title: Text('OPTIRADAR ORCHESTRA', style: GoogleFonts.cinzel(fontSize: 14, fontWeight: FontWeight.bold, color: const Color(0xFFFBBF24))),
      ),
      body: SafeArea(
        child: Column(
          children: [
            buildTopBar(data, isOnline),
            buildSingleAgentBar(activeAgent, (id, cmd) => _order(cmd, id)),
            Expanded(
              child: Center(
                child: AnimatedBuilder(
                  animation: _ctrl,
                  builder: (_, __) => CustomPaint(
                    size: const Size(220, 220),
                    painter: SoundWaveSpherePainter(
                      progress: _ctrl.value,
                      agentColor: _getColor(activeAgent),
                      isSpeaking: isSpeaking,
                    ),
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Text(transcript, textAlign: TextAlign.center, style: const TextStyle(fontSize: 13, color: Color(0xFFE2E8F0), fontWeight: FontWeight.w500)),
            ),
            const SizedBox(height: 16),
            GestureDetector(
              onTap: _toggleMic,
              child: Container(
                width: 65, height: 65,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isListening ? Colors.red : const Color(0xFFD97706),
                  boxShadow: [BoxShadow(color: (isListening ? Colors.red : const Color(0xFFFBBF24)).withOpacity(0.4), blurRadius: 20, spreadRadius: 2)],
                ),
                child: Icon(isListening ? Icons.mic_off : Icons.mic, color: Colors.white, size: 32),
              ),
            ),
            const SizedBox(height: 12),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              color: const Color(0xFF0E131F),
              child: Text(
                "[DEBUG] ${VoiceEngine.debugStatus} · Host: ${isOnline ? 'Connecté (200)' : 'Erreur liaison'}",
                textAlign: TextAlign.center,
                style: GoogleFonts.jetBrainsMono(fontSize: 10, color: isOnline ? const Color(0xFF10B981) : Colors.amber),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
