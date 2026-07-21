import 'package:shared_preferences/shared_preferences.dart';

import '../models/defense_cue_set.dart';
import '../models/training_mode.dart';
import '../models/training_settings.dart';

class TrainingSettingsStorage {
  const TrainingSettingsStorage._();

  static const _modeKey = 'training.mode';
  static const _cueSetKey = 'training.cueSet';
  static const _refreshSecondsKey = 'training.refreshSeconds';
  static const _comboMinLengthKey = 'training.comboMinLength';
  static const _comboMaxLengthKey = 'training.comboMaxLength';
  static const _soundEnabledKey = 'training.soundEnabled';
  static const _voiceEnabledKey = 'training.voiceEnabled';

  static Future<TrainingSettings> load() async {
    final prefs = await SharedPreferences.getInstance();
    final defaults = TrainingSettings.defaults();

    return TrainingSettings(
      mode: _enumByName(
        TrainingMode.values,
        prefs.getString(_modeKey),
        defaults.mode,
      ),
      cueSet: _enumByName(
        DefenseCueSet.values,
        prefs.getString(_cueSetKey),
        defaults.cueSet,
      ),
      refreshSeconds:
          prefs.getInt(_refreshSecondsKey) ?? defaults.refreshSeconds,
      comboMinLength:
          prefs.getInt(_comboMinLengthKey) ?? defaults.comboMinLength,
      comboMaxLength:
          prefs.getInt(_comboMaxLengthKey) ?? defaults.comboMaxLength,
      soundEnabled: prefs.getBool(_soundEnabledKey) ?? defaults.soundEnabled,
      voiceEnabled: prefs.getBool(_voiceEnabledKey) ?? defaults.voiceEnabled,
    );
  }

  static Future<void> save(TrainingSettings settings) async {
    final prefs = await SharedPreferences.getInstance();
    await Future.wait([
      prefs.setString(_modeKey, settings.mode.name),
      prefs.setString(_cueSetKey, settings.cueSet.name),
      prefs.setInt(_refreshSecondsKey, settings.refreshSeconds),
      prefs.setInt(_comboMinLengthKey, settings.comboMinLength),
      prefs.setInt(_comboMaxLengthKey, settings.comboMaxLength),
      prefs.setBool(_soundEnabledKey, settings.soundEnabled),
      prefs.setBool(_voiceEnabledKey, settings.voiceEnabled),
    ]);
  }

  static T _enumByName<T extends Enum>(
    List<T> values,
    String? name,
    T fallback,
  ) {
    for (final value in values) {
      if (value.name == name) {
        return value;
      }
    }
    return fallback;
  }
}
