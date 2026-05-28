import 'package:flutter/material.dart';
import '../models/download_task_model.dart';
import '../services/database_service.dart';

class DownloadProvider extends ChangeNotifier {
  List<DownloadTaskModel> _tasks = [];

  List<DownloadTaskModel> get tasks => _tasks;

  DownloadProvider() {
    loadTasks();
  }

  Future<void> loadTasks() async {
    try {
      _tasks = await DatabaseService.getAllDownloadTasks();
      notifyListeners();
    } catch (e) {
      debugPrint('Error loading download tasks: $e');
    }
  }

  Future<void> addTask(DownloadTaskModel task) async {
    await DatabaseService.insertDownloadTask(task);
    await loadTasks();
  }

  Future<void> updateTask(DownloadTaskModel task) async {
    await DatabaseService.updateDownloadTask(task);
    await loadTasks();
  }

  Future<void> deleteTask(int id) async {
    await DatabaseService.deleteDownloadTask(id);
    await loadTasks();
  }
}
