class Note {
  Note(this.text, {DateTime? date}) : date = date ?? DateTime.now();

  String text;
  DateTime date;

  String get title {
    final first = text.trim().split('\n').first;
    return first.isEmpty ? 'New Note' : first;
  }

  String get preview {
    final lines =
        text.trim().split('\n').where((l) => l.trim().isNotEmpty).toList();
    return lines.length > 1 ? lines[1] : 'No additional text';
  }

  String get dateLabel {
    final n = DateTime.now();
    if (date.year == n.year && date.month == n.month && date.day == n.day) {
      final h = date.hour % 12 == 0 ? 12 : date.hour % 12;
      final ap = date.hour < 12 ? 'AM' : 'PM';
      return '$h:${date.minute.toString().padLeft(2, '0')} $ap';
    }
    return '${date.month}/${date.day}/${date.year % 100}';
  }

  Map<String, dynamic> toJson() => {
        'text': text,
        'date': date.toIso8601String(),
      };

  factory Note.fromJson(Map<String, dynamic> json) => Note(
        json['text'] as String? ?? '',
        date: DateTime.tryParse(json['date'] as String? ?? ''),
      );
}