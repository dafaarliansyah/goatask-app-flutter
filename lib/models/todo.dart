class Todo {
  String id;
  String title;
  String description;
  DateTime dueDate;
  bool isCompleted;
  bool isSyncedWithCalendar;
  String? calendarEventId;

  Todo({
    required this.id,
    required this.title,
    required this.description,
    required this.dueDate,
    this.isCompleted = false,
    this.isSyncedWithCalendar = false,
    this.calendarEventId,
  });

  factory Todo.fromMap(Map<String, dynamic> map, String id) {
    return Todo(
      id: id,
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      dueDate: DateTime.fromMillisecondsSinceEpoch(map['dueDate']),
      isCompleted: map['isCompleted'] ?? false,
      isSyncedWithCalendar: map['isSyncedWithCalendar'] ?? false,
      calendarEventId: map['calendarEventId'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'description': description,
      'dueDate': dueDate.millisecondsSinceEpoch,
      'isCompleted': isCompleted,
      'isSyncedWithCalendar': isSyncedWithCalendar,
      'calendarEventId': calendarEventId,
    };
  }
}