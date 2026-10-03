class Task {
  final String title;

  /// DateTime.monday (1) ... DateTime.sunday (7)
  final int weekday;
  bool done;

  Task(this.title, {required this.weekday, this.done = false});

  Map<String, dynamic> toJson() => {
        'title': title,
        'weekday': weekday,
        'done': done,
      };

  factory Task.fromJson(Map<String, dynamic> json) => Task(
        json['title'] as String,
        weekday: json['weekday'] as int,
        done: json['done'] as bool? ?? false,
      );
}