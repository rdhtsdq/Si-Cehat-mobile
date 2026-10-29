import '../../data/models/recipe_model.dart';
import '../../data/models/education_model.dart';
import '../../data/models/reminder_model.dart';
import '../../data/models/notification_model.dart';

class SeedData {
  static final List<RecipeModel> initialRecipes = [
    RecipeModel(
      id: 'rec_sayur_asem',
      name: 'Sayur Asem',
      category: 'makanan',
      summary: 'Tinggi serat, rendah gula',
      calories: '120 kkal',
      fiber: '4.5 g',
      protein: '3.2 g',
      portion: '1 Mangkuk Sedang',
      ingredients: [
        'Labu siam 100 gram, potong dadu',
        'Kacang panjang 5 lonjor, potong 3 cm',
        'Jagung manis 1 buah, potong melintang',
        'Daun melinjo secukupnya',
        'Asam jawa 2 mata, larutkan',
        'Air 800 ml, garam secukupnya',
      ],
      instructions: [
        'Rebus air hingga mendidih, masukkan jagung manis hingga setengah matang.',
        'Masukkan bumbu halus (bawang merah, kemiri, cabai merah sedikit).',
        'Tambahkan labu siam dan kacang panjang, masak hingga sayuran empuk.',
        'Masukkan air asam jawa dan daun melinjo sesaat sebelum api dimatikan.',
        'Sajikan hangat sebagai lauk berserat tinggi untuk anak.',
      ],
      note: 'Serat dari aneka sayuran membantu memperlambat penyerapan glukosa dalam tubuh anak.',
      iconEmoji: '🍲',
    ),
    RecipeModel(
      id: 'rec_pepes_ikan',
      name: 'Pepes Ikan',
      category: 'makanan',
      summary: 'Sumber protein yang berkualitas',
      calories: '150 kkal',
      fiber: '1.2 g',
      protein: '18.0 g',
      portion: '1 Ekor Sedang',
      ingredients: [
        'Ikan nila/kembung 1 ekor segar',
        'Daun pisang untuk membungkus',
        'Bumbu kuning halus (kunyit, bawang merah, bawang putih, kemiri)',
        'Kemangi 1 genggam',
        'Tomat 1 buah diiris',
      ],
      instructions: [
        'Lumuri ikan yang sudah dibersihkan dengan bumbu halus dan sedikit garam.',
        'Tambahkan daun kemangi dan irisan tomat.',
        'Bungkus rapat dengan daun pisang, semat kedua ujungnya dengan lidi.',
        'Kukus selama 25 menit hingga matang sempurna.',
        'Panggang sebentar di wajan datar agar harum sebelum disajikan.',
      ],
      note: 'Kaya asam lemak sehat dan protein tanpa minyak berlebih.',
      iconEmoji: '🐟',
    ),
    RecipeModel(
      id: 'rec_nasi_tutuk_oncom',
      name: 'Nasi Tutuk Oncom',
      category: 'makanan',
      summary: 'Sumber Energi yang lengkap',
      calories: '220 kkal',
      fiber: '3.5 g',
      protein: '7.0 g',
      portion: '1 Porsi Anak',
      ingredients: [
        'Nasi merah/putih hangat 1 centong',
        'Oncom bakar 50 gram, haluskan',
        'Bawang putih 2 siung, kencur 1 ruas kecil',
        'Garam dan daun kemangi secukupnya',
      ],
      instructions: [
        'Sangrai oncom dengan bumbu kencur dan bawang putih hingga wangi.',
        'Campurkan oncom hangat ke dalam centong nasi.',
        'Aduk rata bersama sedikit daun kemangi segar.',
        'Sajikan bersama lauk berprotein dan lalapan sayur.',
      ],
      note: 'Fermentasi oncom menyediakan protein nabati dan serat pangan yang baik.',
      iconEmoji: '🍚',
    ),
    RecipeModel(
      id: 'rec_wedang_jahe_sereh',
      name: 'Wedang Jahe Sereh Hangat',
      category: 'minuman',
      summary: 'Tanpa pemanis buatan, menyegarkan',
      calories: '35 kkal',
      fiber: '0.5 g',
      protein: '0.2 g',
      portion: '1 Gelas (200 ml)',
      ingredients: [
        'Jahe 1 ruas, memarkan',
        'Sereh 1 batang, memarkan',
        'Kayu manis 1 jari',
        'Madu murni 1 sendok teh',
        'Air 250 ml',
      ],
      instructions: [
        'Rebus air bersama jahe, sereh, dan kayu manis hingga mendidih.',
        'Biarkan hangat, saring ke dalam cangkir.',
        'Tambahkan 1 sendok teh madu murni, aduk rata dan nikmati.',
      ],
      note: 'Pilihan minuman hangat alami menggantikan minuman kemasan berpemanis tinggi.',
      iconEmoji: '🍵',
    ),
    RecipeModel(
      id: 'rec_pisang_kukus',
      name: 'Pisang Barangan Kukus',
      category: 'cemilan',
      summary: 'Cemilan manis alami dan kaya kalium',
      calories: '90 kkal',
      fiber: '2.5 g',
      protein: '1.1 g',
      portion: '1 Buah',
      ingredients: [
        'Pisang barangan/raja 1 buah',
        'Sejumput kelapa parut kukus (opsional)',
      ],
      instructions: [
        'Cuci kulit pisang bersih.',
        'Kukus bersama kulitnya selama 10 menit hingga empuk.',
        'Kupas dan sajikan sebagai camilan sore anak.',
      ],
      note: 'Manis alami tanpa tambahan gula pasir atau minyak goreng.',
      iconEmoji: '🍌',
    ),
  ];

