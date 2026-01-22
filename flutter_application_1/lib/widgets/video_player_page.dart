import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/progress_service.dart';
import 'feedback_widget.dart';

class VideoPlayerPage extends StatefulWidget {
  final String videoPath;
  final String title;

  const VideoPlayerPage({
    super.key,
    required this.videoPath,
    required this.title,
  });

  @override
  State<VideoPlayerPage> createState() => _VideoPlayerPageState();
}

class _VideoPlayerPageState extends State<VideoPlayerPage> {
  late VideoPlayerController _controller;
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.asset(widget.videoPath)
      ..initialize().then((_) {
        setState(() {
          _isInitialized = true;
        });
        _controller.play();
        _controller.addListener(() async {
          if (_controller.value.position == _controller.value.duration) {
             final user = FirebaseAuth.instance.currentUser;
             if (user != null) {
               try {
                 await ProgressService().saveProgress(
                   user.uid,
                   widget.title,
                   {'type': 'video_complete'},
                 );
               } catch (e) {
                 print("Error saving video progress: $e");
               }
             }
          }
        });
      });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Text(widget.title, style: const TextStyle(color: Colors.white)),
        backgroundColor: const Color(0xFF1A1F38),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Video Player Section
            SizedBox(
              height: 300,
              child: Center(
                child: _isInitialized
                    ? AspectRatio(
                        aspectRatio: _controller.value.aspectRatio,
                        child: Stack(
                          alignment: Alignment.bottomCenter,
                          children: [
                            VideoPlayer(_controller),
                            VideoProgressIndicator(_controller, allowScrubbing: true),
                            Positioned(
                              bottom: 60,
                              child: FloatingActionButton(
                                backgroundColor: Colors.redAccent,
                                onPressed: () {
                                  setState(() {
                                    _controller.value.isPlaying
                                        ? _controller.pause()
                                        : _controller.play();
                                  });
                                },
                                child: Icon(
                                  _controller.value.isPlaying
                                      ? Icons.pause
                                      : Icons.play_arrow,
                                ),
                              ),
                            ),
                          ],
                        ),
                      )
                    : const CircularProgressIndicator(color: Colors.redAccent),
              ),
            ),
            
            // Feedback Section
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Divider(color: Colors.white24, thickness: 1),
                  const SizedBox(height: 24),
                  const Text(
                    'Feedback & Reviews',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  FeedbackWidget(
                    moduleType: 'video',
                    moduleName: widget.title,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
