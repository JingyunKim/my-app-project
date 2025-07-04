import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/material.dart';
import '../models/app_settings.dart';

class StorageService {
  static final StorageService _instance = StorageService._internal();
  static SharedPreferences? _prefs;

  factory StorageService() {
    return _instance;
  }

  StorageService._internal();

  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  // 앱 설정 저장
  Future<void> saveSettings(AppSettings settings) async {
    final prefs = await SharedPreferences.getInstance();
    final map = settings.toMap();
    
    await prefs.setBool('notification_enabled', map['notification_enabled']);
    await prefs.setInt('notification_hour', map['notification_hour']);
    await prefs.setInt('notification_minute', map['notification_minute']);
    await prefs.setInt('reset_hour', map['reset_hour']);
    await prefs.setInt('reset_minute', map['reset_minute']);
  }

  // 앱 설정 로드
  Future<AppSettings> loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    
    return AppSettings(
      notificationEnabled: prefs.getBool('notification_enabled') ?? true,
      notificationTime: TimeOfDay(
        hour: prefs.getInt('notification_hour') ?? 23,
        minute: prefs.getInt('notification_minute') ?? 0,
      ),
      resetTime: TimeOfDay(
        hour: prefs.getInt('reset_hour') ?? 2,
        minute: prefs.getInt('reset_minute') ?? 0,
      ),
    );
  }
} 