import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:uuid/uuid.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../shared/widgets/neon_ui_kit.dart';
import '../../../../core/database/database_service.dart';
import '../../../../core/domain/entities/transaction.dart';
import '../../../../core/domain/entities/category.dart';

class AddTransactionPage extends StatefulWidget {
  final bool isIncome;

  const AddTransactionPage({super.key, this.isIncome = false});

  @override
  State<AddTransactionPage> createState() => _AddTransactionPageState();
}

class _AddTransactionPageState extends State<AddTransactionPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  final _descriptionController = TextEditingController();
  
  Category? _selectedCategory;
  DateTime _selectedDate = DateTime.now();
  bool get _isIncome => _tabController.index == 1;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(
      length: 2,
      vsync: this,
      initialIndex: widget.isIncome ? 1 : 0,
    );
    _tabController.addListener(() => setState(() {}));
    
    final categories = DatabaseService().categories.values.toList();
    if (categories.isNotEmpty) {
      _selectedCategory = categories.first;
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    _amountController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final themeColor = _isIncome ? AppColors.income : AppColors.expense;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.close_rounded, color: AppColors.textPrimary),
          onPressed: () => context.pop(),
        ),
        title: Text(_isIncome ? 'DATA INFLOW' : 'DATA OUTFLOW', style: AppTextStyles.headlineMainframe.copyWith(fontSize: 18, color: themeColor)),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: themeColor,
          labelStyle: AppTextStyles.labelNeon.copyWith(color: themeColor),
          unselectedLabelStyle: AppTextStyles.labelNeon.copyWith(color: AppColors.textMuted),
          tabs: const [
            Tab(text: 'OUTFLOW'),
            Tab(text: 'INFLOW'),
          ],
        ),
      ),
      body: Container(
        decoration: const BoxDecoration(gradient: AppColors.spaceGradient),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 140),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildAmountInput(themeColor),
                const SizedBox(height: 32),
                _buildSectionLabel('SYSTEM TAG'),
                const SizedBox(height: 12),
                _buildCategoryGrid(),
                const SizedBox(height: 32),
                _buildSectionLabel('LOG ENTRY'),
                const SizedBox(height: 12),
                _buildNeonTextField(_descriptionController, 'DESCRIPTION', Icons.edit_note_rounded),
                const SizedBox(height: 48),
                _buildSubmitButton(themeColor),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSectionLabel(String label) {
    return Text(label, style: AppTextStyles.labelNeon.copyWith(fontSize: 10, color: AppColors.textMuted));
  }

  Widget _buildAmountInput(Color color) {
    return NeonCard(
      glowColor: color,
      child: Column(
        children: [
          Text('TRANSACTION_VALUE', style: AppTextStyles.labelNeon.copyWith(fontSize: 10, color: color)),
          TextFormField(
            controller: _amountController,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            textAlign: TextAlign.center,
            style: AppTextStyles.moneyLarge.copyWith(color: color),
            decoration: const InputDecoration(
              hintText: '0.00',
              prefixText: '\$ ',
              border: InputBorder.none,
              enabledBorder: InputBorder.none,
              focusedBorder: InputBorder.none,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryGrid() {
    final categories = DatabaseService().categories.values.toList();
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 1.2,
      ),
      itemCount: categories.length,
      itemBuilder: (context, index) {
        final category = categories[index];
        final isSelected = _selectedCategory?.id == category.id;
        final catColor = Color(category.color);
        return GestureDetector(
          onTap: () => setState(() => _selectedCategory = category),
          child: NeonCard(
            padding: const EdgeInsets.all(8),
            glowColor: isSelected ? catColor : Colors.transparent,
            opacity: isSelected ? 0.4 : 0.1,
            hasGlow: isSelected,
            borderColor: isSelected ? catColor : AppColors.surfaceLight,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(_getIcon(category.iconName), color: isSelected ? catColor : AppColors.textMuted, size: 20),
                const SizedBox(height: 4),
                Text(category.name.toUpperCase(), style: AppTextStyles.labelNeon.copyWith(fontSize: 8, color: isSelected ? catColor : AppColors.textMuted), overflow: TextOverflow.ellipsis),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildNeonTextField(TextEditingController controller, String hint, IconData icon) {
    return NeonCard(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      hasGlow: false,
      opacity: 0.1,
      borderColor: AppColors.surfaceLight,
      child: TextFormField(
        controller: controller,
        style: AppTextStyles.bodyMain,
        decoration: InputDecoration(
          hintText: hint,
          prefixIcon: Icon(icon, color: AppColors.textMuted, size: 20),
          border: InputBorder.none,
        ),
      ),
    );
  }

  Widget _buildSubmitButton(Color color) {
    return SizedBox(
      width: double.infinity,
      height: 60,
      child: NeonCard(
        padding: EdgeInsets.zero,
        glowColor: color,
        child: InkWell(
          onTap: _save,
          borderRadius: BorderRadius.circular(24),
          child: Center(
            child: Text(
              _isIncome ? 'COMMIT_INFLOW' : 'COMMIT_OUTFLOW',
              style: AppTextStyles.labelNeon.copyWith(color: color, fontSize: 16),
            ),
          ),
        ),
      ),
    );
  }

  void _save() async {
    if (_amountController.text.isEmpty) return;
    final transaction = Transaction(
      id: const Uuid().v4(),
      amount: double.parse(_amountController.text),
      categoryId: _selectedCategory!.id,
      description: _descriptionController.text,
      date: _selectedDate,
      isIncome: _isIncome,
      createdAt: DateTime.now(),
    );
    await DatabaseService().transactions.put(transaction.id, transaction);
    context.pop();
  }

  IconData _getIcon(String name) {
    const iconMap = {
      'restaurant': Icons.restaurant_menu_rounded,
      'directions_car': Icons.directions_car_filled_rounded,
      'shopping_bag': Icons.shopping_bag_rounded,
    };
    return iconMap[name] ?? Icons.grid_view_rounded;
  }
}
