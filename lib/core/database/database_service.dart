import 'package:hive_flutter/hive_flutter.dart';
import '../domain/entities/transaction.dart';
import '../domain/entities/category.dart';
import '../domain/entities/budget.dart';
import '../domain/entities/goal.dart';
import '../domain/entities/education.dart';
import '../domain/entities/settings.dart';
import '../domain/entities/recurring.dart';
import '../constants/app_constants.dart';

class DatabaseService {
  static final DatabaseService _instance = DatabaseService._internal();
  factory DatabaseService() => _instance;
  DatabaseService._internal();

  late Box<Transaction> _transactionBox;
  late Box<Category> _categoryBox;
  late Box<Budget> _budgetBox;
  late Box<Goal> _goalBox;
  late Box<UserProgress> _progressBox;
  late Box<RecurringTransaction> _recurringBox;
  late Box<dynamic> _settingsBox;

  Box<Transaction> get transactions => _transactionBox;
  Box<Category> get categories => _categoryBox;
  Box<Budget> get budgets => _budgetBox;
  Box<Goal> get goals => _goalBox;
  Box<UserProgress> get progress => _progressBox;
  Box<RecurringTransaction> get recurring => _recurringBox;
  Box<dynamic> get settings => _settingsBox;

  Future<void> initialize() async {
    await Hive.initFlutter();
    
    // Register adapters
    Hive.registerAdapter(TransactionAdapter());
    Hive.registerAdapter(CategoryAdapter());
    Hive.registerAdapter(CategoryTypeAdapter());
    Hive.registerAdapter(BudgetAdapter());
    Hive.registerAdapter(BudgetPeriodAdapter());
    Hive.registerAdapter(BudgetTypeAdapter());
    Hive.registerAdapter(GoalAdapter());
    Hive.registerAdapter(EducationContentAdapter());
    Hive.registerAdapter(ContentTypeAdapter());
    Hive.registerAdapter(DifficultyLevelAdapter());
    Hive.registerAdapter(UserProgressAdapter());
    Hive.registerAdapter(AppSettingsAdapter());
    Hive.registerAdapter(RecurringTransactionAdapter());

    // Open boxes
    _transactionBox = await Hive.openBox<Transaction>('transactions');
    _categoryBox = await Hive.openBox<Category>('categories');
    _budgetBox = await Hive.openBox<Budget>('budgets');
    _goalBox = await Hive.openBox<Goal>('goals');
    _progressBox = await Hive.openBox<UserProgress>('progress');
    _recurringBox = await Hive.openBox<RecurringTransaction>('recurring');
    _settingsBox = await Hive.openBox<dynamic>('settings');

    // Initialize default categories if empty
    if (_categoryBox.isEmpty) {
      await _initializeDefaultCategories();
    }

    // Initialize default education if empty
    if (_progressBox.isEmpty) {
      await _initializeDefaultProgress();
    }
  }

  Future<void> _initializeDefaultCategories() async {
    for (final category in AppConstants.defaultCategories) {
      await _categoryBox.put(category.id, category);
    }
  }

  Future<void> _initializeDefaultProgress() async {
    for (final content in AppConstants.defaultEducationContent) {
      await _progressBox.put(content.id, UserProgress(contentId: content.id));
    }
  }

  Future<void> clearAllData() async {
    await _transactionBox.clear();
    await _budgetBox.clear();
    await _categoryBox.clear();
    await _goalBox.clear();
    await _progressBox.clear();
    await _recurringBox.clear();
    // Keep settings for user preferences
  }

}
