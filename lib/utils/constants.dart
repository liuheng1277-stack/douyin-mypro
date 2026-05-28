import 'package:flutter/material.dart';

class AppConstants {
  static const String appName = '抖下载mypro';
  static const String appVersion = '1.0.0';

  // 默认主题色 - 绿色
  static const Color defaultPrimaryColor = Color(0xFF2E7D32);
  static const Color defaultAccentColor = Color(0xFF4CAF50);
  static const Color defaultBackgroundColor = Color(0xFFF0F8F0);

  // 抖音相关
  static const String douyinBaseUrl = 'https://www.douyin.com';
  static const String douyinShareUrlPattern = r'douyin\.com';

  // 视频解析API源（示例，实际使用时替换为可用的API）
  static const List<String> parserApis = [
    'https://api.example1.com/parse',
    'https://api.example2.com/parse',
    'https://api.example3.com/parse',
  ];

  // 数据库名称
  static const String dbName = 'douyin_mypro.db';
  static const int dbVersion = 1;

  // 下载目录名
  static const String downloadDirName = '抖下载mypro';

  // 同步模式
  static const String syncModeFixedTime = 'fixed_time';
  static const String syncModeInterval = 'interval';
  static const String syncModeOnOpen = 'on_open';
  static const String syncModeBackground = 'background';

  // 设置键
  static const String keyThemeColor = 'theme_color';
  static const String keyBackgroundImage = 'background_image';
  static const String keySyncFixedTime = 'sync_fixed_time';
  static const String keySyncInterval = 'sync_interval';
  static const String keySyncOnOpen = 'sync_on_open';
  static const String keySyncBackground = 'sync_background';
  static const String keySyncBackgroundInterval = 'sync_background_interval';
  static const String keyDownloadDir = 'download_dir';
  static const String keyMaxConcurrentDownloads = 'max_concurrent_downloads';
  static const String keyWifiOnly = 'wifi_only';
  static const String keyDouyinCookies = 'douyin_cookies';
  static const String keyYikeAlbumToken = 'yike_album_token';
}
