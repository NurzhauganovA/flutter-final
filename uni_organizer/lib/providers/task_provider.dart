import 'package:flutter/material.dart';
import '../models/task_model.dart';
import '../services/database_service.dart';
import 'package:firebase_auth/firebase_auth.dart';

class TaskProvider with ChangeNotifier {
  // Получаем текущего юзера
  User? user = FirebaseAuth.instance.currentUser;

  // Если юзера нет, возвращаем пустой сервис, иначе подключаемся к его данным
  DatabaseService get _db => DatabaseService(uid: user?.uid ?? '');

  // Поток задач для UI
  Stream<List<Task>> get tasksStream => _db.tasks;

  // Методы для вызова из UI
  Future<void> addTask(String title, String description, DateTime date) async {
    await _db.addTask(title, description, date);
    notifyListeners();
  }

  Future<void> toggleTask(String id, bool status) async {
    await _db.toggleTaskStatus(id, status);
  }

  Future<void> deleteTask(String id) async {
    await _db.deleteTask(id);
  }
}