import 'package:flutter/widgets.dart';
import 'package:habit_tracker/model/app_settings.dart';
import 'package:habit_tracker/model/habit.dart';
import 'package:isar/isar.dart';
import 'package:path_provider/path_provider.dart';

class HabitDatabase extends ChangeNotifier {
  static late Isar isar;

  /// ? S E T U P

  // I N I T I A L I Z E -- D A T A B A S E
  static Future<void> initialize() async {
    final dir = await getApplicationDocumentsDirectory();
    isar = await Isar.open(
      [HabitSchema, AppSettingsSchema],
      directory: dir.path,
    );
  }

  // save first date of the app startup
  Future<void> saveFirstLaunchDate() async {
    final existingSettings = await isar.appSettings.where().findFirst();
    if (existingSettings == null) {
      final settings = AppSettings()..firstLaunchDate = DateTime.now();
      await isar.writeTxn(() => isar.appSettings.put(settings));
    }
  }

  // get first date of app startup
  Future<DateTime?> getFirstLaunchDate() async {
    final settings = await isar.appSettings.where().findFirst();
    return settings?.firstLaunchDate;
  }

  /// ? C R U D -- H A B I T

  // List of habits
  List<Habit> currentHabits = [];

  // C R E A T E -- add a new habit
  Future<void> addHabit(String habitName) async {
    final newHabit = Habit()..name = habitName;
    await isar.writeTxn(() => isar.habits.put(newHabit));
    readHabits();
  }

  // R E A D -- read saved habits form database
  Future<void> readHabits() async {
    final fetchedHabit = await isar.habits.where().findAll();
    currentHabits.clear();
    currentHabits.addAll(fetchedHabit);
    notifyListeners();
  }

  // U P D A T E -- check habit on and off
  Future<void> updateHabitCompletion(int id, bool isCompleted) async {
    final habit = await isar.habits.get(id);

    if (habit != null) {
      await isar.writeTxn(
        () async {
          final today = DateTime.now();

          // habit is completed add the current date to completed days list
          if (isCompleted && !habit.completedDays.contains(DateTime.now())) {
            habit.completedDays.add(
              DateTime(today.year, today.month, today.day),
            );
          }
          // habit is not completed remove the current date from completed days
          else {
            habit.completedDays.removeWhere(
              (date) => date.year == today.year && date.month == today.month && date.day == today.day,
            );
          }
          // save updated habit back to database
          await isar.habits.put(habit);
          readHabits();
        },
      );
    }
  }

  // U P D A T E -- edit habit name
  Future<void> updateHabitName(int id, String newName) async {
    final habit = await isar.habits.get(id);
    if (habit != null) {
      await isar.writeTxn(() async {
        habit.name = newName;
        await isar.habits.put(habit);
      });
    }

    // refresh habits
    readHabits();
  }

  // D E L E T E -- delete habit
  Future<void> deleteHabit(int id) async {
    await isar.writeTxn(() async {
      await isar.habits.delete(id);
    });

    // refresh habits
    readHabits();
  }
}
