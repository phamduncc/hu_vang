class GoldType {
  final String id;
  final String name;
  final double purity; // Ví dụ: 99.99 (9999), 75.0 (18K)
  final String unit; // Mặc định "chỉ"
  final int colorValue; // Màu biểu trưng
  final bool isCustom;

  const GoldType({
    required this.id,
    required this.name,
    required this.purity,
    this.unit = 'chỉ',
    this.colorValue = 0xFFD4AF37,
    this.isCustom = false,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'purity': purity,
        'unit': unit,
        'colorValue': colorValue,
        'isCustom': isCustom,
      };

  factory GoldType.fromJson(Map<String, dynamic> json) {
    return GoldType(
      id: json['id'] as String,
      name: json['name'] as String,
      purity: (json['purity'] as num).toDouble(),
      unit: json['unit'] as String? ?? 'chỉ',
      colorValue: json['colorValue'] as int? ?? 0xFFD4AF37,
      isCustom: json['isCustom'] as bool? ?? false,
    );
  }

  static List<GoldType> get defaultTypes => const [
        GoldType(
          id: 'nhan_9999',
          name: 'Vàng nhẫn 9999',
          purity: 99.99,
          colorValue: 0xFFFFD700,
        ),
        GoldType(
          id: 'sjc_mieng',
          name: 'Vàng miếng SJC',
          purity: 99.99,
          colorValue: 0xFFE6C343,
        ),
        GoldType(
          id: 'vang_24k',
          name: 'Vàng 24K',
          purity: 99.9,
          colorValue: 0xFFF3C64F,
        ),
        GoldType(
          id: 'vang_18k',
          name: 'Vàng 18K',
          purity: 75.0,
          colorValue: 0xFFDEB887,
        ),
        GoldType(
          id: 'vang_trang_suc',
          name: 'Vàng trang sức',
          purity: 68.0,
          colorValue: 0xFFE8B298,
        ),
        GoldType(
          id: 'vang_khac',
          name: 'Vàng khác',
          purity: 58.5,
          colorValue: 0xFFC0A080,
        ),
      ];
}
