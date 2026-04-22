import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:share_plus/share_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/database/database_service.dart';
import '../../transactions/data/transaction_providers.dart';
import '../../insights/data/insights_providers.dart';

class ExportService {
  static final ExportService _instance = ExportService._internal();
  factory ExportService() => _instance;
  ExportService._internal();

  Future<String> exportTransactionsToCSV() async {
    final db = DatabaseService();
    final transactions = db.transactions.values.toList()
      ..sort((a, b) => b.date.compareTo(a.date));
    
    final buffer = StringBuffer();
    
    // CSV Header
    buffer.writeln('Date,Type,Category,Description,Amount,Merchant,Recurring');
    
    // CSV Data
    for (final t in transactions) {
      final category = db.categories.get(t.categoryId);
      final dateStr = DateFormat('yyyy-MM-dd').format(t.date);
      final type = t.isIncome ? 'Income' : 'Expense';
      final categoryName = category?.name ?? 'Unknown';
      final description = t.description.replaceAll(',', ';');
      final amount = t.amount.toStringAsFixed(2);
      final merchant = t.merchantName?.replaceAll(',', ';') ?? '';
      final recurring = t.isRecurring ? 'Yes' : 'No';
      
      buffer.writeln('$dateStr,$type,$categoryName,$description,$amount,$merchant,$recurring');
    }
    
    // Save to file
    final directory = await getApplicationDocumentsDirectory();
    final timestamp = DateFormat('yyyyMMdd_HHmmss').format(DateTime.now());
    final file = File('${directory.path}/open_budget_transactions_$timestamp.csv');
    await file.writeAsString(buffer.toString());
    
    return file.path;
  }

  Future<String> exportBudgetSummaryToCSV() async {
    final db = DatabaseService();
    final budgets = db.budgets.values.where((b) => b.isActive).toList();
    final transactions = db.transactions.values.toList();
    
    final now = DateTime.now();
    final startOfMonth = DateTime(now.year, now.month, 1);
    final monthTransactions = transactions.where(
      (t) => t.date.isAfter(startOfMonth.subtract(const Duration(days: 1))) && !t.isIncome
    );
    
    final buffer = StringBuffer();
    
    // CSV Header
    buffer.writeln('Budget Summary - ${DateFormat('MMMM yyyy').format(now)}');
    buffer.writeln();
    buffer.writeln('Category,Budget,Spent,Remaining,Status');
    
    for (final budget in budgets) {
      final category = db.categories.get(budget.categoryId ?? '');
      final spent = monthTransactions
          .where((t) => t.categoryId == budget.categoryId)
          .fold(0.0, (sum, t) => sum + t.amount);
      final remaining = budget.amount - spent;
      final status = remaining < 0 ? 'Over Budget' : 'On Track';
      
      buffer.writeln(
        '${category?.name ?? budget.name},${budget.amount.toStringAsFixed(2)},'
        '${spent.toStringAsFixed(2)},${remaining.toStringAsFixed(2)},$status'
      );
    }
    
    // Save to file
    final directory = await getApplicationDocumentsDirectory();
    final timestamp = DateFormat('yyyyMMdd_HHmmss').format(DateTime.now());
    final file = File('${directory.path}/open_budget_summary_$timestamp.csv');
    await file.writeAsString(buffer.toString());
    
    return file.path;
  }

