import 'dart:async';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import '../youtube_player/models/player_config.dart';
import 'model/video_config.dart';
import 'utils/subtitle_parser.dart';

typedef AdaptiveControlsBuilder = Widget Function(
    BuildContext context, VideoPlayerController controller, bool isFullScreen);

typedef SubtitleBuilder = Widget Function(
    BuildContext context, String subtitleText);

class BaseAdaptiveVideoPlayer extends StatefulWidget {
  final VideoPlayerController controller;
  final bool showControls;
  final bool isFullScreen;
  final AdaptiveControlsBuilder? controlsBuilder;
  final SubtitleBuilder? subtitleBuilder;
  final PlayerStyleConfig? styling;
  final void Function(String event, Map<String, dynamic> data)?
      onAnalyticsEvent;
  final List<VideoQuality>? qualities;
  final VideoQuality? currentQuality;
  final void Function(VideoQuality)? onQualitySelected;
  final List<SubtitleTrack>? subtitles;
  final SubtitleTrack? currentSubtitleTrack;
  final void Function(SubtitleTrack?)? onSubtitleSelected;
  final List<SubtitleItem>? parsedSubtitles;
  final bool isLive;

  const BaseAdaptiveVideoPlayer({
    super.key,
    required this.controller,
    this.showControls = true,
    this.isFullScreen = false,
    this.controlsBuilder,
    this.subtitleBuilder,
    this.styling,
    this.onAnalyticsEvent,
    this.qualities,
    this.currentQuality,
    this.onQualitySelected,
    this.subtitles,
    this.currentSubtitleTrack,
    this.onSubtitleSelected,
    this.parsedSubtitles,
    this.isLive = false,
  });

  @override
  State<BaseAdaptiveVideoPlayer> createState() =>
      _BaseAdaptiveVideoPlayerState();
}

class _BaseAdaptiveVideoPlayerState extends State<BaseAdaptiveVideoPlayer> {
  bool _controlsVisible = true;
  int _seekDirection = 0; // -1 for backward, 1 for forward, 0 for none
  Timer? _hideTimer;

  @override
  void initState() {
    super.initState();
    _startHideTimer();

    // Add listener to fire events
    widget.controller.addListener(_videoListener);
    widget.onAnalyticsEvent?.call('video_initialized',
        {'duration': widget.controller.value.duration.inSeconds});
  }

  bool _videoEndedEventSent = false;
  String _currentSubtitleText = '';

  void _videoListener() {
    final position = widget.controller.value.position;
    final duration = widget.controller.value.duration;

    if (position >= duration && duration.inMilliseconds > 0) {
      if (!_videoEndedEventSent) {
        _videoEndedEventSent = true;
        widget.onAnalyticsEvent?.call('video_ended', {});
      }
    } else {
      _videoEndedEventSent = false;
    }

    _updateSubtitle(position);
  }

  void _updateSubtitle(Duration position) {
    if (widget.parsedSubtitles == null || widget.parsedSubtitles!.isEmpty) {
      if (_currentSubtitleText.isNotEmpty) {
        setState(() => _currentSubtitleText = '');
      }
      return;
    }

    // Binary search or simple iteration
    String newText = '';
    for (final item in widget.parsedSubtitles!) {
      if (position >= item.start && position <= item.end) {
        newText = item.text;
        break;
      }
    }

    if (_currentSubtitleText != newText) {
      setState(() => _currentSubtitleText = newText);
    }
  }

  @override
  void dispose() {
    _hideTimer?.cancel();
    super.dispose();
  }

  void _startHideTimer() {
    _hideTimer?.cancel();
    _hideTimer = Timer(const Duration(seconds: 3), () {
      if (mounted && widget.controller.value.isPlaying) {
        setState(() => _controlsVisible = false);
      }
    });
  }

  void _toggleControls() {
    setState(() {
      _controlsVisible = !_controlsVisible;
      if (_controlsVisible) {
        _startHideTimer();
      } else {
        _hideTimer?.cancel();
      }
    });
  }

  void _handleDoubleTap(TapDownDetails details) {
    final width = MediaQuery.of(context).size.width;
    final position = details.globalPosition.dx;
    final currentPosition = widget.controller.value.position;

    setState(() {
      if (position > width / 2) {
        _seekDirection = 1;
        widget.controller.seekTo(currentPosition + const Duration(seconds: 10));
      } else {
        _seekDirection = -1;
        widget.controller.seekTo(currentPosition - const Duration(seconds: 10));
      }
    });

    _startHideTimer(); // Reset auto-hide timer when double tapped

    // Reset visual feedback after a delay
    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted) setState(() => _seekDirection = 0);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        AspectRatio(
          aspectRatio: widget.controller.value.aspectRatio,
          child: Stack(
            alignment: Alignment.bottomCenter,
            children: [
              VideoPlayer(widget.controller),

              // Built-in Subtitle/ClosedCaption overlay Layer
              if (widget.subtitleBuilder != null)
                ValueListenableBuilder(
                  valueListenable: widget.controller,
                  builder: (context, VideoPlayerValue value, child) {
                    return widget.subtitleBuilder!(context, value.caption.text);
                  },
                ),
            ],
          ),
        ),

