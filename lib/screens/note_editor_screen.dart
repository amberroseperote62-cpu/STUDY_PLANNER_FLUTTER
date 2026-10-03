import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:study_planner_flutter/widgets/ios_widgets.dart';
import 'package:study_planner_flutter/models/note.dart';

/// Full-screen note editor, pushed from the Notes list.
class NoteEditorScreen extends StatefulWidget {
  final Note note;
  const NoteEditorScreen({super.key, required this.note});

  @override
  State<NoteEditorScreen> createState() => _NoteEditorScreenState();
}

class _NoteEditorScreenState extends State<NoteEditorScreen> {
  late final TextEditingController _controller =
      TextEditingController(text: widget.note.text);

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final surface = iosSurface(context);

    return CupertinoPageScaffold(
      backgroundColor: surface,
      navigationBar: CupertinoNavigationBar(
        previousPageTitle: 'Notes',
        backgroundColor: surface.withValues(alpha: 0.9),
        trailing: CupertinoButton(
          padding: EdgeInsets.zero,
          minimumSize: Size.zero,
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Done'),
        ),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: CupertinoTextField(
            controller: _controller,
            autofocus: widget.note.text.isEmpty,
            maxLines: null,
            expands: true,
            textAlignVertical: TextAlignVertical.top,
            decoration: null,
            padding: EdgeInsets.zero,
            placeholder: 'Start typing…',
            style: TextStyle(
              fontSize: 17,
              color: Theme.of(context).colorScheme.onSurface,
            ),
            onChanged: (v) {
              widget.note.text = v;
              widget.note.date = DateTime.now();
            },
          ),
        ),
      ),
    );
  }
}