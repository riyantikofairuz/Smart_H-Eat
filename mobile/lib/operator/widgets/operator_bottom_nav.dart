import 'package:flutter/material.dart';
import '../constants/app_colors.dart';

/// Reusable Bottom Navigation Bar for the Operator Interface of Smart H-EAT.
/// Displays 3 tabs: Dashboard (0), Stok (1), and Laporan (2).
/// The currently selected item is highlighted with a rounded terracotta capsule button.
class OperatorBottomNav extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int>? onTabSelected;
  final ValueChanged<int>? onTap;

  const OperatorBottomNav({
    super.key,
    required this.currentIndex,
    this.onTabSelected,
    this.onTap,
  });

  void _handleTap(int index) {
    if (onTap != null) {
      onTap!(index);
    } else if (onTabSelected != null) {
      onTabSelected!(index);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(
          top: BorderSide(color: Color(0xFFF1F5F9), width: 1.0),
        ),
        boxShadow: [
          BoxShadow(
            color: Color.fromRGBO(0, 0, 0, 0.05),
            blurRadius: 10,
            offset: Offset(0, -2),
          ),
        ],
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: SafeArea(
        top: false,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            // Tab 0: Dashboard
            _buildNavItem(
              index: 0,
              icon: Icons.grid_view_rounded,
              label: 'Dashboard',
            ),

            // Tab 1: Stok
            _buildCustomNavItem(
              index: 1,
              label: 'Stok',
              builder: (color) => StokNavIcon(color: color, size: 21),
            ),

            // Tab 2: Laporan
            _buildNavItem(
              index: 2,
              icon: Icons.bar_chart_rounded,
              label: 'Laporan',
              iconSize: 24,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNavItem({
    required int index,
    required IconData icon,
    required String label,
    double iconSize = 21,
  }) {
    return _buildCustomNavItem(
      index: index,
      label: label,
      builder: (color) => Icon(icon, color: color, size: iconSize),
    );
  }

  Widget _buildCustomNavItem({
    required int index,
    required String label,
    required Widget Function(Color color) builder,
  }) {
    final isSelected = currentIndex == index;

    if (isSelected) {
      return GestureDetector(
        onTap: () => _handleTap(index),
        child: Container(
          width: 76,
          height: 62,
          decoration: BoxDecoration(
            color: AppColors.primary,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withValues(alpha: 0.28),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              builder(Colors.white),
              const SizedBox(height: 3),
              Text(
                label,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => _handleTap(index),
      child: SizedBox(
        width: 76,
        height: 62,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            builder(AppColors.textPrimary),
            const SizedBox(height: 3),
            Text(
              label,
              style: const TextStyle(
                color: AppColors.textPrimary,
                fontSize: 11,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Custom vector icon for the Stok navigation tab matching the design screenshots
class StokNavIcon extends StatelessWidget {
  final Color color;
  final double size;

  const StokNavIcon({
    super.key,
    required this.color,
    this.size = 21,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        painter: _StokNavIconPainter(color: color),
      ),
    );
  }
}

class _StokNavIconPainter extends CustomPainter {
  final Color color;

  _StokNavIconPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final w = size.width;
    final h = size.height;

    // Outer container / tray base with angled left edge
    final trayPath = Path()
      ..moveTo(w * 0.20, h * 0.32)
      ..lineTo(w * 0.16, h * 0.88)
      ..lineTo(w * 0.84, h * 0.88)
      ..lineTo(w * 0.84, h * 0.52);
    canvas.drawPath(trayPath, paint);

    // Inner horizontal shelves / slots
    canvas.drawLine(
      Offset(w * 0.28, h * 0.54),
      Offset(w * 0.74, h * 0.54),
      paint,
    );
    canvas.drawLine(
      Offset(w * 0.28, h * 0.70),
      Offset(w * 0.74, h * 0.70),
      paint,
    );

    // Angled top tab / handle
    final tabPath = Path()
      ..moveTo(w * 0.48, h * 0.14)
      ..lineTo(w * 0.48, h * 0.32)
      ..lineTo(w * 0.80, h * 0.32);
    canvas.drawPath(tabPath, paint);
  }

  @override
  bool shouldRepaint(covariant _StokNavIconPainter oldDelegate) =>
      oldDelegate.color != color;
}
