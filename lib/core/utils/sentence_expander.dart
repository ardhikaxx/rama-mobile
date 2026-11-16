class LogbookDraft {
  final String activities;
  final String learnings;
  final String obstacles;

  const LogbookDraft({
    required this.activities,
    required this.learnings,
    required this.obstacles,
  });
}

class SentenceExpander {
  const SentenceExpander._();

  /// Default formal sentence when there are no obstacles during internship.
  static const String defaultNoObstacle =
      'Tidak ada kendala dalam pelaksanaan kegiatan hari ini; seluruh kegiatan berjalan dengan lancar.';

  /// Preset templates for smooth activities without obstacles (with equivalent meanings).
  static const List<String> noObstacleVariations = [
    'Tidak ada kendala dalam pelaksanaan kegiatan hari ini; seluruh kegiatan berjalan dengan lancar.',
    'Tidak ada kendala dalam pelaksanaan kegiatan hari ini; seluruh rangkaian tugas terlaksana dengan baik sesuai arahan.',
    'Pelaksanaan kegiatan hari ini berjalan lancar tanpa adanya kendala atau hambatan yang berarti.',
    'Tidak ada kendala dalam pelaksanaan kegiatan hari ini; koordinasi kerja berjalan kondusif dan optimal.',
    'Secara keseluruhan tidak ada kendala dalam pelaksanaan kegiatan hari ini; seluruh agenda terselesaikan dengan baik.',
  ];

  static int _noObstacleIndex = 0;

  /// Returns a varied message indicating no obstacles, cycling through natural variations.
  static String getNextNoObstacleMessage() {
    final msg = noObstacleVariations[_noObstacleIndex % noObstacleVariations.length];
    _noObstacleIndex++;
    return msg;
  }

  /// Generates a complete formal logbook draft (activities, learnings, obstacles) from a single prompt.
  static LogbookDraft generateSmartLogbook(String rawInput) {
    final trimmed = rawInput.trim();
    if (trimmed.isEmpty) {
      return const LogbookDraft(
        activities: '',
        learnings: '',
        obstacles: defaultNoObstacle,
      );
    }

    final activities = expandActivities(trimmed);
    final learnings = expandLearnings(trimmed);
    final obstacles = _extractObstaclesFromInput(trimmed);

    return LogbookDraft(
      activities: activities,
      learnings: learnings,
      obstacles: obstacles,
    );
  }

  /// Automatically expands brief activity keywords/phrases into formal Indonesian sentences.
  static String expandActivities(String rawInput) {
    final trimmed = rawInput.trim();
    if (trimmed.isEmpty) return '';

    // If input is already a very long formal paragraph (>= 22 words) with formal prefixes, preserve it.
    if (_isAlreadyFormalParagraph(trimmed)) {
      return trimmed.endsWith('.') ? trimmed : '$trimmed.';
    }

    final clauses = _splitIntoClauses(trimmed);
    if (clauses.isEmpty) return '';

    final expandedList = <String>[];

    for (var i = 0; i < clauses.length; i++) {
      final clean = _cleanBulletOrNumber(clauses[i]);
      if (clean.isEmpty) continue;

      final isFirst = i == 0;
      final expanded = _expandSingleActivityClause(clean, isFirst: isFirst, totalClauses: clauses.length);
      if (expanded.isNotEmpty) {
        expandedList.add(expanded);
      }
    }

    if (expandedList.isEmpty) return trimmed;

    // Join sentences into a cohesive, professional paragraph
    return _joinActivitySentences(expandedList);
  }

  /// Automatically expands brief learning keywords/phrases into formal Indonesian sentences.
  static String expandLearnings(String rawInput, [String? activitiesContext]) {
    final effectiveInput = (rawInput.trim().isEmpty && activitiesContext != null && activitiesContext.trim().isNotEmpty)
        ? activitiesContext.trim()
        : rawInput.trim();

    if (effectiveInput.isEmpty) return '';

    // If input is already a long formal learning paragraph, preserve it.
    if (_isAlreadyFormalParagraph(effectiveInput) &&
        (effectiveInput.contains('Memahami') ||
            effectiveInput.contains('Memperoleh') ||
            effectiveInput.contains('Menguasai') ||
            effectiveInput.contains('Mendapatkan') ||
            effectiveInput.contains('Meningkatkan'))) {
      return effectiveInput.endsWith('.') ? effectiveInput : '$effectiveInput.';
    }

    final clauses = _splitIntoClauses(effectiveInput);
    if (clauses.isEmpty) return '';

    final expandedList = <String>[];

    for (var i = 0; i < clauses.length; i++) {
      final clean = _cleanBulletOrNumber(clauses[i]);
      if (clean.isEmpty) continue;

      final isFirst = i == 0;
      final expanded = _expandSingleLearningClause(clean, isFirst: isFirst, totalClauses: clauses.length);
      if (expanded.isNotEmpty) {
        expandedList.add(expanded);
      }
    }

    if (expandedList.isEmpty) return effectiveInput;

    return _joinLearningSentences(expandedList);
  }

