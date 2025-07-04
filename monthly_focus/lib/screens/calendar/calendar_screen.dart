import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:table_calendar/table_calendar.dart';
import '../../providers/goal_provider.dart';
import '../../models/goal.dart';
import '../../models/daily_check.dart';

class CalendarScreen extends StatefulWidget {
  const CalendarScreen({super.key});

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  late final ValueNotifier<List<DailyCheck>> _selectedChecks;
  List<Goal> _currentMonthGoals = [];  // 현재 보고 있는 달의 목표

  @override
  void initState() {
    super.initState();
    _selectedDay = _focusedDay;
    _selectedChecks = ValueNotifier([]);
    _loadMonthData();
  }

  // 선택된 월의 데이터 로드
  Future<void> _loadMonthData() async {
    final provider = context.read<GoalProvider>();
    
    // 2025년 7월 샘플 데이터 체크
    if (_focusedDay.year == 2025 && _focusedDay.month == 7) {
      await provider.loadJuly2025Goals();
    }
    
    // 해당 월의 목표 로드
    final goals = await provider.getGoalsByMonth(_focusedDay);
    setState(() {
      _currentMonthGoals = goals;
    });

    // 해당 월의 체크 데이터 미리 로드
    final firstDay = DateTime(_focusedDay.year, _focusedDay.month, 1);
    final lastDay = DateTime(_focusedDay.year, _focusedDay.month + 1, 0);

    for (var day = firstDay; 
         day.isBefore(lastDay.add(const Duration(days: 1))); 
         day = day.add(const Duration(days: 1))) {
      await provider.loadDailyChecks(day);
    }
    
    if (mounted) {
      setState(() {});
    }
  }

  @override
  void dispose() {
    _selectedChecks.dispose();
    super.dispose();
  }

  void _loadSelectedDayChecks() {
    if (_selectedDay == null) return;
    
    final goalProvider = context.read<GoalProvider>();
    goalProvider.loadDailyChecks(_selectedDay!).then((checks) {
      _selectedChecks.value = checks;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('월간 달성 현황'),
      ),
      body: Consumer<GoalProvider>(
        builder: (context, provider, child) {
          return Column(
            children: [
              _buildMonthlyGoals(),
              TableCalendar<DailyCheck>(
                firstDay: DateTime.utc(2024, 1, 1),
                lastDay: DateTime.utc(2025, 12, 31),
                focusedDay: _focusedDay,
                selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
                calendarFormat: CalendarFormat.month,
                availableCalendarFormats: const {
                  CalendarFormat.month: '월간',
                },
                eventLoader: (day) => provider.getCachedDailyChecks(day),
                onDaySelected: (selectedDay, focusedDay) {
                  setState(() {
                    _selectedDay = selectedDay;
                    _focusedDay = focusedDay;
                  });
                  _loadSelectedDayChecks();
                },
                onPageChanged: (focusedDay) {
                  setState(() {
                    _focusedDay = focusedDay;
                  });
                  _loadMonthData();
                },
                calendarStyle: const CalendarStyle(
                  markersMaxCount: 4,
                  markerDecoration: BoxDecoration(
                    color: Colors.blue,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
              const Divider(),
              Expanded(
                child: ValueListenableBuilder<List<DailyCheck>>(
                  valueListenable: _selectedChecks,
                  builder: (context, checks, _) {
                    if (checks.isEmpty) {
                      return const Center(
                        child: Text('선택한 날짜의 체크 기록이 없습니다'),
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
                            date: _selectedDay!,
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

  Widget _buildMonthlyGoals() {
    return Container(
      padding: const EdgeInsets.all(16),
      color: Theme.of(context).colorScheme.primaryContainer,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '${_focusedDay.year}년 ${_focusedDay.month}월의 목표',
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          if (_currentMonthGoals.isEmpty)
            const Text(
              '설정된 목표가 없습니다',
              style: TextStyle(
                color: Colors.grey,
                fontSize: 14,
              ),
            )
          else
            Wrap(
              spacing: 8,
              children: _currentMonthGoals.map((goal) {
                return Chip(
                  avatar: Text(goal.emoji ?? '🎯'),
                  label: Text(goal.title),
                );
              }).toList(),
            ),
        ],
      ),
    );
  }
} 