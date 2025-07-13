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
import 'package:flutter/foundation.dart';
import '../models/goal.dart';
import '../models/daily_check.dart';
import '../models/app_settings.dart';
import '../services/database_service.dart';
import '../services/storage_service.dart';
import '../utils/app_date_utils.dart';

class GoalProvider with ChangeNotifier {
  final DatabaseService _db = DatabaseService();
  final StorageService _storage = StorageService();
  final AppSettings _settings;
  
  List<Goal> _monthlyGoals = [];
  List<Goal> _nextMonthGoals = [];
  List<Goal> _calendarMonthGoals = [];
  List<DailyCheck> _monthlyChecks = [];
  late DateTime _currentMonth;
  late DateTime _selectedMonth;
  
  // 캐시 관리 개선
  final Map<String, List<DailyCheck>> _dailyChecksCache = {};
  final Set<String> _loadingDates = {};
  
  // 캐시 만료 시간 설정 (1시간)
  static const cacheDuration = Duration(hours: 1);
  final Map<String, DateTime> _cacheTimestamps = {};

  GoalProvider(this._settings) {
    _currentMonth = AppDateUtils.getCurrentDate();
    _selectedMonth = _currentMonth;
    _startCacheCleanupTimer();
  }

  // 주기적인 캐시 정리를 위한 타이머를 시작합니다.
  void _startCacheCleanupTimer() {
    Future.delayed(const Duration(minutes: 30), () {
      _cleanExpiredCache();
      _startCacheCleanupTimer();
    });
  }

  // 만료된 캐시 데이터를 정리합니다.
  void _cleanExpiredCache() {
    final now = DateTime.now();
    _cacheTimestamps.removeWhere((key, timestamp) {
      if (now.difference(timestamp) > cacheDuration) {
        _dailyChecksCache.remove(key);
        return true;
      }
      return false;
    });
  }

  // 날짜에 대한 캐시 키를 생성합니다. (형식: YYYY-MM-DD)
  String _getCacheKey(DateTime date) {
    return '${date.year}-${date.month}-${date.day}';
  }

  List<Goal> get monthlyGoals => _monthlyGoals;
  List<Goal> get nextMonthGoals => _nextMonthGoals;
  List<Goal> get calendarMonthGoals => _calendarMonthGoals;
  List<DailyCheck> get monthlyChecks => _monthlyChecks;
  List<DailyCheck> get todayChecks => getDailyChecksByDate(_now);
  DateTime get currentMonth => _currentMonth;
  DateTime get selectedMonth => _selectedMonth;
  DateTime get _now => _settings.isTestMode && _settings.testDate != null
      ? _settings.testDate!
      : DateTime.now();

  // 다음 달 목표를 데이터베이스에서 로드합니다.
  Future<void> loadNextMonthGoals() async {
    final nextMonth = DateTime(_currentMonth.year, _currentMonth.month + 1, 1);
    final goals = await _db.getGoalsByMonth(nextMonth);
    if (!listEquals(_nextMonthGoals, goals)) {
      _nextMonthGoals = goals;
      notifyListeners();
    }
  }

  // 현재 월의 목표를 데이터베이스에서 로드합니다.
  Future<void> loadMonthlyGoals() async {
    final goals = await _db.getGoalsByMonth(_currentMonth);
    if (!listEquals(_monthlyGoals, goals)) {
      _monthlyGoals = goals;
      notifyListeners();
    }
    await loadTodayChecks();
  }

  // 달력 화면의 선택된 월 목표와 체크 데이터를 로드합니다.
  Future<void> loadCalendarMonthGoals(DateTime month) async {
    print('달력 데이터: ${month.year}년 ${month.month}월 데이터 로드');
    _selectedMonth = month;
    
    final goals = await _db.getGoalsByMonth(month);
    _calendarMonthGoals = goals;
    
    await refreshMonthlyChecks(month);
  }

  // 오늘의 체크 데이터를 로드합니다.
  Future<void> loadTodayChecks() async {
    final now = _now;
    if (!_monthlyChecks.any((check) => 
      check.date.year == now.year && 
      check.date.month == now.month && 
      check.date.day == now.day
    )) {
      final checks = await _db.getDailyChecksByDate(now);
      _monthlyChecks.addAll(checks);
      notifyListeners();
    }
  }

  // 특정 날짜의 체크 데이터를 캐시에서 가져옵니다.
  List<DailyCheck> getCachedDailyChecks(DateTime date) {
    final key = _getCacheKey(date);
    final checks = _dailyChecksCache[key];
    
    if (checks == null) {
      // 캐시에 없는 경우 데이터베이스에서 로드
      loadDailyChecks(date).then((loadedChecks) {
        _dailyChecksCache[key] = loadedChecks;
        _cacheTimestamps[key] = DateTime.now();
        notifyListeners();
      });
      return [];
    }
    
    // 캐시가 만료된 경우 새로 로드
    if (_cacheTimestamps[key] != null &&
        DateTime.now().difference(_cacheTimestamps[key]!) > cacheDuration) {
      loadDailyChecks(date).then((loadedChecks) {
        _dailyChecksCache[key] = loadedChecks;
        _cacheTimestamps[key] = DateTime.now();
        notifyListeners();
      });
    }
    
    return checks;
  }

