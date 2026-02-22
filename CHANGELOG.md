## 1.0.4

* Fix `NormalVideoPlayer` playback on Web not rendering (removed dart:io dependency internally)

## 1.0.3
* Make web platform fully WASM-compatible by replacing dart:html with package:web

## 1.0.2
* Fix web platform compatibility issue from underlying dart:io import

## 1.0.1

## 1.0.0

* Initial release
* Adaptive video player with automatic YouTube/direct video detection
* YouTube player with native controls on mobile (Android/iOS)
* YouTube player with InAppWebView + localhost server on Windows Desktop (fixes Error 153)
* YouTube player with HTML iframe on Web
* Normal video player powered by Chewie (MP4, MOV, AVI, MKV, WebM, etc.)
* Support for network URLs, local files, and in-memory video bytes
* Customizable player styling, text labels, and control visibility
* BLoC/Cubit state management
* Fullscreen mode with state preservation
* Settings panel (auto-play, loop, force HD, captions, mute)
* Seek forward/backward controls on mobile
* Cross-platform support: Android, iOS, Windows, Web
