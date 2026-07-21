import 'dart:async';

import 'package:flutter/material.dart';

import '../../models/defense_cue_set.dart';
import '../../models/generated_drill.dart';
import '../../models/training_mode.dart';
import '../../services/boxing_combo_generator.dart';
import 'widgets/control_panel.dart';
import 'widgets/training_panel.dart';
import 'widgets/training_selector.dart';

class BoxingHomePage extends StatefulWidget {
  const BoxingHomePage({super.key});

  @override
  State<BoxingHomePage> createState() => _BoxingHomePageState();
}

class _BoxingHomePageState extends State<BoxingHomePage> {
  final _generator = BoxingComboGenerator();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  Timer? _timer;
  TrainingMode _mode = TrainingMode.combo;
  DefenseCueSet _cueSet = DefenseCueSet.common;
  int _refreshSeconds = TrainingMode.combo.optimalSeconds;
  int _comboMinLength = 2;
  int _comboMaxLength = 5;
  int _secondsLeft = TrainingMode.combo.optimalSeconds;
  bool _isRunning = false;
  bool _isPaused = false;
  bool _soundEnabled = true;
  bool _voiceEnabled = false;
  bool _isSignedIn = false;
  String _displayName = 'Account';
  GeneratedDrill _currentDrill = GeneratedDrill.empty();
  final List<GeneratedDrill> _history = [];
  int _generatedCount = 0;
  int _sessionSeconds = 0;
  int _pauseCount = 0;