  /// Automatically expands brief obstacle keywords/phrases into formal Indonesian sentences.
  static String expandObstacles(String rawInput) {
    final trimmed = rawInput.trim();
    if (trimmed.isEmpty) {
      return defaultNoObstacle;
    }

    final lower = trimmed.toLowerCase();
    if (_containsAny(lower, [
      'tidak ada',
      'nihil',
      'aman',
      'lancar',
      'none',
      'tidak ada kendala',
      'tidak ada hambatan',
      'baik',
      'oke',
      'ok',
      'no obstacle',
      'tanpa kendala',
      'tanpa hambatan'
    ])) {
      if (trimmed.length >= 30) {
        return trimmed.endsWith('.') ? trimmed : '$trimmed.';
      }
      return defaultNoObstacle;
    }

    final clean = _cleanBulletOrNumber(trimmed);
    if (clean.split(RegExp(r'\s+')).length >= 14 &&
        (clean.startsWith('Tidak ada') ||
            clean.startsWith('Menghadapi') ||
            clean.startsWith('Menemui') ||
            clean.startsWith('Mengalami') ||
            clean.startsWith('Sempat'))) {
      return clean.endsWith('.') ? clean : '$clean.';
    }

    String expanded;

    // Cadastral Survey, GIS & Field Obstacles
    if (_containsAny(lower, ['sinyal', 'gps', 'gnss', 'float', 'vegetasi', 'pohon', 'lereng', 'cycle slip'])) {
      expanded =
          'Menghadapi kendala penerimaan sinyal satelit GNSS yang sempat berstatus float akibat kanopi pohon lebat di lokasi survei, yang disiasati dengan metode offset manual menggunakan meteran pita baja dan Total Station.';
    } else if (_containsAny(lower, ['cuaca', 'hujan', 'badai', 'becek', 'hujan lebat'])) {
      expanded =
          'Menghadapi kondisi cuaca hujan di lokasi kegiatan yang sempat menunda survei luar ruangan demi keselamatan peralatan elektronik, namun waktu dimanfaatkan untuk pengolahan data dan digitalisasi di kantor.';
    } else if (_containsAny(lower, ['batas', 'pemilik', 'saksi', 'hadir', 'patok hilang', 'tanda batas'])) {
      expanded =
          'Menemui kendala ketidakhadiran pemilik bidang tanah yang bersebelahan saat penunjukan tanda batas, yang berhasil diselesaikan melalui koordinasi bersama aparat pemerintah setempat untuk penjadwalan verifikasi ulang.';
    } else if (_containsAny(lower, ['overlap', 'tumpang tindih', 'warkah', 'peta lama', 'selisih luas'])) {
      expanded =
          'Menemukan ketidaksesuaian data spasial antara peta pendaftaran analog lama dengan kondisi fisik lapangan riil (overlap), yang ditindaklanjuti melalui rekonstruksi batas dan konfirmasi arsip warkah ukur.';
    } else if (_containsAny(lower, ['medan', 'curam', 'bukit', 'jurang', 'akses', 'topografi'])) {
      expanded =
          'Menghadapi medan topografi yang cukup menantang di lokasi penugasan, yang diatasi dengan pemilihan titik ikat yang aman dan penyesuaian rute jelajah survei.';
    } else if (_containsAny(lower, ['server', 'jaringan', 'geokkp', 'kkp', 'down', 'sinkronisasi', 'internet'])) {
      expanded =
          'Sempat mengalami kelambatan akses jaringan saat sinkronisasi data pada server sistem, yang disiasati dengan merapikan data secara offline terlebih dahulu sebelum proses unggah dilakukan.';
    }
    // Generic Technical & Hardware Obstacles
    else if (_containsAny(lower, ['error', 'bug', 'crash', 'fail', 'gagal', 'exception'])) {
      expanded =
          'Menemui kendala teknis berupa kendala $clean, yang berhasil diatasi melalui penelusuran dokumentasi teknis dan konsultasi bersama mentor pembimbing.';
    } else if (_containsAny(lower, ['laptop', 'pc', 'perangkat', 'hang', 'komputer', 'spek', 'freeze'])) {
      expanded =
          'Mengalami penurunan performa pada perangkat kerja saat memproses $clean, yang disiasati melalui optimalisasi manajemen memori dan aplikasi agar tidak mengganggu alur kerja.';
    } else if (_containsAny(lower, ['belum paham', 'kurang paham', 'bingung', 'sulit', 'kesulitan', 'alur'])) {
      expanded =
          'Sempat mengalami sedikit kendala dalam memahami alur kerja $clean, namun berhasil dipahami dengan baik setelah berdiskusi langsung dengan pembimbing magang.';
    } else if (_containsAny(lower, ['waktu', 'deadline', 'mepet', 'padat'])) {
      expanded =
          'Menghadapi tantangan tenggat waktu yang cukup padat terkait $clean, yang berhasil dituntaskan dengan menyusun prioritas pengerjaan secara teratur.';
    } else {
      expanded =
          'Menghadapi sedikit kendala teknis terkait $clean, namun permasalahan tersebut berhasil ditangani dengan baik berkat koordinasi aktif bersama tim teknis dan pembimbing lapangan.';
    }

    return expanded.endsWith('.') ? expanded : '$expanded.';
  }

