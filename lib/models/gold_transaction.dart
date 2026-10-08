enum TransactionType {
  buy('Mua vào', 'mua'),
  sell('Bán ra', 'ban'),
  adjustment('Điều chỉnh', 'dieu_chinh'),
  giftReceived('Được tặng/nhận', 'nhan_tang'),
  giftGiven('Cho/tặng đi', 'cho_tang');

  final String label;
  final String key;
  const TransactionType(this.label, this.key);

  static TransactionType fromKey(String key) {
    return TransactionType.values.firstWhere(
      (e) => e.key == key || e.name == key,
      orElse: () => TransactionType.buy,
    );
  }
}

class GoldTransaction {
  final String id;
  final String goldTypeId;
  final TransactionType type;
  /// Lượng vàng tính theo chuẩn "chỉ" (1 lượng = 10 chỉ)
  final double quantity;
  /// Đơn vị lúc người dùng nhập ('chỉ', 'lượng', 'phân')
  final String inputUnit;
  /// Đơn giá trên 1 chỉ (VNĐ/chỉ)
  final double pricePerUnit;
  /// Tiền công / tiền phí phụ nếu có (VNĐ)
  final double fee;
  /// Tổng số tiền thực tế giao dịch (VNĐ)
  final double totalAmount;
  /// Ngày giờ giao dịch
  final DateTime transactionDate;
  /// Cửa hàng / Tiệm vàng
  final String? shop;
  /// Ghi chú
  final String? note;
  /// Giá vốn được trích khi bán (để tính lãi đã chốt)
  final double? costBasisAtSale;
  /// Lãi/lỗ chốt được trong lần bán (totalAmount - costBasisAtSale)
  final double? realizedProfit;

  const GoldTransaction({
    required this.id,
    required this.goldTypeId,
    required this.type,
    required this.quantity,
    this.inputUnit = 'chỉ',
    required this.pricePerUnit,
    this.fee = 0.0,
    required this.totalAmount,
    required this.transactionDate,
    this.shop,
    this.note,
    this.costBasisAtSale,
    this.realizedProfit,
  });

  /// Chuyển đổi hiển thị sang lượng (1 lượng = 10 chỉ)
  double get quantityInLuong => quantity / 10.0;

  GoldTransaction copyWith({
    String? id,
    String? goldTypeId,
    TransactionType? type,
    double? quantity,
    String? inputUnit,
    double? pricePerUnit,
    double? fee,
    double? totalAmount,
    DateTime? transactionDate,
    String? shop,
    String? note,
    double? costBasisAtSale,
    double? realizedProfit,
  }) {
    return GoldTransaction(
      id: id ?? this.id,
      goldTypeId: goldTypeId ?? this.goldTypeId,
      type: type ?? this.type,
      quantity: quantity ?? this.quantity,
      inputUnit: inputUnit ?? this.inputUnit,
      pricePerUnit: pricePerUnit ?? this.pricePerUnit,
      fee: fee ?? this.fee,
      totalAmount: totalAmount ?? this.totalAmount,
      transactionDate: transactionDate ?? this.transactionDate,
      shop: shop ?? this.shop,
      note: note ?? this.note,
      costBasisAtSale: costBasisAtSale ?? this.costBasisAtSale,
      realizedProfit: realizedProfit ?? this.realizedProfit,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'goldTypeId': goldTypeId,
        'type': type.key,
        'quantity': quantity,
        'inputUnit': inputUnit,
        'pricePerUnit': pricePerUnit,
        'fee': fee,
        'totalAmount': totalAmount,
        'transactionDate': transactionDate.toIso8601String(),
        'shop': shop,
        'note': note,
        'costBasisAtSale': costBasisAtSale,
        'realizedProfit': realizedProfit,
      };

  factory GoldTransaction.fromJson(Map<String, dynamic> json) {
    return GoldTransaction(
      id: json['id'] as String,
      goldTypeId: json['goldTypeId'] as String,
      type: TransactionType.fromKey(json['type'] as String),
      quantity: (json['quantity'] as num).toDouble(),
      inputUnit: json['inputUnit'] as String? ?? 'chỉ',
      pricePerUnit: (json['pricePerUnit'] as num).toDouble(),
      fee: (json['fee'] as num?)?.toDouble() ?? 0.0,
      totalAmount: (json['totalAmount'] as num).toDouble(),
      transactionDate: DateTime.parse(json['transactionDate'] as String),
      shop: json['shop'] as String?,
      note: json['note'] as String?,
      costBasisAtSale: (json['costBasisAtSale'] as num?)?.toDouble(),
      realizedProfit: (json['realizedProfit'] as num?)?.toDouble(),
    );
  }
}
