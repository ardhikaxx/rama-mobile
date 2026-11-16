import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/utils/app_snackbar.dart';
import '../../../core/utils/date_formatter.dart';
import '../../../core/utils/sentence_expander.dart';
import '../../../data/models/logbook_entry.dart';
import '../../../providers/logbook_provider.dart';
import '../../widgets/app_card.dart';
import 'widgets/logbook_preview_card.dart';

class LogbookScreen extends ConsumerStatefulWidget {
  const LogbookScreen({super.key});

  @override
  ConsumerState<LogbookScreen> createState() => _LogbookScreenState();
}

class _LogbookScreenState extends ConsumerState<LogbookScreen> {
  // 0: Form Input, 1: Hasil & Pratinjau
  int _selectedTab = 0;

  late final TextEditingController _activitiesController;
  late final TextEditingController _learningsController;
  late final TextEditingController _obstaclesController;

  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    final state = ref.read(logbookProvider);
    _activitiesController = TextEditingController(text: state.activities);
    _learningsController = TextEditingController(text: state.learnings);
    _obstaclesController = TextEditingController(text: state.obstacles);

    _activitiesController.addListener(_onTextChanged);
    _learningsController.addListener(_onTextChanged);
    _obstaclesController.addListener(_onTextChanged);
  }

  void _onTextChanged() {
    setState(() {});
  }

  @override
  void dispose() {
    _activitiesController.removeListener(_onTextChanged);
    _learningsController.removeListener(_onTextChanged);
    _obstaclesController.removeListener(_onTextChanged);

    _activitiesController.dispose();
    _learningsController.dispose();
    _obstaclesController.dispose();
    super.dispose();
  }

  void _syncControllersWithState(LogbookState state) {
    if (state.activities != _activitiesController.text && state.activities.isNotEmpty) {
      _activitiesController.text = state.activities;
    }
    if (state.learnings != _learningsController.text && state.learnings.isNotEmpty) {
      _learningsController.text = state.learnings;
    }
    if (state.obstacles != _obstaclesController.text && state.obstacles.isNotEmpty) {
      _obstaclesController.text = state.obstacles;
    }
  }

  @override
  Widget build(BuildContext context) {
    final logbookState = ref.watch(logbookProvider);
    final logbookNotifier = ref.read(logbookProvider.notifier);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // Synchronize if loaded entry from DB, keep user on form by default so it's always visible
    ref.listen<LogbookState>(logbookProvider, (previous, next) {
      if (next.currentEntry != null && previous?.currentEntry == null) {
        _syncControllersWithState(next);
      }
    });

    return Scaffold(
      appBar: AppBar(
        title: const Text('Generator Logbook'),
        actions: [
          IconButton(
            icon: const Icon(LucideIcons.rotateCcw, size: 20),
            tooltip: 'Mulai Ulang Form',
            onPressed: () {
              _activitiesController.clear();
              _learningsController.clear();
              _obstaclesController.clear();
              logbookNotifier.selectDate(DateTime.now());
              setState(() => _selectedTab = 0);
              AppSnackBar.showInfo(
                context,
                message: 'Form logbook telah direset.',
              );
            },
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Top Mode Switcher (Form Pengisian vs Hasil Pratinjau)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 10, 16, 8),
              child: _buildTopTabBar(isDark, logbookState),
            ),

            // Tab Content
            Expanded(
              child: IndexedStack(
                index: _selectedTab,
                children: [
                  _buildFormView(context, isDark, logbookState, logbookNotifier),
                  _buildPreviewView(context, isDark, logbookState, logbookNotifier),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // --------------------------------------------------------------------------
  // TOP TAB BAR: FORM vs PRATINJAU
  // --------------------------------------------------------------------------
  Widget _buildTopTabBar(bool isDark, LogbookState state) {
    final hasSaved = state.currentEntry != null;

    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : const Color(0xFFF1F5F9),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isDark ? AppColors.darkBorder : const Color(0xFFE2E8F0),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          // Tab 1: Form Pengisian
          Expanded(
            child: InkWell(
              onTap: () => setState(() => _selectedTab = 0),
              borderRadius: BorderRadius.circular(10),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                  color: _selectedTab == 0
                      ? AppColors.primary
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: _selectedTab == 0
                      ? [
                          BoxShadow(
                            color: AppColors.primary.withValues(alpha: 0.35),
                            blurRadius: 6,
                            offset: const Offset(0, 2),
                          ),
                        ]
                      : null,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      LucideIcons.fileEdit,
                      size: 15,
                      color: _selectedTab == 0 ? AppColors.onPrimary : (isDark ? AppColors.darkTextSecondary : AppColors.textSecondary),
                    ),
                    const SizedBox(width: 6),
                    Flexible(
                      child: Text(
                        'Form Pengisian',
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 12.5,
                          fontWeight: FontWeight.w700,
                          color: _selectedTab == 0 ? AppColors.onPrimary : (isDark ? AppColors.darkTextSecondary : AppColors.textSecondary),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          const SizedBox(width: 4),

          // Tab 2: Hasil & Pratinjau
          Expanded(
            child: InkWell(
              onTap: () {
                _generatePreviewAndSwitch(false);
              },
              borderRadius: BorderRadius.circular(10),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                  color: _selectedTab == 1
                      ? AppColors.primary
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: _selectedTab == 1
                      ? [
                          BoxShadow(
                            color: AppColors.primary.withValues(alpha: 0.35),
                            blurRadius: 6,
                            offset: const Offset(0, 2),
                          ),
                        ]
                      : null,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      LucideIcons.fileCheck2,
                      size: 15,
                      color: _selectedTab == 1 ? AppColors.onPrimary : (isDark ? AppColors.darkTextSecondary : AppColors.textSecondary),
                    ),
                    const SizedBox(width: 6),
                    Flexible(
                      child: Text(
                        'Hasil & Pratinjau',
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 12.5,
                          fontWeight: FontWeight.w700,
                          color: _selectedTab == 1 ? AppColors.onPrimary : (isDark ? AppColors.darkTextSecondary : AppColors.textSecondary),
                        ),
                      ),
                    ),
                    if (hasSaved) ...[
                      const SizedBox(width: 4),
                      Container(
                        width: 6,
                        height: 6,
                        decoration: const BoxDecoration(
                          color: AppColors.success,
                          shape: BoxShape.circle,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // --------------------------------------------------------------------------
  // TAB 1: FORM PENGISIAN LENGKAP (SIMPLE & BERSIH)
  // --------------------------------------------------------------------------
  Widget _buildFormView(
    BuildContext context,
    bool isDark,
    LogbookState state,
    LogbookNotifier notifier,
  ) {
    final isSaved = state.currentEntry != null;
    final placeholderStyle = TextStyle(
      color: isDark ? AppColors.darkTextPlaceholder : AppColors.textPlaceholder,
      fontSize: 13.5,
      fontWeight: FontWeight.w400,
    );
    final inputTextStyle = TextStyle(
      color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
      fontSize: 14.5,
      fontWeight: FontWeight.w500,
    );

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Status Info Banner if already saved
            if (isSaved)
              Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF14532D).withValues(alpha: 0.3) : const Color(0xFFDCFCE7),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: const Color(0xFF22C55E),
                    width: 1,
                  ),
                ),
                child: Row(
                  children: [
                    const Icon(LucideIcons.checkCircle2, size: 16, color: AppColors.success),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Logbook tanggal ini sudah tersimpan (${state.currentEntry?.statusDisplayName ?? "Tersimpan"}). Anda dapat mengedit isian form di bawah.',
                        style: TextStyle(
                          fontSize: 11.5,
                          fontWeight: FontWeight.w600,
                          color: isDark ? AppColors.darkTextPrimary : const Color(0xFF14532D),
                        ),
                      ),
                    ),
                    TextButton(
                      onPressed: () => setState(() => _selectedTab = 1),
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        minimumSize: Size.zero,
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                      child: const Text('Lihat Hasil', style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w700)),
                    ),
                  ],
                ),
              ),

            // Date Selector Bar
            AppCard(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              onTap: () async {
                final picked = await showDatePicker(
                  context: context,
                  initialDate: state.selectedDate,
                  firstDate: DateTime(2020),
                  lastDate: DateTime(2030),
                );
                if (picked != null) {
                  await notifier.selectDate(picked);
                  final updated = ref.read(logbookProvider);
                  _syncControllersWithState(updated);
                }
              },
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.primaryContainer,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(LucideIcons.calendar, size: 18, color: AppColors.primary),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Tanggal Aktivitas Kegiatan',
                          style: TextStyle(fontSize: 11, color: AppColors.textSecondary),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          DateFormatter.formatIndonesianDate(state.selectedDate),
                          style: const TextStyle(fontSize: 13.5, fontWeight: FontWeight.w700),
                        ),
                      ],
                    ),
                  ),
                  const Icon(LucideIcons.calendarClock, size: 18, color: AppColors.primary),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // =========================================================
            // 1. URAIAN AKTIVITAS FIELD
            // =========================================================
            _buildFieldHeader(
              title: '1. Uraian Aktivitas Magang',
              subtitle: 'Ketik aktivitas sederhana Anda, sistem akan mengubahnya jadi format resmi',
              isRequired: true,
              isDark: isDark,
            ),
            const SizedBox(height: 6),
            TextFormField(
              controller: _activitiesController,
              maxLines: 4,
              style: inputTextStyle,
              validator: (v) {
                if (v == null || v.trim().isEmpty) {
                  return 'Uraian aktivitas magang tidak boleh kosong';
                }
                return null;
              },
              decoration: InputDecoration(
                hintText: 'Contoh: mengikuti orientasi magang dan install autocad...',
                hintStyle: placeholderStyle,
              ),
            ),

            const SizedBox(height: 16),

            // =========================================================
            // 2. PEMBELAJARAN YANG DIPEROLEH FIELD
            // =========================================================
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: _buildFieldHeader(
                    title: '2. Pembelajaran yang Diperoleh',
                    subtitle: 'Otomatis disusun dari aktivitas jika dikosongkan',
                    isDark: isDark,
                  ),
                ),
                TextButton.icon(
                  onPressed: () {
                    final actInput = _activitiesController.text.trim();
                    if (actInput.isEmpty) {
                      AppSnackBar.showWarning(
                        context,
                        message: 'Isi Uraian Aktivitas terlebih dahulu.',
                      );
                      return;
                    }
                    final generated = SentenceExpander.expandLearnings('', actInput);
                    setState(() => _learningsController.text = generated);
                    AppSnackBar.showSuccess(
                      context,
                      message: '✨ Pembelajaran diselaraskan dari aktivitas!',
                    );
                  },
                  icon: const Icon(LucideIcons.sparkles, size: 13),
                  label: const Text('Buat dari Aktivitas', style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w700)),
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            TextFormField(
              controller: _learningsController,
              maxLines: 4,
              style: inputTextStyle,
              decoration: InputDecoration(
                hintText: 'Ketik pemahaman/kompetensi yang didapat (atau biarkan kosong untuk otomatis)...',
                hintStyle: placeholderStyle,
              ),
            ),

            const SizedBox(height: 16),

            // =========================================================
            // 3. KENDALA YANG DIHADAPI FIELD
            // =========================================================
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: _buildFieldHeader(
                    title: '3. Kendala yang Dihadapi',
                    subtitle: 'Ketik kendala Anda atau klik tombol "Tidak Ada Kendala"',
                    isRequired: true,
                    isDark: isDark,
                  ),
                ),
                TextButton.icon(
                  onPressed: () {
                    setState(() {
                      _obstaclesController.text = SentenceExpander.getNextNoObstacleMessage();
                    });
                  },
                  icon: const Icon(LucideIcons.checkCircle2, size: 13, color: AppColors.success),
                  label: const Text('Tidak Ada Kendala', style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w700, color: AppColors.successDark)),
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            TextFormField(
              controller: _obstaclesController,
              maxLines: 3,
              style: inputTextStyle,
              validator: (v) {
                if (v == null || v.trim().isEmpty) {
                  return 'Silakan ketik kendala yang dihadapi atau klik tombol "Tidak Ada Kendala"';
                }
                return null;
              },
              decoration: InputDecoration(
                hintText: 'Ketik kendala di lapangan/kantor, atau klik tombol "Tidak Ada Kendala" di atas...',
                hintStyle: placeholderStyle,
              ),
            ),

            const SizedBox(height: 24),

            // PRIMARY SUBMIT BUTTON
            ElevatedButton.icon(
              onPressed: () => _generatePreviewAndSwitch(true),
              icon: const Icon(LucideIcons.fileCheck2, size: 20),
              label: const Text(
                'Buat & Lihat Hasil Laporan',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: AppColors.onPrimary,
                minimumSize: const Size.fromHeight(50),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  void _generatePreviewAndSwitch(bool validate) {
    if (validate) {
      if (!(_formKey.currentState?.validate() ?? false)) {
        AppSnackBar.showWarning(
          context,
          message: 'Silakan lengkapi kolom yang wajib diisi terlebih dahulu.',
        );
        return;
      }
    }

    final actInput = _activitiesController.text.trim();
    String learnInput = _learningsController.text.trim();
    if (learnInput.isEmpty && actInput.isNotEmpty) {
      learnInput = SentenceExpander.expandLearnings('', actInput);
    }

    final obsInput = _obstaclesController.text.trim();

    final finalActivities = SentenceExpander.expandActivities(actInput);
    final finalLearnings = SentenceExpander.expandLearnings(learnInput, actInput);
    final finalObstacles = SentenceExpander.expandObstacles(obsInput);

    _activitiesController.text = finalActivities;
    _learningsController.text = finalLearnings;
    _obstaclesController.text = finalObstacles;

    final notifier = ref.read(logbookProvider.notifier);
    notifier.updateFields(
      activities: finalActivities,
      learnings: finalLearnings,
      obstacles: finalObstacles,
    );
    notifier.buildReport(
      activities: finalActivities,
      learnings: finalLearnings,
      obstacles: finalObstacles,
    );

    setState(() => _selectedTab = 1);
  }

  // --------------------------------------------------------------------------
  // TAB 2: PRATINJAU & HASIL LAPORAN RESMI
  // --------------------------------------------------------------------------
  Widget _buildPreviewView(
    BuildContext context,
    bool isDark,
    LogbookState state,
    LogbookNotifier notifier,
  ) {
    final activitiesText = state.activities.isNotEmpty
        ? state.activities
        : SentenceExpander.expandActivities(_activitiesController.text);
    final learningsText = state.learnings.isNotEmpty
        ? state.learnings
        : SentenceExpander.expandLearnings(_learningsController.text, _activitiesController.text);
    final obstaclesText = state.obstacles.isNotEmpty
        ? state.obstacles
        : SentenceExpander.expandObstacles(_obstaclesController.text);

    final previewText = state.generatedPreview.isNotEmpty
        ? state.generatedPreview
        : LogbookEntry.generateTemplateText(
            date: state.selectedDate,
            activities: activitiesText,
            learnings: learningsText,
            obstacles: obstaclesText,
          );

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Pratinjau & Salin Laporan Magang',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
              ),
              OutlinedButton.icon(
                onPressed: () => setState(() => _selectedTab = 0),
                icon: const Icon(LucideIcons.edit3, size: 14),
                label: const Text('Edit Form', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700)),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          const Text(
            'Laporan telah tersusun dalam format resmi kedinasan. Anda dapat menyalin masing-masing bagian untuk kolom portal magang, atau menyalin seluruh format lengkap.',
            style: TextStyle(fontSize: 12.5, color: AppColors.textSecondary, height: 1.35),
          ),

          const SizedBox(height: 14),

          // Separate Section Preview & Copy Cards
          LogbookPreviewCard(
            activities: activitiesText,
            learnings: learningsText,
            obstacles: obstaclesText,
            reportText: previewText,
            savedEntry: state.currentEntry,
            onCopyActivities: () async {
              await Clipboard.setData(ClipboardData(text: activitiesText));
              if (context.mounted) {
                AppSnackBar.showSuccess(
                  context,
                  message: 'Uraian Aktivitas berhasil disalin ke clipboard!',
                );
              }
            },
            onCopyLearnings: () async {
              await Clipboard.setData(ClipboardData(text: learningsText));
              if (context.mounted) {
                AppSnackBar.showSuccess(
                  context,
                  message: 'Pembelajaran yang Diperoleh berhasil disalin ke clipboard!',
                );
              }
            },
            onCopyObstacles: () async {
              await Clipboard.setData(ClipboardData(text: obstaclesText));
              if (context.mounted) {
                AppSnackBar.showWarning(
                  context,
                  message: 'Kendala yang Dihadapi berhasil disalin ke clipboard!',
                );
              }
            },
            onCopyAll: () async {
              await notifier.copyReportToClipboard();
              if (context.mounted) {
                AppSnackBar.showSuccess(
                  context,
                  message: 'Seluruh format logbook lengkap berhasil disalin ke clipboard!',
                );
              }
            },
            onSave: () async {
              try {
                await notifier.saveLogbook();
                if (context.mounted) {
                  AppSnackBar.showSuccess(
                    context,
                    message: 'Logbook tanggal ${DateFormatter.formatIndonesianDateShort(state.selectedDate)} berhasil disimpan!',
                  );
                }
              } catch (e) {
                if (context.mounted) {
                  AppSnackBar.showError(
                    context,
                    message: 'Gagal menyimpan: $e',
                  );
                }
              }
            },
            onEdit: () {
              setState(() => _selectedTab = 0);
            },
            onMarkSubmitted: () async {
              try {
                await notifier.markAsSubmitted();
                if (context.mounted) {
                  AppSnackBar.showSuccess(
                    context,
                    message: 'Status logbook ditandai telah dikirim ke portal!',
                  );
                }
              } catch (e) {
                if (context.mounted) {
                  AppSnackBar.showError(
                    context,
                    message: 'Gagal memperbarui status: $e',
                  );
                }
              }
            },
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  // --------------------------------------------------------------------------
  // HELPER WIDGETS
  // --------------------------------------------------------------------------
  Widget _buildFieldHeader({
    required String title,
    String? subtitle,
    bool isRequired = false,
    bool isDark = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text.rich(
          TextSpan(
            text: title,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
            ),
            children: [
              if (isRequired)
                const TextSpan(
                  text: ' *',
                  style: TextStyle(color: AppColors.danger, fontWeight: FontWeight.bold),
                ),
            ],
          ),
        ),
        if (subtitle != null && subtitle.isNotEmpty) ...[
          const SizedBox(height: 2),
          Text(
            subtitle,
            style: const TextStyle(fontSize: 11.5, color: AppColors.textSecondary),
          ),
        ],
      ],
    );
  }
}
