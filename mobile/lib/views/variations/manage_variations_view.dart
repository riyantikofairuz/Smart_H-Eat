import 'package:flutter/material.dart';
import '../../constants/app_colors.dart';
import '../../models/menu_model.dart';
import '../../models/variation_model.dart';
import '../../services/dummy_operator_service.dart';
import '../../widgets/operator_bottom_nav.dart';
import '../../widgets/operator_header.dart';

class ManageVariationsView extends StatefulWidget {
  final int? initialMenuId;
  final VoidCallback? onBack;
  final ValueChanged<int>? onNavigateTab;

  const ManageVariationsView({
    super.key,
    this.initialMenuId,
    this.onBack,
    this.onNavigateTab,
  });

  @override
  State<ManageVariationsView> createState() => _ManageVariationsViewState();
}

class _ManageVariationsViewState extends State<ManageVariationsView> {
  final DummyOperatorService _service = DummyOperatorService();
  late int _selectedMenuId;

  @override
  void initState() {
    super.initState();
    if (widget.initialMenuId != null) {
      _selectedMenuId = widget.initialMenuId!;
    } else if (_service.menus.isNotEmpty) {
      _selectedMenuId = _service.menus.first.menuId;
    } else {
      _selectedMenuId = 1;
    }
    _service.addListener(_onServiceUpdate);
  }

  @override
  void dispose() {
    _service.removeListener(_onServiceUpdate);
    super.dispose();
  }

  void _onServiceUpdate() {
    if (mounted) setState(() {});
  }

