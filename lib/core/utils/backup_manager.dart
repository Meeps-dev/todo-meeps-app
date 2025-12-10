import 'dart:convert';
import 'dart:io';
import 'package:my_app/core/database/database_helper.dart';
import 'package:path_provider/path_provider.dart';
import 'package:hive/hive.dart';
import '../../models/todo_model.dart';

class BackupManager {
  // 🔹 Get path for backup file
  static Future<File> _getBackupFile() async {
    final dir = await getApplicationDocumentsDirectory();
    return File('${dir.path}/app_backup.json');
  }

  // 🧠 Backup all user + todo data
  static Future<void> backupAllData() async {
    final box = Hive.box('userBox');
    final userData = box.get('userData');

    // Get all todos from SQLite
    final todos = await DatabaseHelper.instance.getTodos();
    final todoList = todos.map((t) => t.toMap()).toList();

    // Combine data
    final backupData = {'user': userData, 'todos': todoList};

    final file = await _getBackupFile();
    await file.writeAsString(jsonEncode(backupData));
    print('✅ Backup saved to ${file.path}');
  }

  // 🔁 Restore data from backup file
  static Future<void> restoreBackup() async {
    final file = await _getBackupFile();
    if (!await file.exists()) throw Exception('❌ No backup file found');

    final data = jsonDecode(await file.readAsString());
    final userData = data['user'];
    final todoList = data['todos'] as List<dynamic>;

    // Restore user Hive data
    final box = Hive.box('userBox');
    await box.put('userData', userData);

    // Restore todos to SQLite
    final db = DatabaseHelper.instance;
    await db.clearTodos(); // Optional: clear old todos
    for (final todo in todoList) {
      await db.addTodo(TodoModel.fromMap(Map<String, dynamic>.from(todo)));
    }

    print('♻️ Backup restored successfully');
  }
}