  Future<String> exportFullReportToText() async {
    final db = DatabaseService();
    final transactions = db.transactions.values.toList()
      ..sort((a, b) => b.date.compareTo(a.date));
    final goals = db.goals.values.toList();
    final budgets = db.budgets.values.where((b) => b.isActive).toList();
    
    final now = DateTime.now();
    final startOfMonth = DateTime(now.year, now.month, 1);
    final monthTransactions = transactions.where(
      (t) => t.date.isAfter(startOfMonth.subtract(const Duration(days: 1))) || 
             t.date.isAtSameMomentAs(startOfMonth)
    );
    
    final income = monthTransactions.where((t) => t.isIncome).fold(0.0, (sum, t) => sum + t.amount);
    final expenses = monthTransactions.where((t) => !t.isIncome).fold(0.0, (sum, t) => sum + t.amount);
    final balance = income - expenses;
    
    final buffer = StringBuffer();
    
    // Header
    buffer.writeln('╔════════════════════════════════════════════╗');
    buffer.writeln('║          OPEN BUDGET - REPORT              ║');
    buffer.writeln('║    ${DateFormat('MMMM d, y').format(now)}                      ║');
    buffer.writeln('╚════════════════════════════════════════════╝');
    buffer.writeln();
    
    // Monthly Summary
    buffer.writeln('📊 MONTHLY SUMMARY');
    buffer.writeln('─' * 44);
    buffer.writeln('Total Income:      \$${income.toStringAsFixed(2)}');
    buffer.writeln('Total Expenses:    \$${expenses.toStringAsFixed(2)}');
    buffer.writeln('Balance:           \$${balance.toStringAsFixed(2)}');
    buffer.writeln();
    
    // Budget Status
    if (budgets.isNotEmpty) {
      buffer.writeln('💰 BUDGET STATUS');
      buffer.writeln('─' * 44);
      for (final budget in budgets) {
        final category = db.categories.get(budget.categoryId ?? '');
        final spent = monthTransactions
            .where((t) => !t.isIncome && t.categoryId == budget.categoryId)
            .fold(0.0, (sum, t) => sum + t.amount);
        final remaining = budget.amount - spent;
        final percent = (spent / budget.amount * 100).toStringAsFixed(0);
        
        buffer.writeln('${category?.name ?? budget.name}:');
        buffer.writeln('  Budget: \$${budget.amount.toStringAsFixed(2)}');
        buffer.writeln('  Spent:  \$${spent.toStringAsFixed(2)} ($percent%)');
        buffer.writeln('  Left:   \$${remaining.toStringAsFixed(2)}');
        buffer.writeln();
      }
    }
    
    // Savings Goals
    if (goals.isNotEmpty) {
      buffer.writeln('🎯 SAVINGS GOALS');
      buffer.writeln('─' * 44);
      for (final goal in goals) {
        final percent = (goal.progress * 100).toStringAsFixed(0);
        buffer.writeln('${goal.name}:');
        buffer.writeln('  Saved:  \$${goal.currentAmount.toStringAsFixed(2)} / \$${goal.targetAmount.toStringAsFixed(2)} ($percent%)');
        if (goal.targetDate != null) {
          final daysLeft = goal.daysRemaining;
          buffer.writeln('  Target: ${DateFormat('MMM d, y').format(goal.targetDate!)} ($daysLeft days)');
        }
        buffer.writeln();
      }
    }
    
    // Recent Transactions
    buffer.writeln('📝 RECENT TRANSACTIONS (Last 10)');
    buffer.writeln('─' * 44);
    for (final t in transactions.take(10)) {
      final category = db.categories.get(t.categoryId);
      final dateStr = DateFormat('MMM d').format(t.date);
      final prefix = t.isIncome ? '+' : '-';
      buffer.writeln('$dateStr | ${category?.name ?? 'Unknown'}: $prefix\$${t.amount.toStringAsFixed(2)}');
      buffer.writeln('       ${t.description}');
    }
    
    buffer.writeln();
    buffer.writeln('Generated by Open Budget');
    buffer.writeln('🎹🦞 Stay retro, stay financially secure.');
    
    // Save to file
    final directory = await getApplicationDocumentsDirectory();
    final timestamp = DateFormat('yyyyMMdd_HHmmss').format(DateTime.now());
    final file = File('${directory.path}/open_budget_report_$timestamp.txt');
    await file.writeAsString(buffer.toString());
    
    return file.path;
  }
}

class ExportPage extends ConsumerWidget {
  const ExportPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final transactions = ref.watch(transactionsProvider);
    final categoryBreakdown = ref.watch(categoryBreakdownProvider);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Export Data'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildInfoCard(transactions.length, categoryBreakdown.length),
            const SizedBox(height: 24),
            _buildExportOptions(context),
            const SizedBox(height: 24),
            _buildDataManagement(context, ref),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard(int transactionCount, int categoryCount) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Icon(
            Icons.file_download,
            size: 48,
            color: AppColors.primary,
          ),
          const SizedBox(height: 16),
          Text(
            '$transactionCount transactions',
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            'across $categoryCount categories',
            style: TextStyle(
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildExportOptions(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Export Options',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 16),
        _buildExportTile(
          icon: Icons.table_chart,
          title: 'Export Transactions (CSV)',
          subtitle: 'All your transactions in spreadsheet format',
          color: AppColors.income,
          onTap: () => _exportCSV(context, 'transactions'),
        ),
        const SizedBox(height: 12),
        _buildExportTile(
          icon: Icons.account_balance_wallet,
          title: 'Export Budget Summary (CSV)',
          subtitle: 'Monthly budget status by category',
          color: AppColors.primary,
          onTap: () => _exportCSV(context, 'budget'),
        ),
        const SizedBox(height: 12),
        _buildExportTile(
          icon: Icons.description,
          title: 'Export Full Report (TXT)',
          subtitle: 'Complete financial summary',
          color: AppColors.accent,
          onTap: () => _exportReport(context),
        ),
      ],
    );
  }

