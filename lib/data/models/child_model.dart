class ChildModel {
  final dynamic id;
  final String name;
  final String dateOfBirth; // YYYY-MM-DD date-only
  final String gender;
  final String healthNotes;
  final bool isActive;
  final String? latestRiskCategory;
  final int? latestRiskScore;
  final String? avatarUrl;

  ChildModel({
    required this.id,
    required this.name,
    required this.dateOfBirth,
    required this.gender,
    required this.healthNotes,
    this.isActive = false,
    this.latestRiskCategory,
    this.latestRiskScore,
    this.avatarUrl,
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
    if (val == null) return '';
    final s = val.toString().trim();
    if (s.length >= 10) return s.substring(0, 10);
    return s;
  }

  factory ChildModel.fromMap(Map<String, dynamic> map) {
    String? riskCat;
    int? riskScore;
    if (map['screenings'] is List && (map['screenings'] as List).isNotEmpty) {
      final first = (map['screenings'] as List).first;
      if (first is Map) {
        riskCat = first['riskCategory'] as String?;
        riskScore = (first['riskScore'] as num?)?.toInt();
      }
    }

    return ChildModel(
      id: map['id'] ?? 0,
      name: map['name'] as String? ?? 'Anak',
      dateOfBirth: _formatDob(map['date_of_birth'] ?? map['birthDate']),
      gender: _formatGender(map['gender']),
      healthNotes:
          (map['health_notes'] ?? map['healthHistory']) as String? ?? '',
      isActive: (map['is_active'] == 1 || map['isActive'] == true),
      latestRiskCategory: riskCat ?? (map['latestRiskCategory'] as String?),
      latestRiskScore: riskScore ?? (map['latestRiskScore'] as num?)?.toInt(),
      avatarUrl: (map['avatarUrl'] ?? map['avatar_url']) as String?,
    );
  }

  factory ChildModel.fromJson(Map<String, dynamic> json) =>
      ChildModel.fromMap(json);

  Map<String, dynamic> toMap() {
    return {
      'id': (id is int) ? id : (int.tryParse(id.toString()) ?? 1),
      'name': name,
      'date_of_birth': dateOfBirth,
      'gender': gender,
      'health_notes': healthNotes,
      'is_active': isActive ? 1 : 0,
      'avatar_url': avatarUrl,
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
      if (latestRiskCategory != null) 'latestRiskCategory': latestRiskCategory,
      if (latestRiskScore != null) 'latestRiskScore': latestRiskScore,
      if (avatarUrl != null) 'avatarUrl': avatarUrl,
    };
  }

  ChildModel copyWith({
    dynamic id,
    String? name,
    String? dateOfBirth,
    String? gender,
    String? healthNotes,
    bool? isActive,
    String? latestRiskCategory,
    int? latestRiskScore,
    String? avatarUrl,
  }) {
    return ChildModel(
      id: id ?? this.id,
      name: name ?? this.name,
      dateOfBirth: dateOfBirth ?? this.dateOfBirth,
      gender: gender ?? this.gender,
      healthNotes: healthNotes ?? this.healthNotes,
      isActive: isActive ?? this.isActive,
      latestRiskCategory: latestRiskCategory ?? this.latestRiskCategory,
      latestRiskScore: latestRiskScore ?? this.latestRiskScore,
      avatarUrl: avatarUrl ?? this.avatarUrl,
    );
  }

  bool get isProfileComplete {
    return name.trim().isNotEmpty &&
        dateOfBirth.trim().isNotEmpty &&
        gender.trim().isNotEmpty;
  }

  int get ageInYears {
    if (dateOfBirth.isEmpty) return 7;
    try {
      final dob = DateTime.parse(dateOfBirth);
      final now = DateTime.now();
      int age = now.year - dob.year;
      if (now.month < dob.month ||
          (now.month == dob.month && now.day < dob.day)) {
        age--;
      }
      return age.clamp(1, 18);
    } catch (_) {
      return 7;
    }
  }
}
