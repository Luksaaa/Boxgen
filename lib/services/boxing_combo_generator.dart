import 'dart:math';

import '../models/defense_cue_set.dart';
import '../models/generated_drill.dart';
import '../models/training_mode.dart';

class BoxingComboGenerator {
  final Random _random = Random();

  static const List<String> commonDefenseCues = [
    'Slip (Dolje)',
    'Duck (Cucanj)',
    'Roll (L/R Cucanj)',
    'Parry (Take a hit)',
    'Block',
    'Pivot (Promjeni smjer)',
    'Step Back',
  ];

  static const List<String> tacticalDefenseCues = [
    'Slip',
    'Slip L',
    'Slip R',
    'Duck',
    'Bob',
    'Weave',
    'Bob & Weave',
    'Roll',
    'Roll Under',
    'Pull Back',
    'Lean Back',
    'Block',
    'High Guard',
    'Cover',
    'Shell',
    'Parry',
    'Catch',
    'Catch & Shoot',
    'Frame',
    'Step Back',
    'Step In',
    'Pivot',
    'Angle',
    'Side Step',
    'Slide Left',
    'Slide Right',
    'Circle Left',
    'Circle Right',
    'Clinch',
    'Tie Up',
    'Smother',
    'Push Off',
    'Inside Control',
    'Cut the Angle',
    'Get Off the Line',
    'Reset',
    'Hold Center',
    'Corner Out',
    'Back to Center',
    'Slip & Counter',
    'Roll & Fire',
    'Block & Counter',
    'Parry & Jab',
    'Catch & Cross',
  ];

  GeneratedDrill generate({
    required TrainingMode mode,
    required DefenseCueSet cueSet,
    required int minLength,
    required int maxLength,
  }) {
    if (mode == TrainingMode.normal) {
      final combo = _generateNormalCombo(minLength, maxLength);
      return GeneratedDrill(
        title: 'Punch combination',
        display: _formatCombo(combo),
      );
    }

    if (mode == TrainingMode.combo) {
      final combo = _generateBoxingCombo(minLength, maxLength);
      return GeneratedDrill(
        title: 'Boxing combo',
        display: _formatCombo(combo),
      );
    }

    final combo1 = _generateBoxingCombo(minLength, maxLength);
    final combo2 = _generateBoxingCombo(minLength, maxLength);
    final cue = _generateDefenseCue(cueSet);

    return GeneratedDrill(
      title: 'New combination',
      display: '${_formatCombo(combo1)}  [ $cue ]  ${_formatCombo(combo2)}',
      cue: cue,
    );
  }

  List<int> _generateNormalCombo(int minLength, int maxLength) {
    final length = _randomBetween(minLength, maxLength);
    return List.generate(length, (_) => _randomBetween(1, 6));
  }

  List<int> _generateBoxingCombo(int minLength, int maxLength) {
    final length = _weightedLength(minLength, maxLength);
    final combo = <int>[];
    var backhand = 0;

    for (var i = 0; i < length; i++) {
      var punch = _randomBetween(1, 6);

      if (punch == 2 || punch == 4 || punch == 6) {
        backhand++;
        if (backhand > 2) {
          punch = 1;
        }
      } else {
        backhand = 0;
      }

      if ((punch == 5 || punch == 6) && _random.nextDouble() < 0.6) {
        punch = [1, 2, 3][_random.nextInt(3)];
      }

      combo.add(punch);
    }

    return combo;
  }

  int _weightedLength(int minLength, int maxLength) {
    const candidates = [2, 3, 4, 5];
    const weights = [30, 30, 30, 10];
    final allowed = <int>[];
    final allowedWeights = <int>[];

    for (var i = 0; i < candidates.length; i++) {
      if (candidates[i] >= minLength && candidates[i] <= maxLength) {
        allowed.add(candidates[i]);
        allowedWeights.add(weights[i]);
      }
    }

    if (allowed.isEmpty) {
      return _randomBetween(minLength, maxLength);
    }

    final total = allowedWeights.reduce((a, b) => a + b);
    var pick = _random.nextInt(total);
    for (var i = 0; i < allowed.length; i++) {
      if (pick < allowedWeights[i]) {
        return allowed[i];
      }
      pick -= allowedWeights[i];
    }
    return allowed.last;
  }

  String _generateDefenseCue(DefenseCueSet cueSet) {
    final cues = cueSet == DefenseCueSet.common
        ? commonDefenseCues
        : tacticalDefenseCues;
    return cues[_random.nextInt(cues.length)];
  }

  int _randomBetween(int minValue, int maxValue) {
    return minValue + _random.nextInt(maxValue - minValue + 1);
  }

  String _formatCombo(List<int> combo) => combo.join(' - ');
}
