enum DefenseCueSet {
  common('Common', 'Basic coach cues'),
  tactical('Tactical', 'Full tactical list');

  const DefenseCueSet(this.label, this.description);

  final String label;
  final String description;
}
