import 'package:hive_flutter/hive_flutter.dart';

import '../models/models.dart';

/// Data source for local Hive database operations.
class LocalDataSource {
  static const String _entriesBoxName = 'password_entries';
  static const String _categoriesBoxName = 'categories';
  static const String _settingsBoxName = 'user_settings';
  static const String _settingsKey = 'settings';

  Box<PasswordEntryModel>? _entriesBox;
  Box<CategoryModel>? _categoriesBox;
  Box<UserSettingsModel>? _settingsBox;

  /// Initializes Hive and opens all boxes.
  Future<void> initialize() async {
    await Hive.initFlutter();

    // Register adapters
    if (!Hive.isAdapterRegistered(0)) {
      Hive.registerAdapter(PasswordEntryModelAdapter());
    }
    if (!Hive.isAdapterRegistered(1)) {
      Hive.registerAdapter(CustomFieldModelAdapter());
    }
    if (!Hive.isAdapterRegistered(2)) {
      Hive.registerAdapter(CategoryModelAdapter());
    }
    if (!Hive.isAdapterRegistered(3)) {
      Hive.registerAdapter(UserSettingsModelAdapter());
    }

    // Open boxes
    _entriesBox = await Hive.openBox<PasswordEntryModel>(_entriesBoxName);
    _categoriesBox = await Hive.openBox<CategoryModel>(_categoriesBoxName);
    _settingsBox = await Hive.openBox<UserSettingsModel>(_settingsBoxName);
  }

  // ===== Password Entries =====

  /// Gets all password entries.
  List<PasswordEntryModel> getAllEntries() {
    return _entriesBox?.values.toList() ?? [];
  }

  /// Gets an entry by ID.
  PasswordEntryModel? getEntryById(String id) {
    return _entriesBox?.get(id);
  }

  /// Saves a password entry.
  Future<void> saveEntry(PasswordEntryModel entry) async {
    await _entriesBox?.put(entry.id, entry);
  }

  /// Deletes a password entry.
  Future<void> deleteEntry(String id) async {
    await _entriesBox?.delete(id);
  }

  /// Clears all entries.
  Future<void> clearAllEntries() async {
    await _entriesBox?.clear();
  }

  // ===== Categories =====

  /// Gets all categories.
  List<CategoryModel> getAllCategories() {
    return _categoriesBox?.values.toList() ?? [];
  }

  /// Saves a category.
  Future<void> saveCategory(CategoryModel category) async {
    await _categoriesBox?.put(category.id, category);
  }

  /// Deletes a category.
  Future<void> deleteCategory(String id) async {
    await _categoriesBox?.delete(id);
  }

  // ===== User Settings =====

  /// Gets user settings.
  UserSettingsModel getSettings() {
    return _settingsBox?.get(_settingsKey) ?? UserSettingsModel.defaults();
  }

  /// Saves user settings.
  Future<void> saveSettings(UserSettingsModel settings) async {
    await _settingsBox?.put(_settingsKey, settings);
  }

  // ===== Lifecycle =====

  /// Closes all boxes.
  Future<void> close() async {
    await _entriesBox?.close();
    await _categoriesBox?.close();
    await _settingsBox?.close();
  }
}
