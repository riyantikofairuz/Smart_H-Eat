import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../constants/app_colors.dart';
import '../../models/restock_log_model.dart';
import '../../services/dummy_operator_service.dart';
import '../../widgets/operator_bottom_nav.dart';
import '../../widgets/operator_header.dart';

class RestockReportView extends StatefulWidget {
  final VoidCallback? onBack;
  final ValueChanged<int>? onNavigateTab;

  const RestockReportView({
    super.key,
    this.onBack,
    this.onNavigateTab,
  });

  @override
  State<RestockReportView> createState() => _RestockReportViewState();
}

class _RestockReportViewState extends State<RestockReportView> {
  final DummyOperatorService _service = DummyOperatorService();
  final TextEditingController _searchController = TextEditingController();
  int _selectedMenuId = 0; // 0 means 'Semua Menu'
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

  String _formatDateTime(DateTime dt) {
    const monthNames = [
      '', 'Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun', 'Jul', 'Agu', 'Sep', 'Okt', 'Nov', 'Des'
    ];
    final day = dt.day.toString().padLeft(2, '0');
    final month = dt.month >= 1 && dt.month <= 12 ? monthNames[dt.month] : dt.month.toString();
    final year = dt.year.toString();
    final hour = dt.hour.toString().padLeft(2, '0');
    final min = dt.minute.toString().padLeft(2, '0');
    return '$day $month $year, $hour:$min WIB';
  }

