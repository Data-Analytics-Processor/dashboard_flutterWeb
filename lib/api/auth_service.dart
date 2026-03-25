// lib/api/auth_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/foundation.dart';

class AuthService {
  static const String _prodUrl = "https://brixta.site";  // fix24
  //static const String _localUrl = "http://10.0.2.2:5000"; // localhost android
  static const String _localUrl = "http://127.0.0.1:5000"; // localhost web
  final String _baseUrl = kReleaseMode ? _prodUrl : _localUrl;

  static const String _tokenKey = 'jwt_token';

  // Singleton pattern (optional, but good for shared state)
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;
  AuthService._internal();

  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_tokenKey);
  }

  Future<void> _saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_tokenKey, token);
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey);
  }

  Future<bool> login(String email, String password) async {
    // Adjust the endpoint to match your FastAPI auth router
    final url = Uri.parse("$_baseUrl/api/v1/auth/login");
    
    // FastAPI OAuth2PasswordRequestForm usually expects application/x-www-form-urlencoded
    final res = await http.post(
      url,
      headers: {"Content-Type": "application/x-www-form-urlencoded"},
      body: {
        "username": email,
        "password": password,
      },
    );

    if (res.statusCode == 200) {
      final data = jsonDecode(res.body);
      final token = data['access_token'];
      if (token != null) {
        await _saveToken(token);
        return true;
      }
    }
    return false;
  }
}