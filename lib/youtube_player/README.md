# YouTube Video Player Package

A comprehensive YouTube video player widget for Flutter with custom controls, settings, and fullscreen support.

## Features

- ✅ Full YouTube video playback
- ✅ Custom video controls
- ✅ Fullscreen mode with landscape orientation
- ✅ Settings bottom sheet (auto-play, loop, HD quality, captions, mute)
- ✅ Seek forward/backward (10 seconds)
- ✅ Current position and remaining duration display
- ✅ Localization support
- ✅ Error handling and loading states

## Usage

```dart
import 'package:your_app/core/common/widgets/youtube_player/youtube_player.dart';

// Basic usage (with default config)
YouTubeVideoPlayer(
  videoSource: 'https://www.youtube.com/watch?v=VIDEO_ID',
)

// With custom configuration
YouTubeVideoPlayer(
  videoSource: 'VIDEO_ID',
  config: YouTubePlayerConfig(
    playback: PlayerPlaybackConfig(
      autoPlay: true,
      loop: false,
      mute: false,
      forceHD: true,
      enableCaption: true,
    ),
    visibility: PlayerVisibilityConfig(
      showControls: true,
      showFullscreenButton: true,
      showSettingsButton: true,
      showAutoPlaySetting: true,
      showLoopSetting: true,
      showForceHDSetting: true,
      showCaptionsSetting: true,
      showMuteSetting: true,
    ),
    style: PlayerStyleConfig(
      progressBarPlayedColor: Colors.red,
      progressBarHandleColor: Colors.redAccent,
      loadingIndicatorColor: Colors.red,
      errorIconColor: Colors.red,
      iconColor: Colors.white,
      textColor: Colors.white,
      backgroundColor: Color(0xFF1D1D1D),
      settingsBackgroundColor: Color(0xFF1D1D1D),
      settingItemBackgroundColor: Color(0xFF0D0D0D),
    ),
    text: PlayerTextConfig(
      playerSettingsText: 'Settings',
      autoPlayText: 'Auto Play',
      loopVideoText: 'Loop',
      forceHdQualityText: 'HD Quality',
      enableCaptionsText: 'Captions',
      muteAudioText: 'Mute',
    ),
  ),
  onEnded: () {
    print('Video ended');
  },
)
```

## Configuration Models

The player uses a clean configuration model approach with all settings organized into logical groups:

- **`YouTubePlayerConfig`** - Complete configuration combining all sub-configs
- **`PlayerStyleConfig`** - Colors, text styles, and visual appearance
- **`PlayerTextConfig`** - Localization texts for UI elements
- **`PlayerVisibilityConfig`** - Show/hide controls and settings
- **`PlayerPlaybackConfig`** - Playback settings (autoplay, loop, mute, forceHD, enableCaption)

All config classes have sensible defaults, so you only need to specify the values you want to change.



## Components

### Main Widget
- `YouTubeVideoPlayer` - Main video player widget

### Shared Widgets (widgets folder)
- `CurrentPosition` - Displays current playback position
- `RemainingDuration` - Shows remaining video duration
- `PlayerBottomActionsBuilder` - Builds reusable bottom action bar for both normal and fullscreen players
- `FullscreenButton` - Fullscreen toggle button widget
- `MuteButton` - Mute toggle button widget
- `SettingsButton` - Settings button widget
- `TimeSeparator` - Time separator widget (" / ")
- `SeekButton` - Seek button widget with icon
- `SeekButtonsOverlay` - Overlay with seek forward/backward buttons
- `PlayerLoadingWidget` - Loading indicator widget
- `PlayerErrorWidget` - Error display widget

### Utilities (utils folder)
- `PlayerUtils` - Shared utility functions for player operations:
  - `seekForward()` / `seekBackward()` - Seek by 10 seconds
  - `toggleMute()` / `setMute()` - Mute controls
  - `getCurrentPosition()` / `getDuration()` - Get playback info
  - `isPlaying()` / `isReady()` - Check player state
  - `play()` / `pause()` / `reset()` - Playback controls
  - `seekTo()` - Seek to position
  - `loadVideo()` - Load new video
  - `setPlaybackRate()` - Set playback speed
  - `disposeController()` - Safely dispose controller
  - `extractVideoId()` - Extract video ID from URL
  - `createPlayerFlags()` - Create player flags with settings
  - `showSettings()` - Show settings bottom sheet
- `PlayerSettingsConfig` - Configuration class for settings sheet
- `PlayerBottomActionsConfig` - Configuration class for bottom actions styling
- `durationFormatter` - Formats duration to readable string (MM:SS or HH:MM:SS)

## Localization Keys

Add these keys to your localization files:

```json
{
  "agent_app": {
    "custom_widgets": {
      "invalid_youtube_url": "Invalid YouTube URL",
      "video_load_failed": "Failed to load video",
      "player_settings": "Player Settings",
      "auto_play": "Auto Play",
      "loop_video": "Loop Video",
      "force_hd_quality": "Force HD Quality",
      "enable_captions": "Enable Captions",
      "mute_audio": "Mute Audio"
    }
  }
}
```

## Dependencies

- `youtube_player_flutter` - YouTube player functionality
- `easy_localization` - Internationalization support
- `flutter/material.dart` - Flutter Material Design

## Public Methods

```dart
final key = GlobalKey<YouTubeVideoPlayerState>();

// Control methods
key.currentState?.play();
key.currentState?.pause();
key.currentState?.stop();
key.currentState?.seekTo(Duration(seconds: 30));
key.currentState?.mute();
key.currentState?.unMute();
key.currentState?.setPlaybackRate(1.5);
key.currentState?.enterFullScreen();
key.currentState?.loadVideo('NEW_VIDEO_ID');

// Get current state
Duration position = key.currentState?.currentPosition ?? Duration.zero;
Duration duration = key.currentState?.duration ?? Duration.zero;
bool isPlaying = key.currentState?.isPlaying ?? false;
```

## Package Structure

```
youtube_player/
├── youtube_player.dart              # Barrel file (exports all)
├── youtube_video_player.dart        # Main player widget
├── widgets/
│   ├── current_position.dart        # Position display widget
│   ├── remaining_duration.dart      # Duration display widget
│   ├── player_controls.dart         # Seek buttons, loading, error widgets
│   ├── player_bottom_actions.dart   # Shared bottom action bar (NEW!)
│   ├── fullscreen_player_page.dart  # Fullscreen player page
│   ├── player_settings_helper.dart  # Settings sheet helper function
│   ├── player_settings_sheet.dart   # Settings bottom sheet widget
│   └── setting_item.dart            # Individual setting item widget
└── utils/
    ├── duration_formatter.dart      # Duration formatting utility
    └── player_utils.dart            # Shared player utilities (NEW!)
```

## Architecture

The player uses a **shared widget and utility architecture** to avoid code duplication:

1. **PlayerBottomActionsBuilder** - A single function builds the bottom action bar for both normal and fullscreen players, ensuring consistency and reducing maintenance.

2. **PlayerUtils** - Centralized utility class with all player operations, used by both `YouTubeVideoPlayer` and `FullScreenPlayerPage`.

3. **Configuration Classes** - `PlayerBottomActionsConfig` and `PlayerSettingsConfig` encapsulate styling and settings, making it easy to pass configurations around.

This architecture ensures:
- ✅ No code duplication between normal and fullscreen modes
- ✅ Consistent UI across all player views
- ✅ Easy to modify controls in one place
- ✅ Reusable widgets for custom implementations

