// lib/services/report_service.dart
import 'dart:convert';
// ignore: avoid_web_libraries_in_flutter
import 'dart:html' as html; // Only works on Flutter Web
import 'package:flutter/foundation.dart';

// 1. The Model
class Report {
  final String id;
  final String name;
  final String type; // 'CSV', 'Excel', 'PDF'
  final String size;
  final DateTime date;
  final List<int> data; // The actual file bytes

  Report({
    required this.id,
    required this.name,
    required this.type,
    required this.size,
    required this.date,
    required this.data,
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

  // Add a report (Call this from ChatPage when AI is done)
  void addReport(String name, String content, String type) {
    // Convert string content to bytes
    List<int> bytes = utf8.encode(content);
    String size = "${(bytes.length / 1024).toStringAsFixed(1)} KB";

    final newReport = Report(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: name,
      type: type,
      size: size,
      date: DateTime.now(),
      data: bytes,
    );

    // Update list and notify listeners
    reportsNotifier.value = [newReport, ...reportsNotifier.value];
  }

  // Trigger Download in Browser
  void downloadReport(Report report) {
    if (kIsWeb) {
      final blob = html.Blob([report.data]);
      final url = html.Url.createObjectUrlFromBlob(blob);
      html.AnchorElement(href: url)
        ..setAttribute("download", "${report.name}.${report.type.toLowerCase()}")
        ..click();
      html.Url.revokeObjectUrl(url);
    }
  }
}