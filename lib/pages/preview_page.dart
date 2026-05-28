import 'package:flutter/material.dart';
import '../models/video_model.dart';
import 'video_player_page.dart';

class PreviewPage extends StatefulWidget {
  final List<VideoModel> videos;

  const PreviewPage({super.key, required this.videos});

  @override
  State<PreviewPage> createState() => _PreviewPageState();
}

class _PreviewPageState extends State<PreviewPage> {
  final PageController _pageController = PageController();
  int _currentIndex = 0;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: PageView.builder(
        controller: _pageController,
        scrollDirection: Axis.vertical,
        itemCount: widget.videos.length,
        onPageChanged: (index) => setState(() => _currentIndex = index),
        itemBuilder: (context, index) {
          final video = widget.videos[index];
          return VideoPlayerPage(video: video);
        },
      ),
    );
  }
}
