import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/app_settings.dart';

class AppDateUtils {
  static AppSettings? _settings;

  static void initialize(AppSettings settings) {
    _settings = settings;
  }

  /// 현재 앱 설정에 따라 현재 날짜를 반환합니다.
  /// 테스트 모드가 활성화되어 있고 테스트 날짜가 설정되어 있다면 테스트 날짜를 반환하고,
  /// 그렇지 않다면 실제 현재 날짜를 반환합니다.
  static DateTime getCurrentDate([BuildContext? context]) {
    if (_settings != null && _settings!.isTestMode && _settings!.testDate != null) {
      return _settings!.testDate!;
    }
    if (context != null) {
      try {
        final settings = Provider.of<AppSettings>(context, listen: false);
        if (settings.isTestMode && settings.testDate != null) {
          return settings.testDate!;
        }
      } catch (_) {}
    }
    return DateTime.now();
  }
} 