import 'package:flutter/foundation.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import '../../data/models/mother_model.dart';
import '../../data/models/child_model.dart';
import '../../data/models/measurement_model.dart';
import '../../data/models/reminder_model.dart';
import '../../data/models/notification_model.dart';
import '../../data/models/activity_log_model.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  // In-memory fallback for platforms where sqflite native binary is not registered
  bool _useInMemoryFallback = false;
  MotherModel? _fallbackMother;
  final List<ChildModel> _fallbackChildren = [];
  final List<MeasurementModel> _fallbackMeasurements = [];
  final List<ReminderModel> _fallbackReminders = [];
  final List<NotificationModel> _fallbackNotifications = [];
  final List<ActivityLogModel> _fallbackActivities = [];
  final Map<String, int> _fallbackWater = {};

  DatabaseHelper._init();

  Future<Database?> get database async {
    if (kIsWeb) {
      if (!_useInMemoryFallback) {
        _useInMemoryFallback = true;
        _initFallbackData();
      }
      return null;
    }
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
      avatarUrl: null,
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
      ReminderModel(id: 1, title: 'Sarapan Pagi', time: '07:00', isEnabled: true, category: 'makan', repeatDays: 'Setiap Hari'),
      ReminderModel(id: 2, title: 'Minum air putih', time: '10:00', isEnabled: true, category: 'minum', repeatDays: 'Setiap Hari'),
      ReminderModel(id: 3, title: 'Aktivitas Fisik', time: '16:00', isEnabled: true, category: 'aktivitas', repeatDays: 'Setiap Hari'),
      ReminderModel(id: 4, title: 'Waktu tidur', time: '20:00', isEnabled: true, category: 'tidur', repeatDays: 'Setiap Hari'),
    ]);
    _fallbackNotifications.clear();
    _fallbackNotifications.addAll([
      NotificationModel(
        id: 'notif-1',
        title: 'Selamat Datang di Si Cehat!',
        message: 'Mulai pantau kesehatan anak Anda dan jelajahi rekomendasi gizi sehat tradisional.',
        type: 'SYSTEM',
        isRead: false,
        createdAt: DateTime.now().subtract(const Duration(hours: 1)),
      ),
      NotificationModel(
        id: 'notif-2',
        title: 'Layanan Konsultasi Tenaga Medis Mitra',
        message: 'Konsultasi dengan Bidan, Ahli Gizi, dan Dokter spesialis anak telah tersedia.',
        type: 'CONSULTATION',
        isRead: false,
        createdAt: DateTime.now().subtract(const Duration(minutes: 30)),
      ),
    ]);
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(
      path,
      version: 4,
      onCreate: _createDB,
      onUpgrade: _onUpgradeDB,
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
        address TEXT,
        avatar_url TEXT
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
        is_active INTEGER NOT NULL DEFAULT 0,
        avatar_url TEXT
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
        repeat_days TEXT,
        category TEXT DEFAULT 'umum',
        is_completed INTEGER NOT NULL DEFAULT 0,
        last_completed_at TEXT
      )
    ''');

    // 5. Notifications
    await db.execute('''
      CREATE TABLE notifications (
        id TEXT PRIMARY KEY,
        title TEXT NOT NULL,
        message TEXT NOT NULL,
        type TEXT NOT NULL,
        reference_id TEXT,
        is_read INTEGER NOT NULL DEFAULT 0,
        created_at TEXT NOT NULL
      )
    ''');

    // 6. Activity Logs
    await db.execute('''
      CREATE TABLE activity_logs (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        remote_id TEXT,
        child_id INTEGER NOT NULL,
        date TEXT NOT NULL,
        title TEXT NOT NULL,
        category TEXT NOT NULL,
        duration_minutes INTEGER NOT NULL DEFAULT 0,
        intensity TEXT,
        notes TEXT,
        created_at TEXT NOT NULL
      )
    ''');

    // 7. Daily Water Logs
    await db.execute('''
      CREATE TABLE daily_water_logs (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        child_id INTEGER NOT NULL,
        date TEXT NOT NULL,
        glasses INTEGER NOT NULL DEFAULT 0,
        UNIQUE(child_id, date)
      )
    ''');

    // Insert Initial Seeds
    await _seedDatabase(db);
  }

  Future<void> _onUpgradeDB(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      try {
        await db.execute('ALTER TABLE mother_profile ADD COLUMN avatar_url TEXT');
      } catch (_) {}
      try {
        await db.execute("ALTER TABLE reminders ADD COLUMN category TEXT DEFAULT 'umum'");
      } catch (_) {}
      try {
        await db.execute("ALTER TABLE reminders ADD COLUMN is_completed INTEGER NOT NULL DEFAULT 0");
      } catch (_) {}
      try {
        await db.execute("ALTER TABLE reminders ADD COLUMN last_completed_at TEXT");
      } catch (_) {}
      try {
        await db.execute('''
          CREATE TABLE IF NOT EXISTS notifications (
            id TEXT PRIMARY KEY,
            title TEXT NOT NULL,
            message TEXT NOT NULL,
            type TEXT NOT NULL,
            reference_id TEXT,
            is_read INTEGER NOT NULL DEFAULT 0,
            created_at TEXT NOT NULL
          )
        ''');
      } catch (_) {}
    }
    if (oldVersion < 3) {
      try {
        await db.execute('ALTER TABLE child_profile ADD COLUMN avatar_url TEXT');
      } catch (_) {}
    }
    if (oldVersion < 4) {
      try {
        await db.execute('''
          CREATE TABLE IF NOT EXISTS activity_logs (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            remote_id TEXT,
            child_id INTEGER NOT NULL,
            date TEXT NOT NULL,
            title TEXT NOT NULL,
            category TEXT NOT NULL,
            duration_minutes INTEGER NOT NULL DEFAULT 0,
            intensity TEXT,
            notes TEXT,
            created_at TEXT NOT NULL
          )
        ''');
      } catch (_) {}
      try {
        await db.execute('''
          CREATE TABLE IF NOT EXISTS daily_water_logs (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            child_id INTEGER NOT NULL,
            date TEXT NOT NULL,
            glasses INTEGER NOT NULL DEFAULT 0,
            UNIQUE(child_id, date)
          )
        ''');
      } catch (_) {}
    }
  }

  Future<void> _seedDatabase(Database db) async {
    // Default Mother
    await db.insert('mother_profile', {
      'id': 1,
      'name': 'Ibu Rina',
      'education': 'S1 / Sarjana',
      'occupation': 'Ibu Rumah Tangga',
      'address': 'Bandung, Jawa Barat',
      'avatar_url': null,
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

    // Default Reminders corresponding to S14
    final reminders = [
      {'title': 'Sarapan Pagi', 'time': '07:00', 'is_enabled': 1, 'repeat_days': 'Setiap Hari', 'category': 'makan', 'is_completed': 0},
      {'title': 'Minum air putih', 'time': '10:00', 'is_enabled': 1, 'repeat_days': 'Setiap Hari', 'category': 'minum', 'is_completed': 0},
      {'title': 'Aktivitas Fisik', 'time': '16:00', 'is_enabled': 1, 'repeat_days': 'Setiap Hari', 'category': 'aktivitas', 'is_completed': 0},
      {'title': 'Waktu tidur', 'time': '20:00', 'is_enabled': 1, 'repeat_days': 'Setiap Hari', 'category': 'tidur', 'is_completed': 0},
    ];
    for (final r in reminders) {
      await db.insert('reminders', r);
    }

    // Default Notifications
    final notifs = [
      {
        'id': 'notif-1',
        'title': 'Selamat Datang di Si Cehat!',
        'message': 'Mulai pantau kesehatan anak Anda dan jelajahi rekomendasi gizi sehat tradisional.',
        'type': 'SYSTEM',
        'reference_id': null,
        'is_read': 0,
        'created_at': DateTime.now().toIso8601String(),
      },
      {
        'id': 'notif-2',
        'title': 'Layanan Konsultasi Tenaga Medis Mitra',
        'message': 'Konsultasi dengan Bidan, Ahli Gizi, dan Dokter spesialis anak telah tersedia.',
        'type': 'CONSULTATION',
        'reference_id': null,
        'is_read': 0,
        'created_at': DateTime.now().toIso8601String(),
      },
    ];
    for (final n in notifs) {
      await db.insert('notifications', n);
    }
  }

  // --- MOTHER PROFILE OPERATIONS ---
  Future<MotherModel?> getMotherProfile() async {
    final db = await database;
    if (db == null) return _fallbackMother;
    final result = await db.query('mother_profile', limit: 1);
    if (result.isNotEmpty) {
      return MotherModel.fromMap(result.first);
    }
    return null;
  }

  Future<void> updateMotherProfile(MotherModel mother) async {
    final db = await database;
    if (db == null) {
      _fallbackMother = mother;
      return;
    }
    await db.update('mother_profile', mother.toMap(), where: 'id = ?', whereArgs: [mother.id]);
  }

  // --- CHILD PROFILE OPERATIONS ---
  Future<List<ChildModel>> getChildren() async {
    final db = await database;
    if (db == null) return List.from(_fallbackChildren);
    final result = await db.query('child_profile');
    return result.map((c) => ChildModel.fromMap(c)).toList();
  }

  Future<ChildModel?> getActiveChild() async {
    final db = await database;
    if (db == null) {
      final active = _fallbackChildren.where((c) => c.isActive);
      return active.isNotEmpty ? active.first : (_fallbackChildren.isNotEmpty ? _fallbackChildren.first : null);
    }
    final result = await db.query('child_profile', where: 'is_active = 1', limit: 1);
    if (result.isNotEmpty) {
      return ChildModel.fromMap(result.first);
    }
    return null;
  }

  Future<int> insertChild(ChildModel child) async {
    final db = await database;
    if (db == null) {
      final newId = (_fallbackChildren.isEmpty ? 1 : (_fallbackChildren.last.id ?? 0) + 1);
      final item = child.copyWith(id: newId);
      _fallbackChildren.add(item);
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

  Future<void> setActiveChild(dynamic childId) async {
    final db = await database;
    if (db == null) {
      for (int i = 0; i < _fallbackChildren.length; i++) {
        _fallbackChildren[i] = _fallbackChildren[i].copyWith(isActive: _fallbackChildren[i].id.toString() == childId.toString());
      }
      return;
    }
    await db.update('child_profile', {'is_active': 0});
    await db.update('child_profile', {'is_active': 1}, where: 'id = ?', whereArgs: [childId]);
  }

  // --- MEASUREMENTS OPERATIONS ---
  Future<List<MeasurementModel>> getMeasurements(dynamic childId) async {
    final db = await database;
    if (db == null) {
      return _fallbackMeasurements.where((m) => m.childId.toString() == childId.toString()).toList()
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

  Future<void> deleteMeasurement(dynamic id) async {
    final db = await database;
    if (db == null) {
      _fallbackMeasurements.removeWhere((m) => m.id.toString() == id.toString());
      return;
    }
    await db.delete('growth_measurements', where: 'id = ?', whereArgs: [id]);
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

  Future<void> deleteReminder(dynamic id) async {
    final db = await database;
    if (db == null) {
      _fallbackReminders.removeWhere((r) => r.id.toString() == id.toString());
      return;
    }
    await db.delete('reminders', where: 'id = ?', whereArgs: [id]);
  }

  // --- NOTIFICATIONS OPERATIONS ---
  Future<List<NotificationModel>> getNotifications() async {
    final db = await database;
    if (db == null) return List.from(_fallbackNotifications);
    final result = await db.query('notifications', orderBy: 'created_at DESC');
    return result.map((n) => NotificationModel.fromJson(n)).toList();
  }

  Future<void> insertNotification(NotificationModel notif) async {
    final db = await database;
    if (db == null) {
      _fallbackNotifications.removeWhere((n) => n.id == notif.id);
      _fallbackNotifications.insert(0, notif);
      return;
    }
    await db.insert('notifications', notif.toMap(), conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<void> markNotificationRead(String id) async {
    final db = await database;
    if (db == null) {
      final index = _fallbackNotifications.indexWhere((n) => n.id == id);
      if (index != -1) {
        _fallbackNotifications[index] = _fallbackNotifications[index].copyWith(isRead: true);
      }
      return;
    }
    await db.update('notifications', {'is_read': 1}, where: 'id = ?', whereArgs: [id]);
  }

  Future<void> markAllNotificationsRead() async {
    final db = await database;
    if (db == null) {
      for (int i = 0; i < _fallbackNotifications.length; i++) {
        _fallbackNotifications[i] = _fallbackNotifications[i].copyWith(isRead: true);
      }
      return;
    }
    await db.update('notifications', {'is_read': 1});
  }

  Future<void> deleteNotification(String id) async {
    final db = await database;
    if (db == null) {
      _fallbackNotifications.removeWhere((n) => n.id == id);
      return;
    }
    await db.delete('notifications', where: 'id = ?', whereArgs: [id]);
  }

  // --- ACTIVITY LOGS OPERATIONS ---
  Future<List<ActivityLogModel>> getActivities(dynamic childId, String date) async {
    final db = await database;
    if (db == null) {
      return _fallbackActivities
          .where((a) => a.childId.toString() == childId.toString() && a.date == date)
          .toList();
    }
    final result = await db.query(
      'activity_logs',
      where: 'child_id = ? AND date = ?',
      whereArgs: [childId, date],
      orderBy: 'id DESC',
    );
    return result.map((m) => ActivityLogModel.fromMap(m)).toList();
  }

  Future<int> insertActivity(ActivityLogModel activity) async {
    final db = await database;
    if (db == null) {
      final newId = _fallbackActivities.length + 1;
      _fallbackActivities.insert(0, activity.copyWith(id: newId));
      return newId;
    }
    return await db.insert('activity_logs', activity.toMap());
  }

  Future<void> deleteActivity(dynamic id) async {
    final db = await database;
    if (db == null) {
      _fallbackActivities.removeWhere((a) => a.id.toString() == id.toString());
      return;
    }
    await db.delete('activity_logs', where: 'id = ?', whereArgs: [id]);
  }

  // --- DAILY WATER LOGS OPERATIONS ---
  Future<int> getWaterGlasses(dynamic childId, String date) async {
    final key = '${childId}_$date';
    final db = await database;
    if (db == null) {
      return _fallbackWater[key] ?? 0;
    }
    final result = await db.query(
      'daily_water_logs',
      columns: ['glasses'],
      where: 'child_id = ? AND date = ?',
      whereArgs: [childId, date],
      limit: 1,
    );
    if (result.isNotEmpty) {
      return (result.first['glasses'] as num?)?.toInt() ?? 0;
    }
    return 0;
  }

  Future<void> setWaterGlasses(dynamic childId, String date, int glasses) async {
    final key = '${childId}_$date';
    final db = await database;
    if (db == null) {
      _fallbackWater[key] = glasses;
      return;
    }
    await db.insert(
      'daily_water_logs',
      {'child_id': childId, 'date': date, 'glasses': glasses},
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  // --- RESET DEMO DATA ---
  Future<void> resetDemoData() async {
    final db = await database;
    if (db == null) {
      _initFallbackData();
      return;
    }
    await db.delete('notifications');
    await db.delete('reminders');
    await db.delete('growth_measurements');
    await db.delete('child_profile');
    await db.delete('mother_profile');
    await _seedDatabase(db);
  }
}
