import 'package:equatable/equatable.dart';
import 'package:hive/hive.dart';

part 'settings.g.dart';

@HiveType(typeId: 11)
class AppSettings extends Equatable {
  @HiveField(0)
  final bool enableCollisionAlerts;
  
  @HiveField(1)
  final bool enableSystemCriticalAlerts;
  
  @HiveField(2)
  final bool enableVelocityWarnings;
  
  @HiveField(3)
  final String currencyCode;

  @HiveField(4)
  final bool biometricEnabled;

  @HiveField(5)
  final String themeName;

  const AppSettings({
    this.enableCollisionAlerts = true,
    this.enableSystemCriticalAlerts = true,
    this.enableVelocityWarnings = true,
    this.currencyCode = 'USD',
    this.biometricEnabled = false,
    this.themeName = 'synthwave',
  });

  String get currencySymbol {
    const currencySymbols = {
      'USD': '\$',
      'EUR': '€',
      'GBP': '£',
      'JPY': '¥',
      'CAD': 'C\$',
      'AUD': 'A\$',
      'CHF': 'CHF',
      'CNY': '¥',
      'INR': '₹',
      'MXN': 'MX\$',
      'BRL': 'R\$',
      'KRW': '₩',
      'SGD': 'S\$',
      'HKD': 'HK\$',
      'NOK': 'kr',
      'SEK': 'kr',
      'DKK': 'kr',
      'NZD': 'NZ\$',
      'ZAR': 'R',
      'RUB': '₽',
      'TRY': '₺',
      'PLN': 'zł',
      'THB': '฿',
      'IDR': 'Rp',
      'MYR': 'RM',
      'PHP': '₱',
      'CZK': 'Kč',
      'ILS': '₪',
      'CLP': 'CLP\$',
      'PKR': '₨',
      'EGP': 'E£',
      'TWD': 'NT\$',
      'AED': 'د.إ',
      'SAR': '﷼',
      'VND': '₫',
    };
    return currencySymbols[currencyCode] ?? '\$';
  }

  AppSettings copyWith({
    bool? enableCollisionAlerts,
    bool? enableSystemCriticalAlerts,
    bool? enableVelocityWarnings,
    String? currencyCode,
    bool? biometricEnabled,
    String? themeName,
  }) {
    return AppSettings(
      enableCollisionAlerts: enableCollisionAlerts ?? this.enableCollisionAlerts,
      enableSystemCriticalAlerts: enableSystemCriticalAlerts ?? this.enableSystemCriticalAlerts,
      enableVelocityWarnings: enableVelocityWarnings ?? this.enableVelocityWarnings,
      currencyCode: currencyCode ?? this.currencyCode,
      biometricEnabled: biometricEnabled ?? this.biometricEnabled,
      themeName: themeName ?? this.themeName,
    );
  }

  @override
  List<Object?> get props => [
        enableCollisionAlerts,
        enableSystemCriticalAlerts,
        enableVelocityWarnings,
        currencyCode,
        biometricEnabled,
        themeName,
      ];
}
