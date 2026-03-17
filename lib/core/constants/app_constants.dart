import '../domain/entities/category.dart';
import '../domain/entities/education.dart';

class AppConstants {
  // App info
  static const String appName = 'Open Budget';
  static const String appVersion = '0.1.0';
  static const String currencySymbol = '\$';
  
  // Database
  static const String dbName = 'open_budget';
  static const int dbVersion = 1;
  
  // Default categories
  static List<Category> get defaultCategories => [
    // Expense categories
    Category(
      id: 'cat_food',
      name: 'Food & Dining',
      iconName: 'restaurant',
      color: 0xFF7C3AED,
      type: CategoryType.expense,
      isSystem: true,
      sortOrder: 0,
    ),
    Category(
      id: 'cat_transport',
      name: 'Transportation',
      iconName: 'directions_car',
      color: 0xFFEC4899,
      type: CategoryType.expense,
      isSystem: true,
      sortOrder: 1,
    ),
    Category(
      id: 'cat_shopping',
      name: 'Shopping',
      iconName: 'shopping_bag',
      color: 0xFF10B981,
      type: CategoryType.expense,
      isSystem: true,
      sortOrder: 2,
    ),
    Category(
      id: 'cat_bills',
      name: 'Bills & Utilities',
      iconName: 'receipt_long',
      color: 0xFF3B82F6,
      type: CategoryType.expense,
      isSystem: true,
      sortOrder: 3,
    ),
    Category(
      id: 'cat_entertainment',
      name: 'Entertainment',
      iconName: 'movie',
      color: 0xFFF59E0B,
      type: CategoryType.expense,
      isSystem: true,
      sortOrder: 4,
    ),
    Category(
      id: 'cat_health',
      name: 'Health & Fitness',
      iconName: 'fitness_center',
      color: 0xFFEF4444,
      type: CategoryType.expense,
      isSystem: true,
      sortOrder: 5,
    ),
    Category(
      id: 'cat_education',
      name: 'Education',
      iconName: 'school',
      color: 0xFF06B6D4,
      type: CategoryType.expense,
      isSystem: true,
      sortOrder: 6,
    ),
    Category(
      id: 'cat_personal',
      name: 'Personal Care',
      iconName: 'spa',
      color: 0xFF8B5CF6,
      type: CategoryType.expense,
      isSystem: true,
      sortOrder: 7,
    ),
    Category(
      id: 'cat_home',
      name: 'Home & Garden',
      iconName: 'home',
      color: 0xFFF97316,
      type: CategoryType.expense,
      isSystem: true,
      sortOrder: 8,
    ),
    Category(
      id: 'cat_gifts',
      name: 'Gifts & Donations',
      iconName: 'card_giftcard',
      color: 0xFF14B8A6,
      type: CategoryType.expense,
      isSystem: true,
      sortOrder: 9,
    ),
    Category(
      id: 'cat_other_expense',
      name: 'Other',
      iconName: 'more_horiz',
      color: 0xFF6366F1,
      type: CategoryType.expense,
      isSystem: true,
      sortOrder: 99,
    ),
    
    // Income categories
    Category(
      id: 'cat_salary',
      name: 'Salary',
      iconName: 'work',
      color: 0xFF10B981,
      type: CategoryType.income,
      isSystem: true,
      sortOrder: 0,
    ),
    Category(
      id: 'cat_freelance',
      name: 'Freelance',
      iconName: 'laptop',
      color: 0xFF3B82F6,
      type: CategoryType.income,
      isSystem: true,
      sortOrder: 1,
    ),
    Category(
      id: 'cat_investments',
      name: 'Investments',
      iconName: 'trending_up',
      color: 0xFFF59E0B,
      type: CategoryType.income,
      isSystem: true,
      sortOrder: 2,
    ),
    Category(
      id: 'cat_other_income',
      name: 'Other Income',
      iconName: 'attach_money',
      color: 0xFF7C3AED,
      type: CategoryType.income,
      isSystem: true,
      sortOrder: 99,
    ),
  ];

