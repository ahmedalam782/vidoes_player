import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart'
    hide CurrentPosition, RemainingDuration;

import 'widgets/fullscreen_player_page.dart';
import 'utils/player_utils.dart';
import 'utils/youtube_web_export.dart';
import 'models/player_config.dart';
import 'cubit/youtube_player_cubit.dart';
import 'widgets/player_bottom_actions.dart';
import 'widgets/player_controls.dart';
import 'widgets/youtube_webview_player_export.dart';

/// A widget for playing YouTube videos with full YouTube controls
/// Similar to native YouTube app with speed, quality, captions, etc.
///
/// Uses [YouTubePlayerConfig] model for all configuration settings.
/// Uses [YoutubePlayerCubit] for state management between normal and fullscreen modes.
class YouTubeVideoPlayer extends StatefulWidget {
  /// The YouTube video URL or video ID
  final String videoSource;

  /// Complete player configuration
  final YouTubePlayerConfig config;

  /// Callback when the video ends
  final VoidCallback? onEnded;

  const YouTubeVideoPlayer({
    super.key,
    required this.videoSource,
    this.config = const YouTubePlayerConfig(),
    this.onEnded,
  });

  @override
  YouTubeVideoPlayerState createState() => YouTubeVideoPlayerState();
}

class YouTubeVideoPlayerState extends State<YouTubeVideoPlayer> {
  YoutubePlayerController? _controller;
  late YoutubePlayerCubit _cubit;
  bool _hasError = false;
  String _errorMessage = '';
  String? _videoId;
  bool _isControllerDisposed = false;
  bool _isInFullscreen = false;
  Duration? _pendingSeekPosition;
  bool _hasRestoredPosition = false;
  bool _videoEnded = false;
  String? _webIframeId;

  YouTubePlayerConfig get _cfg => widget.config;
  PlayerCubitState get _state => _cubit.state;

  bool get _useDesktopPlayer {
    if (kIsWeb) return false;
    final isDesktopPlatform = defaultTargetPlatform != TargetPlatform.android &&
        defaultTargetPlatform != TargetPlatform.iOS;
    return isDesktopPlatform || _cfg.playback.forceDesktopMode;
  }

  @override
  void initState() {
    super.initState();
    _cubit = YoutubePlayerCubit();
    _cubit.updateSettings(
      autoPlay: _cfg.playback.autoPlay,
      loop: _cfg.playback.loop,
      forceHD: _cfg.playback.forceHD,
      enableCaption: _cfg.playback.enableCaption,
    );
    _cubit.setMuted(_cfg.playback.mute);
    _initializePlayer();
  }

