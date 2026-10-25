import 'package:flutter/material.dart';
import '../constants/app_colors.dart';

/// Reusable Header widget for the Operator Interface of Smart H-EAT.
/// Displays the H-EAT brand logo, OPERATOR MODE badge, optional back button,
/// page title, and optional trailing action.
class OperatorHeader extends StatelessWidget {
  final String title;
  final bool? showBackButton;
  final bool showBranding;
  final VoidCallback? onBack;
  final Widget? trailing;
  final double topPadding;
  final double horizontalPadding;

  const OperatorHeader({
    super.key,
    this.title = 'Smart H-EAT',
    this.showBackButton,
    this.showBranding = true,
    this.onBack,
    this.trailing,
    this.topPadding = 0.0,
    this.horizontalPadding = 0.0,
  });

  bool get _effectiveShowBack => showBackButton ?? (title != 'Smart H-EAT');

  @override
  Widget build(BuildContext context) {
    final bool hasNavRow = _effectiveShowBack || trailing != null || (title != 'Smart H-EAT' && title.isNotEmpty);

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
          // Brand logo & Operator badge
          if (showBranding) ...[
            Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(6),
                  child: Image.asset(
                    'assets/images/smart_heat_logo.png',
                    width: 30,
                    height: 30,
                    fit: BoxFit.contain,
                    errorBuilder: (context, error, stackTrace) => Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.12),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.local_fire_department_rounded,
                        color: AppColors.primary,
                        size: 18,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'SMART H-EAT',
                      style: TextStyle(
                        fontSize: 12.5,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 0.8,
                        color: Color(0xFF000000),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: AppColors.operatorBadgeBg,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: const Text(
                        'OPERATOR MODE',
                        style: TextStyle(
                          fontSize: 9.5,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 0.8,
                          color: AppColors.operatorBadgeText,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
            if (hasNavRow) const SizedBox(height: 16),
          ],

          // Navigation row (Back button & Title & optional trailing)
          if (hasNavRow)
            Row(
              children: [
                if (_effectiveShowBack) ...[
                  GestureDetector(
                    onTap: onBack ?? () => Navigator.of(context).maybePop(),
                    child: Container(
                      width: 38,
                      height: 38,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        border: Border.all(color: AppColors.border, width: 1.2),
                        boxShadow: const [
                          BoxShadow(
                            color: Color.fromRGBO(0, 0, 0, 0.04),
                            blurRadius: 4,
                            offset: Offset(0, 2),
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.arrow_back_ios_new_rounded,
                        size: 16,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ),
                  const SizedBox(width: 14),
                ],
                Expanded(
                  child: Text(
                    title,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
                ?trailing,
              ],
            ),
        ],
      ),
    );
  }
}