  // 특정 날짜의 체크 데이터를 데이터베이스에서 로드하고 캐시를 업데이트합니다.
  Future<List<DailyCheck>> loadDailyChecks(DateTime date) async {
    final key = _getCacheKey(date);
    
    try {
      final checks = await _db.getDailyChecksByDate(date);
      
      // 현재 월의 체크 데이터도 업데이트
      if (date.year == _currentMonth.year && date.month == _currentMonth.month) {
        final existingChecks = _monthlyChecks.where((check) => 
          check.date.year == date.year && 
          check.date.month == date.month && 
          check.date.day == date.day
        ).toList();
        
        if (existingChecks.isEmpty) {
          _monthlyChecks.addAll(checks);
        }
      }
      
      _dailyChecksCache[key] = checks;
      _cacheTimestamps[key] = DateTime.now();
      notifyListeners();
      return checks;
    } catch (e) {
      print('Error loading daily checks: $e');
      _loadingDates.remove(key);
      return [];
    }
  }

  // 목표의 체크 상태를 토글하고 데이터베이스에 저장합니다.
  Future<void> toggleGoalCheck(Goal goal) async {
    final now = _now;
    final today = DateTime(now.year, now.month, now.day);
    
    final existingCheck = getDailyChecksByDate(today).firstWhere(
      (check) => check.goalId == goal.id,
      orElse: () => DailyCheck(
        goalId: goal.id!,
        date: today,
        isCompleted: false,
      ),
    );

    DailyCheck updatedCheck;
    if (existingCheck.id == null) {
      final newCheck = DailyCheck(
        goalId: goal.id!,
        date: today,
        isCompleted: true,
      );
      final checkId = await _db.insertDailyCheck(newCheck);
      updatedCheck = newCheck.copyWith(id: checkId);
      _monthlyChecks.add(updatedCheck);
    } else {
      updatedCheck = existingCheck.copyWith(
        isCompleted: !existingCheck.isCompleted,
      );
      await _db.updateDailyCheck(updatedCheck);
      
      final index = _monthlyChecks.indexWhere((check) => check.id == existingCheck.id);
      if (index >= 0) {
        _monthlyChecks[index] = updatedCheck;
      }
    }

    // 체크 데이터 변경 후 현재 월의 데이터를 새로고침
    await refreshMonthlyChecks(_currentMonth);
  }

  // 달력 화면의 월이 변경될 때 해당 월의 목표를 로드합니다.
  Future<void> changeCalendarMonth(DateTime month) async {
    await loadCalendarMonthGoals(month);
  }

  // 현재 날짜가 25일 이후인지 확인하여 다음 달 목표 설정 가능 여부를 반환합니다.
  bool canSetNextMonthGoals() {
    final now = _now;
    return now.day >= 25;
  }

  // 현재 월의 목표가 없는 경우에만 목표 설정이 가능합니다.
  bool canSetCurrentMonthGoals() {
    if (_monthlyGoals.isNotEmpty) {
      return false;
    }
    
    return true;
  }

  // 특정 날짜의 체크 데이터를 가져옵니다.
  List<DailyCheck> getDailyChecksByDate(DateTime date) {
    final key = _getCacheKey(date);
    
    // 1. 먼저 캐시된 데이터 확인
    if (_dailyChecksCache.containsKey(key)) {
      final cachedChecks = _dailyChecksCache[key]!;
      
      // 캐시가 만료되었는지 확인
      final timestamp = _cacheTimestamps[key];
      if (timestamp != null && DateTime.now().difference(timestamp) <= cacheDuration) {
        return cachedChecks;
      }
    }
    
    // 2. 현재 월의 체크 데이터에서 확인
    final checksFromMonthly = _monthlyChecks.where((check) => 
      check.date.year == date.year && 
      check.date.month == date.month && 
      check.date.day == date.day
    ).toList();
    
    if (checksFromMonthly.isNotEmpty) {
      // 찾은 데이터를 캐시에 저장
      _dailyChecksCache[key] = checksFromMonthly;
      _cacheTimestamps[key] = DateTime.now();
      return checksFromMonthly;
    }
    
    // 3. 데이터베이스에서 로드
    if (!_loadingDates.contains(key)) {
      _loadingDates.add(key);
      loadDailyChecks(date).then((checks) {
        _loadingDates.remove(key);
      });
    }
    
    // 로드 중인 동안 빈 리스트 반환
    return [];
  }

