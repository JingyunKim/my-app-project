import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/app_settings.dart';
import 'package:intl/intl.dart';

class AppDateUtils {
  // 현재 날짜를 반환합니다. (테스트 모드일 경우 테스트 날짜 반환)
  static DateTime getCurrentDate([BuildContext? context]) {
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

  // 12시간 단위로 시간을 포맷팅합니다 (예: "오후 11시 0분")
  static String formatTime12Hour(TimeOfDay time) {
    final hour = time.hour;
    final minute = time.minute;
    
    String period;
    int displayHour;
    
    if (hour == 0) {
      period = '오전';
      displayHour = 12;
    } else if (hour < 12) {
      period = '오전';
      displayHour = hour;
    } else if (hour == 12) {
      period = '오후';
      displayHour = 12;
    } else {
      period = '오후';
      displayHour = hour - 12;
    }
    
    return '$period $displayHour시 $minute분';
  }

  // 24시간을 12시간으로 변환합니다
  static TimeOfDay convertTo12Hour(TimeOfDay time) {
    return time; // TimeOfDay는 이미 24시간 형식이므로 그대로 반환
  }

  // 12시간 표시를 24시간으로 변환합니다
  static TimeOfDay convertFrom12Hour(int hour, int minute, bool isPM) {
    int convertedHour = hour;
    if (isPM && hour != 12) {
      convertedHour = hour + 12;
    } else if (!isPM && hour == 12) {
      convertedHour = 0;
    }
    return TimeOfDay(hour: convertedHour, minute: minute);
  }
} 