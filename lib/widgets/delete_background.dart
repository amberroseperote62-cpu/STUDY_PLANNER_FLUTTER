import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:study_planner_flutter/widgets/ios_widgets.dart';

/// Red trash background shown behind a swiped-to-delete row (Dismissible).
class DeleteBackground extends StatelessWidget {
  const DeleteBackground({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Ios.red,
      alignment: Alignment.centerRight,
      padding: const EdgeInsets.only(right: 24),
      child: const Icon(CupertinoIcons.trash, color: Colors.white),
    );
  }
}