import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import '../models/video_model.dart';
import 'database_service.dart';

class SyncService {
  static final Dio _dio = Dio(BaseOptions(
    connectTimeout: const Duration(seconds: 15),
    receiveTimeout: const Duration(seconds: 30),
  ));

  /// 同步用户收藏列表
  /// 注意：这是模拟实现，实际需要根据抖音API或网页版来获取
  static Future<List<VideoModel>> syncFavorites({String? cookies}) async {
    if (cookies == null || cookies.isEmpty) {
      throw Exception('请先登录抖音');
    }

    try {
      // TODO: 实现实际的抖音收藏同步逻辑
      // 这里需要根据抖音网页版API或第三方接口来获取收藏列表

      // 模拟返回数据
      final now = DateTime.now().millisecondsSinceEpoch ~/ 1000;
      return [
        VideoModel(
          videoId: 'demo_${now}_1',
          title: '示例视频1',
          author: '示例作者',
          authorId: 'author_1',
          coverUrl: 'https://example.com/cover1.jpg',
          syncTime: now,
          description: '这是一个示例视频的文案描述...',
        ),
      ];
    } catch (e) {
      debugPrint('Sync error: $e');
      rethrow;
    }
  }

  /// 检查是否有新视频
  static Future<List<VideoModel>> checkNewVideos({String? cookies}) async {
    final allVideos = await DatabaseService.getAllVideos();
    final existingIds = allVideos.map((v) => v.videoId).toSet();

    final synced = await syncFavorites(cookies: cookies);
    return synced.where((v) => !existingIds.contains(v.videoId)).toList();
  }
}
