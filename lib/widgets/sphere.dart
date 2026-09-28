import 'dart:math' as math;
import 'package:flutter/material.dart';

class SoundWaveSpherePainter extends CustomPainter {
  final double progress;
  final Color agentColor;
  final bool isSpeaking;

  SoundWaveSpherePainter({required this.progress, required this.agentColor, required this.isSpeaking});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2.2;
    const numRings = 16;
    final amp = isSpeaking ? 2.2 : 1.0;

    for (int i = 0; i < numRings; i++) {
      final phi = -math.pi / 2 + (i / numRings) * math.pi;
      final ringRadius = math.cos(phi) * radius;
      final yOffset = math.sin(phi) * radius * 0.6;

      final paint = Paint()
        ..color = agentColor.withOpacity(0.35 + ((math.sin(phi) + 1) / 4))
        ..style = PaintingStyle.stroke
        ..strokeWidth = isSpeaking ? 1.8 : 1.2;

      final path = Path();
      const points = 32;
      for (int j = 0; j <= points; j++) {
        final theta = (j / points) * math.pi * 2;
        final wave = math.sin(theta * 5 + progress * math.pi * 2 + i * 0.4) * (5 * amp);
        final r = ringRadius + wave;
        final x = center.dx + math.cos(theta) * r;
        final y = center.dy + yOffset + math.sin(theta) * (r * 0.35);
        if (j == 0) path.moveTo(x, y); else path.lineTo(x, y);
      }
      path.close();
      canvas.drawPath(path, paint);
    }
  }

  @override
  bool shouldRepaint(covariant SoundWaveSpherePainter oldDelegate) => true;
}
