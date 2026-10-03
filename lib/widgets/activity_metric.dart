import 'package:flutter/material.dart';

/// One colored label + value line next to the activity rings.
class ActivityMetric extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const ActivityMetric(this.label, this.value, this.color, {super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            color: color,
          ),
        ),
        Text(
          value,
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w500),
        ),
      ],
    );
  }
}