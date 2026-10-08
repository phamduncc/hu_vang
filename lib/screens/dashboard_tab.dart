import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/portfolio_provider.dart';
import '../utils/theme.dart';
import '../widgets/metric_card.dart';
import '../widgets/gold_jar_widget.dart';
import '../widgets/gold_type_card.dart';
import '../widgets/transaction_tile.dart';
import 'add_transaction_screen.dart';
import 'update_price_screen.dart';
import 'goal_detail_screen.dart';

class DashboardTab extends StatelessWidget {
  final Function(int) onNavigateTab;

  const DashboardTab({super.key, required this.onNavigateTab});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<PortfolioProvider>();
    final summary = provider.portfolioSummary;
    final isHidden = provider.isAmountHidden;
    final recentTransactions = provider.transactions.take(3).toList();
    final typeMap = {for (var t in provider.goldTypes) t.id: t};

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            floating: true,
            title: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: AppTheme.goldPrimary.withAlpha(46),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Text('🪙', style: TextStyle(fontSize: 18)),
                ),
                const SizedBox(width: 10),
                const Text(
                  'Hũ Vàng',
                  style: TextStyle(
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.5,
                  ),
                ),
              ],
            ),
            actions: [
              IconButton(
                tooltip: 'Cập nhật giá vàng hôm nay',
                icon: const Icon(Icons.price_change_outlined, color: AppTheme.goldBright),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const UpdatePriceScreen()),
                  );
                },
              ),
              IconButton(
                tooltip: isHidden ? 'Hiện tài sản' : 'Ẩn tài sản',
                icon: Icon(
                  isHidden ? Icons.visibility_off_rounded : Icons.visibility_rounded,
                  color: AppTheme.goldPrimary,
                ),
                onPressed: () => provider.toggleHideAmount(),
              ),
              const SizedBox(width: 8),
            ],
          ),
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                // 1. Dashboard Hero Card
                DashboardHeroCard(
                  totalQuantity: summary.totalQuantity,
                  totalCost: summary.totalCost,
                  averageCostPerChi: summary.averageCostPerChi,
                  totalCurrentValue: summary.totalCurrentValue,
                  totalProfit: summary.totalProfit,
                  totalProfitPercent: summary.totalProfitPercent,
                  totalRealizedProfit: summary.totalRealizedProfit,
                  isHidden: isHidden,
                  onToggleHidden: () => provider.toggleHideAmount(),
                  onAddTransaction: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const AddTransactionScreen()),
                    );
                  },
                ),

                const SizedBox(height: 18),

                // 2. Gold Jar Visual & Goal Progress
                GoldJarWidget(
                  currentQuantity: summary.totalQuantity,
                  targetQuantity: provider.goal.targetQuantity,
                  goalName: provider.goal.name,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const GoalDetailScreen()),
                    );
                  },
                ),

                const SizedBox(height: 24),

                // 3. Gold Types Section (Portfolio Breakdown)
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'DANH MỤC CÁC LOẠI VÀNG',
                      style: TextStyle(
                        color: AppTheme.goldLight,
                        fontSize: 13,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 1.2,
                      ),
                    ),
                    TextButton.icon(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const UpdatePriceScreen()),
                        );
                      },
                      icon: const Icon(Icons.sync_rounded, size: 14, color: AppTheme.goldPrimary),
                      label: const Text(
                        'Cập nhật giá',
                        style: TextStyle(color: AppTheme.goldPrimary, fontSize: 12),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),

                // Cards for each gold type
                ...summary.items.values.map((item) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: GoldTypeCard(
                      item: item,
                      isHidden: isHidden,
                      onUpdatePrice: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => UpdatePriceScreen(initialGoldTypeId: item.goldType.id),
                          ),
                        );
                      },
                    ),
                  );
                }),

                const SizedBox(height: 20),

                // 4. Recent Transactions Section
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'GIAO DỊCH GẦN ĐÂY',
                      style: TextStyle(
                        color: AppTheme.goldLight,
                        fontSize: 13,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 1.2,
                      ),
                    ),
                    TextButton(
                      onPressed: () => onNavigateTab(1), // Chuyển sang tab Giao dịch
                      child: const Text(
                        'Xem tất cả',
                        style: TextStyle(color: AppTheme.goldPrimary, fontSize: 12, fontWeight: FontWeight.w700),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),

                if (recentTransactions.isEmpty)
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: AppTheme.darkCard,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.white12),
                    ),
                    child: const Center(
                      child: Text(
                        'Chưa có giao dịch nào. Bấm [+ Thêm giao dịch] để bắt đầu!',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.white60),
                      ),
                    ),
                  )
                else
                  ...recentTransactions.map((tx) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: TransactionTile(
                        transaction: tx,
                        goldType: typeMap[tx.goldTypeId],
                        isHidden: isHidden,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => AddTransactionScreen(editTransaction: tx),
                            ),
                          );
                        },
                      ),
                    );
                  }),

                const SizedBox(height: 30),
              ]),
            ),
          ),
        ],
      ),
    );
  }
}
