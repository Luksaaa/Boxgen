import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_tts/flutter_tts.dart';

import '../../models/defense_cue_set.dart';
import '../../models/generated_drill.dart';
import '../../models/training_mode.dart';
import '../../models/training_settings.dart';
import '../../services/boxing_combo_generator.dart';
import '../../services/training_settings_storage.dart';
import 'widgets/account_panel.dart';
import 'widgets/setup_panel.dart';
import 'widgets/stats_panel.dart';
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
  final _pageController = PageController();
  final _tts = FlutterTts();

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
  int _selectedTab = 0;
  GeneratedDrill _currentDrill = GeneratedDrill.empty();
  final List<GeneratedDrill> _history = [];
  int _generatedCount = 0;
  int _sessionSeconds = 0;
  int _pauseCount = 0;

  @override
  void initState() {
    super.initState();
    _currentDrill = _createDrill();
    _loadSavedSettings();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _tts.stop();
    _pageController.dispose();
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

  GeneratedDrill _createDrill() {
    return _generator.generate(
      mode: _mode,
      cueSet: _cueSet,
      minLength: _comboMinLength,
      maxLength: _comboMaxLength,
    );
  }

  void _generateNext({bool updateState = true}) {
    final drill = _createDrill();

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
    _playFeedback(drill);
  }

  void _resetSessionForSettingsChange() {
    _timer?.cancel();
    final drill = _createDrill();

    setState(() {
      _isRunning = false;
      _isPaused = false;
      _secondsLeft = _refreshSeconds;
      _currentDrill = drill;
      _history.clear();
      _generatedCount = 0;
      _sessionSeconds = 0;
      _pauseCount = 0;
    });
  }

  Future<void> _loadSavedSettings() async {
    final settings = await TrainingSettingsStorage.load();
    if (!mounted) {
      return;
    }

    setState(() {
      _mode = settings.mode;
      _cueSet = settings.cueSet;
      _refreshSeconds = settings.refreshSeconds;
      _comboMinLength = settings.comboMinLength;
      _comboMaxLength = settings.comboMaxLength;
      _soundEnabled = settings.soundEnabled;
      _voiceEnabled = settings.voiceEnabled;
      _secondsLeft = settings.refreshSeconds;
      _currentDrill = _createDrill();
      _history.clear();
      _generatedCount = 0;
      _sessionSeconds = 0;
      _pauseCount = 0;
    });
  }

  Future<void> _saveSettings() {
    return TrainingSettingsStorage.save(
      TrainingSettings(
        mode: _mode,
        cueSet: _cueSet,
        refreshSeconds: _refreshSeconds,
        comboMinLength: _comboMinLength,
        comboMaxLength: _comboMaxLength,
        soundEnabled: _soundEnabled,
        voiceEnabled: _voiceEnabled,
      ),
    );
  }

  Future<void> _applySettingsChange(VoidCallback change) async {
    setState(change);
    _resetSessionForSettingsChange();
    await _saveSettings();
  }

  void _changeSound(bool value) {
    _applySettingsChange(() => _soundEnabled = value).then((_) {
      if (value) {
        SystemSound.play(SystemSoundType.click);
      }
    });
  }

  void _changeVoice(bool value) {
    _applySettingsChange(() => _voiceEnabled = value).then((_) {
      if (value) {
        _playFeedback(_currentDrill);
      }
    });
  }

  Future<void> _playFeedback(GeneratedDrill drill) async {
    if (_soundEnabled) {
      await SystemSound.play(SystemSoundType.click);
    }

    if (_voiceEnabled) {
      await _tts.stop();
      await _tts.setSpeechRate(0.48);
      await _tts.setPitch(0.9);
      await _tts.speak(_spokenDrill(drill));
    }
  }

  String _spokenDrill(GeneratedDrill drill) {
    return drill.display
        .replaceAll('-', ' ')
        .replaceAll('[', '')
        .replaceAll(']', '')
        .replaceAll('&', 'and');
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

    await _applySettingsChange(() {
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

    await _applySettingsChange(() {
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

    await _applySettingsChange(() {
      _comboMinLength = selected.start.round();
      _comboMaxLength = selected.end.round();
    });
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

    await _applySettingsChange(() {
      _cueSet = selected;
      if (_mode == TrainingMode.normal || _mode == TrainingMode.combo) {
        _mode = selected == DefenseCueSet.common
            ? TrainingMode.commonDefense
            : TrainingMode.tacticalDefense;
        _refreshSeconds = _mode.optimalSeconds;
        _secondsLeft = _refreshSeconds;
      }
    });
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

  void _showMessage(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  void _selectTab(int index) {
    setState(() => _selectedTab = index);
    _pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 240),
      curve: Curves.easeOutCubic,
    );
  }

  @override
  Widget build(BuildContext context) {
    final pages = [
      _buildTrainingPage(),
      _buildSetupPage(),
      _buildAccountPage(),
      _buildStatsPage(),
    ];

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(14, 14, 14, 10),
          child: PageView(
            controller: _pageController,
            onPageChanged: (index) => setState(() => _selectedTab = index),
            children: pages,
          ),
        ),
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedTab,
        onDestinationSelected: _selectTab,
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.sports_mma_rounded),
            label: 'Training',
          ),
          NavigationDestination(icon: Icon(Icons.tune_rounded), label: 'Setup'),
          NavigationDestination(
            icon: Icon(Icons.person_rounded),
            label: 'Account',
          ),
          NavigationDestination(
            icon: Icon(Icons.insights_rounded),
            label: 'Stats',
          ),
        ],
      ),
    );
  }

  Widget _buildTrainingPage() {
    return TrainingPanel(
      currentDrill: _currentDrill,
      refreshSeconds: _refreshSeconds,
      secondsLeft: _secondsLeft,
      isRunning: _isRunning,
      isPaused: _isPaused,
      onStart: _startTraining,
      onPause: _togglePause,
      onNext: _generateNext,
      onStop: _stopTraining,
      onReset: _resetSessionForSettingsChange,
    );
  }

  Widget _buildSetupPage() {
    return SetupPanel(
      mode: _mode,
      cueSet: _cueSet,
      refreshSeconds: _refreshSeconds,
      comboMinLength: _comboMinLength,
      comboMaxLength: _comboMaxLength,
      soundEnabled: _soundEnabled,
      voiceEnabled: _voiceEnabled,
      onModeTap: _openModeSelector,
      onTempoTap: _openTempoSelector,
      onLengthTap: _openLengthSelector,
      onCueTap: _openCueSelector,
      onSoundChanged: _changeSound,
      onVoiceChanged: _changeVoice,
    );
  }

  Widget _buildAccountPage() {
    return AccountPanel(
      isSignedIn: _isSignedIn,
      displayName: _displayName,
      emailController: _emailController,
      passwordController: _passwordController,
      onAuthPressed: _toggleSignedIn,
    );
  }

  Widget _buildStatsPage() {
    return StatsPanel(
      generatedCount: _generatedCount,
      sessionSeconds: _sessionSeconds,
      pauseCount: _pauseCount,
      history: _history,
    );
  }
}
