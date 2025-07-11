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
import '../../models/app_settings.dart';
import '../../utils/date_utils.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final NotificationService _notificationService = NotificationService();
  final StorageService _storageService = StorageService();

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

  Future<void> _updateTestMode(AppSettings settings, bool value) async {
    settings.isTestMode = value;
    if (value) {
      settings.testDate = AppDateUtils.getCurrentDate();
    } else {
      settings.testDate = null;
    }
    await _storageService.saveSettings(settings);
    AppDateUtils.initialize(settings);
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
      AppDateUtils.initialize(settings);
    }
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