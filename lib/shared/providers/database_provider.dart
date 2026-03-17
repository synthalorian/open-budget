import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/database/database_service.dart';

// Shared database provider - import this in all feature providers
final databaseProvider = Provider<DatabaseService>((ref) {
  return DatabaseService();
});
