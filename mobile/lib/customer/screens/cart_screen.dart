import 'package:flutter/material.dart';

import '../models/cart_item.dart';
import '../providers/cart_provider.dart';
import '../widgets/blur_confirmation_dialog.dart';
import '../widgets/smart_heat_header.dart';
import 'menu_screen.dart';
import 'payment_screen.dart';

/// SCR-04 — Halaman Keranjang (Cart Page)
///
/// Mengimplementasikan halaman keranjang pesanan dengan target tablet portrait
/// (resolusi referensi 720 × 1280).
/// Menangani:
/// - Header persisten (Back, SMART H-EAT / Keranjang)
/// - Filled state (daftar kartu, quantity selector, total akhir, hapus semua)
/// - Empty state (tombol tambah menu, total akhir Rp 0, tombol pembayaran disabled)
/// - Kalkulasi total real-time dan sinkronisasi badge
class CartScreen extends StatelessWidget {
  const CartScreen({super.key});

  static const Color _primaryOrange = Color(0xFFAB2F00);
  static const Color _cardPeach = Color(0xFFFFE1D1);
  static const Color _textDark = Color(0xFF1E1E1E);

  void _handleBack(BuildContext context) {
    Navigator.of(context).pop();
  }

  void _handleBackToMenu(BuildContext context) {
    if (Navigator.of(context).canPop()) {
      Navigator.of(context).popUntil((route) => route.isFirst);
    } else {
      Navigator.of(
        context,
      ).pushReplacement(MaterialPageRoute(builder: (_) => const MenuScreen()));
    }
  }

  Future<void> _handleCheckout(BuildContext context) async {
    final cart = CartProvider.of(context);
    final items = cart.items;
    if (items.isEmpty) return;

    final grandTotal = items.fold(0, (sum, item) => sum + item.totalPrice);
    final totalQuantity = items.fold(0, (sum, item) => sum + item.quantity);

    final confirmed = await showBlurModal<bool>(
      context: context,
      child: BlurConfirmationDialog(
        dialogKey: const ValueKey('order_confirmation_dialog'),
        title: 'Konfirmasi Pesanan',
        description: 'Pastikan semua menu dan jumlah pesanan Anda sudah sesuai sebelum melanjutkan ke pembayaran.',
        summaryContent: _buildOrderSummary(
          items.length,
          totalQuantity,
          grandTotal,
        ),
        primaryButtonText: 'Ya, Lanjut ke Pembayaran',
        primaryButtonKey: const ValueKey('confirm_order_button'),
        onPrimaryPressed: () => Navigator.of(context).pop(true),
        secondaryButtonText: 'Belum, Tambah Menu',
        secondaryButtonKey: const ValueKey('cancel_order_confirmation_button'),
        onSecondaryPressed: () => Navigator.of(context).pop(false),
      ),
    );

    if (!context.mounted) return;

    if (confirmed == true) {
      Navigator.of(context)
          .push(MaterialPageRoute(builder: (context) => const PaymentPage()));
    } else if (confirmed == false) {
      _handleBackToMenu(context);
    }
  }

  Future<void> _handleDecrement(
    BuildContext context,
    CartNotifier cart,
    CartItem item,
  ) async {
    if (item.quantity > 1) {
      cart.decrementItem(item);
      return;
    }

    final confirmed = await showBlurModal<bool>(
      context: context,
      child: BlurConfirmationDialog(
        dialogKey: const ValueKey('delete_item_confirmation_dialog'),
        title: 'Hapus menu dari keranjang?',
        description: 'Menu ini akan dihapus dari keranjang. Apakah Anda yakin ingin melanjutkan?',
        primaryButtonText: 'Hapus Menu',
        primaryButtonKey: const ValueKey('confirm_delete_item_button'),
        onPrimaryPressed: () => Navigator.of(context).pop(true),
        secondaryButtonText: 'Batal',
        secondaryButtonKey: const ValueKey('cancel_delete_item_button'),
        onSecondaryPressed: () => Navigator.of(context).pop(false),
        buttonsAxis: Axis.horizontal,
      ),
    );

    if (!context.mounted) return;

    if (confirmed == true) {
      cart.removeItem(item);
    }
  }

