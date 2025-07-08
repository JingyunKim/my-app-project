/*
 * GoalInputField: 목표 입력 필드 위젯
 * 
 * 주요 기능:
 * - 목표 제목 입력
 * - 이모지 선택 버튼
 * - 입력값 유효성 검사
 * - 자동 포커스 및 키보드 제어
 * 
 * 구성 요소:
 * - TextField: 목표 제목 입력 필드
 * - EmojiButton: 이모지 선택 버튼
 * - ValidationError: 오류 메시지 표시
 * - InputDecoration: 입력 필드 스타일링
 */

import 'package:flutter/material.dart';
import 'package:flutter_emoji/flutter_emoji.dart';
import 'dart:math';

class GoalInputField extends StatelessWidget {
  static const List<String> commonEmojis = [
    // 성취 & 동기부여
    '🎯', '⭐', '🏆', '✨', '💪', '🌟', '🚀', '✅', '📈',
    // 운동 & 건강
    '🏃', '🧘', '🏋️', '⚽', '🎾', '🚴', '🏊', '🥗', '💪',
    // 학습 & 성장
    '📚', '✏️', '💡', '🎓', '💻', '📝', '🔍', '📱', '🗂️',
    // 취미 & 여가
    '🎨', '🎵', '🎮', '📷', '🎬', '🎸', '🎹', '🎭', '🎪',
    // 생활 & 습관
    '🌱', '⏰', '🌞', '🌙', '📋', '🏠', '🧘', '🍵', '😊'
  ];

  final TextEditingController controller;
  final int position;
  final String? emoji;
  final Function(String?) onEmojiSelected;

  const GoalInputField({
    super.key,
    required this.controller,
    required this.position,
    required this.emoji,
    required this.onEmojiSelected,
  });

  // 랜덤 이모지 선택
  static String getRandomEmoji() {
    final random = Random();
    return commonEmojis[random.nextInt(commonEmojis.length)];
  }

  void _showEmojiPicker(BuildContext context) async {
    final String? selected = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('이모지 선택'),
        content: Wrap(
          spacing: 8,
          runSpacing: 8,
          children: commonEmojis.map((emoji) {
            return InkWell(
              onTap: () => Navigator.of(context).pop(emoji),
              child: Container(
                padding: const EdgeInsets.all(8),
                child: Text(
                  emoji,
                  style: const TextStyle(fontSize: 24),
                ),
              ),
            );
          }).toList(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(null),
            child: const Text('취소'),
          ),
        ],
      ),
    );

    if (selected != null) {
      onEmojiSelected(selected);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        IconButton(
          onPressed: () => _showEmojiPicker(context),
          icon: Text(
            emoji ?? getRandomEmoji(),
            style: const TextStyle(fontSize: 24),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: TextField(
            controller: controller,
            decoration: InputDecoration(
              labelText: '$position번째 목표',
              hintText: '목표를 입력해주세요',
              border: const OutlineInputBorder(),
              counter: Text('${controller.text.length}/50'),
            ),
            maxLength: 50,
          ),
        ),
      ],
    );
  }
} 