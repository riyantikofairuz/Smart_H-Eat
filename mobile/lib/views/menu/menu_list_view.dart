import 'package:flutter/material.dart';
import '../../constants/app_colors.dart';
import '../../models/menu_model.dart';
import '../../services/dummy_operator_service.dart';
import '../../widgets/operator_bottom_nav.dart';
import '../category/add_category_view.dart';
import '../restock/restock_report_view.dart';
import '../variations/manage_variations_view.dart';
import 'add_menu_view.dart';
import 'edit_menu_view.dart';

class MenuListView extends StatefulWidget {
  final ValueChanged<int>? onNavigateTab;

  const MenuListView({
    super.key,
    this.onNavigateTab,
  });

  @override
  State<MenuListView> createState() => _MenuListViewState();
}

class _MenuListViewState extends State<MenuListView> {
  final DummyOperatorService _service = DummyOperatorService();
  final TextEditingController _searchController = TextEditingController();
  int _selectedCategoryId = 0; // 0 means 'Semua'
  String _selectedStockStatus = 'Semua'; // 'Semua', 'Tersedia', 'Menipis', 'Habis' (UC-F018)
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _service.addListener(_onServiceUpdate);
  }

  @override
  void dispose() {
    _searchController.dispose();
    _service.removeListener(_onServiceUpdate);
    super.dispose();
  }

  void _onServiceUpdate() {
    if (mounted) setState(() {});
  }

  void _showAddActionSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Material(
        color: Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.border,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 20),
            ListTile(
              leading: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppColors.chipInactiveBg,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.category_rounded, color: AppColors.primary),
              ),
              title: const Text(
                'Tambah Kategori',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
              ),
              subtitle: const Text('Kelola dan buat kategori baru makanan'),
              trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 14),
              onTap: () {
                Navigator.pop(ctx);
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
            const Divider(height: 16),
            ListTile(
              leading: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppColors.primaryLight,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.restaurant_menu_rounded, color: AppColors.primary),
              ),
              title: const Text(
                'Tambah Menu Baru',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
              ),
              subtitle: const Text('Daftarkan menu makanan baru ke mesin vending'),
              trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 14),
              onTap: () {
                Navigator.pop(ctx);
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
            const Divider(height: 16),
            ListTile(
              leading: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppColors.chipInactiveBg,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.tune_rounded, color: AppColors.primary),
              ),
              title: const Text(
                'Kelola Variasi Menu',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
              ),
              subtitle: const Text('Atur grup dan pilihan variasi hidangan (UC-F017)'),
              trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 14),
              onTap: () {
                Navigator.pop(ctx);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ManageVariationsView(
                      onBack: () => Navigator.pop(context),
                      onNavigateTab: widget.onNavigateTab,
                    ),
                  ),
                );
              },
            ),
            const Divider(height: 16),
            ListTile(
              leading: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: const Color(0xFFEDFBF2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.history_rounded, color: AppColors.success),
              ),
              title: const Text(
                'Laporan Riwayat Restock',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
              ),
              subtitle: const Text('Lihat histori pengisian stok makanan (UC-F021)'),
              trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 14),
              onTap: () {
                Navigator.pop(ctx);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => RestockReportView(
                      onBack: () => Navigator.pop(context),
                      onNavigateTab: widget.onNavigateTab,
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 10),
          ],
        ),
      ),
    ),
  );
  }

  void _handleQuickRestock(MenuModel menu) {
    int addQty = (menu.slotCapacity - menu.stock).clamp(1, 5);
    if (menu.stock >= menu.slotCapacity) {
      addQty = 0;
    }

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setModalState) {
          final maxAddable = menu.slotCapacity - menu.stock;
          final isFull = maxAddable <= 0;

          return Container(
            padding: EdgeInsets.only(
              left: 20,
              right: 20,
              top: 20,
              bottom: MediaQuery.of(context).viewInsets.bottom + 24,
            ),
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: AppColors.border,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 18),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: AppColors.primaryLight,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(Icons.inventory_2_rounded, color: AppColors.primary, size: 22),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Restock Slot Mesin',
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                          ),
                          Text(
                            menu.name,
                            style: const TextStyle(fontSize: 13, color: AppColors.textSecondary),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceMuted,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Stok Saat Ini', style: TextStyle(fontSize: 11.5, color: AppColors.textSecondary)),
                          const SizedBox(height: 2),
                          Text(
                            '${menu.stock} Porsi',
                            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                          ),
                        ],
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Kapasitas Slot', style: TextStyle(fontSize: 11.5, color: AppColors.textSecondary)),
                          const SizedBox(height: 2),
                          Text(
                            '${menu.slotCapacity} Porsi',
                            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                          ),
                        ],
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Ruang Kosong', style: TextStyle(fontSize: 11.5, color: AppColors.textSecondary)),
                          const SizedBox(height: 2),
                          Text(
                            '$maxAddable Porsi',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                              color: maxAddable > 0 ? AppColors.primary : AppColors.success,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 18),
                if (isFull)
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFFEDFBF2),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.check_circle_rounded, color: AppColors.success, size: 18),
                        SizedBox(width: 8),
                        Text(
                          'Slot tray mesin sudah penuh!',
                          style: TextStyle(color: AppColors.success, fontWeight: FontWeight.bold, fontSize: 13),
                        ),
                      ],
                    ),
                  )
                else ...[
                  const Text(
                    'Jumlah Porsi yang Ditambahkan:',
                    style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
                  ),
                  const SizedBox(height: 10),
                  Wrap(
                    crossAxisAlignment: WrapCrossAlignment.center,
                    alignment: WrapAlignment.spaceBetween,
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            onPressed: addQty > 1 ? () => setModalState(() => addQty--) : null,
                            icon: const Icon(Icons.remove_circle_outline_rounded, size: 28),
                            color: AppColors.primary,
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                            decoration: BoxDecoration(
                              color: AppColors.chipInactiveBg,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text(
                              '+$addQty Porsi',
                              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                            ),
                          ),
                          IconButton(
                            onPressed: addQty < maxAddable ? () => setModalState(() => addQty++) : null,
                            icon: const Icon(Icons.add_circle_outline_rounded, size: 28),
                            color: AppColors.primary,
                          ),
                        ],
                      ),
                      TextButton.icon(
                        style: TextButton.styleFrom(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                        ),
                        onPressed: () => setModalState(() => addQty = maxAddable),
                        icon: const Icon(Icons.inventory_2_outlined, size: 16, color: AppColors.primary),
                        label: const Text('Isi Penuh Slot', style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.primary)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      onPressed: () {
                        if (addQty <= 0) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Jumlah restock harus lebih dari 0'),
                              backgroundColor: AppColors.deleteRed,
                            ),
                          );
                          return;
                        }
                        _service.restockMenu(menu.menuId, addQty);
                        Navigator.pop(ctx);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Berhasil restock +$addQty porsi untuk "${menu.name}"!'),
                            backgroundColor: AppColors.success,
                          ),
                        );
                      },
                      icon: const Icon(Icons.check_rounded, color: Colors.white),
                      label: Text(
                        'Konfirmasi Restock (Total: ${menu.stock + addQty} Porsi)',
                        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          );
        },
      ),
    );
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

  Widget _buildStockBadge(MenuModel menu) {
    Color bg;
    Color text;
    String label;
    if (menu.stock == 0) {
      bg = const Color(0xFFFDE8E8);
      text = AppColors.deleteRed;
      label = 'Stok Habis';
    } else if (menu.stock <= menu.minStock) {
      bg = const Color(0xFFFFF4E5);
      text = const Color(0xFFD97706);
      label = 'Menipis';
    } else {
      bg = const Color(0xFFE8FDF0);
      text = AppColors.success;
      label = 'Tersedia';
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2.5),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.bold,
          color: text,
        ),
      ),
    );
  }

  Widget _buildStockFilterChip(String label, String statusKey) {
    final isSelected = _selectedStockStatus == statusKey;
    return Padding(
      padding: const EdgeInsets.only(right: 6),
      child: FilterChip(
        label: Text(label),
        selected: isSelected,
        labelStyle: TextStyle(
          fontSize: 11,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
          color: isSelected ? Colors.white : AppColors.chipInactiveText,
        ),
        backgroundColor: AppColors.chipInactiveBg,
        selectedColor: AppColors.primary,
        showCheckmark: false,
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        side: BorderSide.none,
        onSelected: (_) {
          setState(() {
            _selectedStockStatus = statusKey;
          });
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final categories = _service.categories;
    final allMenus = _service.menus;

    final filteredMenus = allMenus.where((m) {
      final matchesCategory = _selectedCategoryId == 0 || m.categoryId == _selectedCategoryId;
      final matchesSearch = _searchQuery.isEmpty || m.name.toLowerCase().contains(_searchQuery);
      final matchesStock = _selectedStockStatus == 'Semua' ||
          (_selectedStockStatus == 'Tersedia' && m.stock > m.minStock) ||
          (_selectedStockStatus == 'Menipis' && m.stock <= m.minStock && m.stock > 0) ||
          (_selectedStockStatus == 'Habis' && m.stock == 0);
      return matchesCategory && matchesSearch && matchesStock;
    }).toList();

    return Scaffold(
      backgroundColor: AppColors.background,
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddActionSheet,
        backgroundColor: AppColors.primary,
        elevation: 4,
        shape: const CircleBorder(),
        child: const Icon(Icons.add, size: 28, color: Colors.white),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Header Brand
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
                                color: Color(0xFF000000), // Warna hitam (#000000)
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

                    // Title
                    const Text(
                      'Daftar Menu Tersedia',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Search Bar
                    Container(
                      height: 46,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColors.border),
                      ),
                      child: TextField(
                        controller: _searchController,
                        onChanged: (val) {
                          setState(() {
                            _searchQuery = val.trim().toLowerCase();
                          });
                        },
                        decoration: InputDecoration(
                          hintText: 'Cari menu makanan...',
                          hintStyle: const TextStyle(color: AppColors.textMuted, fontSize: 13.5),
                          prefixIcon: const Icon(Icons.search_rounded, color: AppColors.textSecondary, size: 20),
                          suffixIcon: _searchQuery.isNotEmpty
                              ? IconButton(
                                  icon: const Icon(Icons.clear_rounded, size: 18, color: AppColors.textSecondary),
                                  onPressed: () {
                                    _searchController.clear();
                                    setState(() => _searchQuery = '');
                                  },
                                )
                              : null,
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                      ),
                    ),
                    const SizedBox(height: 14),

                    // Filter categories chips
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [
                          _buildFilterChip(
                            id: 0,
                            label: 'Semua (${allMenus.length})',
                          ),
                          ...categories.map((cat) {
                            final count = allMenus.where((m) => m.categoryId == cat.categoryId).length;
                            return _buildFilterChip(
                              id: cat.categoryId,
                              label: '${cat.name} ($count)',
                            );
                          }),
                        ],
                      ),
                    ),
                    const SizedBox(height: 10),

                    // Stock Status Filter Chips (UC-F018)
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [
                          _buildStockFilterChip('Semua Stok', 'Semua'),
                          _buildStockFilterChip('Stok Tersedia', 'Tersedia'),
                          _buildStockFilterChip('Stok Menipis', 'Menipis'),
                          _buildStockFilterChip('Stok Habis', 'Habis'),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Quick Action Bar
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: AppColors.border),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: OutlinedButton.icon(
                              onPressed: () {
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
                              icon: const Icon(Icons.category_outlined, size: 16, color: AppColors.primary),
                              label: const Text(
                                'Kelola Kategori',
                                style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.primary),
                              ),
                              style: OutlinedButton.styleFrom(
                                side: const BorderSide(color: AppColors.primary, width: 1.2),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                padding: const EdgeInsets.symmetric(vertical: 8),
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: () {
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
                              icon: const Icon(Icons.add, size: 16, color: Colors.white),
                              label: const Text(
                                'Tambah Menu',
                                style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white),
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.primary,
                                elevation: 0,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                padding: const EdgeInsets.symmetric(vertical: 8),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Menu item cards
                    if (filteredMenus.isEmpty)
                      Container(
                        padding: const EdgeInsets.all(32),
                        alignment: Alignment.center,
                        child: Column(
                          children: [
                            Icon(Icons.search_off_rounded, size: 48, color: AppColors.textMuted.withValues(alpha: 0.6)),
                            const SizedBox(height: 12),
                            Text(
                              _searchQuery.isNotEmpty
                                  ? 'Tidak ditemukan menu dengan kata kunci "$_searchQuery".'
                                  : 'Belum ada menu pada kategori ini.',
                              textAlign: TextAlign.center,
                              style: const TextStyle(color: AppColors.textSecondary),
                            ),
                          ],
                        ),
                      )
                    else
                      ...filteredMenus.map((menu) {
                        return Container(
                          margin: const EdgeInsets.only(bottom: 12),
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(color: AppColors.border),
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Expanded(
                                          child: Text(
                                            menu.name,
                                            style: const TextStyle(
                                              fontSize: 15,
                                              fontWeight: FontWeight.bold,
                                              color: AppColors.textPrimary,
                                            ),
                                          ),
                                        ),
                                        _buildStockBadge(menu),
                                      ],
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      'Rp ${menu.price.toInt()} • Level: ${menu.spiciness}',
                                      style: const TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600,
                                        color: AppColors.primary,
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      'Sisa: ${menu.stock} porsi • Kapasitas slot: ${menu.slotCapacity}',
                                      style: const TextStyle(
                                        fontSize: 11.5,
                                        color: AppColors.textSecondary,
                                      ),
                                    ),
                                    const SizedBox(height: 10),
                                    Wrap(
                                      spacing: 6,
                                      runSpacing: 6,
                                      children: [
                                        // Restock button
                                        GestureDetector(
                                          onTap: () => _handleQuickRestock(menu),
                                          child: Container(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 8,
                                              vertical: 4.5,
                                            ),
                                            decoration: BoxDecoration(
                                              color: AppColors.primaryLight,
                                              borderRadius: BorderRadius.circular(6),
                                            ),
                                            child: const Row(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                Icon(
                                                  Icons.add_shopping_cart_rounded,
                                                  size: 13,
                                                  color: AppColors.primary,
                                                ),
                                                SizedBox(width: 4),
                                                Text(
                                                  'Restock',
                                                  style: TextStyle(
                                                    fontSize: 11,
                                                    fontWeight: FontWeight.w600,
                                                    color: AppColors.primary,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),

                                        // Edit button
                                        GestureDetector(
                                          onTap: () {
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
                                          child: Container(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 8,
                                              vertical: 4.5,
                                            ),
                                            decoration: BoxDecoration(
                                              color: AppColors.background,
                                              borderRadius: BorderRadius.circular(6),
                                              border: Border.all(color: AppColors.border),
                                            ),
                                            child: const Row(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                Icon(
                                                  Icons.edit_outlined,
                                                  size: 13,
                                                  color: AppColors.textPrimary,
                                                ),
                                                SizedBox(width: 4),
                                                Text(
                                                  'Edit',
                                                  style: TextStyle(
                                                    fontSize: 11,
                                                    fontWeight: FontWeight.w600,
                                                    color: AppColors.textPrimary,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),

                                        // Variasi button (UC-F017)
                                        GestureDetector(
                                          onTap: () {
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder: (context) => ManageVariationsView(
                                                  initialMenuId: menu.menuId,
                                                  onBack: () => Navigator.pop(context),
                                                  onNavigateTab: widget.onNavigateTab,
                                                ),
                                              ),
                                            );
                                          },
                                          child: Container(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 8,
                                              vertical: 4.5,
                                            ),
                                            decoration: BoxDecoration(
                                              color: AppColors.chipInactiveBg,
                                              borderRadius: BorderRadius.circular(6),
                                            ),
                                            child: const Row(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                Icon(
                                                  Icons.tune_rounded,
                                                  size: 13,
                                                  color: AppColors.primary,
                                                ),
                                                SizedBox(width: 4),
                                                Text(
                                                  'Variasi',
                                                  style: TextStyle(
                                                    fontSize: 11,
                                                    fontWeight: FontWeight.w600,
                                                    color: AppColors.primary,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),

                                        // Delete button
                                        GestureDetector(
                                          onTap: () => _handleDeleteMenu(menu),
                                          child: Container(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 8,
                                              vertical: 4.5,
                                            ),
                                            decoration: BoxDecoration(
                                              color: AppColors.chipInactiveBg,
                                              borderRadius: BorderRadius.circular(6),
                                            ),
                                            child: const Row(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                Icon(
                                                  Icons.delete_outline_rounded,
                                                  size: 13,
                                                  color: AppColors.deleteRed,
                                                ),
                                                SizedBox(width: 4),
                                                Text(
                                                  'Hapus',
                                                  style: TextStyle(
                                                    fontSize: 11,
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
                              const SizedBox(width: 12),
                              Container(
                                width: 72,
                                height: 72,
                                decoration: BoxDecoration(
                                  color: AppColors.surfaceMuted,
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(color: AppColors.border.withValues(alpha: 0.6)),
                                ),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(11),
                                  child: (menu.imageUrl != null && menu.imageUrl!.isNotEmpty)
                                      ? (menu.imageUrl!.startsWith('assets/')
                                          ? Image.asset(
                                              menu.imageUrl!,
                                              width: 72,
                                              height: 72,
                                              fit: BoxFit.cover,
                                              errorBuilder: (context, error, stackTrace) => const Icon(
                                                Icons.ramen_dining_rounded,
                                                color: AppColors.primary,
                                                size: 28,
                                              ),
                                            )
                                          : Image.network(
                                              menu.imageUrl!,
                                              width: 72,
                                              height: 72,
                                              fit: BoxFit.cover,
                                              errorBuilder: (context, error, stackTrace) => const Icon(
                                                Icons.ramen_dining_rounded,
                                                color: AppColors.primary,
                                                size: 28,
                                              ),
                                            ))
                                      : const Icon(
                                          Icons.ramen_dining_rounded,
                                          color: AppColors.textMuted,
                                          size: 28,
                                        ),
                                ),
                              ),
                            ],
                          ),
                        );
                      }),
                    const SizedBox(height: 70), // padding for FAB
                  ],
                ),
              ),
            ),

            // Bottom Navigation Bar
            OperatorBottomNav(
              currentIndex: 1, // Stok
              onTap: (index) {
                if (widget.onNavigateTab != null) {
                  widget.onNavigateTab!(index);
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterChip({
    required int id,
    required String label,
  }) {
    final isSelected = _selectedCategoryId == id;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedCategoryId = id;
        });
      },
      child: Container(
        margin: const EdgeInsets.only(right: 8),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.chipActiveBg : AppColors.chipInactiveBg,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? AppColors.chipActiveText : AppColors.chipInactiveText,
            fontWeight: FontWeight.w600,
            fontSize: 12.5,
          ),
        ),
      ),
    );
  }
}
