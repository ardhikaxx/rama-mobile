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
  });
}
