// lib/api/api_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/collectionReports_model.dart';
import '../models/projectionReports_model.dart';
import '../models/projectionVsActualReports_model.dart';
import '../models/outstandingReports_model.dart';
import '../models/verifiedDealers_model.dart';

import '../models/hr_reports_model.dart';
import '../models/sales_reports_model.dart';

class ApiService {
  //static const String _mycocoBaseUrl = 'https://brixta.site';
  //static const String _mycocoBaseUrl = "http://10.0.2.2:8000"; // localhost - mycoco backend for reports api
  static const String _mycocoBaseUrl = "http://127.0.0.1:8000"; // localhost - mycoco backend for reports api (web-version)

  // Shared instance for sharing sessionId across all pages
  static final ApiService _instance = ApiService._internal();
  factory ApiService() => _instance;
  ApiService._internal();
  // ----------------------------------------

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
      if (verifiedDealerId != null)
        'verifiedDealerId': verifiedDealerId.toString(),
      if (userId != null) 'userId': userId.toString(),
      if (salesPromoterUserId != null)
        'salesPromoterUserId': salesPromoterUserId.toString(),
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
      if (verifiedDealerId != null)
        'verifiedDealerId': verifiedDealerId.toString(),
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
    throw Exception(
      "Failed to fetch projection vs actual reports: ${res.statusCode}",
    );
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
      if (verifiedDealerId != null)
        'verifiedDealerId': verifiedDealerId.toString(),
      if (userId != null) 'userId': userId.toString(),
      if (salesPromoterUserId != null)
        'salesPromoterUserId': salesPromoterUserId.toString(),
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

  // ------xxxx Admin App Reports Endpoints xxxx-------

  Future<HrReport?> fetchLatestHrReport() async {
    final url = Uri.parse("$_mycocoBaseUrl/api/adminapp/hr-reports/latest");

    final res = await http.get(url);

    if (res.statusCode == 200) {
      final json = jsonDecode(res.body);
      if (json['success'] == true && json['data'] != null) {
        return HrReport.fromJson(json['data']);
      }
      return null; // Return null if no data exists yet
    }
    throw Exception("Failed to fetch HR report: ${res.statusCode}");
  }

  // Fetch Aggregated Manual Data
  Future<Map<String, dynamic>> fetchManualHrData() async {
    final url = Uri.parse("$_mycocoBaseUrl/api/adminapp/hr-reports/manual-data");
    final res = await http.get(url);
    if (res.statusCode == 200) {
      final json = jsonDecode(res.body);
      if (json['success'] == true) {
        return json['data']; // Returns the aggregated arrays
      }
    }
    throw Exception("Failed to fetch manual HR data");
  }

  // Post New Interviews (Batch Submission)
  Future<bool> addHrInterview(Map<String, dynamic> payload) async {
    final url = Uri.parse("$_mycocoBaseUrl/api/adminapp/hr-reports/interviews");
    
    // Note: If you attached your verifyAdminToken middleware to this route, 
    // don't forget to add your Authorization header here!
    // Example: headers: {"Content-Type": "application/json", "Authorization": "Bearer $token"}
    final res = await http.post(
      url, 
      headers: {"Content-Type": "application/json"}, 
      body: jsonEncode(payload)
    );

    if (res.statusCode == 200) {
      final json = jsonDecode(res.body);
      if (json['success'] == true) return true;
      
      // If success is false but status is 200, throw the custom message
      throw Exception(json['error'] ?? "Unknown error occurred while saving interviews.");
    } else {
      // Catch 400/500 backend errors and throw them to the UI
      final json = jsonDecode(res.body);
      throw Exception(json['error'] ?? "Failed with status ${res.statusCode}");
    }
  }

  // Post New Performers (Batch Submission)
  Future<bool> addHrPerformer(Map<String, dynamic> payload) async {
    final url = Uri.parse("$_mycocoBaseUrl/api/adminapp/hr-reports/performers");
    
    final res = await http.post(
      url, 
      headers: {"Content-Type": "application/json"}, 
      body: jsonEncode(payload)
    );

    if (res.statusCode == 200) {
      final json = jsonDecode(res.body);
      if (json['success'] == true) return true;
      
      throw Exception(json['error'] ?? "Unknown error occurred while saving performers.");
    } else {
      final json = jsonDecode(res.body);
      throw Exception(json['error'] ?? "Failed with status ${res.statusCode}");
    }
  }

  // Fetch Latest Automated Excel Data (Sales & Collections)
  Future<SalesReport?> fetchLatestSalesReport() async {
    final url = Uri.parse("$_mycocoBaseUrl/api/adminapp/sales-reports/latest");
    final res = await http.get(url);

    if (res.statusCode == 200) {
      final json = jsonDecode(res.body);
      if (json['success'] == true && json['data'] != null) {
        return SalesReport.fromJson(json['data']);
      }
      return null;
    }
    throw Exception("Failed to fetch Sales report: ${res.statusCode}");
  }

  // Fetch Aggregated Manual Data (Non-Trade Approvals)
  Future<List<NonTradeApproval>> fetchManualSalesData() async {
    final url = Uri.parse("$_mycocoBaseUrl/api/adminapp/sales-reports/manual-data");
    final res = await http.get(url);

    if (res.statusCode == 200) {
      final json = jsonDecode(res.body);
      if (json['success'] == true) {
        final approvalsList = json['data']['nonTradeApprovals'] as List? ?? [];
        return approvalsList.map((item) => NonTradeApproval.fromJson(item)).toList();
      }
    }
    throw Exception("Failed to fetch manual Sales data: ${res.statusCode}");
  }

  // Post New Non-Trade Approvals (Batch Submission)
  Future<bool> addNonTradeApprovals(Map<String, dynamic> payload) async {
    final url = Uri.parse("$_mycocoBaseUrl/api/adminapp/sales-reports/non-trade");
    
    final res = await http.post(
      url, 
      headers: {"Content-Type": "application/json"}, 
      body: jsonEncode(payload)
    );

    if (res.statusCode == 200) {
      final json = jsonDecode(res.body);
      if (json['success'] == true) return true;
      
      throw Exception(json['error'] ?? "Unknown error occurred while saving approvals.");
    } else {
      final json = jsonDecode(res.body);
      throw Exception(json['error'] ?? "Failed with status ${res.statusCode}");
    }
  }

}
