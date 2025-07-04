import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/goal_provider.dart';
import '../../models/daily_check.dart';
import '../goal_setting/goal_setting_screen.dart';
import '../../widgets/goal/goal_check_card.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    _loadGoals();
  }

  Future<void> _loadGoals() async {
    final goalProvider = context.read<GoalProvider>();
    await goalProvider.loadMonthlyGoals();
    await goalProvider.loadTodayChecks();
  }

  void _showGoalSetting() {
    final goalProvider = context.read<GoalProvider>();
    if (!goalProvider.canSetNextMonthGoals()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('다음 달 목표는 이번 달 마지막 날에만 설정할 수 있습니다'),
        ),
      );
      return;
    }

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const GoalSettingScreen(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('오늘의 목표'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: _showGoalSetting,
          ),
        ],
      ),
      body: Consumer<GoalProvider>(
        builder: (context, provider, child) {
          if (provider.monthlyGoals.isEmpty) {
            return const Center(
              child: Text('이번 달 목표가 없습니다\n마지막 날에 다음 달 목표를 설정해주세요'),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: provider.monthlyGoals.length,
            itemBuilder: (context, index) {
              final goal = provider.monthlyGoals[index];
              final check = provider.todayChecks.firstWhere(
                (check) => check.goalId == goal.id,
                orElse: () => DailyCheck(
                  goalId: goal.id!,
                  date: DateTime.now(),
                  isCompleted: false,
                ),
              );

              return Padding(
                padding: const EdgeInsets.only(bottom: 16.0),
                child: GoalCheckCard(
                  goal: goal,
                  isChecked: check.isCompleted,
                  onToggle: () => provider.toggleGoalCheck(goal),
                ),
              );
            },
          );
        },
      ),
    );
  }
} 