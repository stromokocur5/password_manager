// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'password_entry_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class CustomFieldModelAdapter extends TypeAdapter<CustomFieldModel> {
  @override
  final int typeId = 1;

  @override
  CustomFieldModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return CustomFieldModel()
      ..id = fields[0] as String
      ..name = fields[1] as String
      ..encryptedValue = fields[2] as String
      ..isHidden = fields[3] as bool;
  }

  @override
  void write(BinaryWriter writer, CustomFieldModel obj) {
    writer
      ..writeByte(4)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.encryptedValue)
      ..writeByte(3)
      ..write(obj.isHidden);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CustomFieldModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class PasswordEntryModelAdapter extends TypeAdapter<PasswordEntryModel> {
  @override
  final int typeId = 0;

  @override
  PasswordEntryModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return PasswordEntryModel()
      ..id = fields[0] as String
      ..name = fields[1] as String
      ..username = fields[2] as String?
      ..encryptedPassword = fields[3] as String?
      ..uri = fields[4] as String?
      ..encryptedNotes = fields[5] as String?
      ..categoryId = fields[6] as String?
      ..isFavorite = fields[7] as bool
      ..createdAt = fields[8] as DateTime
      ..updatedAt = fields[9] as DateTime
      ..customFields = (fields[10] as List).cast<CustomFieldModel>();
  }

  @override
  void write(BinaryWriter writer, PasswordEntryModel obj) {
    writer
      ..writeByte(11)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.username)
      ..writeByte(3)
      ..write(obj.encryptedPassword)
      ..writeByte(4)
      ..write(obj.uri)
      ..writeByte(5)
      ..write(obj.encryptedNotes)
      ..writeByte(6)
      ..write(obj.categoryId)
      ..writeByte(7)
      ..write(obj.isFavorite)
      ..writeByte(8)
      ..write(obj.createdAt)
      ..writeByte(9)
      ..write(obj.updatedAt)
      ..writeByte(10)
      ..write(obj.customFields);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PasswordEntryModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
