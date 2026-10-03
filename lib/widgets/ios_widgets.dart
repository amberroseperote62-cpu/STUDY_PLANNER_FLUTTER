import 'dart:math' as math;

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

// ---------------------------------------------------------------------------
// iOS-style building blocks, all in one file:
//   Ios + iosSurface/iosSecondary/...   colors
//   IosPage                              large-title scrolling page
//   IosSection                           inset grouped list section
//   IosRow                               Settings-style row
//   IosCard                              rounded surface card
//   RingPainter                          Activity-style progress rings
// ---------------------------------------------------------------------------

/// iOS system colors
class Ios {
  static const blue = Color(0xFF007AFF);
  static const green = Color(0xFF34C759);
  static const red = Color(0xFFFF3B30);
  static const orange = Color(0xFFFF9500);
  static const purple = Color(0xFFAF52DE);
  static const gray = Color(0xFF8E8E93);
  static const pink = Color(0xFFFF2D55);
  static const teal = Color(0xFF32ADE6);
}

bool _isDark(BuildContext c) => Theme.of(c).brightness == Brightness.dark;

Color iosSurface(BuildContext c) =>
    _isDark(c) ? const Color(0xFF1C1C1E) : Colors.white;

Color iosSecondary(BuildContext c) =>
    _isDark(c) ? const Color(0x99EBEBF5) : const Color(0x993C3C43);

Color iosTertiary(BuildContext c) =>
    _isDark(c) ? const Color(0x4DEBEBF5) : const Color(0x4D3C3C43);

Color iosFill(BuildContext c) =>
    _isDark(c) ? const Color(0xFF2C2C2E) : const Color(0xFFE5E5EA);

/// A page with a collapsing iOS large title, like Reminders / Notes / Settings.
class IosPage extends StatelessWidget {
  final String title;
  final Widget? trailing;
  final List<Widget> children;

  const IosPage({
    super.key,
    required this.title,
    required this.children,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    final bg = Theme.of(context).scaffoldBackgroundColor;
    final bottomSpace = MediaQuery.paddingOf(context).bottom + 70;

    return ColoredBox(
      color: bg,
      child: CustomScrollView(
        physics: const BouncingScrollPhysics(
          parent: AlwaysScrollableScrollPhysics(),
        ),
        slivers: [
          CupertinoSliverNavigationBar(
            largeTitle: Text(title),
            trailing: trailing,
            automaticallyImplyLeading: false,
            backgroundColor: bg.withValues(alpha: 0.9),
          ),
          SliverList(delegate: SliverChildListDelegate(children)),
          SliverToBoxAdapter(child: SizedBox(height: bottomSpace)),
        ],
      ),
    );
  }
}

/// Rounded "inset grouped" list section with hairline dividers.
class IosSection extends StatelessWidget {
  final String? header;
  final String? footer;
  final List<Widget> children;

  const IosSection({
    super.key,
    this.header,
    this.footer,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    final divider = Theme.of(context).dividerColor;
    final items = <Widget>[];
    for (var i = 0; i < children.length; i++) {
      if (i > 0) {
        items.add(Divider(
          height: 0.5,
          thickness: 0.5,
          indent: 16,
          color: divider,
        ));
      }
      items.add(children[i]);
    }

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (header != null)
            Padding(
              padding: const EdgeInsets.only(left: 16, bottom: 6),
              child: Text(
                header!.toUpperCase(),
                style: TextStyle(fontSize: 13, color: iosSecondary(context)),
              ),
            ),
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Container(
              color: iosSurface(context),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: items,
              ),
            ),
          ),
          if (footer != null)
            Padding(
              padding: const EdgeInsets.only(left: 16, top: 6),
              child: Text(
                footer!,
                style: TextStyle(fontSize: 13, color: iosSecondary(context)),
              ),
            ),
        ],
      ),
    );
  }
}

/// A Settings-style row: optional colored icon tile, title, value, chevron/trailing.
class IosRow extends StatelessWidget {
  final IconData? icon;
  final Color iconColor;
  final String title;
  final String? value;
  final Widget? trailing;
  final bool chevron;
  final VoidCallback? onTap;

  const IosRow({
    super.key,
    required this.title,
    this.icon,
    this.iconColor = Ios.blue,
    this.value,
    this.trailing,
    this.chevron = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: ConstrainedBox(
        constraints: const BoxConstraints(minHeight: 44),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 7),
          child: Row(
            children: [
              if (icon != null) ...[
                Container(
                  width: 30,
                  height: 30,
                  decoration: BoxDecoration(
                    color: iconColor,
                    borderRadius: BorderRadius.circular(7),
                  ),
                  child: Icon(icon, size: 18, color: Colors.white),
                ),
                const SizedBox(width: 12),
              ],
              Expanded(
                child: Text(title, style: const TextStyle(fontSize: 17)),
              ),
              if (value != null)
                Text(
                  value!,
                  style: TextStyle(fontSize: 17, color: iosSecondary(context)),
                ),
              ?trailing,
              if (chevron) ...[
                const SizedBox(width: 6),
                Icon(
                  CupertinoIcons.chevron_forward,
                  size: 16,
                  color: iosTertiary(context),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

/// Rounded surface card used for Home widgets.
class IosCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;

  const IosCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(16),
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: iosSurface(context),
        borderRadius: BorderRadius.circular(14),
      ),
      child: child,
    );
  }
}

/// Concentric progress rings (Apple Activity style). progress values: 0..1
class RingPainter extends CustomPainter {
  final List<double> progress;
  final List<Color> colors;
  final double stroke;

  RingPainter({
    required this.progress,
    required this.colors,
    this.stroke = 14,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);

    for (var i = 0; i < progress.length; i++) {
      final radius = size.width / 2 - stroke / 2 - i * (stroke + 3);
      if (radius <= 0) break;
      final rect = Rect.fromCircle(center: center, radius: radius);

      final track = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = stroke
        ..color = colors[i].withValues(alpha: 0.2);
      canvas.drawCircle(center, radius, track);

      final p = progress[i].clamp(0.0, 1.0);
      if (p <= 0) continue;
      final arc = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = stroke
        ..strokeCap = StrokeCap.round
        ..color = colors[i];
      canvas.drawArc(rect, -math.pi / 2, 2 * math.pi * p, false, arc);
    }
  }

  @override
  bool shouldRepaint(covariant RingPainter old) =>
      old.progress != progress || old.colors != colors || old.stroke != stroke;
}