import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/utils/date_formatter.dart';
import '../../../../data/models/attendance_record.dart';

class AttendanceDialog extends StatefulWidget {
  final String type; // check_in or check_out
  final AttendanceRecord? initialRecord; // If editing / correcting
  final Function(String status, String? notes) onConfirmed;

  const AttendanceDialog({
    super.key,
    required this.type,
    this.initialRecord,
    required this.onConfirmed,
  });

  static Future<void> show(
    BuildContext context, {
    required String type,
    AttendanceRecord? initialRecord,
    required Function(String status, String? notes) onConfirmed,
  }) {
    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AttendanceDialog(
        type: type,
        initialRecord: initialRecord,
        onConfirmed: onConfirmed,
      ),
    );
  }

  @override
  State<AttendanceDialog> createState() => _AttendanceDialogState();
}

class _AttendanceDialogState extends State<AttendanceDialog> {
  late String _selectedStatus;
  late final TextEditingController _notesController;
  final _now = DateTime.now();

  @override
  void initState() {
    super.initState();
    _selectedStatus = widget.initialRecord?.status ?? AppConstants.statusHadir;
    _notesController = TextEditingController(text: widget.initialRecord?.notes ?? '');
  }

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isCheckIn = widget.type == AppConstants.checkIn;
    final isEditing = widget.initialRecord != null;

    final typeLabel = isCheckIn ? 'Absensi Datang' : 'Absensi Magang (Sebelum Pulang)';
    final timeStr = isEditing
        ? DateFormatter.formatTime(widget.initialRecord!.timestamp)
        : DateFormatter.formatTime(_now);

    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      backgroundColor: isDark ? AppColors.darkSurface : AppColors.surface,
      surfaceTintColor: Colors.transparent,
      titlePadding: const EdgeInsets.fromLTRB(22, 22, 22, 12),
      contentPadding: const EdgeInsets.symmetric(horizontal: 22),
      actionsPadding: const EdgeInsets.fromLTRB(16, 16, 16, 18),
      title: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: isCheckIn ? AppColors.primaryContainer : const Color(0xFFE0E7FF),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              isCheckIn ? LucideIcons.logIn : LucideIcons.logOut,
              color: isCheckIn ? AppColors.primary : AppColors.primaryDark,
              size: 22,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isEditing ? 'Koreksi $typeLabel' : 'Konfirmasi $typeLabel',
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                Text(
                  DateFormatter.formatIndonesianDate(_now),
                  style: TextStyle(
                    fontSize: 12,
                    color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Time banner
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: isDark ? AppColors.darkSurfaceElevated : const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isDark ? AppColors.darkBorder : AppColors.border,
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Waktu Pencatatan:',
                    style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
                  ),
                  Text(
                    '$timeStr WIB',
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: AppColors.primary,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Status Kehadiran Selector
            const Text(
              'Status Kehadiran',
              style: TextStyle(fontSize: 13.5, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _buildStatusChip(AppConstants.statusHadir, 'Hadir', LucideIcons.checkCircle2),
                _buildStatusChip(AppConstants.statusIzin, 'Izin', LucideIcons.fileClock),
                _buildStatusChip(AppConstants.statusSakit, 'Sakit', LucideIcons.heartPulse),
                _buildStatusChip(AppConstants.statusLibur, 'Libur', LucideIcons.palmtree),
              ],
            ),
            const SizedBox(height: 16),

            // Catatan Tambahan (Opsional)
            const Text(
              'Catatan Tambahan (Opsional)',
              style: TextStyle(fontSize: 13.5, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 6),
            TextField(
              controller: _notesController,
              maxLines: 2,
              decoration: const InputDecoration(
                hintText: 'Contoh: Masuk pukul 07.45 karena kendala lalu lintas...',
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Batal'),
        ),
        ElevatedButton(
          onPressed: () {
            Navigator.of(context).pop();
            widget.onConfirmed(
              _selectedStatus,
              _notesController.text.trim().isEmpty ? null : _notesController.text.trim(),
            );
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
            minimumSize: const Size(110, 42),
          ),
          child: Text(isEditing ? 'Simpan' : 'Konfirmasi'),
        ),
      ],
    );
  }

  Widget _buildStatusChip(String value, String label, IconData icon) {
    final isSelected = _selectedStatus == value;

    return ChoiceChip(
      showCheckmark: false,
      label: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 15,
            color: isSelected ? Colors.white : AppColors.textSecondary,
          ),
          const SizedBox(width: 5),
          Text(label),
        ],
      ),
      selected: isSelected,
      selectedColor: AppColors.primary,
      backgroundColor: Colors.transparent,
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
          setState(() {
            _selectedStatus = value;
          });
        }
      },
    );
  }
}
