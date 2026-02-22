import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:chewie/chewie.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:video_player/video_player.dart';

import '../youtube_player/models/player_config.dart';

class NormalVideoPlayer extends StatefulWidget {
  final String videoSource;
  final bool isFile;
  final Uint8List? videoBytes;

  /// Styling configuration for the video player
  final PlayerStyleConfig? styling;

  /// Messages configuration for the video player
  final PlayerTextConfig? messages;

  /// Visibility configuration for the video player
  final PlayerVisibilityConfig? visibility;

  /// Playback configuration for the video player
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
  NormalVideoPlayerState createState() => NormalVideoPlayerState();
}

class NormalVideoPlayerState extends State<NormalVideoPlayer> {
  VideoPlayerController? _videoPlayerController;
  ChewieController? _chewieController;
  bool _hasError = false;
  String _errorMessage = '';
  late final bool _hasInMemoryData;
  late final bool _useFileController;
  late final String _effectiveSource;

  @override
  void initState() {
    super.initState();
    _hasInMemoryData = widget.videoBytes != null;
    _effectiveSource = _hasInMemoryData
        ? 'data:video/mp4;base64,${base64Encode(widget.videoBytes!)}'
        : widget.isFile
            ? widget.videoSource
            : widget.videoSource;
    _useFileController = widget.isFile && !_hasInMemoryData;
    _initializeVideo();
  }

  /// Validates if the URL is a valid video source
  bool _isValidVideoUrl(String url) {
    if (url.isEmpty) return false;

    // Check if it's a data URL (base64)
    if (url.startsWith('data:')) return true;

    // Check if it's a valid file path
    if (_useFileController) {
      final file = File(url);
      return file.existsSync();
    }

    // Check if it's a valid URL format
    try {
      final uri = Uri.parse(url);
      if (!uri.hasScheme || (uri.scheme != 'http' && uri.scheme != 'https')) {
        return false;
      }

      // Check for common video file extensions
      final path = uri.path.toLowerCase();
      final videoExtensions = [
        '.mp4',
        '.mov',
        '.avi',
        '.mkv',
        '.webm',
        '.m4v',
        '.3gp',
        '.flv',
        '.wmv',
        '.m9v',
      ];

      // If URL has extension, check if it's a video extension
      if (path.contains('.')) {
        return videoExtensions.any((ext) => path.endsWith(ext));
      }

      // If no extension, assume it might be a streaming URL
      return true;
    } catch (e) {
      log('URL validation error: $e');
      return false;
    }
  }

