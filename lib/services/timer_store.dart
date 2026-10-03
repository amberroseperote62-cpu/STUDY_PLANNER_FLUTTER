import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Tracks today's focus minutes and completed Pomodoro sessions.
/// Resets automatically when the date changes.
class TimerStore extends ChangeNotifier {
  TimerStore._();
  static final TimerStore instance = TimerStore._();

  static const _keyMinutes = 'timer_minutes_v1';
  static const _keyDate = 'timer_date_v1';
  static const _keySessions = 'timer_sessions_v1';

  int _focusMinutes = 0;
  int _sessions = 0;

  int get focusMinutes => _focusMinutes;
  int get sessions => _sessions;

  /// Load persisted data; call from main() before runApp.
  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    final today = _todayKey();

    // Reset if date has changed.
    if (prefs.getString(_keyDate) != today) {
      await prefs.setString(_keyDate, today);
      await prefs.setInt(_keyMinutes, 0);
      await prefs.setInt(_keySessions, 0);
    }

    _focusMinutes = prefs.getInt(_keyMinutes) ?? 0;
    _sessions = prefs.getInt(_keySessions) ?? 0;
    notifyListeners();
  }

  /// Call when a timer session completes (or is started — your choice).
  Future<void> recordSession(int durationSeconds) async {
    final minutes = (durationSeconds / 60).round();
    _focusMinutes += minutes;
    _sessions += 1;
    notifyListeners();

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyDate, _todayKey());
    await prefs.setInt(_keyMinutes, _focusMinutes);
    await prefs.setInt(_keySessions, _sessions);
  }

  static String _todayKey() {
    final now = DateTime.now();
    return '${now.year}-${now.month}-${now.day}';
  }
}
