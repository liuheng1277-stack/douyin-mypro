import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import '../models/download_task_model.dart';
import '../utils/constants.dart';
import 'database_service.dart';

class DownloadService {
  static final Dio _dio = Dio(BaseOptions(
    connectTimeout: const Duration(seconds: 30),
    receiveTimeout: const Duration(seconds: 60),
  ));

  static Future<String?> getDownloadDirectory() async {
    // 尝试获取外部存储下载目录
    if (Platform.isAndroid) {
      final status = await Permission.storage.request();
      if (status.isGranted || status.isLimited) {
        // 使用应用外部存储
        final extDir = await getExternalStorageDirectory();
        if (extDir != null) {
          final downloadDir = Directory('${extDir.path}/${AppConstants.downloadDirName}');
          if (!await downloadDir.exists()) {
            await downloadDir.create(recursive: true);
          }
          return downloadDir.path;
        }
      }
    }

    // 回退到应用文档目录
    final appDir = await getApplicationDocumentsDirectory();
    final downloadDir = Directory('${appDir.path}/${AppConstants.downloadDirName}');
    if (!await downloadDir.exists()) {
      await downloadDir.create(recursive: true);
    }
    return downloadDir.path;
  }

  static Future<DownloadTaskModel> startDownload({
    required String videoId,
    required String url,
    required String fileName,
    Function(double progress)? onProgress,
  }) async {
    final dirPath = await getDownloadDirectory();
    if (dirPath == null) {
      throw Exception('无法获取下载目录');
    }

    final filePath = '$dirPath/$fileName';

    // 创建下载任务
    final task = DownloadTaskModel(
      videoId: videoId,
      url: url,
      localPath: filePath,
      status: 1, // 下载中
      createTime: DateTime.now().millisecondsSinceEpoch ~/ 1000,
    );

    final taskId = await DatabaseService.insertDownloadTask(task);
    final taskWithId = DownloadTaskModel(
      id: taskId,
      videoId: videoId,
      url: url,
      localPath: filePath,
      status: 1,
      createTime: task.createTime,
    );

    // 开始下载
    try {
      await _dio.download(
        url,
        filePath,
        onReceiveProgress: (received, total) {
          if (total > 0) {
            final progress = received / total;
            onProgress?.call(progress);
          }
        },
      );

      // 下载完成
      final completedTask = DownloadTaskModel(
        id: taskId,
        videoId: videoId,
        url: url,
        localPath: filePath,
        status: 2, // 完成
        progress: 1.0,
        createTime: task.createTime,
      );
      await DatabaseService.updateDownloadTask(completedTask);
      return completedTask;
    } catch (e) {
      // 下载失败
      final failedTask = DownloadTaskModel(
        id: taskId,
        videoId: videoId,
        url: url,
        localPath: filePath,
        status: 3, // 失败
        errorMsg: e.toString(),
        createTime: task.createTime,
      );
      await DatabaseService.updateDownloadTask(failedTask);
      return failedTask;
    }
  }

  static Future<void> deleteDownloadedFile(String filePath) async {
    try {
      final file = File(filePath);
      if (await file.exists()) {
        await file.delete();
      }
    } catch (e) {
      debugPrint('Error deleting file: $e');
    }
  }
}
