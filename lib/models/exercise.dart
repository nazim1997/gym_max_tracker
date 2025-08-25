class Exercise {
  final String name;
  final String category;
  final String? max;
  final String? reps;

  Exercise({
    required this.name,
    required this.category,
    this.max,
    this.reps,
  });
}
