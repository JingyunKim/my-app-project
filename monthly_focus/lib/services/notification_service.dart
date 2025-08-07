/*
 * NotificationService: 로컬 알림 관리
 * 
 * 주요 기능:
 * - 일일 체크 알림 예약/취소
 * - 다음 달 목표 설정 알림 예약/취소
 * - 알림 권한 요청 및 관리
 * 
 * 알림 종류:
 * - daily_check: 매일 지정된 시간에 체크 알림
 * - next_month_goals: 매월 마지막 주에 다음 달 목표 설정 알림
 */

import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_native_timezone/flutter_native_timezone.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import '../models/app_settings.dart';
import '../utils/app_date_utils.dart';

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

  // 매일 지정된 시간에 알림 설정
  Future<void> scheduleDailyReminder({TimeOfDay? notificationTime}) async {
    // 기존 알림 취소
    await _notifications.cancel(0);
    
    final timeToUse = notificationTime ?? const TimeOfDay(hour: 23, minute: 0);
    final scheduledDate = _nextInstanceOfTime(timeToUse);
    
    print('알림 서비스: 알림 예약 - ${AppDateUtils.formatTime12Hour(timeToUse)}');
    
    await _notifications.zonedSchedule(
      0,
      '오늘 하루도 수고하셨어요! 🌙',
      '목표 달성 체크로 오늘 하루를 마무리해보세요',
      scheduledDate,
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'daily_reminder',
          '일일 체크 알림',
          channelDescription: '매일 지정된 시간에 목표 체크를 상기시켜주는 알림입니다',
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
    final nextMonth = DateTime(now.year, now.month + 1);
    
    if (now.day == lastDayOfMonth.day) {
      await _notifications.zonedSchedule(
        1,
        '${nextMonth.month}월의 새로운 목표를 설정해보세요 ✨',
        '다가오는 한 달을 위한 의미있는 목표를 준비해보세요',
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

  // 다음 시간 계산
  tz.TZDateTime _nextInstanceOfTime(TimeOfDay time) {
    final tz.TZDateTime now = tz.TZDateTime.now(tz.local);
    tz.TZDateTime scheduledDate = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day,
      time.hour,
      time.minute,
    );

    print('알림 서비스: 현재 시간 - ${AppDateUtils.formatTime12Hour(TimeOfDay(hour: now.hour, minute: now.minute))}');
    print('알림 서비스: 예약 시간 - ${AppDateUtils.formatTime12Hour(time)}');

    if (scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
      print('알림 서비스: 예약 시간이 과거이므로 다음 날로 조정 - ${AppDateUtils.formatTime12Hour(TimeOfDay(hour: scheduledDate.hour, minute: scheduledDate.minute))}');
    }

    print('알림 서비스: 최종 예약 시간 - ${scheduledDate.year}-${scheduledDate.month}-${scheduledDate.day} ${AppDateUtils.formatTime12Hour(TimeOfDay(hour: scheduledDate.hour, minute: scheduledDate.minute))}');
    return scheduledDate;
  }

  // 알림 취소
  Future<void> cancelAllNotifications() async {
    await _notifications.cancelAll();
  }

  // 테스트용 즉시 알림
  Future<void> showTestNotification() async {
    await _notifications.show(
      999,
      '알림 테스트 ✨',
      '알림이 정상적으로 설정되었습니다',
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'test_notification',
          '테스트 알림',
          channelDescription: '알림 기능 테스트를 위한 채널입니다',
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
    );
  }

  // 테스트용 예약 알림 (10초 후)
  Future<void> showTestScheduledNotification() async {
    final scheduledTime = tz.TZDateTime.now(tz.local).add(const Duration(seconds: 10));
    
    await _notifications.zonedSchedule(
      998,
      '예약 알림 테스트 ⏰',
      '10초 후 알림이 정상적으로 전달되었습니다',
      scheduledTime,
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'test_scheduled_notification',
          '테스트 예약 알림',
          channelDescription: '알림 예약 기능 테스트를 위한 채널입니다',
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