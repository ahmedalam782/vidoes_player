import 'package:flutter/material.dart';

import 'src/youtube_player/utils/player_utils.dart';
import 'src/youtube_player/youtube_video_player.dart';
import 'src/normal_video_player/model/video_config.dart';
import 'src/normal_video_player/normal_video_player.dart';

export 'src/normal_video_player/adaptive_controls.dart'
    show AdaptiveControlsBuilder, SubtitleBuilder;
export 'src/normal_video_player/model/video_config.dart';
export 'src/platform_init.dart';
export 'src/youtube_player/models/player_config.dart';

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
        viewerCount: widget.config.viewerCount,
        isLive: widget.config.isLive,
      );
    }

    // For normal videos, use the NormalVideoPlayer
    return NormalVideoPlayer(
      videoSource: widget.config.videoUrl,
      isFile: widget.config.isFile,
      videoBytes: widget.config.videoBytes,
      qualities: widget.config.qualities,
      initialQuality: widget.config.initialQuality,
      subtitles: widget.config.subtitles,
      initialSubtitle: widget.config.initialSubtitle,
      viewerCount: widget.config.viewerCount,
      styling: widget.config.styling,
      messages: widget.config.messages,
      visibility: widget.config.visibility,
      playback: widget.config.playback,
      controlsBuilder: widget.config.controlsBuilder,
      subtitleBuilder: widget.config.subtitleBuilder,
      onAnalyticsEvent: widget.config.onAnalyticsEvent,
    );
  }
}
