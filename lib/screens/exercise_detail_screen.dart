import 'package:flutter/material.dart';
import '../models/exercise.dart';
import '../widgets/add_workout_dialog.dart';
import '../services/database_helper.dart';
import '../models/workout_entry.dart';
import 'package:fl_chart/fl_chart.dart';
import '../widgets/confirm_delete_dialog.dart';

class ExerciseDetailScreen extends StatefulWidget {
  final Exercise exercise;
  
  const ExerciseDetailScreen({super.key, required this.exercise});

  @override
  State<ExerciseDetailScreen> createState() => _ExerciseDetailScreenState();
}

class _ExerciseDetailScreenState extends State<ExerciseDetailScreen> {
  String _timeFilter = 'All Time';
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
          Container(
            padding: EdgeInsets.symmetric(horizontal: 8),
            decoration: BoxDecoration(
              color: Color(0xFF1E1E1E),
              borderRadius: BorderRadius.circular(8),
            ),
            child: DropdownButton<String>(
              value: _timeFilter,
              dropdownColor: Color(0xFF1E1E1E),
              style: TextStyle(color: Colors.white),
              underline: SizedBox(), // Remove underline
              alignment: Alignment.topRight, // Center the text
              items: ['3 Months', '6 Months', '1 Year', 'All Time']
                  .map((filter) => DropdownMenuItem(
                        value: filter, 
                        child: Text(filter, textAlign: TextAlign.center),
                      ))
                  .toList(),
              onChanged: (value) {
                setState(() {
                  _timeFilter = value!;
                });
              },
            ),
          ),
          // Placeholder for graph
          Container(
            height: 200,
            padding: EdgeInsets.all(16),
            child: FutureBuilder<List<WorkoutEntry>>(
              future: DatabaseHelper().getWorkoutEntries(widget.exercise.id!),
              builder: (context, snapshot) {
                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return Center(child: Text('No data for chart', style: TextStyle(color: Colors.white)));
                }

                final allEntries = snapshot.data!;

                // Filter based on time range
                final cutoffDate = _timeFilter == 'All Time' ? null :
                                   _timeFilter == '3 Months' ? DateTime.now().subtract(Duration(days: 90)) :
                                   _timeFilter == '6 Months' ? DateTime.now().subtract(Duration(days: 180)) :
                                   DateTime.now().subtract(Duration(days: 365));

                final entries = cutoffDate == null 
                    ? allEntries 
                    : allEntries.where((e) => e.date.isAfter(cutoffDate)).toList();

                entries.sort((a, b) => a.date.compareTo(b.date)); // Oldest first

                if (entries.isEmpty) {
                  return Center(child: Text('No data for this time range', style: TextStyle(color: Colors.white)));
                }

                final spots = entries.isEmpty 
                  ? [FlSpot(0, 0)] // Placeholder spot to show empty graph
                  : entries.asMap().entries.map((entry) {
                      return FlSpot(entry.key.toDouble(), entry.value.weight);
                    }).toList();

                return LineChart(
                  LineChartData(
                    lineBarsData: [
                      LineChartBarData(
                        spots: spots,
                        isCurved: true,
                        color: Colors.white,
                        dotData: FlDotData(show: entries.isNotEmpty),
                      ),
                    ],
                    backgroundColor: Color(0xFF1E1E1E),
                    titlesData: FlTitlesData(
                      leftTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          reservedSize: 40,
                          getTitlesWidget: (value, meta) {
                            return Text('${value.toInt()}kg', 
                                       style: TextStyle(color: Colors.white70, fontSize: 10));
                          },
                        ),
                      ),
                      bottomTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          getTitlesWidget: (value, meta) {
                            if (value.toInt() >= entries.length) return Text('');
                            final date = entries[value.toInt()].date;
                            return Text('${date.month}/${date.day}',
                                       style: TextStyle(color: Colors.white70, fontSize: 10));
                          },
                        ),
                      ),
                      topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                      rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    ),
                    minY: 0,
                    maxY: entries.isEmpty ? 100 : (spots.map((s) => s.y).reduce((a, b) => a > b ? a : b) * 1.2),
                  ),
                );
              },
            ),
          ),
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
                                trailing: IconButton(
                                  icon: Icon(Icons.delete, color: Colors.grey),
                                  onPressed: () {
                                    showDialog(
                                      context: context,
                                      builder: (context) => ConfirmDeleteDialog(
                                        title: 'Delete Workout Entry',
                                        content: 'Are you sure you want to delete this workout entry?',
                                        onConfirm: () async {
                                          await DatabaseHelper().deleteWorkoutEntry(entry.id!);
                                          setState(() {});
                                        },
                                      ),
                                    );
                                  },
                                ),
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
          
          // Spacer(),
          
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