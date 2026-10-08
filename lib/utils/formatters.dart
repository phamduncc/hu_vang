import 'package:intl/intl.dart';

class GoldFormatters {
  static final NumberFormat _currencyFormat = NumberFormat('#,###', 'vi_VN');
  static final DateFormat _dateFormat = DateFormat('dd/MM/yyyy');
  static final DateFormat _dateTimeFormat = DateFormat('dd/MM/yyyy HH:mm');
  static final DateFormat _monthYearFormat = DateFormat('MM/yyyy');

  /// Định dạng tiền tệ VNĐ (ví dụ: 126.500.000 đ)
  static String formatCurrency(double amount, {bool isHidden = false, bool includeSymbol = true}) {
    if (isHidden) return '••••••••';
    final sign = amount < 0 ? '-' : '';
    final absVal = amount.abs().round();
    final formatted = _currencyFormat.format(absVal);
    final symbol = includeSymbol ? ' đ' : '';
    return '$sign$formatted$symbol';
  }

  /// Định dạng lãi/lỗ có dấu + / - (ví dụ: +5.500.000 đ)
  static String formatProfit(double amount, {bool isHidden = false}) {
    if (isHidden) return '••••••••';
    final prefix = amount > 0 ? '+' : (amount < 0 ? '-' : '');
    final absVal = amount.abs().round();
    final formatted = _currencyFormat.format(absVal);
    return '$prefix$formatted đ';
  }

  /// Định dạng phần trăm (ví dụ: +4.35%)
  static String formatPercent(double percent, {bool isHidden = false}) {
    if (isHidden) return '••%';
    final prefix = percent > 0 ? '+' : '';
    return '$prefix${percent.toStringAsFixed(2)}%';
  }

  /// Định dạng số lượng vàng theo chỉ (ví dụ: 12.5 chỉ)
  static String formatChi(double quantity, {bool isHidden = false}) {
    if (isHidden) return '•• chỉ';
    // Format gọn số thập phân
    final str = quantity.toStringAsFixed(2).replaceAll(RegExp(r'\.?0+$'), '');
    return '$str chỉ';
  }

  /// Định dạng số lượng vàng theo lượng (ví dụ: 1.25 lượng)
  static String formatLuong(double quantityInChi, {bool isHidden = false}) {
    if (isHidden) return '•• lượng';
    final luong = quantityInChi / 10.0;
    final str = luong.toStringAsFixed(3).replaceAll(RegExp(r'\.?0+$'), '');
    return '$str lượng';
  }

  /// Hiển thị cả 2 đơn vị: 12.5 chỉ ≈ 1.25 lượng
  static String formatDualUnit(double quantityInChi, {bool isHidden = false}) {
    if (isHidden) return '••••';
    final chiStr = formatChi(quantityInChi);
    final luongStr = formatLuong(quantityInChi);
    return '$chiStr  ≈  $luongStr';
  }

  /// Định dạng ngày (dd/MM/yyyy)
  static String formatDate(DateTime date) => _dateFormat.format(date);

  /// Định dạng ngày giờ (dd/MM/yyyy HH:mm)
  static String formatDateTime(DateTime date) => _dateTimeFormat.format(date);

  /// Định dạng tháng/năm (MM/yyyy)
  static String formatMonthYear(DateTime date) => _monthYearFormat.format(date);
}
