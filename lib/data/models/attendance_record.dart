import '../../core/constants/app_constants.dart';

class AttendanceRecord {
  final int? id;
  final String date; // YYYY-MM-DD
  final String type; // check_in, check_out
  final DateTime timestamp;
  final String status; // hadir, izin, sakit, libur
  final String? notes;
  final DateTime createdAt;
  final DateTime? updatedAt;

  const AttendanceRecord({
    this.id,
    required this.date,
    required this.type,
    required this.timestamp,
    this.status = AppConstants.statusHadir,
    this.notes,
    required this.createdAt,
    this.updatedAt,
  });

  bool get isCheckIn => type == AppConstants.checkIn;
  bool get isCheckOut => type == AppConstants.checkOut || type == AppConstants.attendance;

  String get typeDisplayName => 'Absensi Magang (Sebelum Pulang)';

  String get statusDisplayName {
    switch (status) {
      case AppConstants.statusHadir:
        return 'Hadir';
      case AppConstants.statusIzin:
        return 'Izin';
      case AppConstants.statusSakit:
        return 'Sakit';
      case AppConstants.statusLibur:
        return 'Libur';
      default:
        return status;
    }
  }

  AttendanceRecord copyWith({
    int? id,
    String? date,
    String? type,
    DateTime? timestamp,
    String? status,
    String? notes,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return AttendanceRecord(
      id: id ?? this.id,
      date: date ?? this.date,
      type: type ?? this.type,
      timestamp: timestamp ?? this.timestamp,
      status: status ?? this.status,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'date': date,
      'type': type,
      'timestamp': timestamp.toIso8601String(),
      'status': status,
      'notes': notes,
      'created_at': createdAt.toIso8601String(),
      'updated_at': (updatedAt ?? DateTime.now()).toIso8601String(),
    };
  }

  factory AttendanceRecord.fromMap(Map<String, dynamic> map) {
    return AttendanceRecord(
      id: map['id'] as int?,
      date: map['date'] as String,
      type: map['type'] as String,
      timestamp: DateTime.parse(map['timestamp'] as String),
      status: map['status'] as String? ?? AppConstants.statusHadir,
      notes: map['notes'] as String?,
      createdAt: map['created_at'] != null
          ? DateTime.parse(map['created_at'] as String)
          : DateTime.now(),
      updatedAt: map['updated_at'] != null
          ? DateTime.tryParse(map['updated_at'] as String)
          : null,
    );
  }
}
