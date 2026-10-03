import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:study_planner_flutter/models/task.dart';
import 'package:study_planner_flutter/services/task_store.dart';
import 'package:study_planner_flutter/widgets/delete_background.dart';
import 'package:study_planner_flutter/widgets/ios_widgets.dart';
import 'package:study_planner_flutter/widgets/task_row.dart';

class TasksScreen extends StatefulWidget {
  const TasksScreen({super.key});

  @override
  State<TasksScreen> createState() => _TasksScreenState();
}

class _TasksScreenState extends State<TasksScreen> {
  final _store = TaskStore.instance;
  int _selected = TaskStore.today;

  static const _dayNames = {
    1: 'Monday',
    2: 'Tuesday',
    3: 'Wednesday',
    4: 'Thursday',
    5: 'Friday',
    6: 'Saturday',
    7: 'Sunday',
  };

  Future<void> _add() async {
    final controller = TextEditingController();
    final text = await showCupertinoDialog<String>(
      context: context,
      builder: (ctx) => CupertinoAlertDialog(
        title: Text('New Reminder · ${_dayNames[_selected]}'),
        content: Padding(
          padding: const EdgeInsets.only(top: 12),
          child: CupertinoTextField(
            controller: controller,
            autofocus: true,
            placeholder: 'Title',
            textCapitalization: TextCapitalization.sentences,
          ),
        ),
        actions: [
          CupertinoDialogAction(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          CupertinoDialogAction(
            isDefaultAction: true,
            onPressed: () => Navigator.pop(ctx, controller.text.trim()),
            child: const Text('Add'),
          ),
        ],
      ),
    );
    controller.dispose();

    if (text != null && text.isNotEmpty) _store.add(text, _selected);
  }

  void _toggle(Task task) {
    HapticFeedback.selectionClick();
    _store.toggle(task);
  }

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;

    return ListenableBuilder(
      listenable: _store,
      builder: (context, _) {
        final dayTasks = _store.tasksFor(_selected);
        final sorted = [
          ...dayTasks.where((t) => !t.done),
          ...dayTasks.where((t) => t.done),
        ];

        return IosPage(
          title: 'Tasks',
          trailing: CupertinoButton(
            padding: EdgeInsets.zero,
            minimumSize: Size.zero,
            onPressed: _add,
            child: const Icon(CupertinoIcons.plus_circle, size: 26),
          ),
          children: [
            _WeekdayBar(
              selected: _selected,
              today: TaskStore.today,
              hasPending: (d) => _store.remainingFor(d) > 0,
              onSelected: (d) {
                HapticFeedback.selectionClick();
                setState(() => _selected = d);
              },
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(32, 12, 16, 0),
              child: Text(
                _dayNames[_selected]!.toUpperCase(),
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: iosSecondary(context),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(32, 0, 16, 0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '${_store.remainingFor(_selected)}',
                    style: TextStyle(
                      fontSize: 44,
                      fontWeight: FontWeight.w700,
                      color: primary,
                      height: 1.1,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Text(
                      'Remaining',
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w600,
                        color: iosSecondary(context),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            if (sorted.isEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 60),
                child: Center(
                  child: Text(
                    'No Reminders',
                    style:
                        TextStyle(fontSize: 17, color: iosSecondary(context)),
                  ),
                ),
              )
            else
              IosSection(
                children: [
                  for (final task in sorted)
                    Dismissible(
                      key: ObjectKey(task),
                      direction: DismissDirection.endToStart,
                      background: const DeleteBackground(),
                      onDismissed: (_) => _store.remove(task),
                      child: TaskRow(
                        task: task,
                        onToggle: () => _toggle(task),
                      ),
                    ),
                ],
              ),
          ],
        );
      },
    );
  }
}

/// S M T W Th F S selector. Sunday first, like the iOS calendar.
class _WeekdayBar extends StatelessWidget {
  final int selected;
  final int today;
  final bool Function(int weekday) hasPending;
  final ValueChanged<int> onSelected;

  const _WeekdayBar({
    required this.selected,
    required this.today,
    required this.hasPending,
    required this.onSelected,
  });

  // DateTime weekday numbers in display order (Sunday = 7 comes first).
  static const _order = [7, 1, 2, 3, 4, 5, 6];
  static const _labels = ['S', 'M', 'T', 'W', 'Th', 'F', 'S'];

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;
    final label = CupertinoColors.label.resolveFrom(context);

    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 0),
      child: Row(
        children: [
          for (var i = 0; i < 7; i++)
            Expanded(
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () => onSelected(_order[i]),
                child: Column(
                  children: [
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 150),
                      width: 40,
                      height: 40,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: _order[i] == selected
                            ? primary
                            : const Color(0x00000000),
                      ),
                      child: Text(
                        _labels[i],
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: _order[i] == selected
                              ? CupertinoColors.white
                              : (_order[i] == today ? primary : label),
                        ),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Container(
                      width: 5,
                      height: 5,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: hasPending(_order[i])
                            ? primary
                            : const Color(0x00000000),
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}