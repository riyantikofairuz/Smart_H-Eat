import 'package:flutter/material.dart';
import '../../constants/app_colors.dart';
import '../../core/constants/menu_image_helper.dart';
import '../../models/menu_model.dart';
import '../../services/dummy_operator_service.dart';
import '../../widgets/operator_bottom_nav.dart';
import '../category/add_category_view.dart';
import 'add_menu_view.dart';
import 'edit_menu_view.dart';

/// Halaman Stok / Daftar Menu Tersedia Operator
/// Sesuai Gambar 3 & Gambar 4 dari Figma PBL-313.
/// Menampilkan chip filter kategori, daftar kartu menu (Edit & Hapus),
/// serta Speed Dial FAB pop-up untuk Tambah Kategori & Tambah Menu.
class MenuListView extends StatefulWidget {
  final ValueChanged<int>? onNavigateTab;

  const MenuListView({
    super.key,
    this.onNavigateTab,
  });

  @override
  State<MenuListView> createState() => _MenuListViewState();
}

class _MenuListViewState extends State<MenuListView> with SingleTickerProviderStateMixin {
  final DummyOperatorService _service = DummyOperatorService();
  int _selectedCategoryId = 0; // 0 = Semua

  bool _isSpeedDialOpen = false;
  late AnimationController _speedDialController;
  late Animation<double> _speedDialAnimation;

