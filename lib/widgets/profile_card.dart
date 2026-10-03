import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:study_planner_flutter/widgets/ios_widgets.dart';

/// Apple ID-style card at the top of Settings.
class ProfileCard extends StatelessWidget {
  final String initials;
  final String name;
  final String subtitle;
  final VoidCallback? onTap;

  const ProfileCard({
    super.key,
    required this.initials,
    required this.name,
    required this.subtitle,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: iosSurface(context),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              Container(
                width: 60,
                height: 60,
                alignment: Alignment.center,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [Color(0xFFA2A2A7), Color(0xFF6E6E73)],
                  ),
                ),
                child: Text(
                  initials,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w500,
                    color: Colors.white,
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: const TextStyle(
                          fontSize: 20, fontWeight: FontWeight.w500),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: TextStyle(
                          fontSize: 13, color: iosSecondary(context)),
                    ),
                  ],
                ),
              ),
              Icon(CupertinoIcons.chevron_forward,
                  size: 16, color: iosTertiary(context)),
            ],
          ),
        ),
      ),
    );
  }
}