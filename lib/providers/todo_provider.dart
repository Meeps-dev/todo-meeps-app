import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_app/providers/user_provider.dart';
import '../models/todo_model.dart';
import '../viewmodels/todo_viewmodel.dart';

final todoProvider = StateNotifierProvider<TodoViewModel, List<TodoModel>>((
  ref,
) {
  final user = ref.watch(userProvider);
  return TodoViewModel(user.id!);
});
