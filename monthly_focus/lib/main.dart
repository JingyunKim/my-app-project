/*
 * Monthly Focus 앱 진입점
 * 
 * 앱 구조:
 * - lib/
 *   - services/: 데이터베이스, 저장소, 알림 서비스
 *   - providers/: 목표 데이터 상태 관리
 *   - models/: 목표, 체크, 설정 데이터 모델
 *   - screens/: 메인, 홈, 목표 설정, 달력, 설정 화면
 *   - widgets/: 목표 입력, 체크 카드 등 재사용 컴포넌트
 *   - config/: 앱 설정 및 상수
 * 
 * 주요 기능:
 * - Provider 패턴을 통한 상태 관리
 * - SQLite와 SharedPreferences를 통한 데이터 저장
 * - 관심사 분리와 단일 책임 원칙 준수
 */

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/goal_provider.dart';
import 'screens/main_screen.dart';
import 'services/storage_service.dart';
import 'services/notification_service.dart';
import 'models/app_settings.dart';
import 'utils/app_date_utils.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // 서비스 초기화
  final storageService = StorageService();
  await storageService.init();

  final notificationService = NotificationService();
  await notificationService.init();

  // 앱 설정 로드 및 초기화
  final settings = await storageService.loadSettings();
  AppDateUtils.initialize(settings);

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider<AppSettings>.value(value: settings),
        ChangeNotifierProvider<GoalProvider>(
          create: (_) => GoalProvider(settings),
        ),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '한 달의 집중',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      home: const MainScreen(),
    );
  }
}
