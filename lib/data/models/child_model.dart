class ChildModel {
  final dynamic id;
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

  static String _formatGender(dynamic val) {
    if (val == null) return 'Laki-laki';
    final s = val.toString().toUpperCase();
    if (s == 'FEMALE' || s == 'P' || s.contains('PEREMPUAN')) {
      return 'Perempuan';
    }
    return 'Laki-laki';
  }

  static String _formatDob(dynamic val) {
    if (val == null) return '2018-05-14';
    final s = val.toString();
    if (s.length >= 10) return s.substring(0, 10);
    return '2018-05-14';
  }

  factory ChildModel.fromMap(Map<String, dynamic> map) {
    return ChildModel(
      id: map['id'] ?? 0,
      name: map['name'] as String? ?? 'Anak',
      dateOfBirth: _formatDob(map['date_of_birth'] ?? map['birthDate']),
      gender: _formatGender(map['gender']),
      healthNotes: (map['health_notes'] ?? map['healthHistory']) as String? ?? 'Belum ada catatan khusus',
      isActive: (map['is_active'] == 1 || map['isActive'] == true),
    );
  }

  factory ChildModel.fromJson(Map<String, dynamic> json) => ChildModel.fromMap(json);

  Map<String, dynamic> toMap() {
    return {
      'id': (id is int) ? id : (int.tryParse(id.toString()) ?? 1),
      'name': name,
      'date_of_birth': dateOfBirth,
      'gender': gender,
      'health_notes': healthNotes,
      'is_active': isActive ? 1 : 0,
    };
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id.toString(),
      'name': name,
      'birthDate': dateOfBirth,
      'gender': gender == 'Perempuan' ? 'FEMALE' : 'MALE',
      'healthHistory': healthNotes,
      'isActive': isActive,
    };
  }

  ChildModel copyWith({
    dynamic id,
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
