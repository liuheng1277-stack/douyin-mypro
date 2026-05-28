import 'package:flutter/material.dart';
import '../models/video_model.dart';
import '../utils/formatters.dart';

class FileDetailPopup extends StatelessWidget {
  final VideoModel video;

  const FileDetailPopup({super.key, required this.video});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '文件详情',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            _buildDetailItem('文件名', video.title),
            _buildDetailItem('作者', video.author),
            _buildDetailItem('大小', Formatters.formatFileSize(video.fileSize)),
            _buildDetailItem('时长', Formatters.formatDuration(video.duration)),
            _buildDetailItem('分辨率', video.width != null && video.height != null
                ? '${video.width}x${video.height}'
                : '未知'),
            _buildDetailItem('格式', video.format ?? 'MP4'),
            _buildDetailItem('保存路径', video.localPath ?? '未下载'),
            _buildDetailItem('同步时间', Formatters.formatDateTime(video.syncTime)),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('关闭'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailItem(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              label,
              style: TextStyle(
                fontSize: 13,
                color: Colors.grey.shade600,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontSize: 13),
            ),
          ),
        ],
      ),
    );
  }
}
