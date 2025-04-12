// task_model.dart

import 'dart:convert';

class Task {
  int? id;
  String task;
  String description;
  String date;
  String time;
  bool notificationEnabled;
  List<String>? photos;

  Task({
    this.id,
    required this.task,
    required this.description,
    required this.date,
    required this.time,
    required this.notificationEnabled,
    this.photos,
  });

  factory Task.fromMap(Map<String, dynamic> map) => Task(
        id: map['id'],
        task: map['task'],
        description: map['description'],
        date: map['date'],
        time: map['time'],
        notificationEnabled: map['notificationEnabled'] == 1,
        // ignore: prefer_null_aware_operators
        photos: (map['photos'] != null && map['photos'] != 'null')
            ? List<String>.from(jsonDecode(map['photos']))
            : null,
      );

  Map<String, dynamic> toMap() => {
        'id': id,
        'task': task,
        'description': description,
        'date': date,
        'time': time,
        'notificationEnabled': notificationEnabled ? 1 : 0,
        'photos': jsonEncode(photos),
      };
}
