import 'package:flutter/material.dart';
import 'package:study_planner_flutter/theme/app_theme.dart';
import 'package:study_planner_flutter/theme/theme_controller.dart';
import 'package:study_planner_flutter/widgets/footer.dart'; // adjust if Footer lives elsewhere

import 'package:study_planner_flutter/services/notification_service.dart';
import 'package:study_planner_flutter/services/profile_store.dart';
import 'package:study_planner_flutter/services/task_store.dart';
import 'package:study_planner_flutter/services/note_store.dart';
import 'package:study_planner_flutter/services/timer_store.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await NotificationService.instance.init();
  await Future.wait([
    TaskStore.instance.load(),
    ProfileStore.instance.load(),
    NoteStore.instance.load(),
    TimerStore.instance.load(),
  ]);

  runApp(const StudyPlannerApp()); // keep whatever you already had here
}

class StudyPlannerApp extends StatelessWidget {
  const StudyPlannerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: ThemeController.mode,
      builder: (context, mode, _) {
        return MaterialApp(
          title: 'Study Planner',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.light,
          darkTheme: AppTheme.dark,
          themeMode: mode,
          home: const Footer(),
        );
      },
    );
  }
}