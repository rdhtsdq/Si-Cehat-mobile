class ChildModel {
  final int id;
  final String name;
  final String dateOfBirth; // YYYY-MM-DD date-only
  final String gender;
  final String healthNotes;
  final bool isActive;

  ChildModel({
    required this.id,
    required this.name,
    required this.dateOfBirth,
    required this.gender,
    required this.healthNotes,
    this.isActive = false,
  });

  factory ChildModel.fromMap(Map<String, dynamic> map) {
    return ChildModel(
      id: map['id'] as int,
      name: map['name'] as String,
      dateOfBirth: map['date_of_birth'] as String? ?? '2018-05-14',
      gender: map['gender'] as String? ?? 'Laki-laki',
      healthNotes: map['health_notes'] as String? ?? 'Belum ada catatan khusus',
      isActive: (map['is_active'] as int? ?? 0) == 1,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'date_of_birth': dateOfBirth,
      'gender': gender,
      'health_notes': healthNotes,
      'is_active': isActive ? 1 : 0,
    };
  }

  ChildModel copyWith({
    int? id,
    String? name,
    String? dateOfBirth,
    String? gender,
    String? healthNotes,
    bool? isActive,
  }) {
    return ChildModel(
      id: id ?? this.id,
      name: name ?? this.name,
      dateOfBirth: dateOfBirth ?? this.dateOfBirth,
      gender: gender ?? this.gender,
      healthNotes: healthNotes ?? this.healthNotes,
      isActive: isActive ?? this.isActive,
    );
  }

  int get ageInYears {
    try {
      final dob = DateTime.parse(dateOfBirth);
      final now = DateTime.now();
      int age = now.year - dob.year;
      if (now.month < dob.month || (now.month == dob.month && now.day < dob.day)) {
        age--;
      }
      return age;
    } catch (_) {
      return 8; // fallback default
    }
  }
}
