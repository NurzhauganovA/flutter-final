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
    
    // Инициализируем таймзоны с полными данными (включая Asia/Almaty для Астаны)
    tz.initializeTimeZones();

    // Получаем таймзону устройства
    String timeZoneName;
    try {
      timeZoneName = await FlutterTimezone.getLocalTimezone();
      print('🌍 Detected timezone: $timeZoneName');
    } catch (e) {
      print('⚠️ Failed to get timezone, using Asia/Almaty (Astana): $e');
      timeZoneName = 'Asia/Almaty'; // Астана, Казахстан (+5)
    }

    // Устанавливаем таймзону
    try {
      final location = tz.getLocation(timeZoneName);
      tz.setLocalLocation(location);
      print('✅ Timezone set to: ${location.name}');
    } catch (e) {
      print('⚠️ Timezone $timeZoneName not found, trying Asia/Almaty: $e');
      try {
        // Пробуем Астану напрямую
        final location = tz.getLocation('Asia/Almaty');
        tz.setLocalLocation(location);
        print('✅ Timezone set to Asia/Almaty (Astana)');
      } catch (e2) {
        print('❌ Failed to set timezone, using UTC: $e2');
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
      onDidReceiveNotificationResponse: (details) {
        // Обработка нажатия на уведомление
        print('📱 Notification tapped: ${details.payload}');
      },
    );
    
    _isInitialized = true;
    print('✅ NotificationService initialized');
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
        print('📱 Android notification permission: $granted');
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
        print('📱 iOS notification permission: $granted');
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
    
    print("🔔 Scheduling notifications for ${items.length} classes");
    
    // Отменяем только уведомления расписания (ID от 10000 до 99999)
    for (int i = 10000; i < 99999; i++) {
      await flutterLocalNotificationsPlugin.cancel(i);
    }

    int scheduledCount = 0;
    for (var item in items) {
      try {
        // Вычисляем время напоминания (за 5 минут до начала)
        final notificationTime = _nextInstanceOfDayAndTime(
          item.weekday,
          item.startMinutes,
          minutesOffset: 5,
        );
        
        // Проверяем, что время в будущем
        final now = tz.TZDateTime.now(tz.local);
        if (notificationTime.isBefore(now)) {
          print("⏭️ Skipping ${item.subject} - notification time is in the past");
          continue;
        }

        final int notificationId = 10000 + (item.id.hashCode % 89999).abs();

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
        print("✅ Scheduled: ${item.subject} at ${notificationTime.toString()}");
      } catch (e) {
        print("❌ Error scheduling ${item.subject}: $e");
      }
    }
    
    print("✅ Total scheduled: $scheduledCount/${items.length}");
  }

  Future<void> scheduleTaskNotifications(List<Task> tasks) async {
    if (!_isInitialized) {
      await initialize();
    }
    
    print("🔔 Scheduling notifications for ${tasks.length} tasks");
    
    // Отменяем только уведомления задач (ID от 20000 до 29999)
    for (int i = 20000; i < 29999; i++) {
      await flutterLocalNotificationsPlugin.cancel(i);
    }

    int scheduledCount = 0;
    final now = tz.TZDateTime.now(tz.local);
    
    for (var task in tasks) {
      if (task.isDone) continue; // Пропускаем выполненные задачи
      
      try {
        // Создаем дату задачи в локальной таймзоне
        final taskDate = tz.TZDateTime.from(task.date, tz.local);
        
        // Напоминание за день до дедлайна в 9:00
        final reminderDate = tz.TZDateTime(
          tz.local,
          taskDate.year,
          taskDate.month,
          taskDate.day,
          9, // 9:00 утра
          0,
        ).subtract(const Duration(days: 1));
        
        // Если напоминание уже прошло, пропускаем
        if (reminderDate.isBefore(now)) {
          continue;
        }
        
        // Также напоминание в день дедлайна в 8:00
        final dayOfDeadline = tz.TZDateTime(
          tz.local,
          taskDate.year,
          taskDate.month,
          taskDate.day,
          8, // 8:00 утра
          0,
        );
        
        final int reminderId = 20000 + (task.id.hashCode % 9999).abs();
        final int deadlineId = 20000 + 10000 + (task.id.hashCode % 9999).abs();

        // Напоминание за день
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
        
        // Напоминание в день дедлайна
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
        print("❌ Error scheduling task ${task.title}: $e");
      }
    }
    
    print("✅ Total task notifications scheduled: $scheduledCount");
  }

  tz.TZDateTime _nextInstanceOfDayAndTime(
    int weekday,
    int startMinutes, {
    required int minutesOffset,
  }) {
    final tz.TZDateTime now = tz.TZDateTime.now(tz.local);
    print('🕐 Current time: $now (timezone: ${tz.local.name})');

    final int hour = startMinutes ~/ 60;
    final int minute = startMinutes % 60;

    // Создаем дату начала пары сегодня
    tz.TZDateTime scheduledDate = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day,
      hour,
      minute,
    );

    // Сдвигаем на нужное время напоминания (вычитаем минуты)
    scheduledDate = scheduledDate.subtract(Duration(minutes: minutesOffset));

    // Логика переноса дней:
    // 1. Сначала находим правильный день недели
    while (scheduledDate.weekday != weekday) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }

    // 2. Если рассчитанное время напоминания УЖЕ прошло, переносим на следующую неделю
    if (scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 7));
    }

    print('📅 Scheduled notification: $scheduledDate (weekday: $weekday, time: $hour:$minute)');
    return scheduledDate;
  }
}