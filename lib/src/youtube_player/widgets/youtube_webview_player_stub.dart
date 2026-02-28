import 'package:flutter/material.dart';
import '../models/player_config.dart';

/// Stub for YouTubeWebViewPlayer — used on Web where dart:io is not available.
/// On Web, YouTube is handled via HTML iframe, so this widget is never actually used.
class YouTubeWebViewPlayer extends StatefulWidget {
  final String videoId;
  final YouTubePlayerConfig config;
  final VoidCallback? onEnded;
  final VoidCallback? onReady;
  final VoidCallback? onEnterFullscreen;
  final VoidCallback? onExitFullscreen;

  const YouTubeWebViewPlayer({
    super.key,
    required this.videoId,
    required this.config,
    this.onEnded,
    this.onReady,
    this.onEnterFullscreen,
    this.onExitFullscreen,
  });

  @override
  State<YouTubeWebViewPlayer> createState() => YouTubeWebViewPlayerState();
}

class YouTubeWebViewPlayerState extends State<YouTubeWebViewPlayer> {
  @override
  Widget build(BuildContext context) {
    return const SizedBox.shrink();
  }

  void play() {}
  void pause() {}
  void seekTo(int seconds) {}
  void mute() {}
  void unMute() {}
  void exitFullscreen() {}
}
