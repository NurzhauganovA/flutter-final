import 'package:flutter/material.dart';
import '../models/task_model.dart';
import '../services/database_service.dart';
import 'package:firebase_auth/firebase_auth.dart';

class TaskProvider with ChangeNotifier {
  DatabaseService get _db => DatabaseService(
      uid: FirebaseAuth.instance.currentUser?.uid ?? ''
  );

  Stream<List<Task>> get tasksStream => _db.tasks;

  Future<void> addTask(
      String title,
      String description,
      DateTime date, {
        TaskPriority priority = TaskPriority.medium,
        TaskCategory category = TaskCategory.other,
        List<String> tags = const [],
      }) async {
    await _db.addTask(
      title,
      description,
      date,
      priority: priority,
      category: category,
      tags: tags,
    );
    notifyListeners();
  }

  Future<void> toggleTask(String id, bool status) async {
    await _db.toggleTaskStatus(id, status);
    notifyListeners();
  }

  Future<void> updateTask({
    required String taskId,
    String? title,
    String? description,
    DateTime? date,
    TaskPriority? priority,
    TaskCategory? category,
    List<String>? tags,
  }) async {
    await _db.updateTask(
      taskId: taskId,
      title: title,
      description: description,
      date: date,
      priority: priority,
      category: category,
      tags: tags,
    );
    notifyListeners();
  }

  Future<void> deleteTask(String id) async {
    await _db.deleteTask(id);
    notifyListeners();
  }
}