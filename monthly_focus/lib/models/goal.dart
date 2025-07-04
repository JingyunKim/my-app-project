import 'package:flutter/material.dart';

class Goal {
  final int? id;
  final DateTime month;
  final int position;
  final String title;
  final String? emoji;
  final DateTime createdAt;

  Goal({
    this.id,
    required this.month,
    required this.position,
    required this.title,
    this.emoji,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  // DB에서 사용할 Map 변환 메서드
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'month': month.toIso8601String(),
      'position': position,
      'title': title,
      'emoji': emoji,
      'created_at': createdAt.toIso8601String(),
    };
  }

  // DB에서 데이터를 가져올 때 사용할 팩토리 메서드
  factory Goal.fromMap(Map<String, dynamic> map) {
    return Goal(
      id: map['id'] as int,
      month: DateTime.parse(map['month']),
      position: map['position'] as int,
      title: map['title'] as String,
      emoji: map['emoji'] as String?,
      createdAt: DateTime.parse(map['created_at']),
    );
  }

  // 목표 복사본 생성 (상태 업데이트 시 사용)
  Goal copyWith({
    int? id,
    DateTime? month,
    int? position,
    String? title,
    String? emoji,
    DateTime? createdAt,
  }) {
    return Goal(
      id: id ?? this.id,
      month: month ?? this.month,
      position: position ?? this.position,
      title: title ?? this.title,
      emoji: emoji ?? this.emoji,
      createdAt: createdAt ?? this.createdAt,
    );
  }
} 