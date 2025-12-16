import 'package:cloud_firestore/cloud_firestore.dart';

class ScheduleItem {
  final String id;
  final String subject;
  final String type; // Lecture, Lab, Seminar, etc.
  final String location;
  final String teacher;
  final int weekday; // 1 = Monday ... 7 = Sunday
  final int startMinutes; // minutes from 00:00
  final int endMinutes; // minutes from 00:00

  ScheduleItem({
    required this.id,
    required this.subject,
    required this.type,
    required this.location,
    required this.teacher,
    required this.weekday,
    required this.startMinutes,
    required this.endMinutes,
  });

  factory ScheduleItem.fromMap(Map<String, dynamic> data, String documentId) {
    return ScheduleItem(
      id: documentId,
      subject: data['subject'] ?? '',
      type: data['type'] ?? '',
      location: data['location'] ?? '',
      teacher: data['teacher'] ?? '',
      weekday: data['weekday'] ?? 1,
      startMinutes: data['startMinutes'] ?? 0,
      endMinutes: data['endMinutes'] ?? 0,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'subject': subject,
      'type': type,
      'location': location,
      'teacher': teacher,
      'weekday': weekday,
      'startMinutes': startMinutes,
      'endMinutes': endMinutes,
    };
  }

  String get timeRange {
    String format(int minutes) {
      final h = (minutes ~/ 60).toString().padLeft(2, '0');
      final m = (minutes % 60).toString().padLeft(2, '0');
      return '$h:$m';
    }

    return '${format(startMinutes)} - ${format(endMinutes)}';
  }
}


