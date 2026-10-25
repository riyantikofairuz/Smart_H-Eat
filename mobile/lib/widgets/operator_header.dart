import 'package:flutter/material.dart';
import '../core/theme/app_colors.dart';

class OperatorHeader extends StatelessWidget {
  final String title;
  final double topPadding;
  final double horizontalPadding;

  const OperatorHeader({
    super.key,
    this.title = 'Smart H-EAT',
    this.topPadding = 16.0,
    this.horizontalPadding = 24.0,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        top: topPadding,
        left: horizontalPadding,
        right: horizontalPadding,
        bottom: 8.0,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w900,
              color: AppColors.textDark,
              letterSpacing: -0.5,
              height: 1.1,
            ),
          ),
          const SizedBox(height: 6),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3.5),
            decoration: BoxDecoration(
              color: AppColors.badgeBackground,
              borderRadius: BorderRadius.circular(5),
            ),
            child: const Text(
              'OPERATOR MODE',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w800,
                color: AppColors.badgeText,
                letterSpacing: 0.6,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
