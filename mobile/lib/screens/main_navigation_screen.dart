import 'package:flutter/material.dart';
import '../core/theme/app_colors.dart';
import '../models/operator_model.dart';
import '../widgets/operator_bottom_nav.dart';
import 'auth/login_screen.dart';
import 'dashboard/dashboard_screen.dart';
import 'reports/reports_placeholder_screen.dart';
import 'stock/stock_screen.dart';

class MainNavigationScreen extends StatefulWidget {
  final OperatorModel? operator;
  final VoidCallback? onLogout;

  const MainNavigationScreen({
    super.key,
    this.operator,
    this.onLogout,
  });

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  int _currentIndex = 0;

  void _onTabSelected(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  void _navigateToStockTab() {
    setState(() {
      _currentIndex = 1;
    });
  }

  void _handleLogout() {
    if (widget.onLogout != null) {
      widget.onLogout!();
    } else {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (_) => const LoginScreen(),
        ),
      );
    }
  }

  void _confirmExit(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text(
          'Keluar dari Sesi Operator?',
          style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16),
        ),
        content: const Text(
          'Apakah Anda ingin kembali ke halaman Login Operator?',
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
              _handleLogout();
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

  @override
  Widget build(BuildContext context) {
    final List<Widget> pages = [
      DashboardScreen(
        operator: widget.operator,
        onNavigateToStock: _navigateToStockTab,
        onLogout: _handleLogout,
      ),
      const StockScreen(),
      const ReportsPlaceholderScreen(),
    ];

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        if (_currentIndex != 0) {
          // Jika operator berada di tab Stok atau Laporan, tombol kembali mengembalikan ke Dashboard
          setState(() {
            _currentIndex = 0;
          });
        } else {
          // Jika berada di tab Dashboard, tampilkan konfirmasi keluar ke login
          _confirmExit(context);
        }
      },
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: IndexedStack(
          index: _currentIndex,
          children: pages,
        ),
        bottomNavigationBar: OperatorBottomNav(
          currentIndex: _currentIndex,
          onTabSelected: _onTabSelected,
        ),
      ),
    );
  }
}
