import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:chewie/chewie.dart';
import '../models/lesson.dart';
import '../services/progress_service.dart';
import '../providers/auth_provider.dart';
import 'package:provider/provider.dart';

class CustomVideoPlayer extends StatefulWidget {
  final Lesson lesson;
  final bool autoPlay;
  final VoidCallback? onProgressUpdate;

  const CustomVideoPlayer({
    super.key,
    required this.lesson,
    this.autoPlay = false,
    this.onProgressUpdate,
  });

  @override
  State<CustomVideoPlayer> createState() => _CustomVideoPlayerState();
}

class _CustomVideoPlayerState extends State<CustomVideoPlayer> {
  VideoPlayerController? _videoPlayerController;
  ChewieController? _chewieController;
  bool _isInitialized = false;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _initializeVideo();
  }

  Future<void> _initializeVideo() async {
    try {
      setState(() {
        _isLoading = true;
        _error = null;
      });

      // For demo purposes, using a sample video URL
      // In production, use widget.lesson.contentUrl
      const videoUrl =
          'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/BigBuckBunny.mp4';

      _videoPlayerController = VideoPlayerController.networkUrl(
        Uri.parse(videoUrl),
      );

      // Add timeout to prevent hanging
      await _videoPlayerController!.initialize().timeout(
        const Duration(seconds: 10),
        onTimeout: () {
          throw Exception('Video initialization timeout');
        },
      );

      if (mounted) {
        _chewieController = ChewieController(
          videoPlayerController: _videoPlayerController!,
          autoPlay: widget.autoPlay,
          looping: false,
          allowFullScreen: true,
          allowMuting: true,
          showOptions: true,
          showControlsOnInitialize: true,
          materialProgressColors: ChewieProgressColors(
            playedColor: Theme.of(context).colorScheme.primary,
            handleColor: Theme.of(context).colorScheme.primary,
            backgroundColor: Colors.grey.shade300,
            bufferedColor: Colors.grey.shade200,
          ),
          placeholder: Container(
            width: double.infinity,
            height: double.infinity,
            color: Colors.grey.shade900,
            child: const Center(
              child: CircularProgressIndicator(
                color: Colors.white,
              ),
            ),
          ),
          autoInitialize: true,
        );

        // Add progress tracking
        _videoPlayerController!.addListener(_onVideoProgress);

        setState(() {
          _isInitialized = true;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e.toString();
          _isLoading = false;
        });
      }
    }
  }

  void _onVideoProgress() {
    try {
      if (_videoPlayerController != null &&
          _videoPlayerController!.value.isInitialized) {
        final position = _videoPlayerController!.value.position;
        final duration = _videoPlayerController!.value.duration;

        if (duration.inSeconds > 0) {
          final progress = position.inSeconds / duration.inSeconds;
          final watchTime = position.inSeconds;

          // Update progress every 5 seconds or when video ends
          if (watchTime % 5 == 0 || progress >= 1.0) {
            _updateProgress(progress, watchTime);
          }
        }
      }
    } catch (e) {
      debugPrint('Error in video progress tracking: $e');
    }
  }

  Future<void> _updateProgress(double progress, int watchTime) async {
    try {
      final authProvider = context.read<AuthProvider>();
      final userId = authProvider.user?.id ?? 'anonymous';

      await ProgressService.updateLessonProgress(
        lessonId: widget.lesson.id,
        userId: userId,
        progress: progress,
        watchTime: watchTime,
      );

      if (widget.onProgressUpdate != null) {
        widget.onProgressUpdate!();
      }
    } catch (e) {
      debugPrint('Error updating progress: $e');
    }
  }

  @override
  void dispose() {
    try {
      _videoPlayerController?.removeListener(_onVideoProgress);
      _chewieController?.dispose();
      _videoPlayerController?.dispose();
    } catch (e) {
      // Handle disposal errors gracefully
      debugPrint('Error disposing video player: $e');
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Use AspectRatio to maintain proper video dimensions
    return AspectRatio(
      aspectRatio: 16 / 9,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.3),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: _buildVideoContent(),
        ),
      ),
    );
  }

  Widget _buildVideoContent() {
    if (_isLoading) {
      return Container(
        width: double.infinity,
        height: double.infinity,
        color: Colors.grey.shade900,
        child: const Center(
          child: CircularProgressIndicator(
            color: Colors.white,
          ),
        ),
      );
    }

    if (_error != null) {
      return Container(
        width: double.infinity,
        height: double.infinity,
        color: Colors.grey.shade900,
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.error_outline,
                  color: Colors.red,
                  size: 48,
                ),
                const SizedBox(height: 16),
                Text(
                  'Error loading video',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: Colors.white,
                      ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  _error!,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.white70,
                      ),
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: _initializeVideo,
                  child: const Text('Retry'),
                ),
              ],
            ),
          ),
        ),
      );
    }

    if (!_isInitialized || _chewieController == null) {
      return Container(
        width: double.infinity,
        height: double.infinity,
        color: Colors.grey.shade900,
        child: const Center(
          child: CircularProgressIndicator(
            color: Colors.white,
          ),
        ),
      );
    }

    return Chewie(controller: _chewieController!);
  }
}

class VideoPlayerControls extends StatelessWidget {
  final VideoPlayerController controller;
  final VoidCallback? onPlayPause;
  final VoidCallback? onSeek;
  final bool isPlaying;

  const VideoPlayerControls({
    super.key,
    required this.controller,
    this.onPlayPause,
    this.onSeek,
    this.isPlaying = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 60,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.transparent,
            Colors.black.withOpacity(0.7),
          ],
        ),
      ),
      child: Row(
        children: [
          IconButton(
            onPressed: onPlayPause,
            icon: Icon(
              isPlaying ? Icons.pause : Icons.play_arrow,
              color: Colors.white,
            ),
          ),
          Expanded(
            child: VideoProgressIndicator(
              controller,
              allowScrubbing: true,
              colors: VideoProgressColors(
                playedColor: Theme.of(context).colorScheme.primary,
                bufferedColor: Colors.grey.shade300,
                backgroundColor: Colors.grey.shade600,
              ),
            ),
          ),
          Text(
            _formatDuration(controller.value.position),
            style: const TextStyle(color: Colors.white),
          ),
          const Text(
            ' / ',
            style: TextStyle(color: Colors.white),
          ),
          Text(
            _formatDuration(controller.value.duration),
            style: const TextStyle(color: Colors.white),
          ),
          IconButton(
            onPressed: () {
              // Toggle fullscreen
            },
            icon: const Icon(
              Icons.fullscreen,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return '$minutes:$seconds';
  }
}
