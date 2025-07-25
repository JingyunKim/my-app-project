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
    print('달력 화면: 초기화 시작');
    _selectedDay = AppDateUtils.getCurrentDate();
    _selectedChecks = ValueNotifier([]);
    _loadInitialData();
    print('달력 화면: 초기화 완료');
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    print('달력 화면: 의존성 변경 감지');
    final currentDate = AppDateUtils.getCurrentDate(context);
    
    if (!AppDateUtils.isSameDay(_selectedDay, currentDate)) {
      print('달력 화면: 날짜 변경으로 인한 데이터 리로드');
      setState(() {
        _selectedDay = currentDate;
        _focusedDay = currentDate;
      });
      _loadInitialData();
    }
  }

  @override
  void dispose() {
    print('달력 화면: 종료');
    _selectedChecks.dispose();
    super.dispose();
  }

  Future<void> _loadInitialData() async {
    print('달력 화면: 초기 데이터 로드 시작');
    setState(() => _isLoading = true);
    try {
      await _loadMonthData();
      _loadSelectedDayChecks();
    } finally {
      setState(() => _isLoading = false);
      print('달력 화면: 초기 데이터 로드 완료');
    }
  }

  Future<void> _loadMonthData() async {
    print('달력 화면: ${_focusedDay.year}년 ${_focusedDay.month}월 데이터 로드 시작');
    final provider = context.read<GoalProvider>();
    await provider.loadCalendarMonthGoals(_focusedDay);
    setState(() {
      _currentMonthGoals = provider.calendarMonthGoals;
    });
    
    // 선택된 날짜의 체크 데이터도 함께 로드
    if (_selectedDay != null) {
      _loadSelectedDayChecks();
    }
    
    print('달력 화면: ${_focusedDay.year}년 ${_focusedDay.month}월 데이터 로드 완료 - 목표 ${_currentMonthGoals.length}개');
  }

  List<DailyCheck> _getChecksForDay(GoalProvider provider, DateTime day) {
    final checks = provider.getDailyChecksByDate(day);
    return checks;
  }

  void _loadSelectedDayChecks() {
    if (_selectedDay == null) return;
    
    print('달력 화면: 선택된 날짜(${_selectedDay!.year}년 ${_selectedDay!.month}월 ${_selectedDay!.day}일) 체크 데이터 로드');
    final goalProvider = context.read<GoalProvider>();
    final checks = goalProvider.getDailyChecksByDate(_selectedDay!);
    
    _selectedChecks.value = checks;
    
    // 체크 데이터가 비어있으면 자동으로 생성
    if (checks.isEmpty && _currentMonthGoals.isNotEmpty) {
      _selectedChecks.value = _currentMonthGoals.map((goal) => DailyCheck(
        goalId: goal.id!,
        date: _selectedDay!,
        isCompleted: false,
      )).toList();
    }
  }

  @override
  Widget build(BuildContext context) {
    print('달력 화면: 화면 빌드 시작');
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        title: const Text('월간 달성 현황'),
        backgroundColor: Theme.of(context).colorScheme.surface,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: TextButton(
              onPressed: () {
                print('달력 화면: 오늘 날짜로 이동');
                final today = AppDateUtils.getCurrentDate(context);
                setState(() {
                  _selectedDay = today;
                  _focusedDay = today;
                });
                _loadMonthData(); // 오늘 날짜로 이동할 때도 데이터 새로고침
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
              // AppBar와 달력 사이 구분선
              const Divider(
                height: 1,
                thickness: 1.0,
              ),
              TableCalendar<DailyCheck>(
                firstDay: DateTime.utc(2024, 1, 1),
                lastDay: DateTime.utc(2025, 12, 31),
                focusedDay: _focusedDay,
                currentDay: AppDateUtils.getCurrentDate(context),
                selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
                calendarFormat: CalendarFormat.month,
                startingDayOfWeek: StartingDayOfWeek.sunday,  // 일요일부터 시작
                availableCalendarFormats: const {
                  CalendarFormat.month: '월간',
                },
                eventLoader: (day) => _getChecksForDay(provider, day)
                    .where((check) => check.isCompleted)
                    .toList(),
                onDaySelected: (selectedDay, focusedDay) {
                  if (!isSameDay(_selectedDay, selectedDay)) {
                    print('달력 화면: 날짜 선택 - ${selectedDay.year}년 ${selectedDay.month}월 ${selectedDay.day}일');
                    setState(() {
                      _selectedDay = selectedDay;
                      _focusedDay = selectedDay;
                    });
                    _loadSelectedDayChecks();
                  }
                },
                onPageChanged: (focusedDay) async {
                  print('달력 화면: 월 변경 - ${focusedDay.year}년 ${focusedDay.month}월');
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
                    color: Color.fromARGB(255, 42, 115, 174),
                    shape: BoxShape.circle,
                  ),
                  selectedDecoration: BoxDecoration(
                    color: Color.fromARGB(255, 152, 165, 194),
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
                  weekendTextStyle: TextStyle(
                    color: Color(0xFFFF6B6B),  // 주말 텍스트 색상 (일요일)
                  ),
                  outsideDaysVisible: false,  // 현재 월에 속하지 않는 날짜 숨김
                ),
                headerStyle: const HeaderStyle(
                  formatButtonVisible: false,  // 포맷 변경 버튼 숨김
                  titleCentered: true,  // 제목 중앙 정렬
                ),
                calendarBuilders: CalendarBuilders(
                  defaultBuilder: (context, day, focusedDay) {
                    if (day.weekday == DateTime.saturday) {
                      return Center(
                        child: Text(
                          '${day.day}',
                          style: const TextStyle(
                            color: Color(0xFF5C7CFA),  // 토요일 텍스트 색상 (파스텔 블루)
                          ),
                        ),
                      );
                    }
                    return null;  // 기본 스타일 사용
                  },
                ),
              ),
              const Divider(),
              Expanded(
                child: Consumer<GoalProvider>(
                  builder: (context, provider, _) {
                    final checks = _getChecksForDay(provider, _selectedDay ?? AppDateUtils.getCurrentDate(context));
                    
                    if (_currentMonthGoals.isEmpty) {
                      print('달력 화면: 선택된 월의 목표 없음');
                      return const Center(
                        child: Text('선택한 월의 목표가 없습니다'),
                      );
                    }
                    
                    print('달력 화면: 목표 목록 표시 - ${_currentMonthGoals.length}개');
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