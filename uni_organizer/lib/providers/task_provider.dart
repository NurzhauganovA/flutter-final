import 'package:flutter/material.dart';
import '../models/task_model.dart';
import '../services/database_service.dart';
import 'package:firebase_auth/firebase_auth.dart';

class TaskProvider with ChangeNotifier {
  User? user = FirebaseAuth.instance.currentUser;

  DatabaseService get _db => DatabaseService(uid: user?.uid ?? '');

  Stream<List<Task>> get tasksStream => _db.tasks;

  Future<void> addTask(String title, String description, DateTime date) async {
    await _db.addTask(title, description, date);
    notifyListeners();
  }

  Future<void> toggleTask(String id, bool status) async {
    await _db.toggleTaskStatus(id, status);
  }

  Future<void> updateTask({
    required String taskId,
    String? title,
    String? description,
    DateTime? date,
  }) async {
    await _db.updateTask(
      taskId: taskId,
      title: title,
      description: description,
      date: date,
    );
    notifyListeners();
  }

  Future<void> deleteTask(String id) async {
    await _db.deleteTask(id);
  }
}