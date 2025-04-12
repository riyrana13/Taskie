// task_repository.dart

import 'package:sqflite/sqflite.dart';
import 'package:taskie/models/task.dart';

import '../database/database_helper.dart';

class TaskRepository {
  final DatabaseHelper _databaseHelper = DatabaseHelper();
  static const String createTaskTable = '''
    CREATE TABLE IF NOT EXISTS tasks (
      id INTEGER PRIMARY KEY,
      task TEXT NULL,
      description TEXT NULL,
      date TEXT NULL,
      time TEXT NULL,
      notificationEnabled INTEGER DEFAULT 0,
      photos TEXT NULL
    )
  ''';
  Future<int> insertTask(Task task) async {
    final db = await _databaseHelper.database;
    return await db.insert("tasks", task.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<List<Task>> getTasks() async {
    final db = await _databaseHelper.database;
    final List<Map<String, dynamic>> maps = await db.query("tasks");
    return List.generate(maps.length, (i) => Task.fromMap(maps[i]));
  }

  Future<Task> getTask(int id) async {
    final db = await _databaseHelper.database;
    final List<Map<String, dynamic>> maps =
        await db.query("tasks", where: 'id = ?', whereArgs: [id]);
    return Task.fromMap(maps.first);
  }

  Future<int> updateTask(Task task) async {
    final db = await _databaseHelper.database;
    return await db.update("tasks", task.toMap(),
        where: 'id = ?',
        whereArgs: [task.id],
        conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<int> deleteTask(int id) async {
    final db = await _databaseHelper.database;
    return await db.delete("tasks", where: 'id = ?', whereArgs: [id]);
  }
}
