import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/gold_debt.dart';
import '../providers/portfolio_provider.dart';
import '../utils/theme.dart';
import '../utils/formatters.dart';

class AddDebtScreen extends StatefulWidget {
  final GoldDebt? editDebt;

  const AddDebtScreen({super.key, this.editDebt});

  @override
  State<AddDebtScreen> createState() => _AddDebtScreenState();
}

class _AddDebtScreenState extends State<AddDebtScreen> {
  final _formKey = GlobalKey<FormState>();

  late DebtDirection _direction;
  late DebtAssetType _assetType;
  late String _goldTypeId;
  late DateTime _startDate;
  DateTime? _dueDate;
  String _unit = 'chỉ';

  final _personController = TextEditingController();
  final _phoneController = TextEditingController();
  final _amountController = TextEditingController();
  final _priceController = TextEditingController();
  final _noteController = TextEditingController();

  @override
  void initState() {
    super.initState();
    final edit = widget.editDebt;
    if (edit != null) {
      _direction = edit.direction;
      _assetType = edit.assetType;
      _goldTypeId = edit.goldTypeId ?? 'nhan_9999';
      _startDate = edit.startDate;
      _dueDate = edit.dueDate;
      _personController.text = edit.personName;
      _phoneController.text = edit.phoneNumber ?? '';
      _amountController.text = edit.originalAmount.toString();
      _priceController.text = edit.priceAtBorrow?.round().toString() ?? '';
      _noteController.text = edit.note ?? '';
    } else {
      _direction = DebtDirection.iOwe;
      _assetType = DebtAssetType.gold;
      _goldTypeId = 'nhan_9999';
      _startDate = DateTime.now();
    }
  }

  void _save() {
    if (!_formKey.currentState!.validate()) return;

    final rawAmount = double.tryParse(_amountController.text.replaceAll(',', '.')) ?? 0.0;
    double finalAmount = rawAmount;
    if (_assetType == DebtAssetType.gold && _unit == 'lượng') {
      finalAmount = rawAmount * 10.0; // quy về chỉ
    }

    final priceAtBorrow = double.tryParse(_priceController.text.replaceAll('.', ''));

    final debt = GoldDebt(
      id: widget.editDebt?.id ?? 'debt_${DateTime.now().millisecondsSinceEpoch}',
      personName: _personController.text.trim(),
      phoneNumber: _phoneController.text.trim().isEmpty ? null : _phoneController.text.trim(),
      direction: _direction,
      assetType: _assetType,
      goldTypeId: _assetType == DebtAssetType.gold ? _goldTypeId : null,
      originalAmount: finalAmount,
      priceAtBorrow: priceAtBorrow,
      startDate: _startDate,
      dueDate: _dueDate,
      note: _noteController.text.trim().isEmpty ? null : _noteController.text.trim(),
      payments: widget.editDebt?.payments ?? [],
      isSettled: widget.editDebt?.isSettled ?? false,
    );

    final provider = context.read<PortfolioProvider>();
    if (widget.editDebt != null) {
      provider.updateDebt(debt);
    } else {
      provider.addDebt(debt);
    }

    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          widget.editDebt != null ? 'Đã cập nhật khoản nợ!' : 'Đã ghi sổ khoản nợ thành công!',
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
          widget.editDebt != null ? 'Sửa khoản ghi nợ' : 'Thêm khoản ghi nợ',
          style: const TextStyle(fontWeight: FontWeight.w700),
        ),
        actions: [
          TextButton(
            onPressed: _save,
            child: const Text(
              'LƯU',
              style: TextStyle(color: AppTheme.goldBright, fontWeight: FontWeight.w800, fontSize: 16),
            ),
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            // 1. Hướng nợ
            const Text(
              'HƯỚNG KHOẢN NỢ',
              style: TextStyle(color: AppTheme.goldLight, fontSize: 12, fontWeight: FontWeight.w700, letterSpacing: 1.1),
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: ChoiceChip(
                    label: const Center(child: Text('🔴 Tôi nợ (Phải trả)')),
                    selected: _direction == DebtDirection.iOwe,
                    selectedColor: AppTheme.lossRed.withAlpha(60),
                    backgroundColor: AppTheme.darkCard,
                    labelStyle: TextStyle(
                      color: _direction == DebtDirection.iOwe ? Colors.white : Colors.white60,
                      fontWeight: FontWeight.w700,
                    ),
                    onSelected: (val) {
                      if (val) setState(() => _direction = DebtDirection.iOwe);
                    },
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: ChoiceChip(
                    label: const Center(child: Text('🟢 Người khác nợ (Phải thu)')),
                    selected: _direction == DebtDirection.theyOwe,
                    selectedColor: AppTheme.profitGreen.withAlpha(60),
                    backgroundColor: AppTheme.darkCard,
                    labelStyle: TextStyle(
                      color: _direction == DebtDirection.theyOwe ? Colors.white : Colors.white60,
                      fontWeight: FontWeight.w700,
                    ),
                    onSelected: (val) {
                      if (val) setState(() => _direction = DebtDirection.theyOwe);
                    },
                  ),
                ),
              ],
            ),

            const SizedBox(height: 20),

            // 2. Loại tài sản nợ: Vàng hoặc Tiền
            const Text(
              'TÀI SẢN NỢ',
              style: TextStyle(color: AppTheme.goldLight, fontSize: 12, fontWeight: FontWeight.w700, letterSpacing: 1.1),
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: ChoiceChip(
                    avatar: const Icon(Icons.circle, size: 14, color: AppTheme.goldBright),
                    label: const Center(child: Text('Nợ bằng Vàng')),
                    selected: _assetType == DebtAssetType.gold,
                    selectedColor: AppTheme.goldPrimary.withAlpha(60),
                    backgroundColor: AppTheme.darkCard,
                    labelStyle: TextStyle(
                      color: _assetType == DebtAssetType.gold ? Colors.white : Colors.white60,
                      fontWeight: FontWeight.w700,
                    ),
                    onSelected: (val) {
                      if (val) setState(() => _assetType = DebtAssetType.gold);
                    },
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: ChoiceChip(
                    avatar: const Icon(Icons.monetization_on, size: 14, color: Color(0xFF38BDF8)),
                    label: const Center(child: Text('Nợ bằng Tiền (VNĐ)')),
                    selected: _assetType == DebtAssetType.money,
                    selectedColor: const Color(0xFF38BDF8).withAlpha(60),
                    backgroundColor: AppTheme.darkCard,
                    labelStyle: TextStyle(
                      color: _assetType == DebtAssetType.money ? Colors.white : Colors.white60,
                      fontWeight: FontWeight.w700,
                    ),
                    onSelected: (val) {
                      if (val) setState(() => _assetType = DebtAssetType.money);
                    },
                  ),
                ),
              ],
            ),

