import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/app_settings.dart';

class AppDateUtils {
  static AppSettings? _settings;

  // AppSettings를 초기화합니다.
  static void initialize(AppSettings settings) {
    _settings = settings;
  }

  // 현재 날짜를 반환합니다. (테스트 모드일 경우 테스트 날짜 반환)
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

  // 해당 월의 첫 날을 반환합니다.
  static DateTime getStartOfMonth(DateTime date) {
    return DateTime(date.year, date.month, 1);
  }

  // 해당 월의 마지막 날을 반환합니다.
  static DateTime getEndOfMonth(DateTime date) {
    return DateTime(date.year, date.month + 1, 0);
  }

  // 두 날짜가 같은 날인지 확인합니다.
  static bool isSameDay(DateTime? date1, DateTime? date2) {
    if (date1 == null || date2 == null) return false;
    return date1.year == date2.year &&
           date1.month == date2.month &&
           date1.day == date2.day;
  }

  // 두 날짜가 같은 월인지 확인합니다.
  static bool isSameMonth(DateTime? date1, DateTime? date2) {
    if (date1 == null || date2 == null) return false;
    return date1.year == date2.year && date1.month == date2.month;
  }

  // 날짜를 'YYYY년 MM월' 형식으로 포맷팅합니다.
  static String formatMonth(DateTime date) {
    return '${date.year}년 ${date.month}월';
  }
} 