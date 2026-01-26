// lib/services/report_service.dart
import 'dart:convert';
// ignore: avoid_web_libraries_in_flutter
import 'dart:html' as html; // Only works on Flutter Web
import 'package:flutter/foundation.dart';

// Packages for download options
import 'package:excel/excel.dart';

// 1. The Model
class Report {
  final String id;
  final String name;
  final String type; // 'Excel', 'PDF', 'TXT', etc.
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

 // --- DOWNLOADERS ---

  // 1. Text / CSV (Original)
  void downloadAsTxt(Report report) {
    _triggerWebDownload(report.data, "${report.name}.txt", "text/plain");
  }  

  // 2. Excel
  Future<void> downloadAsExcel(Report report) async {
    var excel = Excel.createExcel();
    Sheet sheetObject = excel['Sheet1'];
    
    final textContent = utf8.decode(report.data);
    
    // Split by lines and add as rows
    List<String> lines = const LineSplitter().convert(textContent);
    for (var line in lines) {
      // Split by comma for CSV-like structure, or just put whole line in one cell
      List<String> cells = line.split(',');
      sheetObject.appendRow(cells.map((e) => TextCellValue(e.trim())).toList());
    }
    final bytes = excel.encode();
    
    if (bytes != null) {
      _triggerWebDownload(bytes, "${report.name}.xlsx", "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet");
    }
  }

  // Helper for Browser Download
  void _triggerWebDownload(List<int> bytes, String fileName, String mimeType) {
    if (kIsWeb) {
      final blob = html.Blob([bytes], mimeType);
      final url = html.Url.createObjectUrlFromBlob(blob);
      html.AnchorElement(href: url)
        ..setAttribute("download", fileName)
        ..click();
      html.Url.revokeObjectUrl(url);
    }
  }
}