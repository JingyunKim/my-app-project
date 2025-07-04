import 'package:flutter/material.dart';
import '../models/goal.dart';
import '../models/daily_check.dart';
import '../services/database_service.dart';

class GoalProvider with ChangeNotifier {
  final DatabaseService _db = DatabaseService();
  List<Goal> _monthlyGoals = [];
  List<DailyCheck> _todayChecks = [];
  DateTime _currentMonth = DateTime.now();
  Map<DateTime, List<DailyCheck>> _dailyChecksCache = {};

  List<Goal> get monthlyGoals => _monthlyGoals;
  List<DailyCheck> get todayChecks => _todayChecks;
  DateTime get currentMonth => _currentMonth;

  // 현재 월의 목표 로드
  Future<void> loadMonthlyGoals() async {
    _monthlyGoals = await _db.getGoalsByMonth(_currentMonth);
    notifyListeners();
  }

  // 오늘의 체크 상태 로드
  Future<void> loadTodayChecks() async {
    final now = DateTime.now();
    _todayChecks = await _db.getDailyChecksByDate(
      DateTime(now.year, now.month, now.day),
    );
    notifyListeners();
  }

  // 캐시된 체크 데이터 가져오기
  List<DailyCheck> getCachedDailyChecks(DateTime date) {
    final key = DateTime(date.year, date.month, date.day);
    return _dailyChecksCache[key] ?? [];
  }

  // 비동기로 데이터 로드 및 캐시 업데이트
  Future<List<DailyCheck>> loadDailyChecks(DateTime date) async {
    final checks = await _db.getDailyChecksByDate(date);
    final key = DateTime(date.year, date.month, date.day);
    _dailyChecksCache[key] = checks;
    notifyListeners();
    return checks;
  }

  // 특정 날짜의 체크 상태 조회 (달력용)
  Future<List<DailyCheck>> getDailyChecks(DateTime date) async {
    return await _db.getDailyChecksByDate(
      DateTime(date.year, date.month, date.day),
    );
  }

  // 새로운 목표 추가
  Future<void> addGoal(String title, String? emoji, int position) async {
    // 다음 달 1일 생성
    final now = DateTime.now();
    final nextMonth = DateTime(now.year, now.month + 1, 1);

    final goal = Goal(
      month: nextMonth,
      position: position,
      title: title,
      emoji: emoji,
    );

    await _db.insertGoal(goal);
    await loadMonthlyGoals();
  }

  // 목표 체크 상태 업데이트
  Future<void> toggleGoalCheck(Goal goal) async {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    
    // 이미 체크된 항목이 있는지 확인
    final existingCheck = _todayChecks.firstWhere(
      (check) => check.goalId == goal.id,
      orElse: () => DailyCheck(
        goalId: goal.id!,
        date: today,
        isCompleted: false,
      ),
    );

    if (existingCheck.id == null) {
      // 새로운 체크 생성
      await _db.insertDailyCheck(
        DailyCheck(
          goalId: goal.id!,
          date: today,
          isCompleted: true,
        ),
      );
    } else {
      // 기존 체크 업데이트
      await _db.updateDailyCheck(
        existingCheck.copyWith(
          isCompleted: !existingCheck.isCompleted,
        ),
      );
    }

    await loadTodayChecks();
  }

  // 월 변경
  void changeMonth(DateTime month) {
    _currentMonth = month;
    loadMonthlyGoals();
  }

  // 다음 달 목표 설정 가능 여부 확인
  bool canSetNextMonthGoals() {
    final now = DateTime.now();
    final lastDayOfMonth = DateTime(now.year, now.month + 1, 0);
    return now.day == lastDayOfMonth.day;
  }
} 