import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/gold_transaction.dart';
import '../providers/portfolio_provider.dart';
import '../utils/theme.dart';
import '../utils/formatters.dart';

class AddTransactionScreen extends StatefulWidget {
  final GoldTransaction? editTransaction;

  const AddTransactionScreen({super.key, this.editTransaction});

  @override
  State<AddTransactionScreen> createState() => _AddTransactionScreenState();
}

class _AddTransactionScreenState extends State<AddTransactionScreen> {
  final _formKey = GlobalKey<FormState>();

  late TransactionType _type;
  late String _goldTypeId;
  late DateTime _date;
  String _unit = 'chỉ'; // 'chỉ', 'lượng', 'phân'

  final _quantityController = TextEditingController();
  final _priceController = TextEditingController();
  final _feeController = TextEditingController(text: '0');
  final _totalController = TextEditingController();
  final _shopController = TextEditingController();
  final _noteController = TextEditingController();

  bool _isAutoCalculating = true;

  @override
  void initState() {
    super.initState();
    final edit = widget.editTransaction;
    if (edit != null) {
      _type = edit.type;
      _goldTypeId = edit.goldTypeId;
      _date = edit.transactionDate;
      _unit = edit.inputUnit;
      _quantityController.text = _unit == 'lượng'
          ? (edit.quantity / 10).toString()
          : edit.quantity.toString();
      _priceController.text = edit.pricePerUnit.round().toString();
      _feeController.text = edit.fee.round().toString();
      _totalController.text = edit.totalAmount.round().toString();
      _shopController.text = edit.shop ?? '';
      _noteController.text = edit.note ?? '';
    } else {
      _type = TransactionType.buy;
      _goldTypeId = 'nhan_9999';
      _date = DateTime.now();
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Gợi ý giá thị trường nếu tạo mới và chưa nhập giá
    if (widget.editTransaction == null && _priceController.text.isEmpty) {
      _applySuggestedPrice();
    }
  }

  void _applySuggestedPrice() {
    final provider = context.read<PortfolioProvider>();
    final currentPrice = provider.prices[_goldTypeId];
    if (currentPrice != null) {
      final price = _type == TransactionType.sell
          ? currentPrice.buyPrice // tiệm mua lại
          : currentPrice.sellPrice; // tiệm bán ra
      if (price > 0) {
        _priceController.text = price.round().toString();
        _recalculateTotal();
      }
    }
  }

  void _recalculateTotal() {
    if (!_isAutoCalculating) return;
    final qty = double.tryParse(_quantityController.text.replaceAll(',', '.')) ?? 0.0;
    final pricePerChi = double.tryParse(_priceController.text.replaceAll('.', '')) ?? 0.0;
    final fee = double.tryParse(_feeController.text.replaceAll('.', '')) ?? 0.0;

    // Quy đổi số lượng sang "chỉ"
    double qtyInChi = qty;
    if (_unit == 'lượng') {
      qtyInChi = qty * 10.0;
    } else if (_unit == 'phân') {
      qtyInChi = qty * 0.1;
    }

    final total = (qtyInChi * pricePerChi) + fee;
    if (total > 0) {
      _totalController.text = total.round().toString();
    }
  }

  void _save() {
    if (!_formKey.currentState!.validate()) return;

    final qty = double.tryParse(_quantityController.text.replaceAll(',', '.')) ?? 0.0;
    final pricePerChi = double.tryParse(_priceController.text.replaceAll('.', '')) ?? 0.0;
    final fee = double.tryParse(_feeController.text.replaceAll('.', '')) ?? 0.0;
    final total = double.tryParse(_totalController.text.replaceAll('.', '')) ?? 0.0;

    double qtyInChi = qty;
    if (_unit == 'lượng') {
      qtyInChi = qty * 10.0;
    } else if (_unit == 'phân') {
      qtyInChi = qty * 0.1;
    }

    final provider = context.read<PortfolioProvider>();

    // Kiểm tra số lượng khi bán
    if (_type == TransactionType.sell) {
      final curItem = provider.portfolioSummary.items[_goldTypeId];
      final currentOwned = curItem?.quantity ?? 0.0;
      final editingQty = widget.editTransaction?.quantity ?? 0.0;
      if (qtyInChi > (currentOwned + editingQty + 0.0001)) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Số lượng bán (${GoldFormatters.formatChi(qtyInChi)}) lớn hơn số vàng hiện có (${GoldFormatters.formatChi(currentOwned)})!',
            ),
            backgroundColor: AppTheme.lossRed,
          ),
        );
        return;
      }
    }

    final tx = GoldTransaction(
      id: widget.editTransaction?.id ?? 'tx_${DateTime.now().millisecondsSinceEpoch}',
      goldTypeId: _goldTypeId,
      type: _type,
      quantity: qtyInChi,
      inputUnit: _unit,
      pricePerUnit: pricePerChi,
      fee: fee,
      totalAmount: total > 0 ? total : (qtyInChi * pricePerChi + fee),
      transactionDate: _date,
      shop: _shopController.text.trim().isEmpty ? null : _shopController.text.trim(),
      note: _noteController.text.trim().isEmpty ? null : _noteController.text.trim(),
    );

    if (widget.editTransaction != null) {
      provider.updateTransaction(tx);
    } else {
      provider.addTransaction(tx);
    }

    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          widget.editTransaction != null
              ? 'Đã cập nhật giao dịch thành công!'
              : 'Đã lưu giao dịch vào Hũ Vàng!',
        ),
        backgroundColor: AppTheme.profitGreen,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<PortfolioProvider>();
    final goldTypes = provider.goldTypes;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.editTransaction != null ? 'Sửa giao dịch' : 'Thêm giao dịch vàng',
          style: const TextStyle(fontWeight: FontWeight.w700),
        ),
        actions: [
          TextButton(
            onPressed: _save,
            child: const Text(
              'LƯU',
              style: TextStyle(
                color: AppTheme.goldBright,
                fontWeight: FontWeight.w800,
                fontSize: 16,
              ),
            ),
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            // Transaction Type Selector (Mua, Bán, Điều chỉnh, Tặng)
            const Text(
              'LOẠI GIAO DỊCH',
              style: TextStyle(color: AppTheme.goldLight, fontSize: 12, fontWeight: FontWeight.w700, letterSpacing: 1.1),
            ),
            const SizedBox(height: 10),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: TransactionType.values.map((t) {
                  final isSelected = _type == t;
                  Color color;
                  if (t == TransactionType.buy) {
                    color = AppTheme.profitGreen;
                  } else if (t == TransactionType.sell) {
                    color = AppTheme.lossRed;
                  } else {
                    color = AppTheme.goldPrimary;
                  }

                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: ChoiceChip(
                      label: Text(t.label),
                      selected: isSelected,
                      selectedColor: color.withAlpha(64),
                      backgroundColor: AppTheme.darkCard,
                      labelStyle: TextStyle(
                        color: isSelected ? Colors.white : Colors.white60,
                        fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                      ),
                      side: BorderSide(
                        color: isSelected ? color : Colors.white12,
                        width: isSelected ? 1.5 : 1.0,
                      ),
                      onSelected: (val) {
                        if (val) {
                          setState(() {
                            _type = t;
                            _applySuggestedPrice();
                          });
                        }
                      },
                    ),
                  );
                }).toList(),
              ),
            ),

            const SizedBox(height: 20),

            // Gold Type Selector
            const Text(
              'LOẠI VÀNG',
              style: TextStyle(color: AppTheme.goldLight, fontSize: 12, fontWeight: FontWeight.w700, letterSpacing: 1.1),
            ),
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: AppTheme.darkCard,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: Colors.white12),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: _goldTypeId,
                  isExpanded: true,
                  dropdownColor: AppTheme.darkCardElevated,
                  items: goldTypes.map((type) {
                    return DropdownMenuItem<String>(
                      value: type.id,
                      child: Row(
                        children: [
                          Container(
                            width: 14,
                            height: 14,
                            decoration: BoxDecoration(
                              color: Color(type.colorValue),
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Text(type.name, style: const TextStyle(fontWeight: FontWeight.w600)),
                          const Spacer(),
                          Text(
                            '${type.purity}%',
                            style: const TextStyle(color: Colors.white38, fontSize: 12),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                  onChanged: (val) {
                    if (val != null) {
                      setState(() {
                        _goldTypeId = val;
                        _applySuggestedPrice();
                      });
                    }
                  },
                ),
              ),
            ),

            const SizedBox(height: 20),

            // Quantity & Unit Toggle
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'SỐ LƯỢNG VÀNG',
                  style: TextStyle(color: AppTheme.goldLight, fontSize: 12, fontWeight: FontWeight.w700, letterSpacing: 1.1),
                ),
                // Toggle đơn vị: Chỉ / Lượng / Phân
                Row(
                  children: ['chỉ', 'lượng', 'phân'].map((u) {
                    final isSel = _unit == u;
                    return InkWell(
                      onTap: () {
                        setState(() {
                          _unit = u;
                          _recalculateTotal();
                        });
                      },
                      child: Container(
                        margin: const EdgeInsets.only(left: 6),
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: isSel ? AppTheme.goldPrimary : Colors.white10,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          u,
                          style: TextStyle(
                            color: isSel ? Colors.black : Colors.white70,
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ],
            ),
            const SizedBox(height: 10),
            TextFormField(
              controller: _quantityController,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              decoration: InputDecoration(
                hintText: 'Nhập số lượng (ví dụ: 2.5)',
                suffixText: _unit,
                suffixStyle: const TextStyle(color: AppTheme.goldBright, fontWeight: FontWeight.w700),
              ),
              onChanged: (_) => _recalculateTotal(),
              validator: (v) {
                if (v == null || v.trim().isEmpty) return 'Vui lòng nhập số lượng';
                final n = double.tryParse(v.replaceAll(',', '.'));
                if (n == null || n <= 0) return 'Số lượng phải lớn hơn 0';
                return null;
              },
            ),

            const SizedBox(height: 20),

            // Price per Chi (Đơn giá/chỉ)
            const Text(
              'ĐƠN GIÁ / CHỈ (VNĐ)',
              style: TextStyle(color: AppTheme.goldLight, fontSize: 12, fontWeight: FontWeight.w700, letterSpacing: 1.1),
            ),
            const SizedBox(height: 10),
            TextFormField(
              controller: _priceController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                hintText: 'Nhập đơn giá mỗi chỉ',
                suffixText: 'đ / chỉ',
                suffixStyle: TextStyle(color: Colors.white70),
              ),
              onChanged: (_) => _recalculateTotal(),
              validator: (v) {
                if (v == null || v.trim().isEmpty) return 'Vui lòng nhập đơn giá';
                final n = double.tryParse(v.replaceAll('.', ''));
                if (n == null || n < 0) return 'Đơn giá không hợp lệ';
                return null;
              },
            ),

            const SizedBox(height: 20),

            // Fee & Total Amount
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'TIỀN CÔNG / PHÍ (VNĐ)',
                        style: TextStyle(color: Colors.white60, fontSize: 11, fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: _feeController,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(hintText: '0 đ'),
                        onChanged: (_) => _recalculateTotal(),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'TỔNG TIỀN (VNĐ)',
                        style: TextStyle(color: AppTheme.goldBright, fontSize: 11, fontWeight: FontWeight.w700),
                      ),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: _totalController,
                        keyboardType: TextInputType.number,
                        style: const TextStyle(color: AppTheme.goldBright, fontWeight: FontWeight.w800),
                        decoration: const InputDecoration(
                          hintText: 'Tự động tính',
                          suffixText: 'đ',
                        ),
                        onChanged: (_) {
                          _isAutoCalculating = false;
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 20),

            // Date Picker
            const Text(
              'NGÀY GIAO DỊCH',
              style: TextStyle(color: AppTheme.goldLight, fontSize: 12, fontWeight: FontWeight.w700, letterSpacing: 1.1),
            ),
            const SizedBox(height: 10),
            InkWell(
              onTap: () async {
                final picked = await showDatePicker(
                  context: context,
                  initialDate: _date,
                  firstDate: DateTime(2000),
                  lastDate: DateTime.now().add(const Duration(days: 365)),
                );
                if (picked != null) {
                  setState(() => _date = picked);
                }
              },
              borderRadius: BorderRadius.circular(14),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                decoration: BoxDecoration(
                  color: AppTheme.darkCard,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: Colors.white12),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      GoldFormatters.formatDate(_date),
                      style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
                    ),
                    const Icon(Icons.calendar_today_rounded, size: 18, color: AppTheme.goldPrimary),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 20),

            // Shop / Place
            const Text(
              'CỬA HÀNG / ĐỊA ĐIỂM (TÙY CHỌN)',
              style: TextStyle(color: Colors.white60, fontSize: 11, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 10),
            TextFormField(
              controller: _shopController,
              decoration: const InputDecoration(
                hintText: 'Ví dụ: PNJ, DOJI, SJC, Bảo Tín Minh Châu...',
              ),
            ),

            // Quick suggestion chips for shops
            const SizedBox(height: 8),
            Wrap(
              spacing: 6,
              children: ['PNJ', 'DOJI', 'SJC', 'Bảo Tín Minh Châu', 'Mi Hồng'].map((s) {
                return ActionChip(
                  label: Text(s, style: const TextStyle(fontSize: 11)),
                  backgroundColor: AppTheme.darkCard,
                  side: const BorderSide(color: Colors.white12),
                  onPressed: () {
                    setState(() {
                      _shopController.text = s;
                    });
                  },
                );
              }).toList(),
            ),

            const SizedBox(height: 20),

            // Note
            const Text(
              'GHI CHÚ (TÙY CHỌN)',
              style: TextStyle(color: Colors.white60, fontSize: 11, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 10),
            TextFormField(
              controller: _noteController,
              maxLines: 2,
              decoration: const InputDecoration(
                hintText: 'Ví dụ: Tiền thưởng Tết, mua tích lũy dài hạn...',
              ),
            ),

            const SizedBox(height: 30),

            // Save Button
            SizedBox(
              height: 52,
              child: ElevatedButton.icon(
                onPressed: _save,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.goldPrimary,
                  foregroundColor: Colors.black,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
                icon: const Icon(Icons.check_circle_rounded, size: 22),
                label: Text(
                  widget.editTransaction != null ? 'LƯU THAY ĐỔI' : 'LƯU VÀO HŨ VÀNG',
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
                ),
              ),
            ),

            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }
}
