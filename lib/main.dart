import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/database/database_service.dart';
import 'core/services/notification_service.dart';
import 'core/services/encryption_service.dart';
import 'core/theme/app_theme.dart';
import 'config/app_router.dart';
import 'features/settings/data/digest_service.dart';
import 'features/settings/data/settings_providers.dart';
import 'features/settings/presentation/pages/security_lock_screen.dart';

import 'shared/providers/theme_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Set preferred orientations
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  
  // Set system UI overlay style
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      systemNavigationBarColor: AppColors.background,
      systemNavigationBarIconBrightness: Brightness.light,
    ),
  );
  
  // Initialize services
  await DatabaseService().initialize();
  await NotificationService().initialize();
  await EncryptionService().initialize();
  
  runApp(
    ProviderScope(
      observers: [
        _DigestObserver(),
      ],
      child: const OpenBudgetApp(),
    ),
  );
}

class _DigestObserver extends ProviderObserver {
  @override
  void didAddProvider(ProviderBase provider, Object? value, ProviderContainer container) {
    if (provider.name == 'digestServiceProvider') {
      container.read(digestServiceProvider).checkAndFireDigest();
    }
  }
}

class OpenBudgetApp extends ConsumerStatefulWidget {
  const OpenBudgetApp({super.key});

  @override
  ConsumerState<OpenBudgetApp> createState() => _OpenBudgetAppState();
}

class _OpenBudgetAppState extends ConsumerState<OpenBudgetApp> {
  bool _isAuthenticated = false;

  @override
  Widget build(BuildContext context) {
    final settings = ref.watch(settingsProvider);
    final router = ref.watch(routerProvider);
    final theme = ref.watch(themeProvider);

    if (settings.biometricEnabled && !_isAuthenticated) {
      return MaterialApp(
        title: 'Open Budget',
        debugShowCheckedModeBanner: false,
        theme: theme,
        home: SecurityLockScreen(
          onAuthenticated: () => setState(() => _isAuthenticated = true),
        ),
      );
    }
    
    return MaterialApp.router(
      title: 'Open Budget',
      debugShowCheckedModeBanner: false,
      theme: theme,
      routerConfig: router,
    );
  }
}
