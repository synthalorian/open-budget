// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'settings.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class AppSettingsAdapter extends TypeAdapter<AppSettings> {
  @override
  final int typeId = 11;

  @override
  AppSettings read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return AppSettings(
      enableCollisionAlerts: fields[0] as bool,
      enableSystemCriticalAlerts: fields[1] as bool,
      enableVelocityWarnings: fields[2] as bool,
      currencyCode: fields[3] as String,
      biometricEnabled: fields[4] as bool,
      themeName: fields[5] as String,
    );
  }

  @override
  void write(BinaryWriter writer, AppSettings obj) {
    writer
      ..writeByte(6)
      ..writeByte(0)
      ..write(obj.enableCollisionAlerts)
      ..writeByte(1)
      ..write(obj.enableSystemCriticalAlerts)
      ..writeByte(2)
      ..write(obj.enableVelocityWarnings)
      ..writeByte(3)
      ..write(obj.currencyCode)
      ..writeByte(4)
      ..write(obj.biometricEnabled)
      ..writeByte(5)
      ..write(obj.themeName);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AppSettingsAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
