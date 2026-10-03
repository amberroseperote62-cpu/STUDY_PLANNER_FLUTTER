import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:study_planner_flutter/screens/edit_profile_screen.dart';
import 'package:study_planner_flutter/services/notification_service.dart';
import 'package:study_planner_flutter/services/profile_store.dart';
import 'package:study_planner_flutter/theme/theme_controller.dart';
import 'package:study_planner_flutter/widgets/ios_widgets.dart';
import 'package:study_planner_flutter/widgets/profile_card.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  static final _store = ProfileStore.instance;

  static String _formatMinutes(int m) {
    if (m < 60) return '$m min';
    final h = m ~/ 60;
    final r = m % 60;
    return r == 0 ? '$h hr' : '$h hr $r min';
  }

  /// Makes any row tappable without needing an onTap on IosRow.
  static Widget _tappable(VoidCallback onTap, Widget child) => GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: child,
      );

  /// Wheel picker in a bottom sheet. Calls [onDone] with the chosen value.
  static Future<void> _pickMinutes(
    BuildContext context, {
    required String title,
    required List<int> options,
    required int current,
    required ValueChanged<int> onDone,
  }) async {
    HapticFeedback.selectionClick();
    var index = options.indexOf(current);
    if (index < 0) index = 0;
    var selected = options[index];

    await showCupertinoModalPopup<void>(
      context: context,
      builder: (ctx) => Container(
        height: 300,
        color: CupertinoColors.systemBackground.resolveFrom(ctx),
        child: SafeArea(
          top: false,
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: Row(
                  children: [
                    CupertinoButton(
                      onPressed: () => Navigator.pop(ctx),
                      child: const Text('Cancel'),
                    ),
                    Expanded(
                      child: Text(
                        title,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w600,
                          decoration: TextDecoration.none,
                          color: CupertinoColors.label,
                        ),
                      ),
                    ),
                    CupertinoButton(
                      onPressed: () {
                        onDone(selected);
                        Navigator.pop(ctx);
                      },
                      child: const Text('Done',
                          style: TextStyle(fontWeight: FontWeight.w600)),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: CupertinoPicker(
                  itemExtent: 38,
                  scrollController:
                      FixedExtentScrollController(initialItem: index),
                  onSelectedItemChanged: (i) {
                    HapticFeedback.selectionClick();
                    selected = options[i];
                  },
                  children: [
                    for (final o in options)
                      Center(child: Text(_formatMinutes(o))),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  static void _info(BuildContext context, String title, String message) {
    showCupertinoDialog<void>(
      context: context,
      builder: (ctx) => CupertinoAlertDialog(
        title: Text(title),
        content: Padding(
          padding: const EdgeInsets.only(top: 8),
          child: Text(message),
        ),
        actions: [
          CupertinoDialogAction(
            isDefaultAction: true,
            onPressed: () => Navigator.pop(ctx),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Reflects what's actually on screen, even if the mode is still "system".
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return ListenableBuilder(
      listenable: _store,
      builder: (context, _) {
        return IosPage(
          title: 'Profile',
          children: [
            _tappable(
              () => Navigator.of(context).push(
                CupertinoPageRoute<void>(
                  builder: (_) => const EditProfileScreen(),
                ),
              ),
              ProfileCard(
                initials: _store.initials,
                name: _store.name,
                subtitle: 'Study Planner ID, Goals & Streak',
              ),
            ),

            IosSection(
              header: 'Study',
              children: [
                _tappable(
                  () => _pickMinutes(
                    context,
                    title: 'Daily Goal',
                    options: [for (var m = 15; m <= 480; m += 15) m],
                    current: _store.dailyGoalMinutes,
                    onDone: _store.setDailyGoal,
                  ),
                  IosRow(
                    icon: CupertinoIcons.flag_fill,
                    iconColor: Ios.orange,
                    title: 'Daily Goal',
                    value: _formatMinutes(_store.dailyGoalMinutes),
                    chevron: true,
                  ),
                ),
                _tappable(
                  () => _pickMinutes(
                    context,
                    title: 'Focus Session',
                    options: [for (var m = 5; m <= 120; m += 5) m],
                    current: _store.focusMinutes,
                    onDone: _store.setFocusMinutes,
                  ),
                  IosRow(
                    icon: CupertinoIcons.clock_fill,
                    iconColor: Ios.blue,
                    title: 'Focus Session',
                    value: _formatMinutes(_store.focusMinutes),
                    chevron: true,
                  ),
                ),
              ],
            ),

            IosSection(
              children: [
                IosRow(
                  icon: CupertinoIcons.bell_fill,
                  iconColor: Ios.red,
                  title: 'Notifications',
                  trailing: CupertinoSwitch(
                    value: _store.notifications,
                    onChanged: (v) async {
                      HapticFeedback.selectionClick();
                      _store.setNotifications(v);
                      if (v) {
                        await NotificationService.instance.requestPermission();
                      } else {
                        await NotificationService.instance.cancelAll();
                      }
                    },
                  ),
                ),
                IosRow(
                  icon: CupertinoIcons.speaker_2_fill,
                  iconColor: Ios.pink,
                  title: 'Sounds',
                  trailing: CupertinoSwitch(
                    value: _store.sounds,
                    onChanged: (v) {
                      HapticFeedback.selectionClick();
                      _store.setSounds(v);
                    },
                  ),
                ),
                IosRow(
                  icon: CupertinoIcons.moon_fill,
                  iconColor: Ios.purple,
                  title: 'Focus Mode',
                  trailing: CupertinoSwitch(
                    value: _store.focusMode,
                    onChanged: (v) {
                      HapticFeedback.selectionClick();
                      _store.setFocusMode(v);
                    },
                  ),
                ),
              ],
            ),

            IosSection(
              children: [
                IosRow(
                  icon: CupertinoIcons.circle_lefthalf_fill,
                  iconColor: Ios.teal,
                  title: 'Dark Mode',
                  trailing: CupertinoSwitch(
                    value: isDark,
                    onChanged: (v) {
                      HapticFeedback.selectionClick();
                      ThemeController.setDark(v);
                    },
                  ),
                ),
                _tappable(
                  () => _info(
                    context,
                    'Privacy',
                    'Your tasks and settings stay on this device. '
                        'Study Planner has no account and sends nothing '
                        'to a server.',
                  ),
                  const IosRow(
                    icon: CupertinoIcons.hand_raised_fill,
                    iconColor: Ios.blue,
                    title: 'Privacy',
                    chevron: true,
                  ),
                ),
              ],
            ),

            IosSection(
              footer: 'Study Planner 1.0.0',
              children: [
                _tappable(
                  () => _info(
                    context,
                    'Study Planner',
                    'Version 1.0.0\nPlan your tasks by day and stay '
                        'focused with a study timer.',
                  ),
                  const IosRow(
                    icon: CupertinoIcons.info_circle_fill,
                    iconColor: Ios.gray,
                    title: 'About',
                    chevron: true,
                  ),
                ),
              ],
            ),
          ],
        );
      },
    );
  }
}