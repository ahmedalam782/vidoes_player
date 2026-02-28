import 'dart:typed_data';

import '../../youtube_player/models/player_config.dart';
import '../adaptive_controls.dart';

/// Represents a video stream quality/resolution (e.g. 1080p, 720p, Auto)
class VideoQuality {
  final String title;
  final String url;

  /// Whether this specific quality/source is a live stream
  final bool isLive;

  const VideoQuality({
    required this.title,
    required this.url,
    this.isLive = false,
  });
}

/// Represents a subtitle or closed caption track
class SubtitleTrack {
  final String id;
  final String title;

  /// The subtitle raw content (srt or vtt format)
  final String? content;

  /// A callback to fetch the content if not provided upfront
  final Future<String> Function()? fetcher;

  const SubtitleTrack({
    required this.id,
    required this.title,
    this.content,
    this.fetcher,
  });
}

/// Configuration model for the adaptive video player
class VideoConfig {
  /// Video source URL
  final String videoUrl;

  /// Whether the video is a local file
  final bool isFile;

  /// Whether the video is a live stream (disables seek controls and shows LIVE indicator)
  final bool isLive;

  /// Video bytes for in-memory videos
  final Uint8List? videoBytes;

  /// External list of qualities / sources for resolution picker
  final List<VideoQuality>? qualities;

  /// Initial quality if qualities list is provided
  final VideoQuality? initialQuality;

  /// External list of subtitle tracks
  final List<SubtitleTrack>? subtitles;

  /// Initial subtitle track to activate
  final SubtitleTrack? initialSubtitle;

  /// Custom ui builder for rendering over the video
  final AdaptiveControlsBuilder? controlsBuilder;

  /// Custom builder for subtitles layer
  final SubtitleBuilder? subtitleBuilder;

  /// Optional viewer count to display when stream is live
  final String? viewerCount;

  /// Analytics hook for external tracking of video events
  final void Function(String event, Map<String, dynamic> data)?
      onAnalyticsEvent;

  /// Complete player configuration using YouTube models
  final YouTubePlayerConfig playerConfig;

  const VideoConfig({
    required this.videoUrl,
    this.isFile = false,
    this.isLive = false,
    this.videoBytes,
    this.qualities,
    this.initialQuality,
    this.subtitles,
    this.initialSubtitle,
    this.controlsBuilder,
    this.subtitleBuilder,
    this.viewerCount,
    this.onAnalyticsEvent,
    this.playerConfig = const YouTubePlayerConfig(),
  });

  // Convenience getters
  PlayerStyleConfig get styling => playerConfig.style;
  PlayerTextConfig get messages => playerConfig.text;
  PlayerVisibilityConfig get visibility => playerConfig.visibility;
  PlayerPlaybackConfig get playback => playerConfig.playback;
}
