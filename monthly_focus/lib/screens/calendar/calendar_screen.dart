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

  @override
  void initState() {
    super.initState();
    _selectedDay = _focusedDay;
    _selectedChecks = ValueNotifier([]);
    _loadSelectedDayChecks();
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
          final goals = provider.monthlyGoals;

          return Column(
            children: [
              _buildMonthlyGoals(goals),
              TableCalendar<DailyCheck>(
                firstDay: DateTime.utc(2024, 1, 1),
                lastDay: DateTime.utc(2025, 12, 31),
                focusedDay: _focusedDay,
                selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
                calendarFormat: CalendarFormat.month,
                eventLoader: (day) => provider.getCachedDailyChecks(day),
                onDaySelected: (selectedDay, focusedDay) {
                  setState(() {
                    _selectedDay = selectedDay;
                    _focusedDay = focusedDay;
                  });
                  _loadSelectedDayChecks();
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
                      itemCount: goals.length,
                      itemBuilder: (context, index) {
                        final goal = goals[index];
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

  Widget _buildMonthlyGoals(List<Goal> goals) {
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
          Wrap(
            spacing: 8,
            children: goals.map((goal) {
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