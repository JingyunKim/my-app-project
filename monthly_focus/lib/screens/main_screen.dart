/*
 * MainScreen: 앱의 메인 네비게이션 화면
 * 
 * 주요 기능:
 * - 하단 네비게이션 바 관리
 * - 화면 전환 관리 (홈, 달력, 설정)
 * - 앱 초기화 및 데이터 로딩
 * - 앱 상태 관리
 * 
 * 화면 구성:
 * - BottomNavigationBar: 화면 전환 네비게이션
 * - HomeScreen: 메인 목표 관리 화면
 * - CalendarScreen: 달력 보기 화면
 * - SettingsScreen: 앱 설정 화면
 */

import 'package:flutter/material.dart';
import 'home/home_screen.dart';
import 'calendar/calendar_screen.dart';
import 'settings/settings_screen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;
  late final List<Widget> _screens;

  @override
  void initState() {
    super.initState();
    print('메인 화면: 초기화 시작');
    _screens = [
      const HomeScreen(),
      const CalendarScreen(),
      const SettingsScreen(),
    ];
    print('메인 화면: 초기화 완료');
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    print('메인 화면: 의존성 변경 감지');
  }

  void _handleTabChange(int index) {
    print('메인 화면: 탭 변경 - ${_getTabName(index)}으로 이동 시작');
    setState(() {
      _currentIndex = index;
    });
    print('메인 화면: 탭 변경 완료');
  }

  @override
  Widget build(BuildContext context) {
    print('메인 화면: 화면 빌드 시작');
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: _handleTabChange,
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home),
            label: '오늘',
          ),
          NavigationDestination(
            icon: Icon(Icons.calendar_month_outlined),
            selectedIcon: Icon(Icons.calendar_month),
            label: '달력',
          ),
          NavigationDestination(
            icon: Icon(Icons.settings_outlined),
            selectedIcon: Icon(Icons.settings),
            label: '설정',
          ),
        ],
      ),
    );
  }

  String _getTabName(int index) {
    print('메인 화면: 탭 이름 조회 - 인덱스 $index');
    final name = switch (index) {
      0 => '오늘',
      1 => '달력',
      2 => '설정',
      _ => '알 수 없음'
    };
    print('메인 화면: 탭 이름 반환 - $name');
    return name;
  }
} 