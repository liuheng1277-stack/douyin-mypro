import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import '../utils/constants.dart';

class VideoParserResult {
  final bool success;
  final String? videoUrl;
  final String? coverUrl;
  final String? title;
  final String? author;
  final String? description;
  final String? error;

  VideoParserResult({
    required this.success,
    this.videoUrl,
    this.coverUrl,
    this.title,
    this.author,
    this.description,
    this.error,
  });
}

class VideoParserService {
  static final Dio _dio = Dio(BaseOptions(
    connectTimeout: const Duration(seconds: 15),
    receiveTimeout: const Duration(seconds: 30),
  ));

  /// 解析视频链接
  static Future<VideoParserResult> parseVideo(String url) async {
    // 1. 先尝试各个API源
    for (final apiUrl in AppConstants.parserApis) {
      try {
        final result = await _tryParseWithApi(apiUrl, url);
        if (result.success) return result;
      } catch (e) {
        debugPrint('API $apiUrl failed: $e');
        continue;
      }
    }

    // 2. 所有API都失败，尝试内置浏览器抓取
    try {
      return await _parseWithBrowserFallback(url);
    } catch (e) {
      return VideoParserResult(
        success: false,
        error: '所有解析源均失败: $e',
      );
    }
  }

  static Future<VideoParserResult> _tryParseWithApi(String apiUrl, String videoUrl) async {
    final response = await _dio.post(
      apiUrl,
      data: {'url': videoUrl},
      options: Options(headers: {'Content-Type': 'application/json'}),
    );

    if (response.statusCode == 200 && response.data != null) {
      final data = response.data;
      if (data['code'] == 200 || data['success'] == true) {
        return VideoParserResult(
          success: true,
          videoUrl: data['data']?['video_url'] ?? data['video_url'],
          coverUrl: data['data']?['cover_url'] ?? data['cover_url'],
          title: data['data']?['title'] ?? data['title'],
          author: data['data']?['author'] ?? data['author'],
          description: data['data']?['desc'] ?? data['desc'] ?? data['description'],
        );
      }
    }

    return VideoParserResult(success: false);
  }

  static Future<VideoParserResult> _parseWithBrowserFallback(String url) async {
    // 浏览器回退方案 - 返回失败，让上层使用WebView处理
    return VideoParserResult(
      success: false,
      error: 'API解析失败，请尝试使用WebView登录后解析',
    );
  }

  /// 提取视频ID
  static String? extractVideoId(String url) {
    // 支持多种抖音链接格式
    final patterns = [
      RegExp(r'video/(\d+)'),
      RegExp(r'modal_id=(\d+)'),
      RegExp(r'v\.(\d+)'),
      RegExp(r'/([^/]+)/?$'),
    ];

    for (final pattern in patterns) {
      final match = pattern.firstMatch(url);
      if (match != null && match.group(1) != null) {
        return match.group(1);
      }
    }
    return null;
  }
}
