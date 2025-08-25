import 'package:flutter/material.dart';
import 'screens/home_screen.dart';

void main() {
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
