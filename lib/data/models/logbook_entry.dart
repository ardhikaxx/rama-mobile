import '../../core/constants/app_constants.dart';
import '../../core/utils/date_formatter.dart';

class LogbookEntry {
  final int? id;
  final String date; // YYYY-MM-DD
  final String activities;
  final String learnings;
  final String obstacles;
  final String generatedTemplate;
  final String status; // draft, created, copied, submitted
  final DateTime createdAt;
  final DateTime? updatedAt;

  const LogbookEntry({
    this.id,
    required this.date,
    required this.activities,
    required this.learnings,
    required this.obstacles,
    required this.generatedTemplate,
    this.status = AppConstants.logbookCreated,
    required this.createdAt,
    this.updatedAt,
  });

  bool get isDraft => status == AppConstants.logbookDraft;
  bool get isCreated => status == AppConstants.logbookCreated;
  bool get isCopied => status == AppConstants.logbookCopied;
  bool get isSubmitted => status == AppConstants.logbookSubmitted;

  String get statusDisplayName {
    switch (status) {
      case AppConstants.logbookDraft:
        return 'Draft';
      case AppConstants.logbookCreated:
        return 'Sudah Dibuat';
      case AppConstants.logbookCopied:
        return 'Sudah Disalin';
      case AppConstants.logbookSubmitted:
        return 'Sudah Dikirim';
      default:
        return status;
    }
  }

  static String generateTemplateText({
    required DateTime date,
    required String activities,
    required String learnings,
    required String obstacles,
  }) {
    final formattedDate = DateFormatter.formatIndonesianDate(date);
    return 'LAPORAN AKTIVITAS MAGANG\n'
        'Tanggal: $formattedDate\n\n'
        '1. Uraian Aktivitas\n'
        '${activities.trim()}\n\n'
        '2. Pembelajaran yang Diperoleh\n'
        '${learnings.trim()}\n\n'
        '3. Kendala yang Dihadapi\n'
        '${obstacles.trim()}';
  }

  LogbookEntry copyWith({
    int? id,
    String? date,
    String? activities,
    String? learnings,
    String? obstacles,
    String? generatedTemplate,
    String? status,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return LogbookEntry(
      id: id ?? this.id,
      date: date ?? this.date,
      activities: activities ?? this.activities,
      learnings: learnings ?? this.learnings,
      obstacles: obstacles ?? this.obstacles,
      generatedTemplate: generatedTemplate ?? this.generatedTemplate,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'date': date,
      'activities': activities,
      'learnings': learnings,
      'obstacles': obstacles,
      'generated_template': generatedTemplate,
      'status': status,
      'created_at': createdAt.toIso8601String(),
      'updated_at': (updatedAt ?? DateTime.now()).toIso8601String(),
    };
  }

  factory LogbookEntry.fromMap(Map<String, dynamic> map) {
    return LogbookEntry(
      id: map['id'] as int?,
      date: map['date'] as String,
      activities: map['activities'] as String? ?? '',
      learnings: map['learnings'] as String? ?? '',
      obstacles: map['obstacles'] as String? ?? '',
      generatedTemplate: map['generated_template'] as String? ?? '',
      status: map['status'] as String? ?? AppConstants.logbookCreated,
      createdAt: map['created_at'] != null
          ? DateTime.parse(map['created_at'] as String)
          : DateTime.now(),
      updatedAt: map['updated_at'] != null
          ? DateTime.tryParse(map['updated_at'] as String)
          : null,
    );
  }
}
