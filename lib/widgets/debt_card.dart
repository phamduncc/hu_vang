import 'package:flutter/material.dart';
import '../models/gold_debt.dart';
import '../models/gold_type.dart';
import '../utils/theme.dart';
import '../utils/formatters.dart';

class DebtCard extends StatelessWidget {
  final GoldDebt debt;
  final GoldType? goldType;
  final double currentMarketPrice;
  final bool isHidden;
  final VoidCallback onTap;
  final VoidCallback onPay;

  const DebtCard({
    super.key,
    required this.debt,
    this.goldType,
    required this.currentMarketPrice,
    required this.isHidden,
    required this.onTap,
    required this.onPay,
  });

  @override
  Widget build(BuildContext context) {
    final isIOwe = debt.direction == DebtDirection.iOwe;
    final isGold = debt.assetType == DebtAssetType.gold;
    final directionColor = isIOwe ? AppTheme.lossRed : AppTheme.profitGreen;
    final directionBg = directionColor.withAlpha(35);
    final isSettled = debt.isSettled || debt.remainingAmount <= 0.0001;

    // Giá trị quy đổi thị trường hôm nay
    double marketVal = 0.0;
    if (isGold) {
      marketVal = debt.remainingAmount * currentMarketPrice;
    } else {
      marketVal = debt.remainingAmount;
    }

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppTheme.darkCardElevated,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: debt.isOverdue
                ? AppTheme.lossRed.withAlpha(128)
                : (isSettled ? Colors.white12 : directionColor.withAlpha(60)),
            width: debt.isOverdue ? 1.5 : 1.0,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha(40),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top row: Person Name + Direction Badge
            Row(
              children: [
                CircleAvatar(
                  radius: 18,
                  backgroundColor: directionBg,
                  child: Icon(
                    isIOwe ? Icons.arrow_outward_rounded : Icons.arrow_downward_rounded,
                    color: directionColor,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        debt.personName,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        isIOwe ? 'Tôi nợ người này' : 'Người này nợ tôi',
                        style: TextStyle(
                          color: directionColor,
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
                if (isSettled)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: AppTheme.profitGreen.withAlpha(40),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Text(
                      'ĐÃ TRẢ HẾT',
                      style: TextStyle(
                        color: AppTheme.profitGreen,
                        fontSize: 10,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  )
                else if (debt.isOverdue)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: AppTheme.lossRed.withAlpha(40),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Text(
                      'QUÁ HẠN',
                      style: TextStyle(
                        color: AppTheme.lossRed,
                        fontSize: 10,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  )
                else
                  TextButton.icon(
                    onPressed: onPay,
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      minimumSize: Size.zero,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      backgroundColor: AppTheme.goldPrimary.withAlpha(35),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    icon: const Icon(Icons.payment_rounded, size: 14, color: AppTheme.goldBright),
                    label: const Text(
                      'Trả bớt',
                      style: TextStyle(color: AppTheme.goldBright, fontSize: 11, fontWeight: FontWeight.w700),
                    ),
                  ),
              ],
            ),

            const SizedBox(height: 14),

            // Middle: Remaining Debt Amount
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      isGold ? (goldType?.name ?? 'Vàng') : 'Tiền mặt',
                      style: const TextStyle(color: Colors.white54, fontSize: 11),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      isGold
                          ? GoldFormatters.formatChi(debt.remainingAmount, isHidden: isHidden)
                          : GoldFormatters.formatCurrency(debt.remainingAmount, isHidden: isHidden),
                      style: TextStyle(
                        color: isSettled ? Colors.white60 : Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    if (isGold)
                      Text(
                        '≈ ${GoldFormatters.formatLuong(debt.remainingAmount, isHidden: isHidden)}',
                        style: const TextStyle(color: Colors.white38, fontSize: 11),
                      ),
                  ],
                ),
                if (!isSettled && isGold && marketVal > 0)
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      const Text(
                        'Quy đổi theo giá TT',
                        style: TextStyle(color: AppTheme.goldLight, fontSize: 10),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        GoldFormatters.formatCurrency(marketVal, isHidden: isHidden),
                        style: const TextStyle(
                          color: AppTheme.goldBright,
                          fontSize: 14,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ],
                  ),
              ],
            ),

            const SizedBox(height: 12),

            // Progress bar
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: debt.paidPercentage / 100.0,
                minHeight: 6,
                backgroundColor: Colors.white.withAlpha(20),
                valueColor: AlwaysStoppedAnimation<Color>(
                  isSettled ? AppTheme.profitGreen : AppTheme.goldPrimary,
                ),
              ),
            ),

            const SizedBox(height: 8),

            // Sub info: Ngày vay vs Hạn chót
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Vay: ${GoldFormatters.formatDate(debt.startDate)}',
                  style: const TextStyle(color: Colors.white38, fontSize: 11),
                ),
                if (debt.dueDate != null)
                  Text(
                    'Hạn: ${GoldFormatters.formatDate(debt.dueDate!)}',
                    style: TextStyle(
                      color: debt.isOverdue ? AppTheme.lossRed : Colors.white54,
                      fontSize: 11,
                      fontWeight: debt.isOverdue ? FontWeight.w700 : FontWeight.normal,
                    ),
                  )
                else
                  Text(
                    'Đã trả: ${debt.paidPercentage.toStringAsFixed(0)}%',
                    style: const TextStyle(color: Colors.white38, fontSize: 11),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
