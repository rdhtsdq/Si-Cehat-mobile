class MotherModel {
  final dynamic id;
  final String name;
  final String email;
  final String phone;
  final String education;
  final String occupation;
  final String address;
  final String role;
  final String? avatarUrl;

  MotherModel({
    required this.id,
    required this.name,
    this.email = '',
    this.phone = '',
    required this.education,
    required this.occupation,
    required this.address,
    this.role = 'GUARDIAN',
    this.avatarUrl,
  });

  factory MotherModel.fromMap(Map<String, dynamic> map) {
    return MotherModel(
      id: map['id'] ?? 1,
      name: map['name'] as String? ?? 'Ibu',
      email: map['email'] as String? ?? '',
      phone: map['phone'] as String? ?? '',
      education: map['education'] as String? ?? '',
      occupation: map['occupation'] as String? ?? '',
      address: map['address'] as String? ?? '',
      role: map['role'] as String? ?? 'GUARDIAN',
      avatarUrl: (map['avatarUrl'] ?? map['avatar_url']) as String?,
    );
  }

  factory MotherModel.fromJson(Map<String, dynamic> json) =>
      MotherModel.fromMap(json);

  Map<String, dynamic> toMap() {
    return {
      'id': (id is int) ? id : (int.tryParse(id.toString()) ?? 1),
      'name': name,
      'education': education,
      'occupation': occupation,
      'address': address,
      'avatar_url': avatarUrl,
    };
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id.toString(),
      'name': name,
      'email': email,
      'phone': phone,
      'education': education,
      'occupation': occupation,
      'address': address,
      'role': role,
      'avatarUrl': avatarUrl,
    };
  }

  MotherModel copyWith({
    dynamic id,
    String? name,
    String? email,
    String? phone,
    String? education,
    String? occupation,
    String? address,
    String? role,
    String? avatarUrl,
  }) {
    return MotherModel(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      education: education ?? this.education,
      occupation: occupation ?? this.occupation,
      address: address ?? this.address,
      role: role ?? this.role,
      avatarUrl: avatarUrl ?? this.avatarUrl,
    );
  }
}
