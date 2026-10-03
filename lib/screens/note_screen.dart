import 'package:flutter/cupertino.dart';
import 'package:study_planner_flutter/models/note.dart';
import 'package:study_planner_flutter/screens/note_editor_screen.dart';
import 'package:study_planner_flutter/services/note_store.dart';
import 'package:study_planner_flutter/widgets/delete_background.dart';
import 'package:study_planner_flutter/widgets/ios_widgets.dart';
import 'package:study_planner_flutter/widgets/note_row.dart';

class NotesScreen extends StatefulWidget {
  const NotesScreen({super.key});

  @override
  State<NotesScreen> createState() => _NotesScreenState();
}

class _NotesScreenState extends State<NotesScreen> {
  final _store = NoteStore.instance;
  String _query = '';

  Future<void> _open(Note note) async {
    await Navigator.of(context).push(
      CupertinoPageRoute<void>(builder: (_) => NoteEditorScreen(note: note)),
    );
    _store.changed(note); // removes it if empty, then sorts and saves
  }

  void _create() {
    final note = Note('');
    _store.add(note);
    _open(note);
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: _store,
      builder: (context, _) {
        final q = _query.trim().toLowerCase();
        final shown = _store.notes
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
                      onDismissed: (_) => _store.remove(note),
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
      },
    );
  }
}