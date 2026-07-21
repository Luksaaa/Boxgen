import 'package:flutter/material.dart';

import '../../../app/app_colors.dart';
import '../../../models/defense_cue_set.dart';
import '../../../models/training_mode.dart';
import 'training_controls.dart';

class SetupPanel extends StatelessWidget {
  const SetupPanel({
    super.key,
    required this.mode,
    required this.cueSet,
    required this.refreshSeconds,
    required this.comboMinLength,
    required this.comboMaxLength,
    required this.soundEnabled,
    required this.voiceEnabled,
    required this.onModeTap,
    required this.onTempoTap,
    required this.onLengthTap,
    required this.onCueTap,
    required this.onSoundChanged,
    required this.onVoiceChanged,
    required this.onSavePressed,
  });

  final TrainingMode mode;
  final DefenseCueSet cueSet;
  final int refreshSeconds;
  final int comboMinLength;
  final int comboMaxLength;
  final bool soundEnabled;
  final bool voiceEnabled;
  final VoidCallback onModeTap;
  final VoidCallback onTempoTap;
  final VoidCallback onLengthTap;
  final VoidCallback onCueTap;
  final ValueChanged<bool> onSoundChanged;
  final ValueChanged<bool> onVoiceChanged;
  final VoidCallback onSavePressed;

  @override
  Widget build(BuildContext context) {
    return _TabSurface(
      child: ListView(
        padding: const EdgeInsets.all(16),
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
          const SizedBox(height: 12),
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
        ],
      ),
    );
  }
}

class _TabSurface extends StatelessWidget {
  const _TabSurface({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: const BoxDecoration(
        color: AppColors.surfaceHigh,
        borderRadius: BorderRadius.all(Radius.circular(8)),
      ),
      child: child,
    );
  }
}
