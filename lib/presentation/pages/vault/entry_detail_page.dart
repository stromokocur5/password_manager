import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:uuid/uuid.dart';

import '../../../domain/entities/password_entry.dart';
import '../../blocs/vault/vault.dart';

/// Page for viewing and editing a password entry.
class EntryDetailPage extends StatefulWidget {
  final PasswordEntry? entry; // null for new entry
  final VoidCallback onSave;
  final VoidCallback onCancel;

  const EntryDetailPage({
    super.key,
    this.entry,
    required this.onSave,
    required this.onCancel,
  });

  @override
  State<EntryDetailPage> createState() => _EntryDetailPageState();
}

class _EntryDetailPageState extends State<EntryDetailPage> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _usernameController;
  late TextEditingController _passwordController;
  late TextEditingController _uriController;
  late TextEditingController _notesController;

  bool _obscurePassword = true;
  bool _isEditing = false;
  String _selectedCategory = 'login';

  bool get _isNewEntry => widget.entry == null;

  @override
  void initState() {
    super.initState();
    _isEditing = _isNewEntry;
    _nameController = TextEditingController(text: widget.entry?.name ?? '');
    _usernameController = TextEditingController(
      text: widget.entry?.username ?? '',
    );
    _passwordController = TextEditingController(
      text: widget.entry?.password ?? '',
    );
    _uriController = TextEditingController(text: widget.entry?.uri ?? '');
    _notesController = TextEditingController(text: widget.entry?.notes ?? '');
    _selectedCategory = widget.entry?.categoryId ?? 'login';
  }

  @override
  void dispose() {
    _nameController.dispose();
    _usernameController.dispose();
    _passwordController.dispose();
    _uriController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  void _onSave() {
    if (!_formKey.currentState!.validate()) return;

    final entry = PasswordEntry.create(
      id: widget.entry?.id ?? const Uuid().v4(),
      name: _nameController.text,
      username: _usernameController.text.isEmpty
          ? null
          : _usernameController.text,
      password: _passwordController.text.isEmpty
          ? null
          : _passwordController.text,
      uri: _uriController.text.isEmpty ? null : _uriController.text,
      notes: _notesController.text.isEmpty ? null : _notesController.text,
      categoryId: _selectedCategory,
      isFavorite: widget.entry?.isFavorite ?? false,
    );

    if (_isNewEntry) {
      context.read<VaultBloc>().add(VaultCreateEntry(entry));
    } else {
      context.read<VaultBloc>().add(VaultUpdateEntry(entry));
    }

    widget.onSave();
  }

  void _onDelete() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Entry'),
        content: Text(
          'Are you sure you want to delete "${widget.entry?.name}"?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              context.read<VaultBloc>().add(VaultDeleteEntry(widget.entry!.id));
              widget.onCancel();
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  void _copyToClipboard(String text, String label) {
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$label copied to clipboard'),
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          _isNewEntry
              ? 'New Entry'
              : (_isEditing ? 'Edit Entry' : widget.entry!.name),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: widget.onCancel,
        ),
        actions: [
          if (!_isNewEntry && !_isEditing)
            IconButton(
              icon: const Icon(Icons.edit),
              onPressed: () => setState(() => _isEditing = true),
            ),
          if (!_isNewEntry)
            IconButton(icon: const Icon(Icons.delete), onPressed: _onDelete),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Category selector
            if (_isEditing) ...[
              Text('Category', style: Theme.of(context).textTheme.labelLarge),
              const SizedBox(height: 8),
              SegmentedButton<String>(
                segments: const [
                  ButtonSegment(
                    value: 'login',
                    label: Text('Login'),
                    icon: Icon(Icons.person),
                  ),
                  ButtonSegment(
                    value: 'card',
                    label: Text('Card'),
                    icon: Icon(Icons.credit_card),
                  ),
                  ButtonSegment(
                    value: 'secure_note',
                    label: Text('Note'),
                    icon: Icon(Icons.note),
                  ),
                ],
                selected: {_selectedCategory},
                onSelectionChanged: (selection) {
                  setState(() => _selectedCategory = selection.first);
                },
              ),
              const SizedBox(height: 24),
            ],

            // Name field
            TextFormField(
              controller: _nameController,
              enabled: _isEditing,
              decoration: const InputDecoration(
                labelText: 'Name',
                prefixIcon: Icon(Icons.label),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter a name';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            // Username field
            TextFormField(
              controller: _usernameController,
              enabled: _isEditing,
              decoration: InputDecoration(
                labelText: 'Username / Email',
                prefixIcon: const Icon(Icons.person),
                suffixIcon: !_isEditing && _usernameController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.copy),
                        onPressed: () => _copyToClipboard(
                          _usernameController.text,
                          'Username',
                        ),
                      )
                    : null,
              ),
            ),
            const SizedBox(height: 16),

            // Password field
            TextFormField(
              controller: _passwordController,
              enabled: _isEditing,
              obscureText: _obscurePassword,
              decoration: InputDecoration(
                labelText: 'Password',
                prefixIcon: const Icon(Icons.key),
                suffixIcon: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: Icon(
                        _obscurePassword
                            ? Icons.visibility
                            : Icons.visibility_off,
                      ),
                      onPressed: () =>
                          setState(() => _obscurePassword = !_obscurePassword),
                    ),
                    if (!_isEditing && _passwordController.text.isNotEmpty)
                      IconButton(
                        icon: const Icon(Icons.copy),
                        onPressed: () => _copyToClipboard(
                          _passwordController.text,
                          'Password',
                        ),
                      ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // URI field
            TextFormField(
              controller: _uriController,
              enabled: _isEditing,
              decoration: InputDecoration(
                labelText: 'Website URL',
                prefixIcon: const Icon(Icons.link),
                suffixIcon: !_isEditing && _uriController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.copy),
                        onPressed: () =>
                            _copyToClipboard(_uriController.text, 'URL'),
                      )
                    : null,
              ),
              keyboardType: TextInputType.url,
            ),
            const SizedBox(height: 16),

            // Notes field
            TextFormField(
              controller: _notesController,
              enabled: _isEditing,
              maxLines: 4,
              decoration: const InputDecoration(
                labelText: 'Notes',
                prefixIcon: Icon(Icons.notes),
                alignLabelWithHint: true,
              ),
            ),
            const SizedBox(height: 24),

            // Save button
            if (_isEditing)
              ElevatedButton(
                onPressed: _onSave,
                child: Text(_isNewEntry ? 'Create Entry' : 'Save Changes'),
              ),
          ],
        ),
      ),
    );
  }
}
