import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:my_app/models/user_model.dart';
import 'package:my_app/providers/user_provider.dart';
import '../bottom_nav_shell.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/network/api_services.dart';
import '../../viewmodels/auth_viewmodel.dart';

class LoginPage extends ConsumerStatefulWidget {
  const LoginPage({super.key});

  @override
  ConsumerState<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends ConsumerState<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool isLoading = false;

  final auth = AuthViewModel();

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => isLoading = true);

    try {
      final email = _emailController.text.trim();
      final password = _passwordController.text.trim();

      // 🔐 Simulate login via API
      final data = await ApiServices.sendLogin(email, password);
      final token = data['token'];
      FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      final firebaseUser = FirebaseAuth.instance.currentUser;
      if (firebaseUser == null) {
        throw Exception('Firebase login failed');
      }
      print('firebase data ${firebaseUser.toString()}, ${firebaseUser.email}');

      final userNotifier = ref.read(userProvider.notifier);

      await userNotifier.saveUser(
        UserModel(
          id: firebaseUser.uid, // ✅ MUST save this
          name: firebaseUser.displayName ?? 'Test User',
          email: firebaseUser.email,
          token: firebaseUser.refreshToken,
          profileImage: firebaseUser.photoURL,
        ),
      );

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('✅ Login Successful!')));

      // 🏠 Navigate to Bottom Navigation Shell (Home)
      ref.read(bottomNavIndexProvider.notifier).state = 0;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const BottomNavShell()),
      );
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('❌ Login failed: $e')));
    } finally {
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('🔐 Login')),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TextFormField(
                controller: _emailController,
                decoration: const InputDecoration(labelText: 'Email'),
                validator: (value) =>
                    value!.isEmpty ? 'Enter your email' : null,
              ),
              TextFormField(
                controller: _passwordController,
                decoration: const InputDecoration(labelText: 'Password'),
                obscureText: true,
                validator: (value) =>
                    value!.isEmpty ? 'Enter your password' : null,
              ),
              const SizedBox(height: 20),
              isLoading
                  ? const CircularProgressIndicator()
                  : ElevatedButton(
                      onPressed: _login,
                      child: const Text('Login'),
                    ),
              TextButton(
                onPressed: () =>
                    Navigator.pushReplacementNamed(context, '/signup'),
                child: const Text('New user? Sign up here'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
