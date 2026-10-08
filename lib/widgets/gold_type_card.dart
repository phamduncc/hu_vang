import 'package:flutter/material.dart';
import '../models/portfolio.dart';
import '../utils/theme.dart';
import '../utils/formatters.dart';

class GoldTypeCard extends StatelessWidget {
  final GoldTypePortfolio item;
  final bool isHidden;
  final VoidCallback onUpdatePrice;
  final VoidCallback? onTap;

  const GoldTypeCard({
    super.key,
    required this.item,
    required this.isHidden,
    required this.onUpdatePrice,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final type = item.goldType;
    final isProfit = item.profit >= 0;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppTheme.darkCard,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: Color(type.colorValue).withAlpha(76),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha(50),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          children: [
            // Top row: Type title, purity badge, price edit
            Row(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: Color(type.colorValue).withAlpha(50),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: Color(type.colorValue).withAlpha(128)),
                  ),
                  child: Center(
                    child: Text(
                      '🟡',
                      style: TextStyle(fontSize: 16, color: Color(type.colorValue)),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        type.name,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      Text(
                        'Độ tinh khiết: ${type.purity}%',
                        style: const TextStyle(color: Colors.white54, fontSize: 11),
                      ),
                    ],
                  ),
                ),
                TextButton.icon(
                  onPressed: onUpdatePrice,
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    backgroundColor: Colors.white.withAlpha(15),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  icon: const Icon(Icons.edit_note_rounded, size: 16, color: AppTheme.goldPrimary),
                  label: const Text(
                    'Sửa giá',
                    style: TextStyle(color: AppTheme.goldPrimary, fontSize: 11, fontWeight: FontWeight.w600),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 14),

            // Middle section: Quantity & Current value
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Số lượng sở hữu', style: TextStyle(color: Colors.white54, fontSize: 11)),
                    const SizedBox(height: 2),
                    Text(
                      GoldFormatters.formatChi(item.quantity, isHidden: isHidden),
                      style: const TextStyle(
                        color: AppTheme.goldBright,
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    Text(
                      '≈ ${GoldFormatters.formatLuong(item.quantity, isHidden: isHidden)}',
                      style: const TextStyle(color: Colors.white38, fontSize: 11),
                    ),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    const Text('Giá trị hiện tại', style: TextStyle(color: Colors.white54, fontSize: 11)),
                    const SizedBox(height: 2),
                    Text(
                      GoldFormatters.formatCurrency(item.currentValue, isHidden: isHidden),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    Text(
                      '${isProfit ? "+" : ""}${GoldFormatters.formatCurrency(item.profit, isHidden: isHidden)} (${GoldFormatters.formatPercent(item.profitPercent, isHidden: isHidden)})',
                      style: TextStyle(
                        color: isProfit ? AppTheme.profitGreen : AppTheme.lossRed,
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ],
            ),

            const SizedBox(height: 12),
            Container(height: 1, color: Colors.white.withAlpha(15)),
            const SizedBox(height: 10),

            // Bottom detail strip: Giá vốn vs Giá TB vs Giá TT
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildSubMetric(
                  'Giá vốn',
                  GoldFormatters.formatCurrency(item.totalCost, isHidden: isHidden),
                ),
                _buildSubMetric(
                  'Giá mua TB/chỉ',
                  isHidden ? '••••' : GoldFormatters.formatCurrency(item.averageCost),
                ),
                _buildSubMetric(
                  'Giá thị trường/chỉ',
                  GoldFormatters.formatCurrency(item.marketPrice),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSubMetric(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(color: Colors.white38, fontSize: 10)),
        const SizedBox(height: 2),
        Text(
          value,
          style: const TextStyle(color: Colors.white70, fontSize: 11, fontWeight: FontWeight.w600),
        ),
      ],
    );
  }
}
