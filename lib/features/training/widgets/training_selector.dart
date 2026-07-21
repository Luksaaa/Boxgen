import 'package:flutter/material.dart';

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
  late final FixedExtentScrollController _controller;

  @override
  void initState() {
    super.initState();
    final index = widget.options.indexWhere(
      (option) => _matches(option, _selected),
    );
    _controller = FixedExtentScrollController(
      initialItem: index < 0 ? 0 : index,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  bool _matches(T a, T b) => widget.isSelected?.call(a, b) ?? a == b;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Container(
        height: MediaQuery.sizeOf(context).height * 0.62,
        decoration: const BoxDecoration(
          color: Color(0xFF050507),
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
              child: Stack(
                alignment: Alignment.center,
                children: [
                  const _WheelFadeBackground(),
                  Container(
                    height: 74,
                    margin: const EdgeInsets.symmetric(horizontal: 10),
                    decoration: const BoxDecoration(
                      color: Color(0xFF281421),
                      borderRadius: BorderRadius.all(Radius.circular(8)),
                    ),
                  ),
                  ListWheelScrollView.useDelegate(
                    controller: _controller,
                    itemExtent: 74,
                    diameterRatio: 1.45,
                    perspective: 0.0025,
                    physics: const FixedExtentScrollPhysics(),
                    onSelectedItemChanged: (index) {
                      setState(() => _selected = widget.options[index]);
                    },
                    childDelegate: ListWheelChildBuilderDelegate(
                      childCount: widget.options.length,
                      builder: (context, index) {
                        final option = widget.options[index];
                        final selected = _matches(option, _selected);
                        return _WheelOption(
                          label: widget.labelBuilder(option),
                          subtitle: widget.subtitleBuilder(option),
                          selected: selected,
                        );
                      },
                    ),
                  ),
                ],
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
      ),
    );
  }
}

class _WheelOption extends StatelessWidget {
  const _WheelOption({
    required this.label,
    required this.subtitle,
    required this.selected,
  });

  final String label;
  final String subtitle;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              label,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: selected ? Colors.white : const Color(0xFF525665),
                fontSize: selected ? 34 : 25,
                fontWeight: FontWeight.w900,
                height: 1,
              ),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            subtitle,
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: selected
                  ? const Color(0xFFFFB0CB)
                  : const Color(0xFF3B3F4D),
              fontSize: 12,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _WheelFadeBackground extends StatelessWidget {
  const _WheelFadeBackground();

  @override
  Widget build(BuildContext context) {
    return const DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color(0xFF050507),
            Color(0xFF11182B),
            Color(0xFF11182B),
            Color(0xFF050507),
          ],
          stops: [0, 0.38, 0.62, 1],
        ),
      ),
      child: SizedBox.expand(),
    );
  }
}