  Widget _buildOrderSummary(
    int uniqueCount,
    int totalQuantity,
    int grandTotal,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: const Color(0xFFF9F9FB),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFEEEEEE), width: 1),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Jumlah Item',
                style: TextStyle(
                  fontSize: 14,
                  color: Color(0xFF666666),
                  fontWeight: FontWeight.w500,
                ),
              ),
              Text(
                '$totalQuantity porsi ($uniqueCount menu)',
                style: const TextStyle(
                  fontSize: 14,
                  color: _textDark,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          const Divider(height: 1, color: Color(0xFFEEEEEE)),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Total Pembayaran',
                style: TextStyle(
                  fontSize: 14,
                  color: Color(0xFF666666),
                  fontWeight: FontWeight.w500,
                ),
              ),
              Text(
                _formatRupiah(grandTotal),
                style: const TextStyle(
                  fontSize: 16,
                  color: _primaryOrange,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final cart = CartProvider.of(context);
    final items = cart.items;
    final grandTotal = items.fold(0, (sum, item) => sum + item.totalPrice);

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // ── Header (Persisten, tidak ikut bergulir) ─────────────────────
            SmartHeatHeader(
              pageTitle: 'Keranjang',
              onBack: () => _handleBack(context),
              showLogo: false,
              simpleBack: true,
            ),

            // ── Area Konten Utama ───────────────────────────────────────────
            Expanded(
              child: items.isEmpty
                  ? _buildEmptyState(context)
                  : _buildFilledState(context, cart, items),
            ),

            // ── Panel Bawah (Persisten, Total Akhir & Tombol Pembayaran) ────
            _buildBottomPanel(context, items.isEmpty, grandTotal),
          ],
        ),
      ),
    );
  }

  /// Tampilan Empty State sesuai Keranjang Kosong.png:
  /// Hanya tombol "+ Tambah Menu" di bagian atas tanpa ilustrasi dekoratif.
  Widget _buildEmptyState(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 20, 16, 0),
          child: SizedBox(
            height: 58,
            child: ElevatedButton(
              key: const ValueKey('tambah_menu_button'),
              onPressed: () => _handleBackToMenu(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: _primaryOrange,
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.add_circle_outline, color: Colors.white, size: 24),
                  SizedBox(width: 8),
                  Text(
                    'Tambah Menu',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        const Spacer(),
      ],
    );
  }

  /// Tampilan Filled State saat keranjang memiliki minimal 1 baris item.
  Widget _buildFilledState(
    BuildContext context,
    CartNotifier cart,
    List<CartItem> items,
  ) {
    return Column(
      children: [
        // Baris Judul: Menu Pesanan (X) di kiri, Hapus Semua di kanan
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Menu Pesanan (${items.length})',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: _textDark,
                ),
              ),
              GestureDetector(
                key: const ValueKey('hapus_semua_button'),
                onTap: () {
                  cart.clear();
                },
                child: const Text(
                  'Hapus Semua',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: _primaryOrange,
                  ),
                ),
              ),
            ],
          ),
        ),

        // Daftar kartu item yang dapat digulir mandiri
        Expanded(
          child: ListView.separated(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            itemCount: items.length,
            separatorBuilder: (context, idx) => const SizedBox(height: 14),
            itemBuilder: (context, index) {
              final item = items[index];
              return _CartItemTile(
                key: ValueKey(
                  'cart_item_${item.productId}_${item.spiceLevel}_${item.selectedToppings.map((t) => t.id).join("_")}',
                ),
                item: item,
                onIncrement: () => cart.incrementItem(item),
                onDecrement: () => _handleDecrement(context, cart, item),
              );
            },
          ),
        ),
      ],
    );
  }

  /// Panel Bawah: Total Akhir dan Tombol Lanjut ke Pembayaran.
  Widget _buildBottomPanel(BuildContext context, bool isEmpty, int grandTotal) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, -3),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Kotak Total Akhir
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 18),
              decoration: BoxDecoration(
                color: _cardPeach,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                children: [
                  const Text(
                    'Total Akhir',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: _textDark,
                    ),
                  ),
                  const Spacer(),
                  const Text(
                    ':',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: _textDark,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Text(
                    _formatRupiah(grandTotal),
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w900,
                      color: _textDark,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 14),

            // Tombol Lanjut ke Pembayaran
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                key: const ValueKey('checkout_button'),
                onPressed: isEmpty ? null : () => _handleCheckout(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: _primaryOrange,
                  disabledBackgroundColor: _primaryOrange,
                  foregroundColor: Colors.white,
                  disabledForegroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: const Text(
                  'Lanjut ke Pembayaran',
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  static String _formatRupiah(int amount) {
    final s = amount.toString();
    final buf = StringBuffer();
    int count = 0;
    for (int i = s.length - 1; i >= 0; i--) {
      buf.write(s[i]);
      count++;
      if (count % 3 == 0 && i != 0) buf.write('.');
    }
    return 'Rp ${buf.toString().split('').reversed.join('')}';
  }
}

/// Kartu Item Keranjang sesuai Keranjang.png
class _CartItemTile extends StatelessWidget {
  final CartItem item;
  final VoidCallback onIncrement;
  final VoidCallback onDecrement;

  const _CartItemTile({
    super.key,
    required this.item,
    required this.onIncrement,
    required this.onDecrement,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFFFE1D1),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Thumbnail produk membulat
          ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: SizedBox(
              width: 88,
              height: 88,
              child: Image.asset(
                item.productImagePath,
                fit: BoxFit.cover,
                errorBuilder: (ctx, err, stack) => Container(
                  color: const Color(0xFFFFECE5),
                  child: const Icon(
                    Icons.fastfood_outlined,
                    color: Color(0xFFAB2F00),
                    size: 32,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 14),

          // Detail item (Nama, Kepedasan, Topping, Harga & Selector)
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Nama Produk
                Text(
                  item.productName,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF1E1E1E),
                  ),
                ),
                if (item.spiceLevel.isNotEmpty) ...[
                  const SizedBox(height: 3),
                  Text(
                    item.spiceLevel,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey.shade700,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
                if (item.selectedToppings.isNotEmpty) ...[
                  const SizedBox(height: 2),
                  Text(
                    item.selectedToppings.map((t) => t.name).join(', '),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 11,
                      color: Colors.grey.shade700,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      item.formattedTotalPrice,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w900,
                        color: Color(0xFF1E1E1E),
                      ),
                    ),
                    _QuantitySelector(
                      quantity: item.quantity,
                      onIncrement: onIncrement,
                      onDecrement: onDecrement,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Quantity Selector: Kotak pil putih berisi tombol [-], angka, tombol [+] berbayang halus
class _QuantitySelector extends StatelessWidget {
  final int quantity;
  final VoidCallback onIncrement;
  final VoidCallback onDecrement;

  const _QuantitySelector({
    required this.quantity,
    required this.onIncrement,
    required this.onDecrement,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      padding: const EdgeInsets.all(3),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.08),
                  blurRadius: 4,
                  offset: const Offset(0, 1),
                ),
              ],
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                key: const ValueKey('decrement_button'),
                borderRadius: BorderRadius.circular(8),
                onTap: onDecrement,
                child: const Center(
                  child: Icon(Icons.remove, size: 16, color: Color(0xFF1E1E1E)),
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Text(
              '$quantity',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w800,
                color: Color(0xFF1E1E1E),
              ),
            ),
          ),
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.08),
                  blurRadius: 4,
                  offset: const Offset(0, 1),
                ),
              ],
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                key: const ValueKey('increment_button'),
                borderRadius: BorderRadius.circular(8),
                onTap: onIncrement,
                child: const Center(
                  child: Icon(Icons.add, size: 16, color: Color(0xFF1E1E1E)),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
