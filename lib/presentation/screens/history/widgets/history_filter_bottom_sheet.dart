import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/utils/date_formatter.dart';
import '../../../../providers/history_provider.dart';

class HistoryFilterBottomSheet extends StatefulWidget {
  final HistoryFilter currentFilter;
  final Function(HistoryFilter) onApply;

  const HistoryFilterBottomSheet({
    super.key,
    required this.currentFilter,
    required this.onApply,
  });

  static Future<void> show(
    BuildContext context, {
    required HistoryFilter currentFilter,
    required Function(HistoryFilter) onApply,
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => HistoryFilterBottomSheet(
        currentFilter: currentFilter,
        onApply: onApply,
      ),
    );
  }

  @override
  State<HistoryFilterBottomSheet> createState() => _HistoryFilterBottomSheetState();
}

class _HistoryFilterBottomSheetState extends State<HistoryFilterBottomSheet> {
  DateTime? _startDate;
  DateTime? _endDate;
  late String _selectedType;
  late String _selectedStatus;

  @override
  void initState() {
    super.initState();
    _startDate = widget.currentFilter.startDate;
    _endDate = widget.currentFilter.endDate;
    _selectedType = widget.currentFilter.selectedType;
    _selectedStatus = widget.currentFilter.selectedStatus;
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 20,
        bottom: MediaQuery.of(context).viewInsets.bottom + 20,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Filter Riwayat',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
              ),
              TextButton(
                onPressed: () {
                  setState(() {
                    _startDate = null;
                    _endDate = null;
                    _selectedType = 'all';
                    _selectedStatus = 'all';
                  });
                },
                child: const Text('Reset'),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // Date Range Filter
          const Text(
            'Rentang Tanggal',
            style: TextStyle(fontSize: 13.5, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: _buildDateButton(
                  context,
                  label: _startDate != null
                      ? DateFormatter.formatIndonesianDateShort(_startDate!)
                      : 'Dari Tanggal',
                  icon: LucideIcons.calendar,
                  onTap: () async {
                    final picked = await showDatePicker(
                      context: context,
                      initialDate: _startDate ?? DateTime.now(),
                      firstDate: DateTime(2020),
                      lastDate: DateTime(2030),
                    );
                    if (picked != null) {
                      setState(() => _startDate = picked);
                    }
                  },
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _buildDateButton(
                  context,
                  label: _endDate != null
                      ? DateFormatter.formatIndonesianDateShort(_endDate!)
                      : 'Sampai Tanggal',
                  icon: LucideIcons.calendar,
                  onTap: () async {
                    final picked = await showDatePicker(
                      context: context,
                      initialDate: _endDate ?? DateTime.now(),
                      firstDate: _startDate ?? DateTime(2020),
                      lastDate: DateTime(2030),
                    );
                    if (picked != null) {
                      setState(() => _endDate = picked);
                    }
                  },
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Status Filter
          const Text(
            'Status',
            style: TextStyle(fontSize: 13.5, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _buildFilterChip('all', 'Semua Status', _selectedStatus == 'all', (val) {
                setState(() => _selectedStatus = 'all');
              }),
              _buildFilterChip(
                  AppConstants.statusHadir, 'Hadir', _selectedStatus == AppConstants.statusHadir,
                  (val) {
                setState(() => _selectedStatus = AppConstants.statusHadir);
              }),
              _buildFilterChip(
                  AppConstants.statusIzin, 'Izin', _selectedStatus == AppConstants.statusIzin,
                  (val) {
                setState(() => _selectedStatus = AppConstants.statusIzin);
              }),
              _buildFilterChip(
                  AppConstants.statusSakit, 'Sakit', _selectedStatus == AppConstants.statusSakit,
                  (val) {
                setState(() => _selectedStatus = AppConstants.statusSakit);
              }),
            ],
          ),

          const SizedBox(height: 24),

          // Apply Button
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              widget.onApply(
                widget.currentFilter.copyWith(
                  startDate: _startDate,
                  endDate: _endDate,
                  selectedType: _selectedType,
                  selectedStatus: _selectedStatus,
                  clearDates: _startDate == null && _endDate == null,
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              minimumSize: const Size.fromHeight(48),
            ),
            child: const Text('Terapkan Filter'),
          ),
        ],
      ),
    );
  }

  Widget _buildDateButton(
    BuildContext context, {
    required String label,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return OutlinedButton.icon(
      onPressed: onTap,
      icon: Icon(icon, size: 16),
      label: Text(label, style: const TextStyle(fontSize: 12.5)),
      style: OutlinedButton.styleFrom(
        foregroundColor: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
        side: BorderSide(color: isDark ? AppColors.darkBorder : AppColors.border),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  Widget _buildFilterChip(
    String value,
    String label,
    bool isSelected,
    Function(bool) onSelected,
  ) {
    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      selectedColor: AppColors.primary,
      labelStyle: TextStyle(
        fontSize: 12,
        fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
        color: isSelected ? Colors.white : AppColors.textSecondary,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
        side: BorderSide(color: isSelected ? AppColors.primary : AppColors.border),
      ),
      onSelected: onSelected,
    );
  }
}
