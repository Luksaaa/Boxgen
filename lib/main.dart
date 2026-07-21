import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';

void main() {
  runApp(const BoxgenApp());
}

enum TrainingMode {
  normal(
    label: 'Normal',
    description: 'Random punches',
    optimalSeconds: 10,
    icon: Icons.shuffle_rounded,
  ),
  combo(
    label: 'Combo',
    description: 'Realistic boxing',
    optimalSeconds: 12,
    icon: Icons.sports_mma_rounded,
  ),
  commonDefense(
    label: 'Combo + Def',
    description: 'Common coach cues',
    optimalSeconds: 18,
    icon: Icons.shield_rounded,
  ),
  tacticalDefense(
    label: 'Tactical',
    description: 'All defensive cues',
    optimalSeconds: 22,
    icon: Icons.psychology_alt_rounded,
  );

  const TrainingMode({
    required this.label,
    required this.description,
    required this.optimalSeconds,
    required this.icon,
  });

  final String label;
  final String description;
  final int optimalSeconds;
  final IconData icon;
}

enum DefenseCueSet {
  common('Common', 'Basic coach cues'),
  tactical('Tactical', 'Full tactical list');

  const DefenseCueSet(this.label, this.description);

  final String label;
  final String description;
}

class BoxgenApp extends StatelessWidget {
  const BoxgenApp({super.key});

