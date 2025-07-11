import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/goal_provider.dart';
import '../../models/daily_check.dart';
import '../../services/storage_service.dart';
import '../goal_setting/goal_setting_screen.dart';
import '../../widgets/goal/goal_check_card.dart';
import '../../utils/app_date_utils.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _storage = StorageService();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    print('오늘 화면: 초기화 시작');
    _loadInitialData();
    print('오늘 화면: 초기화 완료');
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    print('오늘 화면: 의존성 변경 감지');
    final currentDate = AppDateUtils.getCurrentDate(context);
    final provider = Provider.of<GoalProvider>(context);
    
    // 날짜가 변경되었거나 데이터가 초기화된 경우에만 로드
    if (provider.monthlyGoals.isEmpty || !AppDateUtils.isSameMonth(currentDate, provider.currentMonth)) {
      print('오늘 화면: 날짜 변경 또는 데이터 초기화로 인한 데이터 리로드');
      _loadInitialData();
    }
  }

  // 초기 데이터를 로드하고 웰컴 가이드를 표시합니다.
  Future<void> _loadInitialData() async {
    print('오늘 화면: 초기 데이터 로드 시작');
    if (_isLoading) {
      print('오늘 화면: 이미 로딩 중이므로 중복 로드 방지');
      return;
    }
    
    setState(() => _isLoading = true);
    try {
      await _loadGoals();
      await _showWelcomeGuideIfNeeded();
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
      print('오늘 화면: 초기 데이터 로드 완료');
    }
  }

  // 앱 최초 실행 시 웰컴 가이드를 표시합니다.
  Future<void> _showWelcomeGuideIfNeeded() async {
    print('오늘 화면: 웰컴 가이드 표시 여부 확인');
    if (!_storage.isWelcomeGuideShown()) {
      print('오늘 화면: 웰컴 가이드 다이얼로그 표시');
      await showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => _buildWelcomeDialog(),
      );
    }
  }

  // 웰컴 가이드 다이얼로그를 생성합니다.
  Widget _buildWelcomeDialog() {
    print('오늘 화면: 웰컴 가이드 다이얼로그 생성');
    return AlertDialog(
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
          const Text('• 달력탭에서 월간 달성 현황을 확인할 수 있어요'),
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
            print('오늘 화면: 웰컴 가이드 확인 및 목표 설정 화면으로 이동');
            _storage.markWelcomeGuideAsShown();
            Navigator.of(context).pop();
            _showGoalSetting(isForCurrentMonth: true);
          },
          child: const Text('이번달 목표 설정하기'),
        ),
      ],
    );
  }

  // 현재 월과 다음 달 목표를 로드합니다.
  Future<void> _loadGoals() async {
    print('오늘 화면: 목표 데이터 로드 시작');
    final goalProvider = context.read<GoalProvider>();
    await goalProvider.loadMonthlyGoals();
    await goalProvider.loadNextMonthGoals();
    await goalProvider.refreshMonthlyChecks(AppDateUtils.getCurrentDate(context));
    print('오늘 화면: 목표 데이터 로드 완료');
  }

  // 목표 설정 화면을 표시합니다.
  void _showGoalSetting({bool isForCurrentMonth = false}) {
    print('오늘 화면: 목표 설정 화면 표시 시도 - ${isForCurrentMonth ? "이번 달" : "다음 달"}');
    final goalProvider = context.read<GoalProvider>();
    final String errorMessage;
    
    if (isForCurrentMonth) {
      if (!goalProvider.canSetCurrentMonthGoals()) {
        errorMessage = '이번 달 목표는 1일부터 24일까지만 설정할 수 있습니다';
        print('오늘 화면: 이번 달 목표 설정 불가 - $errorMessage');
      } else {
        errorMessage = '';
      }
    } else {
      if (!goalProvider.canSetNextMonthGoals()) {
        errorMessage = '다음 달 목표는 이번 달 25일부터 설정할 수 있습니다';
        print('오늘 화면: 다음 달 목표 설정 불가 - $errorMessage');
      } else {
        errorMessage = '';
      }
    }

    if (errorMessage.isNotEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(errorMessage)),
      );
      return;
    }

    print('오늘 화면: 목표 설정 화면으로 이동');
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => GoalSettingScreen(isForCurrentMonth: isForCurrentMonth),
      ),
    ).then((_) {
      print('오늘 화면: 목표 설정 화면에서 복귀 - 데이터 리로드');
      _loadGoals();
    });
  }

  @override
  Widget build(BuildContext context) {
    print('오늘 화면: 화면 빌드 시작');
    return Scaffold(
      appBar: AppBar(
        title: const Text('오늘의 목표'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Consumer<GoalProvider>(
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

  // 현재 월의 목표 목록을 표시합니다.
  Widget _buildCurrentMonthGoals(GoalProvider provider) {
    print('오늘 화면: 이번 달 목표 목록 빌드');
    if (provider.monthlyGoals.isEmpty) {
      print('오늘 화면: 이번 달 목표 없음');
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('이번 달 목표가 없습니다'),
            const SizedBox(height: 16),
            if (provider.canSetCurrentMonthGoals())
              ElevatedButton.icon(
                onPressed: () => _showGoalSetting(isForCurrentMonth: true),
                icon: const Icon(Icons.add),
                label: const Text('이번 달 목표 설정하기'),
              ),
          ],
        ),
      );
    }

    print('오늘 화면: 이번 달 목표 ${provider.monthlyGoals.length}개 표시');
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: provider.monthlyGoals.length,
      itemBuilder: (context, index) {
        final goal = provider.monthlyGoals[index];
        final check = provider.todayChecks.firstWhere(
          (check) => check.goalId == goal.id,
          orElse: () => DailyCheck(
            goalId: goal.id!,
            date: AppDateUtils.getCurrentDate(),
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

  // 다음 달 목표 섹션을 표시합니다.
  Widget _buildNextMonthSection(GoalProvider provider) {
    print('오늘 화면: 다음 달 목표 섹션 빌드');
    if (!provider.canSetNextMonthGoals()) {
      print('오늘 화면: 다음 달 목표 설정 기간이 아님');
      return const SizedBox.shrink();
    }

    final now = AppDateUtils.getCurrentDate();
    final nextMonth = DateTime(now.year, now.month + 1);
    print('오늘 화면: 다음 달(${nextMonth.year}년 ${nextMonth.month}월) 목표 섹션 표시');
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Theme.of(context).colorScheme.surfaceTint.withOpacity(0.1),
            Theme.of(context).colorScheme.surface,
          ],
        ),
      ),
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
          if (provider.nextMonthGoals.isEmpty) ...[
            Row(
              children: [
                const Expanded(
                  child: Text('다음 달 목표를 미리 설정해보세요'),
                ),
                TextButton.icon(
                  onPressed: () => _showGoalSetting(isForCurrentMonth: false),
                  icon: const Icon(Icons.add),
                  label: const Text('설정하기'),
                ),
              ],
            ),
          ] else
            const SizedBox.shrink(),
        ],
      ),
    );
  }
} 