        // Buffering/Loading Indicator Overlay
        ValueListenableBuilder(
          valueListenable: widget.controller,
          builder: (context, VideoPlayerValue value, child) {
            // Only show buffering if we are actively trying to play or at the very start
            if (value.isBuffering &&
                (value.isPlaying || value.position == Duration.zero)) {
              return Center(
                child: CircularProgressIndicator(
                  color: widget.styling?.loadingIndicatorColor ??
                      const Color.fromRGBO(255, 0, 0, 0.7),
                  strokeCap: StrokeCap.round,
                ),
              );
            }
            return const SizedBox.shrink();
          },
        ),

        // Visual feedback overlay for Double-Tap seeking
        if (_seekDirection != 0)
          Positioned.fill(
            child: Row(
              children: [
                Expanded(
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    color: _seekDirection == -1
                        ? Colors.white24
                        : Colors.transparent,
                    child: _seekDirection == -1
                        ? const Center(
                            child: Icon(Icons.fast_rewind,
                                color: Colors.white, size: 48))
                        : null,
                  ),
                ),
                Expanded(
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    color: _seekDirection == 1
                        ? Colors.white24
                        : Colors.transparent,
                    child: _seekDirection == 1
                        ? const Center(
                            child: Icon(Icons.fast_forward,
                                color: Colors.white, size: 48))
                        : null,
                  ),
                ),
              ],
            ),
          ),

        if (_currentSubtitleText.isNotEmpty)
          Positioned(
            left: 20,
            right: 20,
            bottom: widget.showControls && _controlsVisible
                ? 80
                : 20, // Move up if controls are visible
            child: widget.subtitleBuilder != null
                ? widget.subtitleBuilder!(context, _currentSubtitleText)
                : Align(
                    alignment: Alignment.bottomCenter,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.6),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        _currentSubtitleText,
                        textAlign: TextAlign.center,
                        style: widget.styling?.settingItemTextStyle?.copyWith(
                                fontSize: widget.isFullScreen ? 20 : 16) ??
                            TextStyle(
                                color: Colors.white,
                                fontSize: widget.isFullScreen ? 20 : 16),
                      ),
                    ),
                  ),
          ),

        if (widget.showControls)
          Positioned.fill(
            child: GestureDetector(
              onTap: _toggleControls,
              onDoubleTapDown: _handleDoubleTap,
              child: AnimatedOpacity(
                opacity: _controlsVisible ? 1 : 0,
                duration: const Duration(milliseconds: 250),
                child: widget.controlsBuilder != null
                    ? widget.controlsBuilder!(
                        context, widget.controller, widget.isFullScreen)
                    : AdaptiveControlsLayer(
                        controller: widget.controller,
                        isFullScreen: widget.isFullScreen,
                        styling: widget.styling,
                        onAnalyticsEvent: widget.onAnalyticsEvent,
                        qualities: widget.qualities,
                        currentQuality: widget.currentQuality,
                        onQualitySelected: widget.onQualitySelected,
                        subtitles: widget.subtitles,
                        currentSubtitleTrack: widget.currentSubtitleTrack,
                        onSubtitleSelected: widget.onSubtitleSelected,
                        parsedSubtitles: widget.parsedSubtitles,
                        controlsBuilder: widget.controlsBuilder,
                        subtitleBuilder: widget.subtitleBuilder,
                        isLive: widget.isLive,
                      ),
              ),
            ),
          ),
      ],
    );
  }
}

class AdaptiveControlsLayer extends StatelessWidget {
  final VideoPlayerController controller;
  final bool isFullScreen;
  final PlayerStyleConfig? styling;
  final void Function(String event, Map<String, dynamic> data)?
      onAnalyticsEvent;
  final List<VideoQuality>? qualities;
  final VideoQuality? currentQuality;
  final void Function(VideoQuality)? onQualitySelected;
  final List<SubtitleTrack>? subtitles;
  final SubtitleTrack? currentSubtitleTrack;
  final void Function(SubtitleTrack?)? onSubtitleSelected;
  final List<SubtitleItem>? parsedSubtitles;
  final AdaptiveControlsBuilder? controlsBuilder;
  final SubtitleBuilder? subtitleBuilder;
  final bool isLive;

