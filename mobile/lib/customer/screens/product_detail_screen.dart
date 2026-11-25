import 'package:flutter/material.dart';

import '../models/cart_item.dart';
import '../models/product_item.dart';
import '../models/topping_item.dart';
import '../providers/cart_provider.dart';
import '../widgets/fly_to_cart_animation.dart';
import '../widgets/smart_heat_header.dart';

/// SCR-03 — Detail Menu Page
///
/// Menampilkan detail produk dengan kesetiaan penuh terhadap desain referensi `Menu Detail.png`.
/// Menyediakan kontrol kustomisasi (porsi, kepedasan, topping) yang bersih dan minimalis,
/// serta tombol utama "Tambah pesanan" berwarna #AB2F00 dengan total harga real-time.
class ProductDetailScreen extends StatefulWidget {
  final ProductItem product;

  const ProductDetailScreen({super.key, required this.product});

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  // ── GlobalKey untuk mengukur posisi gambar produk untuk animasi terbang ────
  final GlobalKey _productImageKey = GlobalKey();

  // ── State kustomisasi pesanan ──────────────────────────────────────────────
  int _quantity = 1;
  String _spiceLevel = 'Tidak pedas';

  // Set ID topping yang dipilih (boleh lebih dari satu, independen)
  final Set<String> _selectedToppingIds = {};

  // Flag pencegah double-tap pada tombol "Tambah pesanan"
  bool _isAddingToCart = false;

  // ── Constants Palet Desain Referensi ───────────────────────────────────────
  static const _brandTerracotta = Color(
    0xFFAB2F00,
  ); // Warna tombol utama & brand
  static const _peachBackground = Color(
    0xFFFFE1D1,
  ); // Background wadah deskripsi
  static const _pageBackground = Color(0xFFFAF8FF); // Background halaman
  static const _neutralControl = Color(0xFF313131); // Kontrol pill kepedasan
  static const _spiceLevels = ['Tidak pedas', 'Sedang', 'Pedas'];

  // ── Kalkulasi harga ────────────────────────────────────────────────────────
  List<ToppingItem> get _selectedToppings => ToppingItem.defaultToppings
      .where((t) => _selectedToppingIds.contains(t.id))
      .toList();

  int get _toppingPricePerServing =>
      _selectedToppings.fold(0, (sum, t) => sum + t.price);

  int get _pricePerServing => widget.product.price + _toppingPricePerServing;

  int get _totalPrice => _pricePerServing * _quantity;

