import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/gold_debt.dart';
import '../models/gold_type.dart';
import '../providers/portfolio_provider.dart';
import '../utils/theme.dart';
import '../utils/formatters.dart';
import '../widgets/debt_card.dart';
import 'add_debt_screen.dart';

class DebtsScreen extends StatefulWidget {
  const DebtsScreen({super.key});

  @override
  State<DebtsScreen> createState() => _DebtsScreenState();
}

class _DebtsScreenState extends State<DebtsScreen> {
  String _filter = 'all'; // 'all', 'i_owe', 'they_owe', 'pending', 'settled'

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<PortfolioProvider>();
    final allDebts = provider.debts;
    final isHidden = provider.isAmountHidden;
    final goldTypes = {for (var t in provider.goldTypes) t.id: t};

    // Filter logic
    final filteredDebts = allDebts.where((d) {
      if (_filter == 'i_owe') return d.direction == DebtDirection.iOwe;
      if (_filter == 'they_owe') return d.direction == DebtDirection.theyOwe;
      if (_filter == 'pending') return !d.isSettled && d.remainingAmount > 0.0001;
      if (_filter == 'settled') return d.isSettled || d.remainingAmount <= 0.0001;
      return true;
    }).toList();

    final goldReceivable = provider.totalGoldReceivable;
    final goldPayable = provider.totalGoldPayable;
    final netGold = provider.netGoldQuantity;
    final moneyReceivable = provider.totalMoneyReceivable;
    final moneyPayable = provider.totalMoneyPayable;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Sổ Ghi Nợ Vàng & Tiền', style: TextStyle(fontWeight: FontWeight.w800)),
        actions: [
          IconButton(
            tooltip: 'Thêm khoản nợ',
            icon: const Icon(Icons.add_circle_rounded, color: AppTheme.goldBright, size: 26),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const AddDebtScreen()),
              );
            },
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Column(
        children: [
          // 1. Summary Cards Header
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF221F17), Color(0xFF151722)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppTheme.goldPrimary.withAlpha(80)),
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: _buildHeaderMetric(
                          'Người ta nợ tôi (Vàng)',
                          GoldFormatters.formatChi(goldReceivable, isHidden: isHidden),
                          AppTheme.profitGreen,
                          Icons.arrow_downward_rounded,
                          sub: '≈ ${GoldFormatters.formatLuong(goldReceivable, isHidden: isHidden)}',
                        ),
                      ),
                      Container(width: 1, height: 44, color: Colors.white12),
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.only(left: 14),
                          child: _buildHeaderMetric(
                            'Tôi nợ người ta (Vàng)',
                            GoldFormatters.formatChi(goldPayable, isHidden: isHidden),
                            AppTheme.lossRed,
                            Icons.arrow_outward_rounded,
                            sub: '≈ ${GoldFormatters.formatLuong(goldPayable, isHidden: isHidden)}',
                          ),
                        ),
                      ),
                    ],
                  ),
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 10),
                    child: Divider(color: Colors.white12, height: 1),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Vàng ròng sau bù trừ nợ', style: TextStyle(color: Colors.white60, fontSize: 11)),
                          const SizedBox(height: 2),
                          Text(
                            GoldFormatters.formatChi(netGold, isHidden: isHidden),
                            style: const TextStyle(color: AppTheme.goldBright, fontSize: 16, fontWeight: FontWeight.w800),
                          ),
                        ],
                      ),
                      if (moneyReceivable > 0 || moneyPayable > 0)
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            const Text('Nợ tiền mặt', style: TextStyle(color: Colors.white60, fontSize: 11)),
                            const SizedBox(height: 2),
                            Text(
                              'Thu: ${GoldFormatters.formatCurrency(moneyReceivable, isHidden: isHidden)} | Trả: ${GoldFormatters.formatCurrency(moneyPayable, isHidden: isHidden)}',
                              style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w600),
                            ),
                          ],
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          // 2. Filter chips
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _buildFilterChip('Tất cả', 'all'),
                  const SizedBox(width: 8),
                  _buildFilterChip('🔴 Tôi nợ', 'i_owe'),
                  const SizedBox(width: 8),
                  _buildFilterChip('🟢 Người nợ tôi', 'they_owe'),
                  const SizedBox(width: 8),
                  _buildFilterChip('Đang nợ', 'pending'),
                  const SizedBox(width: 8),
                  _buildFilterChip('Đã trả xong', 'settled'),
                ],
              ),
            ),
          ),

          // Count info
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('${filteredDebts.length} khoản nợ', style: const TextStyle(color: Colors.white38, fontSize: 11)),
              ],
            ),
          ),

          const SizedBox(height: 4),

          // 3. Debts list
          Expanded(
            child: filteredDebts.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.handshake_outlined, size: 56, color: Colors.white24),
                        const SizedBox(height: 12),
                        const Text(
                          'Chưa có khoản ghi nợ nào',
                          style: TextStyle(color: Colors.white60, fontSize: 15),
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton.icon(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (_) => const AddDebtScreen()),
                            );
                          },
                          icon: const Icon(Icons.add, size: 18),
                          label: const Text('Thêm khoản nợ mới'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppTheme.goldPrimary,
                            foregroundColor: Colors.black,
                          ),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.fromLTRB(16, 4, 16, 80),
                    itemCount: filteredDebts.length,
                    itemBuilder: (context, index) {
                      final debt = filteredDebts[index];
                      final marketPrice = provider.getDebtMarketPrice(debt);

                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: DebtCard(
                          debt: debt,
                          goldType: debt.goldTypeId != null ? goldTypes[debt.goldTypeId] : null,
                          currentMarketPrice: marketPrice,
                          isHidden: isHidden,
                          onTap: () => _showDebtDetailModal(context, debt, goldTypes[debt.goldTypeId]),
                          onPay: () => _showAddPaymentDialog(context, debt),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: AppTheme.goldPrimary,
        foregroundColor: Colors.black,
        icon: const Icon(Icons.add_rounded, size: 22),
        label: const Text('Thêm Ghi Nợ', style: TextStyle(fontWeight: FontWeight.w800)),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const AddDebtScreen()),
          );
        },
      ),
    );
  }

  Widget _buildHeaderMetric(String label, String value, Color color, IconData icon, {String? sub}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 14, color: color),
            const SizedBox(width: 4),
            Expanded(
              child: Text(
                label,
                style: const TextStyle(color: Colors.white60, fontSize: 11),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(color: color, fontSize: 16, fontWeight: FontWeight.w800),
        ),
        if (sub != null)
          Text(sub, style: const TextStyle(color: Colors.white38, fontSize: 10)),
      ],
    );
  }

  Widget _buildFilterChip(String label, String key) {
    final isSel = _filter == key;
    return ChoiceChip(
      label: Text(label),
      selected: isSel,
      selectedColor: AppTheme.goldPrimary.withAlpha(60),
      backgroundColor: AppTheme.darkCard,
      labelStyle: TextStyle(
        color: isSel ? Colors.white : Colors.white60,
        fontWeight: isSel ? FontWeight.w700 : FontWeight.w500,
        fontSize: 12,
      ),
      onSelected: (val) {
        if (val) setState(() => _filter = key);
      },
    );
  }

  // --- Detail Bottom Sheet ---
  void _showDebtDetailModal(BuildContext context, GoldDebt debt, GoldType? goldType) {
    final provider = context.read<PortfolioProvider>();
    final isGold = debt.assetType == DebtAssetType.gold;
    final isIOwe = debt.direction == DebtDirection.iOwe;
    final marketVal = provider.getDebtCurrentValue(debt);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppTheme.darkCardElevated,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return Padding(
          padding: const EdgeInsets.all(22),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    debt.personName,
                    style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: (isIOwe ? AppTheme.lossRed : AppTheme.profitGreen).withAlpha(40),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      isIOwe ? 'Tôi nợ' : 'Người nợ tôi',
                      style: TextStyle(
                        color: isIOwe ? AppTheme.lossRed : AppTheme.profitGreen,
                        fontWeight: FontWeight.w700,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
              if (debt.phoneNumber != null) ...[
                const SizedBox(height: 4),
                Text('SĐT: ${debt.phoneNumber}', style: const TextStyle(color: Colors.white54, fontSize: 12)),
              ],
              const SizedBox(height: 16),

              _buildDetailRow(
                'Tài sản nợ',
                isGold ? (goldType?.name ?? 'Vàng') : 'Tiền mặt',
              ),
              _buildDetailRow(
                'Số lượng gốc ban đầu',
                isGold
                    ? '${GoldFormatters.formatChi(debt.originalAmount)} (${GoldFormatters.formatLuong(debt.originalAmount)})'
                    : GoldFormatters.formatCurrency(debt.originalAmount),
              ),
              _buildDetailRow(
                'Đã trả',
                isGold
                    ? GoldFormatters.formatChi(debt.totalPaid)
                    : GoldFormatters.formatCurrency(debt.totalPaid),
                textColor: AppTheme.profitGreen,
              ),
              _buildDetailRow(
                'Còn nợ lại',
                isGold
                    ? '${GoldFormatters.formatChi(debt.remainingAmount)} (${GoldFormatters.formatLuong(debt.remainingAmount)})'
                    : GoldFormatters.formatCurrency(debt.remainingAmount),
                isBold: true,
                textColor: isIOwe ? AppTheme.lossRed : AppTheme.profitGreen,
              ),

              if (isGold && marketVal > 0)
                _buildDetailRow(
                  'Quy đổi theo giá TT hôm nay',
                  GoldFormatters.formatCurrency(marketVal),
                  textColor: AppTheme.goldBright,
                  isBold: true,
                ),

              if (debt.priceAtBorrow != null && debt.priceAtBorrow! > 0)
                _buildDetailRow(
                  'Giá lúc vay',
                  '${GoldFormatters.formatCurrency(debt.priceAtBorrow!)}/chỉ',
                ),

              _buildDetailRow('Ngày vay', GoldFormatters.formatDate(debt.startDate)),
              if (debt.dueDate != null)
                _buildDetailRow(
                  'Hạn hẹn trả',
                  GoldFormatters.formatDate(debt.dueDate!),
                  textColor: debt.isOverdue ? AppTheme.lossRed : null,
                ),

              if (debt.note != null && debt.note!.isNotEmpty)
                _buildDetailRow('Ghi chú', debt.note!),

              const SizedBox(height: 16),

              // Payments history list
              if (debt.payments.isNotEmpty) ...[
                const Text(
                  'Lịch sử các lần trả:',
                  style: TextStyle(color: AppTheme.goldLight, fontSize: 12, fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 8),
                Container(
                  constraints: const BoxConstraints(maxHeight: 120),
                  child: ListView.builder(
                    shrinkWrap: true,
                    itemCount: debt.payments.length,
                    itemBuilder: (_, i) {
                      final p = debt.payments[i];
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 3),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              GoldFormatters.formatDate(p.date),
                              style: const TextStyle(color: Colors.white54, fontSize: 11),
                            ),
                            Text(
                              isGold ? GoldFormatters.formatChi(p.amount) : GoldFormatters.formatCurrency(p.amount),
                              style: const TextStyle(color: AppTheme.profitGreen, fontSize: 12, fontWeight: FontWeight.w600),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 16),
              ],

              // Actions buttons: Trả bớt / Sửa / Xóa
              Row(
                children: [
                  OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppTheme.lossRed,
                      side: const BorderSide(color: AppTheme.lossRed),
                    ),
                    icon: const Icon(Icons.delete_outline, size: 18),
                    label: const Text('XÓA'),
                    onPressed: () async {
                      final confirm = await showDialog<bool>(
                        context: context,
                        builder: (dCtx) => AlertDialog(
                          title: const Text('Xác nhận xóa khoản nợ?'),
                          content: const Text('Dữ liệu khoản nợ này sẽ bị xóa vĩnh viễn.'),
                          actions: [
                            TextButton(onPressed: () => Navigator.pop(dCtx, false), child: const Text('HỦY')),
                            ElevatedButton(
                              style: ElevatedButton.styleFrom(backgroundColor: AppTheme.lossRed),
                              onPressed: () => Navigator.pop(dCtx, true),
                              child: const Text('XÓA'),
                            ),
                          ],
                        ),
                      );
                      if (confirm == true) {
                        provider.deleteDebt(debt.id);
                        if (ctx.mounted) Navigator.pop(ctx);
                      }
                    },
                  ),
                  const SizedBox(width: 8),
                  OutlinedButton.icon(
                    icon: const Icon(Icons.edit, size: 18),
                    label: const Text('SỬA'),
                    onPressed: () {
                      Navigator.pop(ctx);
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => AddDebtScreen(editDebt: debt)),
                      );
                    },
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.goldPrimary,
                        foregroundColor: Colors.black,
                      ),
                      icon: const Icon(Icons.payment, size: 18),
                      label: const Text('TRẢ NỢ', style: TextStyle(fontWeight: FontWeight.bold)),
                      onPressed: () {
                        Navigator.pop(ctx);
                        _showAddPaymentDialog(context, debt);
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
            ],
          ),
        );
      },
    );
  }

  // --- Add payment dialog ---
  void _showAddPaymentDialog(BuildContext context, GoldDebt debt) {
    final amountCtrl = TextEditingController();
    final noteCtrl = TextEditingController();
    DateTime payDate = DateTime.now();
    final isGold = debt.assetType == DebtAssetType.gold;

    showDialog(
      context: context,
      builder: (dCtx) => StatefulBuilder(
        builder: (context, setModalState) {
          return AlertDialog(
            title: Text('Ghi nhận trả nợ: ${debt.personName}'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Còn nợ: ${isGold ? GoldFormatters.formatChi(debt.remainingAmount) : GoldFormatters.formatCurrency(debt.remainingAmount)}',
                  style: const TextStyle(color: AppTheme.goldBright, fontSize: 13, fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 14),
                TextField(
                  controller: amountCtrl,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  decoration: InputDecoration(
                    labelText: isGold ? 'Số lượng vàng trả (chỉ)' : 'Số tiền trả (VNĐ)',
                    hintText: isGold ? 'Ví dụ: 1.0' : 'Ví dụ: 5.000.000',
                  ),
                ),
                const SizedBox(height: 12),
                InkWell(
                  onTap: () async {
                    final picked = await showDatePicker(
                      context: context,
                      initialDate: payDate,
                      firstDate: DateTime(2000),
                      lastDate: DateTime.now().add(const Duration(days: 365)),
                    );
                    if (picked != null) {
                      setModalState(() => payDate = picked);
                    }
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                    decoration: BoxDecoration(
                      color: AppTheme.darkCard,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: Colors.white12),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Ngày trả: ${GoldFormatters.formatDate(payDate)}', style: const TextStyle(fontSize: 12)),
                        const Icon(Icons.calendar_today, size: 14, color: AppTheme.goldPrimary),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: noteCtrl,
                  decoration: const InputDecoration(labelText: 'Ghi chú (tùy chọn)'),
                ),
              ],
            ),
            actions: [
              TextButton(onPressed: () => Navigator.pop(dCtx), child: const Text('HỦY')),
              ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: AppTheme.goldPrimary),
                child: const Text('XÁC NHẬN TRẢ', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
                onPressed: () {
                  final raw = double.tryParse(amountCtrl.text.replaceAll(',', '.').replaceAll('.', '')) ?? 0.0;
                  if (raw > 0) {
                    final payment = DebtPayment(
                      id: 'pay_${DateTime.now().millisecondsSinceEpoch}',
                      amount: raw,
                      date: payDate,
                      note: noteCtrl.text.trim().isEmpty ? null : noteCtrl.text.trim(),
                    );
                    context.read<PortfolioProvider>().addDebtPayment(debt.id, payment);
                    Navigator.pop(dCtx);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Đã ghi nhận trả nợ thành công!'),
                        backgroundColor: AppTheme.profitGreen,
                      ),
                    );
                  }
                },
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildDetailRow(String label, String value, {bool isBold = false, Color? textColor}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: Colors.white54, fontSize: 13)),
          Text(
            value,
            style: TextStyle(
              color: textColor ?? (isBold ? Colors.white : Colors.white70),
              fontSize: 13,
              fontWeight: isBold ? FontWeight.w800 : FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
