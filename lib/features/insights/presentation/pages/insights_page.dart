import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../shared/widgets/neon_ui_kit.dart';
import '../../data/insights_providers.dart';

class InsightsPage extends ConsumerWidget {
  const InsightsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final projection = ref.watch(spendingPredictorProvider);
    final insights = ref.watch(spendingInsightsProvider);
    final suggestions = ref.watch(savingsOptimizerProvider);
    final dailySpend = ref.watch(dailySpendingProvider);
    final categoryBreakdown = ref.watch(categoryBreakdownProvider);
    final currency = NumberFormat.simpleCurrency(decimalDigits: 0);

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text('ANALYTICS', style: AppTextStyles.headlineMainframe),
      ),
      body: Container(
        decoration: const BoxDecoration(gradient: AppColors.spaceGradient),
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 120),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (projection != null) ...[
                _buildSectionHeader('AI PROJECTION'),
                const SizedBox(height: 16),
                _buildProjectionCard(projection, currency),
                const SizedBox(height: 32),
              ],
              if (suggestions.isNotEmpty) ...[
                _buildSectionHeader('OPTIMIZATION PROTOCOLS'),
                const SizedBox(height: 16),
                ...suggestions.map((s) => Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: _buildSuggestionCard(s, currency, ref, context),
                    )),
                const SizedBox(height: 32),
              ],
              _buildSectionHeader('SPENDING VELOCITY'),
              const SizedBox(height: 16),
              _buildVelocityChart(dailySpend, currency),
              const SizedBox(height: 32),
              _buildSectionHeader('DATA ALLOCATION'),
              const SizedBox(height: 16),
              _buildCategoryPie(categoryBreakdown),
              const SizedBox(height: 32),
              _buildSectionHeader('SYSTEM INSIGHTS'),
              const SizedBox(height: 16),
              if (projection != null && projection.alerts.isNotEmpty)
                ...projection.alerts.map((a) => Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: _buildInsightCard(a.title, a.description, Color(a.color), _getIcon(a.icon)),
                    )),
              ...insights.map((i) => Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: _buildInsightCard(i.title, i.description, Color(i.color), _getIcon(i.icon)),
                  )),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSuggestionCard(SavingsSuggestion s, NumberFormat currency, WidgetRef ref, BuildContext context) {
    return NeonCard(
      glowColor: AppColors.accent,
      opacity: 0.3,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                s.type == SuggestionType.boost ? Icons.rocket_launch_rounded : Icons.auto_graph_rounded,
                color: AppColors.accent,
                size: 20,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(s.title, style: AppTextStyles.headlineTitle.copyWith(fontSize: 14)),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(s.description, style: AppTextStyles.bodyMain.copyWith(fontSize: 12)),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'POTENTIAL IMPACT: ${currency.format(s.impactAmount)}',
                style: AppTextStyles.labelNeon.copyWith(fontSize: 8, color: AppColors.accent),
              ),
              TextButton(
                onPressed: () async {
                  await ref.read(optimizerNotifierProvider.notifier).executeSuggestion(s);
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('PROTOCOL_EXECUTED: ${s.actionLabel} SUCCESS'),
                        backgroundColor: AppColors.accent,
                      ),
                    );
                  }
                },
                style: TextButton.styleFrom(
                  backgroundColor: AppColors.accent.withOpacity(0.1),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                    side: const BorderSide(color: AppColors.accent),
                  ),
                ),
                child: Text(s.actionLabel, style: AppTextStyles.labelNeon.copyWith(fontSize: 10, color: AppColors.accent)),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildProjectionCard(SpendingProjection projection, NumberFormat currency) {
    final statusColor = projection.healthStatus == 'CRITICAL' 
        ? AppColors.expense 
        : projection.healthStatus == 'WARNING' 
            ? AppColors.warning 
            : AppColors.income;

    return NeonCard(
      glowColor: statusColor,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('MONTHLY PROJECTION', style: AppTextStyles.labelNeon.copyWith(fontSize: 10, color: AppColors.textMuted)),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(4),
                  border: Border.all(color: statusColor.withOpacity(0.5)),
                ),
                child: Text(projection.healthStatus, style: AppTextStyles.labelNeon.copyWith(fontSize: 8, color: statusColor)),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            currency.format(projection.predictedTotal),
            style: AppTextStyles.moneyLarge.copyWith(color: statusColor),
          ),
          Text(
            'ESTIMATED END OF MONTH SPEND',
            style: AppTextStyles.labelNeon.copyWith(fontSize: 8, color: AppColors.textMuted),
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildStatItem('VELOCITY', '${currency.format(projection.velocity)}/day'),
              _buildStatItem('REMAINING', '${projection.daysRemaining} days'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: AppTextStyles.labelNeon.copyWith(fontSize: 8, color: AppColors.textMuted)),
        Text(value, style: AppTextStyles.headlineTitle.copyWith(fontSize: 14)),
      ],
    );
  }

  IconData _getIcon(String icon) {
    switch (icon) {
      case 'warning': return Icons.warning_amber_rounded;
      case 'bolt': return Icons.bolt_rounded;
      case 'trending_up': return Icons.trending_up_rounded;
      case 'pie_chart': return Icons.pie_chart_rounded;
      case 'radar': return Icons.radar_rounded;
      default: return Icons.insights_rounded;
    }
  }

  Widget _buildSectionHeader(String title) {
    return Row(
      children: [
        Container(width: 4, height: 16, color: AppColors.accent),
        const SizedBox(width: 8),
        Text(title, style: AppTextStyles.labelNeon),
      ],
    );
  }

  Widget _buildVelocityChart(List<DailySpend> dailySpend, NumberFormat currency) {
    final spots = dailySpend.map((e) => FlSpot(e.day.toDouble(), e.amount)).toList();
    
    return NeonCard(
      glowColor: AppColors.accent,
      padding: const EdgeInsets.fromLTRB(12, 24, 24, 12),
      child: Column(
        children: [
          SizedBox(
            height: 200,
            child: LineChart(
              LineChartData(
                lineTouchData: LineTouchData(
                  touchTooltipData: LineTouchTooltipData(
                    getTooltipColor: (touchedSpot) => AppColors.surface.withOpacity(0.8),
                    getTooltipItems: (List<LineBarSpot> touchedBarSpots) {
                      return touchedBarSpots.map((barSpot) {
                        return LineTooltipItem(
                          'DAY ${barSpot.x.toInt()}\n',
                          AppTextStyles.labelNeon.copyWith(color: AppColors.textPrimary, fontSize: 10),
                          children: [
                            TextSpan(
                              text: currency.format(barSpot.y),
                              style: AppTextStyles.headlineTitle.copyWith(
                                color: AppColors.accent,
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        );
                      }).toList();
                    },
                  ),
                ),
                gridData: const FlGridData(show: false),
                titlesData: FlTitlesData(
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 22,
                      getTitlesWidget: (value, meta) {
                        if (value % 5 != 0) return const SizedBox();
                        return Text(
                          value.toInt().toString(),
                          style: AppTextStyles.labelNeon.copyWith(fontSize: 8, color: AppColors.textMuted),
                        );
                      },
                    ),
                  ),
                  leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                ),
                borderData: FlBorderData(show: false),
                lineBarsData: [
                  LineChartBarData(
                    spots: spots.isEmpty ? [const FlSpot(0, 0)] : spots,
                    isCurved: true,
                    color: AppColors.accent,
                    barWidth: 3,
                    isStrokeCapRound: true,
                    dotData: const FlDotData(show: false),
                    belowBarData: BarAreaData(
                      show: true,
                      gradient: LinearGradient(
                        colors: [
                          AppColors.accent.withOpacity(0.3),
                          AppColors.accent.withOpacity(0),
                        ],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'TOUCH DATA POINTS FOR BIT-LEVEL DETAIL',
            style: AppTextStyles.labelNeon.copyWith(fontSize: 8, color: AppColors.textMuted),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryPie(List<CategoryBreakdown> breakdown) {
    if (breakdown.isEmpty) {
      return NeonCard(
        child: Center(child: Text('NO ALLOCATION DATA', style: AppTextStyles.labelNeon)),
      );
    }

    return NeonCard(
      glowColor: AppColors.primary,
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          SizedBox(
            height: 200,
            child: PieChart(
              PieChartData(
                sectionsSpace: 4,
                centerSpaceRadius: 40,
                sections: breakdown.map((c) => PieChartSectionData(
                  color: Color(c.color),
                  value: c.amount,
                  title: '${c.percentage.toStringAsFixed(0)}%',
                  radius: 50,
                  titleStyle: AppTextStyles.labelNeon.copyWith(fontSize: 10, color: Colors.white),
                )).toList(),
              ),
            ),
          ),
          const SizedBox(height: 24),
          ...breakdown.take(4).map((c) => Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Row(
              children: [
                Container(width: 8, height: 8, color: Color(c.color)),
                const SizedBox(width: 8),
                Text(c.categoryName.toUpperCase(), style: AppTextStyles.labelNeon.copyWith(fontSize: 8, color: AppColors.textSecondary)),
                const Spacer(),
                Text('${c.percentage.toStringAsFixed(1)}%', style: AppTextStyles.labelNeon.copyWith(fontSize: 8)),
              ],
            ),
          )),
        ],
      ),
    );
  }

  Widget _buildInsightCard(String title, String desc, Color color, IconData icon) {
    return NeonCard(
      glowColor: color,
      opacity: 0.2,
      child: Row(
        children: [
          Icon(icon, color: color, size: 28),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: AppTextStyles.headlineTitle.copyWith(fontSize: 14, color: color)),
                const SizedBox(height: 4),
                Text(desc, style: AppTextStyles.bodyMain.copyWith(fontSize: 12)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
