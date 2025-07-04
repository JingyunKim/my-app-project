import 'package:flutter/material.dart';
import 'package:flutter_emoji/flutter_emoji.dart';

class GoalInputField extends StatelessWidget {
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

  void _showEmojiPicker(BuildContext context) async {
    final parser = EmojiParser();
    final List<String> commonEmojis = [
      '✨', '🎯', '💪', '📚', '🏃', '🎨', '💡', '🌱',
      '🎵', '✍️', '🧘', '🏋️', '🎮', '👨‍💻', '🎬', '📝'
    ];

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
            emoji ?? '😊',
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