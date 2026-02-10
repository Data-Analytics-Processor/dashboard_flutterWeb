// lib/api/api_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:uuid/uuid.dart';
import 'package:flutter/foundation.dart';
import '../models/collectionReports_model.dart';
import '../models/projectionReports_model.dart';
import '../models/projectionVsActualReports_model.dart';

class ApiService {
  static const String _localUrl = "http://localhost:5000"; // Chat GPT - Data Analysis backend
  static const String _prodUrl = "https://backend-py-edco.onrender.com/"; // Chat GPT - Data Analysis backend

  //static const String _mycocoBaseUrl = "http://13.234.76.191"; // aws - mycoco backend for reports api
  static const String _mycocoBaseUrl = "http://10.0.2.2:8000"; // localhost - mycoco backend for reports api

  // CHAT GPT --- DATA ANALYTICS ENDPOINTS
  // Auto-switch logic for Data Analytics URL
  final String _baseUrl = kReleaseMode ? _prodUrl : _localUrl;

  final String _sessionId = const Uuid().v4();
  String get sessionId => _sessionId;

  Future<List<dynamic>> fetchTools() async {
    final res = await http.get(Uri.parse("$_baseUrl/api/v1/chatbot/tools"));

    if (res.statusCode != 200) {
      throw Exception("Failed to fetch tools");
    }

    final data = jsonDecode(res.body);
    return data["tools"];
  }

  Future<String> uploadDataset(String filename, String base64Content) async {
    // 1. Decode Base64 to bytes
    List<int> fileBytes = base64Decode(base64Content);

    // 2. Prepare Multipart Request
    var request = http.MultipartRequest(
      'POST',
      Uri.parse("$_baseUrl/api/v1/chatbot/upload"),
    );

    // 3. Add the file
    request.files.add(
      http.MultipartFile.fromBytes('file', fileBytes, filename: filename),
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

  // ---- xxxxx Data Analytics endpoints end xxxx-----

  // --------- API endpoints for REPORTS ----------
  Future<List<CollectionReport>> fetchCollectionReports({
    int limit = 100,
  }) async {
    final url = Uri.parse(
      "$_mycocoBaseUrl/api/collection-reports?limit=$limit",
    );

    final res = await http.get(url);

    if (res.statusCode == 200) {
      final json = jsonDecode(res.body);
      if (json['success'] == true) {
        return (json['data'] as List)
            .map((e) => CollectionReport.fromJson(e))
            .toList();
      }
    }
    throw Exception("Failed to fetch collections: ${res.statusCode}");
  }

  Future<List<ProjectionVsActualReport>> fetchProjectionVsActual({
    int limit = 100,
  }) async {
    final url = Uri.parse(
      "$_mycocoBaseUrl/api/projection-vs-actual?limit=$limit",
    );

    final res = await http.get(url);

    if (res.statusCode == 200) {
      final json = jsonDecode(res.body);
      if (json['success'] == true) {
        return (json['data'] as List)
            .map((e) => ProjectionVsActualReport.fromJson(e))
            .toList();
      }
    }
    throw Exception("Failed to fetch projection reports: ${res.statusCode}");
  }

  Future<List<ProjectionReport>> fetchProjectionReports({
    int limit = 100,
  }) async {
    final url = Uri.parse(
      "$_mycocoBaseUrl/api/projection-reports?limit=$limit",
    );
    final res = await http.get(url);

    if (res.statusCode == 200) {
      final json = jsonDecode(res.body);
      if (json['success'] == true) {
        return (json['data'] as List)
            .map((e) => ProjectionReport.fromJson(e))
            .toList();
      }
    }
    throw Exception("Failed to fetch projection plans: ${res.statusCode}");
  }

  // ------xxxx Reports Endpoints End xxxx-------
}
