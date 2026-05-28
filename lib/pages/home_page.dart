import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/video_model.dart';
import '../providers/theme_provider.dart';
import '../providers/video_provider.dart';
import '../services/video_parser_service.dart';
import '../services/sync_service.dart';
import '../services/database_service.dart';
import '../utils/constants.dart';
import '../widgets/glass_container.dart';
import '../widgets/video_card.dart';
import 'video_player_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final TextEditingController _urlController = TextEditingController();
  bool _isParsing = false;

  @override
  void dispose() {
    _urlController.dispose();
    super.dispose();
  }

  Future<void> _parseVideo() async {
    final url = _urlController.text.trim();
    if (url.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('请输入视频链接')),
      );
      return;
    }

    setState(() => _isParsing = true);

    try {
      final result = await VideoParserService.parseVideo(url);

      if (result.success && result.videoUrl != null) {
        final videoId = VideoParserService.extractVideoId(url) ?? 'manual_${DateTime.now().millisecondsSinceEpoch}';
        final video = VideoModel(
          videoId: videoId,
          title: result.title ?? '未命名视频',
          author: result.author ?? '未知作者',
          authorId: 'unknown',
          coverUrl: result.coverUrl ?? '',
          videoUrl: result.videoUrl,
          syncTime: DateTime.now().millisecondsSinceEpoch ~/ 1000,
          description: result.description,
        );

        await context.read<VideoProvider>().addVideo(video);

        _urlController.clear();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('视频解析成功')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(result.error ?? '解析失败')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('解析出错: $e')),
      );
    } finally {
      setState(() => _isParsing = false);
    }
  }

  Future<void> _syncFavorites() async {
    final cookies = await DatabaseService.getSetting(AppConstants.keyDouyinCookies);
    if (cookies == null || cookies.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('请先登录抖音')),
      );
      return;
    }

    try {
      final videos = await SyncService.syncFavorites(cookies: cookies);
      await context.read<VideoProvider>().syncVideos(videos);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('同步完成，新增 ${videos.length} 个视频')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('同步失败: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = context.watch<ThemeProvider>();
    final videoProvider = context.watch<VideoProvider>();

    return themeProvider.buildBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: themeProvider.primaryColor,
          title: const Text(AppConstants.appName),
          actions: [
            IconButton(
              icon: const Icon(Icons.sync),
              onPressed: _syncFavorites,
              tooltip: '同步收藏',
            ),
          ],
        ),
        body: Column(
          children: [
            // 输入框区域（毛玻璃效果）
            Padding(
              padding: const EdgeInsets.all(16),
              child: GlassContainer(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                borderRadius: BorderRadius.circular(12),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _urlController,
                        decoration: const InputDecoration(
                          hintText: '粘贴视频链接',
                          border: InputBorder.none,
                          hintStyle: TextStyle(color: Colors.black54),
                        ),
                        style: const TextStyle(color: Colors.black87),
                      ),
                    ),
                    _isParsing
                        ? const SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : ElevatedButton(
                            onPressed: _parseVideo,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: themeProvider.primaryColor,
                              padding: const EdgeInsets.symmetric(horizontal: 20),
                            ),
                            child: const Text('解析'),
                          ),
                  ],
                ),
              ),
            ),

            // 视频推荐列表
            Expanded(
              child: videoProvider.isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : videoProvider.videos.isEmpty
                      ? const Center(
                          child: Text(
                            '暂无视频\n请粘贴链接解析或同步收藏',
                            textAlign: TextAlign.center,
                            style: TextStyle(color: Colors.black54),
                          ),
                        )
                      : RefreshIndicator(
                          onRefresh: () => videoProvider.loadVideos(),
                          child: GridView.builder(
                            padding: const EdgeInsets.all(12),
                            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              childAspectRatio: 0.6,
                              crossAxisSpacing: 10,
                              mainAxisSpacing: 10,
                            ),
                            itemCount: videoProvider.videos.length,
                            itemBuilder: (context, index) {
                              final video = videoProvider.videos[index];
                              return VideoCard(
                                video: video,
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => VideoPlayerPage(video: video),
                                    ),
                                  );
                                },
                              );
                            },
                          ),
                        ),
            ),
          ],
        ),
      ),
    );
  }
}
