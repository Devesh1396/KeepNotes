import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._();
  static Database? _database;

  DatabaseHelper._();

  factory DatabaseHelper() {
    return _instance;
  }

  //Initializing Variables
  static final String Table_Name = "notes";
  static final String Column_uid = "uid";
  static final String Column_title = "title";
  static final String Column_desc = "desc";
  static final String Column_timestamp = "timestamp";

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    Directory documentsDirectory = await getApplicationDocumentsDirectory();
    String path = join(documentsDirectory.path, 'notes_database.db');
    return await openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute("CREATE TABLE $Table_Name("
        "$Column_uid INTEGER PRIMARY KEY AUTOINCREMENT,"
        "$Column_title TEXT,"
        "$Column_desc TEXT,"
        "$Column_timestamp INTEGER"
        ")");
  }

  Future<int> insertNote({required String title, required String desc, required int stamp}) async {
    Database db = await database;
    return await db.insert(Table_Name, {
      Column_title: title,
      Column_desc: desc,
      Column_timestamp: stamp
    });
  }

  Future<List<Map<String, dynamic>>> getNotes() async {
    Database db = await database;
    return await db.query(Table_Name);
  }

  Future<Map<String, dynamic>?> getNoteById(String noteId) async {
    Database db = await database;

    List<Map<String, dynamic>> results = await db.query(
      Table_Name,
      where: "$Column_uid = ?",
      whereArgs: [noteId],
    );

    if (results.isNotEmpty) {
      return results.first;
    } else {
      return null;
    }
  }

  Future<int> updateNote({required String noteId, required String title, required String description, required int stamp}) async {
    Database db = await database;
    return await db.update(
      Table_Name,
      {
        Column_title: title,
        Column_desc: description,
        Column_timestamp: stamp
      },
      where: "$Column_uid = ?",
      whereArgs: [noteId],
    );
  }

  Future<int> deleteNoteById(String noteId) async {
    Database db = await database;
    return await db.delete(
      Table_Name,
      where: "$Column_uid = ?",
      whereArgs: [noteId],
    );
  }


}
