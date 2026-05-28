import 'package:flutter/material.dart';
import '../models/video_model.dart';
import '../services/database_service.dart';

class VideoProvider extends ChangeNotifier {
  List<VideoModel> _videos = [];
  bool _isLoading = false;

  List<VideoModel> get videos => _videos;
  bool get isLoading => _isLoading;

  VideoProvider() {
    loadVideos();
  }

  Future<void> loadVideos() async {
    _isLoading = true;
    notifyListeners();

    try {
      _videos = await DatabaseService.getAllVideos();
    } catch (e) {
      debugPrint('Error loading videos: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> addVideo(VideoModel video) async {
    await DatabaseService.insertVideo(video);
    await loadVideos();
  }

  Future<void> updateVideo(VideoModel video) async {
    await DatabaseService.updateVideo(video);
    await loadVideos();
  }

  Future<void> deleteVideo(int id) async {
    await DatabaseService.deleteVideo(id);
    await loadVideos();
  }

  Future<void> updateDownloadStatus(String videoId, int status, {String? localPath}) async {
    await DatabaseService.updateVideoDownloadStatus(videoId, status, localPath: localPath);
    await loadVideos();
  }

  Future<void> syncVideos(List<VideoModel> newVideos) async {
    for (final video in newVideos) {
      await DatabaseService.insertVideo(video);
    }
    await loadVideos();
  }
}
