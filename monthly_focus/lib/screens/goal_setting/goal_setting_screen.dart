/*
 * GoalSettingScreen: 목표 설정/수정 화면
 * 
 * 주요 기능:
 * - 새 목표 추가
 * - 기존 목표 수정
 * - 이모지 선택기
 * - 목표 순서 변경
 * - 목표 삭제
 * 
 * 화면 구성:
 * - AppBar: 저장/취소 버튼
 * - GoalForm: 목표 입력 폼
 * - EmojiPicker: 이모지 선택 다이얼로그
 * - DeleteConfirmDialog: 삭제 확인 다이얼로그
 */

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:math';
import '../../providers/goal_provider.dart';
import '../../widgets/goal/goal_input_field.dart';
import '../../utils/app_date_utils.dart';
import '../../models/goal.dart';

class GoalSettingScreen extends StatefulWidget {
  final bool isForCurrentMonth;
  final List<Goal> existingGoals;

  const GoalSettingScreen({
    super.key,
    this.isForCurrentMonth = false,
    this.existingGoals = const [],
  });

  @override
  State<GoalSettingScreen> createState() => _GoalSettingScreenState();
}

class _GoalSettingScreenState extends State<GoalSettingScreen> {
  final List<TextEditingController> _controllers = List.generate(
    4,
    (index) => TextEditingController(),
  );

  final List<String?> _emojis = List.filled(4, null);
  
  // 기본 이모지 리스트 확장
  final List<String> _allEmojis = [
    '🎯', '✨', '💪', '🌟', '📚', '🎨', '🎵', '🏃', 
    '🧘', '💡', '🌱', '🎮', '⚡️', '🔥', '🌈', '🎪',
    '🎭', '🎸', '🎹', '🎨', '📝', '🎤', '🏆', '🌺',
    '🦋', '🌙', '☀️', '⭐️', '🌊', '🍀', '🎪', '🎯'
  ];
  
  late final List<String> _randomEmojis;

  @override
  void initState() {
    super.initState();
    print('목표 설정 화면: 초기화 시작');
    // 초기화 시 랜덤 이모지 4개 선택
    final random = Random();
    _randomEmojis = List.generate(4, (index) {
      return _allEmojis[random.nextInt(_allEmojis.length)];
    });

    // 기존 목표가 있으면 설정
    for (int i = 0; i < widget.existingGoals.length && i < 4; i++) {
      final goal = widget.existingGoals[i];
      _controllers[i].text = goal.title;
      _emojis[i] = goal.emoji;
    }
    
    print('목표 설정 화면: 초기화 완료');
  }

  @override
  void dispose() {
    print('목표 설정 화면: 리소스 정리');
    for (var controller in _controllers) {
      controller.dispose();
    }
    super.dispose();
  }

  Future<void> _saveGoals() async {
    print('목표 설정 화면: 목표 저장 시작');
    final goalProvider = context.read<GoalProvider>();
    
    // 모든 필드가 채워져있는지 확인
    if (_controllers.any((controller) => controller.text.isEmpty)) {
      print('목표 설정 화면: 빈 목표가 있어 저장 실패');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('모든 목표를 입력해주세요')),
      );
      return;
    }

    final now = AppDateUtils.getCurrentDate(context);
    final targetMonth = widget.isForCurrentMonth
        ? now
        : DateTime(now.year, now.month + 1);

    print('목표 설정 화면: ${widget.isForCurrentMonth ? "이번 달" : "다음 달"} 목표 저장 시작');
    // 목표 저장
    for (int i = 0; i < 4; i++) {
      final emoji = _emojis[i] ?? _randomEmojis[i]; // null이면 랜덤 이모지 사용
      final title = _controllers[i].text;
      print('목표 설정 화면: ${i + 1}번 목표 저장 - $emoji $title');
      
      if (widget.isForCurrentMonth) {
        // 현재 월의 목표 저장
        await goalProvider.addCurrentMonthGoal(
          title,
          emoji,
          i + 1,
        );
      } else {
        // 다음 달 목표 저장
        await goalProvider.addGoal(
          title,
          emoji,
          i + 1,
        );
      }
    }

    print('목표 설정 화면: 모든 목표 저장 완료');
    if (mounted) {
      Navigator.of(context).pop();
    }
  }

  String _getTitle() {
    final now = AppDateUtils.getCurrentDate(context);
    if (widget.isForCurrentMonth) {
      return '${now.year}년 ${now.month}월의 목표';
    } else {
      final nextMonth = DateTime(now.year, now.month + 1);
      return '${nextMonth.year}년 ${nextMonth.month}월의 목표';
    }
  }

  String _getDescription() {
    final description = widget.isForCurrentMonth
        ? '이번 달에 집중할 4가지 목표를 입력해주세요'
        : '다음 달에 집중할 4가지 목표를 입력해주세요';
    print('목표 설정 화면: 설명 반환 - $description');
    return description;
  }

  @override
  Widget build(BuildContext context) {
    print('목표 설정 화면: 화면 빌드 시작');
    return Scaffold(
      appBar: AppBar(
        title: Text(_getTitle()),
        actions: [
          TextButton(
            onPressed: _saveGoals,
            child: const Text('저장'),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text(
              _getDescription(),
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 24),
            ...List.generate(4, (index) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 16.0),
                child: GoalInputField(
                  controller: _controllers[index],
                  position: index + 1,
                  emoji: _emojis[index] ?? _randomEmojis[index],
                  onEmojiSelected: (emoji) {
                    print('목표 설정 화면: ${index + 1}번 목표 이모지 선택 - $emoji');
                    setState(() {
                      _emojis[index] = emoji;
                    });
                  },
                ),
              );
            }),
            const Spacer(),
            const Text(
              '구체적이고 측정 가능한 목표를 설정해보세요\n예) 매일 30분 독서하기, 주 3회 운동하기',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13,
                color: Colors.grey,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
} 