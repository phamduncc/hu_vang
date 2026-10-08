class AppSettings {
  final bool isAmountHidden;
  final bool isPinEnabled;
  final String pinCode;
  final String preferredUnit; // 'chi' hoặc 'luong'
  final bool useMarketSellPrice; // true = dùng giá tiệm bán ra, false = dùng giá tiệm thu mua vào
  final String themeMode; // 'dark' | 'light'

  const AppSettings({
    this.isAmountHidden = false,
    this.isPinEnabled = false,
    this.pinCode = '1234',
    this.preferredUnit = 'chi',
    this.useMarketSellPrice = true,
    this.themeMode = 'dark',
  });

  AppSettings copyWith({
    bool? isAmountHidden,
    bool? isPinEnabled,
    String? pinCode,
    String? preferredUnit,
    bool? useMarketSellPrice,
    String? themeMode,
  }) {
    return AppSettings(
      isAmountHidden: isAmountHidden ?? this.isAmountHidden,
      isPinEnabled: isPinEnabled ?? this.isPinEnabled,
      pinCode: pinCode ?? this.pinCode,
      preferredUnit: preferredUnit ?? this.preferredUnit,
      useMarketSellPrice: useMarketSellPrice ?? this.useMarketSellPrice,
      themeMode: themeMode ?? this.themeMode,
    );
  }

  Map<String, dynamic> toJson() => {
        'isAmountHidden': isAmountHidden,
        'isPinEnabled': isPinEnabled,
        'pinCode': pinCode,
        'preferredUnit': preferredUnit,
        'useMarketSellPrice': useMarketSellPrice,
        'themeMode': themeMode,
      };

  factory AppSettings.fromJson(Map<String, dynamic> json) {
    return AppSettings(
      isAmountHidden: json['isAmountHidden'] as bool? ?? false,
      isPinEnabled: json['isPinEnabled'] as bool? ?? false,
      pinCode: json['pinCode'] as String? ?? '1234',
      preferredUnit: json['preferredUnit'] as String? ?? 'chi',
      useMarketSellPrice: json['useMarketSellPrice'] as bool? ?? true,
      themeMode: json['themeMode'] as String? ?? 'dark',
    );
  }
}
