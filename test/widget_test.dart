import 'package:flutter_test/flutter_test.dart';
import 'package:hu_vang/models/gold_type.dart';
import 'package:hu_vang/models/gold_transaction.dart';
import 'package:hu_vang/utils/formatters.dart';

void main() {
  test('Gold formatters test', () {
    expect(GoldFormatters.formatChi(12.5), '12.5 chỉ');
    expect(GoldFormatters.formatLuong(12.5), '1.25 lượng');
    expect(GoldFormatters.formatCurrency(126500000), '126.500.000 đ');
    expect(GoldFormatters.formatProfit(5500000), '+5.500.000 đ');
    expect(GoldFormatters.formatProfit(-2000000), '-2.000.000 đ');
  });

  test('GoldType default count', () {
    final types = GoldType.defaultTypes;
    expect(types.length, greaterThanOrEqualTo(5));
    expect(types.any((t) => t.id == 'nhan_9999'), isTrue);
    expect(types.any((t) => t.id == 'sjc_mieng'), isTrue);
  });

  test('Transaction calculation test', () {
    final tx = GoldTransaction(
      id: 'test_1',
      goldTypeId: 'nhan_9999',
      type: TransactionType.buy,
      quantity: 2.5,
      pricePerUnit: 15200000,
      fee: 0,
      totalAmount: 38000000,
      transactionDate: DateTime(2026, 10, 8),
    );

    expect(tx.quantityInLuong, 0.25);
    expect(tx.totalAmount, 38000000);
  });
}
