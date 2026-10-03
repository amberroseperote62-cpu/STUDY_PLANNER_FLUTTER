import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Profile + settings shared across screens, saved on the device.
class ProfileStore extends ChangeNotifier {
  ProfileStore._();
  static final ProfileStore instance = ProfileStore._();

  String _name = 'Student';
  int _dailyGoalMinutes = 120;
  int _focusMinutes = 25;
  bool _notifications = true;
  bool _sounds = true;
  bool _focusMode = false;

  String get name => _name;
  int get dailyGoalMinutes => _dailyGoalMinutes;
  int get focusMinutes => _focusMinutes;
  bool get notifications => _notifications;
  bool get sounds => _sounds;
  bool get focusMode => _focusMode;

  /// Call once from main() before runApp.
  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    _name = prefs.getString('profile_name') ?? _name;
    _dailyGoalMinutes = prefs.getInt('daily_goal') ?? _dailyGoalMinutes;
    _focusMinutes = prefs.getInt('focus_minutes') ?? _focusMinutes;
    _notifications = prefs.getBool('notifications') ?? _notifications;
    _sounds = prefs.getBool('sounds') ?? _sounds;
    _focusMode = prefs.getBool('focus_mode') ?? _focusMode;
    notifyListeners();
  }

  Future<void> _save() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('profile_name', _name);
      await prefs.setInt('daily_goal', _dailyGoalMinutes);
      await prefs.setInt('focus_minutes', _focusMinutes);
      await prefs.setBool('notifications', _notifications);
      await prefs.setBool('sounds', _sounds);
      await prefs.setBool('focus_mode', _focusMode);
    } catch (e) {
      debugPrint('Could not save profile: $e');
    }
  }

  void _changed() {
    notifyListeners();
    _save();
  }

  /// "Student" -> "ST", "Ana Cruz" -> "AC"
  String get initials {
    final parts = _name.trim().split(RegExp(r'\s+'));
    if (parts.isEmpty || parts.first.isEmpty) return '?';
    if (parts.length == 1) {
      final w = parts.first;
      return (w.length >= 2 ? w.substring(0, 2) : w).toUpperCase();
    }
    return (parts[0][0] + parts[1][0]).toUpperCase();
  }

  void setName(String v) {
    _name = v.trim();
    _changed();
  }

  void setDailyGoal(int minutes) {
    _dailyGoalMinutes = minutes;
    _changed();
  }

  void setFocusMinutes(int minutes) {
    _focusMinutes = minutes;
    _changed();
  }

  void setNotifications(bool v) {
    _notifications = v;
    _changed();
  }

  void setSounds(bool v) {
    _sounds = v;
    _changed();
  }

  void setFocusMode(bool v) {
    _focusMode = v;
    _changed();
  }
}