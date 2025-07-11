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
import '../../providers/goal_provider.dart';
import '../../widgets/goal/goal_input_field.dart';

class GoalSettingScreen extends StatefulWidget {
  final bool isForCurrentMonth;

  const GoalSettingScreen({
    super.key,
    this.isForCurrentMonth = false,
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

  @override
  void dispose() {
    for (var controller in _controllers) {
      controller.dispose();
    }
    super.dispose();
  }

  Future<void> _saveGoals() async {
    final goalProvider = context.read<GoalProvider>();
    
    // 모든 필드가 채워져있는지 확인
    if (_controllers.any((controller) => controller.text.isEmpty)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('모든 목표를 입력해주세요')),
      );
      return;
    }

    // 목표 저장
    for (int i = 0; i < 4; i++) {
      if (widget.isForCurrentMonth) {
        // 현재 월의 목표 저장
        await goalProvider.addCurrentMonthGoal(
          _controllers[i].text,
          _emojis[i],
          i + 1,
        );
      } else {
        // 다음 달 목표 저장
        await goalProvider.addGoal(
          _controllers[i].text,
          _emojis[i],
          i + 1,
        );
      }
    }

    if (mounted) {
      Navigator.of(context).pop();
    }
  }

  String _getTitle() {
    return widget.isForCurrentMonth ? '이번 달 목표 설정' : '다음 달 목표 설정';
  }

  String _getDescription() {
    return widget.isForCurrentMonth
        ? '이번 달에 집중할 4가지 목표를 입력해주세요'
        : '다음 달에 집중할 4가지 목표를 입력해주세요';
  }

  @override
  Widget build(BuildContext context) {
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
                  emoji: _emojis[index],
                  onEmojiSelected: (emoji) {
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