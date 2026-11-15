import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../core/constants/app_colors.dart';
import '../../../providers/statistics_provider.dart';
import '../../widgets/app_card.dart';

class StatisticsScreen extends ConsumerWidget {
  const StatisticsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final statFilter = ref.watch(statisticsFilterProvider);
    final statDataAsync = ref.watch(statisticsDataProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Statistik & Rekap Magang'),
      ),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async {
            ref.invalidate(statisticsDataProvider);
          },
          child: statDataAsync.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (err, _) => Center(child: Text('Gagal memuat statistik: $err')),
            data: (stats) {
              return ListView(
                padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
                children: [
                  // Period Selector Chips
                  Row(
                    children: [
                      _buildPeriodChip(
                        ref,
                        label: 'Bulan Ini',
                        period: StatPeriod.thisMonth,
                        isSelected: statFilter.period == StatPeriod.thisMonth,
                      ),
                      const SizedBox(width: 8),
                      _buildPeriodChip(
                        ref,
                        label: 'Minggu Ini',
                        period: StatPeriod.thisWeek,
                        isSelected: statFilter.period == StatPeriod.thisWeek,
                      ),
                      const SizedBox(width: 8),
                      _buildPeriodChip(
                        ref,
                        label: 'Semua Waktu',
                        period: StatPeriod.allTime,
                        isSelected: statFilter.period == StatPeriod.allTime,
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  // Attendance & Logbook Rate Overview Card
                  AppCard(
                    padding: const EdgeInsets.all(18),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Tingkat Kepatuhan & Produktivitas',
                          style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Expanded(
                              child: _buildProgressTile(
                                label: 'Kehadiran',
                                percentage: stats.attendanceRate,
                                color: AppColors.success,
                                subtitle: '${stats.totalCheckIn}/${stats.totalScheduledWorkdays} Hari',
                              ),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: _buildProgressTile(
                                label: 'Logbook Selesai',
                                percentage: stats.logbookRate,
                                color: AppColors.primary,
                                subtitle: '${stats.totalLogbookCreated}/${stats.totalScheduledWorkdays} Laporan',
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Chart: Tren 7 Hari Terakhir
                  AppCard(
                    padding: const EdgeInsets.all(18),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Tren Aktivitas 7 Hari Terakhir',
                              style: TextStyle(fontSize: 14.5, fontWeight: FontWeight.w700),
                            ),
                            Row(
                              children: [
                                _buildChartLegend('Hadir', AppColors.success),
                                const SizedBox(width: 8),
                                _buildChartLegend('Logbook', AppColors.primary),
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                        SizedBox(
                          height: 160,
                          child: BarChart(
                            BarChartData(
                              alignment: BarChartAlignment.spaceAround,
                              maxY: 3,
                              barTouchData: BarTouchData(enabled: false),
                              titlesData: FlTitlesData(
                                show: true,
                                bottomTitles: AxisTitles(
                                  sideTitles: SideTitles(
                                    showTitles: true,
                                    getTitlesWidget: (val, meta) {
                                      final index = val.toInt();
                                      if (index >= 0 && index < stats.dailyPoints.length) {
                                        return Padding(
                                          padding: const EdgeInsets.only(top: 6),
                                          child: Text(
                                            stats.dailyPoints[index].label,
                                            style: const TextStyle(fontSize: 11),
                                          ),
                                        );
                                      }
                                      return const Text('');
                                    },
                                  ),
                                ),
                                leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                                topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                                rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                              ),
                              gridData: const FlGridData(show: false),
                              borderData: FlBorderData(show: false),
                              barGroups: stats.dailyPoints.asMap().entries.map((entry) {
                                final idx = entry.key;
                                final p = entry.value;

                                return BarChartGroupData(
                                  x: idx,
                                  barRods: [
                                    BarChartRodData(
                                      toY: (p.hasCheckIn && p.hasCheckOut) ? 2.5 : (p.hasCheckIn || p.hasCheckOut ? 1.5 : 0.3),
                                      color: AppColors.success,
                                      width: 10,
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    BarChartRodData(
                                      toY: p.hasLogbook ? 2.5 : 0.3,
                                      color: AppColors.primary,
                                      width: 10,
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                  ],
                                );
                              }).toList(),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Detail Metrics Grid
                  const Text(
                    'Detail Rekapitulasi Presensi & Laporan',
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: _buildMetricItem(
                          title: 'Hari Kerja',
                          value: '${stats.totalScheduledWorkdays}',
                          icon: LucideIcons.calendarDays,
                          color: AppColors.primary,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: _buildMetricItem(
                          title: 'Total Hadir',
                          value: '${stats.totalHadir}',
                          icon: LucideIcons.userCheck,
                          color: AppColors.success,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(
                        child: _buildMetricItem(
                          title: 'Izin',
                          value: '${stats.totalIzin}',
                          icon: LucideIcons.fileClock,
                          color: AppColors.warning,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: _buildMetricItem(
                          title: 'Sakit',
                          value: '${stats.totalSakit}',
                          icon: LucideIcons.heartPulse,
                          color: AppColors.danger,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(
                        child: _buildMetricItem(
                          title: 'Absen Datang',
                          value: '${stats.totalCheckIn}',
                          icon: LucideIcons.logIn,
                          color: AppColors.primary,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: _buildMetricItem(
                          title: 'Absen Pulang',
                          value: '${stats.totalCheckOut}',
                          icon: LucideIcons.logOut,
                          color: AppColors.primaryDark,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(
                        child: _buildMetricItem(
                          title: 'Logbook Disalin',
                          value: '${stats.totalLogbookCopied}',
                          icon: LucideIcons.copy,
                          color: AppColors.info,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: _buildMetricItem(
                          title: 'Laporan Terkirim',
                          value: '${stats.totalLogbookSubmitted}',
                          icon: LucideIcons.send,
                          color: AppColors.success,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildPeriodChip(
    WidgetRef ref, {
    required String label,
    required StatPeriod period,
    required bool isSelected,
  }) {
    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      selectedColor: AppColors.primary,
      labelStyle: TextStyle(
        fontSize: 12.5,
        fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
        color: isSelected ? Colors.white : AppColors.textSecondary,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
        side: BorderSide(
          color: isSelected ? AppColors.primary : AppColors.border,
        ),
      ),
      onSelected: (selected) {
        if (selected) {
          ref.read(statisticsFilterProvider.notifier).state =
              ref.read(statisticsFilterProvider).copyWith(period: period);
        }
      },
    );
  }

  Widget _buildProgressTile({
    required String label,
    required double percentage,
    required Color color,
    required String subtitle,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
            Text(
              '${percentage.toStringAsFixed(1)}%',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: color,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(6),
          child: LinearProgressIndicator(
            value: (percentage / 100).clamp(0.0, 1.0),
            minHeight: 8,
            backgroundColor: const Color(0xFFE2E8F0),
            valueColor: AlwaysStoppedAnimation<Color>(color),
          ),
        ),
        const SizedBox(height: 6),
        Text(
          subtitle,
          style: const TextStyle(fontSize: 11.5, color: AppColors.textSecondary),
        ),
      ],
    );
  }

  Widget _buildChartLegend(String label, Color color) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 4),
        Text(label, style: const TextStyle(fontSize: 11)),
      ],
    );
  }

  Widget _buildMetricItem({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return AppCard(
      padding: const EdgeInsets.all(12),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: color, size: 18),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  value,
                  style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
                ),
                Text(
                  title,
                  style: const TextStyle(fontSize: 11.5, color: AppColors.textSecondary),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