  const AdaptiveControlsLayer({
    super.key,
    required this.controller,
    this.isFullScreen = false,
    this.styling,
    this.onAnalyticsEvent,
    this.qualities,
    this.currentQuality,
    this.onQualitySelected,
    this.subtitles,
    this.currentSubtitleTrack,
    this.onSubtitleSelected,
    this.parsedSubtitles,
    this.controlsBuilder,
    this.subtitleBuilder,
    this.isLive = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black45,
      child: Stack(
        children: [
          Align(
            alignment: Alignment.center,
            child: _buildCenterPlayPause(),
          ),
          Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              if (!isLive) _buildProgressBar(),
              _buildBottomBar(context),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCenterPlayPause() {
    return ValueListenableBuilder(
      valueListenable: controller,
      builder: (context, VideoPlayerValue value, _) {
        final isPlaying = value.isPlaying;
        return IconButton(
          iconSize: isFullScreen ? 80 : 64, // Bigger in landscape
          icon: Icon(
            isPlaying ? Icons.pause_circle_outline : Icons.play_circle_outline,
            color: styling?.iconColor ?? Colors.white70,
          ),
          onPressed: () {
            if (isPlaying) {
              controller.pause();
              onAnalyticsEvent?.call(
                  'video_paused', {'position': value.position.inSeconds});
            } else {
              controller.play();
              onAnalyticsEvent?.call(
                  'video_played', {'position': value.position.inSeconds});
            }
          },
        );
      },
    );
  }

  Widget _buildProgressBar() {
    return ValueListenableBuilder(
      valueListenable: controller,
      builder: (context, VideoPlayerValue value, _) {
        final duration = value.duration.inSeconds.toDouble();
        final position = value.position.inSeconds
            .clamp(0, value.duration.inSeconds)
            .toDouble();

        return Stack(
          alignment: Alignment.centerLeft,
          children: [
            // Buffer indicator layer
            Positioned.fill(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: CustomPaint(
                  painter: _BufferPainter(value.buffered, value.duration),
                ),
              ),
            ),

            // Interactive Slider layer
            SliderTheme(
              data: SliderTheme.of(context).copyWith(
                trackHeight: isFullScreen ? 4.0 : 2.0, // Thicker in landscape
                thumbShape: RoundSliderThumbShape(
                    enabledThumbRadius: isFullScreen ? 8.0 : 6.0),
                overlayShape:
                    const RoundSliderOverlayShape(overlayRadius: 14.0),
                activeTrackColor: styling?.progressBarPlayedColor ?? Colors.red,
                inactiveTrackColor:
                    styling?.progressBarHandleColor.withValues(alpha: 0.3) ??
                        Colors.white24,
                thumbColor: styling?.progressBarHandleColor ?? Colors.red,
              ),
              child: Slider(
                min: 0,
                max: duration > 0 ? duration : 1,
                value: position,
                onChanged: (seconds) {
                  controller.seekTo(Duration(seconds: seconds.toInt()));
                },
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildBottomBar(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              _buildLiveIndicator(),
              ValueListenableBuilder(
                valueListenable: controller,
                builder: (context, VideoPlayerValue value, child) {
                  final position = isLive ? Duration.zero : value.position;
                  final duration = isLive ? Duration.zero : value.duration;
                  return Text(
                    isLive
                        ? ''
                        : "${_formatDuration(position)} / ${_formatDuration(duration)}",
                    style: styling?.timeTextStyle ??
                        const TextStyle(color: Colors.white, fontSize: 14),
                  );
                },
              ),
            ],
          ),
          Row(
            children: [
              _buildSettingsButton(context),
              _buildSpeedControl(),
              _buildFullscreenButton(context),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLiveIndicator() {
    if (isLive) {
      // Currently live: show red badge
      return Container(
        margin: const EdgeInsets.only(right: 8),
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
        decoration: BoxDecoration(
          color: Colors.red,
          borderRadius: BorderRadius.circular(4),
        ),
        child: const Text('LIVE',
            style: TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.bold)),
      );
    } else {
      // Not live, but check if there's a live quality available to switch to
      final liveQuality = qualities?.where((q) => q.isLive).firstOrNull;
      if (liveQuality != null) {
        return GestureDetector(
          onTap: () {
            onAnalyticsEvent?.call('switched_to_live', {});
            onQualitySelected?.call(liveQuality);
          },
          child: Container(
            margin: const EdgeInsets.only(right: 8),
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.white54, width: 1),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Row(
              children: [
                Container(
                  width: 6,
                  height: 6,
                  margin: const EdgeInsets.only(right: 4),
                  decoration: const BoxDecoration(
                    color: Colors.red,
                    shape: BoxShape.circle,
                  ),
                ),
                const Text('GO LIVE',
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold)),
              ],
            ),
          ),
        );
      }
    }
    return const SizedBox.shrink();
  }

  String _formatDuration(Duration d) {
    final minutes = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final seconds = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    return "$minutes:$seconds";
  }

  Widget _buildSettingsButton(BuildContext context) {
    return IconButton(
      icon: Icon(Icons.settings, color: styling?.iconColor ?? Colors.white),
      onPressed: () {
        onAnalyticsEvent?.call('settings_opened', {});
        showModalBottomSheet(
          context: context,
          backgroundColor:
              styling?.settingsBackgroundColor ?? const Color(0xFF212121),
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
          ),
          builder: (context) {
            return SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 16.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    ListTile(
                      leading: Icon(Icons.hd,
                          color: styling?.iconColor ?? Colors.white),
                      title: Text('Quality (Resolution)',
                          style: styling?.settingItemTextStyle ??
                              const TextStyle(color: Colors.white)),
                      trailing: Text(currentQuality?.title ?? 'Auto',
                          style: TextStyle(
                              color:
                                  styling?.iconColor.withValues(alpha: 0.7) ??
                                      Colors.white70)),
                      onTap: () {
                        Navigator.pop(context);
                        onAnalyticsEvent
                            ?.call('resolution_settings_clicked', {});
                        if (qualities != null && qualities!.isNotEmpty) {
                          _showQualitiesBottomSheet(context);
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                  content: Text('No qualities available')));
                        }
                      },
                    ),
                    ListTile(
                      leading: Icon(Icons.closed_caption,
                          color: styling?.iconColor ?? Colors.white),
                      title: Text('Subtitles',
                          style: styling?.settingItemTextStyle ??
                              const TextStyle(color: Colors.white)),
                      trailing: Text(currentSubtitleTrack?.title ?? 'Off',
                          style: TextStyle(
                              color:
                                  styling?.iconColor.withValues(alpha: 0.7) ??
                                      Colors.white70)),
                      onTap: () {
                        Navigator.pop(context);
                        onAnalyticsEvent?.call('subtitle_settings_clicked', {});
                        if (subtitles != null && subtitles!.isNotEmpty) {
                          _showSubtitlesBottomSheet(context);
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                  content: Text('No subtitles available')));
                        }
                      },
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildSpeedControl() {
    return PopupMenuButton<double>(
      icon: Icon(Icons.speed, color: styling?.iconColor ?? Colors.white),
      onSelected: (speed) {
        controller.setPlaybackSpeed(speed);
        onAnalyticsEvent?.call('speed_changed', {'speed': speed});
      },
      itemBuilder: (_) => [
        const PopupMenuItem(value: 0.5, child: Text("0.5x")),
        const PopupMenuItem(value: 1.0, child: Text("1x")),
        const PopupMenuItem(value: 1.5, child: Text("1.5x")),
        const PopupMenuItem(value: 2.0, child: Text("2x")),
      ],
    );
  }

  void _showQualitiesBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor:
          styling?.settingsBackgroundColor ?? const Color(0xFF212121),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 16.0),
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: qualities!.length,
              itemBuilder: (context, index) {
                final quality = qualities![index];
                final isSelected = currentQuality == quality;
                return ListTile(
                  title: Text(quality.title,
                      style: styling?.settingItemTextStyle ??
                          const TextStyle(color: Colors.white)),
                  trailing: isSelected
                      ? Icon(Icons.check,
                          color: styling?.iconColor ?? Colors.white)
                      : null,
                  onTap: () {
                    Navigator.pop(context);
                    onQualitySelected?.call(quality);
                  },
                );
              },
            ),
          ),
        );
      },
    );
  }

  void _showSubtitlesBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor:
          styling?.settingsBackgroundColor ?? const Color(0xFF212121),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 16.0),
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: subtitles!.length + 1,
              itemBuilder: (context, index) {
                if (index == 0) {
                  // Off option
                  return ListTile(
                    title: Text('Off',
                        style: styling?.settingItemTextStyle ??
                            const TextStyle(color: Colors.white)),
                    trailing: currentSubtitleTrack == null
                        ? Icon(Icons.check,
                            color: styling?.iconColor ?? Colors.white)
                        : null,
                    onTap: () {
                      Navigator.pop(context);
                      onSubtitleSelected?.call(null);
                    },
                  );
                }
                final track = subtitles![index - 1];
                final isSelected = currentSubtitleTrack == track;
                return ListTile(
                  title: Text(track.title,
                      style: styling?.settingItemTextStyle ??
                          const TextStyle(color: Colors.white)),
                  trailing: isSelected
                      ? Icon(Icons.check,
                          color: styling?.iconColor ?? Colors.white)
                      : null,
                  onTap: () {
                    Navigator.pop(context);
                    onSubtitleSelected?.call(track);
                  },
                );
              },
            ),
          ),
        );
      },
    );
  }

  Widget _buildFullscreenButton(BuildContext context) {
    return IconButton(
      icon: Icon(
        isFullScreen ? Icons.fullscreen_exit : Icons.fullscreen,
        color: styling?.iconColor ?? Colors.white,
      ),
      onPressed: () {
        if (isFullScreen) {
          Navigator.pop(context);
        } else {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => FullscreenPlayer(
                controller: controller,
                styling: styling,
                onAnalyticsEvent: onAnalyticsEvent,
                controlsBuilder: controlsBuilder,
                subtitleBuilder: subtitleBuilder,
                qualities: qualities,
                currentQuality: currentQuality,
                onQualitySelected: onQualitySelected,
                subtitles: subtitles,
                currentSubtitleTrack: currentSubtitleTrack,
                onSubtitleSelected: onSubtitleSelected,
                parsedSubtitles: parsedSubtitles,
                isLive: isLive,
              ),
            ),
          );
        }
      },
    );
  }
}

