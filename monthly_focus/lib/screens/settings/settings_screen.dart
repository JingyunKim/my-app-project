import 'package:flutter/material.dart';
import '../../services/notification_service.dart';
import '../../services/storage_service.dart';
import '../../models/app_settings.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final NotificationService _notificationService = NotificationService();
  final StorageService _storageService = StorageService();
  late AppSettings _settings;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final settings = await _storageService.loadSettings();
    setState(() {
      _settings = settings;
      _isLoading = false;
    });
  }

  Future<void> _updateNotificationEnabled(bool value) async {
    final newSettings = _settings.copyWith(notificationEnabled: value);
    await _storageService.saveSettings(newSettings);
    
    if (value) {
      await _notificationService.scheduleDailyReminder();
    } else {
      await _notificationService.cancelAllNotifications();
    }

    setState(() {
      _settings = newSettings;
    });
  }

  Future<void> _updateNotificationTime() async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _settings.notificationTime,
    );

    if (picked != null) {
      final newSettings = _settings.copyWith(notificationTime: picked);
      await _storageService.saveSettings(newSettings);
      
      if (_settings.notificationEnabled) {
        await _notificationService.scheduleDailyReminder();
      }

      setState(() {
        _settings = newSettings;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('설정'),
      ),
      body: ListView(
        children: [
          SwitchListTile(
            title: const Text('알림 설정'),
            subtitle: const Text('매일 밤 목표 체크 알림을 받습니다'),
            value: _settings.notificationEnabled,
            onChanged: _updateNotificationEnabled,
          ),
          ListTile(
            title: const Text('알림 시간'),
            subtitle: Text(
              '${_settings.notificationTime.hour}시 ${_settings.notificationTime.minute}분',
            ),
            trailing: const Icon(Icons.chevron_right),
            onTap: _updateNotificationTime,
            enabled: _settings.notificationEnabled,
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
  }
} 