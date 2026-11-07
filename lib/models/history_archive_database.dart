import 'package:flutter/rendering.dart';
import 'package:path/path.dart' as path;
import 'package:sqflite/sqflite.dart';
import 'history_model.dart';

class HistoryArchiveDatabase {
  static Database? _database;

  Future<Database> get _db async {
    if (_database != null) return _database!;

    final directory = await getDatabasesPath();
    _database = await openDatabase(
      path.join(directory, 'home_station_history.db'),
      version: 1,
      onCreate: (db, version) => db.execute('''
        CREATE TABLE history_points (
          field_key TEXT NOT NULL,
          time_ms INTEGER NOT NULL,
          value REAL NOT NULL,
          PRIMARY KEY (field_key, time_ms)
        )
      '''),
    );
    debugPrint("The path to the database: ${path.join(directory, 'home_station_history.db')}");
    return _database!;
  }

  Future<void> upsert(Map<String, List<HistoryPoint>> histories) async {
    final database = await _db;
    await database.transaction((txn) async {
      final batch = txn.batch();
      for (final entry in histories.entries) {
        for (final point in entry.value) {
          batch.insert(
            'history_points',
            {
              'field_key': entry.key,
              'time_ms': point.time.toUtc().millisecondsSinceEpoch,
              'value': point.value,
            },
            conflictAlgorithm: ConflictAlgorithm.replace,
          );
        }
        debugPrint('Upserting history points for field: ${entry.key}');
      }
      await batch.commit(noResult: true);
    });
  }

  Future<List<HistoryPoint>> readRange({
    required String fieldKey,
    required DateTime start,
    required DateTime end,
  }) async {
    final rows = await (await _db).query(
      'history_points',
      where: 'field_key = ? AND time_ms >= ? AND time_ms <= ?',
      whereArgs: [
        fieldKey,
        start.toUtc().millisecondsSinceEpoch,
        end.toUtc().millisecondsSinceEpoch,
      ],
      orderBy: 'time_ms ASC',
    );
    return rows
        .map(
          (row) => HistoryPoint(
            DateTime.fromMillisecondsSinceEpoch(
              row['time_ms'] as int,
              isUtc: true,
            ),
            (row['value'] as num).toDouble(),
          ),
        )
        .toList();
  }
}