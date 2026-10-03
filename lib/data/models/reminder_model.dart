class ReminderModel {
  final dynamic id;
  final String title;
  final String time; // HH:mm
  final bool isEnabled;
  final String repeatDays;
  final String category;

  ReminderModel({
    this.id,
    required this.title,
    required this.time,
    required this.isEnabled,
    this.repeatDays = 'Setiap Hari',
    this.category = 'umum',
  });

  factory ReminderModel.fromMap(Map<String, dynamic> map) {
    bool enabled = true;
    if (map['is_enabled'] != null) {
      enabled = (map['is_enabled'] == 1 || map['is_enabled'] == true);
    } else if (map['isEnabled'] != null) {
      enabled = (map['isEnabled'] == true || map['isEnabled'] == 1);
    }

    return ReminderModel(
      id: map['id'],
      title: map['title'] as String? ?? 'Pengingat',
      time: map['time'] as String? ?? '07:00',
      isEnabled: enabled,
      repeatDays: (map['repeat_days'] ?? map['repeatDays']) as String? ?? 'Setiap Hari',
      category: map['category'] as String? ?? 'umum',
    );
  }

  factory ReminderModel.fromJson(Map<String, dynamic> json) => ReminderModel.fromMap(json);

  Map<String, dynamic> toMap() {
    return {
      if (id != null && id is int) 'id': id,
      'title': title,
      'time': time,
      'is_enabled': isEnabled ? 1 : 0,
      'repeat_days': repeatDays,
    };
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id.toString(),
      'title': title,
      'time': time,
      'isEnabled': isEnabled,
      'category': category,
    };
  }

  ReminderModel copyWith({
    dynamic id,
    String? title,
    String? time,
    bool? isEnabled,
    String? repeatDays,
    String? category,
  }) {
    return ReminderModel(
      id: id ?? this.id,
      title: title ?? this.title,
      time: time ?? this.time,
      isEnabled: isEnabled ?? this.isEnabled,
      repeatDays: repeatDays ?? this.repeatDays,
      category: category ?? this.category,
    );
  }
}