  // --------------------------------------------------------------------------
  // CLAUSE PROCESSORS: ACTIVITIES
  // --------------------------------------------------------------------------
  static String _expandSingleActivityClause(String clause, {required bool isFirst, required int totalClauses}) {
    final lower = clause.toLowerCase();

    // 1. Orientasi / Onboarding / Pembekalan / Apel Pagi / Pengarahan
    if (_containsAny(lower, ['orientasi', 'pembekalan', 'pengenalan program', 'onboarding', 'pengarahan awal', 'penerimaan magang', 'apel', 'upacara', 'pengarahan pimpinan'])) {
      final program = _extractFormattedProgramName(clause);
      if (program != null) {
        return 'Mengikuti kegiatan orientasi $program yang mencakup pengenalan program, tata tertib, serta alur pelaksanaan magang';
      }
      if (_containsAny(lower, ['apel', 'upacara'])) {
        return 'Mengikuti kegiatan apel pagi kedinasan serta menyimak pengarahan dan instruksi kerja dari pimpinan instansi penempatan';
      }
      return 'Mengikuti kegiatan orientasi pemagangan yang mencakup pengenalan lingkungan kerja, tata tertib instansi, serta alur pelaksanaan magang';
    }

    // 2. Instalasi / Konfigurasi Software / Persiapan Lingkungan Kerja
    if (_containsAny(lower, ['install', 'instalasi', 'menginstall', 'setup', 'unduh', 'download', 'konfigurasi', 'penginstalan'])) {
      final software = _extractSoftwareName(clause);
      final hasMentor = _containsAny(lower, ['arahan', 'bimbingan', 'instruksi', 'pembimbing', 'mentor']);

      if (hasMentor) {
        return 'mengikuti arahan teknis dari pembimbing lapangan untuk melakukan instalasi dan konfigurasi perangkat lunak $software pada perangkat kerja sebagai persiapan penunjang tugas teknis survei dan pemetaan';
      }
      return 'melakukan instalasi dan konfigurasi perangkat lunak $software pada perangkat kerja sesuai standar penunjang tugas teknis survei dan pemetaan';
    }

    // 3. Cadastral Survey & Measurement (GNSS, Total Station, Terestrial, dsb.)
    if (_containsAny(lower, ['gnss', 'gps', 'rtk', 'geodetik', 'cors', 'total station', 'ts', 'theodolite', 'poligon', 'terestrial', 'waterpass', 'leveling', 'ukur tanah', 'pengukuran bidang', 'survei'])) {
      final loc = _extractLocation(clause);
      final tool = _containsAny(lower, ['total station', 'ts', 'theodolite'])
          ? 'Total Station serta pengukuran poligon batas bidang tanah'
          : (_containsAny(lower, ['waterpass', 'leveling']) ? 'alat ukur Waterpass/Sipat Datar' : 'GNSS Geodetik metode RTK');

      if (loc != null) {
        return 'Melaksanakan pengukuran batas bidang tanah di $loc menggunakan $tool untuk memperoleh data koordinat yang akurat sesuai standar Kantor Pertanahan';
      }
      return 'Melaksanakan kegiatan pengukuran kadastral bidang tanah menggunakan $tool untuk memperoleh data koordinat batas yang akurat sesuai standar Kantor Pertanahan';
    }

    // 4. Pemasangan & Verifikasi Patok / Batas
    if (_containsAny(lower, ['patok', 'tanda batas', 'batas tanah', 'pilar batas', 'pematokan', 'azas contradictoire', 'delimitasi'])) {
      return 'Mengidentifikasi dan memverifikasi pemasangan tanda batas bidang tanah (patok) bersama pemilik tanah dan saksi batas perbatasan sesuai azas contradictoire delimitatie';
    }

    // 5. Digitasi, Pemetaan & AutoCAD / GIS (Non-Installation)
    if (_containsAny(lower, ['autocad', 'cad', 'qgis', 'arcgis', 'gis', 'digitasi', 'peta bidang', 'peta pendaftaran', 'peta situasi', 'plot koordinat', 'ploting', 'topologi', 'clean topology'])) {
      final software = _extractSoftwareName(clause);
      if (_containsAny(lower, ['plot koordinat', 'ploting', 'titik koordinat'])) {
        return 'Melakukan plotting titik koordinat hasil survei lapangan dan digitasi batas bidang tanah menggunakan perangkat lunak $software sesuai sistem proyeksi TM-3°';
      }
      if (_containsAny(lower, ['peta situasi'])) {
        return 'Melakukan penggambaran dan kartografi peta situasi detail lingkungan menggunakan perangkat lunak $software secara presisi';
      }
      return 'Melaksanakan digitasi dan penggambaran peta bidang tanah hasil survei lapangan menggunakan perangkat lunak $software sesuai standar sistem proyeksi TM-3°';
    }

    // 6. Gambar Ukur (GU) & Surat Ukur (SU) / PBT
    if (_containsAny(lower, ['gambar ukur', 'gu', 'surat ukur', 'su', 'pbt', 'sketsa bidang', 'berita acara', 'ba ukur'])) {
      return 'Menyusun dan menyelesaikan Gambar Ukur (GU) serta menyiapkan bahan Peta Bidang Tanah (PBT) dan Surat Ukur (SU) secara rapi dan presisi';
    }

    // 7. Warkah, Buku Tanah & Pengarsipan Dokumen Pertanahan
    if (_containsAny(lower, ['warkah', 'buku tanah', 'arsip', 'mengarsipkan', 'scan warkah', 'pindai warkah', 'penataan berkas', 'ruang arsip'])) {
      return 'Melaksanakan kegiatan penataan, pencarian, dan pengelolaan arsip warkah pertanahan serta buku tanah di ruang arsip guna mendukung tertib administrasi';
    }

    // 8. GeoKKP / Sistem Komputerisasi Kantor Pertanahan
    if (_containsAny(lower, ['geokkp', 'kkp', 'validasi data', 'input sistem', 'entri data', 'cek status bidang'])) {
      return 'Melakukan penataan berkas pertanahan serta validasi dan input data tekstual maupun spasial pada aplikasi GeoKKP Kantor Pertanahan';
    }

    // 9. Excel / Spreadsheet / Rekapitulasi Data
    if (_containsAny(lower, ['excel', 'spreadsheet', 'rekap', 'rekapitulasi', 'input excel', 'daftar bidang', 'tabel data'])) {
      return 'Melakukan rekapitulasi dan penginputan basis data bidang tanah ke dalam lembar kerja digital (Microsoft Excel/Spreadsheet) secara cermat dan sistematis';
    }

    // 10. Pencetakan & Penyiapan Peta Fisik
    if (_containsAny(lower, ['cetak peta', 'print peta', 'ngeprint', 'plotter', 'lipat peta', 'lembar peta'])) {
      return 'Melakukan proses pencetakan, pengecekan skala, dan penataan lembar peta pendaftaran maupun peta bidang tanah untuk kelengkapan berkas teknis';
    }

    // 11. Pelayanan & Loket Pemeriksaan Berkas
    if (_containsAny(lower, ['loket', 'pemohon', 'pelayanan', 'cek berkas', 'kelengkapan berkas', 'permohonan sertipikat'])) {
      return 'Membantu pemeriksaan dan verifikasi kelengkapan berkas permohonan hak atas tanah pada loket pelayanan Kantor Pertanahan';
    }

    // 12. Pengecekan, Kalibrasi & Inventaris Alat Ukur
    if (_containsAny(lower, ['kalibrasi', 'prisma', 'jalon', 'statif', 'cek alat', 'gudang alat', 'rawat alat', 'bersihkan alat'])) {
      return 'Melakukan pengecekan kelayakan, pembersihan, dan kalibrasi peralatan survei lapangan (alat ukur, prisma, dan jalon) sebelum pelaksanaan penugasan';
    }

    // 13. PTSL / Redistribusi Tanah
    if (_containsAny(lower, ['ptsl', 'pendaftaran tanah sistematis', 'redistribusi', 'desa lengkap', 'sidang panitia a'])) {
      final loc = _extractLocation(clause);
      if (loc != null) {
        return 'Melaksanakan kegiatan survei pengukuran bidang tanah dalam program Pendaftaran Tanah Sistematis Lengkap (PTSL) di wilayah $loc';
      }
      return 'Melaksanakan kegiatan survei pengukuran bidang tanah dalam program Pendaftaran Tanah Sistematis Lengkap (PTSL) sesuai target seksi teknis';
    }

    // 14. Rapat / Briefing / Evaluasi / Koordinasi
    if (_containsAny(lower, ['meeting', 'rapat', 'diskusi', 'briefing', 'koordinasi', 'evaluasi'])) {
      return 'Mengikuti agenda koordinasi dan briefing teknis bersama tim seksi pemetaan guna menyelaraskan rencana kerja dan target penugasan';
    }

    // 15. UI / Desain Antarmuka / TI
    if (_containsAny(lower, ['ui', 'antarmuka', 'figma', 'wireframe', 'desain ui'])) {
      return 'Melakukan perancangan dan pengembangan antarmuka (UI) terkait $clause secara terstruktur sesuai standar desain industri';
    }

    // 16. Laporan Harian / Resume Penugasan
    if (_containsAny(lower, ['laporan harian', 'laporan mingguan', 'resume', 'catatan kerja', 'buat laporan'])) {
      return 'Menyusun rekapitulasi laporan harian penugasan serta resume materi teknis pelaksanaan program pemagangan secara terstruktur';
    }

    // 17. Intelligent Dynamic Fallback for ANY other daily input
    return _expandGeneralActivity(clause);
  }

