# 🎥 Adaptive Video Player

🔥 **One Widget. All Platforms. YouTube + MP4. Zero Headaches.**

**A powerful cross-platform Flutter video player that supports YouTube, MP4, HLS, and local videos with one unified widget.**

**Android · iOS · Windows · macOS · Linux · Web**

[![pub package](https://img.shields.io/pub/v/adaptive_video_player.svg)](https://pub.dev/packages/adaptive_video_player)
[![Flutter](https://img.shields.io/badge/Flutter-3.1.0+-02569B?logo=flutter)](https://flutter.dev)
[![Platforms](https://img.shields.io/badge/Platforms-Android%20|%20iOS%20|%20macOS%20|%20Windows%20|%20Linux%20|%20Web-blue)](https://flutter.dev)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](LICENSE)

---

# ⚡ 10-Second Quick Start

```dart
AdaptiveVideoPlayer(
  config: VideoConfig(
    videoUrl: "https://youtu.be/VIDEO_ID",
  ),
);
```

> Just drop it in — it automatically adapts to YouTube or direct video streams.

---

# 📸 Screenshots

| Android                                            | Windows                                            | Web                                        |
| -------------------------------------------------- | -------------------------------------------------- | ------------------------------------------ |
| ![Android](assets/screenshots/android/%281%29.png) | ![Windows](assets/screenshots/windows/%282%29.png) | ![Web](assets/screenshots/web/%283%29.png) |

---

# ✨ Features

## 🎬 Adaptive Video Player

- 🔍 Smart YouTube vs MP4 detection
- 🎯 Unified API (one widget for everything)
- 🌍 True Cross-Platform support
- 📊 Native analytics events & callbacks (`onAnalyticsEvent`)
- 🧠 Production-ready architecture

---

## 📺 YouTube Support

- Native-like mobile experience
- Native YouTube controls on Desktop & Web
- Live Stream support (`isLive`, `viewerCount`)
- Force Desktop Mode on mobile
- Settings panel (HD, captions, loop, mute)
- Safe external link handling
- Fullscreen with state preservation
- WASM ready (Web via `package:web`)

---

## 🎞️ Direct Video Support

- MP4 · MOV · MKV · WebM · HLS · Local files
- Quality selection
- Subtitle support (SRT/VTT)
- Custom control builders
- Error handling
- Windows plugin integration
- Fully custom adaptive controls (No Chewie dependency)

---

# 🆚 Comparison With Popular Packages

| Feature         | adaptive_video_player | youtube_player_flutter | chewie | video_player |
| --------------- | --------------------- | ---------------------- | ------ | ------------ |
| YouTube Support | ✅                    | ✅                     | ❌     | ❌           |
| MP4/HLS Support | ✅                    | ❌                     | ✅     | ✅           |
| Desktop Support | ✅                    | ❌                     | ⚠️     | ⚠️           |
| Unified Widget  | ✅                    | ❌                     | ❌     | ❌           |
| Live Stream     | ✅                    | ❌                     | ❌     | ❌           |

---

# 🖥 Platform Behavior

| Platform                | Engine                      |
| ----------------------- | --------------------------- |
| Android / iOS           | youtube_player_flutter      |
| Windows / macOS / Linux | InAppWebView + localhost    |
| Web                     | HTML iframe via package:web |

> Desktop uses `http://localhost` to bypass YouTube iframe Error 153 restriction.

---

# 📦 Installation

```yaml
dependencies:
  adaptive_video_player: ^1.1.0
```

---

# 🚀 Example Usage

### YouTube

```dart
AdaptiveVideoPlayer(
  config: VideoConfig(
    videoUrl: 'https://www.youtube.com/watch?v=vM2dC8OCZoY',
  ),
);
```

### Direct MP4

```dart
AdaptiveVideoPlayer(
  config: VideoConfig(
    videoUrl: 'https://example.com/video.mp4',
  ),
);
```

### Live Stream

```dart
AdaptiveVideoPlayer(
  config: VideoConfig(
    videoUrl: 'https://www.youtube.com/watch?v=LIVE_ID',
    isLive: true,
    viewerCount: "1.2K",
  ),
);
```

---

## 🔮 Roadmap (Planned)

- 🎬 Playlist Support (Coming Soon)
- 📺 Picture-in-Picture (In Progress)

---

# 👨💻 Author

Ahmed Mohamed Alam
GitHub: [https://github.com/ahmedalam782](https://github.com/ahmedalam782)

---

# 📝 License

MIT License
