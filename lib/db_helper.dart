import 'dart:async';
import 'package:sqflite/sqflite.dart';

class DatabaseHelper {
  DatabaseHelper._();
  static final DatabaseHelper instance = DatabaseHelper._();
  Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await initDatabase();
    return _database!;
  }

  Future<Database> initDatabase() async {
    // Define the database path and schema here
    String path = 'your_database.db';
    return await openDatabase(path, version: 1, onCreate: _createDb);
  }

  void _createDb(Database db, int version) async {
    await db.execute('''
      CREATE TABLE your_table (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        field1 TEXT,
        field2 TEXT
      )
    ''');
  }

  Future<int> insertData(Map<String, dynamic> data) async {
    final db = await database;
    return await db.insert('your_table', data);
  }

  Future<List<Map<String, dynamic>>> getData() async {
    final db = await database;
    return await db.query('your_table');
  }
}