  static String _expandGeneralActivity(String clause) {
    final clean = _cleanBulletOrNumber(clause).trim();
    if (clean.isEmpty) return '';

    final lower = clean.toLowerCase();

    // Membantu ...
    if (lower.startsWith('membantu ')) {
      final sub = clean.substring('membantu '.length).trim();
      return 'Turut serta membantu dalam proses $sub dengan penuh ketelitian di bawah pendampingan staf pembimbing lapangan';
    }

    // Mengikuti ...
    if (lower.startsWith('mengikuti ')) {
      final sub = clean.substring('mengikuti '.length).trim();
      return 'Mengikuti kegiatan $sub secara aktif dan disiplin sesuai jadwal kedinasan instansi penempatan';
    }

    // Melakukan / Melaksanakan ...
    if (lower.startsWith('melakukan ') || lower.startsWith('melaksanakan ')) {
      final sub = clean.replaceFirst(RegExp(r'^(?:melakukan|melaksanakan)\s+', caseSensitive: false), '').trim();
      return 'Melaksanakan kegiatan $sub secara cermat dan sistematis sesuai standar operasional prosedur yang berlaku';
    }

    // Mempelajari / Belajar ...
    if (lower.startsWith('mempelajari ') || lower.startsWith('belajar ')) {
      final sub = clean.replaceFirst(RegExp(r'^(?:mempelajari|belajar)\s+', caseSensitive: false), '').trim();
      return 'Mempelajari dan mendalami alur teknis terkait $sub di bawah bimbingan staf teknis guna mendukung pelaksanaan tugas pemagangan';
    }

    // Membuat / Menyusun / Mengerjakan ...
    if (lower.startsWith('membuat ') || lower.startsWith('menyusun ') || lower.startsWith('mengerjakan ')) {
      final sub = clean.replaceFirst(RegExp(r'^(?:membuat|menyusun|mengerjakan)\s+', caseSensitive: false), '').trim();
      return 'Melakukan penyusunan dan penyelesaian $sub secara terstruktur dan teliti guna mendukung kelancaran administrasi penugasan';
    }

    // Mengecek / Memeriksa ...
    if (lower.startsWith('mengecek ') || lower.startsWith('memeriksa ') || lower.startsWith('cek ')) {
      final sub = clean.replaceFirst(RegExp(r'^(?:mengecek|memeriksa|cek)\s+', caseSensitive: false), '').trim();
      return 'Melakukan pemeriksaan dan verifikasi kelayakan $sub secara teliti guna memastikan kesesuaian data dan dokumen pendukung';
    }

    // Other verbs (starts with me-, ber-, di-, pe-)
    if (_startsVerb(clean)) {
      return 'Melaksanakan kegiatan $clean dengan penuh ketelitian dan berkoordinasi aktif bersama tim teknis di instansi penempatan';
    }

    return 'Melaksanakan kegiatan teknis terkait $clean secara cermat dan sistematis sesuai arahan pembimbing lapangan';
  }

