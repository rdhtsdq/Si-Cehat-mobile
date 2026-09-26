class MeasurementModel {
  final int? id;
  final int childId;
  final String date; // YYYY-MM-DD
  final double weight; // kg
  final double height; // cm
  final String source;
  final String notes;

  MeasurementModel({
    this.id,
    required this.childId,
    required this.date,
    required this.weight,
    required this.height,
    this.source = 'Mandiri',
    this.notes = '',
  });

  factory MeasurementModel.fromMap(Map<String, dynamic> map) {
    return MeasurementModel(
      id: map['id'] as int?,
      childId: map['child_id'] as int,
      date: map['date'] as String,
      weight: (map['weight'] as num).toDouble(),
      height: (map['height'] as num).toDouble(),
      source: map['source'] as String? ?? 'Mandiri',
      notes: map['notes'] as String? ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'child_id': childId,
      'date': date,
      'weight': weight,
      'height': height,
      'source': source,
      'notes': notes,
    };
  }

  String get formattedWeight =>
      '${weight.toStringAsFixed(1).replaceAll('.', ',')} kg';

  String get formattedHeight =>
      '${height.toStringAsFixed(0)} cm';
}
