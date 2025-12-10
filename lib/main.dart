import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'core/utils/cache_manager.dart';
import 'models/user_model.dart';
import 'providers/user_provider.dart';
import 'viewmodels/user_viewmodel.dart';
import 'views/bottom_nav_shell.dart';
import 'views/auth/login_page.dart';
import 'views/auth/signup_page.dart';
import 'views/home/home_page.dart';
import 'views/profile/profile_page.dart';
import 'views/settings/settings_page.dart';
import 'views/settings/set_new_password.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  print('Firebase initialized${Firebase.apps.length}');
  // 🐝 Hive
  await Hive.initFlutter();
  await Hive.openBox('userBox');

  // 🗂 Cache Manager
  await CacheManager.init();

  // 🧠 Load saved user before ProviderScope
  final box = Hive.box('userBox');
  final storedUser = box.get('userData');
  final userNotifier = UserNotifier();

  if (storedUser != null && storedUser is Map) {
    userNotifier.state = UserModel.fromMap(
      Map<String, dynamic>.from(storedUser),
    );
  }

  final bool isLoggedIn = userNotifier.state.token != null;

  runApp(
    ProviderScope(
      overrides: [
        // ⭐ Provide preloaded user state
        userProvider.overrideWith((ref) => userNotifier),
      ],
      child: MyApp(isLoggedIn: isLoggedIn),
    ),
  );
}

class MyApp extends StatelessWidget {
  final bool isLoggedIn;
  const MyApp({super.key, required this.isLoggedIn});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: "Navigation Demo",
      theme: ThemeData(primarySwatch: Colors.blue),

      home: isLoggedIn ? const BottomNavShell() : const LoginPage(),

      routes: {
        '/homeShell': (_) => const BottomNavShell(),
        '/login': (_) => const LoginPage(),
        '/signup': (_) => const SignupPage(),
        '/home': (_) => const HomePage(),
        '/settings': (_) => const SettingsPage(),
        '/profile': (_) => const ProfilePage(),
        '/new-password': (_) => const SetNewPasswordPage(),
      },
    );
  }
}
