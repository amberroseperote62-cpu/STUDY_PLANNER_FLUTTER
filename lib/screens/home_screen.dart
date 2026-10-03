import 'dart:math' as math;

import 'package:flutter/cupertino.dart';
import 'package:study_planner_flutter/services/task_store.dart';
import 'package:study_planner_flutter/widgets/activity_rings_card.dart';
import 'package:study_planner_flutter/widgets/ios_widgets.dart';
import 'package:study_planner_flutter/widgets/stat_card.dart';
import 'package:study_planner_flutter/services/profile_store.dart';

class HomeScreen extends StatelessWidget {
  final String studentName;
  final VoidCallback? onAddTask;
  final VoidCallback? onStartTimer;

  const HomeScreen({
    super.key,
    this.studentName = 'Student',
    this.onAddTask,
    this.onStartTimer,
  });

  static const _days = [
    'Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'
  ];
  static const _months = [
    'January', 'February', 'March', 'April', 'May', 'June', 'July',
    'August', 'September', 'October', 'November', 'December'
  ];

  static String _greeting(int hour) {
    if (hour < 12) return 'Good morning';
    if (hour < 17) return 'Good afternoon';
    return 'Good evening';
  }

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final _ = '${_greeting(now.hour)}, $studentName';
    final date =
        '${_days[now.weekday - 1]}, ${_months[now.month - 1]} ${now.day}'
            .toUpperCase();
    final store = TaskStore.instance;

    return Stack(
      children: [
        ListenableBuilder(
          listenable: Listenable.merge([store, ProfileStore.instance]),
          builder: (context, _) {
            final greeting = '${_greeting(now.hour)}, ${ProfileStore.instance.name}';
            final today = TaskStore.today;
            final upNext = store.pendingFor(today).take(3).toList();

            return IosPage(
              title: 'Today',
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(32, 4, 16, 0),
                  child: Text(
                    greeting,
                    style: const TextStyle(
                        fontSize: 22, fontWeight: FontWeight.w600),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(32, 2, 16, 0),
                  child: Text(
                    date,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: iosSecondary(context),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                  child: ActivityRingsCard(
                    focus: 78,
                    focusGoal: 120,
                    tasks: store.completedFor(today),
                    tasksGoal: math.max(1, store.totalFor(today)),
                    sessions: 2,
                    sessionsGoal: 5,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                  child: Row(
                    children: [
                      const Expanded(
                        child: StatCard(
                          icon: CupertinoIcons.flame_fill,
                          color: Ios.orange,
                          label: 'Streak',
                          value: '7 days',
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: StatCard(
                          icon: CupertinoIcons.checkmark_circle_fill,
                          color: Ios.green,
                          label: 'Completed',
                          value: '${store.completed} tasks',
                        ),
                      ),
                    ],
                  ),
                ),
                IosSection(
                  header: 'Up Next',
                  children: [
                    if (upNext.isEmpty)
                      const IosRow(
                        icon: CupertinoIcons.checkmark_seal_fill,
                        iconColor: Ios.green,
                        title: 'All caught up',
                        value: '',
                      )
                    else
                      for (final t in upNext)
                        IosRow(
                          icon: CupertinoIcons.book_fill,
                          iconColor: Ios.blue,
                          title: t.title,
                          value: 'To do',
                          chevron: true,
                        ),
                  ],
                ),
                // Lets the last rows scroll above the floating buttons.
                const SizedBox(height: 90),
              ],
            );
          },
        ),
        Positioned(
          left: 16,
          right: 16,
          bottom: MediaQuery.of(context).padding.bottom + 16,
          child: Row(
            children: [
              Expanded(
                child: _FloatingAction(
                  icon: CupertinoIcons.add_circled_solid,
                  label: 'Add Task',
                  filled: true,
                  onPressed: onAddTask,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _FloatingAction(
                  icon: CupertinoIcons.timer_fill,
                  label: 'Start Timer',
                  filled: false,
                  onPressed: onStartTimer,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _FloatingAction extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool filled;
  final VoidCallback? onPressed;

  const _FloatingAction({
    required this.icon,
    required this.label,
    required this.filled,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    final primary = CupertinoTheme.of(context).primaryColor;
    final fg = filled ? CupertinoColors.white : primary;
    final bg = filled
        ? primary
        : CupertinoColors.secondarySystemGroupedBackground
            .resolveFrom(context);

    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        boxShadow: const [
          BoxShadow(
            color: Color(0x33000000),
            blurRadius: 16,
            offset: Offset(0, 6),
          ),
        ],
      ),
      child: CupertinoButton(
        padding: const EdgeInsets.symmetric(vertical: 14),
        borderRadius: BorderRadius.circular(28),
        color: bg,
        disabledColor: bg, // stays solid even when onPressed is null
        onPressed: onPressed,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 20, color: fg),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(color: fg, fontWeight: FontWeight.w600),
            ),
          ],
        ),
      ),
    );
  }
}