  // --------------------------------------------------------------------------
  // CLAUSE PROCESSORS: LEARNINGS
  // --------------------------------------------------------------------------
  static String _expandSingleLearningClause(String clause, {required bool isFirst, required int totalClauses}) {
    final lower = clause.toLowerCase();

    // 1. Orientasi / Onboarding / Pembekalan / Apel Pagi
    if (_containsAny(lower, ['orientasi', 'pembekalan', 'pengenalan program', 'onboarding', 'pengarahan awal', 'apel', 'upacara'])) {
      final program = _extractFormattedProgramName(clause);
      if (program != null) {
        return 'Memahami struktur program, hak dan kewajiban peserta, serta standar operasional prosedur yang berlaku selama pelaksanaan $program';
      }
      if (_containsAny(lower, ['apel', 'upacara'])) {
        return 'Memahami etika birokrasi kedinasan, kedisiplinan kerja aparatur, serta arahan pimpinan mengenai prioritas pelayanan publik';
      }
      return 'Memahami struktur organisasi, budaya kerja kedinasan, serta standar operasional prosedur yang berlaku selama pelaksanaan program pemagangan';
    }

    // 2. Instalasi / Konfigurasi Software / AutoCAD / GIS
    if (_containsAny(lower, ['install', 'instalasi', 'menginstall', 'setup', 'konfigurasi', 'penginstalan'])) {
      final software = _extractSoftwareName(clause);
      if (!isFirst) {
        return 'Di sisi teknis, memperoleh pemahaman mengenai kesiapan lingkungan kerja digital dan pengaturan awal perangkat lunak $software yang akan digunakan untuk pengolahan data spasial maupun penggambaran teknis di instansi penempatan';
      }
      return 'Memperoleh pemahaman mengenai kesiapan lingkungan kerja digital dan pengaturan awal perangkat lunak $software yang akan digunakan untuk pengolahan data spasial maupun penggambaran teknis di instansi penempatan';
    }

    // 3. Sistem Proyeksi TM-3 BPN
    if (_containsAny(lower, ['tm-3', 'tm3', 'sistem proyeksi', 'proyeksi tm'])) {
      return 'Memahami sistem proyeksi TM-3° yang menjadi standar resmi pemetaan kadastral di lingkungan Kementerian ATR/BPN';
    }

    // 3. Cadastral Survey & Measurement (GNSS, Total Station, dsb.)
    if (_containsAny(lower, ['gnss', 'gps', 'rtk', 'geodetik', 'cors', 'total station', 'ts', 'theodolite', 'poligon', 'terestrial', 'waterpass', 'leveling', 'ukur tanah', 'pengukuran bidang', 'survei'])) {
      return 'Menguasai teknik akuisisi data koordinat presisi tinggi menggunakan peralatan survei modern serta memahami toleransi ketelitian pemetaan kadastral pada sistem proyeksi TM-3° BPN';
    }

    // 4. Pemasangan & Verifikasi Patok / Batas
    if (_containsAny(lower, ['patok', 'tanda batas', 'batas tanah', 'pilar batas', 'pematokan', 'azas contradictoire', 'delimitasi'])) {
      return 'Memahami penerapan azas Contradictoire Delimitatie dalam penetapan tanda batas bidang tanah demi mencegah potensi sengketa batas kepemilikan';
    }

    // 5. Digitasi, Pemetaan & AutoCAD / GIS (Non-Installation)
    if (_containsAny(lower, ['autocad', 'cad', 'qgis', 'arcgis', 'gis', 'digitasi', 'peta bidang', 'peta pendaftaran', 'peta situasi', 'plot koordinat', 'ploting', 'topologi', 'clean topology'])) {
      final software = _extractSoftwareName(clause);
      return 'Meningkatkan kemahiran dalam pengolahan data geospasial, pembuatan topologi bidang tanah bebas overlap, serta kartografi pertanahan digital menggunakan $software';
    }

    // 6. Gambar Ukur (GU) & Surat Ukur (SU) / PBT
    if (_containsAny(lower, ['gambar ukur', 'gu', 'surat ukur', 'su', 'pbt', 'sketsa bidang', 'berita acara'])) {
      return 'Memahami tata cara penyusunan Gambar Ukur (GU) dan Surat Ukur (SU) yang sah sesuai ketentuan teknis pengukuran dan pemetaan pertanahan';
    }

    // 7. Warkah, Buku Tanah & Pengarsipan Dokumen
    if (_containsAny(lower, ['warkah', 'buku tanah', 'arsip', 'mengarsipkan', 'scan warkah', 'pindai warkah', 'penataan berkas', 'ruang arsip'])) {
      return 'Memahami sistem tata kelola dokumen warkah ukur, manajemen penataan buku tanah, serta pentingnya integritas arsip fisik dalam kepastian hukum pertanahan';
    }

    // 8. GeoKKP / Sistem Digital
    if (_containsAny(lower, ['geokkp', 'kkp', 'validasi data', 'input sistem', 'entri data', 'cek status bidang'])) {
      return 'Memahami alur integrasi data yuridis dan data fisik spasial pada sistem Komputerisasi Kantor Pertanahan (GeoKKP) serta validasi konsistensi data pendaftaran tanah';
    }

    // 9. Excel / Spreadsheet / Rekapitulasi Data
    if (_containsAny(lower, ['excel', 'spreadsheet', 'rekap', 'rekapitulasi', 'input excel', 'daftar bidang', 'tabel data'])) {
      return 'Meningkatkan keterampilan pengolahan basis data digital, verifikasi akurasi data tekstual, serta efisiensi rekapitulasi data penugasan';
    }

    // 10. Pencetakan & Penyiapan Peta
    if (_containsAny(lower, ['cetak peta', 'print peta', 'ngeprint', 'plotter', 'lipat peta', 'lembar peta'])) {
      return 'Memahami standar kartografi cetak, pengecekan skala nominal peta pendaftaran, serta manajemen penyiapan lembar kerja fisik';
    }

    // 11. Pelayanan & Loket Pemeriksaan Berkas
    if (_containsAny(lower, ['loket', 'pemohon', 'pelayanan', 'cek berkas', 'kelengkapan berkas', 'permohonan sertipikat'])) {
      return 'Memahami standar operasional prosedur (SOP) pemeriksaan berkas pendaftaran hak atas tanah serta etika komunikasi dalam pelayanan publik kedinasan';
    }

    // 12. Pengecekan, Kalibrasi & Inventaris Alat Ukur
    if (_containsAny(lower, ['kalibrasi', 'prisma', 'jalon', 'statif', 'cek alat', 'gudang alat', 'rawat alat', 'bersihkan alat'])) {
      return 'Memahami prosedur pemeliharaan preventif, kalibrasi instrumen ukur optik/elektronik, dan faktor keselamatan kerja peralatan survei';
    }

    // 13. PTSL / Pendaftaran Tanah
    if (_containsAny(lower, ['ptsl', 'pendaftaran tanah sistematis', 'redistribusi', 'desa lengkap', 'sidang panitia a'])) {
      return 'Mendapatkan wawasan mendalam mengenai alur kerja program Pendaftaran Tanah Sistematis Lengkap (PTSL) mulai dari pengukuran fisik batas hingga pembukuan hak';
    }

    // 14. Rapat / Koordinasi / Komunikasi
    if (_containsAny(lower, ['meeting', 'rapat', 'diskusi', 'briefing', 'koordinasi', 'komunikasi'])) {
      return 'Meningkatkan kemampuan koordinasi kerja tim, pemahaman target penyelesaian berkas, serta komunikasi profesional di lingkungan kerja kedinasan';
    }

    // 15. Laporan Harian / Resume Penugasan
    if (_containsAny(lower, ['laporan harian', 'laporan mingguan', 'resume', 'catatan kerja', 'buat laporan'])) {
      return 'Meningkatkan akuntabilitas kerja, evaluasi capaian tugas harian, serta keterampilan penyusunan laporan dinas yang profesional';
    }

    // 16. Dynamic General Learning Fallback
    return _expandGeneralLearning(clause);
  }

