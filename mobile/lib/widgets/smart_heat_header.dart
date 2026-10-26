import 'package:flutter/material.dart';

import '../providers/cart_provider.dart';
import 'smart_heat_logo.dart';

/// Header bersama yang digunakan oleh SCR-02 (Menu Page) dan SCR-03 (Detail Menu).
///
/// Pada SCR-02: [onCartTap] diberikan, [onBack] dan [pageTitle] null.
/// Pada SCR-03: [onBack] diberikan, [pageTitle] = 'Detail Menu', [onCartTap] null.
class SmartHeatHeader extends StatelessWidget {
  /// Callback ketika ikon keranjang ditekan (SCR-02).
  final VoidCallback? onCartTap;

  /// Callback ketika tombol kembali ditekan (SCR-03).
  final VoidCallback? onBack;

  /// Judul halaman yang ditampilkan di bawah 'SMART H-EAT'.
  /// Default: 'Customer' (konsisten dengan SCR-02).
  final String pageTitle;

  /// GlobalKey opsional untuk tombol ikon keranjang.
  /// Jika tidak diberikan, menggunakan [cartNotifier.cartIconKey].
  final GlobalKey? cartKey;

  /// Apakah menampilkan logo di samping teks brand (default: true).
  final bool showLogo;

  /// Menggunakan tombol kembali sederhana berupa IconButton Icons.arrow_back (default: false).
  final bool simpleBack;

  const SmartHeatHeader({
    super.key,
    this.onCartTap,
    this.onBack,
    this.pageTitle = 'Customer',
    this.cartKey,
    this.showLogo = true,
    this.simpleBack = false,
  }) : assert(
         onCartTap != null || onBack != null,
         'SmartHeatHeader membutuhkan setidaknya satu dari onCartTap atau onBack.',
       );

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(28, 12, 28, 12),
      decoration: BoxDecoration(
        color: const Color(0xFFFAF8FF),
        border: const Border(
          bottom: BorderSide(color: Color(0xFFE2E0E8), width: 1.0),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            offset: const Offset(0, 2),
            blurRadius: 4,
          ),
        ],
      ),
      child: SafeArea(
        bottom: false,
        child: Row(
          children: [
            // ── Tombol kembali (SCR-03/SCR-04) atau spacer (SCR-02) ───────────
            if (onBack != null)
              if (simpleBack) ...[
                IconButton(
                  icon: const Icon(Icons.arrow_back, color: Color(0xFF1E1E1E)),
                  onPressed: onBack,
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(
                    minWidth: 36,
                    minHeight: 36,
                  ),
                ),
                const SizedBox(width: 8),
              ] else
                Padding(
                  padding: const EdgeInsets.only(right: 12),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: onBack,
                      borderRadius: BorderRadius.circular(14),
                      child: Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(14),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.05),
                              blurRadius: 4,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: const Center(
                          child: Icon(
                            Icons.arrow_back_ios_new_rounded,
                            color: Color(0xFF1E1E1E),
                            size: 20,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),

            // ── Logo ──────────────────────────────────────────────────────────
            if (showLogo) ...[
              const SmartHeatLogo(size: 52),
              const SizedBox(width: 12),
            ],

            // ── Brand Title ───────────────────────────────────────────────────
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'SMART H-EAT',
                  style: TextStyle(
                    color: Color(0xFFAB2F00),
                    fontSize: 13,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 0.8,
                  ),
                ),
                Text(
                  pageTitle,
                  style: const TextStyle(
                    color: Color(0xFF000000),
                    fontSize: 24,
                    fontWeight: FontWeight.w800,
                    height: 1.1,
                  ),
                ),
              ],
            ),

            const Spacer(),

            // ── Cart Button (SCR-02) ──────────────────────────────────────────
            if (onCartTap != null)
              Builder(
                builder: (context) {
                  final cartNotifier = CartProvider.maybeOf(context);
                  final uniqueCount = cartNotifier?.uniqueItemCount ?? 0;

                  final effectiveKey = cartKey ?? cartNotifier?.cartIconKey;

                  // Perbarui cache posisi ikon keranjang setelah render selesai
                  if (cartNotifier != null && effectiveKey != null) {
                    WidgetsBinding.instance.addPostFrameCallback((_) {
                      final box =
                          effectiveKey.currentContext?.findRenderObject()
                              as RenderBox?;
                      if (box != null && box.hasSize && box.attached) {
                        final origin = box.localToGlobal(Offset.zero);
                        cartNotifier.updateCartIconRect(origin & box.size);
                      }
                    });
                  }

                  return Stack(
                    clipBehavior: Clip.none,
                    children: [
                      Material(
                        key: effectiveKey,
                        color: Colors.transparent,
                        child: InkWell(
                          onTap: onCartTap,
                          borderRadius: BorderRadius.circular(20),
                          child: Container(
                            width: 68,
                            height: 68,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(20),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.06),
                                  blurRadius: 8,
                                  offset: const Offset(0, 3),
                                ),
                              ],
                            ),
                            child: const Center(
                              child: Icon(
                                Icons.shopping_cart_outlined,
                                color: Color(0xFF1E1E1E),
                                size: 30,
                              ),
                            ),
                          ),
                        ),
                      ),
                      // Badge jumlah item unik: disembunyikan jika kosong (0)
                      if (uniqueCount > 0)
                        Positioned(
                          top: -4,
                          right: -4,
                          child: IgnorePointer(
                            child: Container(
                              key: const ValueKey('cart_badge'),
                              constraints: const BoxConstraints(
                                minWidth: 22,
                                minHeight: 22,
                              ),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 5,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: const Color(0xFFAB2F00),
                                borderRadius: BorderRadius.circular(11),
                                border: Border.all(
                                  color: Colors.white,
                                  width: 2,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: const Color(0xFFAB2F00)
                                        .withValues(alpha: 0.35),
                                    blurRadius: 4,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: Center(
                                child: Text(
                                  '$uniqueCount',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 11,
                                    fontWeight: FontWeight.w900,
                                    height: 1.0,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                    ],
                  );
                },
              ),
          ],
        ),
      ),
    );
  }
}
