import 'package:flutter/material.dart';

/// Helper pengelola animasi terbang (fly-to-cart).
///
/// Memunculkan elemen gambar produk pada [OverlayEntry], menggerakkannya dari
/// posisi awal [startRect] menuju target [targetCenter] (ikon keranjang di header),
/// mengecilkan ukuran dan memudarkannya (fade-out), lalu memanggil [onCompleted].
class FlyToCartAnimation {
  static void run({
    required BuildContext context,
    required String imagePath,
    required Rect startRect,
    required Offset targetCenter,
    Duration duration = const Duration(milliseconds: 600),
    Curve curve = Curves.easeInOutCubic,
    required VoidCallback onCompleted,
  }) {
    final overlayState = Overlay.maybeOf(context);
    if (overlayState == null) {
      // Fallback aman jika overlay tidak tersedia (misal di beberapa unit test)
      onCompleted();
      return;
    }

    late OverlayEntry entry;
    bool isCompleted = false;

    void finish() {
      if (isCompleted) return;
      isCompleted = true;
      try {
        entry.remove();
      } catch (_) {
        // Abaikan jika sudah terhapus
      }
      onCompleted();
    }

    entry = OverlayEntry(
      builder: (context) {
        return _FlyToCartWidget(
          imagePath: imagePath,
          startRect: startRect,
          targetCenter: targetCenter,
          duration: duration,
          curve: curve,
          onFinish: finish,
        );
      },
    );

    overlayState.insert(entry);
  }
}

class _FlyToCartWidget extends StatefulWidget {
  final String imagePath;
  final Rect startRect;
  final Offset targetCenter;
  final Duration duration;
  final Curve curve;
  final VoidCallback onFinish;

  const _FlyToCartWidget({
    required this.imagePath,
    required this.startRect,
    required this.targetCenter,
    required this.duration,
    required this.curve,
    required this.onFinish,
  });

  @override
  State<_FlyToCartWidget> createState() => _FlyToCartWidgetState();
}

class _FlyToCartWidgetState extends State<_FlyToCartWidget>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: widget.duration);

    _animation = CurvedAnimation(parent: _controller, curve: widget.curve);

    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        widget.onFinish();
      }
    });

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Ukuran awal elemen terbang: thumbnail elegan berbasis proporsi hero
    final double initialWidth = (widget.startRect.width * 0.45).clamp(
      120.0,
      180.0,
    );
    final double initialHeight = initialWidth * (9.0 / 16.0);
    const double targetSize = 22.0;

    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        final double t = _animation.value;

        // 1. Posisi pusat (lerp dari start center ke target center)
        final Offset currentCenter = Offset.lerp(
          widget.startRect.center,
          widget.targetCenter,
          t,
        )!;

        // 2. Ukuran (mengecil bertahap menuju targetSize)
        final double currentWidth = Tween<double>(
          begin: initialWidth,
          end: targetSize,
        ).transform(t);
        final double currentHeight = Tween<double>(
          begin: initialHeight,
          end: targetSize,
        ).transform(t);

        // 3. Opacity (tetap solid di sebagian besar rute, lalu memudar halus saat mendekati keranjang)
        final double opacity = (1.0 - (t - 0.70).clamp(0.0, 0.30) / 0.30).clamp(
          0.0,
          1.0,
        );

        // 4. Border radius (beradaptasi saat mengecil)
        final double borderRadius = Tween<double>(
          begin: 14.0,
          end: 11.0,
        ).transform(t);

        return Positioned(
          left: currentCenter.dx - (currentWidth / 2),
          top: currentCenter.dy - (currentHeight / 2),
          width: currentWidth,
          height: currentHeight,
          child: IgnorePointer(
            child: Opacity(
              opacity: opacity,
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(borderRadius),
                  border: Border.all(
                    color: const Color(0xFFE85827),
                    width: 1.5,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFFE85827)
                          .withValues(alpha: 0.35 * (1.0 - t)),
                      blurRadius: 8,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(borderRadius - 1),
                  child: Image.asset(
                    widget.imagePath,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        color: const Color(0xFFFFECE5),
                        child: const Center(
                          child: Icon(
                            Icons.fastfood_outlined,
                            size: 16,
                            color: Color(0xFFE85827),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
