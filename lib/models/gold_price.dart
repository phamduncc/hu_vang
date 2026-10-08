class GoldPrice {
  final String goldTypeId;
  final double buyPrice; // Giá tiệm mua vào từ khách (VNĐ/chỉ)
  final double sellPrice; // Giá tiệm bán ra cho khách (VNĐ/chỉ)
  final DateTime updatedAt;
  final String? note;

  const GoldPrice({
    required this.goldTypeId,
    required this.buyPrice,
    required this.sellPrice,
    required this.updatedAt,
    this.note,
  });

  Map<String, dynamic> toJson() => {
        'goldTypeId': goldTypeId,
        'buyPrice': buyPrice,
        'sellPrice': sellPrice,
        'updatedAt': updatedAt.toIso8601String(),
        'note': note,
      };

  factory GoldPrice.fromJson(Map<String, dynamic> json) {
    return GoldPrice(
      goldTypeId: json['goldTypeId'] as String,
      buyPrice: (json['buyPrice'] as num).toDouble(),
      sellPrice: (json['sellPrice'] as num).toDouble(),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
      note: json['note'] as String?,
    );
  }
}
