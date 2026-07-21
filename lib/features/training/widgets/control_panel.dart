import 'package:flutter/material.dart';

import '../../../models/defense_cue_set.dart';
import '../../../models/generated_drill.dart';
import '../../../models/training_mode.dart';
import '../../../utils/format_duration.dart';
import 'auth_box.dart';
import 'training_controls.dart';

class ControlPanel extends StatelessWidget {
  const ControlPanel({
    super.key,
    required this.mode,
    required this.cueSet,
    required this.refreshSeconds,
    required this.comboMinLength,
    required this.comboMaxLength,
    required this.soundEnabled,
    required this.voiceEnabled,
    required this.isSignedIn,
    required this.displayName,
    required this.emailController,
    required this.passwordController,
    required this.generatedCount,
    required this.sessionSeconds,
    required this.pauseCount,
    required this.history,
    required this.onModeTap,
    required this.onTempoTap,
    required this.onLengthTap,
    required this.onCueTap,
    required this.onSoundChanged,
    required this.onVoiceChanged,
    required this.onAuthPressed,
    required this.onSavePressed,
  });

  final TrainingMode mode;
  final DefenseCueSet cueSet;
  final int refreshSeconds;
  final int comboMinLength;
  final int comboMaxLength;
  final bool soundEnabled;
  final bool voiceEnabled;
  final bool isSignedIn;
  final String displayName;
  final TextEditingController emailController;
  final TextEditingController passwordController;
  final int generatedCount;
  final int sessionSeconds;
  final int pauseCount;
  final List<GeneratedDrill> history;
  final VoidCallback onModeTap;
  final VoidCallback onTempoTap;
  final VoidCallback onLengthTap;
  final VoidCallback onCueTap;
  final ValueChanged<bool> onSoundChanged;
  final ValueChanged<bool> onVoiceChanged;
  final VoidCallback onAuthPressed;
  final VoidCallback onSavePressed;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: const BoxDecoration(
        color: Color(0xFF1D1319),
        borderRadius: BorderRadius.all(Radius.circular(8)),
      ),
      child: ListView(
        padding: const EdgeInsets.all(14),
        children: [
          SectionTitle(
            icon: Icons.tune_rounded,
            title: 'Setup',
            action: TextButton.icon(
              onPressed: onSavePressed,
              icon: const Icon(Icons.cloud_upload_rounded, size: 18),
              label: const Text('Save'),
            ),
          ),
          const SizedBox(height: 8),
          SelectorRow(
            icon: mode.icon,
            label: 'Mode',
            value: mode.label,
            onTap: onModeTap,
          ),
          SelectorRow(
            icon: Icons.timer_rounded,
            label: 'Tempo',
            value: '$refreshSeconds sec',
            onTap: onTempoTap,
          ),
          SelectorRow(
            icon: Icons.format_list_numbered_rounded,
            label: 'Length',
            value: '$comboMinLength-$comboMaxLength',
            onTap: onLengthTap,
          ),
          SelectorRow(
            icon: Icons.shield_rounded,
            label: 'Defense',
            value: cueSet.label,
            onTap: onCueTap,
          ),
          const SizedBox(height: 10),
          SwitchRow(
            icon: Icons.volume_up_rounded,
            label: 'Sound',
            value: soundEnabled,
            onChanged: onSoundChanged,
          ),
          SwitchRow(
            icon: Icons.record_voice_over_rounded,
            label: 'Voice',
            value: voiceEnabled,
            onChanged: onVoiceChanged,
          ),
          const SizedBox(height: 18),
          const SectionTitle(icon: Icons.person_rounded, title: 'Login'),
          const SizedBox(height: 8),
          AuthBox(
            isSignedIn: isSignedIn,
            displayName: displayName,
            emailController: emailController,
            passwordController: passwordController,
            onAuthPressed: onAuthPressed,
          ),
          const SizedBox(height: 18),
          const SectionTitle(icon: Icons.insights_rounded, title: 'Session'),
          const SizedBox(height: 8),
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
          const SizedBox(height: 18),
          const SectionTitle(icon: Icons.history_rounded, title: 'History'),
          const SizedBox(height: 8),
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
        color: Color(0xFF281922),
        borderRadius: BorderRadius.all(Radius.circular(8)),
      ),
      child: Row(
        children: [
          const Icon(Icons.sports_mma_rounded, color: Color(0xFFFFB0CB)),
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
        color: Color(0xFF281922),
        borderRadius: BorderRadius.all(Radius.circular(8)),
      ),
      child: const Text(
        'History appears after the next generated combo.',
        style: TextStyle(color: Color(0xFFBDAAB3), fontWeight: FontWeight.w700),
      ),
    );
  }
}
