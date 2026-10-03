import 'package:flutter/material.dart';

/// Round Start / Cancel / Pause button like the iOS Clock timer.
class CircleButton extends StatelessWidget {
  final String label;
  final Color background;
  final Color textColor;
  final VoidCallback? onTap;

  const CircleButton({
    super.key,
    required this.label,
    required this.background,
    required this.textColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Opacity(
        opacity: onTap == null ? 0.5 : 1,
        child: Container(
          width: 84,
          height: 84,
          alignment: Alignment.center,
          decoration: BoxDecoration(shape: BoxShape.circle, color: background),
          child: Text(
            label,
            style: TextStyle(fontSize: 17, color: textColor),
          ),
        ),
      ),
    );
  }
}