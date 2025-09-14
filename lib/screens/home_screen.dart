import 'package:flutter/material.dart';
import '../models/exercise.dart';
import '../widgets/add_exercise_dialog.dart';
import '../services/database_helper.dart';
import '../models/workout_entry.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<Exercise> _exercises = [];

  String _selectedCategory = "All";

  final categories = [
    "All",
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
  void initState() {
    super.initState();
    _loadExercises();
  }

  void _loadExercises() async {
    final exercises = await DatabaseHelper().getAllExercises();
    setState(() {
      _exercises = exercises;
    });
    if (_exercises.isNotEmpty) {
      await DatabaseHelper().insertWorkoutEntry(
        WorkoutEntry(exerciseId: 1, weight: 80.0, reps: 8, date: DateTime.now())
      );
    }
  }
  
  @override
  Widget build(BuildContext context) {
    final filtered = _selectedCategory == "All"
        ? _exercises
        : _exercises
            .where((e) => e.category == _selectedCategory)
            .toList();

    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Max Tracker",
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        "Track your lifting progress",
                        style: TextStyle(color: Colors.white70),
                      ),
                    ],
                  ),
                  ElevatedButton.icon(
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (context) => AddExerciseDialog(
                          onAdd: (exercise) async{
                            await DatabaseHelper().insertExercise(exercise);
                            _loadExercises();
                          },
                        ),
                      );
                    },
                    icon: const Icon(Icons.add),
                    label: const Text("Add"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: Colors.black,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                  )
                ],
              ),
              const SizedBox(height: 20),

              // Filter Chips
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: categories.map((cat) {
                    final selected = _selectedCategory == cat;
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      child: ChoiceChip(
                        label: Text(cat),
                        labelStyle: TextStyle(
                          color: selected ? Colors.black : Colors.white,
                        ),
                        selected: selected,
                        selectedColor: Colors.white,
                        backgroundColor: const Color(0xFF1E1E1E),
                        onSelected: (_) {
                          setState(() => _selectedCategory = cat);
                        },
                      ),
                    );
                  }).toList(),
                ),
              ),
              const SizedBox(height: 20),

              // Exercise List
              Expanded(
                child: ListView.builder(
                  itemCount: filtered.length,
                  itemBuilder: (context, index) {
                    final e = filtered[index];
                    return Card(
                      color: const Color(0xFF1E1E1E),
                      margin: const EdgeInsets.symmetric(vertical: 8),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: ListTile(
                        title: Text(
                          e.name,
                          style: const TextStyle(color: Colors.white),
                        ),
                        subtitle: Text(
                          "Max: No records",
                          style: const TextStyle(color: Colors.white70),
                        ),
                        trailing: IconButton(
                          icon: const Icon(Icons.show_chart,
                              color: Colors.white70),
                          onPressed: () {
                            // TODO: graph screen
                          },
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
