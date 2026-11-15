import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/utils/date_formatter.dart';
import '../../../widgets/app_card.dart';

class LogbookForm extends StatefulWidget {
  final DateTime selectedDate;
  final String initialActivities;
  final String initialLearnings;
  final String initialObstacles;
  final Function(DateTime) onDateSelected;
  final Function(String activities, String learnings, String obstacles) onGenerate;

  const LogbookForm({
    super.key,
    required this.selectedDate,
    required this.initialActivities,
    required this.initialLearnings,
    required this.initialObstacles,
    required this.onDateSelected,
    required this.onGenerate,
  });

  @override
  State<LogbookForm> createState() => _LogbookFormState();
}

class _LogbookFormState extends State<LogbookForm> {
  late final TextEditingController _activitiesController;
  late final TextEditingController _learningsController;
  late final TextEditingController _obstaclesController;
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _activitiesController = TextEditingController(text: widget.initialActivities);
    _learningsController = TextEditingController(text: widget.initialLearnings);
    _obstaclesController = TextEditingController(text: widget.initialObstacles);
  }

  @override
  void didUpdateWidget(covariant LogbookForm oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.initialActivities != widget.initialActivities) {
      _activitiesController.text = widget.initialActivities;
    }
    if (oldWidget.initialLearnings != widget.initialLearnings) {
      _learningsController.text = widget.initialLearnings;
    }
    if (oldWidget.initialObstacles != widget.initialObstacles) {
      _obstaclesController.text = widget.initialObstacles;
    }
  }

  @override
  void dispose() {
    _activitiesController.dispose();
    _learningsController.dispose();
    _obstaclesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Date Selector Bar
          AppCard(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            onTap: () async {
              final picked = await showDatePicker(
                context: context,
                initialDate: widget.selectedDate,
                firstDate: DateTime(2020),
                lastDate: DateTime(2030),
              );
              if (picked != null) {
                widget.onDateSelected(picked);
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
                        style: TextStyle(fontSize: 11.5, color: AppColors.textSecondary),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        DateFormatter.formatIndonesianDate(widget.selectedDate),
                        style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
                      ),
                    ],
                  ),
                ),
                const Icon(LucideIcons.calendarClock, size: 18, color: AppColors.primary),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // 1. Uraian Aktivitas Field
          _buildFieldLabel('1. Uraian Aktivitas', isRequired: true),
          const SizedBox(height: 6),
          TextFormField(
            controller: _activitiesController,
            maxLines: 4,
            validator: (v) {
              if (v == null || v.trim().isEmpty) {
                return 'Uraian aktivitas magang tidak boleh kosong';
              }
              return null;
            },
            decoration: const InputDecoration(
              hintText: 'Contoh: Melakukan pengembangan antarmuka aplikasi, memperbaiki tampilan halaman dashboard, dan melakukan pengujian fitur.',
            ),
          ),

          const SizedBox(height: 16),

          // 2. Pembelajaran yang Diperoleh Field
          _buildFieldLabel('2. Pembelajaran yang Diperoleh', isRequired: true),
          const SizedBox(height: 6),
          TextFormField(
            controller: _learningsController,
            maxLines: 3,
            validator: (v) {
              if (v == null || v.trim().isEmpty) {
                return 'Pembelajaran yang diperoleh tidak boleh kosong';
              }
              return null;
            },
            decoration: const InputDecoration(
              hintText: 'Contoh: Memahami penerapan state management, pengelolaan database lokal, dan proses pengujian aplikasi.',
            ),
          ),

          const SizedBox(height: 16),

          // 3. Kendala yang Dihadapi Field + Quick Fill
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildFieldLabel('3. Kendala yang Dihadapi', isRequired: true),
              TextButton.icon(
                onPressed: () {
                  _obstaclesController.text =
                      'Tidak ada kendala berarti selama kegiatan magang berlangsung, seluruh aktivitas dapat diselesaikan dengan baik.';
                },
                icon: const Icon(LucideIcons.sparkles, size: 14),
                label: const Text('Tidak Ada Kendala', style: TextStyle(fontSize: 12)),
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
            validator: (v) {
              if (v == null || v.trim().isEmpty) {
                return 'Kendala yang dihadapi tidak boleh kosong';
              }
              return null;
            },
            decoration: const InputDecoration(
              hintText: 'Contoh: Mengalami kendala dalam penyesuaian tampilan pada beberapa ukuran layar dan proses debugging.',
            ),
          ),

          const SizedBox(height: 20),

          // Primary Button: Mulai Buat
          ElevatedButton.icon(
            onPressed: () {
              if (_formKey.currentState?.validate() ?? false) {
                widget.onGenerate(
                  _activitiesController.text,
                  _learningsController.text,
                  _obstaclesController.text,
                );
              }
            },
            icon: const Icon(LucideIcons.fileText, size: 19),
            label: const Text(
              'Mulai Buat',
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              minimumSize: const Size.fromHeight(50),
              elevation: 2,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFieldLabel(String label, {bool isRequired = false}) {
    return Row(
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 13.5,
            fontWeight: FontWeight.w700,
          ),
        ),
        if (isRequired) ...[
          const SizedBox(width: 4),
          const Text(
            '*',
            style: TextStyle(
              color: AppColors.danger,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ],
    );
  }
}