class FullscreenPlayer extends StatefulWidget {
  final VideoPlayerController controller;
  final AdaptiveControlsBuilder? controlsBuilder;
  final SubtitleBuilder? subtitleBuilder;
  final PlayerStyleConfig? styling;
  final void Function(String event, Map<String, dynamic> data)?
      onAnalyticsEvent;
  final List<VideoQuality>? qualities;
  final VideoQuality? currentQuality;
  final void Function(VideoQuality)? onQualitySelected;
  final List<SubtitleTrack>? subtitles;
  final SubtitleTrack? currentSubtitleTrack;
  final void Function(SubtitleTrack?)? onSubtitleSelected;
  final List<SubtitleItem>? parsedSubtitles;
  final bool isLive;

  const FullscreenPlayer({
    super.key,
    required this.controller,
    this.controlsBuilder,
    this.subtitleBuilder,
    this.styling,
    this.onAnalyticsEvent,
    this.qualities,
    this.currentQuality,
    this.onQualitySelected,
    this.subtitles,
    this.currentSubtitleTrack,
    this.onSubtitleSelected,
    this.parsedSubtitles,
    this.isLive = false,
  });

  @override
  State<FullscreenPlayer> createState() => _FullscreenPlayerState();
}

class _FullscreenPlayerState extends State<FullscreenPlayer> {
  @override
  void initState() {
    super.initState();
    // In a real app, you would set preferred orientations to landscape here
  }

