import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';

class MyHabitTile extends StatelessWidget {
  final String text;
  final bool isCompleted;
  final void Function(bool? value)? onChange;
  final void Function(BuildContext? context) editHabit;
  final void Function(BuildContext? context) deleteHabit;

  const MyHabitTile({
    required this.text,
    required this.isCompleted,
    required this.onChange,
    required this.editHabit,
    required this.deleteHabit,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 25),
      child: Slidable(
        endActionPane: ActionPane(
          motion: const ScrollMotion(),
          children: [
            SlidableAction(
              onPressed: editHabit,
              icon: Icons.settings,
              backgroundColor: Colors.redAccent.shade100,
            ),
            SlidableAction(
              onPressed: deleteHabit,
              icon: Icons.delete,
              backgroundColor: Colors.redAccent.shade200,
            ),
          ],
        ),
        child: GestureDetector(
          onTap: () {
            onChange?.call(!isCompleted);
          },
          child: Container(
            decoration: BoxDecoration(
              color: isCompleted ? Colors.green : Theme.of(context).colorScheme.secondary,
            ),
            padding: const EdgeInsets.all(12),
            child: ListTile(
                title: Text(text),
                leading: Checkbox(
                  value: isCompleted,
                  onChanged: onChange,
                  activeColor: Colors.green,
                )),
          ),
        ),
      ),
    );
  }
}
