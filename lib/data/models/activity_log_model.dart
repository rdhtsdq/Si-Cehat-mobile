class ActivityLogModel {
  final dynamic id;
  final dynamic childId;
  final String date;
  final String title;
  final String category; // 'Aktivitas Fisik', 'Hidrasi Sehat', 'Gizi Seimbang', 'Istirahat'
  final int durationMinutes;
  final String intensity; // 'Ringan', 'Sedang', 'Kuat'
  final String notes;
  final String? createdAt;

  ActivityLogModel({
    this.id,
    required this.childId,
    required this.date,
    required this.title,
    this.category = 'Aktivitas Fisik',
    this.durationMinutes = 30,
    this.intensity = 'Sedang',
    this.notes = '',
    this.createdAt,
  });

  factory ActivityLogModel.fromMap(Map<String, dynamic> map) {
    return ActivityLogModel(
      id: map['id'],
      childId: map['childId'] ?? map['child_id'],
      date: map['date']?.toString().substring(0, 10) ?? '',
      title: map['title'] ?? '',
      category: map['category'] ?? 'Aktivitas Fisik',
      durationMinutes:
          (map['durationMinutes'] ?? map['duration_minutes'] as num?)?.toInt() ??
              0,
      intensity: map['intensity'] ?? 'Sedang',
      notes: map['notes'] ?? '',
      createdAt: map['createdAt']?.toString() ?? map['created_at']?.toString(),
    );
  }

  factory ActivityLogModel.fromJson(Map<String, dynamic> json) =>
      ActivityLogModel.fromMap(json);

  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'child_id': childId,
      'date': date,
      'title': title,
      'category': category,
      'duration_minutes': durationMinutes,
      'intensity': intensity,
      'notes': notes,
      'created_at': createdAt ?? DateTime.now().toIso8601String(),
    };
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id.toString(),
      'childId': childId.toString(),
      'date': date,
      'title': title,
      'category': category,
      'durationMinutes': durationMinutes,
      'intensity': intensity,
      'notes': notes,
    };
  }

  ActivityLogModel copyWith({
    dynamic id,
    dynamic childId,
    String? date,
    String? title,
    String? category,
    int? durationMinutes,
    String? intensity,
    String? notes,
    String? createdAt,
  }) {
    return ActivityLogModel(
      id: id ?? this.id,
      childId: childId ?? this.childId,
      date: date ?? this.date,
      title: title ?? this.title,
      category: category ?? this.category,
      durationMinutes: durationMinutes ?? this.durationMinutes,
      intensity: intensity ?? this.intensity,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
