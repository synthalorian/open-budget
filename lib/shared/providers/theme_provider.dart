import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../features/settings/data/settings_providers.dart';
import '../../core/theme/app_theme.dart';
import '../../core/theme/neon_themes.dart';

final themeProvider = Provider<ThemeData>((ref) {
  final settings = ref.watch(settingsProvider);
  final neonTheme = NeonThemes.byName(settings.themeName);
  return AppTheme.createTheme(neonTheme);
});
