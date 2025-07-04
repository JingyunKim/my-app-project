import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_native_timezone/flutter_native_timezone.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  final FlutterLocalNotificationsPlugin _notifications = FlutterLocalNotificationsPlugin();

  factory NotificationService() {
    return _instance;
  }

  NotificationService._internal();

  Future<void> init() async {
    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    await _notifications.initialize(
      const InitializationSettings(
        android: androidSettings,
        iOS: iosSettings,
      ),
    );

    // 타임존 초기화
    tz.initializeTimeZones();
    final String timeZoneName = await FlutterNativeTimezone.getLocalTimezone();
    tz.setLocalLocation(tz.getLocation(timeZoneName));
  }

  // 매일 밤 11시 알림 설정
  Future<void> scheduleDailyReminder() async {
    await _notifications.zonedSchedule(
      0,
      '오늘의 목표를 체크해주세요',
      '하루를 마무리하기 전에 목표 달성 여부를 체크해주세요',
      _nextInstanceOfElevenPM(),
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'daily_reminder',
          '일일 체크 알림',
          channelDescription: '매일 밤 11시에 목표 체크를 상기시켜주는 알림입니다',
          importance: Importance.high,
          priority: Priority.high,
        ),
        iOS: DarwinNotificationDetails(
          sound: 'default.wav',
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
        ),
      ),
      androidAllowWhileIdle: true,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.time,
    );
  }

  // 다음 달 목표 설정 알림
  Future<void> scheduleMonthlyGoalReminder() async {
    final now = DateTime.now();
    final lastDayOfMonth = DateTime(now.year, now.month + 1, 0);
    
    if (now.day == lastDayOfMonth.day) {
      await _notifications.zonedSchedule(
        1,
        '다음 달 목표를 설정해주세요',
        '새로운 달을 위한 4가지 목표를 설정할 시간입니다',
        tz.TZDateTime.from(
          DateTime(now.year, now.month, now.day, 20), // 오후 8시
          tz.local,
        ),
        const NotificationDetails(
          android: AndroidNotificationDetails(
            'monthly_reminder',
            '월간 목표 설정 알림',
            channelDescription: '다음 달 목표 설정을 상기시켜주는 알림입니다',
            importance: Importance.high,
            priority: Priority.high,
          ),
          iOS: DarwinNotificationDetails(
            sound: 'default.wav',
            presentAlert: true,
            presentBadge: true,
            presentSound: true,
          ),
        ),
        androidAllowWhileIdle: true,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
      );
    }
  }

  // 다음 11시 시간 계산
  tz.TZDateTime _nextInstanceOfElevenPM() {
    final tz.TZDateTime now = tz.TZDateTime.now(tz.local);
    tz.TZDateTime scheduledDate = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day,
      23, // 23시 (11 PM)
    );

    if (scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }

    return scheduledDate;
  }

  // 알림 취소
  Future<void> cancelAllNotifications() async {
    await _notifications.cancelAll();
  }
} 