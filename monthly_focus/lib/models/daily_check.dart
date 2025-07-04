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
      'date': date.toIso8601String(),
      'is_completed': isCompleted ? 1 : 0,
      'checked_at': checkedAt.toIso8601String(),
    };
  }

  // DB에서 데이터를 가져올 때 사용할 팩토리 메서드
  factory DailyCheck.fromMap(Map<String, dynamic> map) {
    return DailyCheck(
      id: map['id'] as int,
      goalId: map['goal_id'] as int,
      date: DateTime.parse(map['date']),
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