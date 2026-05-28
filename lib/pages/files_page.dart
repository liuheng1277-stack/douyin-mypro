import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/video_model.dart';
import '../providers/theme_provider.dart';
import '../providers/video_provider.dart';
import '../services/download_service.dart';
import '../utils/formatters.dart';
import '../widgets/file_detail_popup.dart';
import 'video_player_page.dart';
import 'preview_page.dart';

class FilesPage extends StatefulWidget {
  const FilesPage({super.key});

  @override
  State<FilesPage> createState() => _FilesPageState();
}

class _FilesPageState extends State<FilesPage> {
  bool _isDouyinMode = false;

  @override
  Widget build(BuildContext context) {
    final themeProvider = context.watch<ThemeProvider>();
    final videoProvider = context.watch<VideoProvider>();
    final downloadedVideos = videoProvider.videos
        .where((v) => v.downloadStatus == 2 || v.localPath != null)
        .toList();

    if (_isDouyinMode && downloadedVideos.isNotEmpty) {
      return PreviewPage(videos: downloadedVideos);
    }

    return themeProvider.buildBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: themeProvider.primaryColor,
          title: const Text('文件'),
          actions: [
            // 浏览模式切换
            TextButton.icon(
              onPressed: () {
                setState(() => _isDouyinMode = !_isDouyinMode);
              },
              icon: Icon(
                _isDouyinMode ? Icons.view_list : Icons.view_carousel,
                color: Colors.white,
              ),
              label: Text(
                _isDouyinMode ? '列表模式' : '抖音模式',
                style: const TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),
        body: downloadedVideos.isEmpty
            ? const Center(
                child: Text(
                  '暂无下载的视频',
                  style: TextStyle(color: Colors.black54),
                ),
              )
            : ListView.builder(
                padding: const EdgeInsets.all(12),
                itemCount: downloadedVideos.length,
                itemBuilder: (context, index) {
                  final video = downloadedVideos[index];
                  return _buildVideoListItem(video);
                },
              ),
      ),
    );
  }

  Widget _buildVideoListItem(VideoModel video) {
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => VideoPlayerPage(video: video),
            ),
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              // 缩略图
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Container(
                  width: 80,
                  height: 80,
                  color: Colors.grey.shade300,
                  child: video.coverUrl.isNotEmpty
                      ? Image.network(
                          video.coverUrl,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => const Icon(Icons.video_file),
                        )
                      : const Icon(Icons.video_file),
                ),
              ),
              const SizedBox(width: 12),
              // 信息
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      Formatters.truncateText(video.title, 40),
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      video.author,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    // 文件大小（可点击查看详情）
                    GestureDetector(
                      onTap: () {
                        showDialog(
                          context: context,
                          builder: (_) => FileDetailPopup(video: video),
                        );
                      },
                      child: Text(
                        Formatters.formatFileSize(video.fileSize),
                        style: TextStyle(
                          fontSize: 12,
                          color: Theme.of(context).primaryColor,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              // 更多操作
              PopupMenuButton<String>(
                onSelected: (value) async {
                  switch (value) {
                    case 'rename':
                      _showRenameDialog(video);
                      break;
                    case 'share':
                      // TODO: 实现分享
                      break;
                    case 'delete':
                      _confirmDelete(video);
                      break;
                  }
                },
                itemBuilder: (context) => [
                  const PopupMenuItem(value: 'rename', child: Text('重命名')),
                  const PopupMenuItem(value: 'share', child: Text('分享')),
                  const PopupMenuItem(value: 'delete', child: Text('删除')),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showRenameDialog(VideoModel video) {
    final controller = TextEditingController(text: video.title);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('重命名'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(hintText: '输入新名称'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('取消'),
          ),
          ElevatedButton(
            onPressed: () async {
              final newName = controller.text.trim();
              if (newName.isNotEmpty) {
                await context.read<VideoProvider>().updateVideo(
                  video.copyWith(title: newName),
                );
              }
              Navigator.pop(context);
            },
            child: const Text('确定'),
          ),
        ],
      ),
    );
  }

  void _confirmDelete(VideoModel video) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('确认删除'),
        content: const Text('确定要删除这个视频吗？'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('取消'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (video.localPath != null) {
                await DownloadService.deleteDownloadedFile(video.localPath!);
              }
              if (video.id != null) {
                await context.read<VideoProvider>().deleteVideo(video.id!);
              }
              Navigator.pop(context);
            },
            child: const Text('删除'),
          ),
        ],
      ),
    );
  }
}
