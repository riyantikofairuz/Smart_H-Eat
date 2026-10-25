import 'package:flutter/material.dart';
import '../../core/constants/menu_image_helper.dart';
import '../../core/theme/app_colors.dart';
import '../../models/menu_model.dart';
import '../../services/dummy_data_service.dart';
import '../../widgets/add_menu_overlay.dart';
import '../../widgets/operator_header.dart';

class StockScreen extends StatefulWidget {
  const StockScreen({super.key});

  @override
  State<StockScreen> createState() => _StockScreenState();
}

class _StockScreenState extends State<StockScreen> with SingleTickerProviderStateMixin {
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
    MenuImageHelper.ensureInitialized().then((_) {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _speedDialController.dispose();
    super.dispose();
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

  @override
  Widget build(BuildContext context) {
    final dummy = DummyDataService();

    return AnimatedBuilder(
      animation: dummy,
      builder: (context, _) {
        final categories = dummy.categories;
        final allMenus = dummy.menus;

        // Filter list based on selected category
        final filteredMenus = _selectedCategoryId == 0
            ? allMenus
            : allMenus.where((m) => m.categoryId == _selectedCategoryId).toList();

        return Scaffold(
          backgroundColor: AppColors.background,
          body: Stack(
            children: [
              SafeArea(
                child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 1. Header: H-EAT & OPERATOR MODE
                const OperatorHeader(
                  topPadding: 16,
                  horizontalPadding: 20,
                ),

                const SizedBox(height: 14),

                // 2. Title: "Daftar Menu Tersedia"
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20),
                  child: Text(
                    'Daftar Menu Tersedia',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF0F172A),
                      letterSpacing: -0.2,
                    ),
                  ),
                ),

                const SizedBox(height: 12),

                // 3. Category Filter Chips (Horizontal Scrollable)
                _buildCategoryChips(categories, dummy),

                const SizedBox(height: 14),

                // 4. Menu Items List
                Expanded(
                  child: filteredMenus.isEmpty
                      ? _buildEmptyState()
                      : ListView.separated(
                          padding: const EdgeInsets.fromLTRB(20, 2, 20, 84),
                          itemCount: filteredMenus.length,
                          separatorBuilder: (_, _) => const SizedBox(height: 12),
                          itemBuilder: (context, index) {
                            return _buildMenuCard(context, filteredMenus[index], dummy);
                          },
                        ),
                ),
              ],
            ),
          ),
          if (_isSpeedDialOpen)
                Positioned.fill(
                  child: GestureDetector(
                    key: const Key('speed_dial_barrier'),
                    behavior: HitTestBehavior.opaque,
                    onTap: _closeSpeedDial,
                    child: Container(
                      color: Colors.black.withValues(alpha: 0.18),
                    ),
                  ),
                ),
            ],
          ),
          floatingActionButton: _buildSpeedDial(context),
        );
      },
    );
  }

  Widget _buildSpeedDial(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        if (_isSpeedDialOpen) ...[
          // 1. Top: Tambah Kategori (Dark Navy Button + White Label Pill)
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
                  AddMenuOverlay.showAddCategoryDialog(context);
                },
              ),
            ),
          ),
          const SizedBox(height: 14),

          // 2. Middle (Right above FAB): Tambah Menu (Orange Button + White Label Pill)
          FadeTransition(
            opacity: _speedDialAnimation,
            child: ScaleTransition(
              scale: _speedDialAnimation,
              alignment: Alignment.bottomRight,
              child: _buildSpeedDialItem(
                key: const Key('speed_dial_add_menu'),
                buttonColor: AppColors.operatorNavActive,
                icon: Icons.restaurant_rounded,
                label: 'Tambah Menu',
                onTap: () {
                  _closeSpeedDial();
                  AddMenuOverlay.showAddMenuDialog(context);
                },
              ),
            ),
          ),
          const SizedBox(height: 16),
        ],
        FloatingActionButton(
          key: const Key('stock_fab_add'),
          heroTag: 'stock_fab_add',
          onPressed: _toggleSpeedDial,
          backgroundColor: AppColors.operatorNavActive,
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
                fontSize: 13.5,
                fontWeight: FontWeight.w700,
                color: Color(0xFF0F172A),
                letterSpacing: 0.1,
              ),
            ),
          ),
          const SizedBox(width: 12),
          // Circular mini action button, horizontally centered above 56px FAB
          SizedBox(
            width: 56,
            child: Center(
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

  /// Horizontal Category Chips matching the reference screenshot:
  /// Semua (12), Nasi (6), Sup & Kuah (2), Mie & Pasta (4)
  /// Menggunakan SingleChildScrollView horizontal agar dapat digeser mulus
  /// dan seluruh teks kategori tampil utuh tanpa terpotong.
  Widget _buildCategoryChips(List categories, DummyDataService dummy) {
    final totalCount = dummy.menus.length;

    return SizedBox(
      height: 38,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Chip "Semua"
            _buildCategoryChipItem(
              categoryId: 0,
              title: 'Semua ($totalCount)',
              isSelected: _selectedCategoryId == 0,
            ),
            // Chips kategori lainnya
            for (final category in categories) ...[
              const SizedBox(width: 8),
              _buildCategoryChipItem(
                categoryId: category.id,
                title: '${category.name} (${dummy.getCategoryCount(category.id)})',
                isSelected: _selectedCategoryId == category.id,
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
          color: isSelected
              ? AppColors.operatorNavActive
              : AppColors.inputBackground,
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

  /// Menu Card styled in soft lavender with rounded corners, action buttons, and image thumbnail
  Widget _buildMenuCard(
    BuildContext context,
    MenuModel menu,
    DummyDataService dummy,
  ) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.inputBackground,
        borderRadius: BorderRadius.circular(16),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Left Content: Title, Stock Info, and Action Buttons
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                // Nama Menu
                Text(
                  menu.name,
                  style: const TextStyle(
                    fontSize: 15.5,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF0F172A),
                    letterSpacing: -0.2,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),

                const SizedBox(height: 4),

                // Kategori & Karakteristik Makanan (SKPPL)
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (menu.characteristic != null && menu.characteristic!.isNotEmpty) ...[
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                        decoration: BoxDecoration(
                          color: _getCharacteristicBgColor(menu.characteristic!),
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(
                            color: _getCharacteristicBorderColor(menu.characteristic!),
                            width: 0.8,
                          ),
                        ),
                        child: Text(
                          menu.characteristic!,
                          style: TextStyle(
                            fontSize: 10.5,
                            fontWeight: FontWeight.w700,
                            color: _getCharacteristicTextColor(menu.characteristic!),
                          ),
                        ),
                      ),
                      const SizedBox(width: 6),
                    ],
                    Text(
                      menu.categoryName,
                      style: const TextStyle(
                        fontSize: 11.5,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF64748B),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 5),

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
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const TextSpan(
                        text: ' • ',
                        style: TextStyle(
                          color: Color(0xFF94A3B8),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      TextSpan(
                        text: 'Slot maks: ${menu.maxSlot}',
                        style: const TextStyle(
                          color: Color(0xFF64748B),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 10),

                // Action Buttons: Edit and Hapus
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Tombol Edit
                    _buildActionButton(
                      icon: Icons.edit_outlined,
                      iconColor: const Color(0xFFB45309),
                      label: 'Edit',
                      textColor: const Color(0xFF334155),
                      borderColor: const Color(0xFFE2E8F0),
                      onTap: () => AddMenuOverlay.showEditMenuDialog(context, menu),
                    ),

                    const SizedBox(width: 8),

                    // Tombol Hapus
                    _buildActionButton(
                      icon: Icons.delete_outline_rounded,
                      iconColor: const Color(0xFFDC2626),
                      label: 'Hapus',
                      textColor: const Color(0xFFDC2626),
                      borderColor: const Color(0xFFFEE2E2),
                      onTap: () => _confirmDeleteMenu(context, menu, dummy),
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(width: 14),

          // Right Content: Image Thumbnail / Placeholder
          _buildMenuThumbnail(menu),
        ],
      ),
    );
  }

  /// Thumbnail foto menu makanan atau placeholder terstruktur
  Widget _buildMenuThumbnail(MenuModel menu) {
    final imagePath = MenuImageHelper.resolveExistingAssetPath(menu);

    return Container(
      width: 58,
      height: 58,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: const Color(0xFFE2E8F0),
          width: 0.8,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(13),
        child: imagePath == null
            ? _buildImagePlaceholder(menu)
            : (imagePath.startsWith('http://') || imagePath.startsWith('https://'))
                ? Image.network(
                    imagePath,
                    width: 58,
                    height: 58,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      debugPrint('[MenuImage] Gagal memuat URL "$imagePath" untuk "${menu.name}": $error');
                      return _buildImagePlaceholder(menu);
                    },
                  )
                : Image.asset(
                    imagePath,
                    width: 58,
                    height: 58,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      debugPrint('[MenuImage] Gagal memuat aset "$imagePath" untuk "${menu.name}": $error');
                      return _buildImagePlaceholder(menu);
                    },
                  ),
      ),
    );
  }

  /// Placeholder visual yang rapi dan terhindar dari crash jika file foto belum ada
  Widget _buildImagePlaceholder(MenuModel menu) {
    final icon = MenuImageHelper.getCategoryIcon(menu.categoryName);
    return Container(
      width: 58,
      height: 58,
      color: const Color(0xFFF8FAFC),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: const Color(0xFF94A3B8),
              size: 24,
            ),
            const SizedBox(height: 2),
            Container(
              width: 14,
              height: 2,
              decoration: BoxDecoration(
                color: const Color(0xFFCBD5E1),
                borderRadius: BorderRadius.circular(1),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Small pill action button (Edit / Hapus) matching screenshot
  Widget _buildActionButton({
    required IconData icon,
    required Color iconColor,
    required String label,
    required Color textColor,
    required Color borderColor,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(10),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 6),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: borderColor, width: 1.0),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 14, color: iconColor),
              const SizedBox(width: 5),
              Text(
                label,
                style: TextStyle(
                  fontSize: 11.5,
                  fontWeight: FontWeight.w700,
                  color: textColor,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _getCharacteristicBgColor(String characteristic) {
    switch (characteristic.toLowerCase()) {
      case 'lembab':
        return const Color(0xFFFEF3C7);
      case 'banjir':
      case 'berkuah':
      case 'basah':
        return const Color(0xFFE0F2FE);
      case 'kering':
      default:
        return const Color(0xFFF1F5F9);
    }
  }

  Color _getCharacteristicTextColor(String characteristic) {
    switch (characteristic.toLowerCase()) {
      case 'lembab':
        return const Color(0xFFB45309);
      case 'banjir':
      case 'berkuah':
      case 'basah':
        return const Color(0xFF0369A1);
      case 'kering':
      default:
        return const Color(0xFF475569);
    }
  }

  Color _getCharacteristicBorderColor(String characteristic) {
    switch (characteristic.toLowerCase()) {
      case 'lembab':
        return const Color(0xFFFDE68A);
      case 'banjir':
      case 'berkuah':
      case 'basah':
        return const Color(0xFFBAE6FD);
      case 'kering':
      default:
        return const Color(0xFFE2E8F0);
    }
  }

  /// Dialog konfirmasi hapus menu dari data dummy/state lokal
  void _confirmDeleteMenu(
    BuildContext context,
    MenuModel menu,
    DummyDataService dummy,
  ) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text(
          'Hapus Menu?',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w800,
            color: Color(0xFF0F172A),
          ),
        ),
        content: Text(
          'Apakah Anda yakin ingin menghapus "${menu.name}" dari daftar menu mesin vending?',
          style: const TextStyle(fontSize: 13, color: Color(0xFF475569)),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              final success = dummy.deleteMenu(menu.id);
              if (success) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Menu "${menu.name}" berhasil dihapus!'),
                    backgroundColor: AppColors.alertBadge,
                    behavior: SnackBarBehavior.floating,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.alertBadge,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );
  }

  /// State kosong jika filter kategori tidak memiliki menu
  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.restaurant_menu_rounded,
                size: 38,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: 14),
            const Text(
              'Tidak Ada Menu Tersedia',
              style: TextStyle(
                fontSize: 15.5,
                fontWeight: FontWeight.w800,
                color: AppColors.textDark,
              ),
            ),
            const SizedBox(height: 6),
            const Text(
              'Kategori ini belum memiliki menu terdaftar. Silakan pilih kategori lain atau gunakan tombol (+) untuk menambahkan menu.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 12,
                color: AppColors.textMuted,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 14),
            ElevatedButton(
              onPressed: () {
                setState(() => _selectedCategoryId = 0);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              child: const Text('Lihat Semua Menu'),
            ),
          ],
        ),
      ),
    );
  }
}
