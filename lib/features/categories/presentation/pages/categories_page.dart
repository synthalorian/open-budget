import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../shared/widgets/neon_ui_kit.dart';
import '../../../../core/domain/entities/category.dart';
import '../../data/category_providers.dart';

class CategoriesPage extends ConsumerWidget {
  const CategoriesPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final categories = ref.watch(categoriesProvider);

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.chevron_left_rounded, color: AppColors.accent),
          onPressed: () => context.pop(),
        ),
        title: Text('MODULE_LIBRARY', style: AppTextStyles.headlineMainframe.copyWith(fontSize: 20)),
      ),
      body: Container(
        decoration: const BoxDecoration(gradient: AppColors.spaceGradient),
        child: ListView.builder(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 120),
          itemCount: categories.length,
          itemBuilder: (context, index) {
            final category = categories[index];
            return _buildCategoryCard(context, ref, category);
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showCreateCategorySheet(context, ref),
        backgroundColor: AppColors.primary,
        child: Icon(Icons.add_rounded, color: Colors.white, size: 32),
      ),
    );
  }

  Widget _buildCategoryCard(BuildContext context, WidgetRef ref, Category category) {
    final color = Color(category.color);
    return NeonCard(
      glowColor: color,
      opacity: 0.2,
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: color.withOpacity(0.3)),
            ),
            child: Icon(_getIcon(category.iconName), color: color, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(category.name.toUpperCase(), style: AppTextStyles.headlineTitle.copyWith(fontSize: 16)),
                Text(category.type.name.toUpperCase(), style: AppTextStyles.labelNeon.copyWith(fontSize: 8, color: AppColors.textMuted)),
              ],
            ),
          ),
          if (!category.isSystem) ...[
            IconButton(
              icon: Icon(Icons.edit_rounded, color: AppColors.accent, size: 20),
              onPressed: () => _showEditCategorySheet(context, ref, category),
            ),
            IconButton(
              icon: Icon(Icons.delete_outline_rounded, color: AppColors.expense, size: 20),
              onPressed: () => _showDeleteConfirm(context, ref, category),
            ),
          ],
        ],
      ),
    );
  }

  void _showDeleteConfirm(BuildContext context, WidgetRef ref, Category category) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: Text('TERMINATE_MODULE?', style: AppTextStyles.labelNeon.copyWith(color: AppColors.expense)),
        content: Text('Are you sure you want to delete ${category.name}? Transactions in this category will become unlinked.', style: AppTextStyles.bodyMain),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: Text('CANCEL', style: AppTextStyles.labelNeon.copyWith(color: AppColors.textMuted))),
          TextButton(
            onPressed: () {
              ref.read(categoryNotifierProvider.notifier).deleteCategory(category.id);
              Navigator.pop(context);
            },
            child: Text('TERMINATE', style: AppTextStyles.labelNeon.copyWith(color: AppColors.expense)),
          ),
        ],
      ),
    );
  }

  void _showCreateCategorySheet(BuildContext context, WidgetRef ref) {
    String name = '';
    String selectedIcon = 'category';
    int selectedColor = AppColors.primary.value;
    CategoryType selectedType = CategoryType.expense;

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
              Text('INITIALIZE_NEW_MODULE', style: AppTextStyles.headlineMainframe.copyWith(fontSize: 18)),
              const SizedBox(height: 24),
              TextField(
                style: AppTextStyles.bodyMain,
                decoration: InputDecoration(
                  hintText: 'MODULE_NAME',
                  prefixIcon: Icon(Icons.terminal_rounded, color: AppColors.accent),
                  filled: true,
                  fillColor: AppColors.surfaceLight,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                ),
                onChanged: (val) => name = val,
              ),
              const SizedBox(height: 24),
              Text('DATA_TYPE', style: AppTextStyles.labelNeon.copyWith(fontSize: 10, color: AppColors.textMuted)),
              const SizedBox(height: 8),
              Row(
                children: [
                  _buildTypeToggle(setState, 'EXPENSE', CategoryType.expense, selectedType == CategoryType.expense, (newType) => selectedType = newType),
                  const SizedBox(width: 12),
                  _buildTypeToggle(setState, 'INCOME', CategoryType.income, selectedType == CategoryType.income, (newType) => selectedType = newType),
                ],
              ),
              const SizedBox(height: 24),
              Text('NEON_HEX_CODE', style: AppTextStyles.labelNeon.copyWith(fontSize: 10, color: AppColors.textMuted)),
              const SizedBox(height: 12),
              SizedBox(
                height: 40,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  children: [
                    AppColors.primary,
                    AppColors.accent,
                    AppColors.income,
                    AppColors.expense,
                    Colors.orange,
                    Colors.yellow,
                    Colors.blue,
                  ].map((c) => GestureDetector(
                    onTap: () => setState(() => selectedColor = c.value),
                    child: Container(
                      width: 40,
                      height: 40,
                      margin: const EdgeInsets.only(right: 12),
                      decoration: BoxDecoration(
                        color: c,
                        shape: BoxShape.circle,
                        border: Border.all(color: selectedColor == c.value ? Colors.white : Colors.transparent, width: 2),
                        boxShadow: [BoxShadow(color: c.withOpacity(0.4), blurRadius: 8)],
                      ),
                    ),
                  )).toList(),
                ),
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: () {
                    if (name.isNotEmpty) {
                      ref.read(categoryNotifierProvider.notifier).createCategory(
                        name: name,
                        iconName: selectedIcon,
                        color: selectedColor,
                        type: selectedType,
                      );
                      Navigator.pop(context);
                    }
                  },
                  style: ElevatedButton.styleFrom(backgroundColor: Color(selectedColor)),
                  child: Text('COMMIT_TO_GRID', style: AppTextStyles.labelNeon.copyWith(color: Colors.white)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTypeToggle(StateSetter setState, String label, CategoryType targetType, bool isSelected, Function(CategoryType) onSelect) {
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => onSelect(targetType)),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.primary.withOpacity(0.2) : AppColors.surfaceLight,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: isSelected ? AppColors.primary : Colors.transparent),
          ),
          child: Text(label, style: AppTextStyles.labelNeon.copyWith(fontSize: 10, color: isSelected ? Colors.white : AppColors.textMuted), textAlign: TextAlign.center),
        ),
      ),
    );
  }

  void _showEditCategorySheet(BuildContext context, WidgetRef ref, Category category) {
    String name = category.name;
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setState) => Padding(
          padding: EdgeInsets.only(
            left: 24, right: 24, top: 24,
            bottom: MediaQuery.of(ctx).viewInsets.bottom + 24,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('EDIT MODULE', style: AppTextStyles.headlineMainframe),
              const SizedBox(height: 24),
              TextField(
                controller: TextEditingController(text: name),
                onChanged: (v) => name = v,
                style: AppTextStyles.headlineTitle,
                decoration: InputDecoration(
                  labelText: 'MODULE NAME',
                  labelStyle: AppTextStyles.labelNeon.copyWith(fontSize: 10),
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: () {
                    if (name.trim().isNotEmpty) {
                      ref.read(categoryNotifierProvider.notifier).updateCategory(
                        category.copyWith(name: name.trim()),
                      );
                      Navigator.pop(ctx);
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.accent,
                    foregroundColor: AppColors.background,
                  ),
                  child: Text('SAVE CHANGES', style: AppTextStyles.labelNeon.copyWith(color: AppColors.background)),
                ),
              ),
            ],
          ),
        ),
      ),
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
