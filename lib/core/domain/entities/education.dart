import 'package:equatable/equatable.dart';
import 'package:hive/hive.dart';

part 'education.g.dart';

@HiveType(typeId: 7)
enum ContentType {
  @HiveField(0)
  tip,
  @HiveField(1)
  article,
  @HiveField(2)
  challenge,
  @HiveField(3)
  course,
}

@HiveType(typeId: 8)
enum DifficultyLevel {
  @HiveField(0)
  beginner,
  @HiveField(1)
  intermediate,
  @HiveField(2)
  advanced,
}

@HiveType(typeId: 9)
class EducationContent extends Equatable {
  @HiveField(0)
  final String id;
  
  @HiveField(1)
  final String title;
  
  @HiveField(2)
  final String description;
  
  @HiveField(3)
  final ContentType type;
  
  @HiveField(4)
  final DifficultyLevel difficulty;
  
  @HiveField(5)
  final String content;
  
  @HiveField(6)
  final List<String> tags;
  
  @HiveField(7)
  final String iconName;
  
  @HiveField(8)
  final int readTimeMinutes;
  
  @HiveField(9)
  final bool isPremium;
  
  @HiveField(10)
  final DateTime createdAt;

  const EducationContent({
    required this.id,
    required this.title,
    required this.description,
    required this.type,
    this.difficulty = DifficultyLevel.beginner,
    required this.content,
    this.tags = const [],
    required this.iconName,
    this.readTimeMinutes = 5,
    this.isPremium = false,
    required this.createdAt,
  });

  @override
  List<Object?> get props => [
        id,
        title,
        description,
        type,
        difficulty,
        content,
        tags,
        iconName,
        readTimeMinutes,
        isPremium,
        createdAt,
      ];
}

@HiveType(typeId: 10)
class UserProgress extends Equatable {
  @HiveField(0)
  final String contentId;
  
  @HiveField(1)
  final bool isCompleted;
  
  @HiveField(2)
  final bool isBookmarked;
  
  @HiveField(3)
  final DateTime? completedAt;
  
  @HiveField(4)
  final int progressPercent;

  const UserProgress({
    required this.contentId,
    this.isCompleted = false,
    this.isBookmarked = false,
    this.completedAt,
    this.progressPercent = 0,
  });

  UserProgress copyWith({
    String? contentId,
    bool? isCompleted,
    bool? isBookmarked,
    DateTime? completedAt,
    int? progressPercent,
  }) {
    return UserProgress(
      contentId: contentId ?? this.contentId,
      isCompleted: isCompleted ?? this.isCompleted,
      isBookmarked: isBookmarked ?? this.isBookmarked,
      completedAt: completedAt ?? this.completedAt,
      progressPercent: progressPercent ?? this.progressPercent,
    );
  }

  @override
  List<Object?> get props => [
        contentId,
        isCompleted,
        isBookmarked,
        completedAt,
        progressPercent,
      ];
}
