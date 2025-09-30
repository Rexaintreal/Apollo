import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:provider/provider.dart';
import '../models/playlist_provider.dart';
import 'package:apollo/themes/cat_provider.dart';

class DancingCat extends StatefulWidget {
  const DancingCat({super.key});

  @override
  State<DancingCat> createState() => _DancingCatState();
}

class _DancingCatState extends State<DancingCat>
    with TickerProviderStateMixin {
  late AnimationController _danceController;
  late Ticker _ticker;

  double x = 100, y = 100;
  double dx = 2, dy = 2;

  @override
  void initState() {
    super.initState();
    _danceController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    )..repeat(reverse: true);

    _ticker = createTicker((elapsed) {
      setState(() {
        final screen =
            MediaQueryData.fromView(WidgetsBinding.instance.window).size;
        final catSize = context.read<CatProvider>().catSize;

        x += dx;
        y += dy;

        if (x <= 0 || x + catSize >= screen.width) dx = -dx;
        if (y <= 0 || y + catSize >= screen.height - 100) dy = -dy;
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
    final catProvider = context.watch<CatProvider>();

    final isPlaying = playlistProvider.isPlaying;
    final position = playlistProvider.currentDuration.inMilliseconds;
    final catSize = catProvider.catSize;

    if (!catProvider.isCatEnabled || !isPlaying) {
      _danceController.stop();
      _ticker.stop();
      return const SizedBox.shrink();
    }

    final speed = 300 + (position % 400);
    _danceController.duration = Duration(milliseconds: speed.clamp(200, 700));

    if (!_danceController.isAnimating) _danceController.repeat(reverse: true);

    if (catProvider.isMotionEnabled) {
      if (!_ticker.isActive) _ticker.start();
    } else {
      if (_ticker.isActive) _ticker.stop();
    }

    Widget catWidget = AnimatedBuilder(
      animation: _danceController,
      builder: (context, child) {
        final flip = _danceController.value > 0.5 ? -1.0 : 1.0;
        final scale = 1.0 + (_danceController.value * 0.2);
        return Transform(
          alignment: Alignment.center,
          transform: Matrix4.identity()..scale(flip * scale, scale),
          child: child,
        );
      },
      child: Opacity(
        opacity: catProvider.catOpacity, 
        child: SizedBox(
          width: catSize,
          height: catSize,
          child: Image.asset(
            catProvider.selectedCat,
            fit: BoxFit.contain,
            filterQuality: FilterQuality.none,
          ),
        ),
      ),
    );

    return Positioned(
      left: x,
      top: y,
      child: catProvider.isMotionEnabled
          ? catWidget
          : GestureDetector(
              onPanUpdate: (details) {
                setState(() {
                  x += details.delta.dx;
                  y += details.delta.dy;
                });
              },
              child: catWidget,
            ),
    );
  }
}
