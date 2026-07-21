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
