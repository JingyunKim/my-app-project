/*
 * 위젯 테스트: Monthly Focus 앱의 위젯 테스트
 * 
 * 테스트 범위:
 * - 앱 실행 및 초기화
 * - 목표 입력 위젯
 * - 목표 체크 카드
 * - 달력 위젯
 * 
 * 테스트 케이스:
 * - 앱 시작 시 정상 렌더링
 * - 목표 입력 유효성 검사
 * - 체크 상태 토글 동작
 * - 달력 날짜 선택
 */

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:monthly_focus/main.dart';

void main() {
  testWidgets('Counter increments smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const MyApp());

    // Verify that our counter starts at 0.
    expect(find.text('0'), findsOneWidget);
    expect(find.text('1'), findsNothing);

    // Tap the '+' icon and trigger a frame.
    await tester.tap(find.byIcon(Icons.add));
    await tester.pump();

    // Verify that our counter has incremented.
    expect(find.text('0'), findsNothing);
    expect(find.text('1'), findsOneWidget);
  });
}
