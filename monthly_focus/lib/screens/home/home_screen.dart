import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/goal_provider.dart';
import '../../models/daily_check.dart';
import '../../services/storage_service.dart';
import '../goal_setting/goal_setting_screen.dart';
import '../../widgets/goal/goal_check_card.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _storage = StorageService();

  @override
  void initState() {
    super.initState();
    _loadGoals();
    _showWelcomeGuideIfNeeded();
  }

  Future<void> _showWelcomeGuideIfNeeded() async {
    if (!_storage.isWelcomeGuideShown()) {
      // 화면이 완전히 빌드된 후 팝업 표시
      WidgetsBinding.instance.addPostFrameCallback((_) {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => AlertDialog(
            title: const Text('한 달의 집중에 오신 것을 환영합니다! 🎉'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '매월 4가지 목표를 설정하고 달성해보세요.',
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
                const SizedBox(height: 16),
                const Text('• 매월 25일부터 다음 달 목표를 설정할 수 있어요'),
                const Text('• 매일 목표 달성 여부를 체크해보세요'),
                const Text('• 달력에서 월간 달성 현황을 확인할 수 있어요'),
                const SizedBox(height: 16),
                Text(
                  '지금 바로 이번 달의 목표를 설정해보세요!',
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () {
                  _storage.markWelcomeGuideAsShown();
                  Navigator.of(context).pop();
                  _showGoalSetting();
                },
                child: const Text('목표 설정하기'),
              ),
            ],
          ),
        );
      });
    }
  }

  Future<void> _loadGoals() async {
    final goalProvider = context.read<GoalProvider>();
    await goalProvider.loadMonthlyGoals();
    await goalProvider.loadNextMonthGoals();
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
      ),
      body: Consumer<GoalProvider>(
        builder: (context, provider, child) {
          return Column(
            children: [
              Expanded(
                child: _buildCurrentMonthGoals(provider),
              ),
              const Divider(height: 1),
              _buildNextMonthSection(provider),
            ],
          );
        },
      ),
    );
  }

  Widget _buildCurrentMonthGoals(GoalProvider provider) {
    if (provider.monthlyGoals.isEmpty) {
      return const Center(
        child: Text('이번 달 목표가 없습니다'),
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
  }

  Widget _buildNextMonthSection(GoalProvider provider) {
    final now = DateTime.now();
    final nextMonth = DateTime(now.year, now.month + 1);
    
    return Container(
      padding: const EdgeInsets.all(16),
      color: Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.3),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            '${nextMonth.year}년 ${nextMonth.month}월의 목표',
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          if (provider.nextMonthGoals.isEmpty)
            Row(
              children: [
                const Expanded(
                  child: Text(
                    '다음 달 목표를 설정해주세요',
                    style: TextStyle(
                      color: Colors.grey,
                      fontSize: 14,
                    ),
                  ),
                ),
                TextButton.icon(
                  onPressed: _showGoalSetting,
                  icon: const Icon(Icons.add),
                  label: const Text('목표 설정'),
                ),
              ],
            )
          else
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: provider.nextMonthGoals.map((goal) {
                return Chip(
                  avatar: Text(goal.emoji ?? '🎯'),
                  label: Text(goal.title),
                  backgroundColor: Theme.of(context).colorScheme.primaryContainer,
                );
              }).toList(),
            ),
        ],
      ),
    );
  }
} 