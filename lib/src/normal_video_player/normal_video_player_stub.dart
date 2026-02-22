import 'dart:typed_data';
import 'package:flutter/material.dart';
import '../youtube_player/models/player_config.dart';

/// Stub for NormalVideoPlayer — used on platforms where video_player is not available.
class NormalVideoPlayer extends StatelessWidget {
  final String videoSource;
  final bool isFile;
  final Uint8List? videoBytes;
  final PlayerStyleConfig? styling;
  final PlayerTextConfig? messages;
  final PlayerVisibilityConfig? visibility;
  final PlayerPlaybackConfig? playback;

  const NormalVideoPlayer({
    super.key,
    required this.videoSource,
    this.isFile = false,
    this.videoBytes,
    this.styling,
    this.messages,
    this.visibility,
    this.playback,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: styling?.backgroundColor ?? Colors.black,
      child: const AspectRatio(
        aspectRatio: 16 / 9,
        child: Center(
          child: Text(
            'Video playback is not supported on this platform.',
            style: TextStyle(color: Colors.white),
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }

  // Stub public methods
  void play() {}
  void pause() {}
  void seekTo(Duration position) {}
  Duration get currentPosition => Duration.zero;
  Duration get duration => Duration.zero;
  bool get isPlaying => false;
  void setPlaybackSpeed(double speed) {}
}
