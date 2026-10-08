class GoldGoal {
  final String id;
  final String name; // Tên hũ / mục tiêu ví dụ "Hũ Vàng Tích Lũy", "Mục tiêu 1 Cây Vàng"
  final double targetQuantity; // Số chỉ vàng mục tiêu
  final DateTime? targetDate; // Hạn chót nếu có
  final double monthlyTargetQuantity; // Dự kiến mua mỗi tháng (tính theo chỉ)
  final String? goldTypeId; // null = tổng tất cả vàng

  const GoldGoal({
    required this.id,
    required this.name,
    required this.targetQuantity,
    this.targetDate,
    this.monthlyTargetQuantity = 1.0,
    this.goldTypeId,
  });

  /// Đơn vị lượng (1 lượng = 10 chỉ)
  double get targetQuantityInLuong => targetQuantity / 10.0;
  double get monthlyTargetInLuong => monthlyTargetQuantity / 10.0;

  GoldGoal copyWith({
    String? id,
    String? name,
    double? targetQuantity,
    DateTime? targetDate,
    double? monthlyTargetQuantity,
    String? goldTypeId,
  }) {
    return GoldGoal(
      id: id ?? this.id,
      name: name ?? this.name,
      targetQuantity: targetQuantity ?? this.targetQuantity,
      targetDate: targetDate ?? this.targetDate,
      monthlyTargetQuantity:
          monthlyTargetQuantity ?? this.monthlyTargetQuantity,
      goldTypeId: goldTypeId ?? this.goldTypeId,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'targetQuantity': targetQuantity,
        'targetDate': targetDate?.toIso8601String(),
        'monthlyTargetQuantity': monthlyTargetQuantity,
        'goldTypeId': goldTypeId,
      };

  factory GoldGoal.fromJson(Map<String, dynamic> json) {
    return GoldGoal(
      id: json['id'] as String,
      name: json['name'] as String,
      targetQuantity: (json['targetQuantity'] as num).toDouble(),
      targetDate: json['targetDate'] != null
          ? DateTime.parse(json['targetDate'] as String)
          : null,
      monthlyTargetQuantity:
          (json['monthlyTargetQuantity'] as num?)?.toDouble() ?? 1.0,
      goldTypeId: json['goldTypeId'] as String?,
    );
  }

  static GoldGoal get defaultGoal => const GoldGoal(
        id: 'default_goal',
        name: 'Hũ Vàng Tích Lũy',
        targetQuantity: 20.0, // 20 chỉ = 2 lượng
        monthlyTargetQuantity: 2.0, // 2 chỉ / tháng
      );
}
