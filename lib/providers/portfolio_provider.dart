import 'dart:math';
import 'package:flutter/foundation.dart';
import '../models/gold_type.dart';
import '../models/gold_transaction.dart';
import '../models/gold_price.dart';
import '../models/gold_goal.dart';
import '../models/portfolio.dart';
import '../models/app_settings.dart';
import '../services/storage_service.dart';

class PortfolioProvider extends ChangeNotifier {
  final StorageService _storage;

  List<GoldType> _goldTypes = [];
  List<GoldTransaction> _transactions = [];
  Map<String, GoldPrice> _prices = {};
  GoldGoal _goal = GoldGoal.defaultGoal;
  AppSettings _settings = const AppSettings();

  bool _isUnlocked = true;

  PortfolioProvider(this._storage) {
    _loadData();
  }

  // --- Getters ---
  List<GoldType> get goldTypes => List.unmodifiable(_goldTypes);
  List<GoldTransaction> get transactions => List.unmodifiable(_transactions);
  Map<String, GoldPrice> get prices => Map.unmodifiable(_prices);
  GoldGoal get goal => _goal;
  AppSettings get settings => _settings;
  bool get isAmountHidden => _settings.isAmountHidden;
  bool get isLocked => _settings.isPinEnabled && !_isUnlocked;

  void _loadData() {
    _goldTypes = _storage.loadGoldTypes();
    _transactions = _storage.loadTransactions();
    _prices = _storage.loadPrices();
    _goal = _storage.loadGoal();
    _settings = _storage.loadSettings();

    if (_settings.isPinEnabled) {
      _isUnlocked = false;
    } else {
      _isUnlocked = true;
    }
    notifyListeners();
  }

  // --- PIN Lock & Privacy ---
  bool unlockWithPin(String pin) {
    if (pin == _settings.pinCode) {
      _isUnlocked = true;
      notifyListeners();
      return true;
    }
    return false;
  }

  void lockApp() {
    if (_settings.isPinEnabled) {
      _isUnlocked = false;
      notifyListeners();
    }
  }

  Future<void> toggleHideAmount() async {
    _settings = _settings.copyWith(isAmountHidden: !_settings.isAmountHidden);
    await _storage.saveSettings(_settings);
    notifyListeners();
  }

  Future<void> updateSettings(AppSettings newSettings) async {
    _settings = newSettings;
    await _storage.saveSettings(_settings);
    notifyListeners();
  }

  // --- Portfolio Calculation Engine ---
  PortfolioSummary get portfolioSummary {
    // Sắp xếp giao dịch theo thời gian tăng dần để tính giá vốn chuẩn xác
    final sortedTxs = List<GoldTransaction>.from(_transactions)
      ..sort((a, b) => a.transactionDate.compareTo(b.transactionDate));

    final Map<String, double> runningQty = {};
    final Map<String, double> runningCost = {};
    final Map<String, double> runningRealizedProfit = {};

    for (final type in _goldTypes) {
      runningQty[type.id] = 0.0;
      runningCost[type.id] = 0.0;
      runningRealizedProfit[type.id] = 0.0;
    }

    for (final tx in sortedTxs) {
      final tid = tx.goldTypeId;
      final curQty = runningQty[tid] ?? 0.0;
      final curCost = runningCost[tid] ?? 0.0;
      final curRealized = runningRealizedProfit[tid] ?? 0.0;

      switch (tx.type) {
        case TransactionType.buy:
        case TransactionType.giftReceived:
          runningQty[tid] = curQty + tx.quantity;
          runningCost[tid] = curCost + tx.totalAmount;
          break;

        case TransactionType.sell:
          if (curQty > 0) {
            final avgCostBeforeSale = curCost / curQty;
            final costBasisOfSold = tx.quantity * avgCostBeforeSale;
            final profitOfSale = tx.totalAmount - costBasisOfSold;

            final newQty = max(0.0, curQty - tx.quantity);
            final newCost = newQty <= 0.0001 ? 0.0 : max(0.0, curCost - costBasisOfSold);

            runningQty[tid] = newQty;
            runningCost[tid] = newCost;
            runningRealizedProfit[tid] = curRealized + profitOfSale;
          }
          break;

        case TransactionType.giftGiven:
          if (curQty > 0) {
            final avgCost = curCost / curQty;
            final costBasis = tx.quantity * avgCost;
            final newQty = max(0.0, curQty - tx.quantity);
            final newCost = newQty <= 0.0001 ? 0.0 : max(0.0, curCost - costBasis);
            runningQty[tid] = newQty;
            runningCost[tid] = newCost;
          }
          break;

        case TransactionType.adjustment:
          // Điều chỉnh số lượng
          final newQty = max(0.0, tx.quantity);
          if (newQty == 0) {
            runningQty[tid] = 0;
            runningCost[tid] = 0;
          } else {
            runningQty[tid] = newQty;
            // Nếu có tổng tiền nhập vào thì cập nhật, ngược lại giữ nguyên tỉ lệ
            if (tx.totalAmount > 0) {
              runningCost[tid] = tx.totalAmount;
            }
          }
          break;
      }
    }

    // Xây dựng danh sách thống kê từng loại
    final Map<String, GoldTypePortfolio> items = {};
    double totalQuantity = 0.0;
    double totalCost = 0.0;
    double totalCurrentValue = 0.0;
    double totalRealizedProfit = 0.0;

    for (final type in _goldTypes) {
      final qty = runningQty[type.id] ?? 0.0;
      final cost = runningCost[type.id] ?? 0.0;
      final realized = runningRealizedProfit[type.id] ?? 0.0;
      final avgCost = qty > 0 ? (cost / qty) : 0.0;

      // Lấy giá thị trường hiện tại
      final priceEntry = _prices[type.id];
      // Nếu bật useMarketSellPrice thì dùng giá bán ra từ tiệm, hoặc giá tiệm thu mua vào
      final marketPrice = priceEntry != null
          ? (_settings.useMarketSellPrice ? priceEntry.sellPrice : priceEntry.buyPrice)
          : 0.0;

      final currentValue = qty * marketPrice;
      final profit = currentValue - cost;
      final profitPercent = cost > 0 ? (profit / cost) * 100 : 0.0;

      items[type.id] = GoldTypePortfolio(
        goldType: type,
        quantity: qty,
        totalCost: cost,
        averageCost: avgCost,
        marketPrice: marketPrice,
        currentValue: currentValue,
        profit: profit,
        profitPercent: profitPercent,
        realizedProfit: realized,
      );

      totalQuantity += qty;
      totalCost += cost;
      totalCurrentValue += currentValue;
      totalRealizedProfit += realized;
    }

    final totalProfit = totalCurrentValue - totalCost;
    final totalProfitPercent = totalCost > 0 ? (totalProfit / totalCost) * 100 : 0.0;
    final totalAverageCost = totalQuantity > 0 ? (totalCost / totalQuantity) : 0.0;

    return PortfolioSummary(
      totalQuantity: totalQuantity,
      totalCost: totalCost,
      averageCostPerChi: totalAverageCost,
      totalCurrentValue: totalCurrentValue,
      totalProfit: totalProfit,
      totalProfitPercent: totalProfitPercent,
      totalRealizedProfit: totalRealizedProfit,
      items: items,
    );
  }

