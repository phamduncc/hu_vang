import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/portfolio_provider.dart';
import '../utils/theme.dart';

class UpdatePriceScreen extends StatefulWidget {
  final String? initialGoldTypeId;

  const UpdatePriceScreen({super.key, this.initialGoldTypeId});

  @override
  State<UpdatePriceScreen> createState() => _UpdatePriceScreenState();
}

class _UpdatePriceScreenState extends State<UpdatePriceScreen> {
  final Map<String, TextEditingController> _buyControllers = {};
  final Map<String, TextEditingController> _sellControllers = {};
  final Map<String, TextEditingController> _noteControllers = {};

  @override
  void initState() {
    super.initState();
    final provider = context.read<PortfolioProvider>();
    for (final type in provider.goldTypes) {
      final current = provider.prices[type.id];
      _buyControllers[type.id] = TextEditingController(
        text: current != null ? current.buyPrice.round().toString() : '',
      );
      _sellControllers[type.id] = TextEditingController(
        text: current != null ? current.sellPrice.round().toString() : '',
      );
      _noteControllers[type.id] = TextEditingController(
        text: current?.note ?? '',
      );
    }
  }

  @override
  void dispose() {
    for (final c in _buyControllers.values) {
      c.dispose();
    }
    for (final c in _sellControllers.values) {
      c.dispose();
    }
    for (final c in _noteControllers.values) {
      c.dispose();
    }
    super.dispose();
  }

  void _saveAll() {
    final provider = context.read<PortfolioProvider>();
    for (final type in provider.goldTypes) {
      final buy = double.tryParse(
            _buyControllers[type.id]?.text.replaceAll('.', '') ?? '',
          ) ??
          0.0;
      final sell = double.tryParse(
            _sellControllers[type.id]?.text.replaceAll('.', '') ?? '',
          ) ??
          0.0;
      final note = _noteControllers[type.id]?.text.trim();

      if (buy > 0 || sell > 0) {
        provider.updatePrice(
          type.id,
          buy > 0 ? buy : sell,
          sell > 0 ? sell : buy,
          note: note,
        );
      }
    }

    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Đã cập nhật bảng giá thị trường thành công!'),
        backgroundColor: AppTheme.profitGreen,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<PortfolioProvider>();
    final types = provider.goldTypes;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Cập nhật giá thị trường', style: TextStyle(fontWeight: FontWeight.w700)),
        actions: [
          TextButton(
            onPressed: _saveAll,
            child: const Text(
              'LƯU TẤT CẢ',
              style: TextStyle(color: AppTheme.goldBright, fontWeight: FontWeight.w800),
            ),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppTheme.goldPrimary.withAlpha(30),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppTheme.goldPrimary.withAlpha(76)),
            ),
            child: const Row(
              children: [
                Icon(Icons.info_outline_rounded, color: AppTheme.goldPrimary, size: 20),
                SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Ứng dụng hoạt động Offline 100%. Bạn có thể tự cập nhật giá vàng hôm nay từ tiệm vàng bạn tin cậy để tự động định giá tài sản & lãi/lỗ.',
                    style: TextStyle(color: Colors.white70, fontSize: 12),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          ...types.map((type) {
            final isHighlight = widget.initialGoldTypeId == type.id;
            return Card(
              color: isHighlight
                  ? const Color(0xFF24221C)
                  : AppTheme.darkCard,
              margin: const EdgeInsets.only(bottom: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
                side: BorderSide(
                  color: isHighlight ? AppTheme.goldPrimary : Colors.white12,
                  width: isHighlight ? 1.5 : 1.0,
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 12,
                          height: 12,
                          decoration: BoxDecoration(
                            color: Color(type.colorValue),
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          type.name,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                        const Spacer(),
                        Text(
                          '${type.purity}% tinh khiết',
                          style: const TextStyle(color: Colors.white38, fontSize: 11),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Tiệm mua vào (đ/chỉ)',
                                style: TextStyle(color: Colors.white60, fontSize: 11),
                              ),
                              const SizedBox(height: 6),
                              TextFormField(
                                controller: _buyControllers[type.id],
                                keyboardType: TextInputType.number,
                                decoration: const InputDecoration(
                                  hintText: 'Nhập giá mua vào',
                                  contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
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
                                'Tiệm bán ra (đ/chỉ)',
                                style: TextStyle(color: AppTheme.goldBright, fontSize: 11, fontWeight: FontWeight.w600),
                              ),
                              const SizedBox(height: 6),
                              TextFormField(
                                controller: _sellControllers[type.id],
                                keyboardType: TextInputType.number,
                                decoration: const InputDecoration(
                                  hintText: 'Nhập giá bán ra',
                                  contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          }),
          const SizedBox(height: 20),
          SizedBox(
            height: 50,
            child: ElevatedButton.icon(
              onPressed: _saveAll,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.goldPrimary,
                foregroundColor: Colors.black,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              ),
              icon: const Icon(Icons.check_circle_rounded),
              label: const Text(
                'LƯU CẬP NHẬT GIÁ',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800),
              ),
            ),
          ),
          const SizedBox(height: 40),
        ],
      ),
    );
  }
}
