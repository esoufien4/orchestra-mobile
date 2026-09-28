import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'services/api.dart';
import 'widgets/sphere.dart';
import 'widgets/stats.dart';
import 'widgets/buttons.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  OrchestraApi.initTts();
  runApp(const MaterialApp(debugShowCheckedModeBanner: false, home: OrchestraScreen()));
}

class OrchestraScreen extends StatefulWidget {
  const OrchestraScreen({super.key});
  @override
  State<OrchestraScreen> createState() => _OrchestraScreenState();
}

class _OrchestraScreenState extends State<OrchestraScreen> with SingleTickerProviderStateMixin {
  Map<String, dynamic>? data;
  String transcript = "Touchez un agent pour lui donner un ordre";
  String activeAgent = "atlas";
  bool isSpeaking = false;
  late AnimationController _ctrl;
  Timer? _timer;
  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: const Duration(seconds: 4))..repeat();
    _refresh();
    _timer = Timer.periodic(const Duration(seconds: 3), (_) => _refresh());
    OrchestraApi.tts.setStartHandler(() => setState(() => isSpeaking = true));
    OrchestraApi.tts.setCompletionHandler(() => setState(() => isSpeaking = false));
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
      OrchestraApi.speak(speech);
    }
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
        title: Row(
          children: [
            Container(width: 8, height: 8, decoration: BoxDecoration(color: isOnline ? const Color(0xFF10B981) : Colors.red, shape: BoxShape.circle)),
            const SizedBox(width: 8),
            Text('OPTIRADAR ORCHESTRA', style: GoogleFonts.cinzel(fontSize: 14, fontWeight: FontWeight.bold, color: const Color(0xFFFBBF24))),
          ],
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            buildStatBar(data, isOnline),
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
            buildAgentButtons(_order),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
