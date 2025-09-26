import 'package:flutter/material.dart';
import '../models/exercise.dart';
import '../widgets/add_workout_dialog.dart';
import '../services/database_helper.dart';
import '../models/workout_entry.dart';

class ExerciseDetailScreen extends StatefulWidget {
  final Exercise exercise;
  
  const ExerciseDetailScreen({super.key, required this.exercise});

  @override
  State<ExerciseDetailScreen> createState() => _ExerciseDetailScreenState();
}

class _ExerciseDetailScreenState extends State<ExerciseDetailScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Text(widget.exercise.name),
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context, true),
        ),
      ),
      body: Column(
        children: [
          // Placeholder for graph
          Expanded(
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Workout History', style: TextStyle(color: Colors.white, fontSize: 18)),
                  SizedBox(height: 16),
                  Expanded(
                    child: FutureBuilder<List<WorkoutEntry>>(
                      future: DatabaseHelper().getWorkoutEntries(widget.exercise.id!),
                      builder: (context, snapshot) {
                        if (!snapshot.hasData) return CircularProgressIndicator();

                        final entries = snapshot.data!;
                        if (entries.isEmpty) {
                          return Text('No workout records', style: TextStyle(color: Colors.white70));
                        }

                        return ListView.builder(
                          itemCount: entries.length,
                          itemBuilder: (context, index) {
                            final entry = entries[index];
                            return Card(
                              color: Color(0xFF1E1E1E),
                              child: ListTile(
                                title: Text('${entry.weight}kg × ${entry.reps} reps', 
                                           style: TextStyle(color: Colors.white)),
                                subtitle: Text('${entry.date.day}/${entry.date.month}/${entry.date.year}',
                                             style: TextStyle(color: Colors.white70)),
                              ),
                            );
                          },
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
          
          Spacer(),
          
          // Add Max Weight button
          Padding(
            padding: EdgeInsets.all(16),
            child: ElevatedButton(
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (context) => AddWorkoutDialog(
                    exerciseId: widget.exercise.id!,
                    onAdd: (workoutEntry) async {
                      await DatabaseHelper().insertWorkoutEntry(workoutEntry);
                      // Refresh the screen to show updated data
                      setState(() {});
                    },
                  ),
                );
              },
              child: Text('Add Max Weight'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: Colors.black,
                minimumSize: Size(double.infinity, 50),
              ),
            ),
          ),
        ],
      ),
    );
  }
}