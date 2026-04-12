// lib/api/api_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:uuid/uuid.dart';
import '../models/collectionReports_model.dart';
import '../models/projectionReports_model.dart';
import '../models/projectionVsActualReports_model.dart';
import '../models/outstandingReports_model.dart';
import '../models/verifiedDealers_model.dart';

class ApiService {
  //static const String _baseUrl = "http://10.0.2.2:5000"; // Chat GPT - Data Analysis backend
  static const String _baseUrl = "https://backend-py-edco.onrender.com"; // Chat GPT - Data Analysis backend

  static const String _mycocoBaseUrl = 'https://brixta.site'; 
  //static const String _mycocoBaseUrl = "https://adminappbackend-ocpc.onrender.com"; // render - mycoco backend for reports api
  //static const String _mycocoBaseUrl = "http://10.0.2.2:8000"; // localhost - mycoco backend for reports api
  //static const String _mycocoBaseUrl = "http://127.0.0.1:8000"; // localhost - mycoco backend for reports api (web-version)

  // Shared instance for sharing sessionId across all pages
  static final ApiService _instance = ApiService._internal();
  factory ApiService() => _instance;
  ApiService._internal();
  // ----------------------------------------
  
  // CHAT GPT --- DATA ANALYTICS ENDPOINTS

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
    int limit = 50,
    int page = 1,
    String? institution,
    String? fromDate,
    String? toDate,
    int? verifiedDealerId, 
    int? userId, 
    int? salesPromoterUserId, 
    String? sortBy,
    String? sortDir,
  }) async {
    final queryParams = <String, String>{
      'limit': limit.toString(),
      'page': page.toString(),
      if (institution != null) 'institution': institution,
      if (fromDate != null) 'fromDate': fromDate,
      if (toDate != null) 'toDate': toDate,
      if (verifiedDealerId != null) 'verifiedDealerId': verifiedDealerId.toString(),
      if (userId != null) 'userId': userId.toString(),
      if (salesPromoterUserId != null) 'salesPromoterUserId': salesPromoterUserId.toString(),
      if (sortBy != null) 'sortBy': sortBy,
      if (sortDir != null) 'sortDir': sortDir,
    };

    final url = Uri.parse(
      "$_mycocoBaseUrl/api/collection-reports",
    ).replace(queryParameters: queryParams);

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

  Future<List<OutstandingReport>> fetchOutstandingReports({
    int limit = 50,
    int page = 1,
    int? verifiedDealerId,
    String? collectionReportId,
    String? dvrId,
    bool? isOverdue,
    bool? isAccountJsbJud,
    String? sortBy,
    String? sortDir,
    String? reportDate, 
    String? fromDate,   
    String? toDate,
    String? search,     
  }) async {
    final queryParams = <String, String>{
      'limit': limit.toString(),
      'page': page.toString(),
      if (verifiedDealerId != null)
        'verifiedDealerId': verifiedDealerId.toString(),
      if (collectionReportId != null) 'collectionReportId': collectionReportId,
      if (dvrId != null) 'dvrId': dvrId,
      if (isOverdue != null) 'isOverdue': isOverdue.toString(),
      if (isAccountJsbJud != null)
        'isAccountJsbJud': isAccountJsbJud.toString(),
      if (sortBy != null) 'sortBy': sortBy,
      if (sortDir != null) 'sortDir': sortDir,
      if (reportDate != null) 'reportDate': reportDate,
      if (fromDate != null) 'fromDate': fromDate,
      if (toDate != null) 'toDate': toDate,
      if (search != null) 'search': search,
    };

    final url = Uri.parse(
      "$_mycocoBaseUrl/api/outstanding-reports",
    ).replace(queryParameters: queryParams);

    final res = await http.get(url);

    if (res.statusCode == 200) {
      final json = jsonDecode(res.body);
      if (json['success'] == true) {
        return (json['data'] as List)
            .map((e) => OutstandingReport.fromJson(e))
            .toList();
      }
    }
    throw Exception("Failed to fetch outstanding reports: ${res.statusCode}");
  }

  Future<List<VerifiedDealer>> fetchVerifiedDealers({
    int limit = 50,
    int page = 1,
    String? zone,
    String? area,
    String? dealerCategory,
    String? dealerCode,
    bool? isSubdealer,
    int? userId,
    int? dealerId, 
    String? sortBy,
    String? sortDir,
  }) async {
    final queryParams = <String, String>{
      'limit': limit.toString(),
      'page': page.toString(),
      if (zone != null) 'zone': zone,
      if (area != null) 'area': area,
      if (dealerCategory != null) 'dealerCategory': dealerCategory,
      if (dealerCode != null) 'dealerCode': dealerCode,
      if (isSubdealer != null) 'isSubdealer': isSubdealer.toString(),
      if (userId != null) 'userId': userId.toString(),
      if (dealerId != null) 'dealerId': dealerId.toString(), 
      if (sortBy != null) 'sortBy': sortBy,
      if (sortDir != null) 'sortDir': sortDir,
    };

    final url = Uri.parse(
      "$_mycocoBaseUrl/api/verified-dealers",
    ).replace(queryParameters: queryParams);

    final res = await http.get(url);

    if (res.statusCode == 200) {
      final json = jsonDecode(res.body);
      if (json['success'] == true) {
        return (json['data'] as List)
            .map((e) => VerifiedDealer.fromJson(e))
            .toList();
      }
    }
    throw Exception("Failed to fetch verified dealers: ${res.statusCode}");
  }

  Future<List<ProjectionVsActualReport>> fetchProjectionVsActual({
    int limit = 100,
    String? institution,
    String? zone,
    String? dealerName,
    int? verifiedDealerId, 
    int? userId, 
    String? fromDate,
    String? toDate,
  }) async {
    final queryParams = <String, String>{
      'limit': limit.toString(),
      if (institution != null) 'institution': institution,
      if (zone != null) 'zone': zone,
      if (dealerName != null) 'dealerName': dealerName,
      if (verifiedDealerId != null) 'verifiedDealerId': verifiedDealerId.toString(),
      if (userId != null) 'userId': userId.toString(),
      if (fromDate != null) 'fromDate': fromDate,
      if (toDate != null) 'toDate': toDate,
    };

    final url = Uri.parse(
      "$_mycocoBaseUrl/api/projection-vs-actual",
    ).replace(queryParameters: queryParams);

    final res = await http.get(url);

    if (res.statusCode == 200) {
      final json = jsonDecode(res.body);
      if (json['success'] == true) {
        return (json['data'] as List)
            .map((e) => ProjectionVsActualReport.fromJson(e))
            .toList();
      }
    }
    throw Exception("Failed to fetch projection vs actual reports: ${res.statusCode}");
  }

  Future<List<ProjectionReport>> fetchProjectionReports({
    int limit = 100,
    String? institution,
    String? zone,
    int? verifiedDealerId, 
    int? userId, 
    int? salesPromoterUserId, 
    String? fromDate,
    String? toDate,
  }) async {
    final queryParams = <String, String>{
      'limit': limit.toString(),
      if (institution != null) 'institution': institution,
      if (zone != null) 'zone': zone,
      if (verifiedDealerId != null) 'verifiedDealerId': verifiedDealerId.toString(),
      if (userId != null) 'userId': userId.toString(),
      if (salesPromoterUserId != null) 'salesPromoterUserId': salesPromoterUserId.toString(),
      if (fromDate != null) 'fromDate': fromDate,
      if (toDate != null) 'toDate': toDate,
    };

    final url = Uri.parse(
      "$_mycocoBaseUrl/api/projection-reports",
    ).replace(queryParameters: queryParams);

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