// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'settings.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class AppSettingsAdapter extends TypeAdapter<AppSettings> {
  @override
  final int typeId = 10;

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
      currencySymbol: fields[3] as String,
    );
  }

  @override
  void write(BinaryWriter writer, AppSettings obj) {
    writer
      ..writeByte(4)
      ..writeByte(0)
      ..write(obj.enableCollisionAlerts)
      ..writeByte(1)
      ..write(obj.enableSystemCriticalAlerts)
      ..writeByte(2)
      ..write(obj.enableVelocityWarnings)
      ..writeByte(3)
      ..write(obj.currencySymbol);
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
