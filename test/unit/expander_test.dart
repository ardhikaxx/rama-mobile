import 'package:flutter_test/flutter_test.dart';
import 'package:rama_app/core/utils/sentence_expander.dart';

void main() {
  group('SentenceExpander Smart Benchmark Tests', () {
    test('expands user orientation + autocad install input perfectly', () {
      const input =
          'mengikuti orientasi pemagangan nasional batch 3A angkatan 2 tahun 2026 dan mengikuti arahan menginstall Autocad';

      final draft = SentenceExpander.generateSmartLogbook(input);

      expect(
        draft.activities,
        equals(
          'Mengikuti kegiatan orientasi Pemagangan Nasional Batch 3A Angkatan 2 Tahun 2026 yang mencakup pengenalan program, tata tertib, serta alur pelaksanaan magang. Selain itu, mengikuti arahan teknis dari pembimbing lapangan untuk melakukan instalasi dan konfigurasi perangkat lunak AutoCAD pada perangkat kerja sebagai persiapan penunjang tugas teknis survei dan pemetaan.',
        ),
      );

      expect(
        draft.learnings,
        equals(
          'Memahami struktur program, hak dan kewajiban peserta, serta standar operasional prosedur yang berlaku selama pelaksanaan Pemagangan Nasional Batch 3A Angkatan 2 Tahun 2026. Di sisi teknis, memperoleh pemahaman mengenai kesiapan lingkungan kerja digital dan pengaturan awal perangkat lunak AutoCAD yang akan digunakan untuk pengolahan data spasial maupun penggambaran teknis di instansi penempatan.',
        ),
      );
    });

    test('expands everyday morning apel + cadastral survey into mature sentences', () {
      final act = SentenceExpander.expandActivities('apel pagi lalu ukur tanah di desa sekarputih');
      expect(act, contains('apel pagi kedinasan'));
      expect(act, contains('pengukuran batas bidang tanah di Desa Sekarputih'));

      final learn = SentenceExpander.expandLearnings('', act);
      expect(learn, contains('etika birokrasi kedinasan'));
      expect(learn, contains('akuisisi data koordinat presisi tinggi'));
    });

    test('expands archiving warkah + excel data entry into mature sentences', () {
      final act = SentenceExpander.expandActivities('membantu arsip warkah dan input data bidang tanah ke excel');
      expect(act, contains('arsip warkah pertanahan'));
      expect(act, contains('Microsoft Excel'));

      final learn = SentenceExpander.expandLearnings('', act);
      expect(learn, contains('tata kelola dokumen warkah'));
      expect(learn, contains('basis data digital'));
    });

    test('expands arbitrary daily action using dynamic linguistic normalizer', () {
      final act = SentenceExpander.expandActivities('mewawancarai warga mengenai riwayat kepemilikan tanah');
      expect(act, contains('Melaksanakan kegiatan mewawancarai warga mengenai riwayat kepemilikan tanah'));
      expect(act, contains('instansi penempatan'));

      final learn = SentenceExpander.expandLearnings('tata cara wawancara riwayat tanah');
      expect(learn, contains('Memperoleh pemahaman praktis serta wawasan berharga'));
    });

    test('cycles through varied no-obstacle messages with identical core meaning', () {
      final msg1 = SentenceExpander.getNextNoObstacleMessage();
      final msg2 = SentenceExpander.getNextNoObstacleMessage();
      expect(msg1, isNot(equals(msg2)));
      expect(msg1, contains('Tidak ada kendala dalam pelaksanaan kegiatan hari ini'));
      expect(msg2, contains('kegiatan'));
    });
  });
}
