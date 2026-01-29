import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'core/encryption/encryption.dart';
import 'data/datasources/datasources.dart';
import 'data/repositories/repositories.dart';
import 'domain/entities/password_entry.dart';
import 'presentation/blocs/blocs.dart';
import 'presentation/pages/pages.dart';
import 'presentation/theme/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize data sources
  final localDataSource = LocalDataSource();
  await localDataSource.initialize();

  final secureDataSource = SecureDataSource();

  // Initialize services
  final keyDerivation = KeyDerivationService();
  final encryptionService = EncryptionService();

  // Initialize repositories
  final authRepository = AuthRepositoryImpl(
    secureDataSource: secureDataSource,
    keyDerivation: keyDerivation,
  );

  final vaultRepository = VaultRepositoryImpl(
    localDataSource: localDataSource,
    encryptionService: encryptionService,
    getKey: () => authRepository.currentKey,
  );

  runApp(
    SecureVaultApp(
      authRepository: authRepository,
      vaultRepository: vaultRepository,
    ),
  );
}

/// Main application widget.
class SecureVaultApp extends StatelessWidget {
  final AuthRepositoryImpl authRepository;
  final VaultRepositoryImpl vaultRepository;

  const SecureVaultApp({
    super.key,
    required this.authRepository,
    required this.vaultRepository,
  });

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (_) =>
              AuthBloc(authRepository: authRepository)
                ..add(const AuthCheckVaultSetup()),
        ),
        BlocProvider(
          create: (_) => VaultBloc(vaultRepository: vaultRepository),
        ),
      ],
      child: MaterialApp(
        title: 'SecureVault',
        theme: AppTheme.light,
        darkTheme: AppTheme.dark,
        themeMode: ThemeMode.system,
        home: const AppNavigator(),
      ),
    );
  }
}

/// Root navigator handling auth states and navigation.
class AppNavigator extends StatefulWidget {
  const AppNavigator({super.key});

  @override
  State<AppNavigator> createState() => _AppNavigatorState();
}

class _AppNavigatorState extends State<AppNavigator> {
  // Navigation state
  bool _showSettings = false;
  bool _showGenerator = false;
  PasswordEntry? _selectedEntry;
  bool _creatingNewEntry = false;

  void _navigateToVault() {
    setState(() {
      _showSettings = false;
      _showGenerator = false;
      _selectedEntry = null;
      _creatingNewEntry = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is AuthUnlocked) {
          // Load entries when unlocked
          context.read<VaultBloc>().add(const VaultLoadEntries());
        }
      },
      builder: (context, state) {
        // Loading state
        if (state is AuthInitial || state is AuthLoading) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        // Needs setup
        if (state is AuthNeedsSetup) {
          return const SetupMasterPasswordPage();
        }

        // Locked
        if (state is AuthLocked || state is AuthError) {
          return const UnlockPage();
        }

        // Unlocked - show vault or sub-pages
        if (state is AuthUnlocked) {
          if (_showSettings) {
            return SettingsPage(onBack: _navigateToVault);
          }

          if (_showGenerator) {
            return Scaffold(
              appBar: AppBar(
                title: const Text('Password Generator'),
                leading: IconButton(
                  icon: const Icon(Icons.arrow_back),
                  onPressed: _navigateToVault,
                ),
              ),
              body: const GeneratorPage(),
            );
          }

          if (_selectedEntry != null || _creatingNewEntry) {
            return EntryDetailPage(
              entry: _selectedEntry,
              onSave: _navigateToVault,
              onCancel: _navigateToVault,
            );
          }

          return VaultPage(
            onAddEntry: () => setState(() => _creatingNewEntry = true),
            onViewEntry: (entry) => setState(() => _selectedEntry = entry),
            onOpenSettings: () => setState(() => _showSettings = true),
            onOpenGenerator: () => setState(() => _showGenerator = true),
            onLock: () => context.read<AuthBloc>().add(const AuthLockVault()),
          );
        }

        return const Scaffold(body: Center(child: Text('Unknown state')));
      },
    );
  }
}
