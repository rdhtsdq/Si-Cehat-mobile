import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/colors.dart';
import '../../core/constants/typography.dart';
import '../../data/models/recipe_model.dart';
import '../../providers/education_provider.dart';
import '../diary/food_diary_screen.dart';
import 'menu_detail_screen.dart';

class _MealItemData {
  final String type; // Sarapan, Camilan Pagi, Makan Siang, Camilan Sore, Makan Malam
  final String title;
  final String time;
  final String image;
  final IconData icon;
  final String calories;
  final String protein;
  final String fiber;
  final String carbs;
  final String description;
  final String tips;
  final String? relatedRecipeId;

  const _MealItemData({
    required this.type,
    required this.title,
    required this.time,
    required this.image,
    required this.icon,
    required this.calories,
    required this.protein,
    required this.fiber,
    required this.carbs,
    required this.description,
    required this.tips,
    this.relatedRecipeId,
  });
}

class MealPlanScreen extends StatefulWidget {
  const MealPlanScreen({super.key});

  @override
  State<MealPlanScreen> createState() => _MealPlanScreenState();
}

class _MealPlanScreenState extends State<MealPlanScreen> {
  int _range = 0; // 0: Menu 1 Hari, 1: Menu 7 Hari, 2: Smart Traditional
  int _day = 0; // 0..6 for 7 days

