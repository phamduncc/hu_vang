import 'gold_type.dart';

class GoldTypePortfolio {
  final GoldType goldType;
  final double quantity; // Số chỉ
  final double totalCost; // Giá vốn còn lại
  final double averageCost; // Giá mua trung bình / chỉ
  final double marketPrice; // Giá thị trường tham chiếu
  final double currentValue; // Giá trị thị trường hiện tại
  final double profit; // Lãi/lỗ tạm tính
  final double profitPercent; // % Lãi/lỗ tạm tính
  final double realizedProfit; // Lãi đã chốt từ bán vàng

  const GoldTypePortfolio({
    required this.goldType,
    required this.quantity,
    required this.totalCost,
    required this.averageCost,
    required this.marketPrice,
    required this.currentValue,
    required this.profit,
    required this.profitPercent,
    required this.realizedProfit,
  });

  double get quantityInLuong => quantity / 10.0;
}

class PortfolioSummary {
  final double totalQuantity; // Số chỉ
  final double totalCost; // Tổng giá vốn
  final double averageCostPerChi; // Giá vốn trung bình chung / chỉ
  final double totalCurrentValue; // Tổng giá trị thị trường
  final double totalProfit; // Lãi tạm tính
  final double totalProfitPercent; // % Lãi tạm tính
  final double totalRealizedProfit; // Lãi đã chốt
  final Map<String, GoldTypePortfolio> items;

  const PortfolioSummary({
    required this.totalQuantity,
    required this.totalCost,
    required this.averageCostPerChi,
    required this.totalCurrentValue,
    required this.totalProfit,
    required this.totalProfitPercent,
    required this.totalRealizedProfit,
    required this.items,
  });

  double get totalQuantityInLuong => totalQuantity / 10.0;

  factory PortfolioSummary.empty() {
    return const PortfolioSummary(
      totalQuantity: 0,
      totalCost: 0,
      averageCostPerChi: 0,
      totalCurrentValue: 0,
      totalProfit: 0,
      totalProfitPercent: 0,
      totalRealizedProfit: 0,
      items: {},
    );
  }
}
