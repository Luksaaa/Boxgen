import 'package:flutter/material.dart';

enum TrainingMode {
  normal(
    label: 'Normal',
    description: 'Random punches',
    optimalSeconds: 10,
    icon: Icons.shuffle_rounded,
  ),
  combo(
    label: 'Combo',
    description: 'Realistic boxing',
    optimalSeconds: 12,
    icon: Icons.sports_mma_rounded,
  ),
  commonDefense(
    label: 'Combo + Def',
    description: 'Common coach cues',
    optimalSeconds: 18,
    icon: Icons.shield_rounded,
  ),
  tacticalDefense(
    label: 'Tactical',
    description: 'All defensive cues',
    optimalSeconds: 22,
    icon: Icons.psychology_alt_rounded,
  );

  const TrainingMode({
    required this.label,
    required this.description,
    required this.optimalSeconds,
    required this.icon,
  });

  final String label;
  final String description;
  final int optimalSeconds;
  final IconData icon;
}
