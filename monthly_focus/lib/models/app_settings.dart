/*
 * AppSettings: 앱 설정 데이터 모델
 * 
 * 주요 속성:
 * - notification_enabled: 알림 활성화 여부
 * - notification_time: 일일 알림 시간
 * - next_month_notification: 다음 달 목표 알림 여부
 * - theme_mode: 앱 테마 모드 (라이트/다크)
 * 
 * 기능:
 * - JSON 직렬화/역직렬화
 * - SharedPreferences 저장/로드
 * - 설정 변경 이벤트 처리
 */

import 'package:flutter/material.dart';
import 'dart:convert';

class AppSettings {
  final bool notificationEnabled;
  final TimeOfDay notificationTime;
  final TimeOfDay resetTime;

  AppSettings({
    this.notificationEnabled = true,
    TimeOfDay? notificationTime,
    TimeOfDay? resetTime,
  })  : notificationTime = notificationTime ?? const TimeOfDay(hour: 23, minute: 0),
        resetTime = resetTime ?? const TimeOfDay(hour: 2, minute: 0);

  // SharedPreferences에서 사용할 Map 변환 메서드
  Map<String, dynamic> toMap() {
    return {
      'notification_enabled': notificationEnabled,
      'notification_hour': notificationTime.hour,
      'notification_minute': notificationTime.minute,
      'reset_hour': resetTime.hour,
      'reset_minute': resetTime.minute,
    };
  }

  // JSON 직렬화
  String toJson() => json.encode(toMap());

  // SharedPreferences에서 데이터를 가져올 때 사용할 팩토리 메서드
  factory AppSettings.fromMap(Map<String, dynamic> map) {
    return AppSettings(
      notificationEnabled: map['notification_enabled'] as bool,
      notificationTime: TimeOfDay(
        hour: map['notification_hour'] as int,
        minute: map['notification_minute'] as int,
      ),
      resetTime: TimeOfDay(
        hour: map['reset_hour'] as int,
        minute: map['reset_minute'] as int,
      ),
    );
  }

  // JSON 역직렬화
  factory AppSettings.fromJson(String source) => 
      AppSettings.fromMap(json.decode(source) as Map<String, dynamic>);

  // 설정 복사본 생성 (상태 업데이트 시 사용)
  AppSettings copyWith({
    bool? notificationEnabled,
    TimeOfDay? notificationTime,
    TimeOfDay? resetTime,
  }) {
    return AppSettings(
      notificationEnabled: notificationEnabled ?? this.notificationEnabled,
      notificationTime: notificationTime ?? this.notificationTime,
      resetTime: resetTime ?? this.resetTime,
    );
  }
} 