  @override
  void dispose() {
    // Restore preferred orientations
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: BaseAdaptiveVideoPlayer(
          controller: widget.controller,
          showControls: true,
          isFullScreen: true,
          controlsBuilder: widget.controlsBuilder,
          subtitleBuilder: widget.subtitleBuilder,
          styling: widget.styling,
          onAnalyticsEvent: widget.onAnalyticsEvent,
          qualities: widget.qualities,
          currentQuality: widget.currentQuality,
          onQualitySelected: widget.onQualitySelected,
          subtitles: widget.subtitles,
          currentSubtitleTrack: widget.currentSubtitleTrack,
          onSubtitleSelected: widget.onSubtitleSelected,
          parsedSubtitles: widget.parsedSubtitles,
          isLive: widget.isLive,
        ),
      ),
    );
  }
}

class _BufferPainter extends CustomPainter {
  final List<DurationRange> buffered;
  final Duration duration;

  _BufferPainter(this.buffered, this.duration);

  @override
  void paint(Canvas canvas, Size size) {
    if (duration.inMilliseconds == 0) return;

    final paint = Paint()
      ..color = Colors.white54
      ..style = PaintingStyle.fill;

    for (final range in buffered) {
      final startX =
          (range.start.inMilliseconds / duration.inMilliseconds) * size.width;
      final endX =
          (range.end.inMilliseconds / duration.inMilliseconds) * size.width;

      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTRB(startX, size.height / 2 - 1, endX, size.height / 2 + 1),
          const Radius.circular(2),
        ),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(_BufferPainter oldDelegate) {
    return oldDelegate.buffered != buffered || oldDelegate.duration != duration;
  }
}
