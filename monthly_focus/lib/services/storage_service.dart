/*
 * StorageService: 앱 설정 및 상태 저장소
 * 
 * 주요 기능:
 * - SharedPreferences를 사용한 앱 설정 저장/로드
 * - 앱 최초 설치일 관리
 * - 알림 설정 관리
 * - 가이드 표시 여부 관리
 * - 위젯과의 데이터 공유
 * 
 * 저장 데이터:
 * - app_settings: 앱 설정 (알림, 리셋 시간 등)
 * - install_date: 앱 설치일
 * - welcome_guide_shown: 가이드 표시 여부
 * - monthlyGoals: 월간 목표 (위젯과 공유)
 */

import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/material.dart';
import '../models/app_settings.dart';
import '../models/goal.dart';
import '../models/daily_check.dart';

class StorageService {
  static final StorageService _instance = StorageService._internal();
  static const String _settingsKey = 'app_settings';
  static const String _installDateKey = 'install_date';  // 설치일 저장 키
  static const String _welcomeShownKey = 'welcome_guide_shown';  // 가이드 표시 여부 키
  static const String _monthlyGoalsKey = 'monthlyGoals';  // 월간 목표 키 (위젯과 공유)
  late SharedPreferences _prefs;

  factory StorageService() {
    return _instance;
  }

  StorageService._internal();

  // SharedPreferences를 초기화하고 앱 설치일을 저장합니다.
  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
    
    if (!_prefs.containsKey(_installDateKey)) {
      await _prefs.setString(_installDateKey, DateTime.now().toIso8601String());
    }
  }

  // 앱 최초 설치일을 반환합니다.
  DateTime getInstallDate() {
    final dateStr = _prefs.getString(_installDateKey);
    return dateStr != null ? DateTime.parse(dateStr) : DateTime.now();
  }

  // 앱 설정을 저장소에 저장합니다.
  Future<void> saveSettings(AppSettings settings) async {
    await _prefs.setString(_settingsKey, settings.toJson());
  }

  // 저장된 앱 설정을 로드합니다.
  AppSettings loadSettings() {
    final json = _prefs.getString(_settingsKey);
    return json != null ? AppSettings.fromJson(json) : AppSettings();
  }

  // 웰컴 가이드 표시 여부를 확인합니다.
  bool isWelcomeGuideShown() {
    return _prefs.getBool(_welcomeShownKey) ?? false;
  }

  // 웰컴 가이드를 표시했음을 저장합니다.
  Future<void> markWelcomeGuideAsShown() async {
    await _prefs.setBool(_welcomeShownKey, true);
  }

  // 모든 설정을 초기화하고 설치일을 현재 시점으로 업데이트합니다.
  Future<void> clearAllSettings() async {
    await _prefs.clear();
    await _prefs.setString(_installDateKey, DateTime.now().toIso8601String());
  }

  // 위젯과 공유할 월간 목표를 저장합니다.
  Future<void> saveMonthlyGoalsForWidget(List<Goal> goals, List<DailyCheck> dailyChecks) async {
    try {
      final today = DateTime.now();
      final widgetGoals = goals.map((goal) {
        final todayCheck = dailyChecks.firstWhere(
          (check) => check.goalId == goal.id && 
                     check.date.year == today.year &&
                     check.date.month == today.month &&
                     check.date.day == today.day,
          orElse: () => DailyCheck(
            goalId: goal.id ?? 0,
            date: today,
            isCompleted: false,
          ),
        );
        
        return {
          'id': goal.id.toString(),
          'title': goal.title,
          'isCompleted': todayCheck.isCompleted,
          'year': goal.month.year,
          'month': goal.month.month,
        };
      }).toList();
      
      await _prefs.setString(_monthlyGoalsKey, widgetGoals.toString());
    } catch (e) {
      print('위젯용 목표 저장 실패: $e');
    }
  }

  // 위젯에서 사용할 월간 목표를 로드합니다.
  List<Map<String, dynamic>> loadMonthlyGoalsForWidget() {
    try {
      final goalsStr = _prefs.getString(_monthlyGoalsKey);
      if (goalsStr != null) {
        // 간단한 파싱 (실제로는 JSON 사용 권장)
        return [];
      }
    } catch (e) {
      print('위젯용 목표 로드 실패: $e');
    }
    return [];
  }
} 