  // 7-day balanced Indonesian child nutrition plan
  static const List<List<_MealItemData>> _weeklyMeals = [
    // Hari 1
    [
      _MealItemData(
        type: 'Sarapan',
        title: 'Nasi Telur Ceplok + Sayur Bening Bayam + Pepaya',
        time: '07:00',
        image: 'dish-1.png',
        icon: Icons.wb_sunny_outlined,
        calories: '290 kkal',
        protein: '14 g',
        fiber: '3.5 g',
        carbs: '42 g',
        description: '1 centong nasi putih hangat, 1 butir telur mata sapi minim minyak, 1 mangkuk sayur bening bayam jagung manis, dan 2 potong pepaya segar.',
        tips: 'Kombinasi protein telur dan serat bayam membantu fokus belajar anak di pagi hari tanpa lonjakan gula mendadak.',
      ),
      _MealItemData(
        type: 'Camilan Pagi',
        title: 'Pisang Barangan Kukus',
        time: '10:30',
        image: 'dish-2.png',
        icon: Icons.local_cafe_outlined,
        calories: '90 kkal',
        protein: '1.2 g',
        fiber: '2.6 g',
        carbs: '22 g',
        description: '1 buah pisang barangan ukuran sedang, dikukus hangat tanpa tambahan gula.',
        tips: 'Manis alami buah menyediakan energi cadangan yang aman dan ramah insulin.',
        relatedRecipeId: 'rec_pisang_kukus',
      ),
      _MealItemData(
        type: 'Makan Siang',
        title: 'Pepes Ikan Nila + Nasi + Sayur Asem Segar',
        time: '13:00',
        image: 'dish-3.png',
        icon: Icons.lunch_dining_outlined,
        calories: '340 kkal',
        protein: '22 g',
        fiber: '4.8 g',
        carbs: '45 g',
        description: '1 ekor pepes ikan bumbu kuning rempah daun kemangi, 1 centong nasi, dan 1 mangkuk kuah sayur asem labu siam kacang panjang.',
        tips: 'Pepes ikan kaya asam lemak omega-3 dan protein berkualitas tinggi tanpa minyak jenuh.',
        relatedRecipeId: 'rec_pepes_ikan',
      ),
      _MealItemData(
        type: 'Camilan Sore',
        title: 'Jagung Manis Rebus Serut',
        time: '16:00',
        image: 'dish-4.png',
        icon: Icons.bakery_dining_outlined,
        calories: '110 kkal',
        protein: '3.0 g',
        fiber: '3.2 g',
        carbs: '24 g',
        description: '1/2 buah jagung manis rebus diserut hangat, tanpa kental manis atau margarin.',
        tips: 'Camilan biji-bijian utuh kaya serat larut yang baik untuk kesehatan pencernaan.',
      ),
      _MealItemData(
        type: 'Makan Malam',
        title: 'Nasi + Tempe Bacem Panggang + Tumis Kangkung',
        time: '19:00',
        image: 'dish-2.png',
        icon: Icons.dinner_dining_outlined,
        calories: '280 kkal',
        protein: '16 g',
        fiber: '4.2 g',
        carbs: '38 g',
        description: '1 centong nasi, 2 potong tempe bacem panggang teflon, dan tumis kangkung bawang putih minim minyak.',
        tips: 'Fermentasi tempe mendukung mikrobiota usus dan penyerapan zat besi sebelum istirahat malam.',
      ),
    ],

    // Hari 2
    [
      _MealItemData(
        type: 'Sarapan',
        title: 'Bubur Ayam Kampung Sehat + Irisan Wortel',
        time: '07:00',
        image: 'dish-1.png',
        icon: Icons.wb_sunny_outlined,
        calories: '270 kkal',
        protein: '15 g',
        fiber: '2.8 g',
        carbs: '38 g',
        description: '1 mangkuk bubur beras kaldu ayam kampung asli, suwiran dada ayam, irisan wortel rebus, dan daun seledri segar.',
        tips: 'Kuah kaldu alami memberi kehangatan lambung anak dan hidrasi awal hari.',
      ),
      _MealItemData(
        type: 'Camilan Pagi',
        title: 'Apel Merah Potong Segar',
        time: '10:30',
        image: 'dish-4.png',
        icon: Icons.local_cafe_outlined,
        calories: '55 kkal',
        protein: '0.4 g',
        fiber: '2.5 g',
        carbs: '14 g',
        description: '1/2 buah apel potong dicuci bersih dengan kulitnya.',
        tips: 'Pektin pada apel menjaga rasa kenyang dan kestabilan mikrobioma.',
      ),
      _MealItemData(
        type: 'Makan Siang',
        title: 'Nasi Tim Ayam Jamur + Sup Brokoli Tahu',
        time: '13:00',
        image: 'dish-3.png',
        icon: Icons.lunch_dining_outlined,
        calories: '320 kkal',
        protein: '20 g',
        fiber: '4.0 g',
        carbs: '40 g',
        description: '1 porsi nasi tim gurih dada ayam cincang dan jamur merang, disajikan dengan semangkuk sup brokoli tahu sutra hangat.',
        tips: 'Brokoli kaya antioksidan sulforaphane yang memperkuat sistem imun anak.',
      ),
      _MealItemData(
        type: 'Camilan Sore',
        title: 'Ubi Jalar Ungu Kukus',
        time: '16:00',
        image: 'dish-2.png',
        icon: Icons.bakery_dining_outlined,
        calories: '100 kkal',
        protein: '1.5 g',
        fiber: '3.0 g',
        carbs: '23 g',
        description: '1 potong ubi ungu kukus manis alami.',
        tips: 'Karbohidrat kompleks berindeks glikemik rendah baik untuk menjaga energi sore hari.',
      ),
      _MealItemData(
        type: 'Makan Malam',
        title: 'Sayur Lodeh Labu Siam + Tahu Ungkep + Nasi',
        time: '19:00',
        image: 'dish-1.png',
        icon: Icons.dinner_dining_outlined,
        calories: '290 kkal',
        protein: '12 g',
        fiber: '4.5 g',
        carbs: '44 g',
        description: '1 centong nasi, kuah sayur lodeh santan sangat encer dengan labu siam dan kacang panjang, ditambah 2 potong tahu bumbu kuning.',
        tips: 'Gunakan santan encer untuk mengurangi lemak jenuh berlebih pada sajian malam anak.',
      ),
    ],

    // Hari 3
    [
      _MealItemData(
        type: 'Sarapan',
        title: 'Omelet Sayur Pelangi (Wortel, Buncis & Telur)',
        time: '07:00',
        image: 'dish-1.png',
        icon: Icons.wb_sunny_outlined,
        calories: '280 kkal',
        protein: '13 g',
        fiber: '3.0 g',
        carbs: '30 g',
        description: '1 butir telur dikocok dengan wortel cincang, buncis halus, disajikan bersama 1 lembar roti gandum panggang.',
        tips: 'Warna-warni sayur menarik selera makan anak sekaligus melengkapi aneka fitonutrien.',
      ),
      _MealItemData(
        type: 'Camilan Pagi',
        title: 'Jeruk Manis Segar',
        time: '10:30',
        image: 'dish-2.png',
        icon: Icons.local_cafe_outlined,
        calories: '60 kkal',
        protein: '1.0 g',
        fiber: '2.3 g',
        carbs: '15 g',
        description: '1 buah jeruk manis lokal, dikupas langsung makan.',
        tips: 'Vitamin C alami membantu penyerapan zat besi dari sarapan anak.',
      ),
      _MealItemData(
        type: 'Makan Siang',
        title: 'Ikan Kembung Bakar Rempah + Sayur Bayam Bening + Nasi',
        time: '13:00',
        image: 'dish-3.png',
        icon: Icons.lunch_dining_outlined,
        calories: '350 kkal',
        protein: '24 g',
        fiber: '3.6 g',
        carbs: '42 g',
        description: '1 ekor ikan kembung bakar teflon bumbu rempah kunyit jahe, 1 centong nasi putih, dan 1 mangkuk sayur bayam hangat.',
        tips: 'Ikan kembung mengandung DHA dan EPA setara salmon dengan harga yang sangat terjangkau.',
      ),
      _MealItemData(
        type: 'Camilan Sore',
        title: 'Edamame Rebus Gurih Alami',
        time: '16:00',
        image: 'dish-4.png',
        icon: Icons.bakery_dining_outlined,
        calories: '95 kkal',
        protein: '7.5 g',
        fiber: '3.8 g',
        carbs: '8 g',
        description: '1 mangkuk kecil edamame rebus dengan sejumput garam.',
        tips: 'Sumber protein nabati lengkap dan serat pangan tinggi untuk cemilan sore.',
      ),
      _MealItemData(
        type: 'Makan Malam',
        title: 'Sup Ayam Kentang Bening + Tempe Kukus',
        time: '19:00',
        image: 'dish-2.png',
        icon: Icons.dinner_dining_outlined,
        calories: '275 kkal',
        protein: '18 g',
        fiber: '3.2 g',
        carbs: '35 g',
        description: 'Sup kaldu bening dengan potongan daging ayam tanpa kulit, kentang rebus, wortel, dan 2 potong tempe kukus gurih.',
        tips: 'Makan malam berkuah hangat memudahkan pencernaan dan mendukung tidur nyenyak.',
      ),
    ],

    // Hari 4
    [
      _MealItemData(
        type: 'Sarapan',
        title: 'Roti Gandum Panggang Telur Mata Sapi + Susu',
        time: '07:00',
        image: 'dish-1.png',
        icon: Icons.wb_sunny_outlined,
        calories: '310 kkal',
        protein: '16 g',
        fiber: '4.0 g',
        carbs: '36 g',
        description: '1 lembar roti gandum panggang, 1 butir telur mata sapi, selada segar, dan 1 gelas kecil susu sapi tawar tanpa gula.',
        tips: 'Serat gandum utuh memperpanjang rasa kenyang tanpa membuat kantuk saat sekolah.',
      ),
      _MealItemData(
        type: 'Camilan Pagi',
        title: 'Pepaya Potong Dingin',
        time: '10:30',
        image: 'dish-2.png',
        icon: Icons.local_cafe_outlined,
        calories: '50 kkal',
        protein: '0.6 g',
        fiber: '2.0 g',
        carbs: '12 g',
        description: '1 mangkuk kecil pepaya matang segar.',
        tips: 'Enzim papain pada pepaya melancarkan pencernaan anak secara alami.',
      ),
      _MealItemData(
        type: 'Makan Siang',
        title: 'Pecel Lele Panggang + Sayur Asem Komplit + Nasi',
        time: '13:00',
        image: 'dish-3.png',
        icon: Icons.lunch_dining_outlined,
        calories: '360 kkal',
        protein: '25 g',
        fiber: '4.5 g',
        carbs: '46 g',
        description: '1 ekor lele panggang dengan sambal tomat segar tanpa minyak jelantah, nasi putih 1 centong, dan sayur asem segar.',
        tips: 'Memanggang lele menggantikan proses goreng rendam minyak, menurunkan kalori hingga 40%.',
        relatedRecipeId: 'rec_sayur_asem',
      ),
      _MealItemData(
        type: 'Camilan Sore',
        title: 'Pisang Barangan Segar',
        time: '16:00',
        image: 'dish-4.png',
        icon: Icons.bakery_dining_outlined,
        calories: '85 kkal',
        protein: '1.0 g',
        fiber: '2.5 g',
        carbs: '21 g',
        description: '1 buah pisang ukuran sedang siap santap.',
        tips: 'Kalium pada pisang menjaga tekanan darah dan keseimbangan elektrolit tubuh.',
      ),
      _MealItemData(
        type: 'Makan Malam',
        title: 'Tahu Telur Kukus Lembut + Capcay Kuah',
        time: '19:00',
        image: 'dish-1.png',
        icon: Icons.dinner_dining_outlined,
        calories: '260 kkal',
        protein: '15 g',
        fiber: '4.0 g',
        carbs: '30 g',
        description: 'Kukusan tahu sutra dan kocokan telur gurih, disajikan dengan capcay aneka sayur (wortel, sawi, kembang kol).',
        tips: 'Tekstur lembut dan kuah segar sangat disukai anak-anak di malam hari.',
      ),
    ],

    // Hari 5
    [
      _MealItemData(
        type: 'Sarapan',
        title: 'Nasi Gurih Rempah Rendah Santan + Telur Rebus',
        time: '07:00',
        image: 'dish-1.png',
        icon: Icons.wb_sunny_outlined,
        calories: '300 kkal',
        protein: '13 g',
        fiber: '3.0 g',
        carbs: '45 g',
        description: 'Nasi dimasak kaldu daun salam dan serai dengan sedikit santan, 1 butir telur rebus, dan irisan timun segar.',
        tips: 'Aroma rempah alami menggugah nafsu makan anak tanpa perlu tambahan MSG berlebih.',
      ),
      _MealItemData(
        type: 'Camilan Pagi',
        title: 'Semangka Merah Segar',
        time: '10:30',
        image: 'dish-2.png',
        icon: Icons.local_cafe_outlined,
        calories: '45 kkal',
        protein: '0.8 g',
        fiber: '1.2 g',
        carbs: '11 g',
        description: '2 potong semangka merah dingin segar.',
        tips: 'Tinggi kadar air (92%) dan likopen untuk mencegah dehidrasi anak saat aktif bermain.',
      ),
      _MealItemData(
        type: 'Makan Siang',
        title: 'Sup Daging Kacang Merah + Nasi Putih',
        time: '13:00',
        image: 'dish-3.png',
        icon: Icons.lunch_dining_outlined,
        calories: '370 kkal',
        protein: '23 g',
        fiber: '5.2 g',
        carbs: '48 g',
        description: 'Daging sapi tanpa lemak dipadu kacang merah empuk kaya serat dan zat besi, dipadukan 1 centong nasi hangat.',
        tips: 'Kacang merah adalah juara serat nabati yang mencegah stunting dan lonjakan glukosa.',
      ),
      _MealItemData(
        type: 'Camilan Sore',
        title: 'Jagung Manis Rebus Pipil',
        time: '16:00',
        image: 'dish-4.png',
        icon: Icons.bakery_dining_outlined,
        calories: '100 kkal',
        protein: '2.8 g',
        fiber: '3.0 g',
        carbs: '22 g',
        description: '1 cangkir jagung pipil manis rebus tanpa pemanis buatan.',
        tips: 'Karbohidrat kompleks ramah cerna.',
      ),
      _MealItemData(
        type: 'Makan Malam',
        title: 'Tumis Tempe Buncis Bawang Merah + Nasi',
        time: '19:00',
        image: 'dish-2.png',
        icon: Icons.dinner_dining_outlined,
        calories: '280 kkal',
        protein: '16 g',
        fiber: '4.6 g',
        carbs: '38 g',
        description: '1 centong nasi putih, tumisan buncis renyah dan potongan tempe gurih dengan minyak kelapa sedikit.',
        tips: 'Buncis kaya kromium yang membantu efektivitas kerja hormon insulin alami tubuh.',
      ),
    ],

    // Hari 6
    [
      _MealItemData(
        type: 'Sarapan',
        title: 'Lontong Sayur Labu Siam Labu Manis (Tanpa Santan Kental)',
        time: '07:00',
        image: 'dish-1.png',
        icon: Icons.wb_sunny_outlined,
        calories: '290 kkal',
        protein: '12 g',
        fiber: '3.8 g',
        carbs: '46 g',
        description: 'Potongan lontong beras dengan kuah bumbu kuning labu siam encer dan 1/2 butir telur rebus.',
        tips: 'Menu sarapan tradisional khas Nusantara yang disesuaikan agar rendah kolesterol.',
      ),
      _MealItemData(
        type: 'Camilan Pagi',
        title: 'Buah Naga Merah Potong',
        time: '10:30',
        image: 'dish-4.png',
        icon: Icons.local_cafe_outlined,
        calories: '60 kkal',
        protein: '1.2 g',
        fiber: '2.9 g',
        carbs: '13 g',
        description: '1/2 buah naga merah dipotong dadu.',
        tips: 'Antosianin dan serat buah naga merawat flora bakteri baik di usus.',
      ),
      _MealItemData(
        type: 'Makan Siang',
        title: 'Nasi Rawon Daging Tanpa Lemak + Tauge Pendek',
        time: '13:00',
        image: 'dish-3.png',
        icon: Icons.lunch_dining_outlined,
        calories: '360 kkal',
        protein: '24 g',
        fiber: '3.8 g',
        carbs: '44 g',
        description: 'Kuah rawon kluwek kaya rempah dengan irisan daging sapi has dalam, tauge pendek segar, dan 1 centong nasi.',
        tips: 'Kluwek dan serai memiliki antioksidan tinggi pencegah inflamasi seluler.',
        relatedRecipeId: 'rec_nasi_tutuk_oncom',
      ),
      _MealItemData(
        type: 'Camilan Sore',
        title: 'Wedang Kacang Hijau Kuah Jahe (Rendah Gula)',
        time: '16:00',
        image: 'dish-2.png',
        icon: Icons.bakery_dining_outlined,
        calories: '120 kkal',
        protein: '5.0 g',
        fiber: '3.5 g',
        carbs: '22 g',
        description: 'Semangkuk kacang hijau empuk dengan kuah jahe harum, tanpa santan kental, manis secukupnya madu/gula aren.',
        tips: 'Kaya folat dan zinc penting untuk metabolisme sel anak.',
        relatedRecipeId: 'rec_wedang_jahe_sereh',
      ),
      _MealItemData(
        type: 'Makan Malam',
        title: 'Pepes Tahu Ikan Nila + Lalapan Timun + Nasi',
        time: '19:00',
        image: 'dish-1.png',
        icon: Icons.dinner_dining_outlined,
        calories: '270 kkal',
        protein: '18 g',
        fiber: '3.0 g',
        carbs: '36 g',
        description: 'Kukusan pepes daun pisang berisi tahu dan suwiran ikan nila harum kemangi, ditemani nasi dan timun segar.',
        tips: 'Mudah dicerna sebelum istirahat malam dan menjaga gula darah puasa anak tetap stabil.',
        relatedRecipeId: 'rec_pepes_ikan',
      ),
    ],

    // Hari 7
    [
      _MealItemData(
        type: 'Sarapan',
        title: 'Nasi Kuning Kunyit Asli + Telur Suwir + Timun',
        time: '07:00',
        image: 'dish-1.png',
        icon: Icons.wb_sunny_outlined,
        calories: '310 kkal',
        protein: '12 g',
        fiber: '2.5 g',
        carbs: '48 g',
        description: 'Nasi kuning rempah kunyit asli perasan segar, irisan telur dadar tipis, dan potongan mentimun segar.',
        tips: 'Kurkumin pada kunyit melindungi lambung anak dan menstimulasi imunitas alami.',
      ),
      _MealItemData(
        type: 'Camilan Pagi',
        title: 'Melon Hijau Manis Segar',
        time: '10:30',
        image: 'dish-2.png',
        icon: Icons.local_cafe_outlined,
        calories: '50 kkal',
        protein: '0.8 g',
        fiber: '1.4 g',
        carbs: '12 g',
        description: '2 potong melon hijau manis potong dadu.',
        tips: 'Kaya elektrolit kalium dan air menyegarkan tubuh.',
      ),
      _MealItemData(
        type: 'Makan Siang',
        title: 'Sayur Asem Komplit + Ikan Mas Bakar + Nasi',
        time: '13:00',
        image: 'dish-3.png',
        icon: Icons.lunch_dining_outlined,
        calories: '350 kkal',
        protein: '22 g',
        fiber: '4.5 g',
        carbs: '46 g',
        description: 'Sayur asem kuah segar isi jagung, labu, kacang panjang dan melinjo muda, disajikan dengan ikan bakar bumbu jahe.',
        tips: 'Sajian lengkap kaya serat sayuran dan protein murni tanpa lemak berlebih.',
        relatedRecipeId: 'rec_sayur_asem',
      ),
      _MealItemData(
        type: 'Camilan Sore',
        title: 'Puding Buah Alami Sari Jeruk & Agar-agar',
        time: '16:00',
        image: 'dish-4.png',
        icon: Icons.bakery_dining_outlined,
        calories: '75 kkal',
        protein: '1.0 g',
        fiber: '2.8 g',
        carbs: '16 g',
        description: 'Puding agar-agar rumput laut bening dengan potongan buah asli tanpa pemanis sintetis.',
        tips: 'Serat larut agar-agar baik untuk saluran cerna anak.',
      ),
      _MealItemData(
        type: 'Makan Malam',
        title: 'Soto Ayam Bening Kuah Rempah + Tauge & Nasi',
        time: '19:00',
        image: 'dish-2.png',
        icon: Icons.dinner_dining_outlined,
        calories: '280 kkal',
        protein: '18 g',
        fiber: '3.0 g',
        carbs: '38 g',
        description: 'Kuah soto bening rempah kapulaga serai, suwiran daging ayam kampung, tauge segar, dan 1 centong nasi putih.',
        tips: 'Kuah hangat kaya rempah menghangatkan tubuh anak di malam hari dan menenangkan istirahatnya.',
      ),
    ],
  ];

