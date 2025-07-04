import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/goal_provider.dart';
import '../../widgets/goal/goal_input_field.dart';

class GoalSettingScreen extends StatefulWidget {
  const GoalSettingScreen({super.key});

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
      await goalProvider.addGoal(
        _controllers[i].text,
        _emojis[i],
        i + 1,
      );
    }

    if (mounted) {
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('다음 달 목표 설정'),
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
            const Text(
              '다음 달에 집중할 4가지 목표를 입력해주세요',
              style: TextStyle(fontSize: 16),
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
          ],
        ),
      ),
    );
  }
} 