  static List<EducationContent> get defaultEducationContent => [
    EducationContent(
      id: 'strat_503020',
      title: 'THE 50/30/20 PROTOCOL',
      description: 'Master the foundational logic of budgeting.',
      type: ContentType.course,
      difficulty: DifficultyLevel.beginner,
      iconName: 'shield_rounded',
      content: 'The 50/30/20 rule is a simple plan to help you reach your financial goals. Allocate 50% of income to Needs, 30% to Wants, and 20% to Savings.',
      createdAt: DateTime.now(),
    ),
    EducationContent(
      id: 'strat_zerosum',
      title: 'ZERO-SUM GAME',
      description: 'Assign every dollar a task. Leave no survivors.',
      type: ContentType.challenge,
      difficulty: DifficultyLevel.intermediate,
      iconName: 'gamepad_rounded',
      content: 'In a zero-sum budget, your income minus your expenses should equal zero. This forces you to account for every cent.',
      createdAt: DateTime.now(),
    ),
    EducationContent(
      id: 'strat_coupon',
      title: 'COUPON CRYPTO',
      description: 'Optimize every transaction at the point of sale.',
      type: ContentType.tip,
      difficulty: DifficultyLevel.beginner,
      iconName: 'qr_code_scanner_rounded',
      content: 'Never checkout without a scan. Digital coupons are the simplest way to reduce data drain.',
      createdAt: DateTime.now(),
    ),
    EducationContent(
      id: 'strat_subs',
      title: 'SUBSCRIPTION PURGE',
      description: 'Eliminate recurring data drains.',
      type: ContentType.challenge,
      difficulty: DifficultyLevel.advanced,
      iconName: 'auto_delete_rounded',
      content: 'Review your bank statement for recurring charges. If you haven\'t used the module in 30 days, terminate the link.',
      createdAt: DateTime.now(),
    ),
    EducationContent(
      id: 'strat_emergency',
      title: 'EMERGENCY OVERRIDE',
      description: 'Build a safety net for system failures.',
      type: ContentType.course,
      difficulty: DifficultyLevel.beginner,
      iconName: 'shield_rounded',
      content: 'Aim for 3-6 months of essential expenses in a high-yield savings module. This provides an override switch for life\'s unexpected crashes.',
      createdAt: DateTime.now(),
    ),
    EducationContent(
      id: 'strat_debt_snowball',
      title: 'DEBT SNOWBALL PROTOCOL',
      description: 'Crush liabilities from smallest to largest.',
      type: ContentType.course,
      difficulty: DifficultyLevel.intermediate,
      iconName: 'bolt_rounded',
      content: 'List all debts. Pay minimums on all but the smallest. Channel every spare bit into that one until it is purged. Repeat.',
      createdAt: DateTime.now(),
    ),
    EducationContent(
      id: 'strat_invest_auto',
      title: 'AUTOMATED APPRECIATION',
      description: 'Set your wealth to auto-grow.',
      type: ContentType.tip,
      difficulty: DifficultyLevel.beginner,
      iconName: 'trending_up_rounded',
      content: 'Set up an automated transfer to your investment module on payday. Take the human decision out of the loop.',
      createdAt: DateTime.now(),
    ),
  ];
  
  // Budget templates
  static const Map<String, double> budgetTemplates = {
    'student': 1000.0,
    'single': 2500.0,
    'family': 5000.0,
    'custom': 0.0,
  };
  
  // Default budget allocations (50/30/20 rule)
  static const Map<String, double> defaultBudgetAllocation = {
    'needs': 0.50,    // 50% for necessities
    'wants': 0.30,    // 30% for discretionary
    'savings': 0.20,  // 20% for savings
  };
}

class RouteConstants {
  static const String home = '/';
  static const String addTransaction = '/add-transaction';
  static const String transactionDetail = '/transaction';
  static const String budget = '/budget';
  static const String budgetDetail = '/budget-detail';
  static const String goals = '/goals';
  static const String goalDetail = '/goal-detail';
  static const String insights = '/insights';
  static const String education = '/education';
  static const String educationDetail = '/education-detail';
  static const String settings = '/settings';
  static const String categories = '/categories';
  static const String export = '/export';
}
