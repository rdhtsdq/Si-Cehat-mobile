class NotificationModel {
  final String id;
  final String title;
  final String message;
  final String type; // CONSULTATION, REMINDER, EDUCATION, SYSTEM
  final String? referenceId;
  final bool isRead;
  final DateTime createdAt;

  NotificationModel({
    required this.id,
    required this.title,
    required this.message,
    required this.type,
    this.referenceId,
    required this.isRead,
    required this.createdAt,
  });

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    DateTime created = DateTime.now();
    if (json['createdAt'] != null) {
      created = DateTime.tryParse(json['createdAt'].toString()) ?? DateTime.now();
    } else if (json['created_at'] != null) {
      created = DateTime.tryParse(json['created_at'].toString()) ?? DateTime.now();
    }

    bool read = false;
    if (json['isRead'] != null) {
      read = json['isRead'] == true || json['isRead'] == 1;
    } else if (json['is_read'] != null) {
      read = json['is_read'] == 1 || json['is_read'] == true;
    }

    return NotificationModel(
      id: json['id']?.toString() ?? '',
      title: json['title'] as String? ?? 'Pemberitahuan',
      message: json['message'] as String? ?? '',
      type: (json['type'] as String? ?? 'SYSTEM').toUpperCase(),
      referenceId: json['referenceId']?.toString() ?? json['reference_id']?.toString(),
      isRead: read,
      createdAt: created,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'message': message,
      'type': type,
      'reference_id': referenceId,
      'is_read': isRead ? 1 : 0,
      'created_at': createdAt.toIso8601String(),
    };
  }

  NotificationModel copyWith({
    String? id,
    String? title,
    String? message,
    String? type,
    String? referenceId,
    bool? isRead,
    DateTime? createdAt,
  }) {
    return NotificationModel(
      id: id ?? this.id,
      title: title ?? this.title,
      message: message ?? this.message,
      type: type ?? this.type,
      referenceId: referenceId ?? this.referenceId,
      isRead: isRead ?? this.isRead,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
