import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/utils/app_snackbar.dart';
import '../../../core/utils/date_formatter.dart';
import '../../../data/models/activity_history.dart';
import '../../../data/models/attendance_record.dart';
import '../../../data/models/logbook_entry.dart';
import '../../../providers/app_providers.dart';
import '../../../providers/attendance_provider.dart';
import '../../../providers/history_provider.dart';
import '../../../providers/logbook_provider.dart';
import '../../widgets/app_card.dart';
import '../../widgets/confirm_dialog.dart';
import '../../widgets/empty_state_view.dart';
import '../attendance/widgets/attendance_dialog.dart';
import 'widgets/history_attendance_tile.dart';
import 'widgets/history_filter_bottom_sheet.dart';
import 'widgets/history_logbook_tile.dart';

class HistoryScreen extends ConsumerStatefulWidget {
  final Function(int tabIndex)? onNavigateTab;

  const HistoryScreen({super.key, this.onNavigateTab});

  @override
  ConsumerState<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends ConsumerState<HistoryScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    final initialTab = ref.read(historyFilterProvider).selectedTabIndex;
    _tabController = TabController(length: 3, vsync: this, initialIndex: initialTab);
    _tabController.addListener(() {
      if (!_tabController.indexIsChanging) {
        ref.read(historyFilterProvider.notifier).setTab(_tabController.index);
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final filter = ref.watch(historyFilterProvider);
    final historyNotifier = ref.read(historyFilterProvider.notifier);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Riwayat Aktivitas'),
        bottom: TabBar(
          controller: _tabController,
          labelColor: isDark ? AppColors.primary : AppColors.primaryDark,
          unselectedLabelColor: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary,
          indicatorColor: AppColors.primary,
          indicatorWeight: 3,
          labelStyle: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13.5),
          tabs: const [
            Tab(text: 'Absensi'),
            Tab(text: 'Logbook'),
            Tab(text: 'Semua Aktivitas'),
          ],
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Search & Filter Bar
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _searchController,
                      onChanged: (val) => historyNotifier.setSearchQuery(val),
                      decoration: InputDecoration(
                        hintText: 'Cari riwayat kegiatan...',
                        prefixIcon: const Icon(LucideIcons.search, size: 18),
                        suffixIcon: _searchController.text.isNotEmpty
                            ? IconButton(
                                icon: const Icon(LucideIcons.x, size: 16),
                                onPressed: () {
                                  _searchController.clear();
                                  historyNotifier.setSearchQuery('');
                                },
                              )
                            : null,
                        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton.filledTonal(
                    onPressed: () {
                      HistoryFilterBottomSheet.show(
                        context,
                        currentFilter: filter,
                        onApply: (newFilter) {
                          historyNotifier.setDateRange(newFilter.startDate, newFilter.endDate);
                          historyNotifier.setStatusFilter(newFilter.selectedStatus);
                          historyNotifier.setTypeFilter(newFilter.selectedType);
                        },
                      );
                    },
                    icon: const Icon(LucideIcons.slidersHorizontal, size: 19),
                    tooltip: 'Filter Riwayat',
                  ),
                ],
              ),
            ),

            // Active Filter Pill
            if (filter.startDate != null ||
                filter.selectedStatus != 'all' ||
                filter.searchQuery.isNotEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                child: Row(
                  children: [
                    const Text(
                      'Filter Aktif: ',
                      style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w600),
                    ),
                    Expanded(
                      child: Text(
                        [
                          if (filter.startDate != null)
                            '${DateFormatter.formatIndonesianDateShort(filter.startDate!)} s/d ${filter.endDate != null ? DateFormatter.formatIndonesianDateShort(filter.endDate!) : "Kini"}',
                          if (filter.selectedStatus != 'all') 'Status: ${filter.selectedStatus}',
                          if (filter.searchQuery.isNotEmpty) '"${filter.searchQuery}"',
                        ].join(' • '),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontSize: 11.5, color: AppColors.primary),
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        _searchController.clear();
                        historyNotifier.resetFilters();
                      },
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 6),
                        minimumSize: Size.zero,
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                      child: const Text('Hapus Filter', style: TextStyle(fontSize: 11.5)),
                    ),
                  ],
                ),
              ),

            // Tab Views
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _buildAttendanceTab(),
                  _buildLogbookTab(),
                  _buildAllActivitiesTab(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAttendanceTab() {
    final attendanceAsync = ref.watch(attendanceHistoryListProvider);

    return RefreshIndicator(
      onRefresh: () async {
        ref.invalidate(attendanceHistoryListProvider);
      },
      child: attendanceAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(child: Text('Gagal memuat: $err')),
        data: (records) {
          if (records.isEmpty) {
            return const EmptyStateView(
              icon: LucideIcons.calendarX2,
              title: 'Belum Ada Riwayat Absensi',
              description: 'Riwayat absensi datang dan pulang yang Anda konfirmasi akan tercatat di sini.',
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 95),
            itemCount: records.length,
            itemBuilder: (ctx, index) {
              final record = records[index];
              return HistoryAttendanceTile(
                record: record,
                onEdit: () => _handleEditAttendance(record),
                onDelete: () => _handleDeleteAttendance(record),
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildLogbookTab() {
    final logbookAsync = ref.watch(logbookHistoryListProvider);

    return RefreshIndicator(
      onRefresh: () async {
        ref.invalidate(logbookHistoryListProvider);
      },
      child: logbookAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(child: Text('Gagal memuat: $err')),
        data: (entries) {
          if (entries.isEmpty) {
            return const EmptyStateView(
              icon: LucideIcons.fileQuestion,
              title: 'Belum Ada Riwayat Logbook',
              description: 'Laporan aktivitas magang yang Anda simpan akan muncul dan terorganisir di sini.',
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 95),
            itemCount: entries.length,
            itemBuilder: (ctx, index) {
              final entry = entries[index];
              return HistoryLogbookTile(
                entry: entry,
                onEdit: () {
                  final date = DateFormatter.parseDateKey(entry.date);
                  ref.read(logbookProvider.notifier).selectDate(date);
                  if (widget.onNavigateTab != null) {
                    widget.onNavigateTab!(2); // Navigate to Logbook tab
                  }
                },
                onDelete: () => _handleDeleteLogbook(entry),
                onCopied: () {
                  AppSnackBar.showSuccess(
                    context,
                    message: 'Laporan logbook disalin ke clipboard!',
                  );
                  ref.invalidate(logbookHistoryListProvider);
                },
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildAllActivitiesTab() {
    final historyAsync = ref.watch(allActivityHistoryListProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return RefreshIndicator(
      onRefresh: () async {
        ref.invalidate(allActivityHistoryListProvider);
      },
      child: historyAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(child: Text('Gagal memuat: $err')),
        data: (activities) {
          if (activities.isEmpty) {
            return const EmptyStateView(
              icon: LucideIcons.activity,
              title: 'Belum Ada Jejak Aktivitas',
              description: 'Semua log perubahan absensi, logbook, dan pengaturan dicatat secara otomatis di sini.',
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 95),
            itemCount: activities.length,
            itemBuilder: (ctx, index) {
              final act = activities[index];
              final timeStr = DateFormatter.formatTime(act.timestamp);
              final dateStr = DateFormatter.formatIndonesianDateShort(act.timestamp);

              return Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: AppCard(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: AppColors.primaryContainer,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(LucideIcons.sparkles, color: AppColors.primary, size: 16),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              act.title,
                              style: const TextStyle(
                                fontSize: 13.5,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              act.description,
                              style: TextStyle(
                                fontSize: 12,
                                color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary,
                                height: 1.35,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '$dateStr • $timeStr WIB',
                              style: const TextStyle(
                                fontSize: 11,
                                color: AppColors.textTertiary,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 4),
                      PopupMenuButton<String>(
                        icon: const Icon(LucideIcons.moreVertical, size: 16, color: AppColors.textTertiary),
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                        tooltip: 'Opsi Aktivitas',
                        onSelected: (val) {
                          if (val == 'open_logbook') {
                            if (widget.onNavigateTab != null) {
                              widget.onNavigateTab!(2);
                            }
                          } else if (val == 'delete') {
                            _handleDeleteActivity(act);
                          }
                        },
                        itemBuilder: (context) => [
                          if (act.metadata?.startsWith('entry_id:') == true)
                            const PopupMenuItem(
                              value: 'open_logbook',
                              child: Row(
                                children: [
                                  Icon(LucideIcons.fileText, size: 15, color: AppColors.primary),
                                  SizedBox(width: 8),
                                  Text('Buka Logbook', style: TextStyle(fontSize: 12.5)),
                                ],
                              ),
                            ),
                          const PopupMenuItem(
                            value: 'delete',
                            child: Row(
                              children: [
                                Icon(LucideIcons.trash2, size: 15, color: AppColors.danger),
                                SizedBox(width: 8),
                                Text('Hapus Log', style: TextStyle(fontSize: 12.5, color: AppColors.danger)),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  void _handleEditAttendance(AttendanceRecord record) {
    AttendanceDialog.show(
      context,
      type: record.type,
      initialRecord: record,
      onConfirmed: (status, notes) async {
        try {
          final updated = record.copyWith(
            status: status,
            notes: notes,
            updatedAt: DateTime.now(),
          );
          await ref.read(attendanceProvider.notifier).updateRecord(updated);
          ref.invalidate(attendanceHistoryListProvider);
          if (mounted) {
            AppSnackBar.showSuccess(
              context,
              message: 'Data absensi berhasil diperbarui!',
            );
          }
        } catch (e) {
          if (mounted) {
            AppSnackBar.showError(
              context,
              message: e.toString(),
            );
          }
        }
      },
    );
  }

  void _handleDeleteAttendance(AttendanceRecord record) async {
    final confirmed = await ConfirmDialog.show(
      context,
      title: 'Hapus Rekaman Absensi?',
      message: 'Apakah Anda yakin ingin menghapus data absensi ${record.typeDisplayName} untuk tanggal ${record.date}?',
      confirmText: 'Hapus Data',
      isDestructive: true,
      icon: LucideIcons.trash2,
    );

    if (confirmed == true && record.id != null) {
      await ref.read(attendanceProvider.notifier).deleteRecord(record.id!);
      ref.invalidate(attendanceHistoryListProvider);
      if (mounted) {
        AppSnackBar.showInfo(
          context,
          message: 'Data absensi telah dihapus.',
        );
      }
    }
  }

  void _handleDeleteLogbook(LogbookEntry entry) async {
    final confirmed = await ConfirmDialog.show(
      context,
      title: 'Hapus Laporan Logbook?',
      message: 'Apakah Anda yakin ingin menghapus logbook tanggal ${entry.date}?',
      confirmText: 'Hapus Laporan',
      isDestructive: true,
      icon: LucideIcons.trash2,
    );

    if (confirmed == true && entry.id != null) {
      final repo = ref.read(logbookRepositoryProvider);
      await repo.deleteLogbook(entry.id!);
      ref.invalidate(logbookHistoryListProvider);
      if (mounted) {
        AppSnackBar.showInfo(
          context,
          message: 'Laporan logbook telah dihapus.',
        );
      }
    }
  }

  void _handleDeleteActivity(ActivityHistory act) async {
    final confirmed = await ConfirmDialog.show(
      context,
      title: 'Hapus Log Aktivitas?',
      message: 'Apakah Anda yakin ingin menghapus catatan log aktivitas ini?',
      confirmText: 'Hapus Log',
      isDestructive: true,
      icon: LucideIcons.trash2,
    );

    if (confirmed == true && act.id != null) {
      final repo = ref.read(activityHistoryRepositoryProvider);
      await repo.deleteActivity(act.id!);
      ref.invalidate(allActivityHistoryListProvider);
      if (mounted) {
        AppSnackBar.showInfo(
          context,
          message: 'Catatan log aktivitas telah dihapus.',
        );
      }
    }
  }
}
