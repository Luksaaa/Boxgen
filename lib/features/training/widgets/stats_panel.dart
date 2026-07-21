import 'package:flutter/material.dart';

import '../../../app/app_colors.dart';
import '../../../models/generated_drill.dart';
import '../../../utils/format_duration.dart';
import 'training_controls.dart';

class StatsPanel extends StatelessWidget {
  const StatsPanel({
    super.key,
    required this.generatedCount,
    required this.sessionSeconds,
    required this.pauseCount,
    required this.history,
  });

  final int generatedCount;
  final int sessionSeconds;
  final int pauseCount;
  final List<GeneratedDrill> history;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: const BoxDecoration(
        color: AppColors.surfaceHigh,
        borderRadius: BorderRadius.all(Radius.circular(8)),
      ),
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const SectionTitle(icon: Icons.insights_rounded, title: 'Session'),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: MetricTile(label: 'Generated', value: '$generatedCount'),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: MetricTile(label: 'Pauses', value: '$pauseCount'),
              ),
            ],
          ),
          const SizedBox(height: 10),
          MetricTile(
            label: 'Training time',
            value: formatDuration(sessionSeconds),
          ),
          const SizedBox(height: 20),
          const SectionTitle(icon: Icons.history_rounded, title: 'History'),
          const SizedBox(height: 12),
          if (history.isEmpty)
            const _EmptyHistory()
          else
            ...history.map((drill) => _HistoryRow(drill: drill)),
        ],
      ),
    );
  }
}

class _HistoryRow extends StatelessWidget {
  const _HistoryRow({required this.drill});

  final GeneratedDrill drill;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: const BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.all(Radius.circular(8)),
      ),
      child: Row(
        children: [
          const Icon(Icons.sports_mma_rounded, color: AppColors.primary),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              drill.display,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontWeight: FontWeight.w800),
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyHistory extends StatelessWidget {
  const _EmptyHistory();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: const BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.all(Radius.circular(8)),
      ),
      child: const Text(
        'History appears after the next generated combo.',
        style: TextStyle(
          color: AppColors.textMuted,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}
