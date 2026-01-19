import 'package:flutter/material.dart';

import '../youtube_player/utils/player_utils.dart';
import '../youtube_player/youtube_video_player.dart';
import 'model/video_config.dart';
import 'normal_video_player.dart';

/// Adaptive video player that detects and plays both YouTube and normal videos
class AdaptiveVideoPlayer extends StatefulWidget {
  final VideoConfig config;

  const AdaptiveVideoPlayer({super.key, required this.config});

  @override
  State<AdaptiveVideoPlayer> createState() => _AdaptiveVideoPlayerState();
}

class _AdaptiveVideoPlayerState extends State<AdaptiveVideoPlayer> {
  bool _isYouTubeVideo = false;
  String? _youtubeVideoId;

  @override
  void initState() {
    super.initState();
    _detectVideoType();
  }

  /// Detects if the video URL is a YouTube video
  void _detectVideoType() {
    final videoId = PlayerUtils.extractVideoId(widget.config.videoUrl);
    if (videoId != null && videoId.isNotEmpty) {
      setState(() {
        _isYouTubeVideo = true;
        _youtubeVideoId = videoId;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isYouTubeVideo && _youtubeVideoId != null) {
      // Use the local YouTubeVideoPlayer for YouTube videos
      return YouTubeVideoPlayer(
        videoSource: _youtubeVideoId!,
        config: widget.config.playerConfig,
      );
    }

    // For normal videos, use the NormalVideoPlayer
    return NormalVideoPlayer(
      videoSource: widget.config.videoUrl,
      isFile: widget.config.isFile,
      videoBytes: widget.config.videoBytes,
      styling: widget.config.styling,
      messages: widget.config.messages,
      visibility: widget.config.visibility,
      playback: widget.config.playback,
    );
  }
}
