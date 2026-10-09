import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/gold_type.dart';
import '../models/gold_transaction.dart';
import '../models/gold_price.dart';
import '../models/gold_goal.dart';
import '../models/gold_debt.dart';
import '../models/app_settings.dart';

class StorageService {
  static const String _keyTransactions = 'hu_vang_transactions';
  static const String _keyGoldTypes = 'hu_vang_gold_types';
  static const String _keyPrices = 'hu_vang_prices';
  static const String _keyGoal = 'hu_vang_goal';
  static const String _keyDebts = 'hu_vang_debts';
  static const String _keySettings = 'hu_vang_settings';
  static const String _keyVersion = 'hu_vang_clean_version';

  final SharedPreferences _prefs;

  StorageService(this._prefs);

  static Future<StorageService> init() async {
    final prefs = await SharedPreferences.getInstance();
    final service = StorageService(prefs);

    // Migration to clean slate: clear any previously cached mock data
    final currentVersion = prefs.getString(_keyVersion);
    if (currentVersion != '2.0_clean') {
      await service.initializeWithCleanDefaults();
      await prefs.setString(_keyVersion, '2.0_clean');
    }

    return service;
  }

  Future<void> initializeWithCleanDefaults() async {
    await saveGoldTypes(GoldType.defaultTypes);
    await savePrices({}); // Không lưu giá hard-code
    await saveTransactions([]); // Không lưu giao dịch hard-code
    await saveDebts([]); // Không lưu nợ hard-code
    await saveGoal(GoldGoal.defaultGoal);
    await saveSettings(const AppSettings());
  }

  // --- Transactions ---
  List<GoldTransaction> loadTransactions() {
    final raw = _prefs.getString(_keyTransactions);
    if (raw == null) return [];
    try {
      final list = jsonDecode(raw) as List;
      return list.map((e) => GoldTransaction.fromJson(e as Map<String, dynamic>)).toList();
    } catch (_) {
      return [];
    }
  }

  Future<void> saveTransactions(List<GoldTransaction> transactions) async {
    final raw = jsonEncode(transactions.map((e) => e.toJson()).toList());
    await _prefs.setString(_keyTransactions, raw);
  }

  // --- Debts (Ghi nợ) ---
  List<GoldDebt> loadDebts() {
    final raw = _prefs.getString(_keyDebts);
    if (raw == null) return [];
    try {
      final list = jsonDecode(raw) as List;
      return list.map((e) => GoldDebt.fromJson(e as Map<String, dynamic>)).toList();
    } catch (_) {
      return [];
    }
  }

  Future<void> saveDebts(List<GoldDebt> debts) async {
    final raw = jsonEncode(debts.map((e) => e.toJson()).toList());
    await _prefs.setString(_keyDebts, raw);
  }

  // --- Gold Types ---
  List<GoldType> loadGoldTypes() {
    final raw = _prefs.getString(_keyGoldTypes);
    if (raw == null) return GoldType.defaultTypes;
    try {
      final list = jsonDecode(raw) as List;
      return list.map((e) => GoldType.fromJson(e as Map<String, dynamic>)).toList();
    } catch (_) {
      return GoldType.defaultTypes;
    }
  }

  Future<void> saveGoldTypes(List<GoldType> types) async {
    final raw = jsonEncode(types.map((e) => e.toJson()).toList());
    await _prefs.setString(_keyGoldTypes, raw);
  }

  // --- Prices ---
  Map<String, GoldPrice> loadPrices() {
    final raw = _prefs.getString(_keyPrices);
    if (raw == null) return {};
    try {
      final map = jsonDecode(raw) as Map<String, dynamic>;
      return map.map((k, v) => MapEntry(k, GoldPrice.fromJson(v as Map<String, dynamic>)));
    } catch (_) {
      return {};
    }
  }

  Future<void> savePrices(Map<String, GoldPrice> prices) async {
    final map = prices.map((k, v) => MapEntry(k, v.toJson()));
    await _prefs.setString(_keyPrices, jsonEncode(map));
  }

  // --- Goal ---
  GoldGoal loadGoal() {
    final raw = _prefs.getString(_keyGoal);
    if (raw == null) return GoldGoal.defaultGoal;
    try {
      return GoldGoal.fromJson(jsonDecode(raw) as Map<String, dynamic>);
    } catch (_) {
      return GoldGoal.defaultGoal;
    }
  }