  String _formatIndonesianDate(DateTime dt) {
    const days = ['Senin', 'Selasa', 'Rabu', 'Kamis', 'Jumat', 'Sabtu', 'Minggu'];
    const months = [
      'Januari',
      'Februari',
      'Maret',
      'April',
      'Mei',
      'Juni',
      'Juli',
      'Agustus',
      'September',
      'Oktober',
      'November',
      'Desember',
    ];
    final dayName = days[dt.weekday - 1];
    final monthName = months[dt.month - 1];
    return '$dayName, ${dt.day} $monthName ${dt.year}';
  }

  void _showMealDetailsModal(_MealItemData meal, List<RecipeModel> allRecipes) {
    RecipeModel? relatedRecipe;
    if (meal.relatedRecipeId != null) {
      final matches = allRecipes.where((r) => r.id == meal.relatedRecipeId);
      if (matches.isNotEmpty) {
        relatedRecipe = matches.first;
      }
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        padding: const EdgeInsets.all(20),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 14),
            Row(
              children: [
                CircleAvatar(
                  radius: 18,
                  backgroundColor: const Color(0xFFE2F3E7),
                  child: Icon(meal.icon, size: 20, color: AppColors.primaryGreenDark),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${meal.type} · ${meal.time}',
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primaryGreenDark,
                        ),
                      ),
                      Text(
                        meal.title,
                        style: AppTypography.titleCard.copyWith(fontSize: 16),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),

            // Nutrition chips
            Row(
              children: [
                _buildModalNutriChip('Energi', meal.calories, const Color(0xFFE8F5E9)),
                const SizedBox(width: 8),
                _buildModalNutriChip('Protein', meal.protein, const Color(0xFFE0F2FE)),
                const SizedBox(width: 8),
                _buildModalNutriChip('Serat', meal.fiber, const Color(0xFFFEF3C7)),
                const SizedBox(width: 8),
                _buildModalNutriChip('Karbo', meal.carbs, const Color(0xFFFCE7F3)),
              ],
            ),
            const SizedBox(height: 14),

            Text(
              'Rincian Menu & Porsi Anak:',
              style: AppTypography.titleCard.copyWith(fontSize: 13),
            ),
            const SizedBox(height: 4),
            Text(
              meal.description,
              style: AppTypography.bodyRegular.copyWith(fontSize: 12, color: AppColors.textDark),
            ),
            const SizedBox(height: 12),

            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: const Color(0xFFF0FDF4),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: const Color(0xFFBBF7D0)),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.verified_outlined, size: 16, color: AppColors.primaryGreenDark),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      meal.tips,
                      style: const TextStyle(fontSize: 11, color: AppColors.primaryGreenDark),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 18),

            Row(
              children: [
                if (relatedRecipe != null) ...[
                  Expanded(
                    child: OutlinedButton.icon(
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.primaryGreen,
                        side: const BorderSide(color: AppColors.primaryGreen),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                      onPressed: () {
                        Navigator.pop(ctx);
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => MenuDetailScreen(recipe: relatedRecipe),
                          ),
                        );
                      },
                      icon: const Icon(Icons.menu_book, size: 18),
                      label: const Text('Lihat Resep', style: TextStyle(fontSize: 12)),
                    ),
                  ),
                  const SizedBox(width: 10),
                ],
                Expanded(
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryGreen,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    onPressed: () {
                      Navigator.pop(ctx);
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => FoodDiaryScreen(
                            initialFood: meal.title,
                            initialMeal: meal.type,
                          ),
                        ),
                      );
                    },
                    icon: const Icon(Icons.bookmark_add_outlined, size: 18),
                    label: const Text('Catat di Diary', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }

  Widget _buildModalNutriChip(String label, String value, Color bg) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          children: [
            Text(label, style: const TextStyle(fontSize: 10, color: AppColors.textSecondary)),
            const SizedBox(height: 2),
            Text(value, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.textDark)),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final eduProv = Provider.of<EducationProvider>(context);
    final allRecipes = eduProv.allRecipes;

    final targetDate = DateTime.now().add(Duration(days: _range == 1 ? _day : 0));
    final activeMeals = _range == 1 ? _weeklyMeals[_day] : _weeklyMeals[0];

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(
            Icons.chevron_left,
            size: 28,
            color: AppColors.textDark,
          ),
        ),
        title: Text(
          'Rencana Menu',
          style: AppTypography.headingScreen.copyWith(
            fontSize: 20,
            color: AppColors.textDark,
          ),
        ),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
          children: [
            _introCard(),
            const SizedBox(height: 12),
            _focusCard(),
            const SizedBox(height: 12),

            // Top Menu Tabs
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _choice(
                    'Menu 1 Hari',
                    _range == 0,
                    () => setState(() => _range = 0),
                  ),
                  _choice(
                    'Menu 7 Hari',
                    _range == 1,
                    () => setState(() => _range = 1),
                  ),
                  _choice(
                    'Smart Traditional Meal Plan',
                    _range == 2,
                    () => setState(() => _range = 2),
                  ),
                ],
              ),
            ),

            // 7-day selectors
            if (_range == 1) ...[
              const SizedBox(height: 8),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: List.generate(
                    7,
                    (i) => Padding(
                      padding: const EdgeInsets.only(right: 6),
                      child: ChoiceChip(
                        label: Text(
                          'Hari ${i + 1}',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: _day == i ? Colors.white : AppColors.textDark,
                          ),
                        ),
                        selected: _day == i,
                        selectedColor: AppColors.primaryGreen,
                        backgroundColor: const Color(0xFFF1F5F9),
                        onSelected: (_) => setState(() => _day = i),
                      ),
                    ),
                  ),
                ),
              ),
            ],

            const SizedBox(height: 10),

            // Date indicator (for 1-day or 7-day schedules)
            if (_range != 2) ...[
              Row(
                children: [
                  const Icon(Icons.calendar_month, size: 16, color: AppColors.primaryGreenDark),
                  const SizedBox(width: 6),
                  Text(
                    _formatIndonesianDate(targetDate),
                    style: AppTypography.bodySecondary.copyWith(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: AppColors.primaryGreenDark,
                    ),
                  ),
                  const Spacer(),
                  Text(
                    '5 Jadwal Makan Seimbang',
                    style: AppTypography.bodySecondary.copyWith(fontSize: 11),
                  ),
                ],
              ),
              const SizedBox(height: 8),

              // Meal cards
              ...activeMeals.map(
                (meal) => _mealCard(meal, allRecipes),
              ),
            ] else ...[
              // Smart Traditional Meal Plan View
              Row(
                children: [
                  const Icon(Icons.restaurant_menu, size: 16, color: AppColors.primaryGreenDark),
                  const SizedBox(width: 6),
                  Text(
                    'Katalog Resep Tradisional Pintar (${allRecipes.length})',
                    style: AppTypography.bodySecondary.copyWith(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: AppColors.primaryGreenDark,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Text(
                'Menu tradisional Nusantara bergizi seimbang, tinggi serat, dan rendah gula untuk pencegahan diabetes & stunting.',
                style: AppTypography.bodySecondary.copyWith(fontSize: 11),
              ),
              const SizedBox(height: 10),

              ...allRecipes.map((recipe) => _traditionalRecipeCard(recipe)),
            ],
          ],
        ),
      ),
    );
  }

  Widget _introCard() => Container(
    padding: const EdgeInsets.all(12),
    decoration: BoxDecoration(
      color: const Color(0xFFFFF8E8),
      borderRadius: BorderRadius.circular(10),
      border: Border.all(color: const Color(0xFFFFE08A)),
    ),
    child: Row(
      children: [
        const CircleAvatar(
          radius: 18,
          backgroundColor: Color(0xFFFFD878),
          child: Icon(
            Icons.health_and_safety_outlined,
            size: 20,
            color: Colors.white,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Meal Timing & Gizi Seimbang',
                style: AppTypography.titleCard.copyWith(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                'Jadwal makan teratur membantu menjaga glukosa darah anak stabil sepanjang hari.',
                style: AppTypography.bodySecondary.copyWith(fontSize: 11),
              ),
            ],
          ),
        ),
      ],
    ),
  );

  Widget _focusCard() => Container(
    padding: const EdgeInsets.all(12),
    decoration: BoxDecoration(
      color: const Color(0xFFF0F8F2),
      borderRadius: BorderRadius.circular(10),
      border: Border.all(color: AppColors.lightGreen.withValues(alpha: 0.5)),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Fokus Nutrisi Minggu Ini',
          style: AppTypography.titleCard.copyWith(
            fontSize: 12,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 8),
        const Wrap(
          spacing: 10,
          runSpacing: 8,
          children: [
            _FocusItem(Icons.eco_outlined, 'Sayur serat di\nsetiap menu'),
            _FocusItem(Icons.local_drink_outlined, 'Air putih rutin,\nstop soda'),
            _FocusItem(Icons.check_circle_outline, 'Variasi ikan &\ntempe alami'),
          ],
        ),
      ],
    ),
  );

  Widget _choice(String label, bool selected, VoidCallback onTap) => Padding(
    padding: const EdgeInsets.only(right: 6),
    child: ChoiceChip(
      label: Text(
        label,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: selected ? Colors.white : AppColors.textDark,
        ),
      ),
      selected: selected,
      selectedColor: AppColors.primaryGreen,
      backgroundColor: const Color(0xFFF0F0F0),
      onSelected: (_) => onTap(),
    ),
  );

  Widget _mealCard(_MealItemData meal, List<RecipeModel> allRecipes) => Container(
    margin: const EdgeInsets.only(bottom: 10),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(12),
      boxShadow: const [
        BoxShadow(
          color: Color(0x0F000000),
          blurRadius: 6,
          offset: Offset(0, 2),
        ),
      ],
      border: Border.all(color: const Color(0xFFF1F5F9)),
    ),
    child: Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => _showMealDetailsModal(meal, allRecipes),
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.asset(
                  'assets/figma_features/${meal.image}',
                  width: 68,
                  height: 68,
                  fit: BoxFit.cover,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(meal.icon, size: 14, color: AppColors.primaryGreen),
                        const SizedBox(width: 4),
                        Text(
                          meal.type,
                          style: AppTypography.titleCard.copyWith(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: AppColors.primaryGreenDark,
                          ),
                        ),
                        const Spacer(),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF1F5F9),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            meal.time,
                            style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      meal.title,
                      style: AppTypography.bodyRegular.copyWith(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Text(
                          meal.calories,
                          style: const TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: AppColors.primaryGreenDark,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Prot: ${meal.protein} · Serat: ${meal.fiber}',
                          style: AppTypography.bodySecondary.copyWith(fontSize: 9),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 4),
              const Icon(
                Icons.chevron_right,
                size: 20,
                color: AppColors.textSecondary,
              ),
            ],
          ),
        ),
      ),
    ),
  );

  Widget _traditionalRecipeCard(RecipeModel recipe) => Container(
    margin: const EdgeInsets.only(bottom: 10),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(12),
      border: Border.all(color: const Color(0xFFE2E8F0)),
      boxShadow: const [
        BoxShadow(
          color: Color(0x0C000000),
          blurRadius: 4,
          offset: Offset(0, 1),
        ),
      ],
    ),
    child: Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => MenuDetailScreen(recipe: recipe),
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: AppColors.veryLightGreen,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(recipe.iconEmoji, style: const TextStyle(fontSize: 24)),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          recipe.name,
                          style: AppTypography.titleCard.copyWith(fontSize: 14),
                        ),
                        Text(
                          recipe.summary,
                          style: AppTypography.bodySecondary.copyWith(fontSize: 11),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xFFE2F3E7),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      recipe.calories,
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primaryGreenDark,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  _recipeMiniTag(Icons.grass, 'Serat: ${recipe.fiber}'),
                  const SizedBox(width: 8),
                  _recipeMiniTag(Icons.fitness_center, 'Protein: ${recipe.protein}'),
                  const Spacer(),
                  TextButton.icon(
                    style: TextButton.styleFrom(
                      padding: EdgeInsets.zero,
                      minimumSize: const Size(50, 24),
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                    onPressed: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => FoodDiaryScreen(
                          initialFood: recipe.name,
                          initialMeal: 'Makan Siang',
                        ),
                      ),
                    ),
                    icon: const Icon(Icons.add, size: 14, color: AppColors.primaryGreen),
                    label: const Text(
                      'Catat Diary',
                      style: TextStyle(fontSize: 11, color: AppColors.primaryGreen, fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    ),
  );

  Widget _recipeMiniTag(IconData icon, String text) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
    decoration: BoxDecoration(
      color: const Color(0xFFF8FAFC),
      borderRadius: BorderRadius.circular(4),
      border: Border.all(color: const Color(0xFFE2E8F0)),
    ),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 12, color: AppColors.textSecondary),
        const SizedBox(width: 4),
        Text(text, style: const TextStyle(fontSize: 10, color: AppColors.textSecondary)),
      ],
    ),
  );
}

class _FocusItem extends StatelessWidget {
  final IconData icon;
  final String label;
  const _FocusItem(this.icon, this.label);

  @override
  Widget build(BuildContext context) => SizedBox(
    width: 95,
    child: Row(
      children: [
        Icon(icon, size: 15, color: AppColors.primaryGreenDark),
        const SizedBox(width: 4),
        Expanded(child: Text(label, style: const TextStyle(fontSize: 9))),
      ],
    ),
  );
}
