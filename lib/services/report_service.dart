// lib/services/report_service.dart
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:excel/excel.dart';

// 🚀 IMPORT THE SAFE DOWNLOADER (Handles Web vs Mobile automatically)
import 'downloader/downloader.dart'; 

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

  // 1. Text / CSV
  void downloadAsTxt(Report report) {
    // Uses the safe cross-platform downloader
    downloadFile(report.data, "${report.name}.txt", "text/plain");
  }  

  // 2. Excel
  Future<void> downloadAsExcel(Report report) async {
    var excel = Excel.createExcel();
    Sheet sheetObject = excel['Sheet1'];
    
    final textContent = utf8.decode(report.data);
    
    // Split by lines and add as rows
    List<String> lines = const LineSplitter().convert(textContent);
    for (var line in lines) {
      List<String> cells = line.split(',');
      sheetObject.appendRow(cells.map((e) => TextCellValue(e.trim())).toList());
    }
    final bytes = excel.encode();
    
    if (bytes != null) {
      // Uses the safe cross-platform downloader
      downloadFile(bytes, "${report.name}.xlsx", "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet");
    }
  }
}