  static final List<ReminderModel> initialReminders = [
    ReminderModel(id: 1, title: 'Sarapan Pagi', time: '07:00', isEnabled: true, category: 'makan', repeatDays: 'Setiap Hari'),
    ReminderModel(id: 2, title: 'Minum air putih', time: '10:00', isEnabled: true, category: 'minum', repeatDays: 'Setiap Hari'),
    ReminderModel(id: 3, title: 'Aktivitas Fisik', time: '16:00', isEnabled: true, category: 'aktivitas', repeatDays: 'Setiap Hari'),
    ReminderModel(id: 4, title: 'Waktu tidur', time: '20:00', isEnabled: true, category: 'tidur', repeatDays: 'Setiap Hari'),
  ];

  static final List<QuizQuestion> sampleQuizQuestions = [
    QuizQuestion(
      question: 'Berapa batas anjuran konsumsi gula harian maksimal untuk anak usia sekolah?',
      options: [
        'Kurang lebih 4-5 sendok teh (25 gram)',
        '10 sendok makan',
        'Bebas selama anak aktif',
        'Tidak ada batasan untuk anak'
      ],
      correctIndex: 0,
      explanation: 'Organisasi Kesehatan Dunia (WHO) dan Kemenkes RI menganjurkan batas maksimal konsumsi gula tambahan sekitar 25 gram atau 4 sendok teh per hari untuk anak.',
    ),
    QuizQuestion(
      question: 'Manakah minuman terbaik untuk hidrasi harian anak?',
      options: [
        'Teh manis kemasan',
        'Air putih bersih dan higienis',
        'Minuman berkarbonasi (soda)',
        'Susu kental manis'
      ],
      correctIndex: 1,
      explanation: 'Air putih adalah pilihan terbaik untuk memenuhi kebutuhan cairan tubuh anak tanpa menambah beban gula dan kalori kosong.',
    ),
    QuizQuestion(
      question: 'Berapa durasi aktivitas fisik aktif yang dianjurkan untuk anak usia 6-12 tahun setiap hari?',
      options: [
        'Cukup 5 menit',
        'Minimal 60 menit (1 jam) per hari',
        'Hanya di akhir pekan',
        'Tidak perlu berolahraga'
      ],
      correctIndex: 1,
      explanation: 'Anak dianjurkan bergerak aktif minimal 60 menit per hari, seperti bermain di luar, bersepeda, berjalan kaki, atau berolahraga ringan.',
    ),
  ];

  static final List<NotificationModel> initialNotifications = [
    NotificationModel(
      id: 'notif-1',
      title: 'Selamat Datang di Si Cehat!',
      message: 'Mulai pantau kesehatan anak Anda dan jelajahi rekomendasi gizi sehat tradisional.',
      type: 'SYSTEM',
      isRead: false,
      createdAt: DateTime(2026, 1, 15, 10, 0),
    ),
    NotificationModel(
      id: 'notif-2',
      title: 'Layanan Konsultasi Tenaga Medis Mitra',
      message: 'Konsultasi dengan Bidan, Ahli Gizi, dan Dokter spesialis anak telah tersedia.',
      type: 'CONSULTATION',
      isRead: false,
      createdAt: DateTime(2026, 1, 15, 9, 30),
    ),
  ];
}
