import 'package:flutter/material.dart';

Widget buildSingleAgentBar(String activeAgent, Function(String, String) onSelect) {
  final agents = [
    {'id': 'atlas', 'name': '👑 ATLAS', 'color': const Color(0xFFFBBF24), 'cmd': 'Atlas quel est le statut général'},
    {'id': 'cipher', 'name': '🔍 CIPHER', 'color': const Color(0xFF06B6D4), 'cmd': 'Cipher explore de nouveaux SaaS'},
    {'id': 'vesper', 'name': '⚖️ VESPER', 'color': const Color(0xFF10B981), 'cmd': 'Vesper donne le bilan financier'},
    {'id': 'aura', 'name': '✍️ AURA', 'color': const Color(0xFFC084FC), 'cmd': 'Aura prépare le prochain article'},
    {'id': 'nexus', 'name': '⚡ NEXUS', 'color': const Color(0xFF3B82F6), 'cmd': 'Nexus statut des clics'},
  ];

  return Container(
    height: 48,
    margin: const EdgeInsets.symmetric(vertical: 8),
    child: ListView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      children: agents.map((ag) {
        final isSel = (activeAgent == ag['id']);
        return Padding(
          padding: const EdgeInsets.only(right: 8),
          child: ActionChip(
            label: Text(ag['name'] as String, style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: isSel ? Colors.black : Colors.white)),
            backgroundColor: isSel ? (ag['color'] as Color) : const Color(0xFF0E131F),
            side: BorderSide(color: ag['color'] as Color),
            onPressed: () => onSelect(ag['id'] as String, ag['cmd'] as String),
          ),
        );
      }).toList(),
    ),
  );
}
