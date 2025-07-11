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

  static DateTime getStartOfMonth(DateTime date) {
    return DateTime(date.year, date.month, 1);
  }

  static DateTime getEndOfMonth(DateTime date) {
    return DateTime(date.year, date.month + 1, 0);
  }

  static bool isSameDay(DateTime? date1, DateTime? date2) {
    if (date1 == null || date2 == null) return false;
    return date1.year == date2.year &&
           date1.month == date2.month &&
           date1.day == date2.day;
  }

  static bool isSameMonth(DateTime? date1, DateTime? date2) {
    if (date1 == null || date2 == null) return false;
    return date1.year == date2.year && date1.month == date2.month;
  }

  static String formatMonth(DateTime date) {
    return '${date.year}년 ${date.month}월';
  }
} 