// lib/api/api_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:uuid/uuid.dart';
import 'package:flutter/foundation.dart';

class ApiService {
  static const String _localUrl = "http://localhost:5000";
  static const String _prodUrl = "https://backend-py-edco.onrender.com"; 

  // 2. Auto-switch logic
  final String _baseUrl = kReleaseMode ? _prodUrl : _localUrl;

  final String _sessionId = const Uuid().v4();
  String get sessionId => _sessionId;

  /* -----------------------------
   * 1. GET TOOLS 
   * ----------------------------- */
  Future<List<dynamic>> fetchTools() async {
    final res = await http.get(Uri.parse("$_baseUrl/api/v1/chatbot/tools"));

    if (res.statusCode != 200) {
      throw Exception("Failed to fetch tools");
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
    // 1. Decode Base64 to bytes
    List<int> fileBytes = base64Decode(base64Content);

    // 2. Prepare Multipart Request
    var request = http.MultipartRequest(
      'POST',
      Uri.parse("$_baseUrl/api/v1/chatbot/upload"),
    );

    // 3. Add the file
    request.files.add(
      http.MultipartFile.fromBytes(
        'file',
        fileBytes,
        filename: filename,
      ),
    );

    // 4. Send
    final streamedResponse = await request.send();
    final res = await http.Response.fromStream(streamedResponse);

    if (res.statusCode != 200) {
      throw Exception("Dataset upload failed: ${res.body}");
    }

    // 5. Return the 'file_path' that the backend needs for context
    final data = jsonDecode(res.body);
    return data["file_path"];
  }

  /* -----------------------------
   * 3. CHAT (The Unified Brain)
   * Replaces executeTool & explainResult
   * ----------------------------- */
  Future<Map<String, dynamic>> sendChat({
    required String message,
    String? csvFilePath, // Optional: Only send if a file is uploaded
  }) async {
    final body = {
      "message": message,
      "session_id": _sessionId,
      if (csvFilePath != null) "csv_file_path": csvFilePath,
    };

    final res = await http.post(
      Uri.parse("$_baseUrl/api/v1/chatbot/chat"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode(body),
    );

    if (res.statusCode != 200) {
      throw Exception("Chat request failed: ${res.body}");
    }
    return jsonDecode(res.body);
  }
}