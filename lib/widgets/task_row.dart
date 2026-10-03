import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:study_planner_flutter/widgets/ios_widgets.dart';
import 'package:study_planner_flutter/models/task.dart';

/// A Reminders-style row with a circular checkbox.
class TaskRow extends StatelessWidget {
  final Task task;
  final VoidCallback onToggle;

  const TaskRow({super.key, required this.task, required this.onToggle});

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;

    return Container(
      color: iosSurface(context),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: onToggle,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 150),
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: task.done ? primary : Colors.transparent,
                border: Border.all(
                  color: task.done ? primary : iosTertiary(context),
                  width: 1.5,
                ),
              ),
              child: task.done
                  ? const Icon(CupertinoIcons.checkmark,
                      size: 14, color: Colors.white)
                  : null,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              task.title,
              style: TextStyle(
                fontSize: 17,
                color: task.done ? iosSecondary(context) : null,
              ),
            ),
          ),
        ],
      ),
    );
  }
}