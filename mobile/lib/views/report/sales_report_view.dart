import 'package:flutter/material.dart';
import '../../constants/app_colors.dart';
import '../../models/sales_report_model.dart';
import '../../services/dummy_operator_service.dart';
import '../../widgets/operator_bottom_nav.dart';
import '../../widgets/operator_header.dart';
import '../restock/restock_report_view.dart';

/// Halaman Laporan Penjualan (STEP 4)
/// Menampilkan filter periode (Hari Ini, Minggu Ini, Bulan Ini),
/// kartu ringkasan KPI (Total Pendapatan & Total Terjual),
/// visualisasi grafik tren penjualan (Bar Chart),
/// serta daftar penjualan per menu terlaris.
/// Dirancang presisi 100% selaras dengan Mockup Gambar 4.
class SalesReportView extends StatefulWidget {
  final VoidCallback? onBack;
  final ValueChanged<int>? onNavigateTab;

  const SalesReportView({
    super.key,
    this.onBack,
    this.onNavigateTab,
  });

  @override
  State<SalesReportView> createState() => _SalesReportViewState();
}

class _SalesReportViewState extends State<SalesReportView> {
  final DummyOperatorService _service = DummyOperatorService();
  SalesPeriod _selectedPeriod = SalesPeriod.weekly;

