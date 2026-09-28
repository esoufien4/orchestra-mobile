import 'package:flutter/material.dart';

Widget buildTopBar(Map<String, dynamic>? data, bool isOnline) {
  final sys = data?['system'] ?? {};
  final prod = data?['production'] ?? {};
  return Container(
    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
    color: const Color(0xFF0E131F),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(isOnline ? "HOST: R420 OK" : "HOST: OFFLINE",
            style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold,
                color: isOnline ? const Color(0xFF10B981) : Colors.red)),
        Text("CPU: ${sys['cpu'] ?? '--'}%", style: const TextStyle(fontSize: 11, color: Colors.white70)),
        Text("CLICS: ${prod['total_clicks'] ?? '3'}", style: const TextStyle(fontSize: 11, color: Colors.white70)),
        Text("GAINS: \$${prod['revenue_usd'] ?? '1525'}",
            style: const TextStyle(fontSize: 11, color: Color(0xFF10B981), fontWeight: FontWeight.bold)),
      ],
    ),
  );
}
