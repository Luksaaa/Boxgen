import 'defense_cue_set.dart';
import 'training_mode.dart';

class TrainingSettings {
  const TrainingSettings({
    required this.mode,
    required this.cueSet,
    required this.refreshSeconds,
    required this.comboMinLength,
    required this.comboMaxLength,
    required this.soundEnabled,
    required this.voiceEnabled,
  });

  factory TrainingSettings.defaults() => const TrainingSettings(
    mode: TrainingMode.combo,
    cueSet: DefenseCueSet.common,
    refreshSeconds: 12,
    comboMinLength: 2,
    comboMaxLength: 5,
    soundEnabled: true,
    voiceEnabled: false,
  );

  final TrainingMode mode;
  final DefenseCueSet cueSet;
  final int refreshSeconds;
  final int comboMinLength;
  final int comboMaxLength;
  final bool soundEnabled;
  final bool voiceEnabled;
}
