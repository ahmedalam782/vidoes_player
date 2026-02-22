import 'package:flutter/material.dart';
import '../models/player_config.dart';

/// Stub for YouTubeWebViewPlayer — used on Web where dart:io is not available.
/// On Web, YouTube is handled via HTML iframe, so this widget is never actually used.
class YouTubeWebViewPlayer extends StatelessWidget {
  final String videoId;
  final YouTubePlayerConfig config;
  final VoidCallback? onEnded;
  final VoidCallback? onReady;

  const YouTubeWebViewPlayer({
    super.key,
    required this.videoId,
    required this.config,
    this.onEnded,
    this.onReady,
  });

  @override
  Widget build(BuildContext context) {
    return const SizedBox.shrink();
  }

  void play() {}
  void pause() {}
  void seekTo(int seconds) {}
  void mute() {}
  void unMute() {}
}
