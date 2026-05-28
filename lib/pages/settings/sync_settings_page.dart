import 'package:flutter/material.dart';
import '../../services/database_service.dart';
import '../../utils/constants.dart';

class SyncSettingsPage extends StatefulWidget {
  const SyncSettingsPage({super.key});

  @override
  State<SyncSettingsPage> createState() => _SyncSettingsPageState();
}

class _SyncSettingsPageState extends State<SyncSettingsPage> {
  TimeOfDay? _fixedTime;
  int _intervalMinutes = 30;
  bool _syncOnOpen = false;
  bool _syncBackground = false;
  int _backgroundIntervalHours = 6;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final timeStr = await DatabaseService.getSetting(AppConstants.keySyncFixedTime);
    if (timeStr != null && timeStr.isNotEmpty) {
      final parts = timeStr.split(':');
      if (parts.length == 2) {
        setState(() {
          _fixedTime = TimeOfDay(
            hour: int.parse(parts[0]),
            minute: int.parse(parts[1]),
          );
        });
      }
    }

    final interval = await DatabaseService.getSetting(AppConstants.keySyncInterval);
    if (interval != null) {
      setState(() => _intervalMinutes = int.tryParse(interval) ?? 30);
    }

    final onOpen = await DatabaseService.getSetting(AppConstants.keySyncOnOpen);
    setState(() => _syncOnOpen = onOpen == 'true');

    final bg = await DatabaseService.getSetting(AppConstants.keySyncBackground);
    setState(() => _syncBackground = bg == 'true');

    final bgInterval = await DatabaseService.getSetting(AppConstants.keySyncBackgroundInterval);
    if (bgInterval != null) {
      setState(() => _backgroundIntervalHours = int.tryParse(bgInterval) ?? 6);
    }
  }

  Future<void> _saveSettings() async {
    if (_fixedTime != null) {
      await DatabaseService.setSetting(
        AppConstants.keySyncFixedTime,
        '${_fixedTime!.hour.toString().padLeft(2, '0')}:${_fixedTime!.minute.toString().padLeft(2, '0')}',
      );
    }
    await DatabaseService.setSetting(
      AppConstants.keySyncInterval,
      _intervalMinutes.toString(),
    );
    await DatabaseService.setSetting(
      AppConstants.keySyncOnOpen,
      _syncOnOpen.toString(),
    );
    await DatabaseService.setSetting(
      AppConstants.keySyncBackground,
      _syncBackground.toString(),
    );
    await DatabaseService.setSetting(
      AppConstants.keySyncBackgroundInterval,
      _backgroundIntervalHours.toString(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('同步设置'),
        actions: [
          TextButton(
            onPressed: () async {
              await _saveSettings();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('设置已保存')),
              );
              Navigator.pop(context);
            },
            child: const Text('保存', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
      body: ListView(
        children: [
          // 每天固定时间同步（点击弹出时间选择器）
          ListTile(
            leading: const Icon(Icons.access_time),
            title: const Text('每天固定时间同步'),
            subtitle: Text(_fixedTime != null
                ? '${_fixedTime!.hour.toString().padLeft(2, '0')}:${_fixedTime!.minute.toString().padLeft(2, '0')}'
                : '点击设置时间'),
            trailing: _fixedTime != null
                ? IconButton(
                    icon: const Icon(Icons.clear),
                    onPressed: () => setState(() => _fixedTime = null),
                  )
                : const Icon(Icons.chevron_right),
            onTap: () async {
              final time = await showTimePicker(
                context: context,
                initialTime: _fixedTime ?? TimeOfDay.now(),
              );
              if (time != null) {
                setState(() => _fixedTime = time);
              }
            },
          ),
          const Divider(),

          // 每隔N分钟检查
          ListTile(
            leading: const Icon(Icons.timer),
            title: const Text('每隔N分钟检查'),
            subtitle: Text('当前: $_intervalMinutes 分钟'),
            onTap: () => _showIntervalPicker(),
          ),
          const Divider(),

          // 打开App时自动刷新
          SwitchListTile(
            secondary: const Icon(Icons.app_settings_alt),
            title: const Text('打开App时自动刷新'),
            value: _syncOnOpen,
            onChanged: (value) => setState(() => _syncOnOpen = value),
          ),
          const Divider(),

          // 后台刷新
          SwitchListTile(
            secondary: const Icon(Icons.update),
            title: const Text('后台自动刷新'),
            subtitle: Text('每 $_backgroundIntervalHours 小时'),
            value: _syncBackground,
            onChanged: (value) => setState(() => _syncBackground = value),
          ),
          if (_syncBackground)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  const Text('刷新间隔:'),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Slider(
                      value: _backgroundIntervalHours.toDouble(),
                      min: 1,
                      max: 24,
                      divisions: 23,
                      label: '$_backgroundIntervalHours 小时',
                      onChanged: (value) {
                        setState(() => _backgroundIntervalHours = value.round());
                      },
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  void _showIntervalPicker() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('设置检查间隔'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('$_intervalMinutes 分钟'),
            Slider(
              value: _intervalMinutes.toDouble(),
              min: 5,
              max: 120,
              divisions: 23,
              label: '$_intervalMinutes 分钟',
              onChanged: (value) {
                setState(() => _intervalMinutes = value.round());
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('确定'),
          ),
        ],
      ),
    );
  }
}
