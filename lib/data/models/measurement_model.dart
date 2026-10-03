class MeasurementModel {
  final dynamic id;
  final dynamic childId;
  final String date; // YYYY-MM-DD
  final double weight; // kg
  final double height; // cm
  final String source;
  final String notes;
  final double? bmi;
  final String? nutritionalStatus;

  MeasurementModel({
    this.id,
    required this.childId,
    required this.date,
    required this.weight,
    required this.height,
    this.source = 'Mandiri',
    this.notes = '',
    this.bmi,
    this.nutritionalStatus,
  });

  factory MeasurementModel.fromMap(Map<String, dynamic> map) {
    final rawDate = (map['date'] ?? map['createdAt'] ?? '').toString();
    final formattedDate = rawDate.length >= 10 ? rawDate.substring(0, 10) : rawDate;

    return MeasurementModel(
      id: map['id'],
      childId: map['child_id'] ?? map['childId'] ?? 1,
      date: formattedDate,
      weight: (map['weight'] ?? map['weightKg'] as num?)?.toDouble() ?? 0.0,
      height: (map['height'] ?? map['heightCm'] as num?)?.toDouble() ?? 0.0,
      source: map['source'] as String? ?? 'Mandiri',
      notes: map['notes'] as String? ?? '',
      bmi: (map['bmi'] as num?)?.toDouble(),
      nutritionalStatus: (map['nutritionalStatus'] ?? map['status']) as String?,
    );
  }

  factory MeasurementModel.fromJson(Map<String, dynamic> json) => MeasurementModel.fromMap(json);

  Map<String, dynamic> toMap() {
    return {
      if (id != null && id is int) 'id': id,
      'child_id': (childId is int) ? childId : (int.tryParse(childId.toString()) ?? 1),
      'date': date,
      'weight': weight,
      'height': height,
      'source': source,
      'notes': notes,
    };
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id.toString(),
      'childId': childId.toString(),
      'date': date,
      'weightKg': weight,
      'heightCm': height,
      'source': source,
      'notes': notes,
      if (bmi != null) 'bmi': bmi,
      if (nutritionalStatus != null) 'nutritionalStatus': nutritionalStatus,
    };
  }

  String get formattedWeight =>
      '${weight.toStringAsFixed(1).replaceAll('.', ',')} kg';

  String get formattedHeight =>
      '${height.toStringAsFixed(0)} cm';
}
