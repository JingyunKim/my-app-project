import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/goal_provider.dart';
import '../../models/daily_check.dart';
import '../../services/storage_service.dart';
import '../goal_setting/goal_setting_screen.dart';
import '../../widgets/goal/goal_check_card.dart';
import '../../utils/app_date_utils.dart';
import '../../models/monthly_quote.dart';
import 'package:intl/intl.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _storage = StorageService();
  bool _isLoading = false;
  DateTime? _lastLoadedDate;
  bool _isInitialized = false;

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
    
    if (!_isInitialized) {
      print('오늘 화면: 아직 초기화되지 않음');
      return;
    }

    final currentDate = AppDateUtils.getCurrentDate(context);
    final provider = Provider.of<GoalProvider>(context);
    
    // 날짜가 실제로 변경되었거나 데이터가 없는 경우에만 로드
    if (_lastLoadedDate == null || 
        !AppDateUtils.isSameDay(_lastLoadedDate!, currentDate) ||
        provider.monthlyGoals.isEmpty) {
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
      await _syncWidgetData();
      _lastLoadedDate = AppDateUtils.getCurrentDate(context);
      _isInitialized = true;
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
        barrierDismissible: true,
        builder: (context) => _buildWelcomeDialog(),
      );
    }
  }

  // 웰컴 가이드 다이얼로그를 생성합니다.
  Widget _buildWelcomeDialog() {
    print('오늘 화면: 웰컴 가이드 다이얼로그 생성');
    return AlertDialog(
      title: const Text(
        '한 달의 집중에 오신 것을 환영합니다! 🎉',
        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '매월 4가지 목표를 설정하고 달성해보세요.',
            style: TextStyle(fontSize: 14),
          ),
          const SizedBox(height: 12),
          const Text(
            '• 매월 25일부터 다음 달 목표를 설정할 수 있어요',
            style: TextStyle(fontSize: 13),
          ),
          const Text(
            '• 매일 목표 달성 여부를 체크해보세요',
            style: TextStyle(fontSize: 13),
          ),
          const Text(
            '• 달력탭에서 월간 달성 현황을 확인할 수 있어요',
            style: TextStyle(fontSize: 13),
          ),
          const SizedBox(height: 12),
          Text(
            '지금 바로 이번 달의 목표를 설정해보세요!',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () {
            print('오늘 화면: 웰컴 가이드 확인');
            _storage.markWelcomeGuideAsShown();
            Navigator.of(context).pop();
          },
          child: const Text(
            '확인',
            style: TextStyle(fontSize: 14),
          ),
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

  // 위젯 데이터를 동기화합니다.
  Future<void> _syncWidgetData() async {
    print('오늘 화면: 위젯 데이터 동기화 시작');
    final goalProvider = context.read<GoalProvider>();
    await goalProvider.syncWidgetData();
    print('오늘 화면: 위젯 데이터 동기화 완료');
  }

  // 목표 설정 화면을 표시합니다.
  void _showGoalSetting({bool isForCurrentMonth = false}) {
    print('오늘 화면: 목표 설정 화면 표시 시도 - ${isForCurrentMonth ? "이번 달" : "다음 달"}');
    final goalProvider = context.read<GoalProvider>();
    final existingGoals = isForCurrentMonth ? goalProvider.monthlyGoals : goalProvider.nextMonthGoals;
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
        builder: (context) => GoalSettingScreen(
          isForCurrentMonth: isForCurrentMonth,
          existingGoals: existingGoals,
        ),
      ),
    ).then((_) {
      print('오늘 화면: 목표 설정 화면에서 복귀 - 데이터 리로드');
      _loadGoals();
      _syncWidgetData();
    });
  }

  // 현재 날짜의 월일을 반환합니다.
  String _getCurrentMonthDay() {
    final now = AppDateUtils.getCurrentDate(context);
    final dateFormat = DateFormat('M월 d일');
    return dateFormat.format(now);
  }

  // Today 스타일의 날짜 위젯을 빌드합니다.
  Widget _buildTodayDate() {
    final now = AppDateUtils.getCurrentDate(context);
    final dateFormat = DateFormat('M월 d일');
    
    return Text(
      dateFormat.format(now),
      style: TextStyle(
        color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
        fontWeight: FontWeight.w500,
        fontSize: 15,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    print('오늘 화면: 화면 빌드 시작');
    return Scaffold(
      appBar: AppBar(
        title: const Text('오늘의 목표'),
        centerTitle: true,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: _buildTodayDate(),
          ),
        ],
        backgroundColor: Theme.of(context).colorScheme.surface,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Consumer<GoalProvider>(
              builder: (context, provider, child) {
                return Column(
                  children: [
                    // AppBar와 목표 섹션 사이 구분선
                    const Divider(
                      height: 1,
                      thickness: 1.0,
                    ),
                    Expanded(
                      child: _buildCurrentMonthGoals(provider),
                    ),
                    _buildMonthlyQuote(),
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

    final now = AppDateUtils.getCurrentDate(context);
    final nextMonth = DateTime(now.year, now.month + 1);
    print('오늘 화면: 다음 달(${nextMonth.year}년 ${nextMonth.month}월) 목표 섹션 표시');
    
    final theme = Theme.of(context);
    final primaryColor = theme.colorScheme.primary;
    
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            primaryColor.withOpacity(0.15),
            primaryColor.withOpacity(0.05),
            primaryColor.withOpacity(0.15),
          ],
        ),
        border: Border(
          top: BorderSide(
            color: primaryColor.withOpacity(0.2),
            width: 1,
          ),
          bottom: BorderSide(
            color: primaryColor.withOpacity(0.2),
            width: 1,
          ),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Row(
          children: [
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.calendar_month,
                  size: 20,
                  color: primaryColor,
                ),
                const SizedBox(width: 8),
                Text(
                  '${nextMonth.month}월의 목표',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
              ],
            ),
            const Spacer(),
            if (provider.nextMonthGoals.isEmpty)
              TextButton.icon(
                onPressed: () => _showGoalSetting(isForCurrentMonth: false),
                icon: const Icon(Icons.add, size: 20),
                label: const Text(
                  '설정하기',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                style: TextButton.styleFrom(
                  backgroundColor: primaryColor.withOpacity(0.1),
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              )
            else
              TextButton.icon(
                onPressed: () => _showGoalSetting(isForCurrentMonth: false),
                icon: const Icon(Icons.edit_note, size: 20),
                label: const Text(
                  '조회 및 수정하기',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                style: TextButton.styleFrom(
                  backgroundColor: primaryColor.withOpacity(0.1),
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  minimumSize: const Size(140, 0), // 버튼의 최소 너비 설정
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildMonthlyQuote() {
    final now = AppDateUtils.getCurrentDate(context);
    final quote = MonthlyQuotes.getQuoteForMonth(now);

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (quote.source != null) ...[
            Text(
              quote.quote,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(width: 4),
            Text(
              '- ${quote.source}',
              style: TextStyle(
                fontSize: 12,
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                fontStyle: FontStyle.italic,
              ),
            ),
          ] else
            Text(
              quote.quote,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
            ),
        ],
      ),
    );
  }
} 