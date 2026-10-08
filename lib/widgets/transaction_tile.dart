import 'package:flutter/material.dart';
import '../models/gold_transaction.dart';
import '../models/gold_type.dart';
import '../utils/theme.dart';
import '../utils/formatters.dart';

class TransactionTile extends StatelessWidget {
  final GoldTransaction transaction;
  final GoldType? goldType;
  final bool isHidden;
  final VoidCallback onTap;

  const TransactionTile({
    super.key,
    required this.transaction,
    this.goldType,
    required this.isHidden,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final typeName = goldType?.name ?? 'Vàng';

    Color badgeColor;
    IconData icon;
    String sign;

    if (transaction.type == TransactionType.buy) {
      badgeColor = AppTheme.profitGreen;
      icon = Icons.add_circle_outline_rounded;
      sign = '+';
    } else if (transaction.type == TransactionType.sell) {
      badgeColor = AppTheme.lossRed;
      icon = Icons.remove_circle_outline_rounded;
      sign = '-';
    } else if (transaction.type == TransactionType.giftReceived) {
      badgeColor = const Color(0xFF38BDF8);
      icon = Icons.card_giftcard_rounded;
      sign = '+';
    } else if (transaction.type == TransactionType.giftGiven) {
      badgeColor = const Color(0xFFF472B6);
      icon = Icons.volunteer_activism_rounded;
      sign = '-';
    } else {
      badgeColor = AppTheme.goldPrimary;
      icon = Icons.tune_rounded;
      sign = '±';
    }

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppTheme.darkCardElevated,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.white.withAlpha(15)),
        ),
        child: Column(
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Type Icon Badge
                Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    color: badgeColor.withAlpha(38),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: badgeColor.withAlpha(100)),
                  ),
                  child: Icon(icon, color: badgeColor, size: 20),
                ),
                const SizedBox(width: 12),

                // Middle Info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            transaction.type.label,
                            style: TextStyle(
                              color: badgeColor,
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Container(
                            width: 3,
                            height: 3,
                            decoration: const BoxDecoration(
                              color: Colors.white38,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              typeName,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${GoldFormatters.formatDate(transaction.transactionDate)}${transaction.shop != null && transaction.shop!.isNotEmpty ? ' • ${transaction.shop}' : ''}',
                        style: const TextStyle(color: Colors.white38, fontSize: 11),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      if (transaction.note != null && transaction.note!.isNotEmpty) ...[
                        const SizedBox(height: 2),
                        Text(
                          transaction.note!,
                          style: const TextStyle(
                            color: Colors.white54,
                            fontSize: 11,
                            fontStyle: FontStyle.italic,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ],
                  ),
                ),

                const SizedBox(width: 8),

                // Right metrics: Quantity & Total money
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '$sign${GoldFormatters.formatChi(transaction.quantity, isHidden: isHidden)}',
                      style: TextStyle(
                        color: badgeColor,
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      GoldFormatters.formatCurrency(transaction.totalAmount, isHidden: isHidden),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Text(
                      '@${GoldFormatters.formatCurrency(transaction.pricePerUnit, isHidden: isHidden)}/chỉ',
                      style: const TextStyle(color: Colors.white38, fontSize: 10),
                    ),
                  ],
                ),
              ],
            ),

            if (transaction.type == TransactionType.sell &&
                transaction.realizedProfit != null) ...[
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: (transaction.realizedProfit! >= 0
                          ? AppTheme.profitGreen
                          : AppTheme.lossRed)
                      .withAlpha(30),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Lãi chốt lời giao dịch này:',
                      style: TextStyle(color: Colors.white60, fontSize: 11),
                    ),
                    Text(
                      GoldFormatters.formatProfit(
                        transaction.realizedProfit!,
                        isHidden: isHidden,
                      ),
                      style: TextStyle(
                        color: transaction.realizedProfit! >= 0
                            ? AppTheme.profitGreen
                            : AppTheme.lossRed,
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
