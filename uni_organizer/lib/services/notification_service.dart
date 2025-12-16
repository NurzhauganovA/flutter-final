import 'dart:io';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest_all.dart';
import '../models/schedule_model.dart';
import '../models/task_model.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();
  
  bool _isInitialized = false;

  Future<void> initialize() async {
    if (_isInitialized) return;
    
    initializeTimeZones();

    String timeZoneName;
    try {
      timeZoneName = await FlutterTimezone.getLocalTimezone();
    } catch (e) {
      timeZoneName = 'Asia/Almaty';
    }

    try {
      final location = tz.getLocation(timeZoneName);
      tz.setLocalLocation(location);
    } catch (e) {
      try {
        final location = tz.getLocation('Asia/Almaty');
        tz.setLocalLocation(location);
      } catch (e2) {
        tz.setLocalLocation(tz.getLocation('UTC'));
      }
    }

    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    final DarwinInitializationSettings initializationSettingsDarwin =
        DarwinInitializationSettings(
      requestSoundPermission: true,
      requestBadgePermission: true,
      requestAlertPermission: true,
    );

    final InitializationSettings initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsDarwin,
    );

    await flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: (details) {},
    );
    
    _isInitialized = true;
  }

  Future<bool> requestPermissions() async {
    if (!_isInitialized) {
      await initialize();
    }
    
    if (Platform.isAndroid) {
      final androidImplementation = flutterLocalNotificationsPlugin
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>();
      
      if (androidImplementation != null) {
        final granted = await androidImplementation.requestNotificationsPermission();
        return granted ?? false;
      }
    } else if (Platform.isIOS) {
      final iosImplementation = flutterLocalNotificationsPlugin
          .resolvePlatformSpecificImplementation<
              IOSFlutterLocalNotificationsPlugin>();
      
      if (iosImplementation != null) {
        final granted = await iosImplementation.requestPermissions(
          alert: true,
          badge: true,
          sound: true,
        );
        return granted ?? false;
      }
    }
    return false;
  }

  Future<void> showInstantNotification({
    required String title,
    required String body,
  }) async {
    const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
      'main_channel',
      'Main Channel',
      importance: Importance.max,
      priority: Priority.high,
    );

    const NotificationDetails details = NotificationDetails(
      android: androidDetails,
      iOS: DarwinNotificationDetails(),
    );

    await flutterLocalNotificationsPlugin.show(
      0,
      title,
      body,
      details,
    );
  }

  Future<void> scheduleClassNotifications(List<ScheduleItem> items) async {
    if (!_isInitialized) {
      await initialize();
    }

    int scheduledCount = 0;
    for (var item in items) {
      try {
        final int notificationId = 10000 + (item.id.hashCode % 89999).abs();

        final notificationTime = _nextInstanceOfDayAndTime(
          item.weekday,
          item.startMinutes,
          minutesOffset: 5,
        );

        final now = tz.TZDateTime.now(tz.local);
        if (notificationTime.isBefore(now)) {
          continue;
        }

        await flutterLocalNotificationsPlugin.zonedSchedule(
          notificationId,
          '📚 ${item.subject}',
          '${item.type} starts in 5 minutes at ${item.location}',
          notificationTime,
          const NotificationDetails(
            android: AndroidNotificationDetails(
              'schedule_channel',
              'Schedule Notifications',
              channelDescription: 'Notifications for upcoming classes',
              importance: Importance.max,
              priority: Priority.high,
              enableVibration: true,
              playSound: true,
            ),
            iOS: DarwinNotificationDetails(
              presentAlert: true,
              presentBadge: true,
              presentSound: true,
            ),
          ),
          androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
          uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
          matchDateTimeComponents: DateTimeComponents.dayOfWeekAndTime,
        );

        scheduledCount++;
      } catch (e) {
        // Error scheduling notification
      }
    }
  }

  Future<void> scheduleTaskNotifications(List<Task> tasks) async {
    if (!_isInitialized) {
      await initialize();
    }
    
    for (int i = 20000; i < 29999; i++) {
      await flutterLocalNotificationsPlugin.cancel(i);
    }

    int scheduledCount = 0;
    final now = tz.TZDateTime.now(tz.local);
    
    for (var task in tasks) {
      if (task.isDone) continue;
      
      try {
        final taskDate = tz.TZDateTime.from(task.date, tz.local);
        
        final reminderDate = tz.TZDateTime(
          tz.local,
          taskDate.year,
          taskDate.month,
          taskDate.day,
          9,
          0,
        ).subtract(const Duration(days: 1));
        
        if (reminderDate.isBefore(now)) {
          continue;
        }
        
        final dayOfDeadline = tz.TZDateTime(
          tz.local,
          taskDate.year,
          taskDate.month,
          taskDate.day,
          8,
          0,
        );
        
        final int reminderId = 20000 + (task.id.hashCode % 9999).abs();
        final int deadlineId = 20000 + 10000 + (task.id.hashCode % 9999).abs();

        if (reminderDate.isAfter(now)) {
          await flutterLocalNotificationsPlugin.zonedSchedule(
            reminderId,
            '📝 Task Reminder: ${task.title}',
            'Due tomorrow! ${task.description.isNotEmpty ? task.description : ""}',
            reminderDate,
            const NotificationDetails(
              android: AndroidNotificationDetails(
                'task_channel',
                'Task Notifications',
                channelDescription: 'Notifications for task deadlines',
                importance: Importance.high,
                priority: Priority.high,
                enableVibration: true,
                playSound: true,
              ),
              iOS: DarwinNotificationDetails(
                presentAlert: true,
                presentBadge: true,
                presentSound: true,
              ),
            ),
            androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
            uiLocalNotificationDateInterpretation:
                UILocalNotificationDateInterpretation.absoluteTime,
          );
          scheduledCount++;
        }
        
        if (dayOfDeadline.isAfter(now) && dayOfDeadline.isBefore(taskDate.add(const Duration(hours: 1)))) {
          await flutterLocalNotificationsPlugin.zonedSchedule(
            deadlineId,
            '⏰ Deadline Today: ${task.title}',
            'This task is due today!',
            dayOfDeadline,
            const NotificationDetails(
              android: AndroidNotificationDetails(
                'task_channel',
                'Task Notifications',
                channelDescription: 'Notifications for task deadlines',
                importance: Importance.max,
                priority: Priority.high,
                enableVibration: true,
                playSound: true,
              ),
              iOS: DarwinNotificationDetails(
                presentAlert: true,
                presentBadge: true,
                presentSound: true,
              ),
            ),
            androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
            uiLocalNotificationDateInterpretation:
                UILocalNotificationDateInterpretation.absoluteTime,
          );
          scheduledCount++;
        }
      } catch (e) {
        // Error scheduling task notification
      }
    }
  }

  tz.TZDateTime _nextInstanceOfDayAndTime(
    int weekday,
    int startMinutes, {
    required int minutesOffset,
  }) {
    final tz.TZDateTime now = tz.TZDateTime.now(tz.local);

    final int hour = startMinutes ~/ 60;
    final int minute = startMinutes % 60;

    tz.TZDateTime scheduledDate = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day,
      hour,
      minute,
    );

    scheduledDate = scheduledDate.subtract(Duration(minutes: minutesOffset));

    while (scheduledDate.weekday != weekday) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }

    if (scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 7));
    }

    return scheduledDate;
  }
}