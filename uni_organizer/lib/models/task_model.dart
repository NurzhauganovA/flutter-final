import 'package:cloud_firestore/cloud_firestore.dart';

class Task {
  String id;
  String title;
  String description;
  DateTime date;
  bool isDone;

  Task({
    required this.id,
    required this.title,
    required this.description,
    required this.date,
    this.isDone = false,
  });

  // Преобразование данных ИЗ Firebase в наш объект
  factory Task.fromMap(Map<String, dynamic> data, String documentId) {
    return Task(
      id: documentId,
      title: data['title'] ?? '',
      description: data['description'] ?? '',
      // Firebase хранит дату как Timestamp, нам нужно конвертировать в DateTime
      date: (data['date'] as Timestamp).toDate(),
      isDone: data['isDone'] ?? false,
    );
  }

  // Преобразование НАШЕГО объекта в формат для Firebase
  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'description': description,
      'date': Timestamp.fromDate(date),
      'isDone': isDone,
    };
  }
}