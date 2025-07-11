/*
 * CalendarScreen: 월간 달력 화면
 * 
 * 주요 기능:
 * - 월간 달력 표시
 * - 일별 목표 체크 현황 표시
 * - 날짜별 상세 체크 목록
 * - 월 이동 네비게이션
 * 
 * 화면 구성:
 * - MonthCalendar: 달력 위젯
 * - DailyCheckList: 선택된 날짜의 체크 목록
 * - MonthNavigator: 월 이동 버튼
 * - CheckSummary: 월간 체크 통계
 */

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:table_calendar/table_calendar.dart';
import '../../providers/goal_provider.dart';
import '../../models/goal.dart';
import '../../models/daily_check.dart';
import '../../utils/app_date_utils.dart';

class CalendarScreen extends StatefulWidget {
  const CalendarScreen({super.key});

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  DateTime _focusedDay = AppDateUtils.getCurrentDate();
  DateTime? _selectedDay;
  late final ValueNotifier<List<DailyCheck>> _selectedChecks;
  List<Goal> _currentMonthGoals = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _selectedDay = AppDateUtils.getCurrentDate();
    _selectedChecks = ValueNotifier([]);
    _loadInitialData();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final currentDate = AppDateUtils.getCurrentDate(context);
    final provider = Provider.of<GoalProvider>(context);
    
    // 날짜가 변경되었거나 데이터가 초기화된 경우
    if (!AppDateUtils.isSameDay(_selectedDay, currentDate)) {
      setState(() {
        _selectedDay = currentDate;
        _focusedDay = currentDate;
        _selectedChecks.value = [];
      });
      _loadInitialData();
    }
  }

  Future<void> _loadInitialData() async {
    setState(() => _isLoading = true);
    try {
      await _loadMonthData();
      _loadSelectedDayChecks();
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _loadMonthData() async {
    final provider = context.read<GoalProvider>();
    await provider.loadCalendarMonthGoals(_focusedDay);
    setState(() {
      _currentMonthGoals = provider.calendarMonthGoals;
    });
  }

  @override
  void dispose() {
    _selectedChecks.dispose();
    super.dispose();
  }

  void _loadSelectedDayChecks() {
    if (_selectedDay == null) return;
    
    final goalProvider = context.read<GoalProvider>();
    
    // 오늘 날짜인 경우 todayChecks 사용
    if (AppDateUtils.isSameDay(_selectedDay, AppDateUtils.getCurrentDate(context))) {
      setState(() {
        _selectedChecks.value = goalProvider.todayChecks;
      });
      return;
    }
    
    goalProvider.loadDailyChecks(_selectedDay!).then((checks) {
      if (mounted) {
        setState(() {
          _selectedChecks.value = checks;
        });
      }
    });
  }

  List<DailyCheck> _getChecksForDay(GoalProvider provider, DateTime day) {
    final normalizedDay = DateTime(day.year, day.month, day.day);
    final normalizedToday = DateTime(
      AppDateUtils.getCurrentDate(context).year,
      AppDateUtils.getCurrentDate(context).month,
      AppDateUtils.getCurrentDate(context).day,
    );
    
    if (normalizedDay.isAtSameMomentAs(normalizedToday)) {
      return provider.todayChecks;
    }
    
    return provider.getCachedDailyChecks(day);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('월간 달성 현황'),
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: TextButton(
              onPressed: () {
                final today = AppDateUtils.getCurrentDate(context);
                setState(() {
                  _selectedDay = today;
                  _focusedDay = today;
                });
                _loadSelectedDayChecks();
              },
              child: const Text(
                'Today',
                style: TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
        ],
      ),
      body: Consumer<GoalProvider>(
        builder: (context, provider, child) {
          if (_isLoading) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          return Column(
            children: [
              TableCalendar<DailyCheck>(
                firstDay: DateTime.utc(2024, 1, 1),
                lastDay: DateTime.utc(2025, 12, 31),
                focusedDay: _focusedDay,
                currentDay: AppDateUtils.getCurrentDate(context),
                selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
                calendarFormat: CalendarFormat.month,
                availableCalendarFormats: const {
                  CalendarFormat.month: '월간',
                },
                eventLoader: (day) => _getChecksForDay(provider, day)
                    .where((check) => check.isCompleted)
                    .toList(),
                onDaySelected: (selectedDay, focusedDay) {
                  if (!isSameDay(_selectedDay, selectedDay)) {
                    setState(() {
                      _selectedDay = selectedDay;
                      _focusedDay = focusedDay;
                    });
                    _loadSelectedDayChecks();
                  }
                },
                onPageChanged: (focusedDay) async {
                  setState(() => _focusedDay = focusedDay);
                  await _loadMonthData();
                },
                calendarStyle: const CalendarStyle(
                  markersMaxCount: 4,
                  markerDecoration: BoxDecoration(
                    color: Colors.blue,
                    shape: BoxShape.circle,
                  ),
                  todayDecoration: BoxDecoration(
                    color: Colors.blue,
                    shape: BoxShape.circle,
                  ),
                  selectedDecoration: BoxDecoration(
                    color: Colors.deepPurple,
                    shape: BoxShape.circle,
                  ),
                  todayTextStyle: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                  selectedTextStyle: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const Divider(),
              Expanded(
                child: Consumer<GoalProvider>(
                  builder: (context, provider, _) {
                    final checks = _getChecksForDay(provider, _selectedDay ?? AppDateUtils.getCurrentDate(context));
                    
                    if (_currentMonthGoals.isEmpty) {
                      return const Center(
                        child: Text('선택한 월의 목표가 없습니다'),
                      );
                    }
                    
                    return ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: _currentMonthGoals.length,
                      itemBuilder: (context, index) {
                        final goal = _currentMonthGoals[index];
                        final check = checks.firstWhere(
                          (check) => check.goalId == goal.id,
                          orElse: () => DailyCheck(
                            goalId: goal.id!,
                            date: _selectedDay ?? AppDateUtils.getCurrentDate(context),
                            isCompleted: false,
                          ),
                        );

                        return ListTile(
                          leading: Text(goal.emoji ?? '🎯'),
                          title: Text(
                            goal.title,
                            style: TextStyle(
                              decoration: check.isCompleted
                                  ? TextDecoration.lineThrough
                                  : null,
                              color:
                                  check.isCompleted ? Colors.grey : Colors.black,
                            ),
                          ),
                          trailing: Icon(
                            check.isCompleted
                                ? Icons.check_circle
                                : Icons.check_circle_outline,
                            color: check.isCompleted ? Colors.green : Colors.grey,
                          ),
                          enabled: false,  // 클릭 비활성화
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }
} 