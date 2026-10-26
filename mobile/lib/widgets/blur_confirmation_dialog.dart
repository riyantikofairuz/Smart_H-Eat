import 'dart:math';
import 'dart:ui';

import 'package:flutter/material.dart';

/// Helper function to display a centered confirmation dialog with a strong
/// background blur (25px) and semi-transparent dark overlay.
///
/// Ensures:
/// - Screen behind dialog is heavily blurred.
/// - Dialog card remains 100% sharp and readable.
/// - Outside taps cannot dismiss the dialog ([barrierDismissible] = false).
/// - Android hardware/gesture back button cannot bypass confirmation ([PopScope.canPop] = false).
Future<T?> showBlurModal<T>({
  required BuildContext context,
  required Widget child,
}) {
  return showGeneralDialog<T>(
    context: context,
    barrierDismissible: false,
    barrierLabel: 'BlurConfirmationDialog',
    barrierColor: Colors.transparent, // Handled explicitly in Stack overlay
    transitionDuration: const Duration(milliseconds: 220),
    pageBuilder: (dialogContext, animation, secondaryAnimation) {
      final screenWidth = MediaQuery.of(dialogContext).size.width;
      // Width around 80% of tablet screen (max 560px for comfortable reading)
      final dialogWidth = min(screenWidth * 0.82, 540.0);

      return PopScope(
        canPop: false,
        child: Stack(
          alignment: Alignment.center,
          children: [
            // Strong background blur with dark translucent overlay
            Positioned.fill(
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 25, sigmaY: 25),
                child: Container(color: Colors.black.withValues(alpha: 0.55)),
              ),
            ),
            // Sharp, fully opaque dialog card in exact center
            Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 24,
                ),
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    maxWidth: dialogWidth,
                    minWidth: 300,
                  ),
                  child: child,
                ),
              ),
            ),
          ],
        ),
      );
    },
    transitionBuilder: (context, animation, secondaryAnimation, child) {
      final curved = CurvedAnimation(
        parent: animation,
        curve: Curves.easeOutCubic,
      );
      return FadeTransition(
        opacity: curved,
        child: ScaleTransition(
          scale: Tween<double>(begin: 0.94, end: 1.0).animate(curved),
          child: child,
        ),
      );
    },
  );
}

/// A reusable confirmation dialog styled for the Smart H-Eat design system.
class BlurConfirmationDialog extends StatelessWidget {
  final Key? dialogKey;
  final String title;
  final String description;
  final Widget? summaryContent;
  final String primaryButtonText;
  final VoidCallback onPrimaryPressed;
  final Key? primaryButtonKey;
  final String secondaryButtonText;
  final VoidCallback onSecondaryPressed;
  final Key? secondaryButtonKey;
  final Axis buttonsAxis;

  static const Color _primaryOrange = Color(0xFFAB2F00);
  static const Color _textDark = Color(0xFF1E1E1E);

  const BlurConfirmationDialog({
    super.key,
    this.dialogKey,
    required this.title,
    required this.description,
    this.summaryContent,
    required this.primaryButtonText,
    required this.onPrimaryPressed,
    this.primaryButtonKey,
    required this.secondaryButtonText,
    required this.onSecondaryPressed,
    this.secondaryButtonKey,
    this.buttonsAxis = Axis.vertical,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: Container(
        key: dialogKey,
        padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 26),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.20),
              blurRadius: 30,
              spreadRadius: 0,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Title
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w800,
                color: _textDark,
                letterSpacing: -0.2,
              ),
            ),
            const SizedBox(height: 12),

            // Description
            Text(
              description,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 14,
                height: 1.45,
                color: Color(0xFF555555),
                fontWeight: FontWeight.w500,
              ),
            ),

            // Optional Summary Box (item count & total payment)
            if (summaryContent != null) ...[
              const SizedBox(height: 18),
              summaryContent!,
            ],

            const SizedBox(height: 24),

            if (buttonsAxis == Axis.horizontal) ...[
              Row(
                children: [
                  // Secondary Button (e.g. Batal)
                  Expanded(
                    child: SizedBox(
                      height: 50,
                      child: OutlinedButton(
                        key: secondaryButtonKey,
                        onPressed: onSecondaryPressed,
                        style: OutlinedButton.styleFrom(
                          foregroundColor: _primaryOrange,
                          side: const BorderSide(
                            color: _primaryOrange,
                            width: 1.5,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Text(
                          secondaryButtonText,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: _primaryOrange,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  // Primary Button (e.g. Hapus Menu)
                  Expanded(
                    child: SizedBox(
                      height: 50,
                      child: ElevatedButton(
                        key: primaryButtonKey,
                        onPressed: onPrimaryPressed,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _primaryOrange,
                          foregroundColor: Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Text(
                          primaryButtonText,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ] else ...[
              // Primary Button
              SizedBox(
                height: 50,
                child: ElevatedButton(
                  key: primaryButtonKey,
                  onPressed: onPrimaryPressed,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _primaryOrange,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    primaryButtonText,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 10),

              // Secondary Button
              SizedBox(
                height: 50,
                child: OutlinedButton(
                  key: secondaryButtonKey,
                  onPressed: onSecondaryPressed,
                  style: OutlinedButton.styleFrom(
                    foregroundColor: _primaryOrange,
                    side: const BorderSide(color: _primaryOrange, width: 1.5),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    secondaryButtonText,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: _primaryOrange,
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
