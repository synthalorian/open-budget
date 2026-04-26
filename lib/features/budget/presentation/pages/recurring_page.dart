import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../shared/widgets/neon_ui_kit.dart';
import '../../../../shared/providers/database_provider.dart';
import '../../../../core/domain/entities/recurring.dart';
import '../../../../core/domain/entities/category.dart';
import '../../data/recurring_providers.dart';

class RecurringPage extends ConsumerWidget {
  const RecurringPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final recurring = ref.watch(recurringTransactionsProvider);
    final currency = NumberFormat.simpleCurrency(decimalDigits: 0);
    final db = ref.watch(databaseProvider);

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.chevron_left_rounded, color: AppColors.accent),
          onPressed: () => context.pop(),
        ),
        title: Text('CHRONOS_MODULE', style: AppTextStyles.headlineMainframe),
      ),
      body: Container(
        decoration: BoxDecoration(gradient: AppColors.spaceGradient),
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 120),
          children: [
            _buildHeader('ACTIVE_PROTOCOLS'),
            const SizedBox(height: 16),
            if (recurring.isEmpty)
              _buildEmptyState()
            else
              ...recurring.map((r) {
                final category = db.categories.get(r.categoryId);
                return _buildRecurringCard(context, ref, r, category, currency);
              }).toList(),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddRecurringSheet(context, ref, db),
        backgroundColor: AppColors.accent,
        child: Icon(Icons.add_rounded, color: AppColors.background),
      ),
    );
  }

  Widget _buildHeader(String title) {
    return Row(
      children: [
        Container(width: 4, height: 16, color: AppColors.primary),
        const SizedBox(width: 8),
        Text(title, style: AppTextStyles.labelNeon),
      ],
    );
  }

  Widget _buildEmptyState() {
    return NeonCard(
      child: Center(
        child: Text('NO RECURRING TRANSACTIONS DETECTED', style: AppTextStyles.labelNeon),
      ),
    );
  }

  Widget _buildRecurringCard(
    BuildContext context, 
    WidgetRef ref, 
    RecurringTransaction r, 
    Category? category, 
    NumberFormat currency
  ) {
    final color = Color(category?.color ?? 0xFF9D50BB);
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: GestureDetector(
        onLongPress: () => _showDeleteConfirm(context, ref, r),
        child: NeonCard(
        glowColor: r.isActive ? color : AppColors.textMuted,
        opacity: r.isActive ? 0.2 : 0.1,
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(_getIcon(category?.iconName ?? 'more_horiz'), color: color, size: 20),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(r.description.toUpperCase(), style: AppTextStyles.headlineTitle.copyWith(fontSize: 14)),
                  Text('DAY ${r.dayOfMonth} OF MONTH', style: AppTextStyles.labelNeon.copyWith(fontSize: 8, color: AppColors.textMuted)),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(currency.format(r.amount), style: AppTextStyles.headlineTitle.copyWith(fontSize: 16, color: color)),
                Transform.scale(
                  scale: 0.7,
                  child: Switch(
                    value: r.isActive, 
                    onChanged: (val) => ref.read(recurringNotifierProvider.notifier).toggleActive(r.id, val),
                    activeThumbColor: AppColors.accent,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
      ),
    );
  }

  void _showDeleteConfirm(BuildContext context, WidgetRef ref, RecurringTransaction r) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: Text('DELETE RECURRING', style: AppTextStyles.labelNeon.copyWith(color: AppColors.expense)),
        content: Text('Delete "${r.description}"?', style: AppTextStyles.bodyMain),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('CANCEL', style: TextStyle(color: AppColors.textMuted)),
          ),
          TextButton(
            onPressed: () {
              ref.read(recurringNotifierProvider.notifier).deleteRecurring(r.id);
              Navigator.pop(ctx);
            },
            child: Text('TERMINATE', style: TextStyle(color: AppColors.expense)),
          ),
        ],
      ),
    );
  }

  void _showAddRecurringSheet(BuildContext context, WidgetRef ref, dynamic db) {
    String description = '';
    double amount = 0;
    int dayOfMonth = 1;
    Category? selectedCategory;
    final List<Category> categories = (db.categories.values as Iterable<Category>)
        .where((c) => c.type == CategoryType.expense)
        .toList();
    if (categories.isNotEmpty) selectedCategory = categories.first;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => Padding(
          padding: EdgeInsets.fromLTRB(24, 24, 24, MediaQuery.of(context).viewInsets.bottom + 40),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('INITIALIZE_RECURRING', style: AppTextStyles.headlineMainframe.copyWith(fontSize: 18)),
              const SizedBox(height: 24),
              TextField(
                style: AppTextStyles.bodyMain,
                decoration: _inputDecoration('DESCRIPTION', Icons.edit_note_rounded),
                onChanged: (val) => description = val,
              ),
              const SizedBox(height: 16),
              TextField(
                style: AppTextStyles.bodyMain,
                keyboardType: TextInputType.number,
                decoration: _inputDecoration('AMOUNT', Icons.monetization_on_rounded),
                onChanged: (val) => amount = double.tryParse(val) ?? 0,
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: DropdownButtonFormField<int>(
                      value: dayOfMonth,
                      dropdownColor: AppColors.surface,
                      decoration: _inputDecoration('DAY', Icons.calendar_month_rounded),
                      items: List.generate(31, (index) => index + 1)
                          .map((day) => DropdownMenuItem(value: day, child: Text(day.toString())))
                          .toList(),
                      onChanged: (val) => setState(() => dayOfMonth = val ?? 1),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: DropdownButtonFormField<Category>(
                      value: selectedCategory,
                      dropdownColor: AppColors.surface,
                      decoration: _inputDecoration('CATEGORY', Icons.category_rounded),
                      items: categories.map<DropdownMenuItem<Category>>((c) => DropdownMenuItem(
                        value: c,
                        child: Text(c.name.toUpperCase(), style: const TextStyle(fontSize: 10)),
                      )).toList(),
                      onChanged: (val) => setState(() => selectedCategory = val),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: () {
                    if (description.isNotEmpty && amount > 0 && selectedCategory != null) {
                      final r = RecurringTransaction(
                        id: const Uuid().v4(),
                        amount: amount,
                        categoryId: selectedCategory!.id,
                        description: description,
                        dayOfMonth: dayOfMonth,
                        createdAt: DateTime.now(),
                      );
                      ref.read(recurringNotifierProvider.notifier).addRecurring(r);
                      Navigator.pop(context);
                    }
                  },
                  style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
                  child: Text('COMMIT_TO_CHRONOS', style: AppTextStyles.labelNeon.copyWith(color: Colors.white)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  InputDecoration _inputDecoration(String label, IconData icon) {
    return InputDecoration(
      labelText: label,
      labelStyle: AppTextStyles.labelNeon.copyWith(fontSize: 8, color: AppColors.textMuted),
      prefixIcon: Icon(icon, color: AppColors.accent, size: 20),
      filled: true,
      fillColor: AppColors.surfaceLight,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
    );
  }

  IconData _getIcon(String name) {
    const iconMap = {
      'restaurant': Icons.restaurant_menu_rounded,
      'directions_car': Icons.directions_car_filled_rounded,
      'shopping_bag': Icons.shopping_bag_rounded,
      'receipt_long': Icons.receipt_long_rounded,
      'movie': Icons.movie_rounded,
      'fitness_center': Icons.fitness_center_rounded,
      'school': Icons.school_rounded,
      'spa': Icons.spa_rounded,
      'home': Icons.home_rounded,
      'card_giftcard': Icons.card_giftcard_rounded,
      'more_horiz': Icons.more_horiz_rounded,
      'work': Icons.work_rounded,
      'laptop': Icons.laptop_mac_rounded,
      'trending_up': Icons.trending_up_rounded,
      'attach_money': Icons.attach_money_rounded,
    };
    return iconMap[name] ?? Icons.grid_view_rounded;
  }
}

// Real code uses Transform.scale inside the widget tree.
