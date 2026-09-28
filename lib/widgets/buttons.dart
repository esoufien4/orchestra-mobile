import 'package:flutter/material.dart';

Widget buildAgentButtons(Function(String, String) onOrder) {
  Widget btn(String label, String cmd, String target) => Padding(
    padding: const EdgeInsets.only(right: 8),
    child: ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFF0E131F),
        foregroundColor: Colors.white,
        side: const BorderSide(color: Color(0xFF1E293B)),
        shape: const StadiumBorder(),
      ),
      onPressed: () => onOrder(cmd, target),
      child: Text(label, style: const TextStyle(fontSize: 12)),
    ),
  );

  return SingleChildScrollView(
    scrollDirection: Axis.horizontal,
    padding: const EdgeInsets.symmetric(horizontal: 16),
    child: Row(
      children: [
        btn('👑 Atlas', 'Atlas quel est le statut', 'atlas'),
        btn('🔍 Cipher', 'Cipher cherche des SaaS', 'cipher'),
        btn('⚖️ Vesper', 'Vesper donne le bilan financier', 'vesper'),
        btn('✍️ Aura', 'Aura prépare un article', 'aura'),
        btn('⚡ Nexus', 'Nexus statut des clics', 'nexus'),
      ],
    ),
  );
}