  @override
  void initState() {
    super.initState();
    _generateNext();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _startTraining() {
    _timer?.cancel();
    setState(() {
      _isRunning = true;
      _isPaused = false;
      _secondsLeft = _refreshSeconds;
    });
    _timer = Timer.periodic(const Duration(seconds: 1), (_) => _tick());
  }

  void _tick() {
    if (!_isRunning || _isPaused) {
      return;
    }

    setState(() {
      _sessionSeconds++;
      if (_secondsLeft > 1) {
        _secondsLeft--;
      } else {
        _generateNext(updateState: false);
        _secondsLeft = _refreshSeconds;
      }
    });
  }

  void _togglePause() {
    if (!_isRunning) {
      _startTraining();
      return;
    }

    setState(() {
      _isPaused = !_isPaused;
      if (_isPaused) {
        _pauseCount++;
      }
    });
  }

  void _stopTraining() {
    _timer?.cancel();
    setState(() {
      _isRunning = false;
      _isPaused = false;
      _secondsLeft = _refreshSeconds;
    });
  }

  void _generateNext({bool updateState = true}) {
    final drill = _generator.generate(
      mode: _mode,
      cueSet: _cueSet,
      minLength: _comboMinLength,
      maxLength: _comboMaxLength,
    );

    void apply() {
      if (!_currentDrill.isEmpty) {
        _history.insert(0, _currentDrill);
        if (_history.length > 6) {
          _history.removeLast();
        }
      }
      _currentDrill = drill;
      _generatedCount++;
      _secondsLeft = _refreshSeconds;
    }

    if (updateState) {
      setState(apply);
    } else {
      apply();
    }
  }

  Future<void> _openModeSelector() async {
    final selected = await showTrainingSelector<TrainingMode>(
      context: context,
      title: 'Training mode',
      selected: _mode,
      options: TrainingMode.values,
      labelBuilder: (mode) => mode.label,
      subtitleBuilder: (mode) => mode.description,
    );

    if (selected == null) {
      return;
    }

    setState(() {
      _mode = selected;
      _refreshSeconds = selected.optimalSeconds;
      _secondsLeft = _refreshSeconds;
      if (selected == TrainingMode.tacticalDefense) {
        _cueSet = DefenseCueSet.tactical;
      }
      if (selected == TrainingMode.commonDefense) {
        _cueSet = DefenseCueSet.common;
      }
    });
    _generateNext();
  }

  Future<void> _openTempoSelector() async {
    final options = <int>[3, 5, 8, 10, 12, 15, 18, 22, 30, 45, 60];
    final selected = await showTrainingSelector<int>(
      context: context,
      title: 'Tempo',
      selected: _refreshSeconds,
      options: options,
      labelBuilder: (value) => '$value sec',
      subtitleBuilder: (value) => value == _mode.optimalSeconds
          ? 'Optimal for ${_mode.label}'
          : 'Refresh interval',
    );

    if (selected == null) {
      return;
    }

    setState(() {
      _refreshSeconds = selected;
      _secondsLeft = selected;
    });
  }

  Future<void> _openLengthSelector() async {
    const options = <RangeValues>[
      RangeValues(2, 3),
      RangeValues(2, 4),
      RangeValues(2, 5),
      RangeValues(3, 5),
      RangeValues(3, 6),
      RangeValues(4, 6),
    ];
    final current = RangeValues(
      _comboMinLength.toDouble(),
      _comboMaxLength.toDouble(),
    );
    final selected = await showTrainingSelector<RangeValues>(
      context: context,
      title: 'Combo length',
      selected: current,
      options: options,
      labelBuilder: (value) =>
          '${value.start.round()}-${value.end.round()} punches',
      subtitleBuilder: (_) => 'Generator range',
      isSelected: (a, b) => a.start == b.start && a.end == b.end,
    );

    if (selected == null) {
      return;
    }

    setState(() {
      _comboMinLength = selected.start.round();
      _comboMaxLength = selected.end.round();
    });
    _generateNext();
  }

  Future<void> _openCueSelector() async {
    final selected = await showTrainingSelector<DefenseCueSet>(
      context: context,
      title: 'Defense cues',
      selected: _cueSet,
      options: DefenseCueSet.values,
      labelBuilder: (cueSet) => cueSet.label,
      subtitleBuilder: (cueSet) => cueSet.description,
    );

    if (selected == null) {
      return;
    }

    setState(() {
      _cueSet = selected;
      if (_mode == TrainingMode.normal || _mode == TrainingMode.combo) {
        _mode = selected == DefenseCueSet.common
            ? TrainingMode.commonDefense
            : TrainingMode.tacticalDefense;
        _refreshSeconds = _mode.optimalSeconds;
        _secondsLeft = _refreshSeconds;
      }
    });
    _generateNext();
  }

  void _toggleSignedIn() {
    if (_isSignedIn) {
      setState(() {
        _isSignedIn = false;
        _displayName = 'Account';
      });
      return;
    }

    final email = _emailController.text.trim();
    setState(() {
      _isSignedIn = true;
      _displayName = email.isEmpty ? 'Firebase user' : email;
    });
    _showMessage('Login UI is ready. Connect Firebase Auth to make it real.');
  }

  void _saveForAccount() {
    if (!_isSignedIn) {
      _showMessage(
        'Login is required to save settings, custom cues, and stats.',
      );
      return;
    }

    _showMessage('Firebase save hook ready: write this state to users/{uid}.');
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final wide = constraints.maxWidth >= 880;
            final trainingPanel = TrainingPanel(
              currentDrill: _currentDrill,
              mode: _mode,
              refreshSeconds: _refreshSeconds,
              secondsLeft: _secondsLeft,
              isRunning: _isRunning,
              isPaused: _isPaused,
              generatedCount: _generatedCount,
              sessionSeconds: _sessionSeconds,
              onStart: _startTraining,
              onPause: _togglePause,
              onNext: _generateNext,
              onStop: _stopTraining,
            );
            final controlPanel = ControlPanel(
              mode: _mode,
              cueSet: _cueSet,
              refreshSeconds: _refreshSeconds,
              comboMinLength: _comboMinLength,
              comboMaxLength: _comboMaxLength,
              soundEnabled: _soundEnabled,
              voiceEnabled: _voiceEnabled,
              isSignedIn: _isSignedIn,
              displayName: _displayName,
              emailController: _emailController,
              passwordController: _passwordController,
              generatedCount: _generatedCount,
              sessionSeconds: _sessionSeconds,
              pauseCount: _pauseCount,
              history: _history,
              onModeTap: _openModeSelector,
              onTempoTap: _openTempoSelector,
              onLengthTap: _openLengthSelector,
              onCueTap: _openCueSelector,
              onSoundChanged: (value) => setState(() => _soundEnabled = value),
              onVoiceChanged: (value) => setState(() => _voiceEnabled = value),
              onAuthPressed: _toggleSignedIn,
              onSavePressed: _saveForAccount,
            );

            if (wide) {
              return Padding(
                padding: const EdgeInsets.all(18),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Expanded(flex: 7, child: trainingPanel),
                    const SizedBox(width: 16),
                    Expanded(flex: 4, child: controlPanel),
                  ],
                ),
              );
            }

            return ListView(
              padding: const EdgeInsets.all(14),
              children: [
                SizedBox(height: 620, child: trainingPanel),
                const SizedBox(height: 16),
                SizedBox(height: 760, child: controlPanel),
              ],
            );
          },
        ),
      ),
    );
  }
}
