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

  final List<Widget> _screens = [
    const HomeScreen(),
    const CalendarScreen(),
    const SettingsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
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
} 