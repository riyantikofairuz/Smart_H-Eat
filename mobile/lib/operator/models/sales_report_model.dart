enum SalesPeriod {
  daily,
  weekly,
  monthly,
}

class SalesDailyTrend {
  final String dayName;
  final int count;
  final bool isPeak;

  SalesDailyTrend({
    required this.dayName,
    required this.count,
    this.isPeak = false,
  });
}

class MenuSalesStat {
  final String menuName;
  final int portionsSold;
  final double totalRevenue;
  final String? imageUrl;

  MenuSalesStat({
    required this.menuName,
    required this.portionsSold,
    required this.totalRevenue,
    this.imageUrl,
  });
}

class SalesReportData {
  final SalesPeriod period;
  final String totalRevenueDisplay;
  final int totalPortions;
  final String peakSummary;
  final List<SalesDailyTrend> dailyTrends;
  final List<MenuSalesStat> menuSales;

  SalesReportData({
    required this.period,
    required this.totalRevenueDisplay,
    required this.totalPortions,
    required this.peakSummary,
    required this.dailyTrends,
    required this.menuSales,
  });
}
