// lib/models/finance_reports_model.dart

class FinanceRow {
  final String particular;
  final Map<String, dynamic> statuses;
  final String? remarks;

  FinanceRow({required this.particular, required this.statuses, this.remarks});

  factory FinanceRow.fromJson(Map<String, dynamic> json) {
    return FinanceRow(
      particular: json['particular'] ?? '',
      statuses: Map<String, dynamic>.from(json['statuses'] ?? {}),
      remarks: json['remarks'],
    );
  }
}

class FinanceReport {
  final String id;
  final String reportDate;
  final String? institution;
  final String? sourceFileName;
  final String? sourceMessageId;
  final List<String> detectedMonths;
  final List<FinanceRow> plbsStatus;
  final List<FinanceRow> costSheetJSB;
  final List<FinanceRow> costSheetJUD;
  final List<FinanceRow> investorQueries;
  final List<dynamic> parserWarnings;
  final dynamic rawPayload;
  final DateTime? createdAt;

  FinanceReport({
    required this.id,
    required this.reportDate,
    this.institution,
    this.sourceFileName,
    this.sourceMessageId,
    required this.detectedMonths,
    required this.plbsStatus,
    required this.costSheetJSB,
    required this.costSheetJUD,
    required this.investorQueries,
    required this.parserWarnings,
    this.rawPayload,
    this.createdAt,
  });

  factory FinanceReport.fromJson(Map<String, dynamic> json) {
    return FinanceReport(
      id: json['id'] ?? '',
      reportDate: json['reportDate'] ?? '',
      institution: json['institution'],
      sourceFileName: json['sourceFileName'],
      sourceMessageId: json['sourceMessageId'],
      detectedMonths: (json['detectedMonths'] as List? ?? [])
          .map((e) => e.toString())
          .toList(),
      plbsStatus: (json['plbsStatus'] as List? ?? [])
          .map((e) => FinanceRow.fromJson(Map<String, dynamic>.from(e)))
          .toList(),
      costSheetJSB: (json['costSheetJSB'] as List? ?? [])
          .map((e) => FinanceRow.fromJson(Map<String, dynamic>.from(e)))
          .toList(),
      costSheetJUD: (json['costSheetJUD'] as List? ?? [])
          .map((e) => FinanceRow.fromJson(Map<String, dynamic>.from(e)))
          .toList(),
      investorQueries: (json['investorQueries'] as List? ?? [])
          .map((e) => FinanceRow.fromJson(Map<String, dynamic>.from(e)))
          .toList(),
      parserWarnings: json['parserWarnings'] as List? ?? [],
      rawPayload: json['rawPayload'],
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'])
          : null,
    );
  }
}
