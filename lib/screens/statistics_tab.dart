import 'dart:math';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import '../models/gold_transaction.dart';
import '../providers/portfolio_provider.dart';
import '../utils/theme.dart';
import '../utils/formatters.dart';
import 'goal_detail_screen.dart';

class StatisticsTab extends StatefulWidget {
  const StatisticsTab({super.key});

  @override
  State<StatisticsTab> createState() => _StatisticsTabState();
}

class _StatisticsTabState extends State<StatisticsTab> {
  int _touchedPieIndex = -1;

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<PortfolioProvider>();
    final summary = provider.portfolioSummary;
    final txs = provider.transactions;
    final isHidden = provider.isAmountHidden;
    final goal = provider.goal;

    // Tính toán tổng số liệu thống kê
    final totalTxCount = txs.length;
    final totalBuySpent = txs
        .where((t) => t.type == TransactionType.buy)
        .fold(0.0, (sum, t) => sum + t.totalAmount);
    final totalSellRevenue = txs
        .where((t) => t.type == TransactionType.sell)
        .fold(0.0, (sum, t) => sum + t.totalAmount);
    final totalRealizedProfit = summary.totalRealizedProfit;

    // Phân bổ theo loại vàng
    final itemsWithQuantity = summary.items.values.where((e) => e.quantity > 0.0001).toList();

    // Thống kê theo tháng (6 tháng gần nhất)
    final monthlySpendMap = <String, double>{};
    final now = DateTime.now();
    for (int i = 5; i >= 0; i--) {
      final m = DateTime(now.year, now.month - i, 1);
      final key = 'T${m.month}/${m.year % 100}';
      monthlySpendMap[key] = 0.0;
    }

