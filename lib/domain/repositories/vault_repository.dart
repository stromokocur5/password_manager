import '../entities/password_entry.dart';

/// Abstract repository for vault operations.
abstract class VaultRepository {
  /// Gets all password entries.
  Future<List<PasswordEntry>> getAllEntries();

  /// Gets a single entry by ID.
  Future<PasswordEntry?> getEntryById(String id);

  /// Searches entries by query (name, username, uri).
  Future<List<PasswordEntry>> searchEntries(String query);

  /// Gets entries by category.
  Future<List<PasswordEntry>> getEntriesByCategory(String categoryId);

  /// Gets favorite entries.
  Future<List<PasswordEntry>> getFavoriteEntries();

  /// Creates a new entry.
  Future<void> createEntry(PasswordEntry entry);

  /// Updates an existing entry.
  Future<void> updateEntry(PasswordEntry entry);

  /// Deletes an entry by ID.
  Future<void> deleteEntry(String id);

  /// Exports all entries (for backup).
  Future<List<PasswordEntry>> exportAllEntries();

  /// Imports entries (from backup).
  Future<void> importEntries(List<PasswordEntry> entries);
}
