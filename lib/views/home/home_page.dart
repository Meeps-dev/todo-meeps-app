import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_app/core/database/database_helper.dart';
import 'package:my_app/providers/todo_provider.dart';
import 'package:my_app/providers/user_provider.dart';
import 'package:my_app/services/firestore_service.dart';
import '../../core/network/api_services.dart';
import '../bottom_nav_shell.dart';
import '../../models/todo_model.dart';

class HomePage extends ConsumerStatefulWidget {
  const HomePage({super.key});

  @override
  ConsumerState<HomePage> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage> {
  List<dynamic>? users;
  bool isLoading = true;
  String? error;

  @override
  void initState() {
    super.initState();
    _loadUsers();
    _loadTodosOnStart();
  }

  Future<void> _loadUsers() async {
    try {
      setState(() => isLoading = true);
      final fetchedUsers = await ApiServices.fetchUsers();
      setState(() {
        users = fetchedUsers;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        error = e.toString();
        isLoading = false;
      });
    }
  }

  // ✅ Load todos immediately when homepage opens
  Future<void> _loadTodosOnStart() async {
    await ref.read(todoProvider.notifier).loadTodos();
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(userProvider);
    final todos = ref.watch(todoProvider);

    if (user.id == null) {
      return const Center(child: CircularProgressIndicator());
    }

    return Scaffold(
      appBar: AppBar(title: const Text('🏠 Home')),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const SizedBox(height: 20),
          CircleAvatar(
            radius: 45,
            backgroundImage: user.profileImage != null
                ? NetworkImage(user.profileImage!)
                : null,
            child: user.profileImage == null
                ? const Icon(Icons.person, size: 45, color: Colors.blue)
                : null,
          ),

          const SizedBox(height: 15),

          // Welcome text
          Text(
            'Welcome, ${user.name ?? "User"}!',
            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 15),

          // Go to Profile button
          ElevatedButton(
            child: const Text('👤 Profile'),
            onPressed: () {
              ref.read(bottomNavIndexProvider.notifier).state = 1;
            },
          ),

          const Divider(height: 40, thickness: 2),

          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.0),
            child: Text(
              '📝 My To-Do List',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),

          // ✅ Scrollable To-Do list
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: todos.isEmpty
                  ? const Center(
                      child: Text(
                        'No tasks yet. Tap + to add one!',
                        style: TextStyle(fontSize: 16),
                      ),
                    )
                  : ListView.separated(
                      itemCount: todos.length,
                      separatorBuilder: (_, __) =>
                          const SizedBox(height: 8), // spacing between cards
                      itemBuilder: (context, index) {
                        final todo = todos[index];
                        return Card(
                          elevation: 3,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: ListTile(
                            title: Text(todo.title),
                            subtitle: todo.description.isNotEmpty
                                ? Text(todo.description)
                                : null,
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  icon: const Icon(
                                    Icons.edit,
                                    color: Colors.blue,
                                  ),
                                  onPressed: () =>
                                      _showTodoDialog(context, ref, todo: todo),
                                ),
                                IconButton(
                                  icon: const Icon(
                                    Icons.delete,
                                    color: Colors.red,
                                  ),
                                  onPressed: () async {
                                    final user = ref.read(userProvider);
                                    if (user.id != null && todo.id != null) {
                                      final firestore = FirestoreService();
                                      await firestore.deleteTodo(
                                        user.id!,
                                        todo.id!,
                                      );
                                      await ref
                                          .read(todoProvider.notifier)
                                          .loadTodos();
                                    }
                                  },
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.add),
        onPressed: () => _showTodoDialog(context, ref),
      ),
    );
  }

  void _showTodoDialog(BuildContext context, WidgetRef ref, {TodoModel? todo}) {
    final titleController = TextEditingController(text: todo?.title ?? '');
    final descController = TextEditingController(text: todo?.description ?? '');
    final isEditing = todo != null;
    final user = ref.read(userProvider);
    if (user.id == null) return; // safety check

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(isEditing ? 'Edit Todo' : 'Add Todo'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: titleController,
              decoration: const InputDecoration(hintText: 'Enter title...'),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: descController,
              decoration: const InputDecoration(
                hintText: 'Enter description...',
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              final title = titleController.text.trim();
              final description = descController.text.trim();

              if (title.isEmpty) return;

              if (isEditing) {
                final updatedTodo = TodoModel(
                  id: todo.id,
                  title: title,
                  description: description,
                );
                await DatabaseHelper.instance.updateTodo(updatedTodo);
              } else {
                final newTodo = TodoModel(
                  title: title,
                  description: description,
                );
                final firestore = FirestoreService();
                await firestore.addTodoForUser(user.id!, newTodo);
              }

              Navigator.pop(context);
              ref.read(todoProvider.notifier).loadTodos();
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }
}
