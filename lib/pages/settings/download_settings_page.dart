import 'package:flutter/material.dart';
import '../../services/database_service.dart';
import '../../utils/constants.dart';

class DownloadSettingsPage extends StatefulWidget {
  const DownloadSettingsPage({super.key});

  @override
  State<DownloadSettingsPage> createState() => _DownloadSettingsPageState();
}

class _DownloadSettingsPageState extends State<DownloadSettingsPage> {
  int _maxConcurrent = 3;
  bool _wifiOnly = true;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final max = await DatabaseService.getSetting(AppConstants.keyMaxConcurrentDownloads);
    if (max != null) {
      setState(() => _maxConcurrent = int.tryParse(max) ?? 3);
    }

    final wifi = await DatabaseService.getSetting(AppConstants.keyWifiOnly);
    setState(() => _wifiOnly = wifi != 'false');
  }

  Future<void> _saveSettings() async {
    await DatabaseService.setSetting(
      AppConstants.keyMaxConcurrentDownloads,
      _maxConcurrent.toString(),
    );
    await DatabaseService.setSetting(
      AppConstants.keyWifiOnly,
      _wifiOnly.toString(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('下载设置'),
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
          // 同时下载数
          ListTile(
            leading: const Icon(Icons.download),
            title: const Text('同时下载数'),
            subtitle: Text('$_maxConcurrent 个'),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Slider(
              value: _maxConcurrent.toDouble(),
              min: 1,
              max: 10,
              divisions: 9,
              label: '$_maxConcurrent 个',
              onChanged: (value) {
                setState(() => _maxConcurrent = value.round());
              },
            ),
          ),
          const Divider(),

          // 仅WiFi下载
          SwitchListTile(
            secondary: const Icon(Icons.wifi),
            title: const Text('仅WiFi下载'),
            subtitle: const Text('使用移动数据时不自动下载'),
            value: _wifiOnly,
            onChanged: (value) => setState(() => _wifiOnly = value),
          ),
          const Divider(),

          // 下载目录
          ListTile(
            leading: const Icon(Icons.folder),
            title: const Text('下载目录'),
            subtitle: const Text('/storage/emulated/0/Download/抖下载mypro/'),
            onTap: () {
              // TODO: 实现目录选择
            },
          ),
        ],
      ),
    );
  }
}
