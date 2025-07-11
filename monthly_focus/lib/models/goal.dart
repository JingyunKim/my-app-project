/*
 * Goal: 월간 목표 데이터 모델
 * 
 * 주요 속성:
 * - id: 고유 식별자
 * - month: 목표가 속한 월 (YYYY-MM 형식)
 * - position: 목표 표시 순서
 * - title: 목표 제목
 * - emoji: 목표 대표 이모지
 * - created_at: 생성일시
 * 
 * 기능:
 * - JSON 직렬화/역직렬화
 * - 데이터베이스 매핑
 * - 목표 복사 및 비교
 */

import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';

class Goal {
  final int? id;
  final DateTime month;
  final int position;
  final String title;
  final String? emoji;
  final DateTime createdAt;

  // 목표 객체를 생성합니다.
  Goal({
    this.id,
    required this.month,
    required this.position,
    required this.title,
    this.emoji,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  // 목표 데이터를 Map 형태로 변환합니다.
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

  // Map 데이터로부터 목표 객체를 생성합니다.
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

  // 목표의 일부 속성을 변경한 새로운 객체를 생성합니다.
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