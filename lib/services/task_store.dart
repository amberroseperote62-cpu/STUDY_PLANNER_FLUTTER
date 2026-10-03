import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:study_planner_flutter/models/task.dart';

/// Single source of truth for tasks, saved on the device.
class TaskStore extends ChangeNotifier {
  TaskStore._();
  static final TaskStore instance = TaskStore._();

  static const _key = 'tasks_v1';
  static int get today => DateTime.now().weekday;

  final List<Task> _tasks = [];

  /// Call once from main() before runApp.
  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_key);

    _tasks.clear();
    if (raw == null) {
      // First launch only: sample tasks. Return [] here to start empty.
      _tasks.addAll(_seed());
      await _save();
      return;
    }
    try {
      final list = jsonDecode(raw) as List<dynamic>;
      _tasks.addAll(
        list.map((e) => Task.fromJson(e as Map<String, dynamic>)),
      );
    } catch (e) {
      debugPrint('Could not read saved tasks: $e');
    }
    notifyListeners();
  }

  Future<void> _save() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(
        _key,
        jsonEncode(_tasks.map((t) => t.toJson()).toList()),
      );
    } catch (e) {
      debugPrint('Could not save tasks: $e');
    }
  }

  static List<Task> _seed() {
    final t = DateTime.now().weekday;
    final tomorrow = t % 7 + 1;
    return [
      Task('Finish physics homework', weekday: t),
      Task('Read chapter 4 of Biology', weekday: t),
      Task('Prepare presentation slides', weekday: tomorrow),
      Task('Review flashcards', weekday: t, done: true),
    ];
  }

  // All days
  List<Task> get tasks => List.unmodifiable(_tasks);
  int get completed => _tasks.where((t) => t.done).length;

  // Per day
  List<Task> tasksFor(int weekday) =>
      _tasks.where((t) => t.weekday == weekday).toList();
  List<Task> pendingFor(int weekday) =>
      _tasks.where((t) => t.weekday == weekday && !t.done).toList();
  int remainingFor(int weekday) => pendingFor(weekday).length;
  int totalFor(int weekday) => tasksFor(weekday).length;
  int completedFor(int weekday) => totalFor(weekday) - remainingFor(weekday);

  void add(String title, int weekday) {
    _tasks.insert(0, Task(title, weekday: weekday));
    notifyListeners();
    _save();
  }

  void toggle(Task task) {
    task.done = !task.done;
    notifyListeners();
    _save();
  }

  void remove(Task task) {
    _tasks.remove(task);
    notifyListeners();
    _save();
  }
}