  Future<void> _initializeVideo() async {
    try {
      // Validate URL first
      if (!_isValidVideoUrl(_effectiveSource)) {
        if (mounted) {
          setState(() {
            _hasError = true;
            _errorMessage = widget.messages?.videoLoadFailedText ?? '';
          });
        } else {
          _hasError = true;
          _errorMessage = widget.messages?.videoLoadFailedText ?? '';
        }
        return;
      }

      final bool isNetworkSource = !_useFileController;
      if (isNetworkSource &&
          !_effectiveSource.startsWith('data:') &&
          _effectiveSource.startsWith('http://')) {
        log(
          'Warning: Using HTTP URL for video. Consider using HTTPS for production.',
        );
      }

      log(
        _hasInMemoryData
            ? 'Playing in-memory video source'
            : 'Playing video from: $_effectiveSource',
      );

      _videoPlayerController = _useFileController
          ? VideoPlayerController.file(
              File(_effectiveSource),
              videoPlayerOptions: VideoPlayerOptions(
                mixWithOthers: true,
                allowBackgroundPlayback: true,
              ),
            )
          : VideoPlayerController.networkUrl(
              Uri.parse(_effectiveSource),
              videoPlayerOptions: VideoPlayerOptions(
                mixWithOthers: true,
                allowBackgroundPlayback: true,
              ),
            );

      await _videoPlayerController!.initialize();
      if (mounted) {
        setState(() {
          _chewieController = ChewieController(
            videoPlayerController: _videoPlayerController!,
            autoPlay: widget.playback?.autoPlay ?? false,
            looping: widget.playback?.loop ?? false,
            showControls: widget.visibility?.showControls ?? true,
            allowFullScreen: widget.visibility?.showFullscreenButton ?? true,
            allowedScreenSleep: false,
            showControlsOnInitialize: true,
            controlsSafeAreaMinimum: EdgeInsets.zero,
            hideControlsTimer: const Duration(seconds: 3),
            deviceOrientationsAfterFullScreen: [
              DeviceOrientation.portraitUp,
              DeviceOrientation.portraitDown,
            ],
            deviceOrientationsOnEnterFullScreen: [
              DeviceOrientation.landscapeLeft,
              DeviceOrientation.landscapeRight,
            ],
            systemOverlaysAfterFullScreen: [
              SystemUiOverlay.top,
              SystemUiOverlay.bottom,
            ],
            materialProgressColors: ChewieProgressColors(
              playedColor: widget.styling?.progressBarPlayedColor ??
                  const Color.fromRGBO(255, 0, 0, 0.7),
              handleColor: widget.styling?.progressBarHandleColor ??
                  const Color.fromRGBO(200, 200, 200, 1.0),
              bufferedColor: widget.styling?.progressBarPlayedColor.withValues(
                    alpha: 0.3,
                  ) ??
                  const Color.fromRGBO(30, 30, 200, 0.2),
              backgroundColor: Colors.white.withValues(alpha: 0.3),
            ),
            routePageBuilder:
                (context, animation, secondaryAnimation, provider) {
              return Directionality(
                textDirection: TextDirection.ltr,
                child: AnimatedBuilder(
                  animation: animation,
                  builder: (context, child) {
                    return Scaffold(
                      backgroundColor: Colors.black,
                      body: Center(child: provider),
                    );
                  },
                ),
              );
            },
            placeholder: Center(
              child: CircularProgressIndicator(
                color: widget.styling?.loadingIndicatorColor,
                strokeCap: StrokeCap.round,
              ),
            ),
            errorBuilder: (context, errorMessage) => Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.error_outline,
                    color: widget.styling?.errorIconColor,
                    size: 48,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    widget.messages?.videoUnavailableText ??
                        'Video Unavailable',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: widget.styling?.textColor,
                    ),
                  ),
                ],
              ),
            ),
          );
        });
      }
    } catch (e) {
      log('Video initialization error: $e');
      if (mounted) {
        setState(() {
          _hasError = true;
          if (e is PlatformException) {
            final errorMsg = e.message ?? e.toString();
            if (errorMsg.contains('MediaCodec') ||
                errorMsg.contains('ExoPlaybackException')) {
              _errorMessage = widget.messages?.videoNotCompatibleText ??
                  'Video Not Compatible';
            } else {
              _errorMessage =
                  widget.messages?.videoCannotBeLoadedSecurityPolicyText ??
                      'Video Cannot Be Loaded Security Policy';
            }
          } else {
            _errorMessage =
                widget.messages?.videoLoadFailedText ?? 'Video Load Failed';
          }
        });
      }
    }
  }

  @override
  void dispose() {
    _videoPlayerController?.dispose();
    _chewieController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_hasError) {
      return Container(
        decoration: BoxDecoration(
          color: widget.styling?.backgroundColor ?? Colors.black,
          borderRadius: BorderRadius.circular(8),
        ),
        child: AspectRatio(
          aspectRatio: 16 / 9,
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.error_outline,
                    color: widget.styling?.errorIconColor ??
                        const Color.fromRGBO(255, 0, 0, 0.7),
                    size: 48,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _errorMessage,
                    style: TextStyle(
                      color: widget.styling?.textColor ??
                          const Color.fromRGBO(255, 0, 0, 0.7),
                      fontSize: 14,
                    ),
                    textAlign: TextAlign.center,
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    }

    if (_chewieController == null) {
      return Container(
        decoration: BoxDecoration(
          color: widget.styling?.backgroundColor ?? Colors.black,
          borderRadius: BorderRadius.circular(8),
        ),
        child: AspectRatio(
          aspectRatio: 16 / 9,
          child: Center(
            child: CircularProgressIndicator(
              color: widget.styling?.loadingIndicatorColor ??
                  const Color.fromRGBO(255, 0, 0, 0.7),
              strokeCap: StrokeCap.round,
            ),
          ),
        ),
      );
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: Directionality(
        textDirection: TextDirection.ltr,
        child: AspectRatio(
          aspectRatio: _videoPlayerController!.value.isInitialized
              ? _videoPlayerController!.value.aspectRatio
              : 16 / 9,
          child: Chewie(controller: _chewieController!),
        ),
      ),
    );
  }

  // Public methods
  void play() => _videoPlayerController?.play();
  void pause() => _videoPlayerController?.pause();
  void seekTo(Duration position) => _videoPlayerController?.seekTo(position);
  Duration get currentPosition =>
      _videoPlayerController?.value.position ?? Duration.zero;
  Duration get duration =>
      _videoPlayerController?.value.duration ?? Duration.zero;
  bool get isPlaying => _videoPlayerController?.value.isPlaying ?? false;
  void setPlaybackSpeed(double speed) =>
      _videoPlayerController?.setPlaybackSpeed(speed);
}
