import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:my_app/services/firestore_service.dart';
import '../models/todo_model.dart';

class TodoViewModel extends StateNotifier<List<TodoModel>> {
  final FirestoreService _service = FirestoreService();
  final String userId;

  TodoViewModel(this.userId) : super([]) {
    loadTodos();
  }

  Future<void> loadTodos() async {
    final todos = await _service.getTodos(userId);
    state = todos;
  }

  Future<void> addTodo(TodoModel todo) async {
    await _service.addTodo(userId, todo);
    await loadTodos();
  }

  Future<void> updateTodo(TodoModel todo) async {
    await _service.updateTodo(userId, todo);
    await loadTodos();
  }

  Future<void> deleteTodo(String id) async {
    await _service.deleteTodo(userId, id);
    await loadTodos();
  }

  Future<void> clearAll() async {
    await _service.clearTodos(userId);
    state = [];
  }
}
