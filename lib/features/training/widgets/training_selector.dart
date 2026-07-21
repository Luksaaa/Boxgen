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
