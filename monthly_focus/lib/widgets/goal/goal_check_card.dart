/*
 * GoalCheckCard: 목표별 일일 체크 카드 위젯
 * 
 * 주요 기능:
 * - 목표 정보 표시 (제목, 이모지)
 * - 일일 체크 상태 표시
 * - 체크 상태 토글 기능
 * - 체크 히스토리 표시
 * 
 * 구성 요소:
 * - 목표 타이틀 섹션
 * - 체크 버튼
 * - 체크 히스토리 그리드
 * - 애니메이션 효과
 */

import 'package:flutter/material.dart';
import '../../models/goal.dart';

class GoalCheckCard extends StatelessWidget {
  final Goal goal;
  final bool isChecked;
  final VoidCallback onToggle;

  const GoalCheckCard({
    super.key,
    required this.goal,
    required this.isChecked,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      child: InkWell(
        onTap: onToggle,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              if (goal.emoji != null) ...[
                Text(
                  goal.emoji!,
                  style: const TextStyle(fontSize: 24),
                ),
                const SizedBox(width: 12),
              ],
              Expanded(
                child: Text(
                  goal.title,
                  style: TextStyle(
                    fontSize: 16,
                    decoration: isChecked ? TextDecoration.lineThrough : null,
                    color: isChecked ? Colors.grey : null,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: Theme.of(context).primaryColor,
                    width: 2,
                  ),
                  color: isChecked ? Theme.of(context).primaryColor : null,
                ),
                child: isChecked
                    ? const Icon(
                        Icons.check,
                        size: 16,
                        color: Colors.white,
                      )
                    : null,
              ),
            ],
          ),
        ),
      ),
    );
  }
} 