  static String _expandGeneralLearning(String clause) {
    final clean = _cleanBulletOrNumber(clause).trim();
    if (clean.isEmpty) return '';

    final lower = clean.toLowerCase();

    if (lower.startsWith('belajar ') || lower.startsWith('memahami ') || lower.startsWith('mempelajari ')) {
      final sub = clean.replaceFirst(RegExp(r'^(?:belajar|memahami|mempelajari)\s+', caseSensitive: false), '').trim();
      return 'Memahami secara mendalam konsep, alur kerja, dan penerapan teknis mengenai $sub dalam lingkungan kerja kedinasan';
    }

    return 'Memperoleh pemahaman praktis serta wawasan berharga mengenai $clean dalam mendukung efisiensi operasional dan kualitas pelayanan di instansi penempatan';
  }

  // --------------------------------------------------------------------------
  // SENTENCE JOINING HELPERS
  // --------------------------------------------------------------------------
  static String _joinActivitySentences(List<String> sentences) {
    if (sentences.isEmpty) return '';
    if (sentences.length == 1) {
      final s = sentences.first.trim();
      final capitalized = s.isNotEmpty ? '${s[0].toUpperCase()}${s.substring(1)}' : s;
      return capitalized.endsWith('.') ? capitalized : '$capitalized.';
    }

    final buffer = StringBuffer();
    for (var i = 0; i < sentences.length; i++) {
      var s = sentences[i].trim();
      if (s.isEmpty) continue;

      if (i == 0) {
        s = '${s[0].toUpperCase()}${s.substring(1)}';
        buffer.write(s);
        if (!s.endsWith('.')) buffer.write('.');
      } else {
        buffer.write(' ');
        if (!s.startsWith('Selain itu,') &&
            !s.startsWith('Di samping itu,') &&
            !s.startsWith('Kemudian,') &&
            !s.startsWith('Selanjutnya,')) {
          // Check lowercase lead
          final leading = (i == 1) ? 'Selain itu, ' : 'Di samping itu, ';
          final cleanContent = s.replaceFirst(RegExp(r'^(?:selain itu|kemudian|di samping itu),\s*', caseSensitive: false), '');
          final lowerInitial = cleanContent.isNotEmpty
              ? '${cleanContent[0].toLowerCase()}${cleanContent.substring(1)}'
              : cleanContent;
          buffer.write('$leading$lowerInitial');
        } else {
          buffer.write(s);
        }
        if (!buffer.toString().endsWith('.')) buffer.write('.');
      }
    }

    return buffer.toString().trim();
  }