            const SizedBox(height: 20),

            // 3. Tên người liên quan
            const Text(
              'TÊN NGƯỜI NỢ / CHỦ NỢ',
              style: TextStyle(color: AppTheme.goldLight, fontSize: 12, fontWeight: FontWeight.w700, letterSpacing: 1.1),
            ),
            const SizedBox(height: 10),
            TextFormField(
              controller: _personController,
              decoration: const InputDecoration(
                hintText: 'Ví dụ: Mẹ, Chị Lan, Anh Nam, Tiệm vàng Kim Thành...',
                prefixIcon: Icon(Icons.person_outline_rounded, color: AppTheme.goldPrimary),
              ),
              validator: (v) {
                if (v == null || v.trim().isEmpty) return 'Vui lòng nhập tên người nợ / chủ nợ';
                return null;
              },
            ),

            const SizedBox(height: 16),

            // Số điện thoại (tùy chọn)
            TextFormField(
              controller: _phoneController,
              keyboardType: TextInputType.phone,
              decoration: const InputDecoration(
                labelText: 'Số điện thoại (tùy chọn)',
                hintText: '090...',
                prefixIcon: Icon(Icons.phone_outlined, color: Colors.white54),
              ),
            ),

            const SizedBox(height: 20),

            // 4. Cấu hình chi tiết Nợ Vàng hoặc Nợ Tiền
            if (_assetType == DebtAssetType.gold) ...[
              const Text(
                'LOẠI VÀNG NỢ',
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
                              width: 12,
                              height: 12,
                              decoration: BoxDecoration(
                                color: Color(type.colorValue),
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 10),
                            Text(type.name, style: const TextStyle(fontWeight: FontWeight.w600)),
                          ],
                        ),
                      );
                    }).toList(),
                    onChanged: (val) {
                      if (val != null) setState(() => _goldTypeId = val);
                    },
                  ),
                ),
              ),
              const SizedBox(height: 20),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'SỐ LƯỢNG VÀNG NỢ',
                    style: TextStyle(color: AppTheme.goldLight, fontSize: 12, fontWeight: FontWeight.w700, letterSpacing: 1.1),
                  ),
                  Row(
                    children: ['chỉ', 'lượng'].map((u) {
                      final isSel = _unit == u;
                      return InkWell(
                        onTap: () => setState(() => _unit = u),
                        child: Container(
                          margin: const EdgeInsets.only(left: 6),
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
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
                controller: _amountController,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                decoration: InputDecoration(
                  hintText: 'Ví dụ: 2.0',
                  suffixText: _unit,
                  suffixStyle: const TextStyle(color: AppTheme.goldBright, fontWeight: FontWeight.w700),
                ),
                validator: (v) {
                  if (v == null || v.trim().isEmpty) return 'Vui lòng nhập số lượng vàng';
                  final n = double.tryParse(v.replaceAll(',', '.'));
                  if (n == null || n <= 0) return 'Số lượng phải lớn hơn 0';
                  return null;
                },
              ),
              const SizedBox(height: 16),

              TextFormField(
                controller: _priceController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Giá vàng/chỉ tại thời điểm vay (tùy chọn)',
                  hintText: 'Để theo dõi chênh lệch giá lúc vay vs hiện tại',
                  suffixText: 'đ/chỉ',
                ),
              ),
            ] else ...[
              const Text(
                'SỐ TIỀN NỢ (VNĐ)',
                style: TextStyle(color: AppTheme.goldLight, fontSize: 12, fontWeight: FontWeight.w700, letterSpacing: 1.1),
              ),
              const SizedBox(height: 10),
              TextFormField(
                controller: _amountController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  hintText: 'Ví dụ: 15.000.000',
                  suffixText: 'đ',
                  suffixStyle: TextStyle(color: AppTheme.goldBright, fontWeight: FontWeight.w700),
                ),
                validator: (v) {
                  if (v == null || v.trim().isEmpty) return 'Vui lòng nhập số tiền nợ';
                  final n = double.tryParse(v.replaceAll('.', ''));
                  if (n == null || n <= 0) return 'Số tiền phải lớn hơn 0';
                  return null;
                },
              ),
            ],

            const SizedBox(height: 20),

            // 5. Ngày vay & Ngày hẹn trả
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'NGÀY BẮT ĐẦU VAY',
                        style: TextStyle(color: Colors.white60, fontSize: 11, fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(height: 8),
                      InkWell(
                        onTap: () async {
                          final picked = await showDatePicker(
                            context: context,
                            initialDate: _startDate,
                            firstDate: DateTime(2000),
                            lastDate: DateTime(2100),
                          );
                          if (picked != null) setState(() => _startDate = picked);
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                          decoration: BoxDecoration(
                            color: AppTheme.darkCard,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.white12),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(GoldFormatters.formatDate(_startDate), style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                              const Icon(Icons.calendar_today_rounded, size: 16, color: AppTheme.goldPrimary),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'HẠN HẸN TRẢ (TÙY CHỌN)',
                        style: TextStyle(color: Colors.white60, fontSize: 11, fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(height: 8),
                      InkWell(
                        onTap: () async {
                          final picked = await showDatePicker(
                            context: context,
                            initialDate: _dueDate ?? DateTime.now().add(const Duration(days: 90)),
                            firstDate: DateTime(2000),
                            lastDate: DateTime(2100),
                          );
                          if (picked != null) setState(() => _dueDate = picked);
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                          decoration: BoxDecoration(
                            color: AppTheme.darkCard,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.white12),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                _dueDate != null ? GoldFormatters.formatDate(_dueDate!) : 'Chưa đặt hạn',
                                style: TextStyle(
                                  fontSize: 13,
                                  color: _dueDate != null ? Colors.white : Colors.white38,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const Icon(Icons.event_available_rounded, size: 16, color: AppTheme.goldPrimary),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 20),

            // Ghi chú
            const Text(
              'GHI CHÚ / MỤC ĐÍCH VAY',
              style: TextStyle(color: Colors.white60, fontSize: 11, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            TextFormField(
              controller: _noteController,
              maxLines: 2,
              decoration: const InputDecoration(
                hintText: 'Ví dụ: Mượn vàng làm nhà, Vay mua đất, Cần trả trước Tết...',
              ),
            ),

            const SizedBox(height: 30),

            // Nút Lưu
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
                  widget.editDebt != null ? 'LƯU THAY ĐỔI' : 'LƯU VÀO SỔ GHI NỢ',
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
