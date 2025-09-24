import 'package:flutter/material.dart';
import '../models/exercise.dart';
import '../widgets/add_workout_dialog.dart';

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
      ),
      body: Column(
        children: [
          // Placeholder for graph
          Container(
            height: 300,
            margin: EdgeInsets.all(16),
            color: Color(0xFF1E1E1E),
            child: Center(
              child: Text('Graph goes here', style: TextStyle(color: Colors.white)),
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
                    onAdd: (workoutEntry) {
                      // TODO: Save to database and refresh
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