// 📁 lib/api_services.dart
import 'dart:convert';
import '../utils/cache_manager.dart';
import 'package:http/http.dart' as http;

class ApiServices {
  static const String baseUrl = 'https://jsonplaceholder.typicode.com';

  // 🟢 GET: Fetch demo users (with caching)
  static Future<List<dynamic>> fetchUsers() async {
    const cacheKey = 'usersCache';

    // 1️⃣ Try loading cached data first
    final cached = CacheManager.getResponse(
      cacheKey,
      maxAge: Duration(hours: 1),
    );
    if (cached != null) {
      print('📦 Loaded users from cache!');
      return cached;
    }

    // 2️⃣ Fetch from the internet if not cached or expired
    final url = Uri.parse('$baseUrl/users');
    print('🌐 Fetching users from network...');
    final response = await http.get(url);

    print('📥 GET /users → ${response.statusCode}');

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);

      // 3️⃣ Save to cache for next time
      await CacheManager.saveResponse(cacheKey, data);

      print('💾 Saved users to cache.');
      return data;
    } else if (response.statusCode == 404) {
      throw Exception('⚠️ Users not found');
    } else if (response.statusCode >= 500) {
      throw Exception('💥 Server error, try again later');
    } else {
      throw Exception('❌ Unexpected error (${response.statusCode})');
    }
  }

  // 🟣 POST: Login
  static Future<Map<String, dynamic>> sendLogin(
    String email,
    String password,
  ) async {
    final url = Uri.parse('$baseUrl/posts');
    print('📡 Sending login request...');
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email, 'password': password}),
    );

    print('📩 Response: ${response.statusCode}');
    print('📩 Body: ${response.body}');

    // ✅ Successful login (simulated)
    if (response.statusCode == 201) {
      return {'token': 'fake_login_token_1234'};
    }
    // ❌ Client-side errors
    else if (response.statusCode == 400) {
      throw Exception('❌ Invalid email or password');
    }
    // 💥 Server-side errors
    else if (response.statusCode >= 500) {
      throw Exception('💥 Server error, please try again later');
    } else {
      throw Exception('⚠️ Unexpected error (${response.statusCode})');
    }
  }

  // 🔵 POST: Signup
  static Future<Map<String, dynamic>> sendSignup(
    String name,
    String email,
    String password,
  ) async {
    final url = Uri.parse('$baseUrl/posts');
    print('📡 Sending signup request...');
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'name': name, 'email': email, 'password': password}),
    );

    print('📩 Response: ${response.statusCode}');

    if (response.statusCode == 201) {
      return {'token': 'fake_signup_token_5678'};
    } else if (response.statusCode == 400) {
      throw Exception('⚠️ Invalid input — check your form fields');
    } else if (response.statusCode >= 500) {
      throw Exception('💥 Server error — please try again later');
    } else {
      throw Exception('❌ Unexpected error (${response.statusCode})');
    }
  }
}
