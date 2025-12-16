import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/task_model.dart';
import '../models/schedule_model.dart';
import '../models/user_model.dart';

class DatabaseService {
  final String uid;
  DatabaseService({required this.uid});

  final FirebaseFirestore _db = FirebaseFirestore.instance;

  DocumentReference get userDoc => _db.collection('users').doc(uid);

  CollectionReference get taskCollection => userDoc.collection('tasks');

  CollectionReference get scheduleCollection => userDoc.collection('schedule');

  Future<void> createUserProfile(String email) async {
    await userDoc.set({
      'email': email,
      'name': 'Student',
      'major': '',
      'group': '',
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  Stream<UserProfile?> get userProfile {
    return userDoc.snapshots().map((doc) {
      if (!doc.exists) return null;
      return UserProfile.fromMap(doc.data() as Map<String, dynamic>, uid);
    });
  }

  Future<void> updateUserProfile({
    String? name,
    String? major,
    String? group,
  }) async {
    final Map<String, dynamic> updates = {};
    if (name != null) updates['name'] = name;
    if (major != null) updates['major'] = major;
    if (group != null) updates['group'] = group;

    if (updates.isNotEmpty) {
      await userDoc.update(updates);
    }
  }

  Future<void> addTask(String title, String description, DateTime date) async {
    await taskCollection.add({
      'title': title,
      'description': description,
      'date': Timestamp.fromDate(date),
      'isDone': false,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  Stream<List<Task>> get tasks {
    return taskCollection
        .orderBy('date', descending: false)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        return Task.fromMap(doc.data() as Map<String, dynamic>, doc.id);
      }).toList();
    });
  }

  Future<void> toggleTaskStatus(String taskId, bool currentStatus) async {
    await taskCollection.doc(taskId).update({'isDone': !currentStatus});
  }

  Future<void> updateTask({
    required String taskId,
    String? title,
    String? description,
    DateTime? date,
  }) async {
    final Map<String, dynamic> updates = {};
    if (title != null) updates['title'] = title;
    if (description != null) updates['description'] = description;
    if (date != null) updates['date'] = Timestamp.fromDate(date);

    if (updates.isNotEmpty) {
      await taskCollection.doc(taskId).update(updates);
    }
  }

  Future<void> deleteTask(String taskId) async {
    await taskCollection.doc(taskId).delete();
  }

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
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> updateScheduleItem({
    required String id,
    String? subject,
    String? type,
    String? location,
    String? teacher,
    int? weekday,
    int? startMinutes,
    int? endMinutes,
  }) async {
    final Map<String, dynamic> updates = {};
    if (subject != null) updates['subject'] = subject;
    if (type != null) updates['type'] = type;
    if (location != null) updates['location'] = location;
    if (teacher != null) updates['teacher'] = teacher;
    if (weekday != null) updates['weekday'] = weekday;
    if (startMinutes != null) updates['startMinutes'] = startMinutes;
    if (endMinutes != null) updates['endMinutes'] = endMinutes;

    if (updates.isNotEmpty) {
      await scheduleCollection.doc(id).update(updates);
    }
  }

  Future<void> deleteScheduleItem(String id) async {
    await scheduleCollection.doc(id).delete();
  }
}