  Future<void> saveGoal(GoldGoal goal) async {
    await _prefs.setString(_keyGoal, jsonEncode(goal.toJson()));
  }

  // --- Settings ---
  AppSettings loadSettings() {
    final raw = _prefs.getString(_keySettings);
    if (raw == null) return const AppSettings();
    try {
      return AppSettings.fromJson(jsonDecode(raw) as Map<String, dynamic>);
    } catch (_) {
      return const AppSettings();
    }
  }

  Future<void> saveSettings(AppSettings settings) async {
    await _prefs.setString(_keySettings, jsonEncode(settings.toJson()));
  }

  // --- Backup & Restore (Offline 100%) ---
  String exportBackupJson() {
    final backup = {
      'app': 'HuVang',
      'version': '1.0.0',
      'exportedAt': DateTime.now().toIso8601String(),
      'goldTypes': loadGoldTypes().map((e) => e.toJson()).toList(),
      'prices': loadPrices().map((k, v) => MapEntry(k, v.toJson())),
      'transactions': loadTransactions().map((e) => e.toJson()).toList(),
      'debts': loadDebts().map((e) => e.toJson()).toList(),
      'goal': loadGoal().toJson(),
      'settings': loadSettings().toJson(),
    };
    return const JsonEncoder.withIndent('  ').convert(backup);
  }

  Future<bool> importBackupJson(String jsonString) async {
    try {
      final data = jsonDecode(jsonString) as Map<String, dynamic>;
      if (data['goldTypes'] != null) {
        final list = (data['goldTypes'] as List)
            .map((e) => GoldType.fromJson(e as Map<String, dynamic>))
            .toList();
        await saveGoldTypes(list);
      }
      if (data['prices'] != null) {
        final map = (data['prices'] as Map<String, dynamic>).map(
          (k, v) => MapEntry(k, GoldPrice.fromJson(v as Map<String, dynamic>)),
        );
        await savePrices(map);
      }
      if (data['transactions'] != null) {
        final list = (data['transactions'] as List)
            .map((e) => GoldTransaction.fromJson(e as Map<String, dynamic>))
            .toList();
        await saveTransactions(list);
      }
      if (data['debts'] != null) {
        final list = (data['debts'] as List)
            .map((e) => GoldDebt.fromJson(e as Map<String, dynamic>))
            .toList();
        await saveDebts(list);
      }
      if (data['goal'] != null) {
        await saveGoal(GoldGoal.fromJson(data['goal'] as Map<String, dynamic>));
      }
      if (data['settings'] != null) {
        await saveSettings(AppSettings.fromJson(data['settings'] as Map<String, dynamic>));
      }
      return true;
    } catch (e) {
      return false;
    }
  }

  /// Xuất giao dịch ra CSV để mở trong Excel
  String exportTransactionsCsv() {
    final txs = loadTransactions();
    final types = {for (var t in loadGoldTypes()) t.id: t.name};

    final buffer = StringBuffer();
    // Header
    buffer.writeln('Mã GD,Ngày,Loại GD,Loại Vàng,Số lượng (chỉ),Số lượng (lượng),Đơn giá (đ/chỉ),Phí (đ),Tổng tiền (đ),Cửa hàng,Ghi chú');

    for (final tx in txs) {
      final typeName = types[tx.goldTypeId] ?? tx.goldTypeId;
      final dateStr = tx.transactionDate.toIso8601String().split('T').first;
      final shop = (tx.shop ?? '').replaceAll(',', ' ');
      final note = (tx.note ?? '').replaceAll(',', ' ');
      buffer.writeln(
        '${tx.id},$dateStr,${tx.type.label},$typeName,${tx.quantity},${(tx.quantity / 10).toStringAsFixed(3)},${tx.pricePerUnit},${tx.fee},${tx.totalAmount},"$shop","$note"',
      );
    }
    return buffer.toString();
  }

  Future<void> clearAll() async {
    await _prefs.clear();
    await saveGoldTypes(GoldType.defaultTypes);
    await savePrices({});
    await saveTransactions([]);
    await saveDebts([]);
    await saveGoal(GoldGoal.defaultGoal);
    await saveSettings(const AppSettings());
    await _prefs.setString(_keyVersion, '2.0_clean');
  }
}
