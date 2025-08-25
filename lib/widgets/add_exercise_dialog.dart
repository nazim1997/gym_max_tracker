import 'package:flutter/material.dart';
import '../models/exercise.dart';

class AddExerciseDialog extends StatefulWidget {
  final void Function(Exercise) onAdd;

  const AddExerciseDialog({super.key, required this.onAdd});

  @override
  State<AddExerciseDialog> createState() => _AddExerciseDialogState();
}

class _AddExerciseDialogState extends State<AddExerciseDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _maxController = TextEditingController();
  final _repsController = TextEditingController();
  String _selectedCategory = "Chest";

  final categories = [
    "Biceps",
    "Triceps",
    "Forearms",
    "Shoulders",
    "Chest",
    "Back",
    "Legs",
    "Abdomen",
  ];

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: const Color(0xFF1E1E1E),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: const Text("Add Exercise", style: TextStyle(color: Colors.white)),
      content: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: "Exercise Name",
                  labelStyle: TextStyle(color: Colors.white70),
                ),
                style: const TextStyle(color: Colors.white),
                validator: (val) =>
                    val == null || val.isEmpty ? "Enter exercise name" : null,
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                value: _selectedCategory,
                dropdownColor: Colors.black,
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(
                  labelText: "Category",
                  labelStyle: TextStyle(color: Colors.white70),
                ),
                items: categories
                    .map((c) => DropdownMenuItem(
                          value: c,
                          child: Text(c),
                        ))
                    .toList(),
                onChanged: (val) {
                  if (val != null) {
                    setState(() => _selectedCategory = val);
                  }
                },
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _maxController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: "Max Weight (kg)",
                  labelStyle: TextStyle(color: Colors.white70),
                ),
                style: const TextStyle(color: Colors.white),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _repsController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: "Repetitions",
                  labelStyle: TextStyle(color: Colors.white70),
                ),
                style: const TextStyle(color: Colors.white),
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text("Cancel", style: TextStyle(color: Colors.white70)),
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.white,
            foregroundColor: Colors.black,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
          onPressed: () {
            if (_formKey.currentState!.validate()) {
              widget.onAdd(Exercise(
                name: _nameController.text,
                category: _selectedCategory,
                max: _maxController.text.isEmpty
                    ? null
                    : "${_maxController.text}kg",
                reps: _repsController.text.isEmpty
                    ? null
                    : _repsController.text,
              ));
              Navigator.pop(context);
            }
          },
          child: const Text("Add"),
        ),
      ],
    );
  }
}
