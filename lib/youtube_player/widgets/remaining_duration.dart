import 'package:flutter/material.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';

import '../utils/duration_formatter.dart';

/// A widget which displays the remaining duration of the video.
class RemainingDuration extends StatefulWidget {
  /// Creates [RemainingDuration] widget.
  const RemainingDuration({super.key, this.controller});

  /// Overrides the default [YoutubePlayerController].
  final YoutubePlayerController? controller;

  @override
  State<RemainingDuration> createState() => _RemainingDurationState();
}

class _RemainingDurationState extends State<RemainingDuration> {
  late YoutubePlayerController _controller;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final controller = YoutubePlayerController.of(context);
    if (controller == null) {
      assert(
        widget.controller != null,
        '\n\nNo controller could be found in the provided context.\n\n'
        'Try passing the controller explicitly.',
      );
      _controller = widget.controller!;
    } else {
      _controller = controller;
    }
    _controller.removeListener(listener);
    _controller.addListener(listener);
  }

  @override
  void dispose() {
    _controller.removeListener(listener);
    super.dispose();
  }

  void listener() {
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.ltr,
      child: Text(
        '- ${durationFormatter((_controller.metadata.duration.inMilliseconds) - (_controller.value.position.inMilliseconds))}',
        style: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w400,
          color: Colors.white,
        ),
      ),
    );
  }
}
