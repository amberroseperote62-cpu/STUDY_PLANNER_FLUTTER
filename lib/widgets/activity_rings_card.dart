import 'package:flutter/material.dart';
import 'package:study_planner_flutter/widgets/activity_metric.dart';
import 'package:study_planner_flutter/widgets/ios_widgets.dart';

/// Apple Activity-style card: three rings plus their numbers.
class ActivityRingsCard extends StatelessWidget {
  final int focus;
  final int focusGoal;
  final int tasks;
  final int tasksGoal;
  final int sessions;
  final int sessionsGoal;

  const ActivityRingsCard({
    super.key,
    required this.focus,
    required this.focusGoal,
    required this.tasks,
    required this.tasksGoal,
    required this.sessions,
    required this.sessionsGoal,
  });

  double _ratio(int value, int goal) => goal == 0 ? 0 : value / goal;

  @override
  Widget build(BuildContext context) {
    return IosCard(
      child: Row(
        children: [
          SizedBox(
            width: 120,
            height: 120,
            child: CustomPaint(
              painter: RingPainter(
                progress: [
                  _ratio(focus, focusGoal),
                  _ratio(tasks, tasksGoal),
                  _ratio(sessions, sessionsGoal),
                ],
                colors: const [Ios.pink, Ios.green, Ios.teal],
                stroke: 14,
              ),
            ),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ActivityMetric('Focus', '$focus/$focusGoal min', Ios.pink),
                const SizedBox(height: 12),
                ActivityMetric('Tasks', '$tasks/$tasksGoal', Ios.green),
                const SizedBox(height: 12),
                ActivityMetric('Sessions', '$sessions/$sessionsGoal', Ios.teal),
              ],
            ),
          ),
        ],
      ),
    );
  }
}