class MotherModel {
  final int id;
  final String name;
  final String education;
  final String occupation;
  final String address;

  MotherModel({
    required this.id,
    required this.name,
    required this.education,
    required this.occupation,
    required this.address,
  });

  factory MotherModel.fromMap(Map<String, dynamic> map) {
    return MotherModel(
      id: map['id'] as int,
      name: map['name'] as String,
      education: map['education'] as String? ?? 'S1 / Sarjana',
      occupation: map['occupation'] as String? ?? 'Ibu Rumah Tangga',
      address: map['address'] as String? ?? 'Bandung',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'education': education,
      'occupation': occupation,
      'address': address,
    };
  }

  MotherModel copyWith({
    int? id,
    String? name,
    String? education,
    String? occupation,
    String? address,
  }) {
    return MotherModel(
      id: id ?? this.id,
      name: name ?? this.name,
      education: education ?? this.education,
      occupation: occupation ?? this.occupation,
      address: address ?? this.address,
    );
  }
}
