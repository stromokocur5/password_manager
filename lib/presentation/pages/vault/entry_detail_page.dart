import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:uuid/uuid.dart';

import '../../../domain/entities/password_entry.dart';
import '../../blocs/vault/vault.dart';
import '../../theme/app_theme.dart';
import '../../widgets/widgets.dart';

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
  bool _isSaving = false;

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

  void _onSave() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);
    HapticFeedback.mediumImpact();

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

    // Small delay for animation
    await Future.delayed(const Duration(milliseconds: 300));
    widget.onSave();
  }

  void _onDelete() {
    HapticFeedback.heavyImpact();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
        title: Text('Delete Entry', style: AppTypography.headline3),
        content: Text(
          'Are you sure you want to delete "${widget.entry?.name}"?',
          style: AppTypography.bodyMedium,
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
            style: TextButton.styleFrom(foregroundColor: AppColors.error),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  void _copyToClipboard(String text, String label) {
    Clipboard.setData(ClipboardData(text: text));
    HapticFeedback.lightImpact();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle, color: AppColors.accent, size: 18),
            const SizedBox(width: 12),
            Text('$label copied'),
          ],
        ),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final categoryColor = getCategoryColor(_selectedCategory);

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
            // Hero category icon
            Center(
              child: Hero(
                tag: 'entry_icon_${widget.entry?.id ?? 'new'}',
                child: Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: categoryColor.withAlpha(30),
                    borderRadius: BorderRadius.circular(4),
                    border: Border.all(color: categoryColor, width: 2),
                  ),
                  child: Icon(
                    _getCategoryIcon(),
                    color: categoryColor,
                    size: 40,
                  ),
                ),
              ),
            ).animate().scale(
              begin: const Offset(0.8, 0.8),
              duration: 400.ms,
              curve: Curves.elasticOut,
            ),
            const SizedBox(height: 24),

            // Category selector
            if (_isEditing) ...[
              Text(
                'Category',
                style: AppTypography.label.copyWith(
                  color: AppColors.textSecondaryLight,
                ),
              ),
              const SizedBox(height: 8),
              _CategorySelector(
                selected: _selectedCategory,
                onChanged: (cat) => setState(() => _selectedCategory = cat),
              ).animate().fadeIn(duration: 300.ms),
              const SizedBox(height: 24),
            ],

            // Form fields
            _buildTextField(
              controller: _nameController,
              label: 'Name',
              icon: Icons.label,
              enabled: _isEditing,
              validator: (value) =>
                  value?.isEmpty == true ? 'Please enter a name' : null,
            ),
            const SizedBox(height: 16),

            _buildTextField(
              controller: _usernameController,
              label: 'Username / Email',
              icon: Icons.person,
              enabled: _isEditing,
              showCopy: !_isEditing && _usernameController.text.isNotEmpty,
              onCopy: () =>
                  _copyToClipboard(_usernameController.text, 'Username'),
            ),
            const SizedBox(height: 16),

            _buildPasswordField(),
            const SizedBox(height: 16),

            _buildTextField(
              controller: _uriController,
              label: 'Website URL',
              icon: Icons.link,
              enabled: _isEditing,
              showCopy: !_isEditing && _uriController.text.isNotEmpty,
              onCopy: () => _copyToClipboard(_uriController.text, 'URL'),
              keyboardType: TextInputType.url,
            ),
            const SizedBox(height: 16),

            _buildTextField(
              controller: _notesController,
              label: 'Notes',
              icon: Icons.notes,
              enabled: _isEditing,
              maxLines: 4,
            ),
            const SizedBox(height: 32),

            // Save button
            if (_isEditing)
              AnimatedButton(
                    label: _isNewEntry ? 'Create Entry' : 'Save Changes',
                    icon: Icons.check,
                    isLoading: _isSaving,
                    onPressed: _isSaving ? null : _onSave,
                  )
                  .animate()
                  .fadeIn(delay: 200.ms, duration: 300.ms)
                  .slideY(begin: 0.2, end: 0, duration: 300.ms),
          ],
        ),
      ),
    );
  }

  IconData _getCategoryIcon() {
    switch (_selectedCategory) {
      case 'login':
        return Icons.person;
      case 'card':
        return Icons.credit_card;
      case 'identity':
        return Icons.badge;
      case 'secure_note':
        return Icons.note;
      default:
        return Icons.lock;
    }
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    required bool enabled,
    String? Function(String?)? validator,
    bool showCopy = false,
    VoidCallback? onCopy,
    TextInputType? keyboardType,
    int maxLines = 1,
  }) {
    return TextFormField(
      controller: controller,
      enabled: enabled,
      validator: validator,
      keyboardType: keyboardType,
      maxLines: maxLines,
      style: AppTypography.bodyMedium,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
        alignLabelWithHint: maxLines > 1,
        suffixIcon: showCopy
            ? IconButton(
                icon: const Icon(Icons.copy, size: 20),
                onPressed: onCopy,
              )
            : null,
      ),
    );
  }

  Widget _buildPasswordField() {
    return TextFormField(
      controller: _passwordController,
      enabled: _isEditing,
      obscureText: _obscurePassword,
      style: AppTypography.bodyMedium,
      decoration: InputDecoration(
        labelText: 'Password',
        prefixIcon: const Icon(Icons.key),
        suffixIcon: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: Icon(
                _obscurePassword ? Icons.visibility : Icons.visibility_off,
                size: 20,
              ),
              onPressed: () =>
                  setState(() => _obscurePassword = !_obscurePassword),
            ),
            if (!_isEditing && _passwordController.text.isNotEmpty)
              IconButton(
                icon: const Icon(Icons.copy, size: 20),
                onPressed: () =>
                    _copyToClipboard(_passwordController.text, 'Password'),
              ),
          ],
        ),
      ),
    );
  }
}

class _CategorySelector extends StatelessWidget {
  final String selected;
  final ValueChanged<String> onChanged;

  const _CategorySelector({required this.selected, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _CategoryButton(
          id: 'login',
          icon: Icons.person,
          label: 'Login',
          isSelected: selected == 'login',
          onTap: () => onChanged('login'),
        ),
        const SizedBox(width: 8),
        _CategoryButton(
          id: 'card',
          icon: Icons.credit_card,
          label: 'Card',
          isSelected: selected == 'card',
          onTap: () => onChanged('card'),
        ),
        const SizedBox(width: 8),
        _CategoryButton(
          id: 'secure_note',
          icon: Icons.note,
          label: 'Note',
          isSelected: selected == 'secure_note',
          onTap: () => onChanged('secure_note'),
        ),
      ],
    );
  }
}

class _CategoryButton extends StatelessWidget {
  final String id;
  final IconData icon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _CategoryButton({
    required this.id,
    required this.icon,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final color = getCategoryColor(id);

    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isSelected ? color : color.withAlpha(20),
            borderRadius: BorderRadius.circular(4),
            border: Border.all(color: color, width: isSelected ? 2 : 1),
          ),
          child: Column(
            children: [
              Icon(icon, color: isSelected ? Colors.white : color, size: 24),
              const SizedBox(height: 4),
              Text(
                label,
                style: AppTypography.label.copyWith(
                  color: isSelected ? Colors.white : color,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
