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

  Future<void> _updateNotificationEnabled(AppSettings settings, bool value) async {
    settings.notificationEnabled = value;
    await _storageService.saveSettings(settings);
    
    if (value) {
      await _notificationService.scheduleDailyReminder();
    } else {
      await _notificationService.cancelAllNotifications();
    }
  }

  Future<void> _updateNotificationTime(AppSettings settings) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: settings.notificationTime,
    );

    if (picked != null) {
      settings.notificationTime = picked;
      await _storageService.saveSettings(settings);
      
      if (settings.notificationEnabled) {
        await _notificationService.scheduleDailyReminder();
      }
    }
  }

  // 테스트 모드 설정을 업데이트하고 관련 데이터를 새로고침합니다.
  Future<void> _updateTestMode(AppSettings settings, bool value) async {
    settings.isTestMode = value;
    if (!value) {
      settings.testDate = null;
    } else if (settings.testDate == null) {
      settings.testDate = AppDateUtils.getCurrentDate();
    }
    await _storageService.saveSettings(settings);
    
    // Provider 상태 업데이트
    if (mounted) {
      context.read<GoalProvider>().updateSettings(settings);
    }
  }

  Future<void> _updateTestDate(AppSettings settings) async {
    if (!settings.isTestMode) return;

    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: settings.testDate ?? AppDateUtils.getCurrentDate(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );

    if (picked != null) {
      settings.testDate = picked;
      await _storageService.saveSettings(settings);

      // Provider 상태 업데이트
      if (mounted) {
        context.read<GoalProvider>().updateSettings(settings);
      }
    }
  }

  Future<void> _showResetConfirmDialog(String title, String message, Function() onConfirm) async {
    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('취소'),
          ),
          TextButton(
            onPressed: () {
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
    await _showResetConfirmDialog(
      '전체 데이터 초기화',
      '모든 목표와 체크 데이터, 앱 설정이 초기화되며\n앱 설치일이 현재 시점으로 변경됩니다.\n이 작업은 되돌릴 수 없습니다.',
      () async {
        // 데이터베이스 초기화
        await _databaseService.clearAllData();
        
        // 설정 초기화
        final defaultSettings = AppSettings();
        await _storageService.saveSettings(defaultSettings);
        
        // Provider 상태 업데이트
        if (mounted) {
          final settings = Provider.of<AppSettings>(context, listen: false);
          settings
            ..notificationEnabled = defaultSettings.notificationEnabled
            ..notificationTime = defaultSettings.notificationTime
            ..resetTime = defaultSettings.resetTime
            ..isTestMode = defaultSettings.isTestMode
            ..testDate = defaultSettings.testDate;

          // GoalProvider 상태 업데이트
          context.read<GoalProvider>().updateSettings(settings);
          
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
    return Consumer<AppSettings>(
      builder: (context, settings, child) {
        return Scaffold(
          appBar: AppBar(
            title: const Text('설정'),
          ),
          body: ListView(
            children: [
              SwitchListTile(
                title: const Text('알림 설정'),
                subtitle: const Text('매일 밤 목표 체크 알림을 받습니다'),
                value: settings.notificationEnabled,
                onChanged: (value) => _updateNotificationEnabled(settings, value),
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
              // 개발자 설정 섹션 추가
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
              const Divider(),
              const Padding(
                padding: EdgeInsets.all(16.0),
                child: Text('데이터 관리', style: TextStyle(fontWeight: FontWeight.bold)),
              ),
              ListTile(
                title: const Text('전체 데이터 초기화'),
                subtitle: const Text('모든 데이터를 초기화합니다'),
                leading: const Icon(Icons.delete_forever),
                textColor: Colors.red,
                iconColor: Colors.red,
                onTap: _resetAllData,
              ),
              const Divider(),
              AboutListTile(
                icon: const Icon(Icons.info),
                applicationName: '한 달의 집중',
                applicationVersion: '1.0.0',
                applicationLegalese: '© 2024 Monthly Focus',
                child: const Text('앱 정보'),
              ),
            ],
          ),
        );
      },
    );
  }
} 