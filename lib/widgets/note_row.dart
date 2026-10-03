import 'package:flutter/material.dart';
import 'package:study_planner_flutter/widgets/ios_widgets.dart';
import 'package:study_planner_flutter/models/note.dart';

/// A Notes-style list row: bold title, then date and preview.
class NoteRow extends StatelessWidget {
  final Note note;
  final VoidCallback onTap;

  const NoteRow({super.key, required this.note, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final secondary = iosSecondary(context);

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Container(
        color: iosSurface(context),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              note.title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 2),
            Row(
              children: [
                Text(note.dateLabel,
                    style: TextStyle(fontSize: 15, color: secondary)),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    note.preview,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(fontSize: 15, color: secondary),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}