// 🧩 Import the tools we need
import 'package:my_app/models/todo_model.dart';
import 'package:sqflite/sqflite.dart'; // lets us use SQLite database on device
import 'package:path/path.dart'; // helps build correct file paths
// import 'models/todo_model.dart'; // our Todo model (title, description, etc.)

// 🏦 This class is our Database Manager — it handles all talk with the local database
class DatabaseHelper {
  // ✅ Make just ONE helper for the whole app (singleton)
  static final DatabaseHelper instance = DatabaseHelper._init();

  // This holds the opened database
  static Database? _database;

  // Private constructor (no one else can make new DatabaseHelpers)
  DatabaseHelper._init();

  // 🧠 When we need the database, this gets it for us
  // If it's already open, we just return it.
  // If not, we open it.
  Future<Database> get database async {
    // If already open, return it
    if (_database != null) return _database!;

    // Otherwise, open a new database file called "todos.db"
    _database = await _initDB('todos.db');

    // Give it back
    return _database!;
  }

  // 📂 This opens (or creates) the database file on your phone
  Future<Database> _initDB(String fileName) async {
    // Get where the phone stores app databases
    final dbPath = await getDatabasesPath();

    // Combine the folder + file name correctly for all devices
    final path = join(dbPath, fileName);

    // Open the database (and create it if it doesn’t exist yet)
    return await openDatabase(
      path, // file location
      version: 1, // version of the database (we’ll use 1 for now)
      onCreate: _createDB, // what to do when making it the first time
    );
  }

  // 🧱 This runs ONCE when the database is first created
  // It makes our table named "todos"
  Future _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE todos(
        id INTEGER PRIMARY KEY AUTOINCREMENT,  -- unique id that counts up automatically
        title TEXT NOT NULL,                   -- todo title (required)
        description TEXT                       -- todo details (optional)
      )
    ''');
  }

  // ➕ Add a new todo into our "todos" table
  Future<int> addTodo(TodoModel todo) async {
    final db = await instance.database; // make sure db is open
    return await db.insert(
      'todos',
      todo.toFirestore(),
    ); // insert todo and return its id
  }

  // 📋 Get all todos from our database
  Future<List<TodoModel>> getTodos() async {
    final db = await instance.database; // open db
    final result = await db.query('todos'); // get all rows
    // Turn every row (Map) into a Todo object
    return result.map((e) => TodoModel.fromMap(e)).toList();
  }

  // ✏️ Update a todo (when editing)
  Future<int> updateTodo(TodoModel todo) async {
    final db = await instance.database;
    return await db.update(
      'todos', // table name
      todo.toFirestore(), // new todo data
      where: 'id = ?', // tell DB which row to update
      whereArgs: [todo.id], // actual id value
    );
  }

  // 🔹 Clear all todos (used during restore)
  Future<void> clearTodos() async {
    final db = await database;
    await db.delete('todos');
  }

  // ❌ Delete a todo by its id
  Future<int> deleteTodo(id) async {
    final db = await instance.database;
    return await db.delete(
      'todos',
      where: 'id = ?', // delete where id matches
      whereArgs: [id],
    );
  }
}