    for (final tx in txs) {
      if (tx.type == TransactionType.buy) {
        final key = 'T${tx.transactionDate.month}/${tx.transactionDate.year % 100}';
        if (monthlySpendMap.containsKey(key)) {
          monthlySpendMap[key] = (monthlySpendMap[key] ?? 0.0) + tx.totalAmount;
        }
      }
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Thống Kê Tài Sản', style: TextStyle(fontWeight: FontWeight.w800)),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // 1. Overview Grid
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: AppTheme.darkCard,
              borderRadius: BorderRadius.circular(22),
              border: Border.all(color: Colors.white12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'TỔNG QUAN DANH MỤC',
                  style: TextStyle(
                    color: AppTheme.goldLight,
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1.2,
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: _buildMetricTile(
                        'Tổng giao dịch',
                        '$totalTxCount lượt',
                        Icons.swap_horiz_rounded,
                        AppTheme.goldPrimary,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildMetricTile(
                        'Tổng vàng sở hữu',
                        GoldFormatters.formatChi(summary.totalQuantity, isHidden: isHidden),
                        Icons.circle_outlined,
                        AppTheme.goldBright,
                        subtitle: '≈ ${GoldFormatters.formatLuong(summary.totalQuantity, isHidden: isHidden)}',
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: _buildMetricTile(
                        'Tổng tiền đã mua',
                        GoldFormatters.formatCurrency(totalBuySpent, isHidden: isHidden),
                        Icons.arrow_downward_rounded,
                        AppTheme.profitGreen,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildMetricTile(
                        'Tiền thu về từ bán',
                        GoldFormatters.formatCurrency(totalSellRevenue, isHidden: isHidden),
                        Icons.arrow_upward_rounded,
                        AppTheme.lossRed,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: _buildMetricTile(
                        'Giá vốn trung bình',
                        isHidden ? '••••' : '${GoldFormatters.formatCurrency(summary.averageCostPerChi)}/chỉ',
                        Icons.calculate_outlined,
                        AppTheme.infoBlue,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildMetricTile(
                        'Lãi đã chốt (Bán)',
                        GoldFormatters.formatProfit(totalRealizedProfit, isHidden: isHidden),
                        Icons.monetization_on_outlined,
                        totalRealizedProfit >= 0 ? AppTheme.profitGreen : AppTheme.lossRed,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // 2. Allocation by Gold Type (Pie Chart)
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: AppTheme.darkCard,
              borderRadius: BorderRadius.circular(22),
              border: Border.all(color: Colors.white12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'PHÂN BỔ THEO LOẠI VÀNG',
                      style: TextStyle(
                        color: AppTheme.goldLight,
                        fontSize: 12,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 1.2,
                      ),
                    ),
                    Icon(Icons.pie_chart_outline_rounded, color: AppTheme.goldPrimary, size: 18),
                  ],
                ),
                const SizedBox(height: 16),

                if (itemsWithQuantity.isEmpty)
                  const SizedBox(
                    height: 140,
                    child: Center(
                      child: Text('Chưa có vàng trong danh mục', style: TextStyle(color: Colors.white54)),
                    ),
                  )
                else ...[
                  SizedBox(
                    height: 180,
                    child: PieChart(
                      PieChartData(
                        pieTouchData: PieTouchData(
                          touchCallback: (event, pieTouchResponse) {
                            setState(() {
                              if (!event.isInterestedForInteractions ||
                                  pieTouchResponse == null ||
                                  pieTouchResponse.touchedSection == null) {
                                _touchedPieIndex = -1;
                                return;
                              }
                              _touchedPieIndex = pieTouchResponse
                                  .touchedSection!.touchedSectionIndex;
                            });
                          },
                        ),
                        sectionsSpace: 3,
                        centerSpaceRadius: 40,
                        sections: List.generate(itemsWithQuantity.length, (i) {
                          final item = itemsWithQuantity[i];
                          final isTouched = i == _touchedPieIndex;
                          final totalQ = summary.totalQuantity;
                          final pct = totalQ > 0 ? (item.quantity / totalQ) * 100 : 0.0;
                          final radius = isTouched ? 50.0 : 42.0;

                          return PieChartSectionData(
                            color: Color(item.goldType.colorValue),
                            value: item.quantity,
                            title: '${pct.toStringAsFixed(0)}%',
                            radius: radius,
                            titleStyle: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
                          );
                        }),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Legends
                  ...itemsWithQuantity.map((item) {
                    final pct = summary.totalQuantity > 0
                        ? (item.quantity / summary.totalQuantity) * 100
                        : 0.0;
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      child: Row(
                        children: [
                          Container(
                            width: 10,
                            height: 10,
                            decoration: BoxDecoration(
                              color: Color(item.goldType.colorValue),
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              item.goldType.name,
                              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                            ),
                          ),
                          Text(
                            '${pct.toStringAsFixed(1)}% ',
                            style: const TextStyle(color: Colors.white70, fontSize: 13, fontWeight: FontWeight.w700),
                          ),
                          Text(
                            '(${GoldFormatters.formatChi(item.quantity, isHidden: isHidden)})',
                            style: const TextStyle(color: Colors.white38, fontSize: 12),
                          ),
                        ],
                      ),
                    );
                  }),
                ],
              ],
            ),
          ),

          const SizedBox(height: 20),

          // 3. Monthly Spend Bar Chart
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: AppTheme.darkCard,
              borderRadius: BorderRadius.circular(22),
              border: Border.all(color: Colors.white12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'TIỀN MUA VÀNG THEO THÁNG',
                      style: TextStyle(
                        color: AppTheme.goldLight,
                        fontSize: 12,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 1.2,
                      ),
                    ),
                    Icon(Icons.bar_chart_rounded, color: AppTheme.goldPrimary, size: 20),
                  ],
                ),
                const SizedBox(height: 6),
                const Text(
                  '6 tháng gần đây nhất (triệu đồng)',
                  style: TextStyle(color: Colors.white38, fontSize: 11),
                ),
                const SizedBox(height: 18),

                SizedBox(
                  height: 180,
                  child: BarChart(
                    BarChartData(
                      alignment: BarChartAlignment.spaceAround,
                      maxY: (monthlySpendMap.values.fold(0.0, max) / 1000000) * 1.25 + 5,
                      barTouchData: BarTouchData(
                        touchTooltipData: BarTouchTooltipData(
                          getTooltipItem: (group, groupIndex, rod, rodIndex) {
                            final monthKey = monthlySpendMap.keys.elementAt(groupIndex);
                            final valM = rod.toY;
                            return BarTooltipItem(
                              '$monthKey\n${valM.toStringAsFixed(1)} triệu',
                              const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                            );
                          },
                        ),
                      ),
                      titlesData: FlTitlesData(
                        show: true,
                        topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                        rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                        leftTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            reservedSize: 32,
                            getTitlesWidget: (val, meta) {
                              if (val % 20 == 0 || val == 0) {
                                return Text(
                                  '${val.toInt()}M',
                                  style: const TextStyle(color: Colors.white38, fontSize: 9),
                                );
                              }
                              return const SizedBox();
                            },
                          ),
                        ),
                        bottomTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            getTitlesWidget: (val, meta) {
                              final idx = val.toInt();
                              if (idx >= 0 && idx < monthlySpendMap.length) {
                                return Padding(
                                  padding: const EdgeInsets.only(top: 6),
                                  child: Text(
                                    monthlySpendMap.keys.elementAt(idx),
                                    style: const TextStyle(color: Colors.white60, fontSize: 10),
                                  ),
                                );
                              }
                              return const SizedBox();
                            },
                          ),
                        ),
                      ),
                      gridData: FlGridData(
                        show: true,
                        drawVerticalLine: false,
                        getDrawingHorizontalLine: (val) => FlLine(
                          color: Colors.white.withAlpha(13),
                          strokeWidth: 1,
                        ),
                      ),
                      borderData: FlBorderData(show: false),
                      barGroups: List.generate(monthlySpendMap.length, (i) {
                        final valTrieu = (monthlySpendMap.values.elementAt(i) / 1000000);
                        return BarChartGroupData(
                          x: i,
                          barRods: [
                            BarChartRodData(
                              toY: valTrieu,
                              gradient: const LinearGradient(
                                colors: [Color(0xFFE5C158), Color(0xFFB38F24)],
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                              ),
                              width: 16,
                              borderRadius: const BorderRadius.vertical(top: Radius.circular(6)),
                            ),
                          ],
                        );
                      }),
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // 4. Goal & Projection Shortcut
          InkWell(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const GoalDetailScreen()),
              );
            },
            borderRadius: BorderRadius.circular(20),
            child: Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF262013), Color(0xFF1B1B25)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppTheme.goldPrimary.withAlpha(76)),
              ),
              child: Row(
                children: [
                  const Text('🎯', style: TextStyle(fontSize: 28)),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          goal.name,
                          style: const TextStyle(
                            color: AppTheme.goldBright,
                            fontSize: 15,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Mục tiêu: ${GoldFormatters.formatChi(goal.targetQuantity)} • Mua ${GoldFormatters.formatChi(goal.monthlyTargetQuantity)}/tháng',
                          style: const TextStyle(color: Colors.white70, fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                  const Icon(Icons.arrow_forward_ios_rounded, size: 16, color: AppTheme.goldPrimary),
                ],
              ),
            ),
          ),

          const SizedBox(height: 30),
        ],
      ),
    );
  }

  Widget _buildMetricTile(String title, String value, IconData icon, Color color, {String? subtitle}) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppTheme.darkCardElevated,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white.withAlpha(15)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 14, color: color),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(color: Colors.white60, fontSize: 11),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w800),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          if (subtitle != null) ...[
            const SizedBox(height: 2),
            Text(
              subtitle,
              style: const TextStyle(color: Colors.white38, fontSize: 10),
            ),
          ],
        ],
      ),
    );
  }
}