  // 특정 월의 체크 데이터를 새로고침합니다.
  Future<void> refreshMonthlyChecks(DateTime month) async {
    print('체크 데이터: ${month.year}년 ${month.month}월 데이터 새로고침');
    final checks = await _db.getDailyChecksByMonth(month);
    _monthlyChecks = checks;
    
    // 캐시 업데이트
    for (var check in checks) {
      final key = _getCacheKey(check.date);
      final dayChecks = checks.where((c) => 
        c.date.year == check.date.year && 
        c.date.month == check.date.month && 
        c.date.day == check.date.day
      ).toList();
      
      _dailyChecksCache[key] = dayChecks;
      _cacheTimestamps[key] = DateTime.now();
    }
    
    notifyListeners();
  }

  // 현재 월의 목표를 저장합니다.
  Future<void> addCurrentMonthGoal(String title, String emoji, int position) async {
    print('목표 저장: 현재 월 목표 저장 - $emoji $title');
    final goal = Goal(
      title: title,
      emoji: emoji,
      position: position,
      month: _currentMonth,
    );
    
    // 기존 목표가 있으면 업데이트, 없으면 새로 추가
    final existingGoal = _monthlyGoals.firstWhere(
      (g) => g.position == position,
      orElse: () => Goal(
        title: '',
        emoji: '',
        position: position,
        month: _currentMonth,
      ),
    );

    Goal updatedGoal;
    if (existingGoal.id != null) {
      updatedGoal = existingGoal.copyWith(
        title: title,
        emoji: emoji,
      );
      await _db.updateGoal(updatedGoal);
    } else {
      final id = await _db.insertGoal(goal);
      updatedGoal = goal.copyWith(id: id);
    }

    // 목표 리스트 업데이트
    final index = _monthlyGoals.indexWhere((g) => g.position == position);
    if (index >= 0) {
      _monthlyGoals[index] = updatedGoal;
    } else {
      _monthlyGoals.add(updatedGoal);
    }
    
    notifyListeners();
  }

  // 다음 달 목표를 저장합니다.
  Future<void> addGoal(String title, String emoji, int position) async {
    print('목표 저장: 다음 달 목표 저장 - $emoji $title');
    final nextMonth = DateTime(_currentMonth.year, _currentMonth.month + 1, 1);
    final goal = Goal(
      title: title,
      emoji: emoji,
      position: position,
      month: nextMonth,
    );
    
    // 기존 목표가 있으면 업데이트, 없으면 새로 추가
    final existingGoal = _nextMonthGoals.firstWhere(
      (g) => g.position == position,
      orElse: () => Goal(
        title: '',
        emoji: '',
        position: position,
        month: nextMonth,
      ),
    );

    Goal updatedGoal;
    if (existingGoal.id != null) {
      updatedGoal = existingGoal.copyWith(
        title: title,
        emoji: emoji,
      );
      await _db.updateGoal(updatedGoal);
    } else {
      final id = await _db.insertGoal(goal);
      updatedGoal = goal.copyWith(id: id);
    }

    // 목표 리스트 업데이트
    final index = _nextMonthGoals.indexWhere((g) => g.position == position);
    if (index >= 0) {
      _nextMonthGoals[index] = updatedGoal;
    } else {
      _nextMonthGoals.add(updatedGoal);
    }
    
    notifyListeners();
  }

  @override
  void dispose() {
    _dailyChecksCache.clear();
    _cacheTimestamps.clear();
    super.dispose();
  }

  // 앱 설정이 변경될 때 관련 데이터를 새로고침합니다.
  Future<void> updateSettings(AppSettings settings) async {
    // 캐시 초기화
    _dailyChecksCache.clear();
    _cacheTimestamps.clear();
    _loadingDates.clear();
    
    // 현재 날짜 업데이트 (테스트 날짜 적용)
    _currentMonth = settings.isTestMode && settings.testDate != null
        ? settings.testDate!
        : DateTime.now();
    _selectedMonth = _currentMonth;
    
    // 데이터 초기화
    _monthlyGoals = [];
    _nextMonthGoals = [];
    _calendarMonthGoals = [];
    _monthlyChecks = []; // 추가: 월별 체크 데이터 초기화
    
    // 상태 변경을 즉시 알림
    notifyListeners();
    
    // 모든 데이터 새로고침
    await loadMonthlyGoals();  // 현재 월 목표와 오늘의 체크 데이터 로드
    await loadNextMonthGoals();
    await loadCalendarMonthGoals(_selectedMonth);
  }

  // 모든 데이터 초기화
  void clearAllData() {
    _monthlyGoals = [];
    _nextMonthGoals = [];
    _calendarMonthGoals = [];
    _monthlyChecks = []; // 추가: 월별 체크 데이터 초기화
    _dailyChecksCache.clear();
    _cacheTimestamps.clear();
    _loadingDates.clear();
    notifyListeners();
  }
} 