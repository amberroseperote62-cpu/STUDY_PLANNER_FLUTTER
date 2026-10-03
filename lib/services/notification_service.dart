import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:study_planner_flutter/widgets/time_format.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

/// Local (offline) notifications for the study timer.
///
///  * "Come back!"  – scheduled a few seconds after the user leaves the app
///                    while the timer is running, cancelled when they return.
///  * "Time's up!"  – scheduled for the moment the timer ends, so the user is
///                    alerted even if the app was closed.
class NotificationService {
  NotificationService._();
  static final NotificationService instance = NotificationService._();

  static const int _comeBackId = 1;
  static const int _doneId = 2;

  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();
  bool _ready = false;

  final NotificationDetails _details = const NotificationDetails(
    android: AndroidNotificationDetails(
      'study_timer',
      'Study timer',
      channelDescription: 'Reminders while your study timer is running',
      importance: Importance.high,
      priority: Priority.high,
    ),
    iOS: DarwinNotificationDetails(),
  );

  /// Call once from main(). Does nothing on platforms we haven't configured
  /// (web / desktop), so the app still runs there.
  Future<void> init() async {
    final supported = !kIsWeb &&
        (defaultTargetPlatform == TargetPlatform.android ||
            defaultTargetPlatform == TargetPlatform.iOS);
    if (!supported) return;

    tz.initializeTimeZones();

    await _plugin.initialize(
      settings: InitializationSettings(
        android: const AndroidInitializationSettings('@mipmap/ic_launcher'),
        // Permission is requested later, when the user starts a timer.
        iOS: DarwinInitializationSettings(
          requestAlertPermission: false,
          requestBadgePermission: false,
          requestSoundPermission: false,
        ),
      ),
    );
    _ready = true;
  }

  /// Asks for notification permission (Android 13+ and iOS). Safe to call
  /// repeatedly; the OS only shows its prompt when it's still undecided.
  Future<void> requestPermission() async {
    if (!_ready) return;
    try {
      await _plugin
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>()
          ?.requestNotificationsPermission();
      await _plugin
          .resolvePlatformSpecificImplementation<
              IOSFlutterLocalNotificationsPlugin>()
          ?.requestPermissions(alert: true, badge: true, sound: true);
    } catch (e) {
      debugPrint('Notification permission request failed: $e');
    }
  }

  /// "Come back! 12:40 left." shown [delay] from now. The time shown is what
  /// will actually be left when the notification appears.
  Future<void> scheduleComeBack({
    required DateTime endTime,
    required Duration delay,
  }) async {
    final fireAt = DateTime.now().add(delay);
    final secondsLeft = endTime.difference(fireAt).inSeconds;
    if (secondsLeft <= 0) return; // timer ends before we'd nag
    await _schedule(
      id: _comeBackId,
      at: fireAt,
      title: 'Come back!',
      body: '${formatClock(secondsLeft)} left on your study timer.',
    );
  }

  Future<void> scheduleDone(DateTime endTime) => _schedule(
        id: _doneId,
        at: endTime,
        title: "Time's up!",
        body: 'Nice work. Take a short break.',
      );

  Future<void> cancelComeBack() async {
    if (_ready) await _plugin.cancel(id: _comeBackId);
  }

  Future<void> cancelDone() async {
    if (_ready) await _plugin.cancel(id: _doneId);
  }

  Future<void> cancelAll() async {
    if (_ready) await _plugin.cancelAll();
  }

  Future<void> _schedule({
    required int id,
    required DateTime at,
    required String title,
    required String body,
  }) async {
    if (!_ready) return;
    try {
      // Exact timing needs the "alarms & reminders" permission on Android 12+.
      // If we don't have it, fall back to inexact (can arrive a bit late).
      final canExact = await _plugin
              .resolvePlatformSpecificImplementation<
                  AndroidFlutterLocalNotificationsPlugin>()
              ?.canScheduleExactNotifications() ??
          false;

      await _plugin.zonedSchedule(
        id: id,
        title: title,
        body: body,
        // An absolute moment in time, so the zone doesn't matter.
        scheduledDate: tz.TZDateTime.from(at, tz.UTC),
        notificationDetails: _details,
        androidScheduleMode: canExact
            ? AndroidScheduleMode.exactAllowWhileIdle
            : AndroidScheduleMode.inexactAllowWhileIdle,
      );
    } catch (e) {
      debugPrint('Could not schedule notification $id: $e');
    }
  }
}