  String _formatCurrency(double amount) {
    final intAmount = amount.toInt();
    final str = intAmount.toString();
    final regExp = RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))');
    final formatted = str.replaceAllMapped(regExp, (Match m) => '${m[1]}.');
    return 'Rp $formatted';
  }

  void _showAddGroupDialog(MenuModel menu) {
    final nameController = TextEditingController();
    bool isRequired = false;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
          title: const Text('Tambah Grup Variasi', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Menu: ${menu.name}', style: const TextStyle(fontSize: 12.5, color: AppColors.textSecondary)),
              const SizedBox(height: 14),
              const Text('Nama Grup (cth: Tingkat Kepedasan, Porsi, Topping)', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
              const SizedBox(height: 6),
              TextField(
                controller: nameController,
                decoration: InputDecoration(
                  hintText: 'Nama grup variasi...',
                  filled: true,
                  fillColor: AppColors.chipInactiveBg,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Checkbox(
                    value: isRequired,
                    activeColor: AppColors.primary,
                    onChanged: (val) => setDialogState(() => isRequired = val ?? false),
                  ),
                  const Text('Wajib dipilih oleh konsumen', style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w500)),
                ],
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Batal', style: TextStyle(color: AppColors.textSecondary)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              onPressed: () {
                final groupName = nameController.text.trim();
                if (groupName.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Nama grup variasi tidak boleh kosong!'), backgroundColor: AppColors.deleteRed),
                  );
                  return;
                }
                _service.addVariationGroup(menu.menuId, groupName, isRequired);
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Grup variasi "$groupName" berhasil ditambahkan!'), backgroundColor: AppColors.success),
                );
              },
              child: const Text('Simpan Grup', style: TextStyle(fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );
  }

  void _showAddOptionDialog(MenuModel menu, MenuVariationGroup group, [MenuVariationOption? existingOption]) {
    final nameController = TextEditingController(text: existingOption?.name ?? '');
    final priceController = TextEditingController(
      text: existingOption != null ? existingOption.extraPrice.toInt().toString() : '0',
    );

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        title: Text(
          existingOption != null ? 'Edit Opsi Variasi' : 'Tambah Opsi Variasi',
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Grup: ${group.name}', style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
            const SizedBox(height: 14),
            const Text('Nama Opsi (cth: Pedas Level 1, Jumbo, Telur Dadar)', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
            const SizedBox(height: 6),
            TextField(
              controller: nameController,
              decoration: InputDecoration(
                hintText: 'Nama opsi...',
                filled: true,
                fillColor: AppColors.chipInactiveBg,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
                contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
              ),
            ),
            const SizedBox(height: 12),
            const Text('Harga Tambahan (Rp)', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
            const SizedBox(height: 6),
            TextField(
              controller: priceController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                hintText: '0 (jika gratis)',
                prefixText: 'Rp ',
                filled: true,
                fillColor: AppColors.chipInactiveBg,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
                contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Batal', style: TextStyle(color: AppColors.textSecondary)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            onPressed: () {
              final optName = nameController.text.trim();
              if (optName.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Nama opsi tidak boleh kosong!'), backgroundColor: AppColors.deleteRed),
                );
                return;
              }

              final priceText = priceController.text.trim();
              final parsedPrice = double.tryParse(priceText);

              // SKPPL Skenario Alternatif UC-F017:
              // "Operator memasukkan nilai harga tambahan variasi dengan format tidak valid (misal: huruf atau nominal negatif)
              // -> Sistem menampilkan pesan kesalahan 'Nominal harga variasi tidak valid' dan menolak penyimpanan."
              if (parsedPrice == null || parsedPrice < 0) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Nominal harga variasi tidak valid'),
                    backgroundColor: AppColors.deleteRed,
                  ),
                );
                return;
              }

              if (existingOption != null) {
                _service.updateVariationOption(
                  menu.menuId,
                  group.groupId,
                  existingOption.optionId,
                  optName,
                  parsedPrice,
                );
              } else {
                _service.addVariationOption(
                  menu.menuId,
                  group.groupId,
                  optName,
                  parsedPrice,
                );
              }

              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Opsi "$optName" berhasil disimpan!'),
                  backgroundColor: AppColors.success,
                ),
              );
            },
            child: const Text('Simpan Opsi', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final menus = _service.menus;
    final currentMenu = menus.isNotEmpty
        ? menus.firstWhere((m) => m.menuId == _selectedMenuId, orElse: () => menus.first)
        : null;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    OperatorHeader(
                      title: 'Kelola Variasi Menu',
                      showBackButton: widget.onBack != null,
                      onBack: widget.onBack,
                    ),
                    const SizedBox(height: 16),

                    // Selector Menu Makanan
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: AppColors.border),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Pilih Menu Makanan:',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textSecondary,
                            ),
                          ),
                          const SizedBox(height: 8),
                          DropdownButtonHideUnderline(
                            child: DropdownButton<int>(
                              value: currentMenu?.menuId,
                              isExpanded: true,
                              icon: const Icon(Icons.keyboard_arrow_down_rounded, color: AppColors.primary),
                              items: menus.map((m) {
                                return DropdownMenuItem<int>(
                                  value: m.menuId,
                                  child: Text(
                                    m.name,
                                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                                  ),
                                );
                              }).toList(),
                              onChanged: (val) {
                                if (val != null) {
                                  setState(() {
                                    _selectedMenuId = val;
                                  });
                                }
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),

                    if (currentMenu != null) ...[
                      // Group header and Add Group button
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Grup Variasi (${currentMenu.variationGroups.length})',
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          TextButton.icon(
                            style: TextButton.styleFrom(foregroundColor: AppColors.primary),
                            onPressed: () => _showAddGroupDialog(currentMenu),
                            icon: const Icon(Icons.add_circle_outline_rounded, size: 16),
                            label: const Text('+ Tambah Grup', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12.5)),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),

                      if (currentMenu.variationGroups.isEmpty)
                        Container(
                          padding: const EdgeInsets.all(28),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: AppColors.border),
                          ),
                          child: Column(
                            children: [
                              Icon(Icons.tune_rounded, size: 40, color: AppColors.textMuted.withValues(alpha: 0.6)),
                              const SizedBox(height: 10),
                              const Text(
                                'Menu ini belum memiliki grup variasi',
                                style: TextStyle(fontSize: 13, color: AppColors.textSecondary, fontWeight: FontWeight.w600),
                              ),
                              const SizedBox(height: 10),
                              ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.primary,
                                  foregroundColor: Colors.white,
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                ),
                                onPressed: () => _showAddGroupDialog(currentMenu),
                                child: const Text('Buat Grup Variasi Pertama'),
                              ),
                            ],
                          ),
                        )
                      else
                        ListView.separated(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: currentMenu.variationGroups.length,
                          separatorBuilder: (_, __) => const SizedBox(height: 14),
                          itemBuilder: (context, gIndex) {
                            final group = currentMenu.variationGroups[gIndex];
                            return _buildGroupCard(currentMenu, group);
                          },
                        ),
                    ],
                  ],
                ),
              ),
            ),

            OperatorBottomNav(
              currentIndex: 1, // Stok/Menu tab
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

  Widget _buildGroupCard(MenuModel menu, MenuVariationGroup group) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.border),
        boxShadow: const [
          BoxShadow(
            color: Color.fromRGBO(0, 0, 0, 0.02),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Row(
                  children: [
                    Text(
                      group.name,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: group.isRequired ? AppColors.primaryLight : AppColors.surfaceMuted,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        group.isRequired ? 'Wajib Pilih' : 'Opsional',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: group.isRequired ? AppColors.primary : AppColors.textSecondary,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: const Icon(Icons.delete_outline_rounded, color: AppColors.deleteRed, size: 20),
                onPressed: () {
                  _service.deleteVariationGroup(menu.menuId, group.groupId);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Grup "${group.name}" dihapus.'), backgroundColor: AppColors.deleteRed),
                  );
                },
              ),
            ],
          ),
          const SizedBox(height: 10),
          const Divider(height: 1),
          const SizedBox(height: 10),

          // Options List
          if (group.options.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Text(
                'Belum ada opsi pilihan dalam grup ini.',
                style: TextStyle(fontSize: 12, color: AppColors.textMuted, fontStyle: FontStyle.italic),
              ),
            )
          else
            Column(
              children: group.options.map((opt) {
                return Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceMuted,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        opt.name,
                        style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13, color: AppColors.textPrimary),
                      ),
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: opt.extraPrice > 0 ? AppColors.primaryLight : Colors.white,
                              borderRadius: BorderRadius.circular(6),
                              border: Border.all(
                                color: opt.extraPrice > 0 ? AppColors.primary.withValues(alpha: 0.3) : AppColors.border,
                              ),
                            ),
                            child: Text(
                              opt.extraPrice > 0 ? '+${_formatCurrency(opt.extraPrice)}' : 'Gratis (+Rp 0)',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: opt.extraPrice > 0 ? AppColors.primary : AppColors.textSecondary,
                              ),
                            ),
                          ),
                          const SizedBox(width: 4),
                          IconButton(
                            icon: const Icon(Icons.edit_outlined, size: 16, color: AppColors.textSecondary),
                            onPressed: () => _showAddOptionDialog(menu, group, opt),
                          ),
                          IconButton(
                            icon: const Icon(Icons.close_rounded, size: 16, color: AppColors.deleteRed),
                            onPressed: () => _service.deleteVariationOption(menu.menuId, group.groupId, opt.optionId),
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),

          const SizedBox(height: 6),
          Align(
            alignment: Alignment.centerLeft,
            child: OutlinedButton.icon(
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.primary,
                side: const BorderSide(color: AppColors.primary, width: 1.2),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              ),
              onPressed: () => _showAddOptionDialog(menu, group),
              icon: const Icon(Icons.add, size: 16),
              label: const Text('+ Tambah Opsi Pilihan', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
            ),
          ),
        ],
      ),
    );
  }
}
