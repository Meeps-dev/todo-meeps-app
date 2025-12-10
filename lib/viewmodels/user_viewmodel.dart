import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:my_app/firebase_storage.dart';
import '../models/user_model.dart';

class UserNotifier extends StateNotifier<UserModel> {
  UserNotifier() : super(UserModel());

  bool isLoaded = false;
  final _box = Hive.box('userBox');

  Future<void> loadUser() async {
    final userMap = _box.get('userData');

    if (userMap != null) {
      var loaded = UserModel.fromMap(Map<String, dynamic>.from(userMap));

      // 🚀 FIX: if Hive lost the ID, restore it from FirebaseAuth
      if (loaded.id == null || loaded.id!.isEmpty) {
        final firebaseUser = FirebaseAuth.instance.currentUser;
        if (firebaseUser != null) {
          loaded = loaded.copyWith(id: firebaseUser.uid);
        }
      }

      state = loaded;
    } else {
      state = UserModel();
    }

    isLoaded = true;
  }

  // Save user to Hive
  Future<void> saveUser(UserModel user) async {
    await _box.put('userData', user.toMap());
    await _box.put('isLoggedIn', true);
    state = user;
  }

  // Update name
  Future<void> setName(String newName) async {
    final updated = state.copyWith(name: newName);
    await saveUser(updated);
  }

  // Save token
  Future<void> setToken(String newToken) async {
    final updated = state.copyWith(token: newToken);
    await saveUser(updated);
  }

  // Update profile image (URL only)
  Future<void> updateProfileImage(File imageFile) async {
    final userId = state.id;

    if (userId == null) throw Exception("User ID is null");

    final storage = StorageService();

    // Upload using correct filename
    final imageUrl = await storage.uploadImage(imageFile.path);

    // Save URL in Firestore
    await FirebaseFirestore.instance.collection('users').doc(userId).update({
      'profileImage': imageUrl,
    });

    // Update UI state
    state = state.copyWith(profileImage: imageUrl);
  }

  // Logout (keep profile + name)
  Future<void> logout() async {
    final updated = state.copyWith(token: null);
    await saveUser(updated);
    await _box.put('isLoggedIn', false);
  }
}
