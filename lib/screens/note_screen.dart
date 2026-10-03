import 'package:flutter/cupertino.dart';
import 'package:study_planner_flutter/widgets/note_row.dart';
import 'package:study_planner_flutter/screens/note_editor_screen.dart';
import 'package:study_planner_flutter/widgets/delete_background.dart';
import 'package:study_planner_flutter/widgets/ios_widgets.dart';
import 'package:study_planner_flutter/models/note.dart';

class NotesScreen extends StatefulWidget {
  const NotesScreen({super.key});

  @override
  State<NotesScreen> createState() => _NotesScreenState();
}

class _NotesScreenState extends State<NotesScreen> {
  final List<Note> _notes = [
    Note('Exam schedule\nMath on Monday, Physics on Wednesday'),
    Note('Study tips\nUse active recall and spaced repetition'),
    Note('Book list\nCampbell Biology, Calculus by Stewart'),
  ];
  String _query = '';

  Future<void> _open(Note note) async {
    await Navigator.of(context).push(
      CupertinoPageRoute<void>(builder: (_) => NoteEditorScreen(note: note)),
    );
    if (!mounted) return;
    setState(() {
      if (note.text.trim().isEmpty) _notes.remove(note);
      _notes.sort((a, b) => b.date.compareTo(a.date));
    });
  }

  void _create() {
    final note = Note('');
    setState(() => _notes.insert(0, note));
    _open(note);
  }

  @override
  Widget build(BuildContext context) {
    final q = _query.trim().toLowerCase();
    final shown = _notes
        .where((n) => q.isEmpty || n.text.toLowerCase().contains(q))
        .toList();

    return IosPage(
      title: 'Notes',
      trailing: CupertinoButton(
        padding: EdgeInsets.zero,
        minimumSize: Size.zero,
        onPressed: _create,
        child: const Icon(CupertinoIcons.square_pencil, size: 24),
      ),
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
          child: CupertinoSearchTextField(
            onChanged: (v) => setState(() => _query = v),
          ),
        ),
        if (shown.isNotEmpty)
          IosSection(
            children: [
              for (final note in shown)
                Dismissible(
                  key: ObjectKey(note),
                  direction: DismissDirection.endToStart,
                  background: const DeleteBackground(),
                  onDismissed: (_) => setState(() => _notes.remove(note)),
                  child: NoteRow(note: note, onTap: () => _open(note)),
                ),
            ],
          ),
        Padding(
          padding: const EdgeInsets.only(top: 12),
          child: Center(
            child: Text(
              shown.isEmpty
                  ? 'No Notes'
                  : '${shown.length} Note${shown.length == 1 ? '' : 's'}',
              style: TextStyle(fontSize: 13, color: iosSecondary(context)),
            ),
          ),
        ),
      ],
    );
  }
}