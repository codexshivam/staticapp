import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

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
      version: 1,
      onCreate: _createDB,
    );
  }

  Future<void> _createDB(Database db, int version) async {
    await db.execute('''
CREATE TABLE listen_history (
  id TEXT PRIMARY KEY,
  listened_at INTEGER NOT NULL
)
''');
  }

  Future<void> saveHistoryItem(String confessionId) async {
    final db = await instance.database;
    final timestamp = DateTime.now().millisecondsSinceEpoch;

    await db.insert(
      'listen_history',
      {
        'id': confessionId,
        'listened_at': timestamp,
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<String>> getHistoryIds() async {
    final db = await instance.database;
    final result = await db.query(
      'listen_history',
      orderBy: 'listened_at DESC',
    );

    return result.map((row) => row['id'] as String).toList();
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
