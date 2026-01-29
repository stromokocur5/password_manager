import 'package:hive/hive.dart';

part 'password_entry_model.g.dart';

/// Hive model for custom fields.
@HiveType(typeId: 1)
class CustomFieldModel extends HiveObject {
  @HiveField(0)
  late String id;

  @HiveField(1)
  late String name;

  @HiveField(2)
  late String encryptedValue;

  @HiveField(3)
  late bool isHidden;

  CustomFieldModel();

  CustomFieldModel.create({
    required this.id,
    required this.name,
    required this.encryptedValue,
    this.isHidden = false,
  });
}

/// Hive model for password entries.
@HiveType(typeId: 0)
class PasswordEntryModel extends HiveObject {
  @HiveField(0)
  late String id;

  @HiveField(1)
  late String name;

  @HiveField(2)
  String? username;

  @HiveField(3)
  String? encryptedPassword;

  @HiveField(4)
  String? uri;

  @HiveField(5)
  String? encryptedNotes;

  @HiveField(6)
  String? categoryId;

  @HiveField(7)
  late bool isFavorite;

  @HiveField(8)
  late DateTime createdAt;

  @HiveField(9)
  late DateTime updatedAt;

  @HiveField(10)
  late List<CustomFieldModel> customFields;

  PasswordEntryModel();

  PasswordEntryModel.create({
    required this.id,
    required this.name,
    this.username,
    this.encryptedPassword,
    this.uri,
    this.encryptedNotes,
    this.categoryId,
    this.isFavorite = false,
    required this.createdAt,
    required this.updatedAt,
    List<CustomFieldModel>? customFields,
  }) : customFields = customFields ?? [];
}
