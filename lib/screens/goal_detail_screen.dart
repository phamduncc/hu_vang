import 'dart:math';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/portfolio_provider.dart';
import '../utils/theme.dart';
import '../utils/formatters.dart';
import '../widgets/gold_jar_widget.dart';

class GoalDetailScreen extends StatefulWidget {
  const GoalDetailScreen({super.key});

  @override
  State<GoalDetailScreen> createState() => _GoalDetailScreenState();
}

class _GoalDetailScreenState extends State<GoalDetailScreen> {
  final _nameController = TextEditingController();
  final _targetQtyController = TextEditingController();
  final _monthlyQtyController = TextEditingController();

  String _targetUnit = 'chỉ'; // 'chỉ' hoặc 'lượng'
  String _monthlyUnit = 'chỉ';

  @override
  void initState() {
    super.initState();
    final goal = context.read<PortfolioProvider>().goal;
    _nameController.text = goal.name;
    _targetQtyController.text = goal.targetQuantity.toString();
    _monthlyQtyController.text = goal.monthlyTargetQuantity.toString();
  }

  void _saveGoal() {
    final name = _nameController.text.trim();
    final rawTarget = double.tryParse(_targetQtyController.text.replaceAll(',', '.')) ?? 20.0;
    final rawMonthly = double.tryParse(_monthlyQtyController.text.replaceAll(',', '.')) ?? 1.0;

    final targetInChi = _targetUnit == 'lượng' ? rawTarget * 10.0 : rawTarget;
    final monthlyInChi = _monthlyUnit == 'lượng' ? rawMonthly * 10.0 : rawMonthly;

    final provider = context.read<PortfolioProvider>();
    final updated = provider.goal.copyWith(
      name: name.isEmpty ? 'Hũ Vàng Tích Lũy' : name,
      targetQuantity: targetInChi,
      monthlyTargetQuantity: monthlyInChi,
    );

    provider.updateGoal(updated);
    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Đã cập nhật mục tiêu & kế hoạch hũ vàng!'),
        backgroundColor: AppTheme.profitGreen,
      ),
    );
  }

  void _setPreset(double targetInChi) {
    setState(() {
      _targetUnit = 'chỉ';
      _targetQtyController.text = targetInChi.toString();
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<PortfolioProvider>();
    final goal = provider.goal;
    final summary = provider.portfolioSummary;

    final currentQty = summary.totalQuantity;
    final targetQty = goal.targetQuantity > 0 ? goal.targetQuantity : 20.0;
    final remaining = max(0.0, targetQty - currentQty);

    // Kế hoạch mua tích lũy
    final monthlyQty = goal.monthlyTargetQuantity > 0 ? goal.monthlyTargetQuantity : 1.0;
    final monthsNeeded = monthlyQty > 0 ? (remaining / monthlyQty).ceil() : 0;
    final now = DateTime.now();
    final projectedTargetDate = DateTime(now.year, now.month + monthsNeeded, now.day);

    // Ước tính tiền cần mỗi tháng (dựa trên giá TB hoặc giá thị trường đã nhập)
    final refPrice = summary.totalCost > 0 && summary.totalQuantity > 0
        ? summary.averageCostPerChi
        : (provider.prices.values.isNotEmpty ? provider.prices.values.first.sellPrice : 0.0);
    final estimatedMonthlyCost = monthlyQty * refPrice;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Mục Tiêu & Kế Hoạch Hũ Vàng', style: TextStyle(fontWeight: FontWeight.w700)),
        actions: [
          TextButton(
            onPressed: _saveGoal,
            child: const Text(
              'LƯU',
              style: TextStyle(color: AppTheme.goldBright, fontWeight: FontWeight.w800),
            ),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          // Visual Gold Jar
          GoldJarWidget(
            currentQuantity: currentQty,
            targetQuantity: targetQty,
            goalName: goal.name,
          ),

          const SizedBox(height: 24),

          // Kế hoạch mua vàng card
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF231D12), Color(0xFF161822)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AppTheme.goldPrimary.withAlpha(90)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(
                  children: [
                    Icon(Icons.calendar_month_rounded, color: AppTheme.goldBright, size: 20),
                    SizedBox(width: 8),
                    Text(
                      'DỰ BÁO KẾ HOẠCH MUA VÀNG',
                      style: TextStyle(
                        color: AppTheme.goldLight,
                        fontSize: 12,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 1.2,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                Row(
                  children: [
                    Expanded(
                      child: _buildPlanStat(
                        'Mục tiêu',
                        GoldFormatters.formatChi(targetQty),
                        GoldFormatters.formatLuong(targetQty),
                      ),
                    ),
                    Expanded(
                      child: _buildPlanStat(
                        'Hiện có',
                        GoldFormatters.formatChi(currentQty),
                        GoldFormatters.formatLuong(currentQty),
                      ),
                    ),
                    Expanded(
                      child: _buildPlanStat(
                        'Còn thiếu',
                        GoldFormatters.formatChi(remaining),
                        GoldFormatters.formatLuong(remaining),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Container(height: 1, color: Colors.white12),
                const SizedBox(height: 14),

                if (remaining <= 0)
                  const Text(
                    '🎉 Xin chúc mừng! Bạn đã hoàn thành 100% mục tiêu tích lũy vàng này.',
                    style: TextStyle(color: AppTheme.profitGreen, fontWeight: FontWeight.w600),
                  )
                else ...[
                  RichText(
                    text: TextSpan(
                      style: const TextStyle(color: Colors.white70, fontSize: 13, height: 1.5),
                      children: [
                        const TextSpan(text: 'Nếu mua đều đặn '),
                        TextSpan(
                          text: '${GoldFormatters.formatChi(monthlyQty)}/tháng',
                          style: const TextStyle(color: AppTheme.goldBright, fontWeight: FontWeight.w800),
                        ),
                        if (estimatedMonthlyCost > 0) ...[
                          const TextSpan(text: ' (~'),
                          TextSpan(
                            text: GoldFormatters.formatCurrency(estimatedMonthlyCost),
                            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700),
                          ),
                          const TextSpan(text: '/tháng)'),
                        ],
                        const TextSpan(text: ':\n'),
                        const TextSpan(text: '👉 Bạn sẽ về đích sau '),
                        TextSpan(
                          text: '$monthsNeeded tháng',
                          style: const TextStyle(color: AppTheme.goldBright, fontWeight: FontWeight.w800),
                        ),
                        const TextSpan(text: ' (Dự kiến: '),
                        TextSpan(
                          text: 'Tháng ${projectedTargetDate.month}/${projectedTargetDate.year}',
                          style: const TextStyle(color: AppTheme.profitGreen, fontWeight: FontWeight.w800),
                        ),
                        const TextSpan(text: ')!'),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),

          const SizedBox(height: 28),

          // Form chỉnh sửa mục tiêu
          const Text(
            'CHỈNH SỬA MỤC TIÊU',
            style: TextStyle(color: AppTheme.goldLight, fontSize: 13, fontWeight: FontWeight.w800, letterSpacing: 1.1),
          ),
          const SizedBox(height: 12),

          // Tên mục tiêu
          TextFormField(
            controller: _nameController,
            decoration: const InputDecoration(
              labelText: 'Tên Hũ Vàng / Mục tiêu',
              hintText: 'Ví dụ: Hũ Vàng Cưới, Mua Nhà, Tích Lũy 2 Cây',
            ),
          ),

          const SizedBox(height: 16),

          // Số lượng mục tiêu
          Row(
            children: [
              Expanded(
                child: TextFormField(
                  controller: _targetQtyController,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  decoration: InputDecoration(
                    labelText: 'Số lượng mục tiêu',
                    suffixText: _targetUnit,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              SegmentedButton<String>(
                segments: const [
                  ButtonSegment(value: 'chỉ', label: Text('Chỉ')),
                  ButtonSegment(value: 'lượng', label: Text('Lượng')),
                ],
                selected: {_targetUnit},
                onSelectionChanged: (val) {
                  setState(() => _targetUnit = val.first);
                },
              ),
            ],
          ),

          const SizedBox(height: 10),

          // Quick Presets
          Wrap(
            spacing: 8,
            runSpacing: 6,
            children: [
              _buildPresetChip('5 chỉ', 5.0),
              _buildPresetChip('1 lượng (10 chỉ)', 10.0),
              _buildPresetChip('2 lượng (20 chỉ)', 20.0),
              _buildPresetChip('5 lượng (50 chỉ)', 50.0),
              _buildPresetChip('10 lượng (100 chỉ)', 100.0),
            ],
          ),

          const SizedBox(height: 20),

          // Kế hoạch mua hàng tháng
          Row(
            children: [
              Expanded(
                child: TextFormField(
                  controller: _monthlyQtyController,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  decoration: InputDecoration(
                    labelText: 'Kế hoạch mua mỗi tháng',
                    suffixText: _monthlyUnit,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              SegmentedButton<String>(
                segments: const [
                  ButtonSegment(value: 'chỉ', label: Text('Chỉ')),
                  ButtonSegment(value: 'lượng', label: Text('Lượng')),
                ],
                selected: {_monthlyUnit},
                onSelectionChanged: (val) {
                  setState(() => _monthlyUnit = val.first);
                },
              ),
            ],
          ),

          const SizedBox(height: 30),

          SizedBox(
            height: 50,
            child: ElevatedButton.icon(
              onPressed: _saveGoal,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.goldPrimary,
                foregroundColor: Colors.black,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              ),
              icon: const Icon(Icons.check_circle_rounded),
              label: const Text(
                'LƯU CÀI ĐẶT MỤC TIÊU',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800),
              ),
            ),
          ),

          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _buildPlanStat(String label, String chiVal, String luongVal) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(color: Colors.white54, fontSize: 11)),
        const SizedBox(height: 2),
        Text(
          chiVal,
          style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w800),
        ),
        Text(
          luongVal,
          style: const TextStyle(color: AppTheme.goldLight, fontSize: 10),
        ),
      ],
    );
  }

  Widget _buildPresetChip(String label, double val) {
    return ActionChip(
      label: Text(label, style: const TextStyle(fontSize: 11)),
      backgroundColor: AppTheme.darkCardElevated,
      side: const BorderSide(color: Colors.white12),
      onPressed: () => _setPreset(val),
    );
  }
}
