import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart'
    hide CurrentPosition, RemainingDuration;
import '../core/dependency_injection/injectable_config.dart';
import 'widgets/fullscreen_player_page.dart';
import 'widgets/player_controls.dart';
import 'widgets/player_bottom_actions.dart';
import 'utils/player_utils.dart';
import 'models/player_config.dart';
import 'cubit/youtube_player_cubit.dart';

/// A widget for playing YouTube videos with full YouTube controls
/// Similar to native YouTube app with speed, quality, captions, etc.
///
/// Uses [YouTubePlayerConfig] model for all configuration settings.
/// Uses [YoutubePlayerCubit] for state management between normal and fullscreen modes.
///
/// Example:
/// ```dart
/// YouTubeVideoPlayer(
///   videoSource: 'VIDEO_ID',
///   config: YouTubePlayerConfig(
///     playback: PlayerPlaybackConfig(autoPlay: true),
///     style: PlayerStyleConfig(iconColor: Colors.red),
///   ),
/// )
/// ```
class YouTubeVideoPlayer extends StatefulWidget {
  /// The YouTube video URL or video ID
  final String videoSource;

  /// Complete player configuration
  /// Contains all styling, text, visibility, and playback settings
  /// If not provided, uses default configuration
  final YouTubePlayerConfig config;

  /// Callback when the video ends
  final VoidCallback? onEnded;

  /// Creates a YouTubeVideoPlayer with the given configuration
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

  /// Helper getter for config
  YouTubePlayerConfig get _cfg => widget.config;

  /// Helper getter for cubit state
  PlayerCubitState get _state => _cubit.state;

