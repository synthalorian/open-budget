import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/database/database_service.dart';
import 'core/services/notification_service.dart';
import 'core/theme/app_theme.dart';
import 'config/app_router.dart';
import 'features/settings/data/digest_service.dart';

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
      systemNavigationBarColor: AppColors.surface,
      systemNavigationBarIconBrightness: Brightness.light,
    ),
  );
  
  // Initialize services
  await DatabaseService().initialize();
  await NotificationService().initialize();
  
  runApp(
    ProviderScope(
      child: const OpenBudgetApp(),
      observers: [
        _DigestObserver(),
      ],
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

class OpenBudgetApp extends StatelessWidget {
  const OpenBudgetApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Open Budget',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkTheme,
      routerConfig: AppRouter.router,
    );
  }
}