  @override
  Widget build(BuildContext context) {
    const background = Color(0xFF130D11);
    const surface = Color(0xFF20141B);
    const primary = Color(0xFFFF9BC0);

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Boxgen',
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: background,
        colorScheme: ColorScheme.fromSeed(
          seedColor: primary,
          brightness: Brightness.dark,
          surface: surface,
        ),
        fontFamily: 'Arial',
        useMaterial3: true,
        snackBarTheme: const SnackBarThemeData(
          behavior: SnackBarBehavior.floating,
          backgroundColor: Color(0xFF40202D),
          contentTextStyle: TextStyle(color: Colors.white),
        ),
      ),
      home: const BoxingHomePage(),
    );
  }
}

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
            final trainingPanel = _TrainingPanel(
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
            final controlPanel = _ControlPanel(
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

class _TrainingPanel extends StatelessWidget {
  const _TrainingPanel({
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
                _TimerPill(secondsLeft: secondsLeft, isPaused: isPaused),
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
                  child: _PrimaryActionButton(
                    icon: isRunning && !isPaused
                        ? Icons.pause_rounded
                        : Icons.play_arrow_rounded,
                    label: isRunning && !isPaused ? 'Pause' : 'Start',
                    onPressed: isRunning ? onPause : onStart,
                  ),
                ),
                const SizedBox(width: 10),
                _IconActionButton(
                  icon: Icons.skip_next_rounded,
                  tooltip: 'Next combo',
                  onPressed: onNext,
                ),
                const SizedBox(width: 10),
                _IconActionButton(
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
                  child: _MetricTile(label: 'Combos', value: '$generatedCount'),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _MetricTile(
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

class _ControlPanel extends StatelessWidget {
  const _ControlPanel({
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
          _SectionTitle(
            icon: Icons.tune_rounded,
            title: 'Setup',
            action: TextButton.icon(
              onPressed: onSavePressed,
              icon: const Icon(Icons.cloud_upload_rounded, size: 18),
              label: const Text('Save'),
            ),
          ),
          const SizedBox(height: 8),
          _SelectorRow(
            icon: mode.icon,
            label: 'Mode',
            value: mode.label,
            onTap: onModeTap,
          ),
          _SelectorRow(
            icon: Icons.timer_rounded,
            label: 'Tempo',
            value: '$refreshSeconds sec',
            onTap: onTempoTap,
          ),
          _SelectorRow(
            icon: Icons.format_list_numbered_rounded,
            label: 'Length',
            value: '$comboMinLength-$comboMaxLength',
            onTap: onLengthTap,
          ),
          _SelectorRow(
            icon: Icons.shield_rounded,
            label: 'Defense',
            value: cueSet.label,
            onTap: onCueTap,
          ),
          const SizedBox(height: 10),
          _SwitchRow(
            icon: Icons.volume_up_rounded,
            label: 'Sound',
            value: soundEnabled,
            onChanged: onSoundChanged,
          ),
          _SwitchRow(
            icon: Icons.record_voice_over_rounded,
            label: 'Voice',
            value: voiceEnabled,
            onChanged: onVoiceChanged,
          ),
          const SizedBox(height: 18),
          _SectionTitle(icon: Icons.person_rounded, title: 'Login'),
          const SizedBox(height: 8),
          _AuthBox(
            isSignedIn: isSignedIn,
            displayName: displayName,
            emailController: emailController,
            passwordController: passwordController,
            onAuthPressed: onAuthPressed,
          ),
          const SizedBox(height: 18),
          _SectionTitle(icon: Icons.insights_rounded, title: 'Session'),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: _MetricTile(
                  label: 'Generated',
                  value: '$generatedCount',
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _MetricTile(label: 'Pauses', value: '$pauseCount'),
              ),
            ],
          ),
          const SizedBox(height: 10),
          _MetricTile(
            label: 'Training time',
            value: formatDuration(sessionSeconds),
          ),
          const SizedBox(height: 18),
          _SectionTitle(icon: Icons.history_rounded, title: 'History'),
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

class _AuthBox extends StatelessWidget {
  const _AuthBox({
    required this.isSignedIn,
    required this.displayName,
    required this.emailController,
    required this.passwordController,
    required this.onAuthPressed,
  });

  final bool isSignedIn;
  final String displayName;
  final TextEditingController emailController;
  final TextEditingController passwordController;
  final VoidCallback onAuthPressed;

  @override
  Widget build(BuildContext context) {
    if (isSignedIn) {
      return Container(
        padding: const EdgeInsets.all(12),
        decoration: const BoxDecoration(
          color: Color(0xFF281922),
          borderRadius: BorderRadius.all(Radius.circular(8)),
        ),
        child: Row(
          children: [
            const Icon(Icons.verified_user_rounded, color: Color(0xFFFFB0CB)),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                displayName,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontWeight: FontWeight.w800),
              ),
            ),
            TextButton(onPressed: onAuthPressed, child: const Text('Logout')),
          ],
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: const BoxDecoration(
        color: Color(0xFF281922),
        borderRadius: BorderRadius.all(Radius.circular(8)),
      ),
      child: Column(
        children: [
          TextField(
            controller: emailController,
            keyboardType: TextInputType.emailAddress,
            decoration: const InputDecoration(
              prefixIcon: Icon(Icons.mail_rounded),
              labelText: 'Email',
            ),
          ),
          const SizedBox(height: 10),
          TextField(
            controller: passwordController,
            obscureText: true,
            decoration: const InputDecoration(
              prefixIcon: Icon(Icons.lock_rounded),
              labelText: 'Password',
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              onPressed: onAuthPressed,
              icon: const Icon(Icons.login_rounded),
              label: const Text('Login'),
            ),
          ),
        ],
      ),
    );
  }
}

class _SelectorRow extends StatelessWidget {
  const _SelectorRow({
    required this.icon,
    required this.label,
    required this.value,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final String value;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Material(
        color: const Color(0xFF281922),
        borderRadius: const BorderRadius.all(Radius.circular(8)),
        child: InkWell(
          borderRadius: const BorderRadius.all(Radius.circular(8)),
          onTap: onTap,
          child: SizedBox(
            height: 58,
            child: Row(
              children: [
                const SizedBox(width: 12),
                Icon(icon, color: const Color(0xFFFFB0CB)),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    label,
                    style: const TextStyle(fontWeight: FontWeight.w700),
                  ),
                ),
                Text(
                  value,
                  style: const TextStyle(
                    color: Color(0xFFE6D3DC),
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(width: 8),
                const Icon(Icons.expand_more_rounded, color: Color(0xFFBDAAB3)),
                const SizedBox(width: 8),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _SwitchRow extends StatelessWidget {
  const _SwitchRow({
    required this.icon,
    required this.label,
    required this.value,
    required this.onChanged,
  });

  final IconData icon;
  final String label;
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Container(
        height: 58,
        decoration: const BoxDecoration(
          color: Color(0xFF281922),
          borderRadius: BorderRadius.all(Radius.circular(8)),
        ),
        child: Row(
          children: [
            const SizedBox(width: 12),
            Icon(icon, color: const Color(0xFFFFB0CB)),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                label,
                style: const TextStyle(fontWeight: FontWeight.w700),
              ),
            ),
            Switch(value: value, onChanged: onChanged),
            const SizedBox(width: 8),
          ],
        ),
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({required this.icon, required this.title, this.action});

  final IconData icon;
  final String title;
  final Widget? action;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 18, color: const Color(0xFFFFB0CB)),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            title,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w900),
          ),
        ),
        ?action,
      ],
    );
  }
}

class _MetricTile extends StatelessWidget {
  const _MetricTile({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 70,
      padding: const EdgeInsets.symmetric(horizontal: 14),
      decoration: const BoxDecoration(
        color: Color(0xFF281922),
        borderRadius: BorderRadius.all(Radius.circular(8)),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: Color(0xFFBDAAB3),
              fontSize: 12,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 4),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              value,
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w900),
            ),
          ),
        ],
      ),
    );
  }
}

class _TimerPill extends StatelessWidget {
  const _TimerPill({required this.secondsLeft, required this.isPaused});

  final int secondsLeft;
  final bool isPaused;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 44,
      padding: const EdgeInsets.symmetric(horizontal: 14),
      decoration: const BoxDecoration(
        color: Color(0xFF281922),
        borderRadius: BorderRadius.all(Radius.circular(8)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isPaused ? Icons.pause_rounded : Icons.timer_rounded,
            color: const Color(0xFFFFB0CB),
          ),
          const SizedBox(width: 8),
          Text(
            isPaused ? 'Paused' : '${secondsLeft}s',
            style: const TextStyle(fontWeight: FontWeight.w900),
          ),
        ],
      ),
    );
  }
}

