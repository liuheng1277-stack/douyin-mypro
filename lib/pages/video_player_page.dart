import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:video_player/video_player.dart';
import '../models/video_model.dart';
import '../providers/theme_provider.dart';
import '../providers/video_provider.dart';
import '../services/download_service.dart';
import '../utils/formatters.dart';
import '../widgets/caption_panel.dart';
import '../widgets/speed_menu.dart';

class VideoPlayerPage extends StatefulWidget {
  final VideoModel video;

  const VideoPlayerPage({super.key, required this.video});

  @override
  State<VideoPlayerPage> createState() => _VideoPlayerPageState();
}

class _VideoPlayerPageState extends State<VideoPlayerPage> {
  VideoPlayerController? _controller;
  bool _isInitialized = false;
  bool _showControls = true;
  bool _isPlaying = false;
  double _currentSpeed = 1.0;
  bool _showCaptionPanel = false;
  bool _showSpeedMenu = false;
  Timer? _controlsTimer;

  // 手势相关
  double _volume = 1.0;
  double _brightness = 1.0;
  bool _isDragging = false;
  double _dragStartX = 0;
  double _dragStartY = 0;

  @override
  void initState() {
    super.initState();
    _initVideoPlayer();
  }

  Future<void> _initVideoPlayer() async {
    final videoUrl = widget.video.localPath ?? widget.video.videoUrl;
    if (videoUrl == null || videoUrl.isEmpty) {
      return;
    }

    try {
      if (videoUrl.startsWith('http')) {
        _controller = VideoPlayerController.networkUrl(Uri.parse(videoUrl));
      } else {
        _controller = VideoPlayerController.asset(videoUrl);
      }

      await _controller!.initialize();
      await _controller!.setLooping(true);
      await _controller!.play();

      setState(() {
        _isInitialized = true;
        _isPlaying = true;
      });

      _controller!.addListener(_onVideoUpdate);
    } catch (e) {
      debugPrint('Video init error: $e');
    }
  }

  void _onVideoUpdate() {
    if (mounted) {
      setState(() {});
    }
  }

  @override
  void dispose() {
    _controlsTimer?.cancel();
    _controller?.removeListener(_onVideoUpdate);
    _controller?.dispose();
    super.dispose();
  }

  void _toggleControls() {
    setState(() => _showControls = !_showControls);
    if (_showControls) {
      _startControlsTimer();
    }
  }

  void _startControlsTimer() {
    _controlsTimer?.cancel();
    _controlsTimer = Timer(const Duration(seconds: 3), () {
      if (mounted) {
        setState(() => _showControls = false);
      }
    });
  }

  void _togglePlay() {
    if (_controller == null) return;
    if (_controller!.value.isPlaying) {
      _controller!.pause();
      setState(() => _isPlaying = false);
    } else {
      _controller!.play();
      setState(() => _isPlaying = true);
    }
    _startControlsTimer();
  }

  void _seekForward() {
    if (_controller == null) return;
    final newPosition = _controller!.value.position + const Duration(seconds: 10);
    _controller!.seekTo(newPosition);
    _startControlsTimer();
  }

  void _seekBackward() {
    if (_controller == null) return;
    final newPosition = _controller!.value.position - const Duration(seconds: 10);
    _controller!.seekTo(newPosition);
    _startControlsTimer();
  }

  void _changeSpeed(double speed) {
    if (_controller == null) return;
    _controller!.setPlaybackSpeed(speed);
    setState(() => _currentSpeed = speed);
  }

