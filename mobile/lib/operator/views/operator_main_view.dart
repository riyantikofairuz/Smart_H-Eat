import 'package:flutter/material.dart';
import '../services/dummy_operator_service.dart';
import 'auth/operator_login_view.dart';
import 'dashboard/operator_dashboard_view.dart';
import 'menu/menu_list_view.dart';
import 'report/sales_report_view.dart';

class OperatorMainView extends StatefulWidget {
  const OperatorMainView({super.key});

  @override
  State<OperatorMainView> createState() => _OperatorMainViewState();
}

class _OperatorMainViewState extends State<OperatorMainView> {
  final DummyOperatorService _service = DummyOperatorService();
  int _currentIndex = 0; // Default to Dashboard (Tab 0)

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

  void _onTabSelected(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    // If operator is not logged in, show OperatorLoginView (UC-F014)
    if (!_service.isLoggedIn) {
      return OperatorLoginView(
        onLoginSuccess: () {
          setState(() {
            _currentIndex = 0;
          });
        },
      );
    }

    switch (_currentIndex) {
      case 0:
        return OperatorDashboardView(onNavigateTab: _onTabSelected);
      case 1:
        return MenuListView(onNavigateTab: _onTabSelected);
      case 2:
        return SalesReportView(onNavigateTab: _onTabSelected);
      default:
        return MenuListView(onNavigateTab: _onTabSelected);
    }
  }
}
