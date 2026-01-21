# 🎥 Videos Player

A comprehensive Flutter video player package that seamlessly handles both YouTube videos and direct video URLs with adaptive player selection.

[![Flutter](https://img.shields.io/badge/Flutter-v3.10.7+-02569B?logo=flutter)](https://flutter.dev)
[![Dart](https://img.shields.io/badge/Dart-3.10.7+-0175C2?logo=dart)](https://dart.dev)
[![License](https://img.shields.io/badge/License-MIT-blue.svg)](LICENSE)

## ✨ Features

### 🎬 Adaptive Video Player

- **Smart Detection**: Automatically detects and plays YouTube videos or direct video URLs
- **Unified API**: Single widget interface for all video types
- **Seamless Integration**: No need to manually choose between player types

### 📺 YouTube Player

- ✅ Full YouTube video support
- ✅ Custom native-like controls
- ✅ Fullscreen mode with state preservation
- ✅ Playback speed control (0.25x - 2x)
- ✅ Quality settings
- ✅ Auto-play and loop options
- ✅ Captions/subtitles support
- ✅ Mute/unmute functionality
- ✅ Seek forward/backward (10s jumps)
- ✅ Settings panel with all controls

### 🎞️ Normal Video Player

- ✅ Supports multiple video formats (MP4, MOV, AVI, MKV, WebM, etc.)
- ✅ Network video streaming
- ✅ Local file playback
- ✅ In-memory video bytes support
- ✅ Powered by Chewie for advanced controls
- ✅ Customizable player UI
- ✅ Fullscreen support
- ✅ Error handling with retry options

### 🎨 Customization

- Fully customizable colors and styles
- Custom text labels and messages
- Configurable visibility of controls
- Flexible playback configurations

### 🏗️ Architecture

- **State Management**: BLoC/Cubit pattern with `flutter_bloc`
- **Dependency Injection**: Clean architecture with `get_it` and `injectable`
- **Type Safety**: Strongly typed configuration models
- **Error Handling**: Comprehensive error management

## 📦 Installation

### 1. Add to `pubspec.yaml`

```yaml
dependencies:
  flutter:
    sdk: flutter
  chewie: ^1.13.0
  video_player: ^2.10.1
  youtube_player_flutter: ^9.1.3
  flutter_bloc: ^9.1.1
  get_it: ^9.2.0
  injectable: ^2.7.1+4
  equatable: ^2.0.8

dev_dependencies:
  build_runner: ^2.10.5
  injectable_generator: ^2.12.0
```

### 2. Install Dependencies

```bash
flutter pub get
```

### 3. Generate Injectable Configuration

```bash
dart run build_runner build --delete-conflicting-outputs
```

## 🚀 Quick Start

### Initialize Dependency Injection

In your `main.dart`:

```dart
import 'package:flutter/material.dart';
import 'core/dependency_injection/injectable_config.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  configureDependencies();
  runApp(const MyApp());
}
```

### Basic Usage

```dart
import 'package:videos_player/normal_video_player/adaptive_video_player.dart';
import 'package:videos_player/normal_video_player/model/video_config.dart';

// The player automatically detects if it's YouTube or direct video
AdaptiveVideoPlayer(
  config: VideoConfig(
    videoUrl: 'https://www.youtube.com/watch?v=VIDEO_ID',
    // or direct video: 'https://example.com/video.mp4'
  ),
)
```

## 📖 Usage Examples

### 1. YouTube Video

```dart
import 'package:videos_player/normal_video_player/adaptive_video_player.dart';
import 'package:videos_player/normal_video_player/model/video_config.dart';
import 'package:videos_player/youtube_player/models/player_config.dart';

AdaptiveVideoPlayer(
  config: VideoConfig(
    videoUrl: 'https://www.youtube.com/watch?v=vM2dC8OCZoY',
    playerConfig: YouTubePlayerConfig(
      playback: PlayerPlaybackConfig(
        autoPlay: true,
        loop: false,
        forceHD: true,
        enableCaption: true,
      ),
      style: PlayerStyleConfig(
        iconColor: Colors.red,
        progressBarPlayedColor: Colors.red,
      ),
    ),
  ),
)
```

### 2. Direct Video URL

```dart
AdaptiveVideoPlayer(
  config: VideoConfig(
    videoUrl: 'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/BigBuckBunny.mp4',
    playerConfig: YouTubePlayerConfig(
      playback: PlayerPlaybackConfig(
        autoPlay: false,
        loop: true,
      ),
    ),
  ),
)
```

### 3. Local Video File

```dart
AdaptiveVideoPlayer(
  config: VideoConfig(
    videoUrl: '/path/to/local/video.mp4',
    isFile: true,
  ),
)
```

### 4. Video from Memory (Uint8List)

```dart
import 'dart:typed_data';

final Uint8List videoBytes = ...; // Your video bytes

AdaptiveVideoPlayer(
  config: VideoConfig(
    videoUrl: '', // Not used for in-memory videos
    videoBytes: videoBytes,
  ),
)
```

### 5. Full Custom Configuration

```dart
AdaptiveVideoPlayer(
  config: VideoConfig(
    videoUrl: 'https://www.youtube.com/watch?v=VIDEO_ID',
    playerConfig: YouTubePlayerConfig(
      // Playback settings
      playback: PlayerPlaybackConfig(
        autoPlay: true,
        loop: false,
        mute: false,
        forceHD: true,
        enableCaption: true,
        startAt: Duration(seconds: 30),
      ),

      // Style customization
      style: PlayerStyleConfig(
        iconColor: Colors.white,
        textColor: Colors.white,
        progressBarPlayedColor: Colors.blue,
        progressBarHandleColor: Colors.blueAccent,
        backgroundColor: Colors.black,
        loadingIndicatorColor: Colors.blue,
      ),

      // Custom text labels
      text: PlayerTextConfig(
        playerSettingsText: 'Settings',
        autoPlayText: 'Auto Play',
        loopVideoText: 'Loop Video',
        qualityText: 'Quality',
        speedText: 'Speed',
        muteAudioText: 'Mute',
      ),

      // Control visibility
      visibility: PlayerVisibilityConfig(
        showSettingsButton: true,
        showFullscreenButton: true,
        showAutoPlaySetting: true,
        showLoopSetting: true,
        showForceHDSetting: true,
        showCaptionsSetting: true,
      ),
    ),
  ),
)
```

## 🎛️ Configuration Options

### VideoConfig

| Property       | Type                  | Description                   | Default        |
| -------------- | --------------------- | ----------------------------- | -------------- |
| `videoUrl`     | `String`              | Video URL (YouTube or direct) | Required       |
| `isFile`       | `bool`                | Whether video is a local file | `false`        |
| `videoBytes`   | `Uint8List?`          | Video data in memory          | `null`         |
| `playerConfig` | `YouTubePlayerConfig` | Complete player configuration | Default config |

### YouTubePlayerConfig

Contains four sub-configurations:

#### 1. PlayerPlaybackConfig

| Property        | Type        | Description         | Default |
| --------------- | ----------- | ------------------- | ------- |
| `autoPlay`      | `bool`      | Auto-start playback | `false` |
| `loop`          | `bool`      | Loop video          | `false` |
| `mute`          | `bool`      | Start muted         | `false` |
| `forceHD`       | `bool`      | Force HD quality    | `false` |
| `enableCaption` | `bool`      | Enable captions     | `true`  |
| `startAt`       | `Duration?` | Start position      | `null`  |

#### 2. PlayerStyleConfig

| Property                 | Type    | Description      | Default        |
| ------------------------ | ------- | ---------------- | -------------- |
| `iconColor`              | `Color` | Icon color       | `Colors.white` |
| `textColor`              | `Color` | Text color       | `Colors.white` |
| `progressBarPlayedColor` | `Color` | Progress color   | `Colors.red`   |
| `backgroundColor`        | `Color` | Background color | `#1D1D1D`      |
| `loadingIndicatorColor`  | `Color` | Loading color    | `Colors.red`   |

#### 3. PlayerTextConfig

| Property             | Type     | Description     | Default             |
| -------------------- | -------- | --------------- | ------------------- |
| `playerSettingsText` | `String` | Settings title  | `"Player Settings"` |
| `autoPlayText`       | `String` | Auto-play label | `"Auto Play"`       |
| `loopVideoText`      | `String` | Loop label      | `"Loop Video"`      |
| `qualityText`        | `String` | Quality label   | `"Quality"`         |
| `speedText`          | `String` | Speed label     | `"Playback Speed"`  |

#### 4. PlayerVisibilityConfig

| Property               | Type   | Description            | Default |
| ---------------------- | ------ | ---------------------- | ------- |
| `showSettingsButton`   | `bool` | Show settings button   | `true`  |
| `showFullscreenButton` | `bool` | Show fullscreen button | `true`  |
| `showAutoPlaySetting`  | `bool` | Show auto-play option  | `true`  |
| `showLoopSetting`      | `bool` | Show loop option       | `true`  |
| `showForceHDSetting`   | `bool` | Show HD option         | `true`  |

## 🧪 Testing

Run all tests:

```bash
flutter test
```

Run tests with coverage:

```bash
flutter test --coverage
```

## 🏛️ Architecture

```
lib/
├── core/
│   ├── dependency_injection/    # Injectable configuration
│   └── utils/                   # Shared utilities
├── normal_video_player/
│   ├── adaptive_video_player.dart    # Main adaptive player
│   ├── normal_video_player.dart      # Direct video player
│   └── model/
│       └── video_config.dart         # Configuration model
└── youtube_player/
    ├── youtube_video_player.dart     # YouTube player widget
    ├── cubit/                        # State management
    │   ├── youtube_player_cubit.dart
    │   └── youtube_player_state.dart
    ├── models/                       # Configuration models
    │   └── player_config.dart
    ├── utils/                        # Utilities
    │   ├── player_utils.dart
    │   └── duration_formatter.dart
    └── widgets/                      # UI components
        ├── player_controls.dart
        ├── player_settings_sheet.dart
        └── fullscreen_player_page.dart
```

## 🔧 Supported Video Formats

### Direct Videos

- MP4 (`.mp4`)
- MOV (`.mov`)
- AVI (`.avi`)
- MKV (`.mkv`)
- WebM (`.webm`)
- M4V (`.m4v`)
- 3GP (`.3gp`)
- FLV (`.flv`)
- WMV (`.wmv`)

### YouTube

- Standard YouTube URLs
- Shortened URLs (youtu.be)
- Embedded URLs
- Mobile URLs (m.youtube.com)

## 🤝 Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit your changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

## 📝 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 👨‍💻 Author

**Ahmed Mohamed**

- GitHub: [@ahmedalam782](https://github.com/ahmedalam782)

## 🙏 Acknowledgments

- [video_player](https://pub.dev/packages/video_player) - Flutter's official video player
- [chewie](https://pub.dev/packages/chewie) - Video player with controls
- [youtube_player_flutter](https://pub.dev/packages/youtube_player_flutter) - YouTube player for Flutter
- [flutter_bloc](https://pub.dev/packages/flutter_bloc) - State management
- [get_it](https://pub.dev/packages/get_it) - Service locator
- [injectable](https://pub.dev/packages/injectable) - Code generation for get_it

## 🐛 Known Issues

- None at the moment. Please report any issues on GitHub.

## 🔮 Roadmap

- [ ] Add playlist support
- [ ] Add picture-in-picture mode
- [ ] Add casting support (Chromecast)
- [ ] Add download functionality
- [ ] Add offline playback
- [ ] Add more video format support
- [ ] Add video editing capabilities
- [ ] Add live streaming support

## ❓ FAQ

**Q: Does this support live streaming?**  
A: Not yet, but it's on the roadmap.

**Q: Can I use this for audio-only content?**  
A: Yes, though it's optimized for video. You can disable video display through custom styling.

**Q: How do I handle errors?**  
A: The player has built-in error handling with retry options. You can also customize error messages through `PlayerTextConfig`.

**Q: Does it work on all platforms?**  
A: It works on Android, iOS, and Web. Desktop support depends on the underlying video_player package.

## 💡 Tips

1. **Always initialize dependencies** before using the player
2. **Use adaptive player** for automatic detection of video types
3. **Customize config** based on your app's theme
4. **Test on real devices** for best performance assessment
5. **Handle errors gracefully** with custom error messages

---

Made with ❤️ by Ahmed Mohamed
