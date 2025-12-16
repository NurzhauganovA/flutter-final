import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../models/schedule_model.dart';
import '../services/database_service.dart';

class ScheduleProvider with ChangeNotifier {
  User? user = FirebaseAuth.instance.currentUser;

  DatabaseService get _db => DatabaseService(uid: user?.uid ?? '');

  Stream<List<ScheduleItem>> get scheduleStream => _db.schedule;

  Future<void> addScheduleItem({
    required String subject,
    required String type,
    required String location,
    required String teacher,
    required int weekday,
    required int startMinutes,
    required int endMinutes,
  }) async {
    await _db.addScheduleItem(
      subject: subject,
      type: type,
      location: location,
      teacher: teacher,
      weekday: weekday,
      startMinutes: startMinutes,
      endMinutes: endMinutes,
    );
    notifyListeners();
  }

  Future<void> deleteScheduleItem(String id) async {
    await _db.deleteScheduleItem(id);
  }
}


