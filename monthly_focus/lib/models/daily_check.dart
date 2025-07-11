/*
 * DailyCheck: 목표별 일일 체크 데이터 모델
 * 
 * 주요 속성:
 * - id: 고유 식별자
 * - goal_id: 연관된 목표 ID
 * - date: 체크한 날짜 (YYYY-MM-DD 형식)
 * - is_completed: 완료 여부
 * - checked_at: 체크한 시간
 * 
 * 기능:
 * - JSON 직렬화/역직렬화
 * - 데이터베이스 매핑
 * - 체크 상태 토글
 */

import 'package:flutter/foundation.dart';

class DailyCheck {
  final int? id;
  final int goalId;
  final DateTime date;
  final bool isCompleted;
  final DateTime checkedAt;

  DailyCheck({
    this.id,
    required this.goalId,
    required this.date,
    required this.isCompleted,
    DateTime? checkedAt,
  }) : checkedAt = checkedAt ?? DateTime.now();

  // DB에서 사용할 Map 변환 메서드
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'goal_id': goalId,
      'date': DateTime(date.year, date.month, date.day).toIso8601String(),
      'is_completed': isCompleted ? 1 : 0,
      'checked_at': checkedAt.toIso8601String(),
    };
  }

  // DB에서 데이터를 가져올 때 사용할 팩토리 메서드
  factory DailyCheck.fromMap(Map<String, dynamic> map) {
    final parsedDate = DateTime.parse(map['date']);
    return DailyCheck(
      id: map['id'] as int,
      goalId: map['goal_id'] as int,
      date: DateTime(parsedDate.year, parsedDate.month, parsedDate.day),
      isCompleted: map['is_completed'] == 1,
      checkedAt: DateTime.parse(map['checked_at']),
    );
  }

  // 체크 복사본 생성 (상태 업데이트 시 사용)
  DailyCheck copyWith({
    int? id,
    int? goalId,
    DateTime? date,
    bool? isCompleted,
    DateTime? checkedAt,
  }) {
    return DailyCheck(
      id: id ?? this.id,
      goalId: goalId ?? this.goalId,
      date: date ?? this.date,
      isCompleted: isCompleted ?? this.isCompleted,
      checkedAt: checkedAt ?? this.checkedAt,
    );
  }
} 