class WorkoutEntry {
  final int? id;
  final int exerciseId;
  final double weight;
  final int reps;
  final DateTime date;
  
  WorkoutEntry({this.id, required this.exerciseId, required this.weight, required this.reps, required this.date});
}