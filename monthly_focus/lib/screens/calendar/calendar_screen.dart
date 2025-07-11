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
    
    if (!AppDateUtils.isSameDay(_selectedDay, currentDate)) {
      setState(() {
        _selectedDay = currentDate;
        _focusedDay = currentDate;
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
    final checks = goalProvider.getCachedDailyChecks(_selectedDay!);
    
    setState(() {
      _selectedChecks.value = checks;
    });
    
    // 캐시된 데이터가 없거나 오늘 날짜인 경우 새로 로드
    if (checks.isEmpty || AppDateUtils.isSameDay(_selectedDay, AppDateUtils.getCurrentDate(context))) {
      goalProvider.loadDailyChecks(_selectedDay!).then((updatedChecks) {
        if (mounted) {
          setState(() {
            _selectedChecks.value = updatedChecks;
          });
        }
      });
    }
  }

  List<DailyCheck> _getChecksForDay(GoalProvider provider, DateTime day) {
    final normalizedDay = DateTime(day.year, day.month, day.day);
    final checks = provider.getCachedDailyChecks(normalizedDay);
    
    // 데이터가 없으면 로드 요청
    if (checks.isEmpty) {
      provider.loadDailyChecks(normalizedDay).then((_) {
        if (mounted) {
          setState(() {});  // 데이터가 로드되면 화면 갱신
        }
      });
    }
    
    return checks;
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
                startingDayOfWeek: StartingDayOfWeek.monday,
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
                      _focusedDay = selectedDay;
                    });
                    _loadSelectedDayChecks();
                  }
                },
                onPageChanged: (focusedDay) async {
                  setState(() {
                    _focusedDay = focusedDay;
                  });
                  await _loadMonthData();
                },
                calendarStyle: const CalendarStyle(
                  markersMaxCount: 4,
                  markerDecoration: BoxDecoration(
                    color: Colors.blue,
                    shape: BoxShape.circle,
                  ),
                  todayDecoration: BoxDecoration(
                    color: Color.fromARGB(255, 137, 188, 231),
                    shape: BoxShape.circle,
                  ),
                  selectedDecoration: BoxDecoration(
                    color: Color.fromARGB(255, 100, 70, 152),
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
                  outsideDaysVisible: false,  // 현재 월에 속하지 않는 날짜 숨김
                ),
                headerStyle: const HeaderStyle(
                  formatButtonVisible: false,  // 포맷 변경 버튼 숨김
                  titleCentered: true,  // 제목 중앙 정렬
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