  // --- Transactions Operations ---
  Future<void> addTransaction(GoldTransaction tx) async {
    // Tính toán costBasisAtSale nếu là giao dịch Bán
    GoldTransaction finalTx = tx;
    if (tx.type == TransactionType.sell) {
      final currentPortfolio = portfolioSummary.items[tx.goldTypeId];
      if (currentPortfolio != null && currentPortfolio.quantity > 0) {
        final avgCost = currentPortfolio.averageCost;
        final costBasis = tx.quantity * avgCost;
        final profit = tx.totalAmount - costBasis;
        finalTx = tx.copyWith(
          costBasisAtSale: costBasis,
          realizedProfit: profit,
        );
      }
    }

    _transactions.insert(0, finalTx);
    await _storage.saveTransactions(_transactions);
    notifyListeners();
  }

  Future<void> updateTransaction(GoldTransaction tx) async {
    final index = _transactions.indexWhere((t) => t.id == tx.id);
    if (index != -1) {
      _transactions[index] = tx;
      await _storage.saveTransactions(_transactions);
      notifyListeners();
    }
  }

  Future<void> deleteTransaction(String id) async {
    _transactions.removeWhere((t) => t.id == id);
    await _storage.saveTransactions(_transactions);
    notifyListeners();
  }

  // --- Gold Price Operations ---
  Future<void> updatePrice(String goldTypeId, double buyPrice, double sellPrice, {String? note}) async {
    final entry = GoldPrice(
      goldTypeId: goldTypeId,
      buyPrice: buyPrice,
      sellPrice: sellPrice,
      updatedAt: DateTime.now(),
      note: note,
    );
    final updated = Map<String, GoldPrice>.from(_prices);
    updated[goldTypeId] = entry;
    _prices = updated;
    await _storage.savePrices(_prices);
    notifyListeners();
  }

  // --- Gold Type Operations ---
  Future<void> addGoldType(GoldType type) async {
    _goldTypes.add(type);
    await _storage.saveGoldTypes(_goldTypes);
    notifyListeners();
  }

  Future<void> updateGoldType(GoldType type) async {
    final index = _goldTypes.indexWhere((t) => t.id == type.id);
    if (index != -1) {
      _goldTypes[index] = type;
      await _storage.saveGoldTypes(_goldTypes);
      notifyListeners();
    }
  }

  // --- Goal Operations ---
  Future<void> updateGoal(GoldGoal goal) async {
    _goal = goal;
    await _storage.saveGoal(goal);
    notifyListeners();
  }

  // --- Backup / Restore / Reset ---
  String exportBackupJson() => _storage.exportBackupJson();

  Future<bool> importBackupJson(String jsonString) async {
    final ok = await _storage.importBackupJson(jsonString);
    if (ok) {
      _loadData();
    }
    return ok;
  }

  String exportCsv() => _storage.exportTransactionsCsv();

  Future<void> clearAllData() async {
    await _storage.clearAll();
    _loadData();
  }
}
