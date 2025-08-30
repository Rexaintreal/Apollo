import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:provider/provider.dart';
import '../models/playlist_provider.dart';

class DancingCat extends StatefulWidget {
  const DancingCat({super.key});

  @override
  State<DancingCat> createState() => _DancingCatState();
}

class _DancingCatState extends State<DancingCat>
    with TickerProviderStateMixin {
  late AnimationController _danceController;
  late Ticker _ticker;

  // Position of cat
  double x = 100, y = 100;
  double dx = 2, dy = 2; // velocity

  @override
  void initState() {
    super.initState();

    // Animation controller for nodding left/right
    _danceController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    )..repeat(reverse: true);

    // Ticker for bouncing across the screen
    _ticker = createTicker((elapsed) {
      setState(() {
        final screen =
            // ignore: deprecated_member_use
            MediaQueryData.fromView(WidgetsBinding.instance.window).size;

        x += dx;
        y += dy;

        const catSize = 80.0;

        // bounce horizontally
        if (x <= 0 || x + catSize >= screen.width) {
          dx = -dx;
        }

        // bounce vertically
        if (y <= 0 || y + catSize >= screen.height - 100) {
          dy = -dy;
        }
      });
    });
  }

  @override
  void dispose() {
    _danceController.dispose();
    _ticker.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final playlistProvider = context.watch<PlaylistProvider>();
    final isPlaying = playlistProvider.isPlaying;
    final position = playlistProvider.currentDuration.inMilliseconds;

    if (!isPlaying) {
      _danceController.stop();
      _ticker.stop();
      return const SizedBox.shrink(); // hide the cat when music is off
    } else {
      // Update speed for fake "beat sync"
      final speed = 300 + (position % 400);
      _danceController.duration =
          Duration(milliseconds: speed.clamp(200, 700));

      if (!_danceController.isAnimating) {
        _danceController.repeat(reverse: true);
      }
      if (!_ticker.isActive) _ticker.start();
    }

    return Positioned(
      left: x,
      top: y,
      child: AnimatedBuilder(
        animation: _danceController,
        builder: (context, child) {
          // flip horizontally left/right
          final flip = _danceController.value > 0.5 ? -1.0 : 1.0;
          final scale = 1.0 + (_danceController.value * 0.2);

          return Transform(
            alignment: Alignment.center,
            transform: Matrix4.identity()
              ..scale(flip * scale, scale),
            child: child,
          );
        },
        child: Image.asset(
          "assets/cat.png",
          width: 80,
          height: 80,
          filterQuality: FilterQuality.none,
        ),
      ),
    );
  }
}
