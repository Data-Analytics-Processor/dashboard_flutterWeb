// lib/api/api_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:uuid/uuid.dart';
import 'package:flutter/foundation.dart';
import 'package:dashboard_flutter/api/auth_service.dart';

class ApiService {
  static const String _prodUrl = "https://brixta.site";  // fix24
  //static const String _localUrl = "http://10.0.2.2:5000"; // localhost android
  static const String _localUrl = "http://127.0.0.1:5000"; // localhost web
  final String _baseUrl = kReleaseMode ? _prodUrl : _localUrl;

  final String _sessionId = const Uuid().v4();
  String get sessionId => _sessionId;

  final AuthService _authService = AuthService();

  // Helper method to attach JWT headers
  Future<Map<String, String>> _getHeaders({bool isMultipart = false}) async {
    final token = await _authService.getToken();
    return {
      if (!isMultipart) "Content-Type": "application/json",
      if (token != null) "Authorization": "Bearer $token",
    };
  }

  /* -----------------------------
   * 1. GET TOOLS 
   * ----------------------------- */
  Future<List<dynamic>> fetchTools() async {
    final headers = await _getHeaders();
    final res = await http.get(
      Uri.parse("$_baseUrl/api/v1/chatbot/tools"),
      headers: headers,
    );

    if (res.statusCode != 200) {
      throw Exception("Failed to fetch tools: ${res.statusCode}");
    }

    final data = jsonDecode(res.body);
    return data["tools"];
  }

  /* -----------------------------
   * 2. UPLOAD DATASET (Base64 -> Multipart)
   * ----------------------------- */
  Future<String> uploadDataset(
    String filename,
    String base64Content,
  ) async {
    List<int> fileBytes = base64Decode(base64Content);
    var request = http.MultipartRequest(
      'POST',
      Uri.parse("$_baseUrl/api/v1/chatbot/upload"),
    );

    // Attach JWT to the multipart request
    final headers = await _getHeaders(isMultipart: true);
    request.headers.addAll(headers);

    request.files.add(
      http.MultipartFile.fromBytes(
        'file',
        fileBytes,
        filename: filename,
      ),
    );

    final streamedResponse = await request.send();
    final res = await http.Response.fromStream(streamedResponse);

    if (res.statusCode != 200) {
      throw Exception("Dataset upload failed: ${res.body}");
    }

    final data = jsonDecode(res.body);
    return data["file_path"];
  }

  /* -----------------------------
   * 3. CHAT
   * ----------------------------- */
  Future<Map<String, dynamic>> sendChat({
    required String message,
    String? csvFilePath,
  }) async {
    final headers = await _getHeaders();
    final body = {
      "message": message,
      "session_id": _sessionId,
      if (csvFilePath != null) "csv_file_path": csvFilePath,
    };

    final res = await http.post(
      Uri.parse("$_baseUrl/api/v1/chatbot/chat"),
      headers: headers,
      body: jsonEncode(body),
    );

    if (res.statusCode != 200) {
      throw Exception("Chat request failed: ${res.body}");
    }
    return jsonDecode(res.body);
  }
}