  static String _joinLearningSentences(List<String> sentences) {
    if (sentences.isEmpty) return '';
    if (sentences.length == 1) {
      final s = sentences.first.trim();
      final capitalized = s.isNotEmpty ? '${s[0].toUpperCase()}${s.substring(1)}' : s;
      return capitalized.endsWith('.') ? capitalized : '$capitalized.';
    }

    final buffer = StringBuffer();
    for (var i = 0; i < sentences.length; i++) {
      var s = sentences[i].trim();
      if (s.isEmpty) continue;

      if (i == 0) {
        s = '${s[0].toUpperCase()}${s.substring(1)}';
        buffer.write(s);
        if (!s.endsWith('.')) buffer.write('.');
      } else {
        buffer.write(' ');
        if (!s.startsWith('Di sisi teknis,') &&
            !s.startsWith('Selain itu,') &&
            !s.startsWith('Di samping itu,')) {
          final leading = s.toLowerCase().contains('teknis') || s.toLowerCase().contains('software')
              ? 'Di sisi teknis, '
              : 'Selain itu, ';
          final cleanContent = s.replaceFirst(RegExp(r'^(?:selain itu|di sisi teknis|di samping itu),\s*', caseSensitive: false), '');
          final lowerInitial = cleanContent.isNotEmpty
              ? '${cleanContent[0].toLowerCase()}${cleanContent.substring(1)}'
              : cleanContent;
          buffer.write('$leading$lowerInitial');
        } else {
          buffer.write(s);
        }
        if (!buffer.toString().endsWith('.')) buffer.write('.');
      }
    }

    return buffer.toString().trim();
  }

  // --------------------------------------------------------------------------
  // CLAUSE SPLITTER & PARSER
  // --------------------------------------------------------------------------
  static List<String> _splitIntoClauses(String input) {
    final rawLines = input
        .split(RegExp(r'(?:[\r\n]+|(?<=\w)\.\s+(?=[A-Z]))'))
        .map((e) => _cleanBulletOrNumber(e.trim()))
        .where((e) => e.isNotEmpty)
        .toList();

    final clauses = <String>[];

    for (final line in rawLines) {
      // Split on conjunctions or commas followed by verbal actions or distinct clauses
      final compoundParts = line.split(RegExp(
        r'(?:\s*;\s*|\s*(?:,\s*)?(?:dan|serta|lalu|kemudian|setelah itu|sekaligus|di samping itu)\s+(?=(?:mengikuti|melakukan|melaksanakan|menginstall|install|menyiapkan|membuat|mengerjakan|mempelajari|memasang|mengukur|ukur|menghitung|mengecek|menditigasi|input|ploting|verifikasi|arahan|bimbingan|diskusi|rapat|membantu|merapikan|mengarsipkan|arsip|mencetak|cetak|scan|memeriksa|rekap|kalibrasi|evaluasi|menyusun|apel|upacara)\b))',
        caseSensitive: false,
      ));

      if (compoundParts.length > 1) {
        for (final p in compoundParts) {
          final pt = p.trim();
          if (pt.isNotEmpty) clauses.add(pt);
        }
      } else {
        // Fallback: Check if line has "dan" / "serta" / "lalu" / "kemudian" joining two substantial parts
        final simpleSplit = line.split(RegExp(r'\s+(?:dan|serta|lalu|kemudian)\s+', caseSensitive: false));
        if (simpleSplit.length == 2 &&
            simpleSplit[0].trim().split(' ').length >= 2 &&
            simpleSplit[1].trim().split(' ').length >= 2 &&
            (_containsActionOrSoftware(simpleSplit[1]))) {
          clauses.add(simpleSplit[0].trim());
          clauses.add(simpleSplit[1].trim());
        } else {
          clauses.add(line);
        }
      }
    }

    return clauses;
  }

  static bool _containsActionOrSoftware(String text) {
    final lower = text.toLowerCase();
    return _containsAny(lower, [
      'mengikuti',
      'melakukan',
      'melaksanakan',
      'install',
      'instalasi',
      'menginstall',
      'autocad',
      'cad',
      'qgis',
      'arcgis',
      'geokkp',
      'patok',
      'ukur',
      'survei',
      'digitasi',
      'warkah',
      'arsip',
      'excel',
      'spreadsheet',
      'cetak',
      'loket',
      'prisma',
      'kalibrasi',
      'buku tanah',
      'apel',
      'upacara',
      'pbt',
      'su',
      'gu',
      'membantu',
      'mempelajari',
    ]);
  }

