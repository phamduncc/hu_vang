import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/gold_transaction.dart';
import '../models/gold_type.dart';
import '../providers/portfolio_provider.dart';
import '../utils/theme.dart';
import '../utils/formatters.dart';
import '../widgets/transaction_tile.dart';
import 'add_transaction_screen.dart';

class TransactionsTab extends StatefulWidget {
  const TransactionsTab({super.key});

  @override
  State<TransactionsTab> createState() => _TransactionsTabState();
}

class _TransactionsTabState extends State<TransactionsTab> {
  String _searchQuery = '';
  TransactionType? _selectedTypeFilter;
  String? _selectedGoldTypeFilter;

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<PortfolioProvider>();
    final allTxs = provider.transactions;
    final goldTypes = provider.goldTypes;
    final isHidden = provider.isAmountHidden;
    final typeMap = {for (var t in goldTypes) t.id: t};

    // Filter transactions
    final filteredTxs = allTxs.where((tx) {
      if (_selectedTypeFilter != null && tx.type != _selectedTypeFilter) {
        return false;
      }
      if (_selectedGoldTypeFilter != null && tx.goldTypeId != _selectedGoldTypeFilter) {
        return false;
      }
      if (_searchQuery.isNotEmpty) {
        final q = _searchQuery.toLowerCase();
        final typeName = (typeMap[tx.goldTypeId]?.name ?? '').toLowerCase();
        final shop = (tx.shop ?? '').toLowerCase();
        final note = (tx.note ?? '').toLowerCase();
        if (!typeName.contains(q) && !shop.contains(q) && !note.contains(q)) {
          return false;
        }
      }
      return true;
    }).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Sổ Giao Dịch Vàng', style: TextStyle(fontWeight: FontWeight.w800)),
        actions: [
          IconButton(
            tooltip: 'Thêm giao dịch',
            icon: const Icon(Icons.add_circle_rounded, color: AppTheme.goldBright, size: 26),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const AddTransactionScreen()),
              );
            },
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Column(
        children: [
          // Search & Filter header
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Tìm kiếm cửa hàng, ghi chú...',
                prefixIcon: const Icon(Icons.search_rounded, color: AppTheme.goldPrimary),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear, size: 18),
                        onPressed: () => setState(() => _searchQuery = ''),
                      )
                    : null,
                contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              ),
              onChanged: (val) => setState(() => _searchQuery = val.trim()),
            ),
          ),

          // Filters Row
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  // Filter Tất cả
                  ChoiceChip(
                    label: const Text('Tất cả'),
                    selected: _selectedTypeFilter == null && _selectedGoldTypeFilter == null,
                    selectedColor: AppTheme.goldPrimary.withAlpha(64),
                    backgroundColor: AppTheme.darkCard,
                    labelStyle: TextStyle(
                      color: _selectedTypeFilter == null && _selectedGoldTypeFilter == null
                          ? Colors.white
                          : Colors.white60,
                      fontWeight: FontWeight.w600,
                    ),
                    onSelected: (val) {
                      if (val) {
                        setState(() {
                          _selectedTypeFilter = null;
                          _selectedGoldTypeFilter = null;
                        });
                      }
                    },
                  ),
                  const SizedBox(width: 8),

                  // Filter Mua
                  ChoiceChip(
                    label: const Text('Mua vào'),
                    selected: _selectedTypeFilter == TransactionType.buy,
                    selectedColor: AppTheme.profitGreen.withAlpha(64),
                    backgroundColor: AppTheme.darkCard,
                    labelStyle: TextStyle(
                      color: _selectedTypeFilter == TransactionType.buy ? Colors.white : Colors.white60,
                      fontWeight: FontWeight.w600,
                    ),
                    onSelected: (val) {
                      setState(() => _selectedTypeFilter = val ? TransactionType.buy : null);
                    },
                  ),
                  const SizedBox(width: 8),

                  // Filter Bán
                  ChoiceChip(
                    label: const Text('Bán ra'),
                    selected: _selectedTypeFilter == TransactionType.sell,
                    selectedColor: AppTheme.lossRed.withAlpha(64),
                    backgroundColor: AppTheme.darkCard,
                    labelStyle: TextStyle(
                      color: _selectedTypeFilter == TransactionType.sell ? Colors.white : Colors.white60,
                      fontWeight: FontWeight.w600,
                    ),
                    onSelected: (val) {
                      setState(() => _selectedTypeFilter = val ? TransactionType.sell : null);
                    },
                  ),
                  const SizedBox(width: 8),

                  // Filter theo loại vàng
                  PopupMenuButton<String>(
                    child: Chip(
                      label: Text(
                        _selectedGoldTypeFilter == null
                            ? 'Loại vàng ▾'
                            : (typeMap[_selectedGoldTypeFilter]?.name ?? 'Loại vàng'),
                      ),
                      backgroundColor: _selectedGoldTypeFilter != null
                          ? AppTheme.goldPrimary.withAlpha(64)
                          : AppTheme.darkCard,
                      side: BorderSide(
                        color: _selectedGoldTypeFilter != null
                            ? AppTheme.goldPrimary
                            : Colors.white12,
                      ),
                    ),
                    itemBuilder: (context) {
                      return [
                        const PopupMenuItem(
                          value: null,
                          child: Text('Tất cả loại vàng'),
                        ),
                        ...goldTypes.map((t) => PopupMenuItem(
                              value: t.id,
                              child: Text(t.name),
                            )),
                      ];
                    },
                    onSelected: (val) {
                      setState(() => _selectedGoldTypeFilter = val);
                    },
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 8),

          // Total Count Bar
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 4),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${filteredTxs.length} giao dịch',
                  style: const TextStyle(color: Colors.white54, fontSize: 12),
                ),
                Text(
                  'Tổng lượng: ${GoldFormatters.formatChi(filteredTxs.fold(0.0, (sum, t) => sum + (t.type == TransactionType.buy ? t.quantity : -t.quantity)), isHidden: isHidden)}',
                  style: const TextStyle(color: AppTheme.goldLight, fontSize: 12, fontWeight: FontWeight.w600),
                ),
              ],
            ),
          ),

          const Divider(color: Colors.white12, height: 16),

          // Transactions List
          Expanded(
            child: filteredTxs.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.receipt_long_rounded, size: 56, color: Colors.white24),
                        const SizedBox(height: 12),
                        const Text(
                          'Không tìm thấy giao dịch nào',
                          style: TextStyle(color: Colors.white60, fontSize: 15),
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton.icon(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (_) => const AddTransactionScreen()),
                            );
                          },
                          icon: const Icon(Icons.add, size: 18),
                          label: const Text('Thêm giao dịch ngay'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppTheme.goldPrimary,
                            foregroundColor: Colors.black,
                          ),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
                    itemCount: filteredTxs.length,
                    itemBuilder: (context, index) {
                      final tx = filteredTxs[index];
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: TransactionTile(
                          transaction: tx,
                          goldType: typeMap[tx.goldTypeId],
                          isHidden: isHidden,
                          onTap: () => _showDetailSheet(context, tx, typeMap[tx.goldTypeId]),
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
        label: const Text('Thêm GD', style: TextStyle(fontWeight: FontWeight.w800)),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const AddTransactionScreen()),
          );
        },
      ),
    );
  }

  void _showDetailSheet(BuildContext context, GoldTransaction tx, GoldType? goldType) {
    final provider = context.read<PortfolioProvider>();

    showModalBottomSheet(
      context: context,
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
                    'Chi tiết giao dịch',
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: (tx.type == TransactionType.buy
                              ? AppTheme.profitGreen
                              : (tx.type == TransactionType.sell
                                  ? AppTheme.lossRed
                                  : AppTheme.goldPrimary))
                          .withAlpha(51),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      tx.type.label,
                      style: TextStyle(
                        color: tx.type == TransactionType.buy
                            ? AppTheme.profitGreen
                            : (tx.type == TransactionType.sell
                                ? AppTheme.lossRed
                                : AppTheme.goldPrimary),
                        fontWeight: FontWeight.w700,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              _buildDetailRow('Loại vàng', goldType?.name ?? tx.goldTypeId),
              _buildDetailRow('Số lượng', '${GoldFormatters.formatChi(tx.quantity)} ≈ ${GoldFormatters.formatLuong(tx.quantity)}'),
              _buildDetailRow('Đơn giá', '${GoldFormatters.formatCurrency(tx.pricePerUnit)}/chỉ'),
              if (tx.fee > 0) _buildDetailRow('Tiền công/Phí', GoldFormatters.formatCurrency(tx.fee)),
              _buildDetailRow('Tổng tiền', GoldFormatters.formatCurrency(tx.totalAmount), isBold: true),
              _buildDetailRow('Ngày GD', GoldFormatters.formatDateTime(tx.transactionDate)),
              if (tx.shop != null && tx.shop!.isNotEmpty) _buildDetailRow('Cửa hàng', tx.shop!),
              if (tx.note != null && tx.note!.isNotEmpty) _buildDetailRow('Ghi chú', tx.note!),
              if (tx.realizedProfit != null)
                _buildDetailRow(
                  'Lãi chốt lời',
                  GoldFormatters.formatProfit(tx.realizedProfit!),
                  textColor: tx.realizedProfit! >= 0 ? AppTheme.profitGreen : AppTheme.lossRed,
                ),

              const SizedBox(height: 24),

              // Action buttons (Sửa / Xóa)
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppTheme.lossRed,
                        side: const BorderSide(color: AppTheme.lossRed),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      icon: const Icon(Icons.delete_outline_rounded, size: 20),
                      label: const Text('XÓA'),
                      onPressed: () async {
                        final confirm = await showDialog<bool>(
                          context: context,
                          builder: (dCtx) => AlertDialog(
                            title: const Text('Xác nhận xóa giao dịch?'),
                            content: const Text('Hành động này sẽ cập nhật lại giá vốn và lượng vàng của bạn.'),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(dCtx, false),
                                child: const Text('HỦY'),
                              ),
                              ElevatedButton(
                                style: ElevatedButton.styleFrom(backgroundColor: AppTheme.lossRed),
                                onPressed: () => Navigator.pop(dCtx, true),
                                child: const Text('XÓA'),
                              ),
                            ],
                          ),
                        );
                        if (confirm == true) {
                          provider.deleteTransaction(tx.id);
                          if (ctx.mounted) Navigator.pop(ctx);
                        }
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.goldPrimary,
                        foregroundColor: Colors.black,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      icon: const Icon(Icons.edit_rounded, size: 20),
                      label: const Text('CHỈNH SỬA', style: TextStyle(fontWeight: FontWeight.w700)),
                      onPressed: () {
                        Navigator.pop(ctx);
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => AddTransactionScreen(editTransaction: tx),
                          ),
                        );
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
              color: textColor ?? (isBold ? AppTheme.goldBright : Colors.white),
              fontSize: 13,
              fontWeight: isBold ? FontWeight.w800 : FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
