import 'package:flutter/material.dart';

/// Komponen visual logo aplikasi Smart H-Eat.
///
/// Menggunakan aset logo resmi `assets/images/smart_heat_logo.png`
/// dengan mempertahankan aspect ratio 1:1 tanpa distorsi/stretching.
class SmartHeatLogo extends StatelessWidget {
  /// Ukuran sisi persegi logo (default: 42).
  final double size;

  /// Lebar opsional jika ingin meng-override [size].
  final double? width;

  /// Tinggi opsional jika ingin meng-override [size].
  final double? height;

  const SmartHeatLogo({super.key, this.size = 42, this.width, this.height});

  @override
  Widget build(BuildContext context) {
    final effectiveWidth = width ?? size;
    final effectiveHeight = height ?? size;

    return Image.asset(
      'assets/images/smart_heat_logo.png',
      width: effectiveWidth,
      height: effectiveHeight,
      fit: BoxFit.contain,
      filterQuality: FilterQuality.medium,
    );
  }
}
