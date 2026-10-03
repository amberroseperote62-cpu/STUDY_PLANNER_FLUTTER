import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:study_planner_flutter/widgets/circle_button.dart';
import 'package:study_planner_flutter/widgets/ios_widgets.dart';

class TimerScreen extends StatefulWidget {
  const TimerScreen({super.key});

  @override
  State<TimerScreen> createState() => _TimerScreenState();
}

class _TimerScreenState extends State<TimerScreen> {
  Duration _selected = const Duration(minutes: 25);
  Timer? _ticker;
  int _total = 0;
  int _remaining = 0;
  bool _active = false; // a timer exists (running or paused)
  bool _running = false;

  @override
  void dispose() {
    _ticker?.cancel();
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
    setState(() {
      _active = false;
      _running = false;
    });
  }

  void _finish() {
    _ticker?.cancel();
    HapticFeedback.heavyImpact();
    setState(() {
      _active = false;
      _running = false;
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
                    CustomPaint(
                      size: const Size(290, 290),
                      painter: RingPainter(
                        progress: [_remaining / _total],
                        colors: const [Ios.orange],
                        stroke: 8,
                      ),
                    ),
                    Text(
                      _format(_remaining),
                      style: const TextStyle(
                        fontSize: 62,
                        fontWeight: FontWeight.w200,
                        fontFeatures: [FontFeature.tabularFigures()],
                      ),
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
                background: iosFill(context),
                textColor: iosSecondary(context),
                onTap: _active ? _cancel : null,
              ),
              if (!_active)
                CircleButton(
                  label: 'Start',
                  background: Ios.green.withValues(alpha: 0.2),
                  textColor: Ios.green,
                  onTap: _start,
                )
              else if (_running)
                CircleButton(
                  label: 'Pause',
                  background: Ios.orange.withValues(alpha: 0.2),
                  textColor: Ios.orange,
                  onTap: _togglePause,
                )
              else
                CircleButton(
                  label: 'Resume',
                  background: Ios.green.withValues(alpha: 0.2),
                  textColor: Ios.green,
                  onTap: _togglePause,
                ),
            ],
          ),
        ),
      ],
    );
  }
}