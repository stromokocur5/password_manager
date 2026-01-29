import 'package:equatable/equatable.dart';

/// A custom field attached to a password entry.
class CustomField extends Equatable {
  /// Unique identifier for this field.
  final String id;

  /// Display name of the field.
  final String name;

  /// Value of the field (encrypted at rest).
  final String value;

  /// Whether this field contains sensitive data.
  final bool isHidden;

  const CustomField({
    required this.id,
    required this.name,
    required this.value,
    this.isHidden = false,
  });

  CustomField copyWith({
    String? id,
    String? name,
    String? value,
    bool? isHidden,
  }) {
    return CustomField(
      id: id ?? this.id,
      name: name ?? this.name,
      value: value ?? this.value,
      isHidden: isHidden ?? this.isHidden,
    );
  }

  @override
  List<Object?> get props => [id, name, value, isHidden];
}

/// Represents a password entry in the vault.
class PasswordEntry extends Equatable {
  /// Unique identifier.
  final String id;

  /// Display name / title.
  final String name;

  /// Username or email.
  final String? username;

  /// The password (stored encrypted at rest).
  final String? password;

  /// Website or application URI.
  final String? uri;

  /// Additional notes.
  final String? notes;

  /// Category or folder ID.
  final String? categoryId;

  /// Whether this is a favorite entry.
  final bool isFavorite;

  /// Creation timestamp.
  final DateTime createdAt;

  /// Last modification timestamp.
  final DateTime updatedAt;

  /// Custom fields for additional data.
  final List<CustomField> customFields;

  const PasswordEntry({
    required this.id,
    required this.name,
    this.username,
    this.password,
    this.uri,
    this.notes,
    this.categoryId,
    this.isFavorite = false,
    required this.createdAt,
    required this.updatedAt,
    this.customFields = const [],
  });

  /// Creates a new entry with default timestamps.
  factory PasswordEntry.create({
    required String id,
    required String name,
    String? username,
    String? password,
    String? uri,
    String? notes,
    String? categoryId,
    bool isFavorite = false,
    List<CustomField>? customFields,
  }) {
    final now = DateTime.now();
    return PasswordEntry(
      id: id,
      name: name,
      username: username,
      password: password,
      uri: uri,
      notes: notes,
      categoryId: categoryId,
      isFavorite: isFavorite,
      createdAt: now,
      updatedAt: now,
      customFields: customFields ?? [],
    );
  }

  PasswordEntry copyWith({
    String? id,
    String? name,
    String? username,
    String? password,
    String? uri,
    String? notes,
    String? categoryId,
    bool? isFavorite,
    DateTime? createdAt,
    DateTime? updatedAt,
    List<CustomField>? customFields,
  }) {
    return PasswordEntry(
      id: id ?? this.id,
      name: name ?? this.name,
      username: username ?? this.username,
      password: password ?? this.password,
      uri: uri ?? this.uri,
      notes: notes ?? this.notes,
      categoryId: categoryId ?? this.categoryId,
      isFavorite: isFavorite ?? this.isFavorite,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? DateTime.now(),
      customFields: customFields ?? this.customFields,
    );
  }

  @override
  List<Object?> get props => [
    id,
    name,
    username,
    password,
    uri,
    notes,
    categoryId,
    isFavorite,
    createdAt,
    updatedAt,
    customFields,
  ];
}