class _PrimaryActionButton extends StatelessWidget {
  const _PrimaryActionButton({
    required this.icon,
    required this.label,
    required this.onPressed,
  });

  final IconData icon;
  final String label;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 54,
      child: FilledButton.icon(
        onPressed: onPressed,
        icon: Icon(icon),
        label: Text(label),
      ),
    );
  }
}

class _IconActionButton extends StatelessWidget {
  const _IconActionButton({
    required this.icon,
    required this.tooltip,
    required this.onPressed,
  });

  final IconData icon;
  final String tooltip;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: SizedBox(
        width: 54,
        height: 54,
        child: IconButton.filledTonal(onPressed: onPressed, icon: Icon(icon)),
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

Future<T?> showTrainingSelector<T>({
  required BuildContext context,
  required String title,
  required T selected,
  required List<T> options,
  required String Function(T value) labelBuilder,
  required String Function(T value) subtitleBuilder,
  bool Function(T a, T b)? isSelected,
}) {
  return showModalBottomSheet<T>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (context) => _TrainingSelector<T>(
      title: title,
      selected: selected,
      options: options,
      labelBuilder: labelBuilder,
      subtitleBuilder: subtitleBuilder,
      isSelected: isSelected,
    ),
  );
}

class _TrainingSelector<T> extends StatefulWidget {
  const _TrainingSelector({
    required this.title,
    required this.selected,
    required this.options,
    required this.labelBuilder,
    required this.subtitleBuilder,
    this.isSelected,
  });

  final String title;
  final T selected;
  final List<T> options;
  final String Function(T value) labelBuilder;
  final String Function(T value) subtitleBuilder;
  final bool Function(T a, T b)? isSelected;

  @override
  State<_TrainingSelector<T>> createState() => _TrainingSelectorState<T>();
}

class _TrainingSelectorState<T> extends State<_TrainingSelector<T>> {
  late T _selected = widget.selected;

  bool _matches(T a, T b) => widget.isSelected?.call(a, b) ?? a == b;

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.68,
      minChildSize: 0.44,
      maxChildSize: 0.92,
      builder: (context, controller) {
        return Container(
          decoration: const BoxDecoration(
            color: Color(0xFF130D11),
            borderRadius: BorderRadius.vertical(top: Radius.circular(8)),
          ),
          child: Column(
            children: [
              SizedBox(
                height: 58,
                child: Row(
                  children: [
                    const SizedBox(width: 16),
                    Expanded(
                      child: Text(
                        widget.title,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                    IconButton(
                      tooltip: 'Close',
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.close_rounded),
                    ),
                    const SizedBox(width: 8),
                  ],
                ),
              ),
              Expanded(
                child: ListView.builder(
                  controller: controller,
                  padding: const EdgeInsets.fromLTRB(10, 4, 10, 10),
                  itemCount: widget.options.length,
                  itemBuilder: (context, index) {
                    final option = widget.options[index];
                    final selected = _matches(option, _selected);
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Material(
                        color: selected
                            ? const Color(0xFF472231)
                            : Colors.transparent,
                        borderRadius: const BorderRadius.all(
                          Radius.circular(8),
                        ),
                        child: InkWell(
                          borderRadius: const BorderRadius.all(
                            Radius.circular(8),
                          ),
                          onTap: () => setState(() => _selected = option),
                          child: SizedBox(
                            height: 64,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  widget.labelBuilder(option),
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    color: selected
                                        ? Colors.white
                                        : const Color(0xFF8E7B84),
                                    fontSize: selected ? 21 : 17,
                                    fontWeight: FontWeight.w900,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  widget.subtitleBuilder(option),
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    color: selected
                                        ? const Color(0xFFFFC9DC)
                                        : const Color(0xFF6F6068),
                                    fontSize: 12,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(10, 8, 10, 10),
                child: SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: FilledButton(
                    onPressed: () => Navigator.pop(context, _selected),
                    child: const Text('Save'),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

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

class GeneratedDrill {
  const GeneratedDrill({
    required this.title,
    required this.display,
    this.cue = '',
  });

  factory GeneratedDrill.empty() =>
      const GeneratedDrill(title: '', display: '');

  final String title;
  final String display;
  final String cue;

  bool get isEmpty => display.isEmpty;
}

String formatDuration(int seconds) {
  final minutes = seconds ~/ 60;
  final remainingSeconds = seconds % 60;
  return '$minutes:${remainingSeconds.toString().padLeft(2, '0')}';
}
