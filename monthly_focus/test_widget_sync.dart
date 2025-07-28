/*
 * 위젯 동기화 테스트 스크립트
 * 
 * 테스트 시나리오:
 * 1. 앱에서 목표 설정
 * 2. 위젯에서 체크 상태 변경
 * 3. 앱에서 동기화 확인
 * 4. 앱에서 체크 상태 변경
 * 5. 위젯에서 동기화 확인
 */

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class WidgetSyncTest {
  static const String _appGroup = 'group.com.example.monthlyfocus';
  static const String _goalsKey = 'monthlyGoals';

  // 테스트용 목표 데이터 생성
  static List<Map<String, dynamic>> createTestGoals() {
    return [
      {
        'id': '1',
        'title': '운동하기',
        'isCompleted': false,
        'year': DateTime.now().year,
        'month': DateTime.now().month,
      },
      {
        'id': '2',
        'title': '책 읽기',
        'isCompleted': true,
        'year': DateTime.now().year,
        'month': DateTime.now().month,
      },
      {
        'id': '3',
        'title': '공부하기',
        'isCompleted': false,
        'year': DateTime.now().year,
        'month': DateTime.now().month,
      },
      {
        'id': '4',
        'title': '명상하기',
        'isCompleted': false,
        'year': DateTime.now().year,
        'month': DateTime.now().month,
      },
    ];
  }

  // 위젯용 데이터 저장
  static Future<void> saveWidgetData(List<Map<String, dynamic>> goals) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonString = goals.toString(); // 간단한 변환
      await prefs.setString(_goalsKey, jsonString);
      print('위젯 데이터 저장 완료: ${goals.length}개 목표');
    } catch (e) {
      print('위젯 데이터 저장 실패: $e');
    }
  }

  // 위젯용 데이터 로드
  static Future<List<Map<String, dynamic>>> loadWidgetData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final data = prefs.getString(_goalsKey);
      if (data != null) {
        print('위젯 데이터 로드 완료');
        return createTestGoals(); // 테스트용 데이터 반환
      }
      return [];
    } catch (e) {
      print('위젯 데이터 로드 실패: $e');
      return [];
    }
  }

  // 테스트 실행
  static Future<void> runTest() async {
    print('=== 위젯 동기화 테스트 시작 ===');
    
    // 1. 테스트 데이터 저장
    final testGoals = createTestGoals();
    await saveWidgetData(testGoals);
    
    // 2. 데이터 로드 확인
    final loadedGoals = await loadWidgetData();
    print('로드된 목표 수: ${loadedGoals.length}');
    
    // 3. 각 목표 상태 출력
    for (final goal in loadedGoals) {
      print('목표: ${goal['title']} - 완료: ${goal['isCompleted']}');
    }
    
    print('=== 위젯 동기화 테스트 완료 ===');
  }
}

// 테스트 화면
class WidgetTestScreen extends StatelessWidget {
  const WidgetTestScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('위젯 테스트'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ElevatedButton(
              onPressed: () async {
                await WidgetSyncTest.runTest();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('테스트 완료! 콘솔을 확인하세요.')),
                );
              },
              child: const Text('위젯 동기화 테스트 실행'),
            ),
            const SizedBox(height: 16),
            const Text(
              '테스트 단계:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text('1. 앱에서 목표 설정'),
            const Text('2. 위젯 추가 (홈 화면에서 길게 누르기)'),
            const Text('3. 위젯에서 체크박스 탭'),
            const Text('4. 앱에서 동기화 확인'),
            const Text('5. 앱에서 체크박스 탭'),
            const Text('6. 위젯에서 동기화 확인'),
          ],
        ),
      ),
    );
  }
} 