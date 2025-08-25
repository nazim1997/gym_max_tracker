import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'models/exercise.dart';
import 'screens/home_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Hive.initFlutter();
  Hive.registerAdapter(ExerciseAdapter());
  await Hive.openBox<Exercise>('exercises');

  runApp(const GymMaxTrackerApp());
}

class GymMaxTrackerApp extends StatelessWidget {
  const GymMaxTrackerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: HomeScreen(),
    );
  }
}