// given a habit list of completion days
// is the habit completed today
import 'package:habit_tracker/model/habit.dart';

bool isHabitCompletedToday(List<DateTime> completedDays) {
  final today = DateTime.now();
  return completedDays
      .any((element) => element.year == today.year && element.month == today.month && element.day == today.day);
}

// prepare heatmap project
Map<DateTime, int> prepHeatMapDataset(List<Habit> habits) {
  final dataset = <DateTime, int>{};

  for (final habit in habits) {
    for (final day in habit.completedDays) {
      final normalizedDay = DateTime(day.year, day.month, day.day);

      if (dataset.containsKey(normalizedDay)) {
        dataset[normalizedDay] = dataset[normalizedDay]! + 1;
      } else {
        dataset[normalizedDay] = 1;
      }
    }
  }
  return dataset;
}
