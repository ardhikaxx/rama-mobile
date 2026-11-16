import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/utils/date_formatter.dart';
import '../../../core/utils/sentence_expander.dart';
import '../../../data/models/logbook_entry.dart';
import '../../../providers/logbook_provider.dart';
import '../../widgets/app_card.dart';
import 'widgets/logbook_preview_card.dart';
import 'widgets/logbook_step_indicator.dart';

class LogbookScreen extends ConsumerStatefulWidget {
  const LogbookScreen({super.key});

  @override
  ConsumerState<LogbookScreen> createState() => _LogbookScreenState();
}

class _LogbookScreenState extends ConsumerState<LogbookScreen> {
  final _pageController = PageController();
  int _currentStep = 0;

  late final TextEditingController _activitiesController;
  late final TextEditingController _learningsController;
  late final TextEditingController _obstaclesController;

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
    _pageController.dispose();
    super.dispose();
  }

  void _goToStep(int step) {
    setState(() {
      _currentStep = step;
    });
    _pageController.animateToPage(
      step,
      duration: const Duration(milliseconds: 280),
      curve: Curves.easeInOutCubic,
    );
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

    // Synchronize if loaded entry from DB
    ref.listen<LogbookState>(logbookProvider, (previous, next) {
      if (next.currentEntry != null && previous?.currentEntry == null) {
        _syncControllersWithState(next);
        if (next.generatedPreview.isNotEmpty && _currentStep == 0) {
          _goToStep(3);
        }
      }
    });

    return Scaffold(
      appBar: AppBar(
        title: const Text('Generator Logbook'),
        actions: [
          IconButton(
            icon: const Icon(LucideIcons.rotateCcw, size: 20),
            tooltip: 'Mulai Ulang / Segarkan',
            onPressed: () {
              _activitiesController.clear();
              _learningsController.clear();
              _obstaclesController.clear();
              logbookNotifier.selectDate(DateTime.now());
              _goToStep(0);
            },
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Top Stepper Navigation Header
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 10, 16, 8),
              child: LogbookStepIndicator(
                currentStep: _currentStep,
                onStepTapped: (step) => _goToStep(step),
              ),
            ),

            // Step Content Pages
            Expanded(
              child: PageView(
                controller: _pageController,
                physics: const NeverScrollableScrollPhysics(),
                children: [
                  _buildStepActivities(context, isDark, logbookState, logbookNotifier),
                  _buildStepLearnings(context, isDark, logbookState, logbookNotifier),
                  _buildStepObstacles(context, isDark, logbookState, logbookNotifier),
                  _buildStepPreview(context, isDark, logbookState, logbookNotifier),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // -------------------------------------------------------------
  // STEP 1: URAIAN AKTIVITAS
  // -------------------------------------------------------------
  Widget _buildStepActivities(
    BuildContext context,
    bool isDark,
    LogbookState state,
    LogbookNotifier notifier,
  ) {
    final expandedText = SentenceExpander.expandActivities(_activitiesController.text);

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(18, 12, 18, 95),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Date Selector Header Card
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

          // Header Instruction
          const Text(
            'Langkah 1: Uraian Aktivitas Magang',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 4),
          const Text(
            'Ketik beberapa kata atau poin kegiatan survei & pemetaan hari ini. RAMA akan otomatis merangkainya menjadi kalimat formal berstandar Kantor Pertanahan.',
            style: TextStyle(fontSize: 12.5, color: AppColors.textSecondary, height: 1.35),
          ),

          const SizedBox(height: 14),

          // Text Field
          TextFormField(
            controller: _activitiesController,
            maxLines: 3,
            decoration: const InputDecoration(
              hintText: 'Ketik beberapa kata, contoh:\n• pengukuran bidang tanah GNSS RTK di Kec. Maesan\n• verifikasi tanda batas patok dan saksi batas\n• digitasi peta bidang dan input GeoKKP',
            ),
          ),

          const SizedBox(height: 10),

          // Quick Chips for Activities
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: [
              _buildChip('Pengukuran Lapangan GNSS RTK', _activitiesController, isDark),
              _buildChip('Pemasangan Patok Batas Bidang', _activitiesController, isDark),
              _buildChip('Pengolahan Data Koordinat TM-3°', _activitiesController, isDark),
              _buildChip('Digitasi Peta Bidang GeoKKP', _activitiesController, isDark),
              _buildChip('Pembuatan Gambar Ukur (GU)', _activitiesController, isDark),
              _buildChip('Pengecekan Warkah & Ploting PBT', _activitiesController, isDark),
            ],
          ),

          const SizedBox(height: 14),

          // Live Expansion Preview Box
          _buildLiveExpansionBox(
            title: 'Kalimat Tambahan Otomatis dari Sistem:',
            expandedText: expandedText,
            placeholder: 'Ketik beberapa kata di atas untuk melihat kalimat formal otomatis yang dirangkai sistem...',
            isDark: isDark,
          ),

          const SizedBox(height: 20),

          // Navigation Button
          ElevatedButton.icon(
            onPressed: () {
              if (_activitiesController.text.trim().isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Silakan ketik beberapa kata uraian aktivitas terlebih dahulu.'),
                    backgroundColor: AppColors.warning,
                  ),
                );
                return;
              }
              _goToStep(1);
            },
            icon: const Icon(LucideIcons.arrowRight, size: 18),
            label: const Text('Lanjut ke Pembelajaran (2/3)', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700)),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              minimumSize: const Size.fromHeight(48),
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  // -------------------------------------------------------------
  // STEP 2: PEMBELAJARAN YANG DIPEROLEH
  // -------------------------------------------------------------
  Widget _buildStepLearnings(
    BuildContext context,
    bool isDark,
    LogbookState state,
    LogbookNotifier notifier,
  ) {
    final expandedText = SentenceExpander.expandLearnings(_learningsController.text);

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(18, 12, 18, 95),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Langkah 2: Pembelajaran yang Diperoleh',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 4),
          const Text(
            'Ketik wawasan teknis, regulasi kadastral, atau keterampilan survei pemetaan yang Anda peroleh hari ini. Sistem akan memperluasnya menjadi kalimat pembelajaran formal.',
            style: TextStyle(fontSize: 12.5, color: AppColors.textSecondary, height: 1.35),
          ),

          const SizedBox(height: 14),

          // Text Field
          TextFormField(
            controller: _learningsController,
            maxLines: 3,
            decoration: const InputDecoration(
              hintText: 'Contoh: sistem proyeksi TM-3 BPN, metode GNSS RTK & Total Station, azas contradictoire delimitatie, alur integrasi GeoKKP',
            ),
          ),

          const SizedBox(height: 10),

          // Quick Chips for Learnings
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: [
              _buildChip('Sistem Proyeksi TM-3° BPN', _learningsController, isDark),
              _buildChip('Metode GNSS RTK & Total Station', _learningsController, isDark),
              _buildChip('Azas Contradictoire Delimitatie', _learningsController, isDark),
              _buildChip('Standar Gambar Ukur & GeoKKP', _learningsController, isDark),
              _buildChip('Regulasi Survei Kadastral ATR/BPN', _learningsController, isDark),
              _buildChip('Komunikasi Lapangan Bersama Pamong', _learningsController, isDark),
            ],
          ),

          const SizedBox(height: 14),

          // Live Expansion Preview Box
          _buildLiveExpansionBox(
            title: 'Kalimat Tambahan Otomatis dari Sistem:',
            expandedText: expandedText,
            placeholder: 'Ketik topik pembelajaran di atas untuk melihat kalimat formal otomatis yang dirangkai sistem...',
            isDark: isDark,
          ),

          const SizedBox(height: 20),

          // Navigation Buttons: Back and Forward
          Row(
            children: [
              Expanded(
                flex: 2,
                child: OutlinedButton.icon(
                  onPressed: () => _goToStep(0),
                  icon: const Icon(LucideIcons.arrowLeft, size: 16),
                  label: const Text('Kembali'),
                  style: OutlinedButton.styleFrom(
                    minimumSize: const Size.fromHeight(48),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                flex: 3,
                child: ElevatedButton.icon(
                  onPressed: () {
                    if (_learningsController.text.trim().isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Silakan ketik pembelajaran yang diperoleh terlebih dahulu.'),
                          backgroundColor: AppColors.warning,
                        ),
                      );
                      return;
                    }
                    _goToStep(2);
                  },
                  icon: const Icon(LucideIcons.arrowRight, size: 18),
                  label: const Text('Lanjut ke Kendala (3/3)', style: TextStyle(fontSize: 13.5, fontWeight: FontWeight.w700)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    minimumSize: const Size.fromHeight(48),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  // -------------------------------------------------------------
  // STEP 3: KENDALA YANG DIHADAPI
  // -------------------------------------------------------------
  Widget _buildStepObstacles(
    BuildContext context,
    bool isDark,
    LogbookState state,
    LogbookNotifier notifier,
  ) {
    final expandedText = SentenceExpander.expandObstacles(_obstaclesController.text);

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(18, 12, 18, 95),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Langkah 3: Kendala yang Dihadapi',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 4),
          const Text(
            'Ketik kendala teknis atau lapangan jika ada hambatan. Jika kegiatan berjalan lancar, Anda dapat memilih salah satu template resmi di bawah.',
            style: TextStyle(fontSize: 12.5, color: AppColors.textSecondary, height: 1.35),
          ),

          const SizedBox(height: 14),

          // Quick Action Card: Pilihan Template Tidak Ada Kendala
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: isDark ? AppColors.darkSurfaceElevated : const Color(0xFFF0FDF4),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: const Color(0xFF86EFAC),
                width: 1.2,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(LucideIcons.sparkles, size: 18, color: AppColors.success),
                    const SizedBox(width: 8),
                    const Expanded(
                      child: Text(
                        'Pilihan Cepat: Hari Ini Lancar (Tanpa Kendala)',
                        style: TextStyle(fontSize: 13.5, fontWeight: FontWeight.w700, color: AppColors.successDark),
                      ),
                    ),
                    InkWell(
                      onTap: () {
                        setState(() {
                          _obstaclesController.text = SentenceExpander.defaultNoObstacle;
                        });
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppColors.success,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Text(
                          'Pilih Utama',
                          style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: Colors.white),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                const Text(
                  'Klik salah satu template kalimat di bawah jika seluruh kegiatan survei dan pemetaan berjalan lancar tanpa kendala:',
                  style: TextStyle(fontSize: 12, color: AppColors.textSecondary, height: 1.35),
                ),
                const SizedBox(height: 10),
                ...SentenceExpander.noObstacleTemplates.asMap().entries.map((entry) {
                  final idx = entry.key;
                  final template = entry.value;
                  final isSelected = _obstaclesController.text.trim() == template;

                  final titles = [
                    'Template 1: Target Survei Selesai Presisi',
                    'Template 2: Sinergi Tim & Aparatur Desa',
                    'Template 3: Peralatan & Sistem GeoKKP Optimal',
                  ];

                  return Padding(
                    padding: const EdgeInsets.only(bottom: 6),
                    child: InkWell(
                      onTap: () {
                        setState(() {
                          _obstaclesController.text = template;
                        });
                      },
                      borderRadius: BorderRadius.circular(8),
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? (isDark ? const Color(0xFF14532D).withValues(alpha: 0.4) : const Color(0xFFDCFCE7))
                              : (isDark ? AppColors.darkSurface : Colors.white),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: isSelected ? const Color(0xFF22C55E) : (isDark ? AppColors.darkBorder : const Color(0xFFE2E8F0)),
                            width: isSelected ? 1.5 : 1.0,
                          ),
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Icon(
                              isSelected ? LucideIcons.checkCircle2 : LucideIcons.circle,
                              size: 16,
                              color: isSelected ? AppColors.success : AppColors.textTertiary,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    titles[idx],
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w700,
                                      color: isSelected
                                          ? AppColors.successDark
                                          : (isDark ? AppColors.darkTextPrimary : AppColors.textPrimary),
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    template,
                                    style: TextStyle(
                                      fontSize: 11,
                                      height: 1.35,
                                      color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                }),
              ],
            ),
          ),

          const SizedBox(height: 14),

          // Text Field
          TextFormField(
            controller: _obstaclesController,
            maxLines: 3,
            decoration: const InputDecoration(
              hintText: 'Contoh: sinyal satelit GNSS terhalang vegetasi lebat, pemilik batas tanah belum hadir, cuaca hujan di lokasi survei, sinkronisasi GeoKKP (atau kosongkan)',
            ),
          ),

          const SizedBox(height: 10),

          // Quick Chips for Obstacles
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: [
              _buildChip('Sinyal GNSS Terhalang Pohon', _obstaclesController, isDark),
              _buildChip('Pemilik Batas Belum Hadir', _obstaclesController, isDark),
              _buildChip('Tumpang Tindih (Overlap) Peta Lama', _obstaclesController, isDark),
              _buildChip('Kondisi Cuaca Hujan Lapangan', _obstaclesController, isDark),
              _buildChip('Topografi Medan Perbukitan', _obstaclesController, isDark),
              _buildChip('Tidak Ada Kendala', _obstaclesController, isDark),
            ],
          ),

          const SizedBox(height: 14),

          // Live Expansion Preview Box
          _buildLiveExpansionBox(
            title: 'Kalimat Tambahan Otomatis dari Sistem:',
            expandedText: expandedText,
            placeholder: 'Ketik kendala di atas atau pilih "Tidak Ada Kendala" untuk melihat kalimat formal otomatis...',
            isDark: isDark,
          ),

          const SizedBox(height: 20),

          // Navigation Buttons: Back and Mulai Buat
          Row(
            children: [
              Expanded(
                flex: 2,
                child: OutlinedButton.icon(
                  onPressed: () => _goToStep(1),
                  icon: const Icon(LucideIcons.arrowLeft, size: 16),
                  label: const Text('Kembali'),
                  style: OutlinedButton.styleFrom(
                    minimumSize: const Size.fromHeight(48),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                flex: 3,
                child: ElevatedButton.icon(
                  onPressed: () {
                    final obsInput = _obstaclesController.text.trim().isEmpty
                        ? 'Tidak ada kendala'
                        : _obstaclesController.text;

                    notifier.updateFields(
                      activities: _activitiesController.text,
                      learnings: _learningsController.text,
                      obstacles: obsInput,
                    );
                    notifier.buildReport(
                      activities: _activitiesController.text,
                      learnings: _learningsController.text,
                      obstacles: obsInput,
                    );

                    _goToStep(3);
                  },
                  icon: const Icon(LucideIcons.sparkles, size: 18),
                  label: const Text('Mulai Buat Laporan', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    minimumSize: const Size.fromHeight(48),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  // -------------------------------------------------------------
  // STEP 4: PRATINJAU & HASIL LAPORAN
  // -------------------------------------------------------------
  Widget _buildStepPreview(
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
        : SentenceExpander.expandLearnings(_learningsController.text);
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
      padding: const EdgeInsets.fromLTRB(18, 12, 18, 95),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Langkah 4: Pratinjau & Salin Laporan Magang',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 4),
          const Text(
            'Setiap bagian telah disusun menjadi kalimat formal terpisah. Anda dapat menyalin masing-masing bagian untuk kolom portal yang sesuai, atau menyalin format lengkap sekaligus.',
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
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Uraian Aktivitas berhasil disalin ke clipboard!'),
                    backgroundColor: AppColors.primary,
                  ),
                );
              }
            },
            onCopyLearnings: () async {
              await Clipboard.setData(ClipboardData(text: learningsText));
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Pembelajaran yang Diperoleh berhasil disalin ke clipboard!'),
                    backgroundColor: AppColors.success,
                  ),
                );
              }
            },
            onCopyObstacles: () async {
              await Clipboard.setData(ClipboardData(text: obstaclesText));
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Kendala yang Dihadapi berhasil disalin ke clipboard!'),
                    backgroundColor: Color(0xFFD97706),
                  ),
                );
              }
            },
            onCopyAll: () async {
              await notifier.copyReportToClipboard();
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Seluruh format logbook lengkap berhasil disalin ke clipboard!'),
                    backgroundColor: AppColors.primary,
                  ),
                );
              }
            },
            onSave: () async {
              try {
                await notifier.saveLogbook();
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        'Logbook tanggal ${DateFormatter.formatIndonesianDateShort(state.selectedDate)} berhasil disimpan!',
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
              _goToStep(0);
            },
            onMarkSubmitted: () async {
              try {
                await notifier.markAsSubmitted();
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
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  // -------------------------------------------------------------
  // HELPER WIDGETS
  // -------------------------------------------------------------
  Widget _buildLiveExpansionBox({
    required String title,
    required String expandedText,
    required String placeholder,
    required bool isDark,
  }) {
    final hasContent = expandedText.trim().isNotEmpty;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurfaceElevated : const Color(0xFFF0FDF4),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: hasContent ? const Color(0xFF86EFAC) : (isDark ? AppColors.darkBorder : AppColors.border),
          width: 1.2,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(LucideIcons.sparkles, size: 16, color: AppColors.success),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w700, color: AppColors.successDark),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            hasContent ? expandedText : placeholder,
            style: TextStyle(
              fontSize: 12.5,
              height: 1.45,
              fontWeight: hasContent ? FontWeight.w600 : FontWeight.w400,
              color: hasContent
                  ? (isDark ? AppColors.darkTextPrimary : const Color(0xFF14532D))
                  : (isDark ? AppColors.darkTextSecondary : AppColors.textTertiary),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChip(String text, TextEditingController controller, bool isDark) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          setState(() {
            if (text == 'Tidak Ada Kendala') {
              controller.text = SentenceExpander.defaultNoObstacle;
            } else {
              final current = controller.text.trim();
              if (current.isEmpty) {
                controller.text = text;
              } else {
                controller.text = '$current\n$text';
              }
            }
          });
        },
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
          decoration: BoxDecoration(
            color: isDark ? AppColors.darkSurfaceElevated : const Color(0xFFF1F5F9),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: isDark ? AppColors.darkBorder : const Color(0xFFCBD5E1),
              width: 1,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                LucideIcons.plus,
                size: 13,
                color: AppColors.primary,
              ),
              const SizedBox(width: 5),
              Text(
                text,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