  Future<void> _downloadVideo() async {
    if (widget.video.videoUrl == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('无可下载的视频链接')),
      );
      return;
    }

    try {
      final task = await DownloadService.startDownload(
        videoId: widget.video.videoId,
        url: widget.video.videoUrl!,
        fileName: '${widget.video.author}_${widget.video.videoId}.mp4',
      );

      if (task.status == 2) {
        await context.read<VideoProvider>().updateDownloadStatus(
          widget.video.videoId,
          2,
          localPath: task.localPath,
        );
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('下载完成')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('下载失败: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        fit: StackFit.expand,
        children: [
          // 视频播放器
          if (_isInitialized && _controller != null)
            GestureDetector(
              onTap: _toggleControls,
              onDoubleTapDown: (details) {
                final screenWidth = MediaQuery.of(context).size.width;
                if (details.globalPosition.dx < screenWidth / 2) {
                  _seekBackward();
                } else {
                  _seekForward();
                }
              },
              onLongPress: () {
                setState(() => _showSpeedMenu = true);
              },
              child: AspectRatio(
                aspectRatio: _controller!.value.aspectRatio,
                child: VideoPlayer(_controller!),
              ),
            )
          else
            const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(color: Colors.white),
                  SizedBox(height: 16),
                  Text('加载中...', style: TextStyle(color: Colors.white)),
                ],
              ),
            ),

          // 文案显示（左下角，抖音风格）
          if (widget.video.description != null && widget.video.description!.isNotEmpty)
            Positioned(
              left: 16,
              right: 80,
              bottom: 100,
              child: GestureDetector(
                onTap: () => setState(() => _showCaptionPanel = true),
                onLongPress: () {
                  Clipboard.setData(ClipboardData(text: widget.video.description!));
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('文案已复制')),
                  );
                },
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.bottomCenter,
                      end: Alignment.topCenter,
                      colors: [
                        Colors.black.withOpacity(0.7),
                        Colors.transparent,
                      ],
                    ),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.video.author,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      _buildCaptionText(widget.video.description!),
                    ],
                  ),
                ),
              ),
            ),

          // 顶部控制栏
          if (_showControls)
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 40),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Colors.black.withOpacity(0.6), Colors.transparent],
                  ),
                ),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back, color: Colors.white),
                      onPressed: () => Navigator.pop(context),
                    ),
                    Expanded(
                      child: Text(
                        Formatters.truncateText(widget.video.title, 20),
                        style: const TextStyle(color: Colors.white, fontSize: 16),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.download, color: Colors.white),
                      onPressed: _downloadVideo,
                    ),
                    PopupMenuButton<String>(
                      icon: const Icon(Icons.more_vert, color: Colors.white),
                      onSelected: (value) {
                        switch (value) {
                          case 'share':
                            // TODO: 分享
                            break;
                          case 'copy_link':
                            Clipboard.setData(ClipboardData(
                              text: 'https://www.douyin.com/video/${widget.video.videoId}',
                            ));
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('链接已复制')),
                            );
                            break;
                        }
                      },
                      itemBuilder: (_) => [
                        const PopupMenuItem(value: 'share', child: Text('分享')),
                        const PopupMenuItem(value: 'copy_link', child: Text('复制链接')),
                      ],
                    ),
                  ],
                ),
              ),
            ),

          // 底部控制栏
          if (_showControls && _controller != null)
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.bottomCenter,
                    end: Alignment.topCenter,
                    colors: [Colors.black.withOpacity(0.7), Colors.transparent],
                  ),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // 进度条
                    VideoProgressIndicator(
                      _controller!,
                      allowScrubbing: true,
                      colors: const VideoProgressColors(
                        playedColor: Colors.white,
                        bufferedColor: Colors.white54,
                        backgroundColor: Colors.white24,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Text(
                          Formatters.formatDuration(_controller!.value.position.inSeconds),
                          style: const TextStyle(color: Colors.white, fontSize: 12),
                        ),
                        const Spacer(),
                        Text(
                          Formatters.formatDuration(_controller!.value.duration.inSeconds),
                          style: const TextStyle(color: Colors.white, fontSize: 12),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    // 播放控制按钮
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.replay_10, color: Colors.white, size: 32),
                          onPressed: _seekBackward,
                        ),
                        const SizedBox(width: 20),
                        IconButton(
                          icon: Icon(
                            _isPlaying ? Icons.pause_circle_filled : Icons.play_circle_filled,
                            color: Colors.white,
                            size: 56,
                          ),
                          onPressed: _togglePlay,
                        ),
                        const SizedBox(width: 20),
                        IconButton(
                          icon: const Icon(Icons.forward_10, color: Colors.white, size: 32),
                          onPressed: _seekForward,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

          // 文案详情面板
          if (_showCaptionPanel)
            CaptionPanel(
              caption: widget.video.description ?? '',
              onClose: () => setState(() => _showCaptionPanel = false),
            ),

          // 倍速菜单
          if (_showSpeedMenu)
            SpeedMenu(
              currentSpeed: _currentSpeed,
              onSpeedChanged: _changeSpeed,
              onClose: () => setState(() => _showSpeedMenu = false),
            ),
        ],
      ),
    );
  }

  Widget _buildCaptionText(String text) {
    // 抖音风格：默认显示1-2行，超出显示"...展开"
    const maxLines = 2;
    final textSpan = TextSpan(
      text: text,
      style: const TextStyle(color: Colors.white, fontSize: 13, height: 1.5),
    );

    return LayoutBuilder(
      builder: (context, constraints) {
        final painter = TextPainter(
          text: textSpan,
          maxLines: maxLines,
          textDirection: TextDirection.ltr,
        );
        painter.layout(maxWidth: constraints.maxWidth);

        if (painter.didExceedMaxLines) {
          // 超出，显示展开按钮
          return RichText(
            maxLines: maxLines,
            overflow: TextOverflow.ellipsis,
            text: TextSpan(
              children: [
                TextSpan(
                  text: text,
                  style: const TextStyle(color: Colors.white, fontSize: 13, height: 1.5),
                ),
                const TextSpan(
                  text: '...展开',
                  style: TextStyle(color: Colors.blue, fontSize: 13),
                ),
              ],
            ),
          );
        }

        return Text(
          text,
          style: const TextStyle(color: Colors.white, fontSize: 13, height: 1.5),
          maxLines: maxLines,
        );
      },
    );
  }
}
