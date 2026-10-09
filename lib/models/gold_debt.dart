enum DebtDirection {
  iOwe('Tôi nợ người khác (Phải trả)', 'i_owe'),
  theyOwe('Người khác nợ tôi (Phải thu)', 'they_owe');

  final String label;
  final String key;
  const DebtDirection(this.label, this.key);

  static DebtDirection fromKey(String key) {
    return DebtDirection.values.firstWhere(
      (e) => e.key == key || e.name == key,
      orElse: () => DebtDirection.iOwe,
    );
  }
}

enum DebtAssetType {
  gold('Nợ bằng Vàng', 'gold'),
  money('Nợ bằng Tiền', 'money');

  final String label;
  final String key;
  const DebtAssetType(this.label, this.key);

  static DebtAssetType fromKey(String key) {
    return DebtAssetType.values.firstWhere(
      (e) => e.key == key || e.name == key,
      orElse: () => DebtAssetType.gold,
    );
  }
}

class DebtPayment {
  final String id;
  final double amount; // Số chỉ vàng hoặc số tiền VNĐ đã trả
  final DateTime date;
  final String? note;

  const DebtPayment({
    required this.id,
    required this.amount,
    required this.date,
    this.note,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'amount': amount,
        'date': date.toIso8601String(),
        'note': note,
      };

  factory DebtPayment.fromJson(Map<String, dynamic> json) {
    return DebtPayment(
      id: json['id'] as String,
      amount: (json['amount'] as num).toDouble(),
      date: DateTime.parse(json['date'] as String),
      note: json['note'] as String?,
    );
  }
}

class GoldDebt {
  final String id;
  final String personName; // Tên người nợ / chủ nợ
  final String? phoneNumber;
  final DebtDirection direction; // iOwe (Tôi nợ) hoặc theyOwe (Người ta nợ tôi)
  final DebtAssetType assetType; // gold (vàng) hoặc money (tiền)
  final String? goldTypeId; // Loại vàng nếu nợ vàng (ví dụ 'nhan_9999', 'sjc_mieng')
  final double originalAmount; // Tổng số chỉ vàng nợ hoặc tổng số tiền VNĐ nợ ban đầu
  final double? priceAtBorrow; // Giá vàng/chỉ tại thời điểm vay (để tính chênh lệch thị trường)
  final DateTime startDate;
  final DateTime? dueDate; // Hạn chót trả nợ nếu có
  final String? note;
  final List<DebtPayment> payments; // Lịch sử các lần trả nợ
  final bool isSettled; // Đã hoàn thành trả xong hết chưa

  const GoldDebt({
    required this.id,
    required this.personName,
    this.phoneNumber,
    required this.direction,
    required this.assetType,
    this.goldTypeId,
    required this.originalAmount,
    this.priceAtBorrow,
    required this.startDate,
    this.dueDate,
    this.note,
    this.payments = const [],
    this.isSettled = false,
  });

  /// Tổng số lượng đã trả
  double get totalPaid => payments.fold(0.0, (sum, p) => sum + p.amount);

  /// Số lượng còn lại phải trả/thu
  double get remainingAmount {
    final rem = originalAmount - totalPaid;
    return rem > 0 ? rem : 0.0;
  }

  /// Tỷ lệ phần trăm đã trả
  double get paidPercentage {
    if (originalAmount <= 0) return 100.0;
    return ((totalPaid / originalAmount) * 100.0).clamp(0.0, 100.0);
  }

  /// Kiểm tra có đang quá hạn không
  bool get isOverdue {
    if (isSettled || remainingAmount <= 0.0001 || dueDate == null) return false;
    return DateTime.now().isAfter(dueDate!);
  }

  GoldDebt copyWith({
    String? id,
    String? personName,
    String? phoneNumber,
    DebtDirection? direction,
    DebtAssetType? assetType,
    String? goldTypeId,
    double? originalAmount,
    double? priceAtBorrow,
    DateTime? startDate,
    DateTime? dueDate,
    String? note,
    List<DebtPayment>? payments,
    bool? isSettled,
  }) {
    return GoldDebt(
      id: id ?? this.id,
      personName: personName ?? this.personName,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      direction: direction ?? this.direction,
      assetType: assetType ?? this.assetType,
      goldTypeId: goldTypeId ?? this.goldTypeId,
      originalAmount: originalAmount ?? this.originalAmount,
      priceAtBorrow: priceAtBorrow ?? this.priceAtBorrow,
      startDate: startDate ?? this.startDate,
      dueDate: dueDate ?? this.dueDate,
      note: note ?? this.note,
      payments: payments ?? this.payments,
      isSettled: isSettled ?? this.isSettled,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'personName': personName,
        'phoneNumber': phoneNumber,
        'direction': direction.key,
        'assetType': assetType.key,
        'goldTypeId': goldTypeId,
        'originalAmount': originalAmount,
        'priceAtBorrow': priceAtBorrow,
        'startDate': startDate.toIso8601String(),
        'dueDate': dueDate?.toIso8601String(),
        'note': note,
        'payments': payments.map((e) => e.toJson()).toList(),
        'isSettled': isSettled,
      };

  factory GoldDebt.fromJson(Map<String, dynamic> json) {
    return GoldDebt(
      id: json['id'] as String,
      personName: json['personName'] as String,
      phoneNumber: json['phoneNumber'] as String?,
      direction: DebtDirection.fromKey(json['direction'] as String),
      assetType: DebtAssetType.fromKey(json['assetType'] as String),
      goldTypeId: json['goldTypeId'] as String?,
      originalAmount: (json['originalAmount'] as num).toDouble(),
      priceAtBorrow: (json['priceAtBorrow'] as num?)?.toDouble(),
      startDate: DateTime.parse(json['startDate'] as String),
      dueDate: json['dueDate'] != null ? DateTime.parse(json['dueDate'] as String) : null,
      note: json['note'] as String?,
      payments: (json['payments'] as List?)
              ?.map((e) => DebtPayment.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      isSettled: json['isSettled'] as bool? ?? false,
    );
  }
}
