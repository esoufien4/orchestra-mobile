import 'dart:async';
import 'dart:convert';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:google_fonts/google_fonts.dart';

void main() {
  runApp(const OrchestraApp());
}

class OrchestraApp extends StatelessWidget {
  const OrchestraApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'OptiRadar Orchestra',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF04060A),
        textTheme: GoogleFonts.interTextTheme(ThemeData.dark().textTheme),
      ),
      home: const WarRoomScreen(),
    );
  }
}

class WarRoomScreen extends StatefulWidget {
  const WarRoomScreen({super.key});

  @override
  State<WarRoomScreen> createState() => _WarRoomScreenState();
}

class _WarRoomScreenState extends State<WarRoomScreen> with SingleTickerProviderStateMixin {
  String serverUrl = "http://100.74.222.16:9090";
  Map<String, dynamic>? telemetry;
  bool isConnected = false;
  String vocalTranscript = "Touchez un agent ou envoyez un ordre vocal";
  String activeAgent = "atlas";
  late AnimationController _animController;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(vsync: this, duration: const Duration(seconds: 4))..repeat();
    fetchTelemetry();
    _timer = Timer.periodic(const Duration(seconds: 3), (_) => fetchTelemetry());
  }

  @override
  void dispose() {
    _animController.dispose();
    _timer?.cancel();
    super.dispose();
  }

  Future<void> fetchTelemetry() async {
    try {
      final res = await http.get(Uri.parse('$serverUrl/api/orchestra/state')).timeout(const Duration(seconds: 2));
      if (res.statusCode == 200) {
        setState(() {
          telemetry = json.decode(res.body);
          isConnected = true;
        });
      }
    } catch (_) {
      if (mounted) setState(() => isConnected = false);
    }
  }

  Future<void> sendCommand(String text, String targetAgent) async {
    setState(() {
      vocalTranscript = "Transmission : « $text »...";
      activeAgent = targetAgent;
    });
    try {
      final res = await http.post(
        Uri.parse('$serverUrl/api/orchestra/voice-dispatch'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'command': text}),
      );
      if (res.statusCode == 200) {
        final data = json.decode(res.body);
        setState(() {
          vocalTranscript = data['speech'] ?? 'Ordre reçu.';
          activeAgent = data['target'] ?? targetAgent;
        });
      }
    } catch (e) {
      setState(() => vocalTranscript = "Erreur de liaison avec le serveur R420.");
    }
  }

  @override
  Widget build(BuildContext context) {
    final sys = telemetry?['system'] ?? {};
    final prod = telemetry?['production'] ?? {};

    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF090D16),
        elevation: 0,
        title: Row(
          children: [
            Container(
              width: 8, height: 8,
              decoration: BoxDecoration(
                color: isConnected ? const Color(0xFF10B981) : Colors.red,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 8),
            Text('OPTIRADAR WAR ROOM', style: GoogleFonts.cinzel(fontSize: 14, fontWeight: FontWeight.bold, color: const Color(0xFFFBBF24))),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white70),
            onPressed: fetchTelemetry,
          )
        ],
      ),
      body: Column(
        children: [
          // 1. Barre Télémétrique Haute
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            color: const Color(0xFF0E131F),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildStat('CPU', '${sys['cpu'] ?? '--'}%'),
                _buildStat('RAM', '${sys['ram'] ?? '--'}%'),
                _buildStat('CLICS', '${prod['clicks'] ?? '3'}'),
                _buildStat('REVENUS', '\$${prod['revenue'] ?? '1525'}', color: const Color(0xFF10B981)),
              ],
            ),
          ),
          
          // 2. Sphère d'Ondes Sonores 3D (Custom Painter)
          Expanded(
            child: Center(
              child: AnimatedBuilder(
                animation: _animController,
                builder: (context, _) {
                  return CustomPaint(
                    size: const Size(240, 240),
                    painter: SoundWaveSpherePainter(
                      progress: _animController.value,
                      agentColor: _getAgentColor(activeAgent),
                    ),
                  );
                },
              ),
            ),
          ),

          // 3. Transcript Vocal
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Text(
              vocalTranscript,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 13, color: Color(0xFFE2E8F0), fontWeight: FontWeight.w500),
            ),
          ),
          const SizedBox(height: 16),

          // 4. Raccourcis Tactiles par Agent
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                _buildActionBtn('🔍 Cipher (Scout)', () => sendCommand('Cipher explore le web pour de nouveaux SaaS', 'cipher')),
                _buildActionBtn('⚖️ Vesper (Arbitre)', () => sendCommand('Vesper donne le rapport financier et scores', 'vesper')),
                _buildActionBtn('✍️ Aura (Rédactrice)', () => sendCommand('Aura rédige le prochain article', 'aura')),
                _buildActionBtn('⚡ Nexus (Tracking)', () => sendCommand('Nexus statut des clics et de la sentinelle', 'nexus')),
              ],
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildStat(String label, String val, {Color color = Colors.white}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: GoogleFonts.jetBrainsMono(fontSize: 10, color: Colors.white54)),
        Text(val, style: GoogleFonts.jetBrainsMono(fontSize: 13, fontWeight: FontWeight.bold, color: color)),
      ],
    );
  }

  Widget _buildActionBtn(String label, VoidCallback onTap) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: OutlinedButton(
        style: OutlinedButton.styleFrom(
          side: const BorderSide(color: Color(0xFF1E293B)),
          backgroundColor: const Color(0xFF0E131F),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        ),
        onPressed: onTap,
        child: Text(label, style: const TextStyle(color: Colors.white, fontSize: 12)),
      ),
    );
  }

  Color _getAgentColor(String agent) {
    switch (agent) {
      case 'cipher': return const Color(0xFF06B6D4);
      case 'vesper': return const Color(0xFF10B981);
      case 'aura': return const Color(0xFFC084FC);
      case 'nexus': return const Color(0xFF3B82F6);
      default: return const Color(0xFFFBBF24);
    }
  }
}

class SoundWaveSpherePainter extends CustomPainter {
  final double progress;
  final Color agentColor;

  SoundWaveSpherePainter({required this.progress, required this.agentColor});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2.2;
    const numRings = 16;

    for (int i = 0; i < numRings; i++) {
      final phi = -math.pi / 2 + (i / numRings) * math.pi;
      final ringRadius = math.cos(phi) * radius;
      final yOffset = math.sin(phi) * radius * 0.6;

      final paint = Paint()
        ..color = agentColor.withOpacity(0.35 + ((math.sin(phi) + 1) / 4))
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.3;

      final path = Path();
      const points = 36;
      for (int j = 0; j <= points; j++) {
        final theta = (j / points) * math.pi * 2;
        final wave = math.sin(theta * 5 + progress * math.pi * 2 + i * 0.4) * 6;
        final r = ringRadius + wave;
        final x = center.dx + math.cos(theta) * r;
        final y = center.dy + yOffset + math.sin(theta) * (r * 0.35);

        if (j == 0) {
          path.moveTo(x, y);
        } else {
          path.lineTo(x, y);
        }
      }
      path.close();
      canvas.drawPath(path, paint);
    }
  }

  @override
  bool shouldRepaint(covariant SoundWaveSpherePainter oldDelegate) => true;
}
