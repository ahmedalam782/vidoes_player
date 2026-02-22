// ignore_for_file: avoid_web_libraries_in_flutter, deprecated_member_use
import 'dart:html' as html;
import 'dart:ui_web' as ui_web;
import 'package:flutter/material.dart';

void registerYoutubeWebIframe(String viewId, String videoId, bool autoPlay) {
  ui_web.platformViewRegistry.registerViewFactory(viewId, (int id) {
    final iframe = html.IFrameElement()
      ..style.border = 'none'
      ..style.width = '100%'
      ..style.height = '100%'
      ..src =
          'https://www.youtube.com/embed/$videoId?autoplay=${autoPlay ? 1 : 0}&rel=0&vq=medium'
      ..allowFullscreen = true
      ..allow = 'autoplay; fullscreen';
    return iframe;
  });
}

Widget buildYoutubeWebIframe(String viewId) {
  return HtmlElementView(viewType: viewId);
}
