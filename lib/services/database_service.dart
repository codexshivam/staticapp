import 'dart:convert';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/confession.dart';

class DatabaseService {
  static final DatabaseService instance = DatabaseService._init();
  static Database? _database;

  DatabaseService._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('confessions.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(
      path,
      version: 2,
      onCreate: _createDB,
      onUpgrade: _upgradeDB,
    );
  }

  Future<void> _createDB(Database db, int version) async {
    await db.execute('''
CREATE TABLE listen_history (
  id TEXT PRIMARY KEY,
  listened_at INTEGER NOT NULL,
  data TEXT
)
''');
  }

  Future<void> _upgradeDB(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      try {
        await db.execute('ALTER TABLE listen_history ADD COLUMN data TEXT;');
      } catch (_) {}
    }
  }

  Future<void> saveHistoryItem(Confession confession) async {
    final db = await instance.database;
    final timestamp = DateTime.now().millisecondsSinceEpoch;

    await db.insert(
      'listen_history',
      {
        'id': confession.id,
        'listened_at': timestamp,
        'data': jsonEncode(confession.toJson()),
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<Confession>> getHistoryConfessions() async {
    final db = await instance.database;
    final result = await db.query(
      'listen_history',
      orderBy: 'listened_at DESC',
    );

    final List<Confession> confessions = [];
    for (final row in result) {
      final listenedAt = row['listened_at'] != null ? DateTime.fromMillisecondsSinceEpoch(row['listened_at'] as int) : null;
      if (row['data'] != null) {
        try {
          final map = jsonDecode(row['data'] as String);
          final conf = Confession.fromJson(map);
          confessions.add(conf.copyWith(listenedAt: listenedAt));
        } catch (_) {}
      } else {
        final id = row['id'] as String;
        final conf = Confession.mockConfessions
            .cast<Confession?>()
            .firstWhere((c) => c?.id == id, orElse: () => null);
        if (conf != null) {
          confessions.add(conf.copyWith(listenedAt: listenedAt));
        }
      }
    }
    return confessions;
  }

  Future<void> deleteHistoryItem(String confessionId) async {
    final db = await instance.database;
    await db.delete(
      'listen_history',
      where: 'id = ?',
      whereArgs: [confessionId],
    );
  }

  Future<void> deleteMultipleHistoryItems(Set<String> ids) async {
    if (ids.isEmpty) return;
    final db = await instance.database;
    final placeholders = List.filled(ids.length, '?').join(',');
    await db.delete(
      'listen_history',
      where: 'id IN ($placeholders)',
      whereArgs: ids.toList(),
    );
  }

  Future<void> clearAllHistory() async {
    final db = await instance.database;
    await db.delete('listen_history');
  }

  Future<void> close() async {
    final db = await instance.database;
    db.close();
  }
}

