// lib/services/report_service.dart
import 'package:flutter/foundation.dart';

// 1. The Model
class Report {
  final String id;
  final String name;
  final String type; // 'Excel', 'PDF', 'TXT', etc.
  final String size;
  final DateTime date;

  final String? content;

  Report({
    required this.id,
    required this.name,
    required this.type,
    required this.size,
    required this.date,
    this.content,
  });
}

// 2. The Service (In-Memory Database)
class ReportService {
  // Singleton Pattern
  static final ReportService _instance = ReportService._internal();
  factory ReportService() => _instance;
  ReportService._internal();

  // The "Database" in RAM
  final ValueNotifier<List<Report>> reportsNotifier = ValueNotifier([]);

  // In-Memory Storage
  final List<Report> _reports = [];

  // Add a report (Call this from ChatPage when AI is done)
  void addReport(String name, String dataContent, String type) {
    // Convert string content to bytes
   final bytes = dataContent.length;
    final sizeStr = bytes > 1024 
        ? "${(bytes / 1024).toStringAsFixed(1)} KB" 
        : "$bytes B";

    final newReport = Report(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: name,
      type: type,
      size: sizeStr,
      date: DateTime.now(),
      content: dataContent,
    );

    // Update list and notify listeners
    _reports.insert(0, newReport); // Add to top
    reportsNotifier.value = List.from(_reports); // Update listeners
  }

}