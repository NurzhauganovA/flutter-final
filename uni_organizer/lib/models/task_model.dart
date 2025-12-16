import 'package:cloud_firestore/cloud_firestore.dart';

enum TaskPriority { low, medium, high, urgent }
enum TaskCategory { assignment, exam, project, reading, other }

class Task {
  String id;
  String title;
  String description;
  DateTime date;
  bool isDone;
  TaskPriority priority;
  TaskCategory category;
  List<String> tags;
  DateTime createdAt;

  Task({
    required this.id,
    required this.title,
    required this.description,
    required this.date,
    this.isDone = false,
    this.priority = TaskPriority.medium,
    this.category = TaskCategory.other,
    this.tags = const [],
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  factory Task.fromMap(Map<String, dynamic> data, String documentId) {
    return Task(
      id: documentId,
      title: data['title'] ?? '',
      description: data['description'] ?? '',
      date: (data['date'] as Timestamp).toDate(),
      isDone: data['isDone'] ?? false,
      priority: TaskPriority.values.firstWhere(
            (e) => e.name == (data['priority'] ?? 'medium'),
        orElse: () => TaskPriority.medium,
      ),
      category: TaskCategory.values.firstWhere(
            (e) => e.name == (data['category'] ?? 'other'),
        orElse: () => TaskCategory.other,
      ),
      tags: List<String>.from(data['tags'] ?? []),
      createdAt: data['createdAt'] != null
          ? (data['createdAt'] as Timestamp).toDate()
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'description': description,
      'date': Timestamp.fromDate(date),
      'isDone': isDone,
      'priority': priority.name,
      'category': category.name,
      'tags': tags,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  String get priorityLabel {
    switch (priority) {
      case TaskPriority.low:
        return 'Low';
      case TaskPriority.medium:
        return 'Medium';
      case TaskPriority.high:
        return 'High';
      case TaskPriority.urgent:
        return 'Urgent';
    }
  }

  String get categoryLabel {
    switch (category) {
      case TaskCategory.assignment:
        return 'Assignment';
      case TaskCategory.exam:
        return 'Exam';
      case TaskCategory.project:
        return 'Project';
      case TaskCategory.reading:
        return 'Reading';
      case TaskCategory.other:
        return 'Other';
    }
  }

  String get categoryEmoji {
    switch (category) {
      case TaskCategory.assignment:
        return '📝';
      case TaskCategory.exam:
        return '📚';
      case TaskCategory.project:
        return '🎯';
      case TaskCategory.reading:
        return '📖';
      case TaskCategory.other:
        return '📌';
    }
  }
}