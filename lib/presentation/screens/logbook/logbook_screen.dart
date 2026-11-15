import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/utils/date_formatter.dart';
import '../../../providers/logbook_provider.dart';
import 'widgets/logbook_form.dart';
import 'widgets/logbook_preview_card.dart';

class LogbookScreen extends ConsumerStatefulWidget {
  const LogbookScreen({super.key});

  @override
  ConsumerState<LogbookScreen> createState() => _LogbookScreenState();
}

class _LogbookScreenState extends ConsumerState<LogbookScreen> {
  final _scrollController = ScrollController();

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final logbookState = ref.watch(logbookProvider);
    final logbookNotifier = ref.read(logbookProvider.notifier);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Generator Logbook'),
        actions: [
          IconButton(
            icon: const Icon(LucideIcons.rotateCcw, size: 20),
            tooltip: 'Segarkan Form',
            onPressed: () {
              logbookNotifier.loadLogbookForDate(logbookState.selectedDate);
            },
          ),
        ],
      ),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async {
            await logbookNotifier.loadLogbookForDate(logbookState.selectedDate);
          },
          child: ListView(
            controller: _scrollController,
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
            children: [
              // Header description
              const Text(
                'Buat Laporan Magang Cepat & Rapi',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 4),
              const Text(
                'Isi ringkasan aktivitas harian Anda, lalu tekan Mulai Buat untuk merangkai format resmi siap salin ke portal.',
                style: TextStyle(
                  fontSize: 12.5,
                  color: AppColors.textSecondary,
                  height: 1.35,
                ),
              ),
              const SizedBox(height: 16),

              // Logbook Input Form
              LogbookForm(
                selectedDate: logbookState.selectedDate,
                initialActivities: logbookState.activities,
                initialLearnings: logbookState.learnings,
                initialObstacles: logbookState.obstacles,
                onDateSelected: (date) {
                  logbookNotifier.selectDate(date);
                },
                onGenerate: (activities, learnings, obstacles) {
                  logbookNotifier.updateFields(
                    activities: activities,
                    learnings: learnings,
                    obstacles: obstacles,
                  );
                  logbookNotifier.buildReport();

                  // Scroll to preview
                  Future.delayed(const Duration(milliseconds: 150), () {
                    _scrollController.animateTo(
                      _scrollController.position.maxScrollExtent,
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeOut,
                    );
                  });
                },
              ),

              const SizedBox(height: 20),

              // Preview Card
              if (logbookState.generatedPreview.isNotEmpty) ...[
                LogbookPreviewCard(
                  reportText: logbookState.generatedPreview,
                  savedEntry: logbookState.currentEntry,
                  onCopy: () async {
                    await logbookNotifier.copyReportToClipboard();
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Laporan berhasil disalin ke clipboard! Siap ditempel ke portal.'),
                          backgroundColor: AppColors.primary,
                        ),
                      );
                    }
                  },
                  onSave: () async {
                    try {
                      await logbookNotifier.saveLogbook();
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              'Logbook tanggal ${DateFormatter.formatIndonesianDateShort(logbookState.selectedDate)} berhasil disimpan!',
                            ),
                            backgroundColor: AppColors.success,
                          ),
                        );
                      }
                    } catch (e) {
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Gagal menyimpan: $e')),
                        );
                      }
                    }
                  },
                  onEdit: () {
                    _scrollController.animateTo(
                      0,
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeOut,
                    );
                  },
                  onMarkSubmitted: () async {
                    try {
                      await logbookNotifier.markAsSubmitted();
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Status logbook ditandai telah dikirim ke portal!'),
                            backgroundColor: AppColors.success,
                          ),
                        );
                      }
                    } catch (e) {
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Gagal memperbarui status: $e')),
                        );
                      }
                    }
                  },
                ),
                const SizedBox(height: 24),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
