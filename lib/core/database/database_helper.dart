import 'package:flutter/foundation.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import '../../data/models/mother_model.dart';
import '../../data/models/child_model.dart';
import '../../data/models/measurement_model.dart';
import '../../data/models/reminder_model.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  // In-memory fallback for platforms where sqflite native binary is not registered
  bool _useInMemoryFallback = false;
  MotherModel? _fallbackMother;
  final List<ChildModel> _fallbackChildren = [];
  final List<MeasurementModel> _fallbackMeasurements = [];
  final List<ReminderModel> _fallbackReminders = [];

  DatabaseHelper._init();

  Future<Database?> get database async {
    if (_useInMemoryFallback) return null;
    if (_database != null) return _database!;
    try {
      _database = await _initDB('si_cehat_local.db');
      return _database!;
    } catch (e) {
      debugPrint('Sqflite initialization failed, switching to memory fallback: $e');
      _useInMemoryFallback = true;
      _initFallbackData();
      return null;
    }
  }

  void _initFallbackData() {
    _fallbackMother = MotherModel(
      id: 1,
      name: 'Ibu Rina',
      education: 'S1 / Sarjana',
      occupation: 'Ibu Rumah Tangga',
      address: 'Bandung, Jawa Barat',
    );
    _fallbackChildren.clear();
    _fallbackChildren.add(ChildModel(
      id: 1,
      name: 'Ahmad',
      dateOfBirth: '2018-05-14',
      gender: 'Laki-laki',
      healthNotes: 'Belum ada catatan khusus',
      isActive: true,
    ));
    _fallbackMeasurements.clear();
    _fallbackMeasurements.addAll([
      MeasurementModel(id: 1, childId: 1, date: '2026-01-15', weight: 19.0, height: 115.0),
      MeasurementModel(id: 2, childId: 1, date: '2026-02-15', weight: 19.5, height: 116.0),
      MeasurementModel(id: 3, childId: 1, date: '2026-03-15', weight: 19.8, height: 116.5),
      MeasurementModel(id: 4, childId: 1, date: '2026-04-15', weight: 20.1, height: 117.2),
      MeasurementModel(id: 5, childId: 1, date: '2026-05-15', weight: 20.5, height: 118.0),
    ]);
    _fallbackReminders.clear();
    _fallbackReminders.addAll([
      ReminderModel(id: 1, title: 'Sarapan Pagi', time: '07:00', isEnabled: true),
      ReminderModel(id: 2, title: 'Minum air putih', time: '10:00', isEnabled: true),
      ReminderModel(id: 3, title: 'Aktivitas Fisik', time: '16:00', isEnabled: true),
      ReminderModel(id: 4, title: 'Waktu tidur', time: '20:00', isEnabled: true),
    ]);
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(
      path,
      version: 1,
      onCreate: _createDB,
    );
  }

  Future<void> _createDB(Database db, int version) async {
    // 1. Mother Profile
    await db.execute('''
      CREATE TABLE mother_profile (
        id INTEGER PRIMARY KEY,
        name TEXT NOT NULL,
        education TEXT,
        occupation TEXT,
        address TEXT
      )
    ''');

    // 2. Child Profile
    await db.execute('''
      CREATE TABLE child_profile (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        date_of_birth TEXT NOT NULL,
        gender TEXT NOT NULL,
        health_notes TEXT,
        is_active INTEGER NOT NULL DEFAULT 0
      )
    ''');

    // 3. Growth Measurements
    await db.execute('''
      CREATE TABLE growth_measurements (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        child_id INTEGER NOT NULL,
        date TEXT NOT NULL,
        weight REAL NOT NULL,
        height REAL NOT NULL,
        source TEXT,
        notes TEXT,
        FOREIGN KEY (child_id) REFERENCES child_profile (id) ON DELETE CASCADE
      )
    ''');

    // 4. Reminders
    await db.execute('''
      CREATE TABLE reminders (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        title TEXT NOT NULL,
        time TEXT NOT NULL,
        is_enabled INTEGER NOT NULL DEFAULT 1,
        repeat_days TEXT
      )
    ''');

    // Insert Initial Seeds
    await _seedDatabase(db);
  }

  Future<void> _seedDatabase(Database db) async {
    // Default Mother
    await db.insert('mother_profile', {
      'id': 1,
      'name': 'Ibu Rina',
      'education': 'S1 / Sarjana',
      'occupation': 'Ibu Rumah Tangga',
      'address': 'Bandung, Jawa Barat',
    });

    // Default Child
    final childId = await db.insert('child_profile', {
      'name': 'Ahmad',
      'date_of_birth': '2018-05-14',
      'gender': 'Laki-laki',
      'health_notes': 'Belum ada catatan khusus',
      'is_active': 1,
    });

    // Default Measurements corresponding to S11 (Jan-Mei with final 20,5 kg and 118 cm)
    final measurements = [
      {'child_id': childId, 'date': '2026-01-15', 'weight': 19.0, 'height': 115.0, 'source': 'Posyandu'},
      {'child_id': childId, 'date': '2026-02-15', 'weight': 19.5, 'height': 116.0, 'source': 'Mandiri'},
      {'child_id': childId, 'date': '2026-03-15', 'weight': 19.8, 'height': 116.5, 'source': 'Mandiri'},
      {'child_id': childId, 'date': '2026-04-15', 'weight': 20.1, 'height': 117.2, 'source': 'Puskesmas'},
      {'child_id': childId, 'date': '2026-05-15', 'weight': 20.5, 'height': 118.0, 'source': 'Mandiri'},
    ];
    for (final m in measurements) {
      await db.insert('growth_measurements', m);
    }

    // Default Reminders matching S14
    final reminders = [
      {'title': 'Sarapan Pagi', 'time': '07:00', 'is_enabled': 1, 'repeat_days': 'Setiap Hari'},
      {'title': 'Minum air putih', 'time': '10:00', 'is_enabled': 1, 'repeat_days': 'Setiap Hari'},
      {'title': 'Aktivitas Fisik', 'time': '16:00', 'is_enabled': 1, 'repeat_days': 'Setiap Hari'},
      {'title': 'Waktu tidur', 'time': '20:00', 'is_enabled': 1, 'repeat_days': 'Setiap Hari'},
    ];
    for (final r in reminders) {
      await db.insert('reminders', r);
    }
  }

  // --- MOTHER PROFILE OPERATIONS ---
  Future<MotherModel> getMotherProfile() async {
    final db = await database;
    if (db == null) return _fallbackMother!;
    final result = await db.query('mother_profile', where: 'id = 1');
    if (result.isNotEmpty) {
      return MotherModel.fromMap(result.first);
    }
    return MotherModel(
      id: 1,
      name: 'Ibu Rina',
      education: 'S1 / Sarjana',
      occupation: 'Ibu Rumah Tangga',
      address: 'Bandung, Jawa Barat',
    );
  }

  Future<void> updateMotherProfile(MotherModel mother) async {
    final db = await database;
    if (db == null) {
      _fallbackMother = mother;
      return;
    }
    await db.update(
      'mother_profile',
      mother.toMap(),
      where: 'id = ?',
      whereArgs: [mother.id],
    );
  }

  // --- CHILD PROFILE OPERATIONS ---
  Future<List<ChildModel>> getChildren() async {
    final db = await database;
    if (db == null) return List.from(_fallbackChildren);
    final result = await db.query('child_profile', orderBy: 'id ASC');
    return result.map((m) => ChildModel.fromMap(m)).toList();
  }

  Future<ChildModel?> getActiveChild() async {
    final db = await database;
    if (db == null) {
      return _fallbackChildren.firstWhere((c) => c.isActive,
          orElse: () => _fallbackChildren.first);
    }
    final result = await db.query('child_profile', where: 'is_active = 1');
    if (result.isNotEmpty) {
      return ChildModel.fromMap(result.first);
    }
    final all = await getChildren();
    return all.isNotEmpty ? all.first : null;
  }

  Future<int> insertChild(ChildModel child) async {
    final db = await database;
    if (db == null) {
      final newId = (_fallbackChildren.isEmpty ? 1 : _fallbackChildren.last.id + 1);
      final newChild = child.copyWith(id: newId);
      _fallbackChildren.add(newChild);
      return newId;
    }
    return await db.insert('child_profile', child.toMap());
  }

  Future<void> updateChild(ChildModel child) async {
    final db = await database;
    if (db == null) {
      final index = _fallbackChildren.indexWhere((c) => c.id == child.id);
      if (index != -1) _fallbackChildren[index] = child;
      return;
    }
    await db.update('child_profile', child.toMap(), where: 'id = ?', whereArgs: [child.id]);
  }

  Future<void> setActiveChild(int childId) async {
    final db = await database;
    if (db == null) {
      for (int i = 0; i < _fallbackChildren.length; i++) {
        _fallbackChildren[i] = _fallbackChildren[i].copyWith(isActive: _fallbackChildren[i].id == childId);
      }
      return;
    }
    await db.update('child_profile', {'is_active': 0});
    await db.update('child_profile', {'is_active': 1}, where: 'id = ?', whereArgs: [childId]);
  }

  // --- MEASUREMENTS OPERATIONS ---
  Future<List<MeasurementModel>> getMeasurements(int childId) async {
    final db = await database;
    if (db == null) {
      return _fallbackMeasurements.where((m) => m.childId == childId).toList()
        ..sort((a, b) => a.date.compareTo(b.date));
    }
    final result = await db.query(
      'growth_measurements',
      where: 'child_id = ?',
      whereArgs: [childId],
      orderBy: 'date ASC',
    );
    return result.map((m) => MeasurementModel.fromMap(m)).toList();
  }

  Future<int> insertMeasurement(MeasurementModel measurement) async {
    final db = await database;
    if (db == null) {
      final newId = (_fallbackMeasurements.isEmpty ? 1 : (_fallbackMeasurements.last.id ?? 0) + 1);
      final item = MeasurementModel(
        id: newId,
        childId: measurement.childId,
        date: measurement.date,
        weight: measurement.weight,
        height: measurement.height,
        source: measurement.source,
        notes: measurement.notes,
      );
      _fallbackMeasurements.add(item);
      return newId;
    }
    return await db.insert('growth_measurements', measurement.toMap());
  }

  // --- REMINDERS OPERATIONS ---
  Future<List<ReminderModel>> getReminders() async {
    final db = await database;
    if (db == null) return List.from(_fallbackReminders);
    final result = await db.query('reminders', orderBy: 'time ASC');
    return result.map((m) => ReminderModel.fromMap(m)).toList();
  }

  Future<int> insertReminder(ReminderModel reminder) async {
    final db = await database;
    if (db == null) {
      final newId = (_fallbackReminders.isEmpty ? 1 : (_fallbackReminders.last.id ?? 0) + 1);
      final item = reminder.copyWith(id: newId);
      _fallbackReminders.add(item);
      return newId;
    }
    return await db.insert('reminders', reminder.toMap());
  }

  Future<void> updateReminder(ReminderModel reminder) async {
    final db = await database;
    if (db == null) {
      final index = _fallbackReminders.indexWhere((r) => r.id == reminder.id);
      if (index != -1) _fallbackReminders[index] = reminder;
      return;
    }
    await db.update('reminders', reminder.toMap(), where: 'id = ?', whereArgs: [reminder.id]);
  }

  Future<void> deleteReminder(int id) async {
    final db = await database;
    if (db == null) {
      _fallbackReminders.removeWhere((r) => r.id == id);
      return;
    }
    await db.delete('reminders', where: 'id = ?', whereArgs: [id]);
  }

  // --- RESET DEMO DATA ---
  Future<void> resetDemoData() async {
    final db = await database;
    if (db == null) {
      _initFallbackData();
      return;
    }
    await db.delete('reminders');
    await db.delete('growth_measurements');
    await db.delete('child_profile');
    await db.delete('mother_profile');
    await _seedDatabase(db);
  }
}
