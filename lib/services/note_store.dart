import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:study_planner_flutter/models/note.dart';

/// Notes shared across the app, saved on the device.
class NoteStore extends ChangeNotifier {
  NoteStore._();
  static final NoteStore instance = NoteStore._();

  static const _key = 'notes_v1';
  final List<Note> _notes = [];

  List<Note> get notes => List.unmodifiable(_notes);

  /// Call once from main() before runApp.
  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_key);

    _notes.clear();
    if (raw == null) {
      // First launch only: sample notes. Remove this to start empty.
      _notes.addAll([
        Note('Exam schedule\nMath on Monday, Physics on Wednesday'),
        Note('Study tips\nUse active recall and spaced repetition'),
        Note('Book list\nCampbell Biology, Calculus by Stewart'),
      ]);
      await _save();
    } else {
      try {
        final list = jsonDecode(raw) as List<dynamic>;
        _notes.addAll(
          list.map((e) => Note.fromJson(e as Map<String, dynamic>)),
        );
      } catch (e) {
        debugPrint('Could not read saved notes: $e');
      }
    }
    _sort();
    notifyListeners();
  }

  Future<void> _save() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(
        _key,
        jsonEncode(_notes.map((n) => n.toJson()).toList()),
      );
    } catch (e) {
      debugPrint('Could not save notes: $e');
    }
  }

  void _sort() => _notes.sort((a, b) => b.date.compareTo(a.date));

  /// Adds a new (still empty) note. Not saved until [changed] is called,
  /// so an abandoned blank note never reaches storage.
  void add(Note note) {
    _notes.insert(0, note);
    notifyListeners();
  }

  void remove(Note note) {
    _notes.remove(note);
    notifyListeners();
    _save();
  }

  /// Call after a note was edited. Drops it if empty, re-sorts and saves.
  void changed(Note note) {
    if (note.text.trim().isEmpty) _notes.remove(note);
    _sort();
    notifyListeners();
    _save();
  }
}