import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/theme/app_theme.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/widgets/async_state_widgets.dart';
import '../../../core/widgets/brand_logo.dart';
import '../../shared/providers.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dashboardAsync = ref.watch(dashboardProvider);
    return Scaffold(
      appBar: AppBar(
        title: const JbsFintechWordmark(markSize: 32, textSize: 22),
      ),
      body: RefreshIndicator(
        onRefresh: () => ref.refresh(dashboardProvider.future),
        child: dashboardAsync.when(
          loading: () => ListView(
            padding: const EdgeInsets.all(20),
            children: const [
              LoadingCard(height: 160),
              SizedBox(height: 16),
              LoadingCard(height: 110),
              SizedBox(height: 16),
              LoadingCard(height: 240),
            ],
          ),
          error: (error, _) => ErrorStateView(
            message: error.toString(),
            onRetry: () => ref.refresh(dashboardProvider),
          ),
          data: (dashboard) {
            if (dashboard.accountBalances.isEmpty &&
                dashboard.topExpenseCategories.isEmpty) {
              return ListView(
                children: const [
                  SizedBox(height: 140),
                  EmptyStateView(
                    title: 'Belum ada data',
                    message:
                        'Mulai catat transaksi agar ringkasan finansial muncul.',
                  ),
                ],
              );
            }

            return ListView(
              padding: const EdgeInsets.all(20),
              children: [
                _BalanceHeroCard(
                  name: dashboard.user.name,
                  totalBalance: dashboard.totalBalance,
                  income: dashboard.totalIncome,
                  expense: dashboard.totalExpense,
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: _SummaryCard(
                        title: 'Saldo Awal',
                        value: AppFormatters.currency(dashboard.initialBalance),
                        icon: Icons.flag_rounded,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _SummaryCard(
                        title: 'Transaksi Hari Ini',
                        value: '${dashboard.transactionsToday}',
                        icon: Icons.today_rounded,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Ringkasan Bulanan',
                          style: Theme.of(context).textTheme.titleMedium
                              ?.copyWith(fontWeight: FontWeight.w700),
                        ),
                        const SizedBox(height: 18),
                        SizedBox(
                          height: 180,
                          child: BarChart(
                            BarChartData(
                              titlesData: FlTitlesData(
                                topTitles: const AxisTitles(),
                                rightTitles: const AxisTitles(),
                                leftTitles: const AxisTitles(),
                                bottomTitles: AxisTitles(
                                  sideTitles: SideTitles(
                                    showTitles: true,
                                    getTitlesWidget: (value, meta) =>
                                        Text(value == 0 ? 'Masuk' : 'Keluar'),
                                  ),
                                ),
                              ),
                              borderData: FlBorderData(show: false),
                              barGroups: [
                                BarChartGroupData(
                                  x: 0,
                                  barRods: [
                                    BarChartRodData(
                                      toY: dashboard.incomeThisMonth.toDouble(),
                                      borderRadius: BorderRadius.circular(8),
                                      color: Theme.of(
                                        context,
                                      ).extension<AppPalette>()!.success,
                                      width: 30,
                                    ),
                                  ],
                                ),
                                BarChartGroupData(
                                  x: 1,
                                  barRods: [
                                    BarChartRodData(
                                      toY: dashboard.expenseThisMonth
                                          .toDouble(),
                                      borderRadius: BorderRadius.circular(8),
                                      color: Theme.of(
                                        context,
                                      ).extension<AppPalette>()!.danger,
                                      width: 30,
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Kategori Pengeluaran Teratas',
                          style: Theme.of(context).textTheme.titleMedium
                              ?.copyWith(fontWeight: FontWeight.w700),
                        ),
                        const SizedBox(height: 18),
                        if (dashboard.topExpenseCategories.isEmpty)
                          const Text(
                            'Belum ada kategori pengeluaran untuk divisualkan.',
                          )
                        else
                          SizedBox(
                            height: 220,
                            child: PieChart(
                              PieChartData(
                                centerSpaceRadius: 42,
                                sectionsSpace: 4,
                                sections: [
                                  for (final (index, item)
                                      in dashboard.topExpenseCategories.indexed)
                                    PieChartSectionData(
                                      color:
                                          Colors.primaries[index %
                                              Colors.primaries.length],
                                      value: item.total.toDouble(),
                                      title: item.category?.name ?? 'Lainnya',
                                      radius: 62,
                                      titleStyle: const TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.w700,
                                        fontSize: 10,
                                      ),
                                    ),
                                ],
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'Saldo per Akun',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 12),
                for (final account in dashboard.accountBalances)
                  Card(
                    child: ListTile(
                      title: Text(account.name),
                      subtitle: Text(account.type.toUpperCase()),
                      trailing: Text(
                        AppFormatters.currency(account.balance),
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _BalanceHeroCard extends StatelessWidget {
  const _BalanceHeroCard({
    required this.name,
    required this.totalBalance,
    required this.income,
    required this.expense,
  });

  final String name;
  final int totalBalance;
  final int income;
  final int expense;

  @override
  Widget build(BuildContext context) {
    final palette = Theme.of(context).extension<AppPalette>()!;
    return Card(
      clipBehavior: Clip.antiAlias,
      child: Stack(
        children: [
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Theme.of(context).colorScheme.primary,
                    const Color(0xFF0B6A88),
                    Theme.of(context).colorScheme.secondary,
                  ],
                ),
              ),
            ),
          ),
          Positioned.fill(
            child: CustomPaint(
              painter: _HeroPatternPainter(
                color: Colors.white.withValues(alpha: 0.16),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Halo, $name',
                  style: Theme.of(
                    context,
                  ).textTheme.titleMedium?.copyWith(color: Colors.white70),
                ),
                const SizedBox(height: 10),
                Text(
                  AppFormatters.currency(totalBalance),
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Kondisi keuangan Anda hari ini',
                  style: Theme.of(
                    context,
                  ).textTheme.bodyMedium?.copyWith(color: Colors.white70),
                ),
                const SizedBox(height: 18),
                Row(
                  children: [
                    Expanded(
                      child: _HeroMetric(
                        label: 'Pemasukan',
                        value: AppFormatters.currency(income),
                        color: palette.success,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _HeroMetric(
                        label: 'Pengeluaran',
                        value: AppFormatters.currency(expense),
                        color: palette.danger,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _HeroPatternPainter extends CustomPainter {
  const _HeroPatternPainter({required this.color});

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.4
      ..strokeCap = StrokeCap.round;

    final center = Offset(size.width * 0.78, size.height * 0.28);
    canvas.drawCircle(center, size.width * 0.22, paint);
    canvas.drawCircle(center, size.width * 0.14, paint);

    final arrow = Path()
      ..moveTo(size.width * 0.58, size.height * 0.72)
      ..lineTo(size.width * 0.93, size.height * 0.23)
      ..lineTo(size.width * 0.86, size.height * 0.25)
      ..moveTo(size.width * 0.93, size.height * 0.23)
      ..lineTo(size.width * 0.91, size.height * 0.34);
    canvas.drawPath(arrow, paint);
  }

  @override
  bool shouldRepaint(covariant _HeroPatternPainter oldDelegate) {
    return oldDelegate.color != color;
  }
}

class _HeroMetric extends StatelessWidget {
  const _HeroMetric({
    required this.label,
    required this.value,
    required this.color,
  });

  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(radius: 6, backgroundColor: color),
                const SizedBox(width: 8),
                Text(label, style: const TextStyle(color: Colors.white70)),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              value,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SummaryCard extends StatelessWidget {
  const _SummaryCard({
    required this.title,
    required this.value,
    required this.icon,
  });

  final String title;
  final String value;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: Theme.of(context).colorScheme.primary),
            const SizedBox(height: 12),
            Text(title, style: Theme.of(context).textTheme.bodyMedium),
            const SizedBox(height: 6),
            Text(
              value,
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
            ),
          ],
        ),
      ),
    );
  }
}
