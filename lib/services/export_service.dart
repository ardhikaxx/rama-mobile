import 'dart:convert';
import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import '../../core/constants/app_constants.dart';
import '../../core/errors/app_exception.dart';
import '../../core/utils/date_formatter.dart';
import '../data/repositories/backup_repository.dart';

class ExportService {
  final BackupRepository _backupRepository;

  ExportService({BackupRepository? backupRepository})
      : _backupRepository = backupRepository ?? BackupRepository();

  Future<File> createBackupFile() async {
    try {
      final data = await _backupRepository.generateBackupMap();
      final jsonString = const JsonEncoder.withIndent('  ').convert(data);

      final dir = await getApplicationDocumentsDirectory();
      final timestamp = DateFormatter.toDateKey(DateTime.now());
      final file = File('${dir.path}/RAMA_Backup_$timestamp.json');

      await file.writeAsString(jsonString);
      return file;
    } catch (e) {
      throw AppDatabaseException('Gagal membuat berkas cadangan: $e');
    }
  }

  Future<void> shareBackupFile() async {
    final file = await createBackupFile();
    await SharePlus.instance.share(
      ShareParams(
        files: [XFile(file.path)],
        text: 'Berkas Cadangan Data Aplikasi RAMA (${AppConstants.appFullName})',
      ),
    );
  }

  Future<File> createAttendanceCsvFile() async {
    try {
      final csvString = await _backupRepository.exportAttendanceToCsv();
      final dir = await getApplicationDocumentsDirectory();
      final timestamp = DateFormatter.toDateKey(DateTime.now());
      final file = File('${dir.path}/RAMA_Absensi_$timestamp.csv');

      await file.writeAsString(csvString);
      return file;
    } catch (e) {
      throw AppDatabaseException('Gagal membuat berkas CSV absensi: $e');
    }
  }

  Future<void> shareAttendanceCsv() async {
    final file = await createAttendanceCsvFile();
    await SharePlus.instance.share(
      ShareParams(
        files: [XFile(file.path)],
        text: 'Data Rekap Absensi Magang RAMA',
      ),
    );
  }

  Future<File> createLogbookCsvFile() async {
    try {
      final csvString = await _backupRepository.exportLogbookToCsv();
      final dir = await getApplicationDocumentsDirectory();
      final timestamp = DateFormatter.toDateKey(DateTime.now());
      final file = File('${dir.path}/RAMA_Logbook_$timestamp.csv');

      await file.writeAsString(csvString);
      return file;
    } catch (e) {
      throw AppDatabaseException('Gagal membuat berkas CSV logbook: $e');
    }
  }

  Future<void> shareLogbookCsv() async {
    final file = await createLogbookCsvFile();
    await SharePlus.instance.share(
      ShareParams(
        files: [XFile(file.path)],
        text: 'Data Rekap Logbook Magang RAMA',
      ),
    );
  }

  Future<Map<String, dynamic>?> pickAndParseBackupFile() async {
    try {
      final files = await FilePicker.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['json'],
      );

      if (files.isEmpty) {
        return null; // user cancelled
      }

      final path = files.first.path;
      if (path == null) {
        throw const ValidationException('Jalur berkas tidak ditemukan.');
      }

      final file = File(path);
      final content = await file.readAsString();
      final decoded = jsonDecode(content);

      if (decoded is! Map<String, dynamic>) {
        throw const ValidationException('Format isi berkas JSON tidak sesuai.');
      }

      return decoded;
    } catch (e) {
      throw ValidationException('Gagal membaca berkas cadangan: $e');
    }
  }
}