  List<RestockLogModel> _getFilteredLogs() {
    return _service.restockLogs.where((log) {
      if (_selectedMenuId != 0 && log.menuId != _selectedMenuId) {
        return false;
      }
      if (_searchQuery.isNotEmpty &&
          !log.menuName.toLowerCase().contains(_searchQuery.toLowerCase()) &&
          !log.note.toLowerCase().contains(_searchQuery.toLowerCase())) {
        return false;
      }
      return true;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final filteredLogs = _getFilteredLogs();
    final totalAdded = filteredLogs.fold<int>(0, (sum, log) => sum + log.qtyAdded);
    final totalActivities = filteredLogs.length;

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
                      title: 'Laporan Restock',
                      showBackButton: widget.onBack != null,
                      onBack: widget.onBack,
                    ),
                    const SizedBox(height: 16),

                    // Top KPI Cards for Restock
                    Row(
                      children: [
                        Expanded(
                          child: Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [Color(0xFFD45522), Color(0xFFA1350E)],
                              ),
                              borderRadius: BorderRadius.circular(18),
                              boxShadow: [
                                BoxShadow(
                                  color: AppColors.primary.withValues(alpha: 0.25),
                                  blurRadius: 8,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Row(
                                  children: [
                                    Icon(Icons.inventory_2_rounded, color: Colors.white70, size: 16),
                                    SizedBox(width: 6),
                                    Text(
                                      'Total Porsi Diisi',
                                      style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 10),
                                Text(
                                  '$totalAdded Porsi',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 22,
                                    fontWeight: FontWeight.w900,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(18),
                              border: Border.all(color: AppColors.border),
                              boxShadow: const [
                                BoxShadow(
                                  color: Color.fromRGBO(0, 0, 0, 0.03),
                                  blurRadius: 6,
                                  offset: Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Row(
                                  children: [
                                    Icon(Icons.history_rounded, color: AppColors.primary, size: 16),
                                    SizedBox(width: 6),
                                    Text(
                                      'Aktivitas Restock',
                                      style: TextStyle(color: AppColors.textSecondary, fontSize: 12, fontWeight: FontWeight.w600),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 10),
                                Text(
                                  '$totalActivities Kali',
                                  style: const TextStyle(
                                    color: AppColors.textPrimary,
                                    fontSize: 22,
                                    fontWeight: FontWeight.w900,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Search & Filter Box
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: AppColors.border),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.search_rounded, color: AppColors.textSecondary, size: 20),
                          const SizedBox(width: 8),
                          Expanded(
                            child: TextField(
                              controller: _searchController,
                              style: const TextStyle(fontSize: 13),
                              decoration: const InputDecoration(
                                hintText: 'Cari menu atau catatan restock...',
                                border: InputBorder.none,
                                isDense: true,
                              ),
                              onChanged: (val) {
                                setState(() {
                                  _searchQuery = val.trim();
                                });
                              },
                            ),
                          ),
                          if (_searchQuery.isNotEmpty)
                            GestureDetector(
                              onTap: () {
                                _searchController.clear();
                                setState(() {
                                  _searchQuery = '';
                                });
                              },
                              child: const Icon(Icons.clear_rounded, size: 18, color: AppColors.textSecondary),
                            ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Filter Menu Horizontal Chips (UC-F021: "memfilter berdasarkan nama menu tertentu")
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(right: 8),
                            child: ChoiceChip(
                              label: const Text('Semua Menu'),
                              selected: _selectedMenuId == 0,
                              selectedColor: AppColors.primary,
                              labelStyle: TextStyle(
                                fontSize: 11.5,
                                fontWeight: _selectedMenuId == 0 ? FontWeight.bold : FontWeight.w500,
                                color: _selectedMenuId == 0 ? Colors.white : AppColors.chipInactiveText,
                              ),
                              backgroundColor: AppColors.chipInactiveBg,
                              side: BorderSide.none,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                              onSelected: (_) => setState(() => _selectedMenuId = 0),
                            ),
                          ),
                          ..._service.menus.map((m) {
                            final isSel = _selectedMenuId == m.menuId;
                            return Padding(
                              padding: const EdgeInsets.only(right: 8),
                              child: ChoiceChip(
                                label: Text(m.name),
                                selected: isSel,
                                selectedColor: AppColors.primary,
                                labelStyle: TextStyle(
                                  fontSize: 11.5,
                                  fontWeight: isSel ? FontWeight.bold : FontWeight.w500,
                                  color: isSel ? Colors.white : AppColors.chipInactiveText,
                                ),
                                backgroundColor: AppColors.chipInactiveBg,
                                side: BorderSide.none,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                                onSelected: (_) => setState(() => _selectedMenuId = m.menuId),
                              ),
                            );
                          }),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),

                    // History Title
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Riwayat Pengisian Stok (${filteredLogs.length})',
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),

                    if (filteredLogs.isEmpty)
                      Container(
                        padding: const EdgeInsets.all(32),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: AppColors.border),
                        ),
                        child: Column(
                          children: [
                            Icon(Icons.inventory_outlined, size: 44, color: AppColors.textMuted.withValues(alpha: 0.6)),
                            const SizedBox(height: 10),
                            const Text(
                              'Belum ada catatan riwayat restock sesuai pencarian',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      )
                    else
                      ListView.separated(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: filteredLogs.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 12),
                        itemBuilder: (context, index) {
                          final log = filteredLogs[index];
                          return _buildRestockLogCard(log);
                        },
                      ),
                  ],
                ),
              ),
            ),

            OperatorBottomNav(
              currentIndex: 2, // Laporan tab
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

  Widget _buildRestockLogCard(RestockLogModel log) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.border),
        boxShadow: const [
          BoxShadow(
            color: Color.fromRGBO(0, 0, 0, 0.03),
            blurRadius: 6,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header: Menu Name & Added Badge
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  log.menuName,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFFEDFBF2),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppColors.success.withValues(alpha: 0.4)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.add_rounded, size: 14, color: AppColors.success),
                    Text(
                      '${log.qtyAdded} Porsi',
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: AppColors.success,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),

          // Stock transition details (SKPPL: "stok sebelum & sesudah")
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: AppColors.surfaceMuted,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Text('Stok Sebelum: ', style: TextStyle(fontSize: 11.5, color: AppColors.textSecondary)),
                    Text('${log.stockBefore} Porsi', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
                  ],
                ),
                const Icon(Icons.arrow_forward_rounded, size: 14, color: AppColors.primary),
                Row(
                  children: [
                    const Text('Stok Sesudah: ', style: TextStyle(fontSize: 11.5, color: AppColors.textSecondary)),
                    Text('${log.stockAfter} Porsi', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.primary)),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),

          // Note & Operator info
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(Icons.person_pin_circle_rounded, size: 14, color: AppColors.textSecondary),
                  const SizedBox(width: 4),
                  Text(
                    log.operatorName,
                    style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
                  ),
                ],
              ),
              Row(
                children: [
                  const Icon(Icons.access_time_rounded, size: 13, color: AppColors.textSecondary),
                  const SizedBox(width: 4),
                  Text(
                    _formatDateTime(log.createdAt),
                    style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
                  ),
                ],
              ),
            ],
          ),
          if (log.note.isNotEmpty) ...[
            const SizedBox(height: 6),
            Text(
              'Catatan: ${log.note}',
              style: const TextStyle(fontSize: 11, fontStyle: FontStyle.italic, color: AppColors.textSecondary),
            ),
          ],
        ],
      ),
    );
  }
}
