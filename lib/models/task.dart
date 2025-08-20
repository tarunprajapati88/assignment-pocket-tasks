
import 'package:uuid/uuid.dart';

class Task {
  final String id;
  final String title;
  final bool done;
  final DateTime createdAt;

  Task({
    String? id,
    required this.title,
    required this.done,
    required this.createdAt,
  }) : id = id ?? const Uuid().v4();

  Task copyWith({
    String? id,
    String? title,
    bool? done,
    DateTime? createdAt,
  }) {
    return Task(
      id: id ?? this.id,
      title: title ?? this.title,
      done: done ?? this.done,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'done': done,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  static Task fromJson(Map<String, dynamic> json) {
    return Task(
      id: json['id'],
      title: json['title'],
      done: json['done'],
      createdAt: DateTime.parse(json['createdAt']),
    );
  }
}