  String _formatRupiah(int amount) {
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

  // ── Tambah ke keranjang ────────────────────────────────────────────────────
  void _addToCart() {
    if (_isAddingToCart) return;
    setState(() => _isAddingToCart = true);

    final item = CartItem(
      productId: widget.product.id,
      productName: widget.product.name,
      productImagePath: widget.product.imagePath,
      basePrice: widget.product.price,
      quantity: _quantity,
      spiceLevel: _spiceLevel,
      selectedToppings: _selectedToppings,
    );

    final cartNotifier = CartProvider.of(context, listen: false);

    // Hitung koordinat awal gambar produk di Detail Menu
    final renderBox =
        _productImageKey.currentContext?.findRenderObject() as RenderBox?;
    final Rect startRect;
    if (renderBox != null && renderBox.hasSize && renderBox.attached) {
      final origin = renderBox.localToGlobal(Offset.zero);
      startRect = origin & renderBox.size;
    } else {
      final mediaQuery = MediaQuery.of(context);
      startRect = Rect.fromLTWH(0, 80, mediaQuery.size.width, 240);
    }

    // Target animasi adalah posisi ikon keranjang di header Menu Page
    final Offset targetCenter = cartNotifier.getCartIconCenter(context);

    // Jalankan animasi produk terbang menuju ikon keranjang
    FlyToCartAnimation.run(
      context: context,
      imagePath: widget.product.imagePath,
      startRect: startRect,
      targetCenter: targetCenter,
      onCompleted: () {
        // Simpan / gabungkan ke keranjang setelah animasi selesai
        cartNotifier.addItem(item);

        // Kembali ke Menu Page setelah berhasil menambahkan pesanan
        if (mounted) {
          Navigator.of(context).pop();
        }
      },
    );
  }

  // ── Build ──────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _pageBackground,
      // ── Fixed Bottom Bar Sesuai Desain Referensi ─────────────────────────────
      bottomNavigationBar: _buildBottomBar(),
      body: SafeArea(
        bottom: false, // bottom ditangani oleh bottomNavigationBar
        child: Column(
          children: [
            // ── Header: Sesuai Menu Detail.png (tanpa ikon keranjang, simple arrow) ──
            SmartHeatHeader(
              pageTitle: 'Detail Menu',
              showLogo: false,
              simpleBack: true,
              onBack: () => Navigator.of(context).pop(),
            ),

            // ── Scrollable Content ─────────────────────────────────────────────
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildHeroImage(),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildProductInfo(),
                          const SizedBox(height: 24),
                          _buildQuantitySection(),
                          const SizedBox(height: 24),
                          _buildSpiceSection(),
                          const SizedBox(height: 24),
                          _buildToppingSection(),
                          // Jarak aman agar konten tidak tertutup fixed bottom bar
                          const SizedBox(height: 120),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Section: Hero Image (Proporsi & Posisi Sesuai Referensi) ────────────────
  Widget _buildHeroImage() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(14, 14, 14, 0),
      child: ClipRRect(
        key: _productImageKey,
        borderRadius: BorderRadius.circular(8),
        child: AspectRatio(
          aspectRatio:
              1.08, // Mendekati 1:1 sesuai Menu Detail.png (2780 x 2584 px)
          child: Image.asset(
            widget.product.imagePath,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) {
              return Container(
                color: const Color(0xFFFFECE5),
                child: const Center(
                  child: Icon(
                    Icons.fastfood_outlined,
                    size: 64,
                    color: _brandTerracotta,
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  // ── Section: Product Info (Tipografi & Warna Sesuai Referensi) ──────────────
  Widget _buildProductInfo() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Nama produk: font besar, elegan, tidak terlalu tebal
        Text(
          widget.product.name,
          style: const TextStyle(
            fontSize: 34,
            fontWeight: FontWeight.w400,
            color: Color(0xFF000000),
            height: 1.15,
            letterSpacing: -0.5,
          ),
        ),
        const SizedBox(height: 8),

        // Harga: Hitam pekat, sangat tegas sesuai Menu Detail.png
        Text(
          widget.product.formattedPrice,
          style: const TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.w900,
            color: Color(0xFF000000),
            letterSpacing: -0.5,
          ),
        ),

        // Deskripsi dalam wadah peach (#FFE1D1) dengan sudut melengkung tanpa border
        if (widget.product.description != null) ...[
          const SizedBox(height: 16),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
            decoration: BoxDecoration(
              color: _peachBackground,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Text(
              widget.product.description!,
              style: const TextStyle(
                fontSize: 15,
                color: Color(0xFF000000),
                height: 1.45,
                fontWeight: FontWeight.w400,
              ),
            ),
          ),
        ],
      ],
    );
  }

  // ── Section: Quantity (Pengatur Jumlah Porsi yang Sederhana) ────────────────
  Widget _buildQuantitySection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Jumlah Porsi',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w800,
            color: Color(0xFF000000),
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            // Tombol minus
            _QuantityButton(
              icon: Icons.remove,
              enabled: _quantity > 1,
              onTap: () {
                if (_quantity > 1) setState(() => _quantity--);
              },
            ),
            // Tampilan angka
            SizedBox(
              width: 48,
              child: Center(
                child: Text(
                  '$_quantity',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF000000),
                  ),
                ),
              ),
            ),
            // Tombol plus
            _QuantityButton(
              icon: Icons.add,
              enabled: true,
              onTap: () => setState(() => _quantity++),
            ),
            const SizedBox(width: 12),
            const Text(
              'porsi',
              style: TextStyle(
                fontSize: 14,
                color: Color(0xFF666666),
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ],
    );
  }

  // ── Section: Spice Level (Pill Neutral #313131 Konsisten Menu) ─────────────
  Widget _buildSpiceSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Tingkat Kepedasan',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w800,
            color: Color(0xFF000000),
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: _spiceLevels.map((level) {
            final isActive = _spiceLevel == level;
            return Padding(
              padding: const EdgeInsets.only(right: 10),
              child: GestureDetector(
                onTap: () => setState(() => _spiceLevel = level),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 18,
                    vertical: 9,
                  ),
                  decoration: BoxDecoration(
                    color: isActive ? _neutralControl : Colors.transparent,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: _neutralControl, width: 1.5),
                  ),
                  child: Text(
                    level,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: isActive ? FontWeight.w700 : FontWeight.w600,
                      color: isActive ? Colors.white : _neutralControl,
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  // ── Section: Toppings (Bersih, Rapi, Tanpa Kartu Berulang) ─────────────────
  Widget _buildToppingSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Pilihan Topping',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w800,
            color: Color(0xFF000000),
          ),
        ),
        const SizedBox(height: 4),
        const Text(
          'Dapat memilih lebih dari satu',
          style: TextStyle(
            fontSize: 12,
            color: Color(0xFF666666),
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 10),
        ...ToppingItem.defaultToppings.map((topping) {
          final isSelected = _selectedToppingIds.contains(topping.id);
          return InkWell(
            onTap: () {
              setState(() {
                if (isSelected) {
                  _selectedToppingIds.remove(topping.id);
                } else {
                  _selectedToppingIds.add(topping.id);
                }
              });
            },
            borderRadius: BorderRadius.circular(8),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
              child: Row(
                children: [
                  // Checkbox sederhana
                  Container(
                    width: 20,
                    height: 20,
                    decoration: BoxDecoration(
                      color: isSelected ? _brandTerracotta : Colors.white,
                      borderRadius: BorderRadius.circular(5),
                      border: Border.all(
                        color: isSelected
                            ? _brandTerracotta
                            : const Color(0xFFB0ADB8),
                        width: 1.5,
                      ),
                    ),
                    child: isSelected
                        ? const Icon(Icons.check, color: Colors.white, size: 14)
                        : null,
                  ),
                  const SizedBox(width: 12),
                  // Nama topping
                  Expanded(
                    child: Text(
                      topping.name,
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: isSelected
                            ? FontWeight.w700
                            : FontWeight.w500,
                        color: const Color(0xFF1A1A1A),
                      ),
                    ),
                  ),
                  // Harga topping
                  Text(
                    topping.formattedPrice,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: isSelected
                          ? FontWeight.w700
                          : FontWeight.w600,
                      color: isSelected
                          ? _brandTerracotta
                          : const Color(0xFF666666),
                    ),
                  ),
                ],
              ),
            ),
          );
        }),
      ],
    );
  }

  // ── Bottom Action Bar (Warna #AB2F00 Sesuai Referensi Menu Detail.png) ─────
  Widget _buildBottomBar() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 10,
            offset: const Offset(0, -3),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 14, 24, 16),
          child: SizedBox(
            height: 60,
            width: double.infinity,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor:
                    _brandTerracotta, // Terracotta #AB2F00 dari referensi
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              onPressed: _isAddingToCart ? null : _addToCart,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    'Tambah pesanan',
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.3,
                    ),
                  ),
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 12),
                    width: 1.5,
                    height: 18,
                    color: Colors.white.withValues(alpha: 0.45),
                  ),
                  Text(
                    _formatRupiah(_totalPrice),
                    style: const TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ── Helper widget: Quantity Button Sederhana Tanpa Dekorasi Berlebih ───────────
class _QuantityButton extends StatelessWidget {
  final IconData icon;
  final bool enabled;
  final VoidCallback onTap;

  const _QuantityButton({
    required this.icon,
    required this.enabled,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: enabled ? onTap : null,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        width: 38,
        height: 38,
        decoration: BoxDecoration(
          color: enabled ? Colors.white : const Color(0xFFF5F4F8),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: enabled ? const Color(0xFF313131) : const Color(0xFFD6D3DC),
            width: 1.2,
          ),
        ),
        child: Center(
          child: Icon(
            icon,
            size: 20,
            color: enabled ? const Color(0xFF1A1A1A) : const Color(0xFFB0ADB8),
          ),
        ),
      ),
    );
  }
}
