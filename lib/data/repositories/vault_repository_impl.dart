import 'dart:typed_data';

import '../../core/encryption/encryption.dart';
import '../../domain/entities/password_entry.dart';
import '../../domain/repositories/vault_repository.dart';
import '../datasources/local_datasource.dart';
import '../models/password_entry_model.dart';

/// Implementation of [VaultRepository] with local encryption.
class VaultRepositoryImpl implements VaultRepository {
  final LocalDataSource _localDataSource;
  final EncryptionService _encryptionService;

  /// Function to get the current encryption key.
  final Uint8List? Function() _getKey;

  VaultRepositoryImpl({
    required LocalDataSource localDataSource,
    required EncryptionService encryptionService,
    required Uint8List? Function() getKey,
  }) : _localDataSource = localDataSource,
       _encryptionService = encryptionService,
       _getKey = getKey;

  @override
  Future<List<PasswordEntry>> getAllEntries() async {
    final models = _localDataSource.getAllEntries();
    return models.map(_modelToEntity).toList();
  }

  @override
  Future<PasswordEntry?> getEntryById(String id) async {
    final model = _localDataSource.getEntryById(id);
    if (model == null) return null;
    return _modelToEntity(model);
  }

  @override
  Future<List<PasswordEntry>> searchEntries(String query) async {
    final lowerQuery = query.toLowerCase();
    final allEntries = await getAllEntries();

    return allEntries.where((entry) {
      return entry.name.toLowerCase().contains(lowerQuery) ||
          (entry.username?.toLowerCase().contains(lowerQuery) ?? false) ||
          (entry.uri?.toLowerCase().contains(lowerQuery) ?? false);
    }).toList();
  }

  @override
  Future<List<PasswordEntry>> getEntriesByCategory(String categoryId) async {
    final allEntries = await getAllEntries();
    return allEntries.where((e) => e.categoryId == categoryId).toList();
  }

  @override
  Future<List<PasswordEntry>> getFavoriteEntries() async {
    final allEntries = await getAllEntries();
    return allEntries.where((e) => e.isFavorite).toList();
  }

  @override
  Future<void> createEntry(PasswordEntry entry) async {
    final model = _entityToModel(entry);
    await _localDataSource.saveEntry(model);
  }

  @override
  Future<void> updateEntry(PasswordEntry entry) async {
    final model = _entityToModel(entry);
    await _localDataSource.saveEntry(model);
  }

  @override
  Future<void> deleteEntry(String id) async {
    await _localDataSource.deleteEntry(id);
  }

  @override
  Future<List<PasswordEntry>> exportAllEntries() async {
    return getAllEntries();
  }

  @override
  Future<void> importEntries(List<PasswordEntry> entries) async {
    for (final entry in entries) {
      await createEntry(entry);
    }
  }

  // ===== Private Helpers =====

  /// Converts domain entity to data model (encrypts sensitive fields).
  PasswordEntryModel _entityToModel(PasswordEntry entry) {
    final key = _getKey();
    if (key == null) {
      throw StateError('Vault is locked');
    }

    String? encryptedPassword;
    if (entry.password != null) {
      encryptedPassword = _encryptionService.encryptString(
        entry.password!,
        key,
      );
    }

    String? encryptedNotes;
    if (entry.notes != null) {
      encryptedNotes = _encryptionService.encryptString(entry.notes!, key);
    }

    final customFields = entry.customFields.map((f) {
      return CustomFieldModel.create(
        id: f.id,
        name: f.name,
        encryptedValue: _encryptionService.encryptString(f.value, key),
        isHidden: f.isHidden,
      );
    }).toList();

    return PasswordEntryModel.create(
      id: entry.id,
      name: entry.name,
      username: entry.username,
      encryptedPassword: encryptedPassword,
      uri: entry.uri,
      encryptedNotes: encryptedNotes,
      categoryId: entry.categoryId,
      isFavorite: entry.isFavorite,
      createdAt: entry.createdAt,
      updatedAt: entry.updatedAt,
      customFields: customFields,
    );
  }

  /// Converts data model to domain entity (decrypts sensitive fields).
  PasswordEntry _modelToEntity(PasswordEntryModel model) {
    final key = _getKey();
    if (key == null) {
      throw StateError('Vault is locked');
    }

    String? password;
    if (model.encryptedPassword != null) {
      password = _encryptionService.decryptString(
        model.encryptedPassword!,
        key,
      );
    }

    String? notes;
    if (model.encryptedNotes != null) {
      notes = _encryptionService.decryptString(model.encryptedNotes!, key);
    }

    final customFields = model.customFields.map((f) {
      return CustomField(
        id: f.id,
        name: f.name,
        value: _encryptionService.decryptString(f.encryptedValue, key),
        isHidden: f.isHidden,
      );
    }).toList();

    return PasswordEntry(
      id: model.id,
      name: model.name,
      username: model.username,
      password: password,
      uri: model.uri,
      notes: notes,
      categoryId: model.categoryId,
      isFavorite: model.isFavorite,
      createdAt: model.createdAt,
      updatedAt: model.updatedAt,
      customFields: customFields,
    );
  }
}