  @override
  void initState() {
    super.initState();
    _speedDialController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 220),
    );
    _speedDialAnimation = CurvedAnimation(
      parent: _speedDialController,
      curve: Curves.easeOutCubic,
      reverseCurve: Curves.easeInCubic,
    );
    _service.addListener(_onServiceUpdate);
    MenuImageHelper.ensureInitialized().then((_) {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _speedDialController.dispose();
    _service.removeListener(_onServiceUpdate);
    super.dispose();
  }

  void _onServiceUpdate() {
    if (mounted) setState(() {});
  }

  void _toggleSpeedDial() {
    setState(() {
      _isSpeedDialOpen = !_isSpeedDialOpen;
      if (_isSpeedDialOpen) {
        _speedDialController.forward();
      } else {
        _speedDialController.reverse();
      }
    });
  }

  void _closeSpeedDial() {
    if (_isSpeedDialOpen) {
      setState(() {
        _isSpeedDialOpen = false;
        _speedDialController.reverse();
      });
    }
  }

  void _handleDeleteMenu(MenuModel menu) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Hapus Menu', style: TextStyle(fontWeight: FontWeight.bold)),
        content: Text('Apakah Anda yakin ingin menghapus "${menu.name}" dari mesin vending?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Batal', style: TextStyle(color: AppColors.textSecondary)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.deleteRed,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            onPressed: () {
              _service.deleteMenu(menu.menuId);
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Menu "${menu.name}" berhasil dihapus'),
                  backgroundColor: AppColors.deleteRed,
                ),
              );
            },
            child: const Text('Hapus', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final categories = _service.categories;
    final allMenus = _service.menus;

    final filteredMenus = _selectedCategoryId == 0
        ? allMenus
        : allMenus.where((m) => m.categoryId == _selectedCategoryId).toList();

    return Scaffold(
      backgroundColor: AppColors.background,
      floatingActionButton: _buildSpeedDial(context),
      body: Stack(
        children: [
          SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 16),

                // Top-Left Smart H-EAT Branding Header matching SalesReportView & OperatorHeader
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Row(
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
                ),

                const SizedBox(height: 16),

                // Judul Halaman: "Daftar Menu Tersedia"
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20),
                  child: Text(
                    'Daftar Menu Tersedia',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF0F172A),
                      letterSpacing: -0.2,
                    ),
                  ),
                ),

                const SizedBox(height: 14),

                // Category Filter Chips (Horizontal Scrollable)
                _buildCategoryChips(categories, allMenus),

                const SizedBox(height: 14),

                // Menu items list
                Expanded(
                  child: filteredMenus.isEmpty
                      ? _buildEmptyState()
                      : ListView.separated(
                          padding: const EdgeInsets.fromLTRB(20, 2, 20, 80),
                          itemCount: filteredMenus.length,
                          separatorBuilder: (_, _) => const SizedBox(height: 12),
                          itemBuilder: (context, index) {
                            return _buildMenuCard(filteredMenus[index]);
                          },
                        ),
                ),

                // Bottom Navigation
                OperatorBottomNav(
                  currentIndex: 1, // Stok Tab
                  onTap: (index) {
                    _closeSpeedDial();
                    if (widget.onNavigateTab != null) {
                      widget.onNavigateTab!(index);
                    }
                  },
                ),
              ],
            ),
          ),

          // Speed Dial Barrier Overlay (Dims background when open)
          if (_isSpeedDialOpen)
            Positioned.fill(
              child: GestureDetector(
                key: const Key('speed_dial_barrier'),
                behavior: HitTestBehavior.opaque,
                onTap: _closeSpeedDial,
                child: Container(
                  color: Colors.black.withValues(alpha: 0.25),
                ),
              ),
            ),
        ],
      ),
    );
  }

  /// Category filter chips matching Image 3:
  /// Semua (12), Nasi (6), Sup & Kuah (2), Mie & Pasta (4), dll.
  Widget _buildCategoryChips(List categories, List<MenuModel> allMenus) {
    final totalCount = allMenus.length;

    return SizedBox(
      height: 38,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildCategoryChipItem(
              categoryId: 0,
              title: 'Semua ($totalCount)',
              isSelected: _selectedCategoryId == 0,
            ),
            for (final cat in categories) ...[
              const SizedBox(width: 8),
              _buildCategoryChipItem(
                categoryId: cat.categoryId,
                title: '${cat.name} (${allMenus.where((m) => m.categoryId == cat.categoryId).length})',
                isSelected: _selectedCategoryId == cat.categoryId,
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryChipItem({
    required int categoryId,
    required String title,
    required bool isSelected,
  }) {
    return InkWell(
      onTap: () {
        _closeSpeedDial();
        setState(() {
          _selectedCategoryId = categoryId;
        });
      },
      borderRadius: BorderRadius.circular(20),
      child: Container(
        height: 38,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFC2410C) : const Color(0xFFEDEFFF),
          borderRadius: BorderRadius.circular(20),
        ),
        alignment: Alignment.center,
        child: Text(
          title,
          maxLines: 1,
          softWrap: false,
          style: TextStyle(
            fontSize: 12.5,
            fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
            color: isSelected ? Colors.white : const Color(0xFF334155),
          ),
        ),
      ),
    );
  }

  /// Kartu Menu sesuai Gambar 3:
  /// - Background: Color(0xFFEDEFFF)
  /// - Nama Menu
  /// - Sisa saat ini: X porsi • Slot maks: Y
  /// - Tombol Edit & Tombol Hapus (Tanpa Restock & Variasi)
  /// - Gambar / Thumbnail di sebelah kanan
  Widget _buildMenuCard(MenuModel menu) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFEDEFFF), // Soft lavender matching Figma
        borderRadius: BorderRadius.circular(16),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Left Content: Title, Stock Info, and Action Buttons (Edit & Hapus)
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                // Nama Menu
                Text(
                  menu.name,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF0F172A),
                    letterSpacing: -0.2,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),

                const SizedBox(height: 6),

                // Info: "Sisa saat ini: 6 porsi • Slot maks: 6"
                RichText(
                  text: TextSpan(
                    style: const TextStyle(
                      fontSize: 12,
                      fontFamily: 'Inter',
                    ),
                    children: [
                      const TextSpan(
                        text: 'Sisa saat ini: ',
                        style: TextStyle(
                          color: Color(0xFF64748B),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      TextSpan(
                        text: '${menu.stock} porsi',
                        style: const TextStyle(
                          color: Color(0xFF0F172A),
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const TextSpan(
                        text: ' • ',
                        style: TextStyle(
                          color: Color(0xFF94A3B8),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const TextSpan(
                        text: 'Slot maks: ',
                        style: TextStyle(
                          color: Color(0xFF64748B),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      TextSpan(
                        text: '${menu.slotCapacity}',
                        style: const TextStyle(
                          color: Color(0xFF0F172A),
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 12),

                // Action Buttons: Edit and Hapus (Sesuai Gambar 3)
                Row(
                  children: [
                    // Tombol Edit
                    InkWell(
                      key: Key('menu_edit_${menu.menuId}'),
                      onTap: () {
                        _closeSpeedDial();
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => EditMenuView(
                              menuId: menu.menuId,
                              onBack: () => Navigator.pop(context),
                              onNavigateTab: widget.onNavigateTab,
                            ),
                          ),
                        );
                      },
                      borderRadius: BorderRadius.circular(8),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: const Color(0xFFCBD5E1),
                            width: 1.0,
                          ),
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.edit_outlined,
                              size: 14,
                              color: Color(0xFF334155),
                            ),
                            SizedBox(width: 4),
                            Text(
                              'Edit',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF334155),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(width: 8),

                    // Tombol Hapus
                    InkWell(
                      key: Key('menu_delete_${menu.menuId}'),
                      onTap: () {
                        _closeSpeedDial();
                        _handleDeleteMenu(menu);
                      },
                      borderRadius: BorderRadius.circular(8),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: const Color(0xFFFCA5A5),
                            width: 1.0,
                          ),
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.delete_outline_rounded,
                              size: 14,
                              color: AppColors.deleteRed,
                            ),
                            SizedBox(width: 4),
                            Text(
                              'Hapus',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: AppColors.deleteRed,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(width: 14),

          // Right Thumbnail Container (Sesuai Gambar 3)
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: const Color(0xFFE2E8F0),
                width: 1.0,
              ),
            ),
            clipBehavior: Clip.antiAlias,
            child: _buildThumbnailImage(menu),
          ),
        ],
      ),
    );
  }

  Widget _buildThumbnailImage(MenuModel menu) {
    final assetPath = MenuImageHelper.resolveExistingAssetPath(menu);
    if (assetPath != null && assetPath.isNotEmpty) {
      return Image.asset(
        assetPath,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => const Center(
          child: Icon(
            Icons.image_outlined,
            size: 28,
            color: Color(0xFF94A3B8),
          ),
        ),
      );
    }

    // Default placeholder matching Gambar 3
    return const Center(
      child: Icon(
        Icons.image_outlined,
        size: 28,
        color: Color(0xFF94A3B8),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.fastfood_outlined,
            size: 48,
            color: const Color(0xFF94A3B8).withValues(alpha: 0.6),
          ),
          const SizedBox(height: 12),
          const Text(
            'Tidak ada menu pada kategori ini.',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Color(0xFF64748B),
            ),
          ),
        ],
      ),
    );
  }

  /// Speed Dial Pop-up Button sesuai Gambar 4:
  /// - FAB (+) dinaikkan agar melayang nyaman di atas bottom navigation bar (tidak menutupi tab Laporan)
  /// - FAB (+) berubah jadi (X) saat terbuka
  /// - Pop-up opsi 1: "Tambah Menu" (tombol bulat oranye + ikon sendok-garpu + pill teks putih)
  /// - Pop-up opsi 2: "Tambah Kategori" (tombol bulat navy + ikon grid + pill teks putih)
  Widget _buildSpeedDial(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 70.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (_isSpeedDialOpen) ...[
            // Top: Tambah Kategori (Dark Navy Button + White Label Pill)
            FadeTransition(
              opacity: _speedDialAnimation,
              child: ScaleTransition(
                scale: _speedDialAnimation,
                alignment: Alignment.bottomRight,
                child: _buildSpeedDialItem(
                  key: const Key('speed_dial_add_category'),
                  buttonColor: const Color(0xFF0F172A),
                  icon: Icons.grid_view_rounded,
                  label: 'Tambah Kategori',
                  onTap: () {
                    _closeSpeedDial();
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => AddCategoryView(
                          onBack: () => Navigator.pop(context),
                          onNavigateTab: widget.onNavigateTab,
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),

            const SizedBox(height: 14),

            // Middle: Tambah Menu (Orange Button + White Label Pill)
            FadeTransition(
              opacity: _speedDialAnimation,
              child: ScaleTransition(
                scale: _speedDialAnimation,
                alignment: Alignment.bottomRight,
                child: _buildSpeedDialItem(
                  key: const Key('speed_dial_add_menu'),
                  buttonColor: const Color(0xFFC2410C),
                  icon: Icons.restaurant_rounded,
                  label: 'Tambah Menu',
                  onTap: () {
                    _closeSpeedDial();
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => AddMenuView(
                          onBack: () => Navigator.pop(context),
                          onNavigateTab: widget.onNavigateTab,
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),

            const SizedBox(height: 16),
          ],

          // Main FAB (+) and (X)
          FloatingActionButton(
            key: const Key('stock_fab_add'),
            heroTag: 'stock_fab_add',
            onPressed: _toggleSpeedDial,
            backgroundColor: const Color(0xFFC2410C),
            elevation: 4,
            shape: const CircleBorder(),
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 200),
              transitionBuilder: (child, animation) => RotationTransition(
                turns: animation,
                child: FadeTransition(opacity: animation, child: child),
              ),
              child: Icon(
                _isSpeedDialOpen ? Icons.close_rounded : Icons.add_rounded,
                key: ValueKey<bool>(_isSpeedDialOpen),
                color: Colors.white,
                size: 28,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSpeedDialItem({
    required Key key,
    required Color buttonColor,
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      key: key,
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.end,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // White label pill
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.12),
                  blurRadius: 8,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: Color(0xFF0F172A),
              ),
            ),
          ),

          const SizedBox(width: 12),

          // Circular Icon Button
          Material(
            color: Colors.transparent,
            shape: const CircleBorder(),
            child: InkWell(
              onTap: onTap,
              customBorder: const CircleBorder(),
              child: Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: buttonColor,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.15),
                      blurRadius: 8,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Center(
                  child: Icon(
                    icon,
                    color: Colors.white,
                    size: 22,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
