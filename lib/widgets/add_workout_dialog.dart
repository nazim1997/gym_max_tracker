import 'package:flutter/material.dart';
import '../models/workout_entry.dart';

class AddWorkoutDialog extends StatefulWidget {
  final Function(WorkoutEntry) onAdd;
  final int exerciseId;
  
  const AddWorkoutDialog({super.key, required this.onAdd, required this.exerciseId});

  @override
  State<AddWorkoutDialog> createState() => _AddWorkoutDialogState();
}

class _AddWorkoutDialogState extends State<AddWorkoutDialog> {
  final _weightController = TextEditingController();
  final _repsController = TextEditingController();
  DateTime _selectedDate = DateTime.now();

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Add Workout Entry'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: _weightController,
            decoration: InputDecoration(labelText: 'Weight (kg)'),
            keyboardType: TextInputType.number,
          ),
          TextField(
            controller: _repsController,
            decoration: InputDecoration(labelText: 'Reps'),
            keyboardType: TextInputType.number,
          ),
          // We'll add date picker later
          SizedBox(height: 16),
          Row(
            children: [
              Text('Date: '),
              TextButton(
                onPressed: () async {
                  final date = await showDatePicker(
                    context: context,
                    initialDate: _selectedDate,
                    firstDate: DateTime(2020),
                    lastDate: DateTime.now(),
                  );
                  if (date != null) {
                    setState(() => _selectedDate = date);
                  }
                },
                child: Text('${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}'),
              ),
            ],
          ),
        ],
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: Text('Cancel')),
        TextButton(
          onPressed: () {
            if (_weightController.text.isNotEmpty && _repsController.text.isNotEmpty) {
              final workoutEntry = WorkoutEntry(
                exerciseId: widget.exerciseId,
                weight: double.parse(_weightController.text),
                reps: int.parse(_repsController.text),
                date: _selectedDate,
              );
              widget.onAdd(workoutEntry);
              Navigator.pop(context);
            }
          },
          child: Text('Add Record'),
        ),
      ],
    );
  }
}