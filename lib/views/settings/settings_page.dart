import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_app/core/utils/backup_manager.dart';
import 'package:my_app/providers/todo_provider.dart';
import 'package:my_app/providers/user_provider.dart';
import 'package:my_app/views/bottom_nav_shell.dart';

class SettingsPage extends ConsumerWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // 🧠 Access user data from Riverpod
    final user = ref.watch(userProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('⚙️ Settings')),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // 🧑‍💼 Profile Image (or initials)
              CircleAvatar(
                radius: 45,
                backgroundImage: user.profileImage != null
                    ? NetworkImage(user.profileImage!)
                    : null,
                child: user.profileImage == null
                    ? const Icon(Icons.person, size: 45, color: Colors.blue)
                    : null,
              ),

              const SizedBox(height: 20),

              // 👤 Name & Email
              Text(
                'Welcome, ${user.name ?? "User"}!',
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                '📧 ${user.email ?? "No email"}',
                style: const TextStyle(fontSize: 18),
              ),
              const SizedBox(height: 10),

              const Divider(height: 40),

              // 🔐 Set new password
              ElevatedButton(
                child: const Text('🔐 Set New Password'),
                onPressed: () async {
                  final newPassword = await Navigator.pushNamed(
                    context,
                    '/new-password',
                  );
                  if (newPassword != null &&
                      newPassword.toString().isNotEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('✅ Password updated (local only).'),
                      ),
                    );
                  }
                },
              ),

              const SizedBox(height: 20),

              // 👤 Back to Profile
              ElevatedButton(
                onPressed: () {
                  // 👇 go to Home tab instead of pushing new page
                  ref.read(bottomNavIndexProvider.notifier).state = 1;
                },
                child: const Text('👤 Go to Profile'),
              ),

              const SizedBox(height: 20),

              // 🏠 Back to Home
              ElevatedButton(
                child: const Text('🏠 Back to Home'),
                onPressed: () {
                  // 👇 go to Home tab instead of pushing new page
                  ref.read(bottomNavIndexProvider.notifier).state = 0;

                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Returned to Home!')),
                  );
                },
              ),

              const SizedBox(height: 40),

              // 🚪 Logout button (uses Riverpod)
              ElevatedButton.icon(
                icon: const Icon(Icons.logout),
                label: const Text('Logout'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 25,
                    vertical: 15,
                  ),
                ),
                onPressed: () async {
                  // 🧠 Show confirmation dialog before logging out
                  await showDialog<bool>(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: const Text('Logout?'),
                      content: const Text(
                        'Are you sure you want to log out of your account?',
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context, false),
                          child: const Text('Cancel'),
                        ),
                        TextButton(
                          onPressed: () async {
                            // ✅ Clear user data from Hive via Riverpod
                            FirebaseAuth.instance.signOut();
                            await ref.read(userProvider.notifier).logout();

                            // ✅ Navigate to login screen and clear all previous routes
                            Navigator.pushNamedAndRemoveUntil(
                              context,
                              '/login', // go to login page
                              (route) => false, // remove all previous routes
                            );
                          },
                          child: const Text('🚪 Log Out'),
                        ),
                      ],
                    ),
                  );
                },
              ),

              ElevatedButton.icon(
                icon: const Icon(Icons.backup),
                label: const Text('Backup Data'),
                onPressed: () async {
                  try {
                    await BackupManager.backupAllData();
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('✅ Backup completed')),
                    );
                  } catch (e) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('❌ Backup failed: $e')),
                    );
                  }
                },
              ),

              ElevatedButton.icon(
                icon: const Icon(Icons.restore),
                label: const Text('Restore Backup'),
                onPressed: () async {
                  try {
                    await BackupManager.restoreBackup();
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('♻️ Restore completed')),
                    );
                    // Reload todos after restore
                    ref.read(todoProvider.notifier).loadTodos();
                  } catch (e) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('❌ Restore failed: $e')),
                    );
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
