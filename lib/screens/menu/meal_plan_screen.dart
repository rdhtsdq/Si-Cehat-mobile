import 'package:flutter/material.dart';
import '../../core/constants/colors.dart';
import '../../core/constants/typography.dart';

class MealPlanScreen extends StatefulWidget {
  const MealPlanScreen({super.key});

  @override
  State<MealPlanScreen> createState() => _MealPlanScreenState();
}

class _MealPlanScreenState extends State<MealPlanScreen> {
  int _range = 0;
  int _day = 0;

  static const _meals = [
    (
      'Sarapan',
      'Nasi telur + sayur bening + buah',
      '07:00',
      'dish-1.png',
      Icons.wb_sunny_outlined,
    ),
    (
      'Camilan Pagi',
      'Pisang',
      '10:30',
      'dish-2.png',
      Icons.local_cafe_outlined,
    ),
    (
      'Makan Siang',
      'Ikan goreng + nasi + sayur asem + buah',
      '13:00',
      'dish-3.png',
      Icons.lunch_dining_outlined,
    ),
    (
      'Camilan Sore',
      'Jagung rebus',
      '16:00',
      'dish-4.png',
      Icons.bakery_dining_outlined,
    ),
    (
      'Makan Malam',
      'Nasi + tempe + sayur kangkung + lalapan',
      '19:00',
      'dish-2.png',
      Icons.dinner_dining_outlined,
    ),
  ];

  @override
  Widget build(BuildContext context) => Scaffold(
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
          if (_range == 1) ...[
            const SizedBox(height: 8),
            Wrap(
              spacing: 6,
              children: List.generate(
                7,
                (i) => ChoiceChip(
                  label: Text(
                    'Hari ${i + 1}',
                    style: const TextStyle(fontSize: 11),
                  ),
                  selected: _day == i,
                  selectedColor: AppColors.primaryGreen,
                  labelStyle: TextStyle(
                    color: _day == i ? Colors.white : AppColors.textDark,
                  ),
                  onSelected: (_) => setState(() => _day = i),
                ),
              ),
            ),
          ],
          const SizedBox(height: 8),
          Row(
            children: [
              const Icon(Icons.calendar_month, size: 16),
              const SizedBox(width: 6),
              Text(
                'Rabu, 23 September 2026',
                style: AppTypography.bodySecondary.copyWith(fontSize: 12),
              ),
            ],
          ),
          const SizedBox(height: 6),
          ..._meals.map(
            (meal) => _mealCard(meal.$1, meal.$2, meal.$3, meal.$4, meal.$5),
          ),
        ],
      ),
    ),
  );

  Widget _introCard() => Container(
    padding: const EdgeInsets.all(12),
    decoration: BoxDecoration(
      color: const Color(0xFFFFF8E8),
      borderRadius: BorderRadius.circular(10),
    ),
    child: Row(
      children: [
        const CircleAvatar(
          radius: 16,
          backgroundColor: Color(0xFFFFD878),
          child: Icon(
            Icons.health_and_safety_outlined,
            size: 18,
            color: Colors.white,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Meal Timing Kamu',
                style: AppTypography.titleCard.copyWith(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                ),
              ),
              Text(
                'Rencana menu harian dengan pilihan makanan bergizi seimbang.',
                style: AppTypography.bodySecondary.copyWith(fontSize: 10),
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
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Fokus Minggu Ini',
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
            _FocusItem(Icons.eco_outlined, 'Tambah sayur\nsetiap hari'),
            _FocusItem(
              Icons.local_drink_outlined,
              'Minum air putih\nlebih rutin',
            ),
            _FocusItem(
              Icons.check_circle_outline,
              'Variasikan sumber\nprotein',
            ),
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
          fontSize: 10,
          color: selected ? Colors.white : AppColors.textDark,
        ),
      ),
      selected: selected,
      selectedColor: AppColors.primaryGreen,
      backgroundColor: const Color(0xFFF0F0F0),
      onSelected: (_) => onTap(),
    ),
  );

  Widget _mealCard(
    String title,
    String description,
    String time,
    String image,
    IconData icon,
  ) => Container(
    margin: const EdgeInsets.only(bottom: 8),
    padding: const EdgeInsets.all(8),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(10),
      boxShadow: const [
        BoxShadow(
          color: Color(0x12000000),
          blurRadius: 4,
          offset: Offset(0, 1),
        ),
      ],
    ),
    child: Row(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Image.asset(
            'assets/figma_features/$image',
            width: 64,
            height: 64,
            fit: BoxFit.cover,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(icon, size: 12, color: AppColors.primaryGreen),
                  const SizedBox(width: 4),
                  Text(
                    title,
                    style: AppTypography.titleCard.copyWith(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                description,
                style: AppTypography.bodyRegular.copyWith(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                '$time  ·  Porsi sesuai kebutuhan anak',
                style: AppTypography.bodySecondary.copyWith(fontSize: 9),
              ),
            ],
          ),
        ),
        const Icon(
          Icons.chevron_right,
          size: 18,
          color: AppColors.textSecondary,
        ),
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
