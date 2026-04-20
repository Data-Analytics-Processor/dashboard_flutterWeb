// lib/api/auth_service.dart
import 'dart:async';
import 'dart:convert';
import 'dart:developer' as dev;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:jwt_decoder/jwt_decoder.dart'; // Run: flutter pub add jwt_decoder
import '../models/users_model.dart';

class AuthService {
  static const String _baseUrl = 'https://brixta.site';
  //static const String _baseUrl = 'http://10.0.2.2:8000'; // localhost
  //static const String _baseUrl = "http://127.0.0.1:8000"; // localhost (web-version)

  final _secureStorage = const FlutterSecureStorage();
  static const String _kCachedProfileKey = 'admin_user_profile_cache';
  static const String _kTokenKey = 'jwt_token';

  // --- CROSS PLATFORM TOKEN STORAGE ---
  Future<void> _saveToken(String token) async {
    if (kIsWeb) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_kTokenKey, token);
    } else {
      await _secureStorage.write(key: _kTokenKey, value: token);
    }
  }

  Future<String?> getToken() async {
    if (kIsWeb) {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString(_kTokenKey);
    } else {
      return await _secureStorage.read(key: _kTokenKey);
    }
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear(); // Clears cached profile and web token

    if (!kIsWeb) {
      await _secureStorage.deleteAll(); // Clears mobile tokens
    }
  }

  // --- ADMIN LOGIN ---
  Future<User> login(
    String loginId,
    String password,
    String deviceId,
    String? fcmToken,
  ) async {
    // 1. Point to the NEW Admin endpoint
    final url = Uri.parse('$_baseUrl/api/auth/admin/login');

    final requestBody = jsonEncode({
      'loginId': loginId.trim(),
      'password': password,
      'deviceId': null, // Currently null per your backend setup
      'fcmToken': fcmToken,
    });

    try {
      final response = await http
          .post(
            url,
            headers: {'Content-Type': 'application/json'},
            body: requestBody,
          )
          .timeout(const Duration(seconds: 45));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final String? token = data['token'];
        final Map<String, dynamic>? userData = data['user'];

        if (token != null && userData != null) {
          await _saveToken(token);
          await _cacheUserProfile(userData);

          // The backend already verified this is an admin, so we just return the parsed user.
          return User.fromJson(userData);
        } else {
          throw Exception('Login response is missing token or user data.');
        }
      } else if (response.statusCode == 403 || response.statusCode == 401) {
        final data = jsonDecode(response.body);
        throw Exception(data['error'] ?? "Unauthorized access");
      } else {
        final data = jsonDecode(response.body);
        throw Exception(data['error'] ?? "Login failed");
      }
    } on TimeoutException {
      throw Exception('Server is taking too long to respond.');
    } catch (e) {
      dev.log('Login Error', error: e, name: 'AuthService');
      rethrow;
    }
  }

  Future<void> _cacheUserProfile(Map<String, dynamic> jsonData) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_kCachedProfileKey, jsonEncode(jsonData));
    } catch (e) {
      dev.log('Cache error: $e', name: 'AuthService');
    }
  }

  // --- AUTO LOGIN (Using JWT Decoder) ---
  Future<User?> tryAutoLogin() async {
    final token = await getToken();
    if (token == null) return null;

    try {
      // 1. Check if token is expired before doing anything else
      if (JwtDecoder.isExpired(token)) {
        await logout();
        return null;
      }

      // 2. Decode the rich payload we set up in the backend
      final Map<String, dynamic> payload = JwtDecoder.decode(token);

      // 3. Double check the admin flag from the token just to be safe
      if (payload['isAdmin'] != true) {
        await logout();
        return null;
      }

      // 4. Try to load the full cached profile first
      final prefs = await SharedPreferences.getInstance();
      final cachedProfileStr = prefs.getString(_kCachedProfileKey);

      if (cachedProfileStr != null) {
        return User.fromJson(jsonDecode(cachedProfileStr));
      } else {
        // Fallback: If cache was cleared but token exists, build a basic user from the JWT payload
        return User(
          id: payload['id'].toString(),
          email: payload['email'] ?? '',
          orgRole: payload['orgRole'],
          jobRoles: payload['jobRole'] != null
              ? List<String>.from(payload['jobRole'])
              : [],
          permissions: List<String>.from(payload['perms'] ?? []),
          isAdminAppUser: payload['isAdmin'] ?? false,
        );
      }
    } catch (e) {
      dev.log('Auto-login Error', error: e, name: 'AuthService');
      return null;
    }
  }
}