  // --------------------------------------------------------------------------
  // ENTITY & FORMATTING EXTRACTORS
  // --------------------------------------------------------------------------
  static String? _extractFormattedProgramName(String text) {
    // Look for: pemagangan nasional batch ... angkatan ... tahun ...
    final regex = RegExp(
      r'(?:program\s+)?(pemagangan\s+nasional(?:\s+batch\s+[a-zA-Z0-9]+)?(?:\s+angkatan\s+[a-zA-Z0-9]+)?(?:\s+tahun\s+\d{4})?)',
      caseSensitive: false,
    );
    final match = regex.firstMatch(text);
    if (match != null) {
      final rawName = match.group(1)!;
      return _toTitleCaseWithAcronyms(rawName);
    }

    // Generic match for batch / angkatan
    final altRegex = RegExp(
      r'((?:pemagangan|magang|msib|kampus merdeka)(?:\s+[a-zA-Z0-9]+)*(?:\s+batch\s+[a-zA-Z0-9]+)?(?:\s+angkatan\s+[a-zA-Z0-9]+)?(?:\s+tahun\s+\d{4})?)',
      caseSensitive: false,
    );
    final altMatch = altRegex.firstMatch(text);
    if (altMatch != null) {
      return _toTitleCaseWithAcronyms(altMatch.group(1)!);
    }

    return null;
  }

  static String _extractSoftwareName(String text) {
    final lower = text.toLowerCase();
    if (lower.contains('autocad') || lower.contains('cad')) return 'AutoCAD';
    if (lower.contains('arcgis')) return 'ArcGIS';
    if (lower.contains('qgis')) return 'QGIS';
    if (lower.contains('geokkp') || lower.contains('kkp')) return 'GeoKKP';
    if (lower.contains('global mapper')) return 'Global Mapper';
    if (lower.contains('surfer')) return 'Surfer';
    if (lower.contains('agisoft')) return 'Agisoft Metashape';
    if (lower.contains('excel')) return 'Microsoft Excel';
    if (lower.contains('word')) return 'Microsoft Word';
    if (lower.contains('vscode') || lower.contains('visual studio code')) return 'Visual Studio Code';
    if (lower.contains('flutter')) return 'Flutter';
    if (lower.contains('python')) return 'Python';
    return 'geospasial';
  }

  static String? _extractLocation(String text) {
    final regex = RegExp(r'\b(desa|kecamatan|kabupaten|kec\.|kelurahan)\s+([a-zA-Z]+)', caseSensitive: false);
    final match = regex.firstMatch(text);
    if (match != null) {
      final type = match.group(1)!;
      final name = match.group(2)!;
      final formattedType = type.toLowerCase() == 'kec.' ? 'Kecamatan' : '${type[0].toUpperCase()}${type.substring(1).toLowerCase()}';
      final formattedName = '${name[0].toUpperCase()}${name.substring(1).toLowerCase()}';
      return '$formattedType $formattedName';
    }
    return null;
  }

  static String _extractObstaclesFromInput(String text) {
    final lower = text.toLowerCase();
    if (_containsAny(lower, ['hujan', 'badai', 'cuaca'])) {
      return expandObstacles('cuaca hujan');
    }
    if (_containsAny(lower, ['sinyal', 'gps', 'float', 'vegetasi'])) {
      return expandObstacles('sinyal satelit');
    }
    if (_containsAny(lower, ['laptop', 'komputer', 'hang', 'lemot'])) {
      return expandObstacles('perangkat komputer');
    }
    if (_containsAny(lower, ['server', 'jaringan', 'down'])) {
      return expandObstacles('server jaringan');
    }
    return defaultNoObstacle;
  }

  static String _toTitleCaseWithAcronyms(String text) {
    return text.split(RegExp(r'\s+')).map((word) {
      final w = word.trim();
      if (w.isEmpty) return '';
      final lower = w.toLowerCase();

      // Preserve special casing like 3A, 2, 2026
      if (RegExp(r'^\d+[a-zA-Z]+$').hasMatch(w)) {
        return w.toUpperCase();
      }
      if (RegExp(r'^\d+$').hasMatch(w)) {
        return w;
      }
      if (lower == 'nasional') return 'Nasional';
      if (lower == 'pemagangan') return 'Pemagangan';
      if (lower == 'batch') return 'Batch';
      if (lower == 'angkatan') return 'Angkatan';
      if (lower == 'tahun') return 'Tahun';
      if (lower == 'bpn') return 'BPN';
      if (lower == 'atr') return 'ATR';

      return '${w[0].toUpperCase()}${w.substring(1).toLowerCase()}';
    }).join(' ');
  }

  static String _cleanBulletOrNumber(String input) {
    return input.replaceFirst(RegExp(r'^[\s\-\*\•\d\.\)\:]+'), '').trim();
  }

  static bool _containsAny(String text, List<String> keywords) {
    final lower = text.toLowerCase();
    for (final k in keywords) {
      if (k.length <= 4) {
        final pattern = RegExp(r'\b' + RegExp.escape(k) + r'\b');
        if (pattern.hasMatch(lower)) return true;
      } else {
        if (lower.contains(k)) return true;
      }
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

  static bool _isAlreadyFormalParagraph(String text) {
    final words = text.split(RegExp(r'\s+'));
    return words.length >= 22 &&
        (text.startsWith('Melaksanakan') ||
            text.startsWith('Mengikuti') ||
            text.startsWith('Memahami') ||
            text.startsWith('Memperoleh') ||
            text.startsWith('Menyusun') ||
            text.startsWith('Melakukan') ||
            text.startsWith('Di sisi teknis,') ||
            text.startsWith('Selain itu,'));
  }
}