  @override
  void initState() {
    super.initState();
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

  void _handleExportReport(SalesReportData report) {
    final periodName = _selectedPeriod == SalesPeriod.daily
        ? 'Harian'
        : _selectedPeriod == SalesPeriod.weekly
            ? 'Mingguan'
            : 'Bulanan';

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        padding: const EdgeInsets.all(24),
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
                  child: const Icon(Icons.picture_as_pdf_rounded, color: AppColors.primary, size: 24),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Ekspor Laporan Penjualan ($periodName)',
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                      ),
                      const SizedBox(height: 2),
                      const Text(
                        'Format PDF & Rekap Data Penjualan Smart H-EAT',
                        style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 18),
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppColors.surfaceMuted,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Total Pendapatan:', style: TextStyle(fontSize: 12.5, color: AppColors.textSecondary)),
                      Text(report.totalRevenueDisplay, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppColors.primary)),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Total Porsi Terjual:', style: TextStyle(fontSize: 12.5, color: AppColors.textSecondary)),
                      Text('${report.totalPortions} Porsi', style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Statistik Puncak:', style: TextStyle(fontSize: 12.5, color: AppColors.textSecondary)),
                      Text(report.peakSummary, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                onPressed: () {
                  Navigator.pop(ctx);
                  // Skenario Alternatif UC-F022: Sistem mengunduh berkas rekapitulasi penjualan ke perangkat Operator
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Berkas Rekapitulasi_Penjualan_$periodName.pdf berhasil diunduh ke perangkat!'),
                      backgroundColor: AppColors.success,
                      duration: const Duration(seconds: 3),
                    ),
                  );
                },
                icon: const Icon(Icons.download_rounded, color: Colors.white),
                label: const Text(
                  'Unduh Berkas Rekapitulasi (.PDF)',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13.5),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final report = _service.getSalesReport(_selectedPeriod);

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
                    // Header Smart H-EAT (Branding & Judul Halaman) with Export Action (UC-F022)
                    OperatorHeader(
                      title: 'Laporan Penjualan',
                      showBackButton: widget.onBack != null,
                      onBack: widget.onBack,
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.print_rounded, color: AppColors.primary, size: 20),
                            tooltip: 'Cetak / Ekspor Laporan',
                            onPressed: () => _handleExportReport(report),
                          ),
                          IconButton(
                            icon: const Icon(Icons.inventory_2_outlined, color: AppColors.primary, size: 20),
                            tooltip: 'Laporan Restock',
                            onPressed: () {
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
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Navigation link to Restock Report (UC-F021)
                    InkWell(
                      onTap: () {
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
                      borderRadius: BorderRadius.circular(12),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: AppColors.border),
                        ),
                        child: const Row(
                          children: [
                            Icon(Icons.history_rounded, size: 18, color: AppColors.primary),
                            SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                'Lihat Riwayat & Laporan Restock Makanan',
                                style: TextStyle(
                                  fontSize: 12.5,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                            ),
                            Icon(Icons.arrow_forward_ios_rounded, size: 13, color: AppColors.textSecondary),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 14),

                    // Filter Tab Kapsul Oranye (Hari Ini | Minggu Ini | Bulan Ini)
                    Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: const Color(0xFFE96A27),
                        borderRadius: BorderRadius.circular(24),
                      ),
                      child: Row(
                        children: [
                          _buildPeriodTab('Hari Ini', SalesPeriod.daily),
                          _buildPeriodTab('Minggu Ini', SalesPeriod.weekly),
                          _buildPeriodTab('Bulan Ini', SalesPeriod.monthly),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Baris Dua Kartu Ringkasan KPI (Total Pendapatan & Total Terjual)
                    Row(
                      children: [
                        // Card 1: Total Pendapatan
                        Expanded(
                          child: Container(
                            height: 130,
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [
                                  Color(0xFFD45522),
                                  Color(0xFFA1350E),
                                ],
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                              ),
                              borderRadius: BorderRadius.circular(18),
                              boxShadow: [
                                BoxShadow(
                                  color: const Color(0xFFA1350E).withValues(alpha: 0.28),
                                  blurRadius: 10,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Icon(
                                  Icons.account_balance_wallet_rounded,
                                  color: Colors.white,
                                  size: 22,
                                ),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Total Pendapatan',
                                      style: TextStyle(
                                        color: Colors.white.withValues(alpha: 0.92),
                                        fontSize: 12,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                    const SizedBox(height: 3),
                                    Text(
                                      report.totalRevenueDisplay,
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 22,
                                        fontWeight: FontWeight.w900,
                                        letterSpacing: -0.3,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),

                        // Card 2: Total Terjual
                        Expanded(
                          child: Container(
                            height: 130,
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [
                                  Color(0xFFD45522),
                                  Color(0xFFA1350E),
                                ],
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                              ),
                              borderRadius: BorderRadius.circular(18),
                              boxShadow: [
                                BoxShadow(
                                  color: const Color(0xFFA1350E).withValues(alpha: 0.28),
                                  blurRadius: 10,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Icon(
                                  Icons.restaurant_rounded,
                                  color: Colors.white,
                                  size: 22,
                                ),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Total Terjual',
                                      style: TextStyle(
                                        color: Colors.white.withValues(alpha: 0.92),
                                        fontSize: 12,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                    const SizedBox(height: 3),
                                    Text(
                                      '${report.totalPortions} Porsi',
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 22,
                                        fontWeight: FontWeight.w900,
                                        letterSpacing: -0.3,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 18),

                    // Card Tren Penjualan (Soft-Blue `#EFF4FE` dengan Bar Chart)
                    Container(
                      padding: const EdgeInsets.all(18),
                      decoration: BoxDecoration(
                        color: const Color(0xFFEFF4FE),
                        borderRadius: BorderRadius.circular(18),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                _selectedPeriod == SalesPeriod.daily
                                    ? 'Tren Penjualan (Hari Ini)'
                                    : _selectedPeriod == SalesPeriod.weekly
                                        ? 'Tren Penjualan (7 Hari)'
                                        : 'Tren Penjualan (Bulan Ini)',
                                style: const TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Flexible(
                                child: Text(
                                  report.peakSummary,
                                  textAlign: TextAlign.end,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: Color(0xFF555C66),
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 22),

                          // Visualisasi Grafik Batang (Bar Chart)
                          SizedBox(
                            height: 155,
                            child: LayoutBuilder(
                              builder: (context, constraints) {
                                final maxCount = report.dailyTrends
                                    .map((t) => t.count)
                                    .fold(1, (a, b) => a > b ? a : b);

                                return Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: report.dailyTrends.map((trend) {
                                    final heightPercent = (trend.count / maxCount).clamp(0.18, 1.0);
                                    final barHeight = 85.0 * heightPercent;

                                    return Column(
                                      mainAxisAlignment: MainAxisAlignment.end,
                                      children: [
                                        // Angka jumlah penjualan di atas batang
                                        Text(
                                          '${trend.count}',
                                          style: TextStyle(
                                            fontSize: 11,
                                            fontWeight: trend.isPeak
                                                ? FontWeight.bold
                                                : FontWeight.w600,
                                            color: trend.isPeak
                                                ? AppColors.textPrimary
                                                : const Color(0xFF555C66),
                                          ),
                                        ),
                                        const SizedBox(height: 6),

                                        // Batang Bar Chart
                                        Container(
                                          width: 32,
                                          height: barHeight,
                                          decoration: BoxDecoration(
                                            color: trend.isPeak
                                                ? const Color(0xFFA83D15)
                                                : Colors.white,
                                            borderRadius: BorderRadius.circular(4),
                                            boxShadow: [
                                              BoxShadow(
                                                color: Colors.black.withValues(alpha: 0.04),
                                                blurRadius: 3,
                                                offset: const Offset(0, 1),
                                              ),
                                            ],
                                          ),
                                        ),
                                        const SizedBox(height: 8),

                                        // Label Hari/Waktu di bawah batang
                                        Text(
                                          trend.dayName,
                                          style: TextStyle(
                                            fontSize: 11.5,
                                            fontWeight: trend.isPeak
                                                ? FontWeight.bold
                                                : FontWeight.w500,
                                            color: trend.isPeak
                                                ? AppColors.textPrimary
                                                : const Color(0xFF6B7280),
                                          ),
                                        ),
                                      ],
                                    );
                                  }).toList(),
                                );
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 22),

                    // Judul Section: Penjualan per Menu
                    const Text(
                      'Penjualan per Menu',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Daftar Item Menu Terlaris
                    if (report.menuSales.isEmpty)
                      Container(
                        padding: const EdgeInsets.symmetric(vertical: 24),
                        alignment: Alignment.center,
                        child: const Text(
                          'Belum ada transaksi pada periode ini',
                          style: TextStyle(color: AppColors.textSecondary),
                        ),
                      )
                    else
                      ...report.menuSales.map((item) {
                        final revenueDisplay = item.totalRevenue >= 1000000
                            ? 'Rp ${(item.totalRevenue / 1000000).toStringAsFixed(2).replaceAll('.', ',')} Jt'
                            : 'Rp ${item.totalRevenue.toInt()}';

                        return Container(
                          margin: const EdgeInsets.only(bottom: 12),
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                          decoration: BoxDecoration(
                            color: const Color(0xFFEFF4FE),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      item.menuName,
                                      style: const TextStyle(
                                        fontSize: 14.5,
                                        fontWeight: FontWeight.bold,
                                        color: AppColors.textPrimary,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      '${item.portionsSold} porsi terjual • Total: $revenueDisplay',
                                      style: const TextStyle(
                                        fontSize: 12.5,
                                        color: Color(0xFF6B7280),
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 12),
                              Container(
                                width: 48,
                                height: 48,
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(12),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withValues(alpha: 0.03),
                                      blurRadius: 4,
                                      offset: const Offset(0, 1),
                                    ),
                                  ],
                                ),
                                child: const Icon(
                                  Icons.image_outlined,
                                  color: AppColors.textPrimary,
                                  size: 24,
                                ),
                              ),
                            ],
                          ),
                        );
                      }),
                    const SizedBox(height: 16),
                  ],
                ),
              ),
            ),

            // Bottom Navigation Bar
            OperatorBottomNav(
              currentIndex: 2, // Tab 'Laporan' aktif
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

  Widget _buildPeriodTab(String title, SalesPeriod period) {
    final isSelected = _selectedPeriod == period;

    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            _selectedPeriod = period;
          });
        },
        behavior: HitTestBehavior.opaque,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 9),
          decoration: BoxDecoration(
            color: isSelected ? const Color(0xFF9C3814) : Colors.transparent,
            borderRadius: BorderRadius.circular(20),
          ),
          alignment: Alignment.center,
          child: Text(
            title,
            style: TextStyle(
              color: Colors.white,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
              fontSize: 13,
            ),
          ),
        ),
      ),
    );
  }
}

