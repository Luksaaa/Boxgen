import 'package:flutter/material.dart';

import '../../../models/generated_drill.dart';
import '../../../models/training_mode.dart';
import '../../../utils/format_duration.dart';
import 'training_controls.dart';

class TrainingPanel extends StatelessWidget {
  const TrainingPanel({
    super.key,
    required this.currentDrill,
    required this.mode,
    required this.refreshSeconds,
    required this.secondsLeft,
    required this.isRunning,
    required this.isPaused,
    required this.generatedCount,
    required this.sessionSeconds,
    required this.onStart,
    required this.onPause,
    required this.onNext,
    required this.onStop,
  });

  final GeneratedDrill currentDrill;
  final TrainingMode mode;
  final int refreshSeconds;
  final int secondsLeft;
  final bool isRunning;
  final bool isPaused;
  final int generatedCount;
  final int sessionSeconds;
  final VoidCallback onStart;
  final VoidCallback onPause;
  final VoidCallback onNext;
  final VoidCallback onStop;

  @override
  Widget build(BuildContext context) {
    final progress = refreshSeconds == 0 ? 0.0 : secondsLeft / refreshSeconds;

    return DecoratedBox(
      decoration: const BoxDecoration(
        color: Color(0xFF160F14),
        borderRadius: BorderRadius.all(Radius.circular(8)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: const BoxDecoration(
                    color: Color(0xFF3D1F2B),
                    borderRadius: BorderRadius.all(Radius.circular(8)),
                  ),
                  child: Icon(mode.icon, color: const Color(0xFFFFB0CB)),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'BOXGEN',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFFFFB0CB),
                        ),
                      ),
                      Text(
                        mode.description,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
                TimerPill(secondsLeft: secondsLeft, isPaused: isPaused),
              ],
            ),
            const SizedBox(height: 18),
            Expanded(
              child: Container(
                decoration: const BoxDecoration(
                  color: Color(0xFF21151D),
                  borderRadius: BorderRadius.all(Radius.circular(8)),
                ),
                padding: const EdgeInsets.all(20),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      currentDrill.title,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: Color(0xFFBDAAB3),
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 18),
                    FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text(
                        currentDrill.display,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 54,
                          fontWeight: FontWeight.w900,
                          height: 1.05,
                        ),
                      ),
                    ),
                    if (currentDrill.cue.isNotEmpty) ...[
                      const SizedBox(height: 18),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 18,
                          vertical: 12,
                        ),
                        decoration: const BoxDecoration(
                          color: Color(0xFF43202D),
                          borderRadius: BorderRadius.all(Radius.circular(8)),
                        ),
                        child: Text(
                          currentDrill.cue,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            color: Color(0xFFFFD7E6),
                            fontSize: 20,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
            const SizedBox(height: 14),
            ClipRRect(
              borderRadius: const BorderRadius.all(Radius.circular(999)),
              child: LinearProgressIndicator(
                value: progress,
                minHeight: 8,
                backgroundColor: const Color(0xFF30212A),
                valueColor: const AlwaysStoppedAnimation(Color(0xFFFF9BC0)),
              ),
            ),
            const SizedBox(height: 14),
            Row(
              children: [
                Expanded(
                  child: PrimaryActionButton(
                    icon: isRunning && !isPaused
                        ? Icons.pause_rounded
                        : Icons.play_arrow_rounded,
                    label: isRunning && !isPaused ? 'Pause' : 'Start',
                    onPressed: isRunning ? onPause : onStart,
                  ),
                ),
                const SizedBox(width: 10),
                IconActionButton(
                  icon: Icons.skip_next_rounded,
                  tooltip: 'Next combo',
                  onPressed: onNext,
                ),
                const SizedBox(width: 10),
                IconActionButton(
                  icon: Icons.stop_rounded,
                  tooltip: 'Stop',
                  onPressed: onStop,
                ),
              ],
            ),
            const SizedBox(height: 14),
            Row(
              children: [
                Expanded(
                  child: MetricTile(label: 'Combos', value: '$generatedCount'),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: MetricTile(
                    label: 'Time',
                    value: formatDuration(sessionSeconds),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
