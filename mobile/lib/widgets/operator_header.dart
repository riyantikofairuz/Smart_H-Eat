import 'package:flutter/material.dart';
import '../constants/app_colors.dart';

/// Reusable Header widget for the Operator Interface of Smart H-EAT.
/// Seamlessly supports both:
/// - Top-level Operator screens (Login, Dashboard, Stock) from teman's implementation.
/// - Inner views with back button & branding from user's views.
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
    this.topPadding = 16.0,
    this.horizontalPadding = 24.0,
  });

  @override
  Widget build(BuildContext context) {
    // 1. Teman's layout for top-level screens (where title is 'Smart H-EAT')
    if (title == 'Smart H-EAT' && (onBack == null && showBackButton != true)) {
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
                color: Color(0xFF1E293B),
                letterSpacing: -0.5,
                height: 1.1,
              ),
            ),
            const SizedBox(height: 6),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3.5),
              decoration: BoxDecoration(
                color: AppColors.operatorBadgeBg,
                borderRadius: BorderRadius.circular(5),
              ),
              child: const Text(
                'OPERATOR MODE',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                  color: AppColors.operatorBadgeText,
                  letterSpacing: 0.6,
                ),
              ),
            ),
          ],
        ),
      );
    }

    // 2. User's layout for inner views with back navigation and branding
    final bool effectiveShowBack = showBackButton ?? (onBack != null || Navigator.of(context).canPop());

    return Padding(
      padding: EdgeInsets.only(
        top: topPadding == 16.0 ? 0.0 : topPadding,
        left: horizontalPadding == 24.0 ? 0.0 : horizontalPadding,
        right: horizontalPadding == 24.0 ? 0.0 : horizontalPadding,
        bottom: 8.0,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
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
            const SizedBox(height: 16),
          ],

          // Navigation row (Back button & Title & optional trailing)
          Row(
            children: [
              if (effectiveShowBack) ...[
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
