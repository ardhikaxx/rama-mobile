class SentenceExpander {
  const SentenceExpander._();

  /// Default formal sentence when there are no obstacles during internship at Kantah Bondowoso.
  static const String defaultNoObstacle =
      'Tidak ada kendala berarti dalam pelaksanaan survei dan pemetaan hari ini; seluruh pengukuran batas bidang tanah dan pengolahan data koordinat di wilayah Bondowoso berjalan lancar sesuai standar teknis BPN.';

  /// Preset templates for smooth cadastral survey & mapping activities without obstacles.
  static const List<String> noObstacleTemplates = [
    'Tidak ada kendala berarti dalam pelaksanaan survei dan pemetaan hari ini; seluruh pengukuran batas bidang tanah dan pengolahan data koordinat di wilayah Bondowoso berjalan lancar sesuai standar teknis BPN.',
    'Seluruh rangkaian kegiatan pengukuran kadastral hari ini terlaksana kondusif tanpa hambatan berkat koordinasi yang baik dengan tim seksi survei pemetaan serta pendampingan perangkat desa setempat.',
    'Peralatan ukur survei (GNSS/Total Station) dan sistem pemetaan GeoKKP berfungsi optimal dengan akurasi data spasial yang memenuhi toleransi ketelitian pemetaan pertanahan.',
  ];

  /// Automatically expands brief activity keywords/phrases into formal Indonesian sentences.
  static String expandActivities(String rawInput) {
    final trimmed = rawInput.trim();
    if (trimmed.isEmpty) return '';

    final lines = trimmed
        .split(RegExp(r'[\r\n]+'))
        .map((e) => e.trim())
        .where((e) => e.isNotEmpty)
        .toList();
    if (lines.isEmpty) return '';

    final expandedList = <String>[];

    for (final line in lines) {
      final clean = _cleanBulletOrNumber(line);
      if (clean.isEmpty) continue;

      // If already a long formal sentence (e.g. >= 14 words), keep as is
      if (clean.split(RegExp(r'\s+')).length >= 14 &&
          (clean.startsWith('Melaksanakan') ||
              clean.startsWith('Melakukan') ||
              clean.startsWith('Menyusun') ||
              clean.startsWith('Mengikuti') ||
              clean.startsWith('Mengidentifikasi'))) {
        expandedList.add(clean.endsWith('.') ? clean : '$clean.');
        continue;
      }

      final lower = clean.toLowerCase();

      String expanded;

      // 1. Cadastral Survey & Mapping Specialized Rules (Kantah Kab. Bondowoso)
      if (_containsAny(lower, ['gnss', 'gps', 'rtk', 'geodetik', 'cors'])) {
        expanded =
            'Melaksanakan pengukuran bidang tanah di lapangan menggunakan GNSS Geodetik metode RTK untuk memperoleh data koordinat batas yang akurat sesuai standar Kantor Pertanahan.';
      } else if (_containsAny(lower, ['total station', 'ts', 'theodolite', 'poligon', 'terestrial'])) {
        expanded =
            'Melakukan pengukuran sudut dan jarak kerangka dasar pemetaan menggunakan Total Station serta pengukuran poligon batas bidang tanah.';
      } else if (_containsAny(lower, ['patok', 'tanda batas', 'batas tanah', 'pilar batas', 'pematokan'])) {
        expanded =
            'Mengidentifikasi dan memverifikasi pemasangan tanda batas bidang tanah (patok) bersama pemilik tanah dan saksi batas perbatasan sesuai azas contradictoire delimitatie.';
      } else if (_containsAny(lower, ['ptsl', 'sistematis lengkap', 'desa ptsl'])) {
        expanded =
            'Melaksanakan kegiatan survei pengukuran bidang tanah dalam program PTSL (Pendaftaran Tanah Sistematis Lengkap) di wilayah penugasan Kabupaten Bondowoso.';
      } else if (_containsAny(lower, ['geokkp', 'kkp', 'aplikasi bpn', 'input kkp'])) {
        expanded =
            'Melakukan input, verifikasi spasial, dan validasi data bidang tanah pada aplikasi Komputerisasi Kantor Pertanahan (GeoKKP) Kantor Pertanahan Kab. Bondowoso.';
      } else if (_containsAny(lower, ['autocad', 'cad', 'qgis', 'arcgis', 'gis', 'digitasi', 'peta bidang'])) {
        expanded =
            'Melaksanakan digitasi dan penggambaran peta bidang tanah hasil survei lapangan menggunakan perangkat lunak geospasial sesuai standar sistem proyeksi TM-3°.';
      } else if (_containsAny(lower, ['gambar ukur', 'gu', 'sketsa bidang'])) {
        expanded =
            'Menyusun dan menyelesaikan Gambar Ukur (GU) yang memuat sketsa bidang tanah, data ukuran batas, serta informasi saksi perbatasan secara rapi dan akurat.';
      } else if (_containsAny(lower, ['surat ukur', 'su', 'pbt', 'peta pendaftaran'])) {
        expanded =
            'Menyiapkan bahan dan penggambaran Peta Bidang Tanah (PBT) serta Surat Ukur (SU) sebagai kelengkapan dokumen yuridis pemetaan pertanahan.';
      } else if (_containsAny(lower, ['koordinat', 'tm-3', 'tm3', 'transformasi', 'perataan', 'baseline'])) {
        expanded =
            'Melakukan pengolahan raw data hasil survei lapangan, koreksi baseline, dan transformasi koordinat ke sistem proyeksi TM-3° Zona BPN.';
      } else if (_containsAny(lower, ['warkah', 'arsip warkah', 'ploting', 'tumpang tindih', 'overlap', 'rekonstruksi'])) {
        expanded =
            'Melakukan pencarian warkah, pengecekan peta pendaftaran, serta ploting bidang tanah untuk memastikan kepastian batas dan mencegah tumpang tindih (overlap).';
      } else if (_containsAny(lower, ['pemecahan', 'pemisahan', 'penggabungan', 'pengembalian batas', 'rutin'])) {
        expanded =
            'Melakukan survei pengukuran kadastral terkait permohonan $clean secara teliti sesuai SOP survei dan pemetaan Kantor Pertanahan Kab. Bondowoso.';
      } else if (_containsAny(lower, ['desa', 'kecamatan', 'bondowoso', 'lapangan'])) {
        expanded =
            'Melakukan peninjauan lokasi dan pengukuran batas bidang tanah bersama aparatur desa setempat di wilayah Kabupaten Bondowoso.';
      }
      // 2. Generic Professional Activity Rules
      else if (_containsAny(lower, ['ui', 'antarmuka', 'figma', 'desain', 'wireframe', 'layout', 'tampilan'])) {
        expanded =
            'Melakukan perancangan dan pengembangan antarmuka (UI) terkait $clean secara terstruktur sesuai dengan standar desain industri.';
      } else if (_containsAny(lower, ['coding', 'koding', 'ngoding', 'develop', 'fitur', 'implementasi', 'backend', 'frontend', 'logic', 'api'])) {
        expanded =
            'Melaksanakan kegiatan implementasi dan pengembangan kode program untuk $clean guna mendukung fungsionalitas sistem.';
      } else if (_containsAny(lower, ['analisis', 'analisa', 'data', 'rekap', 'rekapitulasi', 'evaluasi data', 'riset data'])) {
        expanded =
            'Melakukan kegiatan pengolahan dan analisis data terkait $clean secara cermat untuk menghasilkan laporan yang akurat.';
      } else if (_containsAny(lower, ['meeting', 'rapat', 'diskusi', 'briefing', 'koordinasi', 'evaluasi mingguan'])) {
        expanded =
            'Mengikuti agenda koordinasi dan rapat seksi teknis mengenai $clean guna menyelaraskan target serta progres kerja di Kantah Kab. Bondowoso.';
      } else if (_containsAny(lower, ['test', 'testing', 'uji', 'pengujian', 'qa', 'quality'])) {
        expanded =
            'Melakukan serangkaian proses testing dan pengujian terhadap $clean untuk memastikan seluruh fungsi berjalan tanpa kendala teknis.';
      } else if (_containsAny(lower, ['dokumen', 'dokumentasi', 'laporan', 'modul', 'panduan', 'notula'])) {
        expanded =
            'Menyusun dan menyempurnakan dokumentasi teknis mengenai $clean agar seluruh alur kerja terdokumentasi dengan rapi dan sistematis.';
      } else if (_containsAny(lower, ['administrasi', 'arsip', 'surat', 'surat menyurat', 'input data', 'pembukuan'])) {
        expanded =
            'Mengerjakan penataan arsip dan administrasi kerja terkait $clean secara tertib sesuai arahan dari pembimbing lapangan.';
      } else if (_startsVerb(clean)) {
        expanded =
            'Melaksanakan kegiatan $clean dengan penuh ketelitian dan berkoordinasi aktif bersama tim teknis Kantor Pertanahan Kab. Bondowoso.';
      } else {
        expanded =
            'Melakukan kegiatan teknis survei dan pemetaan terkait $clean secara cermat sesuai arahan instruktur Kantor Pertanahan Kab. Bondowoso.';
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

    final lines = trimmed
        .split(RegExp(r'[\r\n,]+'))
        .map((e) => e.trim())
        .where((e) => e.isNotEmpty)
        .toList();
    if (lines.isEmpty) return '';

    final expandedList = <String>[];

    for (final line in lines) {
      final clean = _cleanBulletOrNumber(line);
      if (clean.isEmpty) continue;

      if (clean.split(RegExp(r'\s+')).length >= 12 &&
          (clean.startsWith('Memperoleh') ||
              clean.startsWith('Memahami') ||
              clean.startsWith('Mendapatkan') ||
              clean.startsWith('Menguasai') ||
              clean.startsWith('Mempelajari'))) {
        expandedList.add(clean.endsWith('.') ? clean : '$clean.');
        continue;
      }

      final lower = clean.toLowerCase();

      String expanded;

      // 1. Cadastral Survey & Mapping Specialized Rules (Kantah Kab. Bondowoso)
      if (_containsAny(lower, ['tm-3', 'tm3', 'proyeksi', 'transverse mercator', 'sistem koordinat'])) {
        expanded =
            'Memahami sistem proyeksi peta TM-3° (Transverse Mercator 3 Derajat) yang menjadi standar resmi pemetaan kadastral di lingkungan Kementerian ATR/BPN.';
      } else if (_containsAny(lower, ['gnss', 'gps', 'rtk', 'statik', 'geodetik', 'cors'])) {
        expanded =
            'Menguasai teknik akuisisi data koordinat presisi tinggi menggunakan receiver GNSS Geodetik metode RTK pada berbagai kondisi medan lapangan.';
      } else if (_containsAny(lower, ['total station', 'ts', 'theodolite', 'poligon', 'sudut'])) {
        expanded =
            'Memahami metode pengukuran terestrial menggunakan Total Station, perhitungan koreksi poligon, dan penentuan posisi titik ikat kerangka dasar pemetaan.';
      } else if (_containsAny(lower, ['contradictoire', 'delimitatie', 'batas', 'patok'])) {
        expanded =
            'Memahami penerapan azas Contradictoire Delimitatie dalam penetapan tanda batas bidang tanah demi mencegah potensi sengketa batas kepemilikan.';
      } else if (_containsAny(lower, ['geokkp', 'kkp', 'aplikasi bpn'])) {
        expanded =
            'Mempelajari alur integrasi data tekstual dan data spasial pertanahan pada sistem Komputerisasi Kantor Pertanahan (GeoKKP) Kementerian ATR/BPN.';
      } else if (_containsAny(lower, ['gambar ukur', 'gu', 'surat ukur', 'su', 'pbt'])) {
        expanded =
            'Memahami tata cara penyusunan Gambar Ukur (GU) dan Surat Ukur (SU) yang sah sesuai ketentuan teknis PMNA/KBPN No. 3 Tahun 1997.';
      } else if (_containsAny(lower, ['ptsl', 'pendaftaran tanah', 'sistematis'])) {
        expanded =
            'Mendapatkan wawasan mendalam mengenai alur kerja program Pendaftaran Tanah Sistematis Lengkap (PTSL) mulai dari pengukuran fisik hingga pembukuan hak.';
      } else if (_containsAny(lower, ['autocad', 'gis', 'qgis', 'arcgis', 'digitasi', 'peta'])) {
        expanded =
            'Meningkatkan kemahiran dalam pengolahan data geospasial, pembuatan topologi bidang tanah bebas overlap, dan kartografi pertanahan digital.';
      } else if (_containsAny(lower, ['komunikasi', 'masyarakat', 'desa', 'pamong', 'koordinasi'])) {
        expanded =
            'Mengasah kemampuan komunikasi lapangan dalam berinteraksi dengan masyarakat pemilik tanah dan perangkat desa di wilayah Kabupaten Bondowoso.';
      } else if (_containsAny(lower, ['regulasi', 'sop', 'atr', 'bpn', 'survei kadastral', 'hukum pertanahan'])) {
        expanded =
            'Memahami regulasi, kode etik surveyor kadastral, serta standar operasional prosedur teknis survei pemetaan di lingkungan Kantor Pertanahan.';
      }
      // 2. Generic Technical & Soft Skills Rules
      else if (_containsAny(lower, ['flutter', 'dart', 'react', 'vue', 'kotlin', 'swift', 'python', 'java', 'sql', 'framework', 'tools'])) {
        expanded =
            'Mendapatkan pemahaman teknis yang mendalam mengenai konsep dan penerapan $clean dalam pengembangan aplikasi modern.';
      } else if (_containsAny(lower, ['git', 'github', 'gitlab', 'version control', 'branch', 'merge'])) {
        expanded =
            'Memahami alur kerja version control menggunakan $clean untuk manajemen kode dan kolaborasi tim yang efisien.';
      } else if (_containsAny(lower, ['database', 'sqlite', 'mysql', 'api', 'rest api', 'backend', 'json'])) {
        expanded =
            'Mempelajari cara kerja integrasi data dan pengelolaan database menggunakan $clean secara terstruktur dan aman.';
      } else if (_containsAny(lower, ['waktu', 'disiplin', 'manajemen waktu', 'tanggung jawab', 'komitmen'])) {
        expanded =
            'Melatih kedisiplinan diri dan kemampuan manajemen waktu kerja agar seluruh target survei dan pemetaan dapat dicapai tepat waktu.';
      } else if (_containsAny(lower, ['troubleshoot', 'debug', 'problem solving', 'analisis masalah', 'pemecahan masalah'])) {
        expanded =
            'Mengasah daya pikir kritis dan kemampuan problem solving dalam mengidentifikasi serta menuntaskan kendala operasional lapangan.';
      } else if (lower.startsWith('belajar ') || lower.startsWith('memahami ') || lower.startsWith('mempelajari ')) {
        expanded =
            'Mendapatkan wawasan berharga dalam $clean serta memahami implementasinya secara nyata di Kantor Pertanahan Kab. Bondowoso.';
      } else {
        expanded =
            'Memperoleh pemahaman teknis dan pengalaman berharga mengenai $clean dalam mendukung operasional survei dan pemetaan Kantor Pertanahan Kab. Bondowoso.';
      }

      expandedList.add(expanded.endsWith('.') ? expanded : '$expanded.');
    }

    if (expandedList.length == 1) {
      return expandedList.first;
    } else {
      return expandedList.map((e) => '• $e').join('\n');
    }
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
      // If user typed or picked a full formal sentence already, return it cleanly
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

    // 1. Cadastral Survey & Mapping Specialized Obstacles (Kantah Kab. Bondowoso)
    if (_containsAny(lower, ['sinyal', 'gps', 'gnss', 'float', 'vegetasi', 'pohon', 'lereng', 'cycle slip'])) {
      expanded =
          'Menghadapi kendala penerimaan sinyal satelit GNSS yang sempat berstatus float akibat kanopi pohon lebat di lokasi survei, yang disiasati dengan metode offset manual menggunakan meteran pita baja dan Total Station.';
    } else if (_containsAny(lower, ['cuaca', 'hujan', 'badai', 'becek', 'hujan lebat'])) {
      expanded =
          'Menghadapi kondisi cuaca hujan di lokasi pengukuran wilayah Bondowoso yang sempat menunda survei luar ruangan demi keselamatan alat ukur elektronik, namun kegiatan dilanjutkan dengan pengolahan data spasial di kantor.';
    } else if (_containsAny(lower, ['batas', 'pemilik', 'saksi', 'hadir', 'patok hilang', 'tanda batas'])) {
      expanded =
          'Menemui kendala ketidakhadiran pemilik bidang tanah yang bersebelahan saat penunjukan tanda batas, yang berhasil diselesaikan melalui koordinasi bersama pamong desa setempat untuk penjadwalan verifikasi ulang.';
    } else if (_containsAny(lower, ['overlap', 'tumpang tindih', 'warkah', 'peta lama', 'selisih luas'])) {
      expanded =
          'Menemukan ketidaksesuaian data spasial antara peta pendaftaran analog lama dengan kondisi fisik lapangan riil (overlap), yang ditindaklanjuti melalui rekonstruksi batas dan konfirmasi arsip warkah ukur.';
    } else if (_containsAny(lower, ['medan', 'curam', 'bukit', 'jurang', 'akses', 'topografi'])) {
      expanded =
          'Menghadapi medan topografi perbukitan yang cukup terjal di wilayah pengukuran Kabupaten Bondowoso, yang diatasi dengan pemilihan titik ikat yang aman dan penyesuaian rute jelajah survei.';
    } else if (_containsAny(lower, ['server', 'jaringan', 'geokkp', 'kkp', 'down', 'sinkronisasi'])) {
      expanded =
          'Sempat mengalami kelambatan sinkronisasi data spasial pada server aplikasi GeoKKP, yang disiasati dengan merapikan data gambar CAD secara offline terlebih dahulu sebelum proses upload.';
    }
    // 2. Generic Technical Obstacle Rules
    else if (_containsAny(lower, ['error', 'bug', 'crash', 'fail', 'gagal', 'exception', 'stacktrace'])) {
      expanded =
          'Menemui kendala teknis berupa kendala $clean, yang berhasil diatasi melalui penelusuran dokumentasi teknis dan konsultasi bersama mentor pembimbing.';
    } else if (_containsAny(lower, ['laptop', 'pc', 'perangkat', 'hang', 'komputer', 'spek', 'freeze'])) {
      expanded =
          'Mengalami penurunan performa pada perangkat kerja saat memproses $clean, yang disiasati melalui optimalisasi manajemen aplikasi agar tidak mengganggu alur kerja.';
    } else if (_containsAny(lower, ['belum paham', 'kurang paham', 'bingung', 'sulit', 'kesulitan', 'alur'])) {
      expanded =
          'Sempat mengalami sedikit kesulitan dalam memahami alur kerja $clean, namun berhasil dipahami dengan baik setelah berdiskusi langsung dengan pembimbing magang.';
    } else if (_containsAny(lower, ['waktu', 'deadline', 'mepet', 'padat'])) {
      expanded =
          'Menghadapi tantangan tenggat waktu yang cukup padat terkait $clean, yang berhasil dituntaskan dengan menyusun prioritas pengerjaan secara teratur.';
    } else {
      expanded =
          'Menghadapi sedikit kendala teknis terkait $clean, namun permasalahan tersebut berhasil ditangani dengan baik berkat koordinasi aktif bersama tim seksi survei pemetaan Kantor Pertanahan Kab. Bondowoso.';
    }

    return expanded.endsWith('.') ? expanded : '$expanded.';
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
}