  @override
  void initState() {
    super.initState();
    _cubit = getIt.get<YoutubePlayerCubit>();
    // Initialize cubit state from widget config
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
    // If video source changed, reinitialize the player
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

  /// Safely checks if the controller is ready for use
  bool get _isControllerSafe =>
      _controller != null && !_isControllerDisposed && mounted;

  void _initializePlayer() {
    try {
      _videoId = PlayerUtils.extractVideoId(widget.videoSource);

      if (_videoId == null || _videoId!.isEmpty) {
        log('Invalid YouTube video source: ${widget.videoSource}');
        if (mounted) {
          setState(() {
            _hasError = true;
            _errorMessage = _cfg.text.invalidYoutubeUrlText;
          });
        }
        return;
      }

      log('Initializing YouTube player with video ID: $_videoId');

      // Use pending seek position for startAt if available (for reload scenarios)
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
          // Restore position when player is ready
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

            // Handle loop manually if enabled
            if (_state.loop && !_isControllerDisposed && mounted) {
              Future.delayed(const Duration(milliseconds: 500), () {
                if (!_isControllerDisposed && mounted && _controller != null) {
                  _videoEnded = false;
                  PlayerUtils.seekTo(_controller!, Duration.zero);
                  PlayerUtils.play(_controller);
                }
              });
            } else {
              // Set video ended state to show replay button
              if (mounted) {
                setState(() {
                  _videoEnded = true;
                });
              }
            }
          }

          // Reset video ended flag when playing starts
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

  /// Opens fullscreen using Navigator.push
  Future<void> _openFullScreen() async {
    final controller = _controller;
    if (controller == null || _isControllerDisposed) return;

    _isInFullscreen = true;

    // Get current position and state before entering fullscreen
    final currentPosition = PlayerUtils.getCurrentPosition(controller);
    final wasPlaying = PlayerUtils.isPlaying(controller);

    // Pause the main player
    PlayerUtils.pause(
      controller,
      onError: (e) => log('Error pausing before fullscreen: $e'),
    );

    // Set landscape and hide system UI
    await SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
    await SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);

    if (!mounted) return;

    // Push fullscreen page with video info and cubit
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

    // Restore orientation to portrait-up only when returning from fullscreen
    await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);

    await SystemChrome.setEnabledSystemUIMode(
      SystemUiMode.manual,
      overlays: SystemUiOverlay.values,
    );

    // Sync position from fullscreen and resume if needed
    if (result != null &&
        mounted &&
        !_isControllerDisposed &&
        _controller != null) {
      try {
        // If video ended in fullscreen, show replay overlay in normal player
        if (result.videoEnded) {
          log('Video ended in fullscreen, showing replay overlay');
          widget.onEnded?.call();
          // Sync mute state only
          if (result.isMuted != _state.isMuted && _isControllerSafe) {
            _cubit.setMuted(result.isMuted);
          }
          // Set video ended state to show replay overlay
          setState(() {
            _videoEnded = true;
          });
          return;
        }

        // Check if settings changed and need reload
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
          // Reload player with new settings at the correct position
          await _reloadPlayerWithSettings(targetPosition: result.position);
          // After reload, resume playback if needed
          if (mounted && !_isControllerDisposed && _controller != null) {
            // Apply mute state after reload
            if (result.isMuted != _state.isMuted) {
              _cubit.setMuted(result.isMuted);
            }
            try {
              PlayerUtils.setMute(_controller!, result.isMuted);
            } catch (e) {
              log('Error applying mute state after reload: $e');
            }
            if (result.wasPlaying) {
              _controller!.play();
            }
          }
        } else {
          // Just sync position and playback state without reload
          if (mounted && !_isControllerDisposed && _controller != null) {
            // Make sure player is paused
            PlayerUtils.pause(_controller);

            // Wait for player to stabilize
            await Future.delayed(const Duration(milliseconds: 300));

            if (mounted && !_isControllerDisposed && _controller != null) {
              // Seek to exact position from fullscreen
              log(
                'Restoring position after fullscreen: ${result.position.inSeconds}s',
              );
              PlayerUtils.seekTo(_controller!, result.position);

              // Wait for seek to complete
              await Future.delayed(const Duration(milliseconds: 500));

              // Verify seek succeeded
              if (mounted && !_isControllerDisposed && _controller != null) {
                final currentPos = PlayerUtils.getCurrentPosition(_controller);
                final diff = (currentPos.inSeconds - result.position.inSeconds)
                    .abs();
                log(
                  'After seek: currentPos=${currentPos.inSeconds}s, target=${result.position.inSeconds}s, diff=$diff',
                );

                // Retry if position is off by more than 2 seconds
                if (diff > 2 && result.position.inSeconds > 0) {
                  log('Position off, retrying seek');
                  await Future.delayed(const Duration(milliseconds: 200));
                  if (mounted &&
                      !_isControllerDisposed &&
                      _controller != null) {
                    PlayerUtils.seekTo(_controller!, result.position);
                    await Future.delayed(const Duration(milliseconds: 400));
                  }
                }
              }

              // Resume playback if was playing in fullscreen
              if (result.wasPlaying &&
                  mounted &&
                  !_isControllerDisposed &&
                  _controller != null) {
                PlayerUtils.play(_controller);
                log('Resumed playback after fullscreen');
              }
            }
          }
        }

        // Always sync mute state from fullscreen to ensure sound works correctly
        if (_isControllerSafe) {
          if (result.isMuted != _state.isMuted) {
            _cubit.setMuted(result.isMuted);
          }
          try {
            PlayerUtils.setMute(_controller!, result.isMuted);
            log(
              'Synced mute state after fullscreen: isMuted=${result.isMuted}',
            );
          } catch (e) {
            log('Error setting mute after fullscreen: $e');
          }
        }
      } catch (e) {
        log('Error syncing after fullscreen: $e');
      }
    }
  }

  /// Restart video from beginning when video has ended
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

    // Save current state safely
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

    log(
      'Reloading player with settings, position: ${currentPosition.inSeconds}s, wasPlaying: $wasPlaying',
    );

    // Set pending seek position for startAt and backup seek
    _pendingSeekPosition = currentPosition;
    _hasRestoredPosition = false;

    // Dispose old controller
    _disposeController();
    setState(() {
      _isControllerDisposed = false;
    });

    // Wait for disposal to complete
    await Future.delayed(const Duration(milliseconds: 200));

    if (!mounted) return;

    // Initialize new player with new settings (uses _pendingSeekPosition for startAt)
    _initializePlayer();

    // Wait for player to be ready and position restored
    await Future.delayed(const Duration(milliseconds: 800));

    // Restore playback state
    if (mounted &&
        _controller != null &&
        !_isControllerDisposed &&
        wasPlaying) {
      await Future.delayed(const Duration(milliseconds: 100));
      PlayerUtils.play(
        _controller,
        onError: (e) => log('Error restoring playback state: $e'),
      );
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
    if (_videoId == null || controller == null || _isControllerDisposed) {
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
            child: Stack(
              alignment: Alignment.center,
              children: [
                YoutubePlayer(
                  controller: controller,
                  showVideoProgressIndicator: true,
                  progressIndicatorColor: _cfg.style.progressBarPlayedColor,
                  progressColors: ProgressBarColors(
                    playedColor: _cfg.style.progressBarPlayedColor,
                    handleColor: _cfg.style.progressBarHandleColor,
                  ),
                  bottomActions: PlayerBottomActionsBuilder.build(
                    config: PlayerBottomActionsConfig(
                      progressBarPlayedColor: _cfg.style.progressBarPlayedColor,
                      progressBarHandleColor: _cfg.style.progressBarHandleColor,
                      iconColor: _cfg.style.iconColor,
                      textColor: _cfg.style.textColor,
                      timeTextStyle: _cfg.style.timeTextStyle,
                    ),
                    isMuted: state.isMuted,
                    isFullscreen: false,
                    showFullscreenButton: _cfg.visibility.showFullscreenButton,
                    showSettingsButton: _cfg.visibility.showSettingsButton,
                    onFullscreenTap: _openFullScreen,
                    onMuteTap: _toggleMute,
                    onSettingsTap: _showSettingsBottomSheet,
                  ),
                  onReady: () {
                    log('YouTube player ready');
                  },
                  onEnded: (metaData) {
                    widget.onEnded?.call();
                  },
                ),
                // Seek buttons overlay (hide when video ended)
                if (!_videoEnded)
                  SeekButtonsOverlay(
                    onSeekBackward: _seekBackward,
                    onSeekForward: _seekForward,
                  ),
                // Replay overlay when video ended
                if (_videoEnded)
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
              ],
            ),
          ),
        );
      },
    );
  }

  // Public methods
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
