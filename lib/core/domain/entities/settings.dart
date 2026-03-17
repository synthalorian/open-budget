import 'package:equatable/equatable.dart';
import 'package:hive/hive.dart';

part 'settings.g.dart';

@HiveType(typeId: 10)
class AppSettings extends Equatable {
  @HiveField(0)
  final bool enableCollisionAlerts;
  
  @HiveField(1)
  final bool enableSystemCriticalAlerts;
  
  @HiveField(2)
  final bool enableVelocityWarnings;
  
  @HiveField(3)
  final String currencySymbol;

  const AppSettings({
    this.enableCollisionAlerts = true,
    this.enableSystemCriticalAlerts = true,
    this.enableVelocityWarnings = true,
    this.currencySymbol = '\$',
  });

  AppSettings copyWith({
    bool? enableCollisionAlerts,
    bool? enableSystemCriticalAlerts,
    bool? enableVelocityWarnings,
    String? currencySymbol,
  }) {
    return AppSettings(
      enableCollisionAlerts: enableCollisionAlerts ?? this.enableCollisionAlerts,
      enableSystemCriticalAlerts: enableSystemCriticalAlerts ?? this.enableSystemCriticalAlerts,
      enableVelocityWarnings: enableVelocityWarnings ?? this.enableVelocityWarnings,
      currencySymbol: currencySymbol ?? this.currencySymbol,
    );
  }

  @override
  List<Object?> get props => [
        enableCollisionAlerts,
        enableSystemCriticalAlerts,
        enableVelocityWarnings,
        currencySymbol,
      ];
}
