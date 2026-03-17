import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/database/database_service.dart';
import '../../../core/domain/entities/education.dart';
import '../../../shared/providers/database_provider.dart';
import '../../../core/constants/app_constants.dart';

final educationContentProvider = Provider<List<EducationContent>>((ref) {
  return AppConstants.defaultEducationContent;
});

final userProgressProvider = Provider<Map<String, UserProgress>>((ref) {
  final db = ref.watch(databaseProvider);
  final progress = <String, UserProgress>{};
  
  for (var key in db.progress.keys) {
    final value = db.progress.get(key);
    if (value != null) {
      progress[key.toString()] = value;
    }
  }
  
  return progress;
});

final educationNotifierProvider = StateNotifierProvider<EducationNotifier, AsyncValue<void>>((ref) {
  return EducationNotifier(ref);
});

class EducationNotifier extends StateNotifier<AsyncValue<void>> {
  final Ref ref;
  EducationNotifier(this.ref) : super(const AsyncValue.data(null));

  Future<void> completeModule(String contentId) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final db = ref.read(databaseProvider);
      final existing = db.progress.get(contentId) ?? UserProgress(contentId: contentId);
      
      final updated = existing.copyWith(
        isCompleted: true,
        completedAt: DateTime.now(),
        progressPercent: 100,
      );
      
      await db.progress.put(contentId, updated);
      ref.invalidate(userProgressProvider);
    });
  }
}

// Achievement logic
final userRankProvider = Provider<String>((ref) {
  final progress = ref.watch(userProgressProvider);
  final completedCount = progress.values.where((p) => p.isCompleted).length;
  
  if (completedCount >= 4) return 'MAINFRAME_MASTER';
  if (completedCount >= 2) return 'GRID_RUNNER';
  return 'NEW_USER';
});
