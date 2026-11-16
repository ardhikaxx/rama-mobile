class SentenceExpander {
  const SentenceExpander._();

  /// Automatically expands brief activity keywords/phrases into formal Indonesian sentences.
  static String expandActivities(String rawInput) {
    final trimmed = rawInput.trim();
    if (trimmed.isEmpty) return '';

    final lines = trimmed.split(RegExp(r'[\r\n]+')).map((e) => e.trim()).where((e) => e.isNotEmpty).toList();
    if (lines.isEmpty) return '';

    final expandedList = <String>[];

    for (final line in lines) {
      final clean = _cleanBulletOrNumber(line);
      if (clean.isEmpty) continue;

      // If already a long formal sentence (e.g. >= 14 words), keep as is
      if (clean.split(RegExp(r'\s+')).length >= 14 && (clean.startsWith('Melaksanakan') || clean.startsWith('Melakukan') || clean.startsWith('Menyusun') || clean.startsWith('Mengikuti'))) {
        expandedList.add(clean.endsWith('.') ? clean : '$clean.');
        continue;
      }

      final lower = clean.toLowerCase();

      String expanded;
      if (_containsAny(lower, ['ui', 'antarmuka', 'figma', 'desain', 'wireframe', 'layout', 'tampilan'])) {
        expanded = 'Melakukan perancangan dan pengembangan antarmuka (UI) terkait $clean secara terstruktur sesuai dengan standar desain industri.';
      } else if (_containsAny(lower, ['coding', 'koding', 'ngoding', 'develop', 'fitur', 'implementasi', 'backend', 'frontend', 'logic', 'api'])) {
        expanded = 'Melaksanakan kegiatan implementasi dan pengembangan kode program untuk $clean guna mendukung fungsionalitas sistem.';
      } else if (_containsAny(lower, ['analisis', 'analisa', 'data', 'rekap', 'rekapitulasi', 'evaluasi data', 'riset data'])) {
        expanded = 'Melakukan kegiatan pengolahan dan analisis data terkait $clean secara cermat untuk menghasilkan laporan yang akurat.';
      } else if (_containsAny(lower, ['meeting', 'rapat', 'diskusi', 'briefing', 'koordinasi', 'evaluasi mingguan'])) {
        expanded = 'Mengikuti agenda koordinasi dan rapat mengenai $clean guna menyelaraskan target serta progres kerja tim magang.';
      } else if (_containsAny(lower, ['test', 'testing', 'uji', 'pengujian', 'qa', 'quality'])) {
        expanded = 'Melakukan serangkaian proses testing dan pengujian terhadap $clean untuk memastikan seluruh fungsi berjalan tanpa kendala teknis.';
      } else if (_containsAny(lower, ['dokumen', 'dokumentasi', 'laporan', 'modul', 'panduan', 'notula'])) {
        expanded = 'Menyusun dan menyempurnakan dokumentasi teknis mengenai $clean agar seluruh alur kerja terdokumentasi dengan rapi dan sistematis.';
      } else if (_containsAny(lower, ['riset', 'studi', 'referensi', 'mencari bahan', 'eksplorasi'])) {
        expanded = 'Melakukan studi literatur dan eksplorasi referensi terkait $clean guna menemukan solusi terbaik dalam implementasi proyek magang.';
      } else if (_containsAny(lower, ['setup', 'install', 'instalasi', 'konfigurasi', 'lingkungan', 'environment'])) {
        expanded = 'Melakukan proses instalasi dan konfigurasi teknis untuk $clean agar sistem siap digunakan dalam alur kerja operasional.';
      } else if (_containsAny(lower, ['perbaikan', 'fixing', 'bug', 'error', 'debug', 'refactor', 'pembenahan'])) {
        expanded = 'Melakukan penelusuran kesalahan (debugging) serta perbaikan kode pada $clean agar sistem kembali stabil dan optimal.';
      } else if (_containsAny(lower, ['administrasi', 'arsip', 'surat', 'surat menyurat', 'input data', 'pembukuan'])) {
        expanded = 'Mengerjakan penataan arsip dan administrasi kerja terkait $clean secara tertib sesuai arahan dari pembimbing lapangan.';
      } else if (_startsVerb(clean)) {
        expanded = 'Melaksanakan kegiatan $clean dengan penuh ketelitian dan berkoordinasi aktif bersama tim magang.';
      } else {
        expanded = 'Melakukan pengerjaan dan tindak lanjut terkait $clean secara terarah sesuai petunjuk pembimbing lapangan.';
      }

      expandedList.add(expanded.endsWith('.') ? expanded : '$expanded.');
    }

    if (expandedList.length == 1) {
      return expandedList.first;
    } else {
      return expandedList.map((e) => '• $e').join('\n');
    }
  }

  /// Automatically expands brief learning keywords/phrases into formal Indonesian sentences.
  static String expandLearnings(String rawInput) {
    final trimmed = rawInput.trim();
    if (trimmed.isEmpty) return '';

    final lines = trimmed.split(RegExp(r'[\r\n,]+')).map((e) => e.trim()).where((e) => e.isNotEmpty).toList();
    if (lines.isEmpty) return '';

    final expandedList = <String>[];

    for (final line in lines) {
      final clean = _cleanBulletOrNumber(line);
      if (clean.isEmpty) continue;

      if (clean.split(RegExp(r'\s+')).length >= 12 && (clean.startsWith('Memperoleh') || clean.startsWith('Memahami') || clean.startsWith('Mendapatkan'))) {
        expandedList.add(clean.endsWith('.') ? clean : '$clean.');
        continue;
      }

      final lower = clean.toLowerCase();

      String expanded;
      if (_containsAny(lower, ['flutter', 'dart', 'react', 'vue', 'kotlin', 'swift', 'python', 'java', 'sql', 'framework', 'tools'])) {
        expanded = 'Mendapatkan pemahaman teknis yang mendalam mengenai konsep dan penerapan $clean dalam pengembangan aplikasi modern.';
      } else if (_containsAny(lower, ['git', 'github', 'gitlab', 'version control', 'branch', 'merge'])) {
        expanded = 'Memahami alur kerja version control menggunakan $clean untuk manajemen kode dan kolaborasi tim yang efisien.';
      } else if (_containsAny(lower, ['database', 'sqlite', 'mysql', 'api', 'rest api', 'backend', 'json'])) {
        expanded = 'Mempelajari cara kerja integrasi data dan pengelolaan database menggunakan $clean secara terstruktur dan aman.';
      } else if (_containsAny(lower, ['komunikasi', 'koordinasi', 'kerjasama', 'kolaborasi', 'tim', 'soft skill', 'public speaking'])) {
        expanded = 'Meningkatkan keterampilan komunikasi profesional dan kerja sama tim dalam menuntaskan target kegiatan magang.';
      } else if (_containsAny(lower, ['waktu', 'disiplin', 'manajemen waktu', 'tanggung jawab', 'komitmen'])) {
        expanded = 'Melatih kedisiplinan diri dan kemampuan manajemen waktu kerja agar seluruh target dapat dicapai tepat waktu.';
      } else if (_containsAny(lower, ['troubleshoot', 'debug', 'problem solving', 'analisis masalah', 'pemecahan masalah'])) {
        expanded = 'Mengasah daya pikir kritis dan kemampuan problem solving dalam mengidentifikasi serta menuntaskan kendala operasional.';
      } else if (lower.startsWith('belajar ') || lower.startsWith('memahami ') || lower.startsWith('mempelajari ')) {
        expanded = 'Mendapatkan wawasan berharga dalam $clean serta memahami implementasinya secara nyata di dunia kerja.';
      } else {
        expanded = 'Memperoleh pemahaman dan wawasan baru seputar $clean yang sangat mendukung peningkatan kompetensi profesional.';
      }

      expandedList.add(expanded.endsWith('.') ? expanded : '$expanded.');
    }

    if (expandedList.length == 1) {
      return expandedList.first;
    } else {
      return expandedList.map((e) => '• $e').join('\n');
    }
  }

  /// Default formal sentence when there are no obstacles during internship.
  static const String defaultNoObstacle =
      'Tidak ada kendala berarti selama kegiatan magang berlangsung, seluruh aktivitas dan tugas harian dapat diselesaikan dengan baik, lancar, serta sesuai target.';

  /// Preset templates for smooth internship activities without obstacles.
  static const List<String> noObstacleTemplates = [
    'Tidak ada kendala berarti selama kegiatan magang berlangsung, seluruh aktivitas dan tugas harian dapat diselesaikan dengan baik, lancar, serta sesuai target.',
    'Seluruh kegiatan magang hari ini berjalan dengan lancar tanpa hambatan, didukung oleh koordinasi tim yang solid serta bimbingan yang jelas dari mentor lapangan.',
    'Tidak ditemui kendala teknis maupun operasional, seluruh sarana kerja dan sistem pendukung berfungsi optimal mendukung kelancaran pekerjaan hari ini.',
  ];

  /// Automatically expands brief obstacle keywords/phrases into formal Indonesian sentences.
  static String expandObstacles(String rawInput) {
    final trimmed = rawInput.trim();
    if (trimmed.isEmpty) {
      return defaultNoObstacle;
    }

    final lower = trimmed.toLowerCase();
    if (_containsAny(lower, ['tidak ada', 'nihil', 'aman', 'lancar', 'none', 'tidak ada kendala', 'tidak ada hambatan', 'baik', 'oke', 'ok', 'no obstacle', 'tanpa kendala', 'tanpa hambatan'])) {
      // If user typed or picked a full formal sentence already, return it cleanly
      if (trimmed.length >= 30) {
        return trimmed.endsWith('.') ? trimmed : '$trimmed.';
      }
      return defaultNoObstacle;
    }

    final clean = _cleanBulletOrNumber(trimmed);
    if (clean.split(RegExp(r'\s+')).length >= 14 && (clean.startsWith('Tidak ada') || clean.startsWith('Menghadapi') || clean.startsWith('Menemui'))) {
      return clean.endsWith('.') ? clean : '$clean.';
    }

    String expanded;
    if (_containsAny(lower, ['jaringan', 'internet', 'wifi', 'koneksi', 'lemot', 'lambat', 'down', 'putus'])) {
      expanded = 'Menghadapi hambatan koneksi jaringan internet yang sempat tidak stabil saat $clean, namun dapat diatasi dengan memanfaatkan jaringan alternatif sehingga pekerjaan tetap selesai tepat waktu.';
    } else if (_containsAny(lower, ['error', 'bug', 'crash', 'fail', 'gagal', 'exception', 'stacktrace'])) {
      expanded = 'Menemui kendala teknis berupa kendala $clean, yang berhasil diatasi melalui penelusuran dokumentasi teknis dan konsultasi bersama mentor pembimbing.';
    } else if (_containsAny(lower, ['laptop', 'pc', 'perangkat', 'hang', 'komputer', 'spek', 'freeze'])) {
      expanded = 'Mengalami penurunan performa pada perangkat kerja saat memproses $clean, yang disiasati melalui optimalisasi manajemen aplikasi agar tidak mengganggu alur kerja.';
    } else if (_containsAny(lower, ['belum paham', 'kurang paham', 'bingung', 'sulit', 'kesulitan', 'alur'])) {
      expanded = 'Sempat mengalami sedikit kesulitan dalam memahami alur kerja $clean, namun berhasil dipahami dengan baik setelah berdiskusi langsung dengan pembimbing magang.';
    } else if (_containsAny(lower, ['waktu', 'deadline', 'mepet', 'padat'])) {
      expanded = 'Menghadapi tantangan tenggat waktu yang cukup padat terkait $clean, yang berhasil dituntaskan dengan menyusun prioritas pengerjaan secara teratur.';
    } else {
      expanded = 'Menghadapi sedikit kendala teknis terkait $clean, namun permasalahan tersebut berhasil ditangani dengan baik berkat koordinasi aktif bersama tim kerja.';
    }

    return expanded.endsWith('.') ? expanded : '$expanded.';
  }

  static String _cleanBulletOrNumber(String input) {
    return input.replaceFirst(RegExp(r'^[\s\-\*\•\d\.\)\:]+'), '').trim();
  }

  static bool _containsAny(String text, List<String> keywords) {
    for (final k in keywords) {
      if (text.contains(k)) return true;
    }
    return false;
  }

  static bool _startsVerb(String text) {
    final lower = text.toLowerCase();
    return lower.startsWith('me') ||
        lower.startsWith('ber') ||
        lower.startsWith('di') ||
        lower.startsWith('ter') ||
        lower.startsWith('mengerjakan') ||
        lower.startsWith('membuat') ||
        lower.startsWith('membantu');
  }
}
