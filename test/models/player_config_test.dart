import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:adaptive_video_player/youtube_player/models/player_config.dart';

void main() {
  group('PlayerStyleConfig', () {
    test('creates PlayerStyleConfig with default values', () {
      const config = PlayerStyleConfig();

      expect(config.progressBarPlayedColor, Colors.red);
      expect(config.progressBarHandleColor, Colors.redAccent);
      expect(config.iconColor, Colors.white);
      expect(config.textColor, Colors.white);
      expect(config.backgroundColor, const Color(0xFF1D1D1D));
    });

    test('creates PlayerStyleConfig with custom values', () {
      const config = PlayerStyleConfig(
        progressBarPlayedColor: Colors.blue,
        iconColor: Colors.green,
        textColor: Colors.yellow,
      );

      expect(config.progressBarPlayedColor, Colors.blue);
      expect(config.iconColor, Colors.green);
      expect(config.textColor, Colors.yellow);
    });

    test('copyWith creates new instance with updated values', () {
      const original = PlayerStyleConfig(iconColor: Colors.white);
      final updated = original.copyWith(iconColor: Colors.red);

      expect(updated.iconColor, Colors.red);
      expect(original.iconColor, Colors.white);
    });
  });

  group('PlayerTextConfig', () {
    test('creates PlayerTextConfig with default values', () {
      const config = PlayerTextConfig();

      expect(config.playerSettingsText, 'Player Settings');
      expect(config.autoPlayText, 'Auto Play');
      expect(config.loopVideoText, 'Loop Video');
      expect(config.forceHdQualityText, 'Force HD Quality');
      expect(config.enableCaptionsText, 'Enable Captions');
    });

    test('creates PlayerTextConfig with custom values', () {
      const config = PlayerTextConfig(
        playerSettingsText: 'Custom Settings',
        autoPlayText: 'Auto Start',
      );

      expect(config.playerSettingsText, 'Custom Settings');
      expect(config.autoPlayText, 'Auto Start');
    });
  });

  group('PlayerVisibilityConfig', () {
    test('creates PlayerVisibilityConfig with default values', () {
      const config = PlayerVisibilityConfig();

      expect(config.showSettingsButton, true);
      expect(config.showFullscreenButton, true);
      expect(config.showAutoPlaySetting, true);
      expect(config.showLoopSetting, true);
    });

    test('creates PlayerVisibilityConfig with custom values', () {
      const config = PlayerVisibilityConfig(
        showSettingsButton: false,
        showFullscreenButton: false,
      );

      expect(config.showSettingsButton, false);
      expect(config.showFullscreenButton, false);
    });
  });

  group('PlayerPlaybackConfig', () {
    test('creates PlayerPlaybackConfig with default values', () {
      const config = PlayerPlaybackConfig();

      expect(config.autoPlay, false);
      expect(config.loop, false);
      expect(config.mute, false);
      expect(config.forceHD, false);
      expect(config.enableCaption, false);
    });

    test('creates PlayerPlaybackConfig with custom values', () {
      const config = PlayerPlaybackConfig(
        autoPlay: false,
        loop: true,
        mute: true,
        forceHD: true,
        enableCaption: true,
      );

      expect(config.autoPlay, false);
      expect(config.loop, true);
      expect(config.mute, true);
      expect(config.forceHD, true);
      expect(config.enableCaption, true);
    });
  });

  group('YouTubePlayerConfig', () {
    test('creates YouTubePlayerConfig with default values', () {
      const config = YouTubePlayerConfig();

      expect(config.style, isA<PlayerStyleConfig>());
      expect(config.text, isA<PlayerTextConfig>());
      expect(config.visibility, isA<PlayerVisibilityConfig>());
      expect(config.playback, isA<PlayerPlaybackConfig>());
    });

    test('creates YouTubePlayerConfig with custom sub-configs', () {
      const config = YouTubePlayerConfig(
        style: PlayerStyleConfig(iconColor: Colors.blue),
        text: PlayerTextConfig(playerSettingsText: 'Settings'),
        visibility: PlayerVisibilityConfig(showSettingsButton: false),
        playback: PlayerPlaybackConfig(autoPlay: true),
      );

      expect(config.style.iconColor, Colors.blue);
      expect(config.text.playerSettingsText, 'Settings');
      expect(config.visibility.showSettingsButton, false);
      expect(config.playback.autoPlay, true);
    });

    test('all sub-configs are accessible', () {
      const config = YouTubePlayerConfig();

      // Should not throw
      expect(() => config.style, returnsNormally);
      expect(() => config.text, returnsNormally);
      expect(() => config.visibility, returnsNormally);
      expect(() => config.playback, returnsNormally);
    });
  });
}
