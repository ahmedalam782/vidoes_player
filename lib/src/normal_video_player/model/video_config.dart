import 'dart:typed_data';

import '../../youtube_player/models/player_config.dart';

/// Configuration model for the adaptive video player
class VideoConfig {
  /// Video source URL
  final String videoUrl;

  /// Whether the video is a local file
  final bool isFile;

  /// Video bytes for in-memory videos
  final Uint8List? videoBytes;

  /// Complete player configuration using YouTube models
  final YouTubePlayerConfig playerConfig;

  const VideoConfig({
    required this.videoUrl,
    this.isFile = false,
    this.videoBytes,
    this.playerConfig = const YouTubePlayerConfig(),
  });

  // Convenience getters
  PlayerStyleConfig get styling => playerConfig.style;
  PlayerTextConfig get messages => playerConfig.text;
  PlayerVisibilityConfig get visibility => playerConfig.visibility;
  PlayerPlaybackConfig get playback => playerConfig.playback;
}
