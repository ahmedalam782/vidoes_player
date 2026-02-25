import 'package:flutter/material.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart'
    hide CurrentPosition, RemainingDuration;
import '../models/player_config.dart';
import 'current_position.dart';
import 'remaining_duration.dart';

/// Fullscreen toggle button widget
class FullscreenButton extends StatelessWidget {
  final VoidCallback onTap;
  final Color iconColor;
  final bool isFullscreen;

  const FullscreenButton({
    super.key,
    required this.onTap,
    required this.iconColor,
    this.isFullscreen = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: Icon(
          isFullscreen ? Icons.fullscreen_exit : Icons.fullscreen,
          color: iconColor,
          size: 24,
        ),
      ),
    );
  }
}

/// Mute toggle button widget
class MuteButton extends StatelessWidget {
  final VoidCallback onTap;
  final Color iconColor;
  final bool isMuted;

  const MuteButton({
    super.key,
    required this.onTap,
    required this.iconColor,
    required this.isMuted,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4),
        child: Icon(
          isMuted ? Icons.volume_off : Icons.volume_up,
          color: iconColor,
          size: 28,
        ),
      ),
    );
  }
}

/// Settings button widget
class SettingsButton extends StatelessWidget {
  final VoidCallback onTap;
  final Color iconColor;

  const SettingsButton({
    super.key,
    required this.onTap,
    required this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4),
        child: Icon(Icons.settings, color: iconColor, size: 24),
      ),
    );
  }
}

/// Time separator widget
class TimeSeparator extends StatelessWidget {
  final TextStyle? textStyle;
  final Color textColor;

  const TimeSeparator({
    super.key,
    this.textStyle,
    this.textColor = Colors.white,
  });

  @override
  Widget build(BuildContext context) {
    return Text(
      ' / ',
      style: textStyle ?? TextStyle(color: textColor, fontSize: 14),
    );
  }
}

/// Utility class for building player bottom actions
/// This eliminates duplication between normal and fullscreen player
class PlayerBottomActionsBuilder {
  /// Builds the list of bottom action widgets for the YouTube player
  ///
  /// [config] - Styling configuration for the actions
  /// [isMuted] - Current mute state
  /// [isFullscreen] - Whether the player is in fullscreen mode
  /// [showFullscreenButton] - Whether to show the fullscreen button
  /// [showSettingsButton] - Whether to show the settings button
  /// [onFullscreenTap] - Callback for fullscreen button tap
  /// [onMuteTap] - Callback for mute button tap
  /// [onSettingsTap] - Callback for settings button tap
  static List<Widget> build({
    required PlayerBottomActionsConfig config,
    required bool isMuted,
    bool isFullscreen = false,
    bool showFullscreenButton = true,
    bool showSettingsButton = false,
    bool isLive = false,
    required VoidCallback onFullscreenTap,
    required VoidCallback onMuteTap,
    VoidCallback? onSettingsTap,
  }) {
    return [
      if (isLive)
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 8),
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
          decoration: BoxDecoration(
            color: Colors.red,
            borderRadius: BorderRadius.circular(4),
          ),
          child: const Text(
            'LIVE',
            style: TextStyle(
                color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
          ),
        ),
      if (!isLive) ...[
        const CurrentPosition(),
        TimeSeparator(
          textStyle: config.timeTextStyle,
          textColor: config.textColor,
        ),
        const RemainingDuration(),
      ],
      if (!isLive)
        ProgressBar(
          isExpanded: true,
          colors: ProgressBarColors(
            playedColor: config.progressBarPlayedColor,
            handleColor: config.progressBarHandleColor,
          ),
        )
      else
        const Spacer(),
      MuteButton(
        onTap: onMuteTap,
        iconColor: config.iconColor,
        isMuted: isMuted,
      ),
      if (showSettingsButton && onSettingsTap != null)
        SettingsButton(onTap: onSettingsTap, iconColor: config.iconColor),
      if (showFullscreenButton)
        FullscreenButton(
          onTap: onFullscreenTap,
          iconColor: config.iconColor,
          isFullscreen: isFullscreen,
        ),
    ];
  }
}
