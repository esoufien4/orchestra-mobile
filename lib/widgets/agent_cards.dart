import 'package:flutter/material.dart';

Widget buildAgentCards(String activeAgent, Function(String) onSelect) {
  final agents = [
    {'id': 'atlas', 'name': '👑 ATLAS', 'color': Color(0xFFFBBF24)},
    {'id': 'cipher', 'name': '🔍 CIPHER', 'color': Color(0xFF06B6D4)},
    {'id': 'vesper', 'name': '⚖️ VESPER', 'color': Color(0xFF10B981)},
    {'id': 'aura', 'name': '✍️ AURA', 'color': Color(0xFFC084FC)},
    {'id': 'nexus', 'name': '⚡ NEXUS', 'color': Color(0xFF3B82F6)},
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
          padding: const EdgeInsets.only(right: 6),
          child: FilterChip(
            selected: isSel,
            label: Text(ag['name'] as String, style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: isSel ? Colors.black : Colors.white70)),
            backgroundColor: const Color(0xFF0E131F),
            selectedColor: ag['color'] as Color,
            side: BorderSide(color: isSel ? (ag['color'] as Color) : const Color(0xFF1E293B)),
            onSelected: (_) => onSelect(ag['id'] as String),
          ),
        );
      }).toList(),
    ),
  );
}
