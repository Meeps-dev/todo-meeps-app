import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'home/home_page.dart';
import 'profile/profile_page.dart';
import 'settings/settings_page.dart';

// 🧭 This Provider stores the current tab index (0 = Home, 1 = Profile, 2 = Settings)
final bottomNavIndexProvider = StateProvider<int>((ref) => 0);

class BottomNavShell extends ConsumerWidget {
  const BottomNavShell({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // 🧠 Listen to which tab is currently selected
    final currentIndex = ref.watch(bottomNavIndexProvider);

    // 🧩 List of pages for each tab
    final pages = const [HomePage(), ProfilePage(), SettingsPage()];

    return Scaffold(
      body: pages[currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: currentIndex,
        onTap: (index) =>
            ref.read(bottomNavIndexProvider.notifier).state = index,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: 'Settings',
          ),
        ],
      ),
    );
  }
}
