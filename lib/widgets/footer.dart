import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:study_planner_flutter/screens/home_screen.dart';
import 'package:study_planner_flutter/screens/note_screen.dart';
import 'package:study_planner_flutter/screens/profile_screen.dart';
import 'package:study_planner_flutter/screens/tasks_screen.dart';
import 'package:study_planner_flutter/screens/timer_screen.dart';

class Footer extends StatefulWidget {
  const Footer({super.key});

  @override
  State<Footer> createState() => _FooterState();
}

class _FooterState extends State<Footer> {
  int _selectedIndex = 0;

  final List<Widget> _screens = const [
    HomeScreen(),
    TasksScreen(),
    TimerScreen(),
    NotesScreen(),
    ProfileScreen(),
  ];

  static const _tabs = [
    _TabItem('Home', CupertinoIcons.house, CupertinoIcons.house_fill),
    _TabItem('Tasks', CupertinoIcons.checkmark_circle,
        CupertinoIcons.checkmark_circle_fill),
    _TabItem('Timer', CupertinoIcons.timer, CupertinoIcons.timer_fill),
    _TabItem('Notes', CupertinoIcons.doc_text, CupertinoIcons.doc_text_fill),
    _TabItem('Profile', CupertinoIcons.person, CupertinoIcons.person_fill),
  ];

  void setTab(int index) {
    if (index == _selectedIndex) return;
    HapticFeedback.selectionClick();
    setState(() => _selectedIndex = index);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true, // lets content scroll underneath the blurred bar
      body: IndexedStack(index: _selectedIndex, children: _screens),
      bottomNavigationBar: _IosTabBar(
        tabs: _tabs,
        currentIndex: _selectedIndex,
        onTap: setTab,
      ),
    );
  }
}

class _TabItem {
  final String label;
  final IconData icon;
  final IconData activeIcon;
  const _TabItem(this.label, this.icon, this.activeIcon);
}

class _IosTabBar extends StatelessWidget {
  final List<_TabItem> tabs;
  final int currentIndex;
  final ValueChanged<int> onTap;

  const _IosTabBar({
    required this.tabs,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final barColor = (isDark ? const Color(0xFF1C1C1E) : Colors.white)
        .withValues(alpha: 0.80);
    final borderColor = isDark
        ? const Color(0x99545458)
        : const Color(0x4D3C3C43);
    final inactive = isDark ? const Color(0x99EBEBF5) : const Color(0x993C3C43);

    return ClipRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 25, sigmaY: 25),
        child: Container(
          decoration: BoxDecoration(
            color: barColor,
            border: Border(top: BorderSide(color: borderColor, width: 0.5)),
          ),
          child: SafeArea(
            top: false,
            child: SizedBox(
              height: 50,
              child: Row(
                children: [
                  for (int i = 0; i < tabs.length; i++)
                    Expanded(
                      child: _TabButton(
                        item: tabs[i],
                        selected: i == currentIndex,
                        activeColor: theme.colorScheme.primary,
                        inactiveColor: inactive,
                        onTap: () => onTap(i),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _TabButton extends StatelessWidget {
  final _TabItem item;
  final bool selected;
  final Color activeColor;
  final Color inactiveColor;
  final VoidCallback onTap;

  const _TabButton({
    required this.item,
    required this.selected,
    required this.activeColor,
    required this.inactiveColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final color = selected ? activeColor : inactiveColor;

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          AnimatedScale(
            scale: selected ? 1.08 : 1.0,
            duration: const Duration(milliseconds: 150),
            child: Icon(selected ? item.activeIcon : item.icon,
                size: 25, color: color),
          ),
          const SizedBox(height: 2),
          Text(
            item.label,
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w500,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}