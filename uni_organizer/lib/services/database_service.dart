import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/task_model.dart';
import '../models/schedule_model.dart';

class DatabaseService {
  final String uid;
  DatabaseService({required this.uid});

  // Ссылка на коллекцию задач конкретного пользователя
  CollectionReference get taskCollection =>
      FirebaseFirestore.instance.collection('users').doc(uid).collection('tasks');

  // Ссылка на коллекцию расписания
  CollectionReference get scheduleCollection =>
      FirebaseFirestore.instance.collection('users').doc(uid).collection('schedule');

  // 1. Добавить задачу (CREATE)
  Future<void> addTask(String title, String description, DateTime date) async {
    await taskCollection.add({
      'title': title,
      'description': description,
      'date': Timestamp.fromDate(date),
      'isDone': false,
    });
  }

  // 2. Получить список задач (READ) - Поток данных в реальном времени
  Stream<List<Task>> get tasks {
    return taskCollection
        .orderBy('date', descending: false) // Сортируем по дате
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        return Task.fromMap(doc.data() as Map<String, dynamic>, doc.id);
      }).toList();
    });
  }

  // 3. Обновить статус (UPDATE)
  Future<void> toggleTaskStatus(String taskId, bool currentStatus) async {
    await taskCollection.doc(taskId).update({'isDone': !currentStatus});
  }

  // 4. Удалить задачу (DELETE)
  Future<void> deleteTask(String taskId) async {
    await taskCollection.doc(taskId).delete();
  }

  // ---------- Расписание ----------

  // Поток расписания, отсортированного по дню недели и времени
  Stream<List<ScheduleItem>> get schedule {
    return scheduleCollection
        .orderBy('weekday')
        .orderBy('startMinutes')
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        return ScheduleItem.fromMap(doc.data() as Map<String, dynamic>, doc.id);
      }).toList();
    });
  }

  Future<void> addScheduleItem({
    required String subject,
    required String type,
    required String location,
    required String teacher,
    required int weekday,
    required int startMinutes,
    required int endMinutes,
  }) async {
    await scheduleCollection.add({
      'subject': subject,
      'type': type,
      'location': location,
      'teacher': teacher,
      'weekday': weekday,
      'startMinutes': startMinutes,
      'endMinutes': endMinutes,
    });
  }

  Future<void> deleteScheduleItem(String id) async {
    await scheduleCollection.doc(id).delete();
  }
}
