import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/user_model.dart';
import '../providers/user_provider.dart';

class AuthViewModel {
  final _auth = FirebaseAuth.instance;

  Future<void> login(WidgetRef ref, String email, String password) async {
    final result = await _auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );

    // Firebase gives us user.uid → use that as token
    final updatedUser = UserModel(
      email: email,
      token: result.user!.uid,
      name: ref.read(userProvider).name,
      profileImage: ref.read(userProvider).profileImage,
    );

    await ref.read(userProvider.notifier).saveUser(updatedUser);
  }

  Future<void> signup(
    WidgetRef ref,
    String name,
    String email,
    String password,
  ) async {
    final result = await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );

    final updatedUser = UserModel(
      name: name,
      email: email,
      token: result.user!.uid,
      profileImage: ref.read(userProvider).profileImage,
    );

    await ref.read(userProvider.notifier).saveUser(updatedUser);
  }

  Future<void> logout(WidgetRef ref) async {
    await _auth.signOut();
    await ref.read(userProvider.notifier).logout();
  }
}
