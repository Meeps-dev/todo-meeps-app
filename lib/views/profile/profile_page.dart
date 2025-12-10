import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_app/providers/user_provider.dart';
import 'package:my_app/services/firestore_service.dart';

import '../bottom_nav_shell.dart';
import 'package:image_picker/image_picker.dart';

class ProfilePage extends ConsumerStatefulWidget {
  const ProfilePage({super.key});

  @override
  ConsumerState<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends ConsumerState<ProfilePage> {
  bool isEditing = false;
  late TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    final userNotifier = ref.read(userProvider.notifier);

    // Load user first
    userNotifier.loadUser().then((_) {
      setState(() {}); // refresh UI after loading
    });

    _controller = TextEditingController(
      text: ref.read(userProvider).name ?? '',
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  // 📸 Pick image and save to Hive via provider
  Future<void> _pickImage() async {
    final user = ref.read(userProvider);
    final userId = user.id;

    if (userId == null) {
      return;
    }

    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile == null) return;

    // THIS handles upload + Firestore update + Hive update
    await ref
        .read(userProvider.notifier)
        .updateProfileImage(File(pickedFile.path));

    setState(() {}); // refresh UI
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(userProvider); // 🧠 Reactively watch user changes

    return Scaffold(
      appBar: AppBar(title: const Text('👤 Profile')),
      body: SingleChildScrollView(
        child: Center(
          child: Card(
            elevation: 6,
            margin: const EdgeInsets.all(20),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15),
            ),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // 🖼 Profile Avatar
                  GestureDetector(
                    onTap: _pickImage,
                    child: CircleAvatar(
                      radius: 45,
                      backgroundImage:
                          (user.profileImage != null &&
                              user.profileImage!.isNotEmpty)
                          ? NetworkImage(
                              user.profileImage!,
                            ) // <-- use NetworkImage for URL
                          : null,
                      child:
                          (user.profileImage == null ||
                              user.profileImage!.isEmpty)
                          ? const Icon(
                              Icons.person,
                              size: 45,
                              color: Colors.blue,
                            )
                          : null,
                    ),
                  ),

                  const SizedBox(height: 15),

                  // ✏️ Editable Name
                  isEditing
                      ? TextField(
                          controller: _controller,
                          textAlign: TextAlign.center,
                          style: const TextStyle(fontSize: 22),
                          decoration: const InputDecoration(
                            hintText: 'Enter your name',
                            border: UnderlineInputBorder(),
                          ),
                        )
                      : Text(
                          'Welcome, ${user.name ?? 'User'}!',
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          ),
                        ),

                  const SizedBox(height: 15),

                  // 🧠 Edit/Save Button
                  ElevatedButton.icon(
                    icon: Icon(isEditing ? Icons.save : Icons.edit),
                    label: Text(isEditing ? 'Save' : 'Edit Name'),
                    onPressed: () async {
                      if (isEditing) {
                        final newName = _controller.text.trim();
                        if (newName.isNotEmpty) {
                          await ref
                              .read(userProvider.notifier)
                              .setName(newName); // ✅ Persist to Hive
                        }
                      }
                      setState(() => isEditing = !isEditing);
                    },
                  ),

                  const SizedBox(height: 15),

                  // 🏠 Home button
                  ElevatedButton(
                    onPressed: () {
                      ref.read(bottomNavIndexProvider.notifier).state = 0;
                    },
                    child: const Text('🏠 Go to Home'),
                  ),

                  const SizedBox(height: 15),

                  // ⚙️ Settings button
                  ElevatedButton(
                    onPressed: () {
                      ref.read(bottomNavIndexProvider.notifier).state = 2;
                    },
                    child: const Text('⚙️ Go to Settings'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
