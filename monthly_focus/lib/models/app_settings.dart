/*
 * AppSettings: 앱 설정 데이터 모델
 * 
 * 주요 속성:
 * - notification_enabled: 알림 활성화 여부
 * - notification_time: 일일 알림 시간
 * - next_month_notification: 다음 달 목표 알림 여부
 * - theme_mode: 앱 테마 모드 (라이트/다크)
 * - is_test_mode: 테스트 모드 활성화 여부
 * - test_date: 테스트 모드에서 사용할 날짜
 * 
 * 기능:
 * - JSON 직렬화/역직렬화
 * - SharedPreferences 저장/로드
 * - 설정 변경 이벤트 처리
 */

import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:provider/provider.dart';

class AppSettings extends ChangeNotifier {
  bool _notificationEnabled;
  TimeOfDay _notificationTime;
  TimeOfDay _resetTime;
  bool _isTestMode;
  DateTime? _testDate;

  bool get notificationEnabled => _notificationEnabled;
  TimeOfDay get notificationTime => _notificationTime;
  TimeOfDay get resetTime => _resetTime;
  bool get isTestMode => _isTestMode;
  DateTime? get testDate => _testDate;

  // 알림 활성화 상태를 설정합니다.
  set notificationEnabled(bool value) {
    _notificationEnabled = value;
    notifyListeners();
  }

  // 알림 시간을 설정합니다.
  set notificationTime(TimeOfDay value) {
    _notificationTime = value;
    notifyListeners();
  }

  // 일일 리셋 시간을 설정합니다.
  set resetTime(TimeOfDay value) {
    _resetTime = value;
    notifyListeners();
  }

  // 테스트 모드 활성화 상태를 설정하고, 비활성화 시 테스트 날짜를 초기화합니다.
  set isTestMode(bool value) {
    _isTestMode = value;
    if (!value) {
      _testDate = null;
    }
    notifyListeners();
  }

  // 테스트 날짜를 설정합니다.
  set testDate(DateTime? value) {
    _testDate = value;
    notifyListeners();
  }

  // 앱 설정을 초기화합니다.
  AppSettings({
    bool notificationEnabled = true,
    TimeOfDay? notificationTime,
    TimeOfDay? resetTime,
    bool isTestMode = false,
    DateTime? testDate,
  })  : _notificationEnabled = notificationEnabled,
        _notificationTime = notificationTime ?? const TimeOfDay(hour: 23, minute: 0),
        _resetTime = resetTime ?? const TimeOfDay(hour: 2, minute: 0),
        _isTestMode = isTestMode,
        _testDate = testDate;

  // SharedPreferences에서 사용할 Map 변환 메서드
  Map<String, dynamic> toMap() {
    return {
      'notification_enabled': notificationEnabled,
      'notification_hour': notificationTime.hour,
      'notification_minute': notificationTime.minute,
      'reset_hour': resetTime.hour,
      'reset_minute': resetTime.minute,
      'is_test_mode': isTestMode,
      'test_date': testDate?.toIso8601String(),
    };
  }

  // JSON 직렬화
  String toJson() => json.encode(toMap());

  // SharedPreferences에서 데이터를 가져올 때 사용할 팩토리 메서드
  factory AppSettings.fromMap(Map<String, dynamic> map) {
    return AppSettings(
      notificationEnabled: map['notification_enabled'] as bool? ?? true,
      notificationTime: TimeOfDay(
        hour: (map['notification_hour'] as int?) ?? 23,
        minute: (map['notification_minute'] as int?) ?? 0,
      ),
      resetTime: TimeOfDay(
        hour: (map['reset_hour'] as int?) ?? 2,
        minute: (map['reset_minute'] as int?) ?? 0,
      ),
      isTestMode: map['is_test_mode'] as bool? ?? false,
      testDate: map['test_date'] != null 
          ? DateTime.parse(map['test_date'] as String)
          : null,
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
    bool? isTestMode,
    DateTime? testDate,
  }) {
    return AppSettings(
      notificationEnabled: notificationEnabled ?? this.notificationEnabled,
      notificationTime: notificationTime ?? this.notificationTime,
      resetTime: resetTime ?? this.resetTime,
      isTestMode: isTestMode ?? this.isTestMode,
      testDate: testDate ?? this.testDate,
    );
  }
} 