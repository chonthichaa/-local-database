import 'package:flutter_localdb/models/note.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class NoteDBHandles {
  final databaseName = "notes.db";
  final tableName = "notes";

  final fieldMap = {
    "id": "INTEGER PRIMARY KEY AUTOINCREMENT",
    "title": "BLOB",
    "content": "BLOB",
    "date_created": "INTEGER",
    "date_last_edited": "INTEGER"
  };

  Database? _database;
  Future<Database> get database async {
    if (_database != null) return _database!;

    //connent database
    _database = await _initDB();
    return _database!;
  }

  Future<Database> _initDB() async {
    var path = await getDatabasesPath();
    var dbPath = join(path, databaseName);
    Database dbConnection = await openDatabase(dbPath, version: 1,
        onCreate: (Database db, int version) async {
      await db.execute(_buildCreateQuery());
    });

    await dbConnection.execute(_buildCreateQuery());
    _buildCreateQuery();
    return dbConnection;
  }

  String _buildCreateQuery() {
    String query = "CREATE TABLE IF NOT EXISTS ";
    query += tableName;
    query += "(";
    fieldMap.forEach((column, field) {
      query += "$column $field,";
    });
    query = query.substring(0, query.length - 1);
    query += " )";

    return query;
  }

  void insertNote(Note note, bool forUpdate) async {
    Database db = await database;
    db.insert(tableName, note.toMap(forUpdate));
  }

  Future<List<Map<String, Object?>>> selectAllNote() async {
    Database db = await database;
    var datas = await db.query(tableName, orderBy: "date_last_edited desc");
    return datas;
  }
}
