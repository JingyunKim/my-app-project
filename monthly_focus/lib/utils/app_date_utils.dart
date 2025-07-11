import 'package:flutter/material.dart';

class AppDateUtils {
  static DateTime getCurrentDate([BuildContext? context]) {
    // 테스트 모드를 위한 context 파라미터 (미사용)
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