  Widget _buildExportTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.chevron_right,
              color: AppColors.textMuted,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDataManagement(BuildContext context, WidgetRef ref) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Data Management',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 16),
        Container(
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            children: [
              ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.accent.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(Icons.backup, color: AppColors.accent, size: 20),
                ),
                title: const Text('Backup Data'),
                subtitle: const Text('Create a local backup file'),
                trailing: Icon(Icons.chevron_right),
                onTap: () => _createBackup(context),
              ),
              Divider(height: 1, indent: 56, color: AppColors.surfaceLight),
              ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.warning.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(Icons.restore, color: AppColors.warning, size: 20),
                ),
                title: const Text('Import Data'),
                subtitle: const Text('Restore from backup file'),
                trailing: Icon(Icons.chevron_right),
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Import feature coming soon')),
                  );
                },
              ),
              Divider(height: 1, indent: 56, color: AppColors.surfaceLight),
              ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.expense.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(Icons.delete_outline, color: AppColors.expense, size: 20),
                ),
                title: const Text('Clear All Data'),
                subtitle: const Text('Delete all transactions and budgets'),
                trailing: Icon(Icons.chevron_right),
                onTap: () => showClearDataDialog(context, ref),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Future<void> _exportCSV(BuildContext context, String type) async {
    try {
      final exportService = ExportService();
      final path = type == 'transactions'
          ? await exportService.exportTransactionsToCSV()
          : await exportService.exportBudgetSummaryToCSV();
      
      if (context.mounted) {
        await Share.shareXFiles(
          [XFile(path)],
          subject: 'Open Budget ${type == 'transactions' ? 'Transactions' : 'Budget Summary'}',
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Export failed: $e')),
        );
      }
    }
  }

  Future<void> _exportReport(BuildContext context) async {
    try {
      final exportService = ExportService();
      final path = await exportService.exportFullReportToText();
      
      if (context.mounted) {
        await Share.shareXFiles(
          [XFile(path)],
          subject: 'Open Budget Full Report',
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Export failed: $e')),
        );
      }
    }
  }

  Future<void> _createBackup(BuildContext context) async {
    try {
      final exportService = ExportService();
      final transactionsPath = await exportService.exportTransactionsToCSV();
      final summaryPath = await exportService.exportBudgetSummaryToCSV();
      
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Backup created successfully!'),
            backgroundColor: AppColors.income,
          ),
        );
        
        await Share.shareXFiles(
          [XFile(transactionsPath), XFile(summaryPath)],
          subject: 'Open Budget Backup',
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Backup failed: $e')),
        );
      }
    }
  }

}

void showClearDataDialog(BuildContext context, WidgetRef ref) {
  showDialog(
    context: context,
    builder: (ctx) => AlertDialog(
      backgroundColor: AppColors.surface,
      title: Text('CLEAR_MAIN_FRAME', style: AppTextStyles.labelNeon.copyWith(color: AppColors.expense)),
      content: Text(
        'PERMANENT_WIPE of transactions, budgets, goals, and recurring protocols. This cannot be undone.',
        style: AppTextStyles.bodyMain,
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(ctx),
          child: Text('CANCEL', style: TextStyle(color: AppColors.textMuted)),
        ),
        ElevatedButton(
          onPressed: () async {
            await DatabaseService().clearAllData();
            if (ctx.mounted) {
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: const Text('MAIN_FRAME WIPED'),
                  backgroundColor: AppColors.expense,
                ),
              );
            }
          },
          style: ElevatedButton.styleFrom(backgroundColor: AppColors.expense),
          child: const Text('TERMINATE'),
        ),
      ],
    ),
  );
}
