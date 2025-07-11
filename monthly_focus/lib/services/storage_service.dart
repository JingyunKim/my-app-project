/*
 * StorageService: 앱 설정 및 상태 저장소
 * 
 * 주요 기능:
 * - SharedPreferences를 사용한 앱 설정 저장/로드
 * - 앱 최초 설치일 관리
 * - 알림 설정 관리
 * - 가이드 표시 여부 관리
 * 
 * 저장 데이터:
 * - app_settings: 앱 설정 (알림, 리셋 시간 등)
 * - install_date: 앱 설치일
 * - welcome_guide_shown: 가이드 표시 여부
 */

import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/material.dart';
import '../models/app_settings.dart';

class StorageService {
  static final StorageService _instance = StorageService._internal();
  static const String _settingsKey = 'app_settings';
  static const String _installDateKey = 'install_date';  // 설치일 저장 키
  static const String _welcomeShownKey = 'welcome_guide_shown';  // 가이드 표시 여부 키
  late SharedPreferences _prefs;

  factory StorageService() {
    return _instance;
  }

  StorageService._internal();

  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
    
    // 앱 최초 설치 시 현재 날짜 저장
    if (!_prefs.containsKey(_installDateKey)) {
      await _prefs.setString(_installDateKey, DateTime.now().toIso8601String());
    }
  }

  // 앱 최초 설치일 조회
  DateTime getInstallDate() {
    final dateStr = _prefs.getString(_installDateKey);
    return dateStr != null ? DateTime.parse(dateStr) : DateTime.now();
  }

  // 앱 설정 저장
  Future<void> saveSettings(AppSettings settings) async {
    await _prefs.setString(_settingsKey, settings.toJson());
  }

  // 앱 설정 로드
  AppSettings loadSettings() {
    final json = _prefs.getString(_settingsKey);
    return json != null ? AppSettings.fromJson(json) : AppSettings();
  }

  // 가이드 표시 여부 확인
  bool isWelcomeGuideShown() {
    return _prefs.getBool(_welcomeShownKey) ?? false;
  }

  // 가이드 표시 완료 저장
  Future<void> markWelcomeGuideAsShown() async {
    await _prefs.setBool(_welcomeShownKey, true);
  }

  // 모든 설정 초기화
  Future<void> clearAllSettings() async {
    await _prefs.clear();
    // 설치일을 현재 시점으로 업데이트
    await _prefs.setString(_installDateKey, DateTime.now().toIso8601String());
  }
} 