/*
 * SettingsScreen: 앱 설정 화면
 * 
 * 주요 기능:
 * - 알림 설정 관리
 *   - 일일 체크 알림 시간
 *   - 다음 달 목표 알림
 * - 테마 설정 (라이트/다크 모드)
 * - 앱 정보 표시
 * - 데이터 백업/복원
 * - 테스트 모드 설정
 * 
 * 화면 구성:
 * - NotificationSettings: 알림 관련 설정
 * - ThemeSettings: 테마 모드 설정
 * - AppInfo: 버전, 개발자 정보
 * - DataManagement: 데이터 관리 옵션
 * - TestModeSettings: 테스트 모드 설정 (개발자용)
 */

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';  // HapticFeedback을 위한 import
import 'package:provider/provider.dart';
import '../../services/notification_service.dart';
import '../../services/storage_service.dart';
import '../../services/database_service.dart'; // Added import for DatabaseService
import '../../models/app_settings.dart';
import '../../utils/app_date_utils.dart';
import '../../providers/goal_provider.dart'; // Added import for GoalProvider

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final NotificationService _notificationService = NotificationService();
  final StorageService _storageService = StorageService();
  final DatabaseService _databaseService = DatabaseService();
  bool _showDeveloperSettings = false;  // 개발자 설정 표시 여부

  Future<void> _updateNotificationEnabled(AppSettings settings, bool value) async {
    print('설정 화면: 알림 설정 변경 - ${value ? "활성화" : "비활성화"}');
    settings.notificationEnabled = value;
    await _storageService.saveSettings(settings);
    
    if (value) {
      print('설정 화면: 알림 스케줄 등록');
      await _notificationService.scheduleDailyReminder();
    } else {
      print('설정 화면: 모든 알림 취소');
      await _notificationService.cancelAllNotifications();
    }
  }

  Future<void> _updateNotificationTime(AppSettings settings) async {
    print('설정 화면: 알림 시간 설정 시작');
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: settings.notificationTime,
    );

    if (picked != null) {
      print('설정 화면: 알림 시간 변경 - ${picked.hour}시 ${picked.minute}분');
      settings.notificationTime = picked;
      await _storageService.saveSettings(settings);
      
      if (settings.notificationEnabled) {
        print('설정 화면: 변경된 시간으로 알림 스케줄 업데이트');
        await _notificationService.scheduleDailyReminder();
      }
    }
  }

  // 테스트 모드 설정을 업데이트하고 관련 데이터를 새로고침합니다.
  Future<void> _updateTestMode(AppSettings settings, bool value) async {
    print('설정 화면: 테스트 모드 ${value ? "활성화" : "비활성화"}');
    settings.isTestMode = value;
    if (!value) {
      settings.testDate = null;
      print('설정 화면: 테스트 날짜 초기화');
    } else if (settings.testDate == null) {
      settings.testDate = AppDateUtils.getCurrentDate();
      print('설정 화면: 테스트 날짜를 현재 날짜로 설정');
    }
    await _storageService.saveSettings(settings);
    
    // Provider 상태 업데이트
    if (mounted) {
      print('설정 화면: Provider 상태 업데이트');
      context.read<GoalProvider>().updateSettings(settings);
    }
  }

  Future<void> _updateTestDate(AppSettings settings) async {
    print('설정 화면: 테스트 날짜 설정 시작');
    if (!settings.isTestMode) {
      print('설정 화면: 테스트 모드가 비활성화되어 있어 날짜 설정 불가');
      return;
    }

    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: settings.testDate ?? AppDateUtils.getCurrentDate(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );

    if (picked != null) {
      print('설정 화면: 테스트 날짜 변경 - ${picked.year}년 ${picked.month}월 ${picked.day}일');
      settings.testDate = picked;
      await _storageService.saveSettings(settings);

      // Provider 상태 업데이트
      if (mounted) {
        print('설정 화면: Provider 상태 업데이트');
        context.read<GoalProvider>().updateSettings(settings);
      }
    }
  }

  Future<void> _showResetConfirmDialog(String title, String message, Function() onConfirm) async {
    print('설정 화면: 초기화 확인 다이얼로그 표시 - $title');
    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () {
              print('설정 화면: 초기화 취소');
              Navigator.of(context).pop();
            },
            child: const Text('취소'),
          ),
          TextButton(
            onPressed: () {
              print('설정 화면: 초기화 확인');
              Navigator.of(context).pop();
              onConfirm();
            },
            style: TextButton.styleFrom(
              foregroundColor: Colors.red,
            ),
            child: const Text('초기화'),
          ),
        ],
      ),
    );
  }

  Future<void> _resetAllData() async {
    print('설정 화면: 전체 데이터 초기화 시작');
    await _showResetConfirmDialog(
      '전체 데이터 초기화',
      '모든 목표와 체크 데이터, 앱 설정이 초기화되며\n앱 설치일이 현재 시점으로 변경됩니다.\n이 작업은 되돌릴 수 없습니다.',
      () async {
        print('설정 화면: 데이터베이스 초기화');
        await _databaseService.clearAllData();
        
        print('설정 화면: 설정 초기화');
        final defaultSettings = AppSettings();
        await _storageService.saveSettings(defaultSettings);
        
        // Provider 상태 업데이트
        if (mounted) {
          print('설정 화면: Provider 상태 업데이트');
          final settings = Provider.of<AppSettings>(context, listen: false);
          settings
            ..notificationEnabled = defaultSettings.notificationEnabled
            ..notificationTime = defaultSettings.notificationTime
            ..resetTime = defaultSettings.resetTime
            ..isTestMode = defaultSettings.isTestMode
            ..testDate = defaultSettings.testDate;

          // GoalProvider 상태 업데이트
          context.read<GoalProvider>().updateSettings(settings);
          
          print('설정 화면: 초기화 완료 메시지 표시');
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('모든 데이터가 초기화되었습니다.'),
              duration: Duration(seconds: 2),
            ),
          );
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    print('설정 화면: 화면 빌드 시작');
    return Consumer<AppSettings>(
      builder: (context, settings, child) {
        return Scaffold(
          backgroundColor: Theme.of(context).colorScheme.surface,
          appBar: AppBar(
            title: const Text('설정'),
            backgroundColor: Theme.of(context).colorScheme.surface,
            elevation: 0,
            surfaceTintColor: Colors.transparent,
            actions: [
              GestureDetector(
                onLongPress: () {
                  print('설정 화면: 개발자 설정 토글');
                  setState(() {
                    _showDeveloperSettings = !_showDeveloperSettings;
                  });
                  // 햅틱 피드백 제공
                  HapticFeedback.heavyImpact();
                  // 토스트 메시지 표시
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(_showDeveloperSettings ? '개발자 설정이 활성화되었습니다.' : '개발자 설정이 비활성화되었습니다.'),
                      duration: const Duration(seconds: 2),
                    ),
                  );
                },
                behavior: HitTestBehavior.opaque,  // 투명 영역도 터치 가능하도록 설정
                child: const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 8.0),
                  child: SizedBox(
                    width: 80,  // 너비 증가
                    height: 56,  // 높이를 AppBar 높이에 맞춤
                  ),
                ),
              ),
            ],
          ),
          body: Column(
            children: [
              // AppBar와 설정 목록 사이 구분선
              const Divider(
                height: 1,
                thickness: 1.0,
              ),
              Expanded(
                child: ListView(
                  children: [
                    // 알림 설정 섹션
                    SwitchListTile(
                      title: const Text('알림 설정'),
                      subtitle: const Text('매일 밤 11시에 알림을 받습니다'),
                      value: settings.notificationEnabled,
                      onChanged: (bool value) {
                        settings.notificationEnabled = value;
                        if (value) {
                          _notificationService.scheduleDailyReminder();
                        } else {
                          _notificationService.cancelAllNotifications();
                        }
                      },
                    ),
                    ListTile(
                      title: const Text('알림 시간'),
                      subtitle: Text(
                        '${settings.notificationTime.hour}시 ${settings.notificationTime.minute}분',
                      ),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () => _updateNotificationTime(settings),
                      enabled: settings.notificationEnabled,
                    ),
                    const Divider(),
                    
                    // 개발자 설정 섹션 - _showDeveloperSettings가 true일 때만 표시
                    if (_showDeveloperSettings) ...[
                      const Padding(
                        padding: EdgeInsets.all(16.0),
                        child: Text('개발자 설정', style: TextStyle(fontWeight: FontWeight.bold)),
                      ),
                      SwitchListTile(
                        title: const Text('테스트 모드'),
                        subtitle: const Text('날짜를 수동으로 설정할 수 있습니다'),
                        value: settings.isTestMode,
                        onChanged: (value) => _updateTestMode(settings, value),
                      ),
                      if (settings.isTestMode)
                        ListTile(
                          title: const Text('테스트 날짜 설정'),
                          subtitle: Text(
                            settings.testDate?.toString().split(' ')[0] ?? '날짜를 선택해주세요',
                          ),
                          trailing: const Icon(Icons.calendar_today),
                          onTap: () => _updateTestDate(settings),
                        ),
                      if (settings.notificationEnabled)
                        ListTile(
                          title: const Text('알림 테스트'),
                          subtitle: const Text('현재 설정된 알림을 즉시 발송합니다'),
                          onTap: () {
                            _notificationService.showTestNotification();
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('테스트 알림이 발송되었습니다.'),
                                duration: Duration(seconds: 2),
                              ),
                            );
                          },
                        ),
                        ListTile(
                          title: const Text(
                            '데이터 초기화',
                            style: TextStyle(
                              color: Colors.red,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          subtitle: const Text(
                            '모든 데이터를 초기화합니다',
                            style: TextStyle(
                              color: Colors.red,
                            ),
                          ),
                          leading: const Icon(
                            Icons.delete_forever,
                            color: Colors.red,
                          ),
                          onTap: _resetAllData,
                        ),
                        const Divider(),
                      ],
                    
                    // 앱 정보 섹션
                    AboutListTile(
                      icon: const Icon(Icons.info),
                      applicationName: '한 달의 집중',
                      applicationVersion: '1.0.0',
                      applicationLegalese: '© 2024 Monthly Focus\n\n만든이: 김진균\nEmail: wlsrbs321@naver.com',
                      child: const Text('앱 정보'),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
} 