import 'dart:developer';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import '../models/player_config.dart';

/// A unified YouTube player that uses InAppWebView + local HTTP server
/// on all non-web platforms (Android, iOS, Windows, macOS, Linux).
///
/// This approach ensures consistent behavior across all platforms
/// and avoids YouTube Error 153 on Desktop.
class YouTubeWebViewPlayer extends StatefulWidget {
  final String videoId;
  final YouTubePlayerConfig config;
  final VoidCallback? onEnded;
  final VoidCallback? onReady;

  const YouTubeWebViewPlayer({
    super.key,
    required this.videoId,
    required this.config,
    this.onEnded,
    this.onReady,
  });

  @override
  State<YouTubeWebViewPlayer> createState() => _YouTubeWebViewPlayerState();
}

class _YouTubeWebViewPlayerState extends State<YouTubeWebViewPlayer> {
  InAppWebViewController? _webViewController;
  HttpServer? _localServer;
  String? _serverUrl;

  @override
  void initState() {
    super.initState();
    _startLocalServer();
  }

  /// Start a local HTTP server to serve the YouTube player HTML.
  /// YouTube allows iframe embedding from http://localhost origins,
  /// which fixes Error 153 on Desktop and works on mobile too.
  Future<void> _startLocalServer() async {
    try {
      // Load the HTML content from the package asset
      final htmlContent = await rootBundle.loadString(
        'packages/videos_player/assets/youtube_player.html',
      );

      // Start a local HTTP server on a random available port
      _localServer = await HttpServer.bind(InternetAddress.loopbackIPv4, 0);
      final port = _localServer!.port;
      log('YouTube local server started on port $port');

      _localServer!.listen((HttpRequest request) {
        request.response
          ..headers.contentType = ContentType.html
          ..write(htmlContent)
          ..close();
      });

      if (mounted) {
        setState(() {
          _serverUrl = 'http://127.0.0.1:$port';
        });
      }
    } catch (e) {
      log('Error starting local server: $e');
    }
  }

  @override
  void dispose() {
    _localServer?.close(force: true);
    log('YouTube local server stopped');
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_serverUrl == null) {
      return const Center(
        child: CircularProgressIndicator(color: Colors.red),
      );
    }

    return InAppWebView(
      initialUrlRequest: URLRequest(
        url: WebUri(_serverUrl!),
      ),
      initialSettings: InAppWebViewSettings(
        javaScriptEnabled: true,
        mediaPlaybackRequiresUserGesture: false,
        allowsInlineMediaPlayback: true,
        isElementFullscreenEnabled: true,
      ),
      onWebViewCreated: (controller) {
        _webViewController = controller;
        log("YouTube WebView created");

        // Register handler for JS → Dart communication
        controller.addJavaScriptHandler(
          handlerName: 'YouTubePlayerHandler',
          callback: (args) {
            if (args.isEmpty) return;
            final data = args[0];
            final event = data['event'];
            if (event == 'onReady') {
              log("YouTube player ready");
              widget.onReady?.call();
            } else if (event == 'onStateChange') {
              final state = data['data'];
              if (state == 0) {
                // YT.PlayerState.ENDED
                widget.onEnded?.call();
              }
            } else if (event == 'onError') {
              log("YouTube player error: ${data['data']}");
            }
          },
        );
      },
      onLoadStop: (controller, url) {
        log("YouTube page loaded: $url");
        // Inject videoId and settings after page loads
        final autoplay = widget.config.playback.autoPlay ? 1 : 0;
        final mute = widget.config.playback.mute ? 1 : 0;
        controller.evaluateJavascript(
          source: "initPlayer('${widget.videoId}', $autoplay, $mute);",
        );
      },
      onConsoleMessage: (controller, consoleMessage) {
        log("JS: ${consoleMessage.message}");
      },
    );
  }

  // Public control methods
  void play() => _webViewController?.evaluateJavascript(source: "playVideo();");
  void pause() =>
      _webViewController?.evaluateJavascript(source: "pauseVideo();");
  void seekTo(int seconds) =>
      _webViewController?.evaluateJavascript(source: "seekTo($seconds);");
  void mute() => _webViewController?.evaluateJavascript(source: "muteVideo();");
  void unMute() =>
      _webViewController?.evaluateJavascript(source: "unMuteVideo();");
}
