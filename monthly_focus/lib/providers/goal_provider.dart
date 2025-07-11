/*
 * GoalProvider: 단일 목표 상태 관리
 * 
 * 주요 기능:
 * - 목표 데이터 상태 관리
 * - 목표 수정 이벤트 처리
 * - 목표 삭제 이벤트 처리
 * - 목표 체크 상태 관리
 * 
 * 상태 구조:
 * - goal: 현재 목표 데이터
 * - isEditing: 수정 모드 여부
 * - dailyChecks: 목표의 체크 데이터
 */

import 'package:flutter/material.dart';
import '../models/goal.dart';
import '../models/daily_check.dart';
import '../services/database_service.dart';
import '../services/storage_service.dart';

class GoalProvider with ChangeNotifier {
  final DatabaseService _db = DatabaseService();
  final StorageService _storage = StorageService();
  List<Goal> _monthlyGoals = [];
  List<Goal> _nextMonthGoals = [];  // 다음 달 목표 저장
  List<DailyCheck> _todayChecks = [];
  DateTime _currentMonth = DateTime.now();
  Map<DateTime, List<DailyCheck>> _dailyChecksCache = {};
  Set<DateTime> _loadingDates = {};

  // TODO: [테스트 코드] 배포 전 아래 테스트용 코드 제거
  // 1. testCurrentDate 변수
  // 2. testCurrentDate getter
  // 3. setTestCurrentDate 메서드
  // 4. canSetNextMonthGoals 메서드에서 실제 DateTime.now() 사용하도록 변경
  // 5. HomeScreen의 날짜 변경 버튼 제거
  DateTime _testCurrentDate = DateTime.now();
  DateTime get testCurrentDate => _testCurrentDate;

  Future<void> setTestCurrentDate(DateTime date) async {
    _testCurrentDate = date;
    _currentMonth = DateTime(date.year, date.month);
    await loadMonthlyGoals();
    await loadNextMonthGoals();
    await loadTodayChecks();
    notifyListeners();
  }

  List<Goal> get monthlyGoals => _monthlyGoals;
  List<Goal> get nextMonthGoals => _nextMonthGoals;  // 다음 달 목표 getter
  List<DailyCheck> get todayChecks => _todayChecks;
  DateTime get currentMonth => _currentMonth;

  // 현재 월의 목표 로드
  Future<void> loadMonthlyGoals() async {
    _monthlyGoals = await _db.getGoalsByMonth(_currentMonth);
    notifyListeners();
  }

  // 다음 달 목표 로드
  Future<void> loadNextMonthGoals() async {
    final nextMonth = DateTime(_currentMonth.year, _currentMonth.month + 1, 1);
    _nextMonthGoals = await _db.getGoalsByMonth(nextMonth);
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
    final key = DateTime(date.year, date.month, date.day);
    
    // 이미 로딩 중이거나 캐시에 있는 경우 캐시된 데이터 반환
    if (_loadingDates.contains(key) || _dailyChecksCache.containsKey(key)) {
      return _dailyChecksCache[key] ?? [];
    }

    _loadingDates.add(key);
    
    try {
      final checks = await _db.getDailyChecksByDate(date);
      _dailyChecksCache[key] = checks;
      notifyListeners();
      return checks;
    } finally {
      _loadingDates.remove(key);
    }
  }

  // 캐시 정리
  void clearOldCache() {
    final now = DateTime.now();
    final oneMonthAgo = DateTime(now.year, now.month - 1, now.day);
    
    _dailyChecksCache.removeWhere((date, _) => date.isBefore(oneMonthAgo));
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
    final now = testCurrentDate;  // DateTime.now() 대신 testCurrentDate 사용
    final installDate = _storage.getInstallDate();
    
    // 설치 당월인 경우 항상 설정 가능
    if (now.year == installDate.year && now.month == installDate.month) {
      return true;
    }
    
    // 25일 이후부터 설정 가능
    return now.day >= 25;
  }

  // 특정 월의 목표 조회
  Future<List<Goal>> getGoalsByMonth(DateTime month) async {
    return await _db.getGoalsByMonth(month);
  }
} 