import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../models/gold_type.dart';
import '../providers/portfolio_provider.dart';
import '../utils/theme.dart';
import 'update_price_screen.dart';
import 'goal_detail_screen.dart';

class SettingsTab extends StatelessWidget {
  const SettingsTab({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<PortfolioProvider>();
    final settings = provider.settings;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Cài Đặt', style: TextStyle(fontWeight: FontWeight.w800)),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Section 1: Quản lý vàng & giá cả
          _buildSectionHeader('DANH MỤC & GIÁ VÀNG'),
          _buildCard([
            _buildTile(
              icon: Icons.price_change_outlined,
              title: 'Cập nhật giá vàng thị trường',
              subtitle: 'Tự nhập giá mua/bán từ các tiệm vàng',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const UpdatePriceScreen()),
                );
              },
            ),
            _buildDivider(),
            _buildTile(
              icon: Icons.category_outlined,
              title: 'Quản lý các loại vàng',
              subtitle: '${provider.goldTypes.length} loại vàng đang kích hoạt',
              onTap: () => _showManageGoldTypesDialog(context),
            ),
            _buildDivider(),
            _buildTile(
              icon: Icons.flag_outlined,
              title: 'Mục tiêu & Kế hoạch Hũ Vàng',
              subtitle: provider.goal.name,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const GoalDetailScreen()),
                );
              },
            ),
            _buildDivider(),
            SwitchListTile(
              secondary: const Icon(Icons.calculate_outlined, color: AppTheme.goldPrimary),
              title: const Text('Định giá theo giá tiệm bán ra', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
              subtitle: Text(
                settings.useMarketSellPrice
                    ? 'Đang tính theo giá tiệm bán ra'
                    : 'Đang tính theo giá tiệm thu mua vào',
                style: const TextStyle(fontSize: 11, color: Colors.white54),
              ),
              value: settings.useMarketSellPrice,
              activeThumbColor: AppTheme.goldBright,
              onChanged: (val) {
                provider.updateSettings(settings.copyWith(useMarketSellPrice: val));
              },
            ),
          ]),

          const SizedBox(height: 20),

          // Section 2: Bảo mật & Riêng tư
          _buildSectionHeader('BẢO MẬT & RIÊNG TƯ'),
          _buildCard([
            SwitchListTile(
              secondary: const Icon(Icons.visibility_off_outlined, color: AppTheme.goldPrimary),
              title: const Text('Ẩn số tiền & tài sản', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
              subtitle: const Text('Hiển thị dạng •••••••• ở màn hình chính', style: TextStyle(fontSize: 11, color: Colors.white54)),
              value: settings.isAmountHidden,
              activeThumbColor: AppTheme.goldBright,
              onChanged: (_) => provider.toggleHideAmount(),
            ),
            _buildDivider(),
            SwitchListTile(
              secondary: const Icon(Icons.lock_outline_rounded, color: AppTheme.goldPrimary),
              title: const Text('Khóa ứng dụng bằng mã PIN', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
              subtitle: Text(
                settings.isPinEnabled ? 'Đang bật bảo vệ bằng mã PIN' : 'Chưa bật mã PIN',
                style: const TextStyle(fontSize: 11, color: Colors.white54),
              ),
              value: settings.isPinEnabled,
              activeThumbColor: AppTheme.goldBright,
              onChanged: (val) {
                if (val) {
                  _showSetPinDialog(context);
                } else {
                  provider.updateSettings(settings.copyWith(isPinEnabled: false));
                }
              },
            ),
            if (settings.isPinEnabled) ...[
              _buildDivider(),
              _buildTile(
                icon: Icons.password_rounded,
                title: 'Đổi mã PIN',
                subtitle: 'Mã PIN hiện tại gồm ${settings.pinCode.length} chữ số',
                onTap: () => _showSetPinDialog(context),
              ),
            ],
          ]),

          const SizedBox(height: 20),

          // Section 3: Sao lưu & Dữ liệu Offline
          _buildSectionHeader('SAO LƯU & DỮ LIỆU OFFLINE'),
          _buildCard([
            _buildTile(
              icon: Icons.file_upload_outlined,
              title: 'Sao lưu dữ liệu (Xuất JSON)',
              subtitle: 'Lưu bản sao an toàn vào máy hoặc ghi nhớ',
              onTap: () => _exportJsonDialog(context),
            ),
            _buildDivider(),
            _buildTile(
              icon: Icons.file_download_outlined,
              title: 'Khôi phục dữ liệu (Nhập JSON)',
              subtitle: 'Khôi phục từ file hoặc nội dung JSON đã sao lưu',
              onTap: () => _importJsonDialog(context),
            ),
            _buildDivider(),
            _buildTile(
              icon: Icons.table_chart_outlined,
              title: 'Xuất file Excel / CSV',
              subtitle: 'Xuất toàn bộ lịch sử giao dịch để xem trên Excel',
              onTap: () => _exportCsvDialog(context),
            ),
            _buildDivider(),
            _buildTile(
              icon: Icons.delete_forever_rounded,
              title: 'Xóa toàn bộ dữ liệu',
              subtitle: 'Đưa ứng dụng về trạng thái ban đầu trống',
              textColor: AppTheme.lossRed,
              onTap: () => _confirmClearAll(context),
            ),
          ]),

          const SizedBox(height: 20),

          // Section 4: Thông tin ứng dụng
          _buildSectionHeader('VỀ ỨNG DỤNG'),
          _buildCard([
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  const Row(
                    children: [
                      Text('🪙', style: TextStyle(fontSize: 24)),
                      SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'HŨ VÀNG — Gold Portfolio',
                              style: TextStyle(
                                color: AppTheme.goldBright,
                                fontWeight: FontWeight.w800,
                                fontSize: 15,
                              ),
                            ),
                            Text(
                              'Phiên bản 1.0 • Hoàn toàn Offline 100%',
                              style: TextStyle(color: Colors.white54, fontSize: 12),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.white.withAlpha(10),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Text(
                      '🔒 Không cần tạo tài khoản, không máy chủ, không thu thập dữ liệu cá nhân. Toàn bộ tài sản được lưu trữ an toàn ngay trên thiết bị của bạn.',
                      style: TextStyle(color: Colors.white70, fontSize: 11, height: 1.4),
                    ),
                  ),
                ],
              ),
            ),
          ]),

          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 8),
      child: Text(
        title,
        style: const TextStyle(
          color: AppTheme.goldLight,
          fontSize: 11,
          fontWeight: FontWeight.w800,
          letterSpacing: 1.2,
        ),
      ),
    );
  }

  Widget _buildCard(List<Widget> children) {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.darkCard,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.white12),
      ),
      child: Column(children: children),
    );
  }

  Widget _buildTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    Color? textColor,
  }) {
    return ListTile(
      leading: Icon(icon, color: textColor ?? AppTheme.goldPrimary),
      title: Text(
        title,
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: textColor ?? Colors.white,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: const TextStyle(fontSize: 11, color: Colors.white54),
      ),
      trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 14, color: Colors.white38),
      onTap: onTap,
    );
  }

  Widget _buildDivider() {
    return const Divider(height: 1, color: Colors.white12, indent: 56);
  }

  // --- Dialogs ---

  void _showSetPinDialog(BuildContext context) {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (dCtx) => AlertDialog(
        title: const Text('Cài đặt mã PIN'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Nhập mã PIN 4 chữ số để bảo vệ ứng dụng khi mở:',
              style: TextStyle(fontSize: 13, color: Colors.white70),
            ),
            const SizedBox(height: 14),
            TextField(
              controller: controller,
              keyboardType: TextInputType.number,
              maxLength: 4,
              obscureText: true,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 24, letterSpacing: 8, fontWeight: FontWeight.bold),
              decoration: const InputDecoration(hintText: '••••'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dCtx),
            child: const Text('HỦY'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.goldPrimary),
            onPressed: () {
              final pin = controller.text.trim();
              if (pin.length >= 4) {
                final provider = context.read<PortfolioProvider>();
                provider.updateSettings(
                  provider.settings.copyWith(isPinEnabled: true, pinCode: pin),
                );
                Navigator.pop(dCtx);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Đã bật bảo vệ mã PIN thành công!'),
                    backgroundColor: AppTheme.profitGreen,
                  ),
                );
              }
            },
            child: const Text('LƯU MÃ PIN', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  void _exportJsonDialog(BuildContext context) {
    final provider = context.read<PortfolioProvider>();
    final json = provider.exportBackupJson();

    showDialog(
      context: context,
      builder: (dCtx) => AlertDialog(
        title: const Text('Sao lưu dữ liệu JSON'),
        content: SizedBox(
          width: 450,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Dưới đây là toàn bộ dữ liệu giao dịch, loại vàng, giá và mục tiêu của bạn ở định dạng JSON an toàn:',
                style: TextStyle(fontSize: 12, color: Colors.white70),
              ),
              const SizedBox(height: 12),
              Container(
                height: 180,
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.black45,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.white12),
                ),
                child: SingleChildScrollView(
                  child: Text(
                    json,
                    style: const TextStyle(fontFamily: 'monospace', fontSize: 11, color: AppTheme.goldLight),
                  ),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dCtx),
            child: const Text('ĐÓNG'),
          ),
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.goldPrimary),
            icon: const Icon(Icons.copy_rounded, color: Colors.black, size: 18),
            label: const Text('SAO CHÉP JSON', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
            onPressed: () {
              Clipboard.setData(ClipboardData(text: json));
              Navigator.pop(dCtx);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Đã sao chép nội dung backup vào Clipboard!'),
                  backgroundColor: AppTheme.profitGreen,
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  void _importJsonDialog(BuildContext context) {
    final controller = TextEditingController();
    final messenger = ScaffoldMessenger.of(context);

    showDialog(
      context: context,
      builder: (dCtx) => AlertDialog(
        title: const Text('Khôi phục từ JSON'),
        content: SizedBox(
          width: 450,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Dán nội dung JSON sao lưu trước đó vào đây để khôi phục dữ liệu:',
                style: TextStyle(fontSize: 12, color: Colors.white70),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: controller,
                maxLines: 8,
                style: const TextStyle(fontFamily: 'monospace', fontSize: 11),
                decoration: const InputDecoration(
                  hintText: '{\n  "app": "HuVang",\n  ...\n}',
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dCtx),
            child: const Text('HỦY'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.goldPrimary),
            child: const Text('KHÔI PHỤC', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
            onPressed: () async {
              final text = controller.text.trim();
              if (text.isNotEmpty) {
                final ok = await context.read<PortfolioProvider>().importBackupJson(text);
                if (dCtx.mounted) Navigator.pop(dCtx);
                if (ok) {
                  messenger.showSnackBar(
                    const SnackBar(
                      content: Text('Khôi phục dữ liệu thành công!'),
                      backgroundColor: AppTheme.profitGreen,
                    ),
                  );
                } else {
                  messenger.showSnackBar(
                    const SnackBar(
                      content: Text('Nội dung JSON không hợp lệ! Vui lòng thử lại.'),
                      backgroundColor: AppTheme.lossRed,
                    ),
                  );
                }
              }
            },
          ),
        ],
      ),
    );
  }

  void _exportCsvDialog(BuildContext context) {
    final provider = context.read<PortfolioProvider>();
    final csv = provider.exportCsv();

    showDialog(
      context: context,
      builder: (dCtx) => AlertDialog(
        title: const Text('Xuất CSV / Excel'),
        content: SizedBox(
          width: 450,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Dữ liệu bảng tính CSV tương thích với Microsoft Excel, Google Sheets:',
                style: TextStyle(fontSize: 12, color: Colors.white70),
              ),
              const SizedBox(height: 12),
              Container(
                height: 160,
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.black45,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.white12),
                ),
                child: SingleChildScrollView(
                  child: Text(
                    csv,
                    style: const TextStyle(fontFamily: 'monospace', fontSize: 11, color: Colors.white70),
                  ),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dCtx),
            child: const Text('ĐÓNG'),
          ),
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.goldPrimary),
            icon: const Icon(Icons.copy_rounded, color: Colors.black, size: 18),
            label: const Text('SAO CHÉP CSV', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
            onPressed: () {
              Clipboard.setData(ClipboardData(text: csv));
              Navigator.pop(dCtx);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Đã sao chép nội dung CSV vào Clipboard!'),
                  backgroundColor: AppTheme.profitGreen,
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  void _showManageGoldTypesDialog(BuildContext context) {
    final provider = context.read<PortfolioProvider>();
    final types = provider.goldTypes;

    showDialog(
      context: context,
      builder: (dCtx) => AlertDialog(
        title: const Text('Danh mục loại vàng'),
        content: SizedBox(
          width: 400,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ...types.map((t) => ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: Container(
                        width: 14,
                        height: 14,
                        decoration: BoxDecoration(
                          color: Color(t.colorValue),
                          shape: BoxShape.circle,
                        ),
                      ),
                      title: Text(t.name, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
                      subtitle: Text('Độ tinh khiết: ${t.purity}% • Đơn vị: ${t.unit}', style: const TextStyle(fontSize: 11)),
                    )),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dCtx),
            child: const Text('ĐÓNG'),
          ),
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.goldPrimary),
            icon: const Icon(Icons.add, color: Colors.black, size: 18),
            label: const Text('THÊM LOẠI VÀNG', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
            onPressed: () {
              Navigator.pop(dCtx);
              _showAddGoldTypeDialog(context);
            },
          ),
        ],
      ),
    );
  }

  void _showAddGoldTypeDialog(BuildContext context) {
    final nameCtrl = TextEditingController();
    final purityCtrl = TextEditingController(text: '99.0');

    showDialog(
      context: context,
      builder: (dCtx) => AlertDialog(
        title: const Text('Thêm loại vàng mới'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameCtrl,
              decoration: const InputDecoration(labelText: 'Tên loại vàng (ví dụ: Vàng 14K, Vàng Ý...)'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: purityCtrl,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              decoration: const InputDecoration(labelText: 'Độ tinh khiết % (ví dụ: 58.5)'),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(dCtx), child: const Text('HỦY')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.goldPrimary),
            child: const Text('THÊM', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
            onPressed: () {
              final name = nameCtrl.text.trim();
              final purity = double.tryParse(purityCtrl.text.replaceAll(',', '.')) ?? 99.0;
              if (name.isNotEmpty) {
                final id = 'custom_${DateTime.now().millisecondsSinceEpoch}';
                final newType = GoldType(
                  id: id,
                  name: name,
                  purity: purity,
                  colorValue: 0xFFE0C068,
                  isCustom: true,
                );
                context.read<PortfolioProvider>().addGoldType(newType);
                Navigator.pop(dCtx);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Đã thêm loại vàng "$name"!'),
                    backgroundColor: AppTheme.profitGreen,
                  ),
                );
              }
            },
          ),
        ],
      ),
    );
  }

  void _confirmClearAll(BuildContext context) {
    showDialog(
      context: context,
      builder: (dCtx) => AlertDialog(
        title: const Text('Xóa toàn bộ dữ liệu?'),
        content: const Text('Tất cả giao dịch và cài đặt sẽ bị xóa hoàn toàn khỏi thiết bị. Hành động này không thể hoàn tác.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(dCtx), child: const Text('HỦY')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.lossRed),
            child: const Text('XÓA HẾT'),
            onPressed: () {
              context.read<PortfolioProvider>().clearAllData();
              Navigator.pop(dCtx);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Đã làm trống toàn bộ dữ liệu!'),
                  backgroundColor: AppTheme.lossRed,
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
