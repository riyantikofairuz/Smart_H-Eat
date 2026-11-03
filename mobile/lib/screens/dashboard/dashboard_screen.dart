import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../models/operator_model.dart';
import '../../services/dummy_data_service.dart';
import '../../widgets/operator_header.dart';

class DashboardScreen extends StatelessWidget {
  final OperatorModel? operator;
  final VoidCallback? onNavigateToStock;
  final VoidCallback? onLogout;

  const DashboardScreen({
    super.key,
    this.operator,
    this.onNavigateToStock,
    this.onLogout,
  });

  @override
  Widget build(BuildContext context) {
    final dummy = DummyDataService();

    final displayName = (operator != null && operator!.name.trim().isNotEmpty)
        ? operator!.name.trim()
        : dummy.operatorGreeting;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: AnimatedBuilder(
          animation: dummy,
          builder: (context, _) {
            return SingleChildScrollView(
              padding: const EdgeInsets.only(bottom: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 1. Top Header: H-EAT & OPERATOR MODE with optional logout action
                  _buildTopHeader(context),

                  const SizedBox(height: 10),

                  // 2. Greeting Card: "Halo, Pak Kemas"
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: _buildGreetingCard(displayName),
                  ),

                  const SizedBox(height: 12),

                  // 3. Alert Card: "Mesin Perlu Restock Segera!"
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: _buildAlertCard(),
                  ),

                  const SizedBox(height: 16),

                  // 4. Section Title: "RINGKASAN OPERASIONAL"
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 20),
                    child: Text(
                      'RINGKASAN OPERASIONAL',
                      style: TextStyle(
                        fontSize: 13.5,
                        fontWeight: FontWeight.w900,
                        color: Color(0xFF0F172A),
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),

                  const SizedBox(height: 10),

                  // 5. Card 1: Total Pendapatan Hari ini
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: _buildMetricCard(
                      icon: Icons.payments_outlined,
                      title: 'Total Pendapatan Hari ini',
                      value: dummy.dailyRevenue,
                    ),
                  ),

                  const SizedBox(height: 10),

                  // 6. Card 2: Porsi Terjual
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: _buildMetricCard(
                      icon: Icons.lunch_dining_outlined,
                      title: 'Porsi Terjual',
                      value: '${dummy.portionsSold} Porsi',
                    ),
                  ),

                  const SizedBox(height: 10),

                  // 7. Card 3: Suhu Vending
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: _buildTemperatureCard(
                      temperature: '${dummy.vendingTemperature}°C',
                      status: dummy.temperatureStatus,
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  /// Greeting banner with orange gradient: "Halo, Pak Kemas"
  Widget _buildGreetingCard(String name) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      decoration: BoxDecoration(
        gradient: AppColors.operatorGreetingGradient,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFEA580C).withValues(alpha: 0.25),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Text(
        'Halo, $name',
        style: const TextStyle(
          color: Colors.white,
          fontSize: 18,
          fontWeight: FontWeight.w800,
          letterSpacing: -0.2,
        ),
      ),
    );
  }

  /// Alert warning card: "Mesin Perlu Restock Segera!" with rust icon and "PERHATIAN" badge
  Widget _buildAlertCard() {
    return GestureDetector(
      onTap: onNavigateToStock,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
        decoration: BoxDecoration(
          color: AppColors.inputBackground,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Icon(
              Icons.warning_rounded,
              color: AppColors.operatorAccentRust,
              size: 38,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 3,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.alertBadgeDark,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: const Text(
                      'PERHATIAN',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 10.5,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 0.6,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Mesin Perlu Restock\nSegera!',
                    style: TextStyle(
                      color: Color(0xFF0F172A),
                      fontSize: 19,
                      fontWeight: FontWeight.w800,
                      height: 1.25,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Metric card with soft blue background and rust colored icon
  Widget _buildMetricCard({
    required IconData icon,
    required String title,
    required String value,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      decoration: BoxDecoration(
        color: AppColors.inputBackground,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            icon,
            color: AppColors.operatorAccentRust,
            size: 26,
          ),
          const SizedBox(height: 10),
          Text(
            title,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: Color(0xFF1E293B),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w800,
              color: Color(0xFF0F172A),
            ),
          ),
        ],
      ),
    );
  }

  /// Temperature card with status indicator: "Suhu Vending 60°C" and "Suhu Optimal"
  Widget _buildTemperatureCard({
    required String temperature,
    required String status,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      decoration: BoxDecoration(
        color: AppColors.inputBackground,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(
            Icons.thermostat_outlined,
            color: AppColors.operatorAccentRust,
            size: 26,
          ),
          const SizedBox(height: 10),
          const Text(
            'Suhu Vending',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: Color(0xFF1E293B),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            temperature,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w800,
              color: Color(0xFF0F172A),
            ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 8,
                height: 8,
                decoration: const BoxDecoration(
                  color: AppColors.operatorAccentRust,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                status,
                style: const TextStyle(
                  fontSize: 11.5,
                  fontWeight: FontWeight.w700,
                  color: AppColors.operatorAccentRust,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// Top header with H-EAT branding and optional logout icon
  Widget _buildTopHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Expanded(
            child: OperatorHeader(
              topPadding: 16,
              horizontalPadding: 20,
            ),
          ),
          if (onLogout != null)
            Padding(
              padding: const EdgeInsets.only(top: 14),
              child: IconButton(
                icon: const Icon(
                  Icons.logout_rounded,
                  color: Color(0xFF64748B),
                  size: 22,
                ),
                tooltip: 'Keluar ke Login',
                onPressed: () => _confirmLogout(context),
              ),
            ),
        ],
      ),
    );
  }

  /// Logout confirmation dialog to return to LoginScreen
  void _confirmLogout(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text(
          'Konfirmasi Keluar',
          style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16),
        ),
        content: const Text(
          'Apakah Anda ingin keluar dari sesi simulasi Operator dan kembali ke halaman Login?',
          style: TextStyle(fontSize: 13),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              onLogout?.call();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.alertBadge,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            child: const Text('Keluar'),
          ),
        ],
      ),
    );
  }
}
