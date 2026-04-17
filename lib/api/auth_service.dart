// lib/api/auth_service.dart
import 'dart:async';
import 'dart:convert';
import 'dart:developer' as dev;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import '../models/users_model.dart'; 

class AuthService {
  //static const String _baseUrl = 'http://65.0.208.126'; //aws
  static const String _baseUrl = 'http://10.0.2.2:8000'; // localhost 
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
    //String deviceId,
    String? fcmToken,
  ) async {
    final url = Uri.parse('$_baseUrl/api/auth/login');
    
    // The backend accepts 'loginId' which maps to adminAppLoginId automatically
    final requestBody = jsonEncode({
      'loginId': loginId.trim(),
      'password': password,
      //'deviceId': deviceId,
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
        final int? userId = data['userId'];

        if (token != null && userId != null) {
          await _saveToken(token);
          
          // Fetch profile to verify Admin status
          final user = await _fetchUserProfile(userId.toString(), token);
          
          if (!user.isAdminAppUser) {
             // If valid credentials but NOT an admin app user
             await logout();
             throw Exception("Access Denied: You do not have Admin App permissions.");
          }
          
          return user;
        } else {
          throw Exception('Login response is missing token.');
        }
      } else if (response.statusCode == 403) {
        final data = jsonDecode(response.body);
        throw Exception(data['error'] ?? "Device unauthorized");
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

  Future<User> _fetchUserProfile(String userId, String token) async {
    final url = Uri.parse('$_baseUrl/api/users/$userId');
    try {
      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      ).timeout(const Duration(seconds: 30));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data.containsKey('data')) {
          await _cacheUserProfile(data['data']);
          return User.fromJson(data['data']);
        } else {
          throw Exception('Profile data missing.');
        }
      } else {
         throw Exception('Failed to load user profile.');
      }
    } catch (e) {
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

  // Auto-Login
  Future<User?> tryAutoLogin() async {
    final token = await getToken();
    if (token == null) return null;

    try {
      // Decode JWT to get ID (simple decoding)
      final parts = token.split('.');
      if (parts.length != 3) return null;
      
      final payload = json.decode(
        ascii.decode(base64.decode(base64.normalize(parts[1]))),
      );
      final String userId = payload['id'].toString();

      final user = await _fetchUserProfile(userId, token);
      
      // Double check permission on auto-login
      if (!user.isAdminAppUser) {
        await logout();
        return null;
      }
      
      return user;
    } catch (e) {
       return null; 
    }
  }
}