  @override
  void didUpdateWidget(covariant YouTubeVideoPlayer oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.videoSource != widget.videoSource) {
      _disposeController();
      _initializePlayer();
    }
  }

  void _disposeController() {
    if (_controller != null && !_isControllerDisposed) {
      _isControllerDisposed = true;
      PlayerUtils.disposeController(
        _controller,
        onError: (e) => log('Error disposing controller: $e'),
      );
      _controller = null;
    }
  }

  bool get _isControllerSafe =>
      _controller != null && !_isControllerDisposed && mounted;

  void _initializePlayer() {
    try {
      _videoId = PlayerUtils.extractVideoId(widget.videoSource);

      if (_videoId == null || _videoId!.isEmpty) {
        if (mounted) {
          setState(() {
            _hasError = true;
            _errorMessage = _cfg.text.invalidYoutubeUrlText;
          });
        }
        return;
      }

      if (kIsWeb) {
        _webIframeId =
            'youtube-iframe-$_videoId-${DateTime.now().millisecondsSinceEpoch}';
        registerYoutubeWebIframe(_webIframeId!, _videoId!, _state.autoPlay);
        if (mounted) {
          setState(() {
            _isControllerDisposed = false;
          });
        }
        return;
      }

      // On Desktop (or forced), skip creating YoutubePlayerController.
      // We use YouTubeWebViewPlayer (InAppWebView + localhost server) to avoid Error 153.
      if (_useDesktopPlayer) {
        if (mounted) {
          setState(() {
            _isControllerDisposed = false;
          });
        }
        return;
      }

      // On mobile (Android/iOS), use native YoutubePlayerController
      final startAtSeconds = _pendingSeekPosition?.inSeconds ?? 0;

      final controller = YoutubePlayerController(
        initialVideoId: _videoId!,
        flags: PlayerUtils.createPlayerFlags(
          autoPlay: _state.autoPlay,
          mute: _state.isMuted,
          loop: _state.loop,
          forceHD: _state.forceHD,
          enableCaption: _state.enableCaption,
          showControls: _cfg.visibility.showControls,
          startAt: startAtSeconds,
        ),
      );

      controller.addListener(() {
        if (!_isControllerDisposed && mounted) {
          if (PlayerUtils.isReady(controller) &&
              !_hasRestoredPosition &&
              _pendingSeekPosition != null) {
            _hasRestoredPosition = true;
            final targetPosition = _pendingSeekPosition!;
            _pendingSeekPosition = null;
            Future.microtask(() {
              if (!_isControllerDisposed && mounted && _controller != null) {
                PlayerUtils.seekTo(_controller!, targetPosition);
              }
            });
          }

          if (controller.value.playerState == PlayerState.ended) {
            widget.onEnded?.call();

            if (_state.loop && !_isControllerDisposed && mounted) {
              Future.delayed(const Duration(milliseconds: 500), () {
                if (!_isControllerDisposed && mounted && _controller != null) {
                  _videoEnded = false;
                  PlayerUtils.seekTo(_controller!, Duration.zero);
                  PlayerUtils.play(_controller);
                }
              });
            } else {
              if (mounted) {
                setState(() {
                  _videoEnded = true;
                });
              }
            }
          }

          if (controller.value.playerState == PlayerState.playing &&
              _videoEnded) {
            if (mounted) {
              setState(() {
                _videoEnded = false;
              });
            }
          }
        }
      });

      if (mounted) {
        setState(() {
          _controller = controller;
          _isControllerDisposed = false;
        });
      }
    } catch (e) {
      log('YouTube player initialization error: $e');
      if (mounted) {
        setState(() {
          _hasError = true;
          _errorMessage = _cfg.text.videoLoadFailedText;
        });
      }
    }
  }

  Future<void> _openFullScreen() async {
    final controller = _controller;
    if (controller == null || _isControllerDisposed) return;

    _isInFullscreen = true;
    final currentPosition = PlayerUtils.getCurrentPosition(controller);
    final wasPlaying = PlayerUtils.isPlaying(controller);

    PlayerUtils.pause(controller);

    await SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
    await SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);

    if (!mounted) return;

    final result = await Navigator.of(context).push<FullScreenResult>(
      PageRouteBuilder(
        opaque: true,
        pageBuilder: (context, animation, secondaryAnimation) {
          return FullScreenPlayerPage(
            videoId: _videoId!,
            initialPosition: currentPosition,
            startPlaying: wasPlaying,
            cubit: _cubit,
            onEnded: widget.onEnded,
            config: _cfg,
          );
        },
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(opacity: animation, child: child);
        },
      ),
    );

    _isInFullscreen = false;
    await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
    await SystemChrome.setEnabledSystemUIMode(
      SystemUiMode.manual,
      overlays: SystemUiOverlay.values,
    );

    if (result != null &&
        mounted &&
        !_isControllerDisposed &&
        _controller != null) {
      try {
        if (result.videoEnded) {
          widget.onEnded?.call();
          if (result.isMuted != _state.isMuted && _isControllerSafe) {
            _cubit.setMuted(result.isMuted);
          }
          setState(() {
            _videoEnded = true;
          });
          return;
        }

        bool settingsChanged = false;
        if (_state.autoPlay != result.autoPlay) {
          _cubit.setAutoPlay(result.autoPlay);
          settingsChanged = true;
        }
        if (_state.loop != result.loop) {
          _cubit.setLoop(result.loop);
          settingsChanged = true;
        }
        if (_state.forceHD != result.forceHD) {
          _cubit.setForceHD(result.forceHD);
          settingsChanged = true;
        }
        if (_state.enableCaption != result.enableCaption) {
          _cubit.setEnableCaption(result.enableCaption);
          settingsChanged = true;
        }

        if (settingsChanged) {
          await _reloadPlayerWithSettings(targetPosition: result.position);
          if (mounted && !_isControllerDisposed && _controller != null) {
            if (result.isMuted != _state.isMuted) {
              _cubit.setMuted(result.isMuted);
            }
            PlayerUtils.setMute(_controller!, result.isMuted);
            if (result.wasPlaying) {
              _controller!.play();
            }
          }
        } else {
          if (mounted && !_isControllerDisposed && _controller != null) {
            PlayerUtils.pause(_controller);
            await Future.delayed(const Duration(milliseconds: 300));
            if (mounted && !_isControllerDisposed && _controller != null) {
              PlayerUtils.seekTo(_controller!, result.position);
              await Future.delayed(const Duration(milliseconds: 500));
              if (result.wasPlaying &&
                  mounted &&
                  !_isControllerDisposed &&
                  _controller != null) {
                PlayerUtils.play(_controller);
              }
            }
          }
        }

        if (_isControllerSafe) {
          if (result.isMuted != _state.isMuted) {
            _cubit.setMuted(result.isMuted);
          }
          PlayerUtils.setMute(_controller!, result.isMuted);
        }
      } catch (e) {
        log('Error syncing after fullscreen: $e');
      }
    }
  }

  void _restartVideo() {
    if (!mounted || _isControllerDisposed || _controller == null) return;
    setState(() {
      _videoEnded = false;
    });
    PlayerUtils.seekTo(_controller!, Duration.zero);
    PlayerUtils.play(_controller);
  }

  void _toggleMute() {
    if (!mounted || _isControllerDisposed || _controller == null) return;
    final newMuteState = PlayerUtils.toggleMute(
      _controller!,
      _state.isMuted,
      onError: (e) => log('Toggle mute error: $e'),
    );
    _cubit.setMuted(newMuteState);
    setState(() {});
  }

  void _seekForward() {
    if (!mounted || _isControllerDisposed) return;
    final controller = _controller;
    if (controller == null) return;
    PlayerUtils.seekForward(
      controller,
      onError: (e) => log('Seek forward error: $e'),
    );
  }

  void _seekBackward() {
    if (!mounted || _isControllerDisposed) return;
    final controller = _controller;
    if (controller == null) return;
    PlayerUtils.seekBackward(
      controller,
      onError: (e) => log('Seek backward error: $e'),
    );
  }

  void _showSettingsBottomSheet() {
    PlayerUtils.showSettings(
      context: context,
      config: PlayerSettingsConfig(
        autoPlay: _state.autoPlay,
        loop: _state.loop,
        forceHD: _state.forceHD,
        enableCaption: _state.enableCaption,
        isMuted: _state.isMuted,
        settingsBackgroundColor: _cfg.style.settingsBackgroundColor,
        settingItemBackgroundColor: _cfg.style.settingItemBackgroundColor,
        iconColor: _cfg.style.iconColor,
        textColor: _cfg.style.textColor,
        switchInactiveThumbColor: _cfg.style.switchInactiveThumbColor,
        switchInactiveTrackColor: _cfg.style.switchInactiveTrackColor,
        playerSettingsText: _cfg.text.playerSettingsText,
        autoPlayText: _cfg.text.autoPlayText,
        loopVideoText: _cfg.text.loopVideoText,
        forceHdQualityText: _cfg.text.forceHdQualityText,
        enableCaptionsText: _cfg.text.enableCaptionsText,
        muteAudioText: _cfg.text.muteAudioText,
        showAutoPlaySetting: _cfg.visibility.showAutoPlaySetting,
        showLoopSetting: _cfg.visibility.showLoopSetting,
        showForceHDSetting: _cfg.visibility.showForceHDSetting,
        showCaptionsSetting: _cfg.visibility.showCaptionsSetting,
        showMuteSetting: _cfg.visibility.showMuteSetting,
        settingsTitleStyle: _cfg.style.settingsTitleStyle,
        settingItemTextStyle: _cfg.style.settingItemTextStyle,
      ),
      onAutoPlayChanged: (value) async {
        if (_state.autoPlay != value) {
          _cubit.setAutoPlay(value);
          await _reloadPlayerWithSettings();
        }
      },
      onLoopChanged: (value) async {
        if (_state.loop != value) {
          _cubit.setLoop(value);
          await _reloadPlayerWithSettings();
        }
      },
      onForceHDChanged: (value) async {
        if (_state.forceHD != value) {
          _cubit.setForceHD(value);
          await _reloadPlayerWithSettings();
        }
      },
      onEnableCaptionChanged: (value) async {
        if (_state.enableCaption != value) {
          _cubit.setEnableCaption(value);
          await _reloadPlayerWithSettings();
        }
      },
      onMutedChanged: (value) {
        if (_state.isMuted != value) {
          _cubit.setMuted(value);
          if (_controller != null) {
            PlayerUtils.setMute(_controller!, _state.isMuted);
          }
        }
      },
    );
  }

  Future<void> _reloadPlayerWithSettings({Duration? targetPosition}) async {
    if (_controller == null || _isControllerDisposed) return;
    Duration currentPosition = targetPosition ?? Duration.zero;
    bool wasPlaying = false;
    try {
      if (targetPosition == null) {
        currentPosition = _controller!.value.position;
      }
      wasPlaying = _controller!.value.isPlaying;
    } catch (e) {
      log('Error getting current state before reload: $e');
    }
    _pendingSeekPosition = currentPosition;
    _hasRestoredPosition = false;
    _disposeController();
    setState(() {
      _isControllerDisposed = false;
    });
    await Future.delayed(const Duration(milliseconds: 200));
    if (!mounted) return;
    _initializePlayer();
    await Future.delayed(const Duration(milliseconds: 800));
    if (mounted &&
        _controller != null &&
        !_isControllerDisposed &&
        wasPlaying) {
      await Future.delayed(const Duration(milliseconds: 100));
      PlayerUtils.play(_controller);
    }
  }

  @override
  void dispose() {
    _disposeController();
    _cubit.close();
    if (!_isInFullscreen) {
      SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
      SystemChrome.setEnabledSystemUIMode(
        SystemUiMode.manual,
        overlays: SystemUiOverlay.values,
      );
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_hasError) {
      return PlayerErrorWidget(
        errorMessage: _errorMessage,
        errorIconColor: _cfg.style.errorIconColor,
        backgroundColor: _cfg.style.backgroundColor,
        textColor: _cfg.style.textColor,
        errorTextStyle: _cfg.style.errorTextStyle,
      );
    }
    final controller = _controller;

    if (_videoId == null || _isControllerDisposed) {
      return PlayerLoadingWidget(
        loadingIndicatorColor: _cfg.style.loadingIndicatorColor,
        backgroundColor: _cfg.style.backgroundColor,
      );
    }
    // On mobile, we need the native controller to be ready
    if (!kIsWeb && !_useDesktopPlayer && controller == null) {
      return PlayerLoadingWidget(
        loadingIndicatorColor: _cfg.style.loadingIndicatorColor,
        backgroundColor: _cfg.style.backgroundColor,
      );
    }

    return BlocBuilder<YoutubePlayerCubit, PlayerCubitState>(
      bloc: _cubit,
      builder: (context, state) {
        return ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: AspectRatio(
            aspectRatio: 16 / 9,
            child: Directionality(
              textDirection: TextDirection.rtl,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // Web: HTML iframe
                  if (kIsWeb && _webIframeId != null)
                    buildYoutubeWebIframe(_webIframeId!)
                  // Desktop or forced: InAppWebView + localhost server
                  else if (_useDesktopPlayer)
                    YouTubeWebViewPlayer(
                      videoId: _videoId!,
                      config: _cfg,
                      onReady: () => log('Desktop YouTube player ready'),
                      onEnded: () => widget.onEnded?.call(),
                    )
                  // Mobile: Native youtube_player_flutter
                  else
                    YoutubePlayer(
                      controller: controller!,
                      showVideoProgressIndicator: true,
                      progressIndicatorColor: _cfg.style.progressBarPlayedColor,
                      progressColors: ProgressBarColors(
                        playedColor: _cfg.style.progressBarPlayedColor,
                        handleColor: _cfg.style.progressBarHandleColor,
                      ),
                      bottomActions: PlayerBottomActionsBuilder.build(
                        config: PlayerBottomActionsConfig(
                          progressBarPlayedColor:
                              _cfg.style.progressBarPlayedColor,
                          progressBarHandleColor:
                              _cfg.style.progressBarHandleColor,
                          iconColor: _cfg.style.iconColor,
                          textColor: _cfg.style.textColor,
                          timeTextStyle: _cfg.style.timeTextStyle,
                        ),
                        isMuted: state.isMuted,
                        isFullscreen: false,
                        showFullscreenButton:
                            _cfg.visibility.showFullscreenButton,
                        showSettingsButton: _cfg.visibility.showSettingsButton,
                        onFullscreenTap: _openFullScreen,
                        onMuteTap: _toggleMute,
                        onSettingsTap: _showSettingsBottomSheet,
                      ),
                      onReady: () => log('YouTube player ready'),
                      onEnded: (metaData) => widget.onEnded?.call(),
                    ),
                  // Seek overlay (mobile only)
                  if (!_videoEnded &&
                      !kIsWeb &&
                      !_useDesktopPlayer &&
                      controller != null)
                    ValueListenableBuilder<YoutubePlayerValue>(
                      valueListenable: controller,
                      builder: (context, value, child) {
                        return AnimatedOpacity(
                          opacity: value.isControlsVisible ? 1.0 : 0.0,
                          duration: const Duration(milliseconds: 300),
                          child: IgnorePointer(
                            ignoring: !value.isControlsVisible,
                            child: child,
                          ),
                        );
                      },
                      child: SeekButtonsOverlay(
                        onSeekBackward: _seekBackward,
                        onSeekForward: _seekForward,
                      ),
                    ),
                  // Replay overlay (mobile only)
                  if (_videoEnded && !kIsWeb && !_useDesktopPlayer)
                    Positioned.fill(
                      child: GestureDetector(
                        onTap: _restartVideo,
                        child: Container(
                          color: Colors.black.withValues(alpha: 0.6),
                          child: Center(
                            child: Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: Colors.black.withValues(alpha: 0.7),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                Icons.replay,
                                color: _cfg.style.iconColor,
                                size: 48,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  // Back button (Web & Desktop / WebView)
                  if ((kIsWeb || _useDesktopPlayer) &&
                      Navigator.canPop(context))
                    Positioned(
                      top: 24,
                      left: 16,
                      child: GestureDetector(
                        onTap: () => Navigator.of(context).pop(),
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.black.withValues(alpha: 0.6),
                            borderRadius: BorderRadius.circular(25),
                          ),
                          child: const Icon(
                            Icons.arrow_back,
                            color: Colors.white,
                            size: 24,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  void play() => PlayerUtils.play(_controller);
  void pause() => PlayerUtils.pause(_controller);
  void stop() => PlayerUtils.reset(_controller);
  void seekTo(Duration position) => PlayerUtils.seekTo(_controller!, position);
  void mute() {
    PlayerUtils.setMute(_controller!, true);
    _cubit.setMuted(true);
  }

  void unMute() {
    PlayerUtils.setMute(_controller!, false);
    _cubit.setMuted(false);
  }

  void setPlaybackRate(double rate) =>
      PlayerUtils.setPlaybackRate(_controller, rate);
  Duration get currentPosition => PlayerUtils.getCurrentPosition(_controller);
  Duration get duration => PlayerUtils.getDuration(_controller);
  bool get isPlaying => PlayerUtils.isPlaying(_controller);
  void enterFullScreen() => _openFullScreen();
  void loadVideo(String videoSource) {
    final newVideoId = PlayerUtils.extractVideoId(videoSource);
    if (newVideoId != null && _controller != null) {
      PlayerUtils.loadVideo(_controller, newVideoId);
    }
  }
}
