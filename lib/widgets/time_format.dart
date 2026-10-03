/// 754 -> "12:34", 4000 -> "1:06:40"
String formatClock(int totalSeconds) {
  final h = totalSeconds ~/ 3600;
  final m = ((totalSeconds % 3600) ~/ 60).toString().padLeft(2, '0');
  final s = (totalSeconds % 60).toString().padLeft(2, '0');
  return h > 0 ? '$h:$m:$s' : '$m:$s';
}