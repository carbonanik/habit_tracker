import 'package:flutter/material.dart';
import 'package:flutter_heatmap_calendar/flutter_heatmap_calendar.dart';
import 'package:habit_tracker/components/my_drawer.dart';
import 'package:habit_tracker/components/my_habit_tile.dart';
import 'package:habit_tracker/components/my_heat_map.dart';
import 'package:habit_tracker/database/habit_database.dart';
import 'package:habit_tracker/model/habit.dart';
import 'package:habit_tracker/util/habit_util.dart';
import 'package:provider/provider.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final TextEditingController _habitNameController = TextEditingController();

  void createNewHabit() {
    showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            content: TextField(
                controller: _habitNameController,
                decoration: const InputDecoration(
                  labelText: 'Create a new habit',
                )),
            actions: [
              MaterialButton(
                onPressed: () {
                  String habitName = _habitNameController.text;
                  context.read<HabitDatabase>().addHabit(habitName);
                  Navigator.pop(context);
                  _habitNameController.clear();
                },
                child: const Text("Save"),
              ),
              MaterialButton(
                onPressed: () {
                  Navigator.pop(context);
                  _habitNameController.clear();
                },
                child: const Text("Cancel"),
              )
            ],
          );
        });
  }

  void checkHabitOnOff(bool? value, Habit habit) {
    if (value != null) {
      context.read<HabitDatabase>().updateHabitCompletion(habit.id, value);
    }
  }

  void editHabit(Habit habit) {
    _habitNameController.text = habit.name;

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          content: TextField(
              controller: _habitNameController,
              decoration: const InputDecoration(
                labelText: 'Edit habit',
              )),
          actions: [
            MaterialButton(
              onPressed: () {
                String habitName = _habitNameController.text;
                context.read<HabitDatabase>().updateHabitName(habit.id, habitName);
                Navigator.pop(context);
                _habitNameController.clear();
              },
              child: const Text("Save"),
            ),
            MaterialButton(
              onPressed: () {
                Navigator.pop(context);
                _habitNameController.clear();
              },
              child: const Text("Cancel"),
            )
          ],
        );
      },
    );
  }

  void deleteHabit(Habit habit) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Delete habit"),
          content: Text("Are you sure you want to delete ${habit.name}?"),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text("Cancel"),
            ),
            TextButton(
              onPressed: () {
                context.read<HabitDatabase>().deleteHabit(habit.id);
                Navigator.pop(context);
              },
              child: const Text("Delete"),
            )
          ],
        );
      },
    );
  }

  @override
  void initState() {
    Provider.of<HabitDatabase>(context, listen: false).readHabits();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      appBar: AppBar(
        title: const Text('Habit Tracker'),
      ),
      drawer: const MyDrawer(),
      floatingActionButton: FloatingActionButton(
        onPressed: createNewHabit,
        elevation: 0,
        backgroundColor: Theme.of(context).colorScheme.tertiary,
        child: const Icon(Icons.add),
      ),
      body: ListView(children: [
        // HEAT MAP
        _buildHeatMap(),
        // HABIT LIST
        _buildHabitList(),
      ]),
    );
  }

  Widget _buildHabitList() {
    final habitDatabase = Provider.of<HabitDatabase>(context);
    final habits = habitDatabase.currentHabits;

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: habits.length,
      itemBuilder: (context, index) {
        final habit = habits[index];

        final isCompletedToday = isHabitCompletedToday(habit.completedDays);
        return MyHabitTile(
          text: habit.name,
          isCompleted: isCompletedToday,
          onChange: (value) => checkHabitOnOff(value, habit),
          editHabit: (context) => editHabit(habit),
          deleteHabit: (context) => deleteHabit(habit),
        );
      },
    );
  }

  Widget _buildHeatMap() {
    final habitDatabase = Provider.of<HabitDatabase>(context);

    final habits = habitDatabase.currentHabits;

    return FutureBuilder(
        future: habitDatabase.getFirstLaunchDate(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            return MyHeatMap(
              startDate: snapshot.data!,
              datasets: prepHeatMapDataset(habits),
            );
          }else{
            return Container();
          }
        });
  }
}
