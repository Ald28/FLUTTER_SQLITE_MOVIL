import 'package:flutter/material.dart';

import 'note.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';


class NoteDatabase {
  static final NoteDatabase instance = NoteDatabase._internal();


  static Database? _database;


  NoteDatabase._internal();


  Future<Database> get database async {
    if (_database != null) {
      return _database!;
    }


    _database = await _initDatabase();
    return _database!;
  }


  Future<Database> _initDatabase() async {
    final databasePath = await getDatabasesPath();
    final path = join(databasePath, 'notes.db');
    return await openDatabase(
      path,
      version: 1,
      onCreate: _createDatabase,
    );
  }


  Future<void> _createDatabase(Database db, _) async {
    return await db.execute('''
        CREATE TABLE ${NoteFields.tableName} (
          ${NoteFields.id} ${NoteFields.idType},
          ${NoteFields.number} ${NoteFields.intType},
          ${NoteFields.title} ${NoteFields.textType},
          ${NoteFields.content} ${NoteFields.textType},
          ${NoteFields.isFavorite} ${NoteFields.intType},
          ${NoteFields.createdTime} ${NoteFields.textType}
        )
      ''');
  }


  Future<NoteModel> create(NoteModel note) async {
    final db = await instance.database;
    final id = await db.insert(NoteFields.tableName, note.toJson());
    return note.copy(id: id);
  }


  Future<NoteModel> read(int id) async {
    final db = await instance.database;
    final maps = await db.query(
      NoteFields.tableName,
      columns: NoteFields.values,
      where: '${NoteFields.id} = ?',
      whereArgs: [id],
    );


    if (maps.isNotEmpty) {
      return NoteModel.fromJson(maps.first);
    } else {
      throw Exception('ID $id not found');
    }
  }


  Future<List<NoteModel>> readAll() async {
    final db = await instance.database;
    const orderBy = '${NoteFields.createdTime} DESC';
    final result = await db.query(NoteFields.tableName, orderBy: orderBy);
    return result.map((json) => NoteModel.fromJson(json)).toList();
  }


  Future<int> update(NoteModel note) async {
    final db = await instance.database;
    return db.update(
      NoteFields.tableName,
      note.toJson(),
      where: '${NoteFields.id} = ?',
      whereArgs: [note.id],
    );
  }


  Future<int> delete(int id) async {
  try {
    final db = await instance.database;
    return await db.delete(
      NoteFields.tableName,
      where: '${NoteFields.id} = ?',
      whereArgs: [id],
    );
  } catch (e) {
    debugPrint('Error deleting note: $e');
    rethrow; // Lanza el error si necesitas manejarlo en otro lugar
  }
}



  Future close() async {
  if (_database != null) {
    await _database!.close();
    _database = null; // Limpia la referencia
  }
}

}

class NoteFields {
  static const List<String> values = [
    id,
    number,
    title,
    content,
    isFavorite,
    createdTime,
  ];
  static const String tableName = 'notes';
  static const String idType = 'INTEGER PRIMARY KEY AUTOINCREMENT';
  static const String textType = 'TEXT NOT NULL';
  static const String intType = 'INTEGER NOT NULL';
  static const String id = '_id';
  static const String title = 'title';
  static const String number = 'number';
  static const String content = 'content';
  static const String isFavorite = 'is_favorite';
  static const String createdTime = 'created_time';
}


class NoteModel {
   int? id;
  final int? number;
  final String title;
  final String content;
  final bool isFavorite;
  final DateTime? createdTime;
  NoteModel({
    this.id,
    this.number,
    required this.title,
    required this.content,
    this.isFavorite = false,
    this.createdTime,
  });
   Map<String, Object?> toJson() => {
        NoteFields.id: id,
        NoteFields.number: number,
        NoteFields.title: title,
        NoteFields.content: content,
        NoteFields.isFavorite: isFavorite ? 1 : 0,
        NoteFields.createdTime: createdTime?.toIso8601String(),
      };


  factory NoteModel.fromJson(Map<String, Object?> json) => NoteModel(
        id: json[NoteFields.id] as int?,
        number: json[NoteFields.number] as int?,
        title: json[NoteFields.title] as String,
        content: json[NoteFields.content] as String,
        isFavorite: json[NoteFields.isFavorite] == 1,
        createdTime:
            DateTime.tryParse(json[NoteFields.createdTime] as String? ?? ''),
      );
      
  NoteModel copy({
    int? id,
    int? number,
    String? title,
    String? content,
    bool? isFavorite,
    DateTime? createdTime,
  }) =>
      NoteModel(
        id: id ?? this.id,
        number: number ?? this.number,
        title: title ?? this.title,
        content: content ?? this.content,
        isFavorite: isFavorite ?? this.isFavorite,
        createdTime: createdTime ?? this.createdTime,
      );
}
