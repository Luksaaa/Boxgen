import 'package:flutter/material.dart';

import '../../../app/app_colors.dart';
import '../../../models/generated_drill.dart';
import 'training_controls.dart';

class TrainingPanel extends StatelessWidget {
  const TrainingPanel({
    super.key,
    required this.currentDrill,
    required this.refreshSeconds,
    required this.secondsLeft,
    required this.isRunning,
    required this.isPaused,
    required this.onStart,
    required this.onPause,
    required this.onNext,
    required this.onStop,
    required this.onReset,
  });

  final GeneratedDrill currentDrill;
  final int refreshSeconds;
  final int secondsLeft;
  final bool isRunning;
  final bool isPaused;
  final VoidCallback onStart;
  final VoidCallback onPause;
  final VoidCallback onNext;
  final VoidCallback onStop;
  final VoidCallback onReset;

  @override
  Widget build(BuildContext context) {
    final progress = refreshSeconds == 0 ? 0.0 : secondsLeft / refreshSeconds;

    return DecoratedBox(
      decoration: const BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.all(Radius.circular(8)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                const Spacer(),
                TimerPill(secondsLeft: secondsLeft, isPaused: isPaused),
              ],
            ),
            const SizedBox(height: 18),
            Expanded(
              child: Container(
                decoration: const BoxDecoration(
                  color: AppColors.surfaceHigh,
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
                        color: AppColors.textMuted,
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
                          color: AppColors.cardActive,
                          borderRadius: BorderRadius.all(Radius.circular(8)),
                        ),
                        child: Text(
                          currentDrill.cue,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            color: AppColors.text,
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
                backgroundColor: AppColors.progressTrack,
                valueColor: const AlwaysStoppedAnimation(AppColors.primary),
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
                  icon: Icons.restart_alt_rounded,
                  tooltip: 'Reset session',
                  onPressed: onReset,
                ),
                const SizedBox(width: 10),
                IconActionButton(
                  icon: Icons.stop_rounded,
                  tooltip: 'Stop',
                  onPressed: onStop,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
