import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:uuid/uuid.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../shared/widgets/neon_ui_kit.dart';
import '../../../../core/domain/entities/goal.dart';
import '../../data/goal_providers.dart';

class AddGoalPage extends ConsumerStatefulWidget {
  const AddGoalPage({super.key});

  @override
  ConsumerState<AddGoalPage> createState() => _AddGoalPageState();
}

class _AddGoalPageState extends ConsumerState<AddGoalPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _targetController = TextEditingController();
  final _notesController = TextEditingController();
  DateTime? _targetDate;

  @override
  void dispose() {
    _nameController.dispose();
    _targetController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    final goal = Goal(
      id: const Uuid().v4(),
      name: _nameController.text.trim(),
      targetAmount: double.parse(_targetController.text),
      targetDate: _targetDate,
      iconName: 'track_changes',
      color: AppColors.accent.value,
      createdAt: DateTime.now(),
      notes: _notesController.text.trim().isEmpty
          ? null
          : _notesController.text.trim(),
    );

    await ref.read(goalNotifierProvider.notifier).createGoal(goal);
    if (mounted) context.pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(title: Text('NEW TARGET', style: AppTextStyles.headlineMainframe)),
      body: Container(
        decoration: const BoxDecoration(gradient: AppColors.spaceGradient),
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 120),
            children: [
              NeonCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('TARGET NAME', style: AppTextStyles.labelNeon),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _nameController,
                      style: AppTextStyles.bodyMain,
                      decoration: InputDecoration(
                        hintText: 'Emergency Fund, New Car...',
                        hintStyle: TextStyle(color: AppColors.textMuted),
                      ),
                      validator: (v) =>
                          v == null || v.trim().isEmpty ? 'Required' : null,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              NeonCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('TARGET AMOUNT', style: AppTextStyles.labelNeon),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _targetController,
                      style: AppTextStyles.moneyLarge,
                      keyboardType:
                          const TextInputType.numberWithOptions(decimal: true),
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(
                            RegExp(r'^\d+\.?\d{0,2}')),
                      ],
                      decoration: InputDecoration(
                        hintText: '0.00',
                        hintStyle: TextStyle(color: AppColors.textMuted),
                        prefixText: '\$ ',
                        prefixStyle: AppTextStyles.moneyLarge,
                      ),
                      validator: (v) {
                        if (v == null || v.isEmpty) return 'Required';
                        final amount = double.tryParse(v);
                        if (amount == null || amount <= 0) return 'Invalid amount';
                        return null;
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              NeonCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('TARGET DATE (OPTIONAL)', style: AppTextStyles.labelNeon),
                    const SizedBox(height: 8),
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      title: Text(
                        _targetDate != null
                            ? '${_targetDate!.month}/${_targetDate!.day}/${_targetDate!.year}'
                            : 'No deadline set',
                        style: AppTextStyles.bodyMain,
                      ),
                      trailing: Icon(Icons.calendar_today,
                          color: AppColors.accent),
                      onTap: () async {
                        final picked = await showDatePicker(
                          context: context,
                          initialDate: DateTime.now().add(const Duration(days: 90)),
                          firstDate: DateTime.now(),
                          lastDate: DateTime(2035),
                        );
                        if (picked != null) setState(() => _targetDate = picked);
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              NeonCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('NOTES (OPTIONAL)', style: AppTextStyles.labelNeon),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _notesController,
                      style: AppTextStyles.bodyMain,
                      maxLines: 3,
                      decoration: InputDecoration(
                        hintText: 'Why is this goal important?',
                        hintStyle: TextStyle(color: AppColors.textMuted),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),
              SizedBox(
                height: 56,
                child: ElevatedButton(
                  onPressed: _save,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.accent,
                    foregroundColor: AppColors.background,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: Text('INITIALIZE TARGET',
                      style: AppTextStyles.headlineMainframe.copyWith(
                          fontSize: 14, color: AppColors.background)),
                ),
              ),
              const SizedBox(height: 80),
            ],
          ),
        ),
      ),
    );
  }
}
