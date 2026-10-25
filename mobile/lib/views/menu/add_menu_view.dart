import 'package:flutter/material.dart';
import '../../constants/app_colors.dart';
import '../../models/menu_model.dart';
import '../../services/dummy_operator_service.dart';
import '../../widgets/operator_bottom_nav.dart';
import '../../widgets/operator_header.dart';

class AddMenuView extends StatefulWidget {
  final VoidCallback? onBack;
  final ValueChanged<int>? onNavigateTab;

  const AddMenuView({
    super.key,
    this.onBack,
    this.onNavigateTab,
  });

  @override
  State<AddMenuView> createState() => _AddMenuViewState();
}

class _AddMenuViewState extends State<AddMenuView> {
  final DummyOperatorService _service = DummyOperatorService();
  final TextEditingController _nameController = TextEditingController();

  late int _selectedCategoryId;
  String _selectedSpiciness = 'Tidak Pedas';
  int _stockCount = 10;
  String? _selectedImageNotice;

  final List<String> _spicinessOptions = ['Tidak Pedas', 'Sedang', 'Pedas'];

  @override
  void initState() {
    super.initState();
    if (_service.categories.isNotEmpty) {
      _selectedCategoryId = _service.categories.first.categoryId;
    } else {
      _selectedCategoryId = 1;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  void _handlePickPhoto() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Material(
        color: Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Pilih Foto Menu',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
              ),
              const SizedBox(height: 14),
              ListTile(
                leading: const Icon(Icons.photo_library_outlined, color: AppColors.primary),
                title: const Text('Pilih dari Galeri'),
                onTap: () {
                  Navigator.pop(ctx);
                  setState(() {
                    _selectedImageNotice = 'Foto menu terpilih';
                  });
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Foto menu berhasil dipilih.'), backgroundColor: AppColors.success),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.camera_alt_outlined, color: AppColors.primary),
              title: const Text('Ambil Foto Kamera'),
              onTap: () {
                Navigator.pop(ctx);
                setState(() {
                  _selectedImageNotice = 'Foto kamera terpilih';
                });
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Foto kamera berhasil diambil.'), backgroundColor: AppColors.success),
                );
              },
            ),
          ],
        ),
      ),
    ),
  );
  }

  void _handleSimpanMenu() {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    final name = _nameController.text.trim();
    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Nama makanan / menu harus diisi!'), backgroundColor: AppColors.deleteRed),
      );
      return;
    }

    final isDuplicate = _service.menus.any(
      (m) => m.name.trim().toLowerCase() == name.toLowerCase(),
    );
    if (isDuplicate) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Menu "$name" sudah terdaftar di mesin!'),
          backgroundColor: AppColors.deleteRed,
        ),
      );
      return;
    }

    String assignedImage = _selectedImageNotice ?? '';
    if (assignedImage.isEmpty) {
      switch (_selectedCategoryId) {
        case 2:
          assignedImage = 'assets/menu/mie_tarempa_basah.jpg';
          break;
        case 3:
          assignedImage = 'assets/menu/mie_tarempa_lembab.jpg';
          break;
        case 4:
          assignedImage = 'assets/menu/mie_tarempa_goreng.jpg';
          break;
        case 5:
          assignedImage = 'assets/menu/mie_tarempa_rebus.jpg';
          break;
        default:
          assignedImage = 'assets/menu/mie_tarempa_kering.jpg';
      }
    }

    final newMenu = MenuModel(
      menuId: 0,
      categoryId: _selectedCategoryId,
      name: name,
      price: 30000,
      spiciness: _selectedSpiciness,
      stock: _stockCount.clamp(0, 10),
      slotCapacity: 10,
      imageUrl: assignedImage,
      isActive: true,
    );

    _service.addMenu(newMenu);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Menu "$name" berhasil ditambahkan!'),
        backgroundColor: AppColors.success,
      ),
    );

    if (widget.onBack != null) {
      widget.onBack!();
    } else {
      Navigator.of(context).maybePop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final categories = _service.categories;

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
                      title: 'Tambah Menu Baru',
                      onBack: widget.onBack,
                    ),
                    const SizedBox(height: 20),

                    // Card 1: Foto Makanan Upload
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: AppColors.border),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Foto Makanan',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 12),
                          GestureDetector(
                            onTap: _handlePickPhoto,
                            child: CustomPaint(
                              painter: DashedRectPainter(
                                color: AppColors.borderDashed,
                                strokeWidth: 1.2,
                                gap: 5.0,
                                radius: 12,
                              ),
                              child: Container(
                                width: double.infinity,
                                padding: const EdgeInsets.symmetric(vertical: 22),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Container(
                                      width: 48,
                                      height: 48,
                                      decoration: BoxDecoration(
                                        color: const Color(0xFFEFF4FE),
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: const Icon(
                                        Icons.image_outlined,
                                        color: AppColors.primary,
                                        size: 24,
                                      ),
                                    ),
                                    const SizedBox(height: 10),
                                    Text(
                                      _selectedImageNotice ?? 'Unggah foto menu',
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold,
                                        color: _selectedImageNotice != null ? AppColors.primary : AppColors.textPrimary,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    const Text(
                                      'Format JPG, PNG (Maks. 2MB)',
                                      style: TextStyle(
                                        fontSize: 11.5,
                                        color: AppColors.textSecondary,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Card 2: Form Input Utama (Nama Makanan, Kategori, Tingkat Kepedasan)
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: AppColors.border),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Section 1: Nama Makanan / Menu
                          const Text(
                            'Nama Makanan / Menu',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Container(
                            height: 48,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: AppColors.border),
                            ),
                            child: TextField(
                              controller: _nameController,
                              decoration: const InputDecoration(
                                hintText: 'Contoh: Rendang Daging Sapi',
                                hintStyle: TextStyle(
                                  color: AppColors.textMuted,
                                  fontSize: 13.5,
                                ),
                                contentPadding: EdgeInsets.symmetric(
                                  horizontal: 14,
                                  vertical: 12,
                                ),
                                border: InputBorder.none,
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),

                          // Section 2: Kategori Makanan
                          const Text(
                            'Kategori Makanan',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 10),
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: categories.map((cat) {
                              final isSelected = cat.categoryId == _selectedCategoryId;
                              return GestureDetector(
                                onTap: () {
                                  setState(() {
                                    _selectedCategoryId = cat.categoryId;
                                  });
                                },
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 9,
                                  ),
                                  decoration: BoxDecoration(
                                    color: isSelected
                                        ? AppColors.primary
                                        : const Color(0xFFF1F4FD),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Text(
                                    cat.name,
                                    style: TextStyle(
                                      color: isSelected
                                          ? Colors.white
                                          : AppColors.textPrimary,
                                      fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                                      fontSize: 13,
                                    ),
                                  ),
                                ),
                              );
                            }).toList(),
                          ),
                          const SizedBox(height: 16),

                          // Section 3: Tingkat Kepedasan
                          const Text(
                            'Tingkat Kepedasan',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 10),
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: _spicinessOptions.map((opt) {
                              final isSelected = opt == _selectedSpiciness;
                              return GestureDetector(
                                onTap: () {
                                  setState(() {
                                    _selectedSpiciness = opt;
                                  });
                                },
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 9,
                                  ),
                                  decoration: BoxDecoration(
                                    color: isSelected
                                        ? AppColors.primary
                                        : const Color(0xFFF1F4FD),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Text(
                                    opt,
                                    style: TextStyle(
                                      color: isSelected
                                          ? Colors.white
                                          : AppColors.textPrimary,
                                      fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                                      fontSize: 13,
                                    ),
                                  ),
                                ),
                              );
                            }).toList(),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Card 3: Pengaturan Slot Mesin
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: const Color(0xFFEFF4FE),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Pengaturan Slot Mesin',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 2),
                          const Text(
                            'Konfigurasi kapasitas tray mesin',
                            style: TextStyle(
                              fontSize: 11.5,
                              color: AppColors.textSecondary,
                            ),
                          ),
                          const SizedBox(height: 14),

                          // Inner White Box: Tambah Stok
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Tambah Stok',
                                  style: TextStyle(
                                    fontSize: 11.5,
                                    color: AppColors.textSecondary,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    GestureDetector(
                                      onTap: () {
                                        if (_stockCount > 1) {
                                          setState(() => _stockCount--);
                                        }
                                      },
                                      child: Container(
                                        width: 40,
                                        height: 36,
                                        decoration: BoxDecoration(
                                          color: const Color(0xFFF1F3F5),
                                          borderRadius: BorderRadius.circular(8),
                                        ),
                                        child: const Icon(Icons.remove, size: 16, color: AppColors.textPrimary),
                                      ),
                                    ),
                                    Text(
                                      '$_stockCount',
                                      style: const TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                        color: AppColors.textPrimary,
                                      ),
                                    ),
                                    GestureDetector(
                                      onTap: () {
                                        if (_stockCount < 10) {
                                          setState(() => _stockCount++);
                                        }
                                      },
                                      child: Container(
                                        width: 40,
                                        height: 36,
                                        decoration: BoxDecoration(
                                          color: const Color(0xFFF1F3F5),
                                          borderRadius: BorderRadius.circular(8),
                                        ),
                                        child: const Icon(Icons.add, size: 16, color: AppColors.textPrimary),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Button: + Simpan & Tambahkan Menu
                    SizedBox(
                      height: 50,
                      child: ElevatedButton.icon(
                        onPressed: _handleSimpanMenu,
                        icon: const Icon(Icons.add, size: 20, color: Colors.white),
                        label: const Text(
                          'Simpan & Tambahkan Menu',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
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
}

// Custom Painter for dashed rectangle
class DashedRectPainter extends CustomPainter {
  final Color color;
  final double strokeWidth;
  final double gap;
  final double radius;

  DashedRectPainter({
    required this.color,
    this.strokeWidth = 1.0,
    this.gap = 5.0,
    this.radius = 12.0,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke;

    final RRect rrect = RRect.fromRectAndRadius(
      Rect.fromLTWH(0, 0, size.width, size.height),
      Radius.circular(radius),
    );

    final Path path = Path()..addRRect(rrect);
    final Path dashedPath = Path();

    double distance = 0.0;
    for (final pathMetric in path.computeMetrics()) {
      while (distance < pathMetric.length) {
        dashedPath.addPath(
          pathMetric.extractPath(distance, distance + gap),
          Offset.zero,
        );
        distance += gap * 2;
      }
    }

    canvas.drawPath(dashedPath, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
