class ReminderModel {
  final int? id;
  final String title;
  final String time; // HH:mm
  final bool isEnabled;
  final String repeatDays;

  ReminderModel({
    this.id,
    required this.title,
    required this.time,
    required this.isEnabled,
    this.repeatDays = 'Setiap Hari',
  });

  factory ReminderModel.fromMap(Map<String, dynamic> map) {
    return ReminderModel(
      id: map['id'] as int?,
      title: map['title'] as String,
      time: map['time'] as String,
      isEnabled: (map['is_enabled'] as int) == 1,
      repeatDays: map['repeat_days'] as String? ?? 'Setiap Hari',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'title': title,
      'time': time,
      'is_enabled': isEnabled ? 1 : 0,
      'repeat_days': repeatDays,
    };
  }

  ReminderModel copyWith({
    int? id,
    String? title,
    String? time,
    bool? isEnabled,
    String? repeatDays,
  }) {
    return ReminderModel(
      id: id ?? this.id,
      title: title ?? this.title,
      time: time ?? this.time,
      isEnabled: isEnabled ?? this.isEnabled,
      repeatDays: repeatDays ?? this.repeatDays,
    );
  }
}
