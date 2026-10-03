import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:study_planner_flutter/services/timer_store.dart';
import 'package:study_planner_flutter/widgets/circle_button.dart';
import 'package:study_planner_flutter/widgets/ios_widgets.dart';

class TimerScreen extends StatefulWidget {
  const TimerScreen({super.key});

  @override
  State<TimerScreen> createState() => _TimerScreenState();
}

class _TimerScreenState extends State<TimerScreen>
    with SingleTickerProviderStateMixin {
  Duration _selected = const Duration(minutes: 25);
  Timer? _ticker;
  int _total = 0;
  int _remaining = 0;
  bool _active = false;
  bool _running = false;

  // Pulse animation controller for the "starting" indicator
  late final AnimationController _pulseCtrl;
  late final Animation<double> _pulseAnim;
  bool _showPulse = false;

  @override
  void initState() {
    super.initState();
    _pulseCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );
    _pulseAnim = Tween<double>(begin: 0.85, end: 1.15).animate(
      CurvedAnimation(parent: _pulseCtrl, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _ticker?.cancel();
    _pulseCtrl.dispose();
    super.dispose();
  }

  void _start() {
    if (_selected.inSeconds == 0) return;
    HapticFeedback.mediumImpact();
    setState(() {
      _total = _selected.inSeconds;
      _remaining = _total;
      _active = true;
      _running = true;
      _showPulse = true;
    });

    // Animate a 3-pulse "starting" burst, then fade out.
    _pulseCtrl.forward(from: 0).then((_) {
      _pulseCtrl.reverse().then((_) {
        _pulseCtrl.forward().then((_) {
          _pulseCtrl.reverse().then((_) {
            _pulseCtrl.forward().then((_) {
              _pulseCtrl.reverse().then((_) {
                if (mounted) setState(() => _showPulse = false);
              });
            });
          });
        });
      });
    });

    _startTicker();
  }

  void _startTicker() {
    _ticker?.cancel();
    _ticker = Timer.periodic(const Duration(seconds: 1), (_) {
      if (_remaining <= 1) {
        _finish();
      } else {
        setState(() => _remaining--);
      }
    });
  }

  void _togglePause() {
    HapticFeedback.selectionClick();
    if (_running) {
      _ticker?.cancel();
      setState(() => _running = false);
    } else {
      setState(() => _running = true);
      _startTicker();
    }
  }

  void _cancel() {
    HapticFeedback.selectionClick();
    _ticker?.cancel();
    _pulseCtrl.stop();
    setState(() {
      _active = false;
      _running = false;
      _showPulse = false;
    });
  }

  void _finish() {
    final elapsed = _total; // full session completed
    _ticker?.cancel();
    HapticFeedback.heavyImpact();
    TimerStore.instance.recordSession(elapsed);
    setState(() {
      _active = false;
      _running = false;
      _showPulse = false;
    });
    if (!mounted) return;
    showCupertinoDialog<void>(
      context: context,
      builder: (ctx) => CupertinoAlertDialog(
        title: const Text('Timer Done'),
        content: const Text('Nice work! Time for a break.'),
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

  String _format(int s) {
    final h = s ~/ 3600;
    final m = ((s % 3600) ~/ 60).toString().padLeft(2, '0');
    final sec = (s % 60).toString().padLeft(2, '0');
    return h > 0 ? '$h:$m:$sec' : '$m:$sec';
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // Solid button colors that are visible in both light and dark mode.
    final cancelBg = isDark ? const Color(0xFF3A3A3C) : const Color(0xFFD1D1D6);
    final cancelFg = isDark ? Colors.white : const Color(0xFF1C1C1E);
    final startBg = isDark ? const Color(0xFF1A3A25) : const Color(0xFF34C759);
    final startFg = isDark ? Ios.green : Colors.white;
    final pauseBg = isDark ? const Color(0xFF3A2A00) : const Color(0xFFFF9500);
    final pauseFg = isDark ? Ios.orange : Colors.white;
    final resumeBg = startBg;
    final resumeFg = startFg;

    return IosPage(
      title: 'Timer',
      children: [
        if (_active)
          Padding(
            padding: const EdgeInsets.only(top: 24),
            child: Center(
              child: SizedBox(
                width: 290,
                height: 290,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    // Animated pulse ring behind the progress ring
                    if (_showPulse)
                      AnimatedBuilder(
                        animation: _pulseAnim,
                        builder: (context, child) => Transform.scale(
                          scale: _pulseAnim.value,
                          child: Container(
                            width: 290,
                            height: 290,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: Ios.orange.withValues(alpha: 0.35),
                                width: 6,
                              ),
                            ),
                          ),
                        ),
                      ),
                    CustomPaint(
                      size: const Size(290, 290),
                      painter: RingPainter(
                        progress: [_remaining / _total],
                        colors: const [Ios.orange],
                        stroke: 8,
                      ),
                    ),
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          _format(_remaining),
                          style: const TextStyle(
                            fontSize: 62,
                            fontWeight: FontWeight.w200,
                            fontFeatures: [FontFeature.tabularFigures()],
                          ),
                        ),
                        if (_showPulse)
                          AnimatedOpacity(
                            opacity: _showPulse ? 1.0 : 0.0,
                            duration: const Duration(milliseconds: 300),
                            child: Text(
                              'Starting…',
                              style: TextStyle(
                                fontSize: 14,
                                color: Ios.orange,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        if (_running && !_showPulse)
                          Text(
                            'Focus',
                            style: TextStyle(
                              fontSize: 14,
                              color: iosSecondary(context),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        if (!_running)
                          Text(
                            'Paused',
                            style: TextStyle(
                              fontSize: 14,
                              color: Ios.orange,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          )
        else
          Padding(
            padding: const EdgeInsets.only(top: 24),
            child: SizedBox(
              height: 216,
              child: CupertinoTimerPicker(
                mode: CupertinoTimerPickerMode.hms,
                initialTimerDuration: _selected,
                onTimerDurationChanged: (d) => _selected = d,
              ),
            ),
          ),
        Padding(
          padding: const EdgeInsets.fromLTRB(32, 36, 32, 0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              CircleButton(
                label: 'Cancel',
                background: cancelBg,
                textColor: cancelFg,
                onTap: _active ? _cancel : null,
              ),
              if (!_active)
                CircleButton(
                  label: 'Start',
                  background: startBg,
                  textColor: startFg,
                  onTap: _start,
                )
              else if (_running)
                CircleButton(
                  label: 'Pause',
                  background: pauseBg,
                  textColor: pauseFg,
                  onTap: _togglePause,
                )
              else
                CircleButton(
                  label: 'Resume',
                  background: resumeBg,
                  textColor: resumeFg,
                  onTap: _togglePause,
                ),
            ],
          ),
        ),
        // Today's stats from TimerStore
        ListenableBuilder(
          listenable: TimerStore.instance,
          builder: (context, _) {
            final mins = TimerStore.instance.focusMinutes;
            final sess = TimerStore.instance.sessions;
            return Padding(
              padding: const EdgeInsets.fromLTRB(32, 32, 32, 0),
              child: Row(
                children: [
                  _StatPill(
                    icon: CupertinoIcons.flame_fill,
                    color: Ios.orange,
                    value: '${mins}m',
                    label: 'Focus today',
                  ),
                  const SizedBox(width: 12),
                  _StatPill(
                    icon: CupertinoIcons.checkmark_seal_fill,
                    color: Ios.green,
                    value: '$sess',
                    label: 'Sessions',
                  ),
                ],
              ),
            );
          },
        ),
      ],
    );
  }
}

class _StatPill extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String value;
  final String label;

  const _StatPill({
    required this.icon,
    required this.color,
    required this.value,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = isDark ? const Color(0xFF2C2C2E) : const Color(0xFFF2F2F7);

    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Row(
          children: [
            Icon(icon, size: 20, color: color),
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 12,
                    color: iosSecondary(context),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}