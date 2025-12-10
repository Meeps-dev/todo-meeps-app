import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import '../models/todo_model.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  static final FirebaseStorage _storage = FirebaseStorage.instance;

  // -------------------------------
  // 🔥 UPLOAD PROFILE IMAGE
  // -------------------------------
  static Future<String> uploadProfileImage(File file, String userId) async {
    if (userId.isEmpty) {
      throw Exception("❌ uploadProfileImage: userId is EMPTY");
    }

    final ref = _storage.ref().child("profile_images/$userId.jpg");

    // upload the file
    await ref.putFile(file);

    // get the download url
    final url = await ref.getDownloadURL();
    return url;
  }

  // -------------------------------
  // 🔥 UPDATE USER DOC WITH IMAGE URL
  // -------------------------------
  Future<void> updateUserProfileImage(String userId, String url) async {
    await _db.collection("users").doc(userId).update({"profileImage": url});
  }

  // Get todos for a user
  Future<List<TodoModel>> getTodos(String userId) async {
    final snap = await _db
        .collection('users')
        .doc(userId)
        .collection('todos')
        .get();

    return snap.docs.map((d) => TodoModel.fromFirestore(d)).toList();
  }

  Future<List<TodoModel>> getTodosForUser(String userId) async {
    final snapshot = await _db
        .collection('users')
        .doc(userId)
        .collection('todos')
        .get();
    return snapshot.docs.map((doc) => TodoModel.fromFirestore(doc)).toList();
  }

  Future<void> addTodoForUser(String userId, TodoModel todo) async {
    final docRef = _db
        .collection('users')
        .doc(userId)
        .collection('todos')
        .doc();
    await docRef.set(todo.toFirestore());
  }

  // Add todo
  Future<void> addTodo(String userId, TodoModel todo) async {
    final doc = _db.collection('users').doc(userId).collection('todos').doc();

    await doc.set(todo.toFirestore());
  }

  // Update todo
  Future<void> updateTodo(String userId, TodoModel todo) async {
    await _db
        .collection('users')
        .doc(userId)
        .collection('todos')
        .doc(todo.id)
        .update(todo.toFirestore());
  }

  // Delete todo

  Future<void> deleteTodo(String userId, String todoId) async {
    await _db
        .collection('users')
        .doc(userId)
        .collection('todos')
        .doc(todoId)
        .delete();
  }

  // Clear all for that user
  Future<void> clearTodos(String userId) async {
    final snap = await _db
        .collection('users')
        .doc(userId)
        .collection('todos')
        .get();

    for (var d in snap.docs) {
      await d.reference.delete();
    }
  }
}
