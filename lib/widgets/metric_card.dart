import 'package:flutter/material.dart';
import '../utils/theme.dart';
import '../utils/formatters.dart';

class DashboardHeroCard extends StatelessWidget {
  final double totalQuantity;
  final double totalCost;
  final double averageCostPerChi;
  final double totalCurrentValue;
  final double totalProfit;
  final double totalProfitPercent;
  final double totalRealizedProfit;
  final bool isHidden;
  final VoidCallback onToggleHidden;
  final VoidCallback onAddTransaction;

  const DashboardHeroCard({
    super.key,
    required this.totalQuantity,
    required this.totalCost,
    required this.averageCostPerChi,
    required this.totalCurrentValue,
    required this.totalProfit,
    required this.totalProfitPercent,
    required this.totalRealizedProfit,
    required this.isHidden,
    required this.onToggleHidden,
    required this.onAddTransaction,
  });

  @override
  Widget build(BuildContext context) {
    final isProfit = totalProfit >= 0;

    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            Color(0xFF2A2312),
            Color(0xFF1B1C27),
            Color(0xFF14151E),
          ],
          stops: [0.0, 0.5, 1.0],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(26),
        border: Border.all(color: AppTheme.goldPrimary.withAlpha(102), width: 1.2),
        boxShadow: [
          BoxShadow(
            color: AppTheme.goldPrimary.withAlpha(38),
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      padding: const EdgeInsets.all(22),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Top title and eye icon
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppTheme.goldPrimary.withAlpha(51),
                      shape: BoxShape.circle,
                    ),
                    child: const Text('🪙', style: TextStyle(fontSize: 18)),
                  ),
                  const SizedBox(width: 10),
                  const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'HŨ VÀNG',
                        style: TextStyle(
                          color: AppTheme.goldLight,
                          fontSize: 15,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 2.0,
                        ),
                      ),
                      Text(
                        'Danh mục tài sản cá nhân',
                        style: TextStyle(color: Colors.white54, fontSize: 11),
                      ),
                    ],
                  ),
                ],
              ),
              IconButton(
                onPressed: onToggleHidden,
                icon: Icon(
                  isHidden ? Icons.visibility_off_rounded : Icons.visibility_rounded,
                  color: AppTheme.goldPrimary,
                  size: 22,
                ),
                tooltip: isHidden ? 'Hiện số tiền' : 'Ẩn số tiền',
              ),
            ],
          ),

          const SizedBox(height: 18),

          // Main quantity block
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
            decoration: BoxDecoration(
              color: Colors.black.withAlpha(89),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: AppTheme.goldPrimary.withAlpha(64)),
            ),
            child: Column(
              children: [
                const Text(
                  'TỔNG LƯỢNG VÀNG',
                  style: TextStyle(
                    color: AppTheme.goldLight,
                    fontSize: 11,
                    letterSpacing: 1.5,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  GoldFormatters.formatChi(totalQuantity, isHidden: isHidden),
                  style: const TextStyle(
                    color: AppTheme.goldBright,
                    fontSize: 28,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '≈ ${GoldFormatters.formatLuong(totalQuantity, isHidden: isHidden)}',
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 18),

          // Two-column cost & average cost
          Row(
            children: [
              Expanded(
                child: _buildMetricItem(
                  label: 'Giá vốn',
                  value: GoldFormatters.formatCurrency(totalCost, isHidden: isHidden),
                  sublabel: 'Thực chi tích lũy',
                ),
              ),
              Container(width: 1, height: 40, color: Colors.white12),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(left: 14),
                  child: _buildMetricItem(
                    label: 'Giá mua TB',
                    value: isHidden
                        ? '••••••••'
                        : '${GoldFormatters.formatCurrency(averageCostPerChi, isHidden: false)}/chỉ',
                    sublabel: 'Bình quân gia quyền',
                  ),
                ),
              ),
            ],
          ),

          const Padding(
            padding: EdgeInsets.symmetric(vertical: 14),
            child: Divider(color: Colors.white12, height: 1),
          ),

          // Current Value & Unrealized Profit
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(
                      children: [
                        Icon(Icons.trending_up_rounded, size: 14, color: AppTheme.goldPrimary),
                        SizedBox(width: 4),
                        Text(
                          'Giá trị hiện tại',
                          style: TextStyle(color: Colors.white70, fontSize: 12),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      GoldFormatters.formatCurrency(totalCurrentValue, isHidden: isHidden),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      'Lãi tạm tính',
                      style: TextStyle(
                        color: isProfit ? AppTheme.profitGreen : AppTheme.lossRed,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      GoldFormatters.formatProfit(totalProfit, isHidden: isHidden),
                      style: TextStyle(
                        color: isProfit ? AppTheme.profitGreen : AppTheme.lossRed,
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    Text(
                      '(${GoldFormatters.formatPercent(totalProfitPercent, isHidden: isHidden)})',
                      style: TextStyle(
                        color: isProfit ? AppTheme.profitGreen : AppTheme.lossRed,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          if (totalRealizedProfit.abs() > 0.1) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.white.withAlpha(13),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Lãi đã chốt (đã bán):',
                    style: TextStyle(color: Colors.white60, fontSize: 12),
                  ),
                  Text(
                    GoldFormatters.formatProfit(totalRealizedProfit, isHidden: isHidden),
                    style: TextStyle(
                      color: totalRealizedProfit >= 0 ? AppTheme.profitGreen : AppTheme.lossRed,
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
          ],

          const SizedBox(height: 16),

          // Add transaction button
          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton.icon(
              onPressed: onAddTransaction,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.goldPrimary,
                foregroundColor: Colors.black,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              icon: const Icon(Icons.add_circle_outline_rounded, size: 20),
              label: const Text(
                'Thêm giao dịch mới',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMetricItem({
    required String label,
    required String value,
    required String sublabel,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(color: Colors.white60, fontSize: 12),
        ),
        const SizedBox(height: 3),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 15,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          sublabel,
          style: const TextStyle(color: Colors.white38, fontSize: 10),
        ),
      ],
    );
  }
}
