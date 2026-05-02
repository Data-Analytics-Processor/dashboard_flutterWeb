// lib/models/purchase_reports_model.dart
class PurchaseMaterialRow {
  final String materialName;
  final String? vendorName;
  final dynamic amount;
  final String? remarks;

  PurchaseMaterialRow({
    required this.materialName,
    this.vendorName,
    this.amount,
    this.remarks,
  });

  factory PurchaseMaterialRow.fromJson(
    Map<String, dynamic> json,
  ) {
    return PurchaseMaterialRow(
      materialName:
          json['materialName'] ?? '',

      vendorName:
          json['vendorName'],

      amount:
          json['amount'],

      remarks:
          json['remarks'],
    );
  }
}

class PurchaseReportStatusRow {
  final String reportName;
  final String status;

  PurchaseReportStatusRow({
    required this.reportName,
    required this.status,
  });

  factory PurchaseReportStatusRow.fromJson(
    Map<String, dynamic> json,
  ) {
    return PurchaseReportStatusRow(
      reportName:
          json['reportName'] ?? '',

      status:
          json['status'] ?? '',
    );
  }
}

class PurchaseReport {
  final String id;
  final String reportDate;

  final String? sourceFileName;
  final String? sourceMessageId;

  final List<PurchaseMaterialRow>
      dailyMaterials;

  final List<PurchaseMaterialRow>
      monthlyImportantMaterials;

  final List<PurchaseReportStatusRow>
      reportStatus;

  final List<dynamic> parserWarnings;

  final dynamic rawPayload;

  PurchaseReport({
    required this.id,
    required this.reportDate,

    this.sourceFileName,
    this.sourceMessageId,

    required this.dailyMaterials,

    required this
        .monthlyImportantMaterials,

    required this.reportStatus,

    required this.parserWarnings,

    this.rawPayload,
  });

  factory PurchaseReport.fromJson(
    Map<String, dynamic> json,
  ) {
    return PurchaseReport(
      id: json['id'] ?? '',

      reportDate:
          json['reportDate'] ?? '',

      sourceFileName:
          json['sourceFileName'],

      sourceMessageId:
          json['sourceMessageId'],

      dailyMaterials:
          (json['dailyMaterials']
                      as List? ??
                  [])
              .map(
                (e) =>
                    PurchaseMaterialRow
                        .fromJson(
                  Map<String, dynamic>.from(e),
                ),
              )
              .toList(),

      monthlyImportantMaterials:
          (json['monthlyImportantMaterials']
                      as List? ??
                  [])
              .map(
                (e) =>
                    PurchaseMaterialRow
                        .fromJson(
                  Map<String, dynamic>.from(e),
                ),
              )
              .toList(),

      reportStatus:
          (json['reportStatus']
                      as List? ??
                  [])
              .map(
                (e) =>
                    PurchaseReportStatusRow
                        .fromJson(
                  Map<String, dynamic>.from(e),
                ),
              )
              .toList(),

      parserWarnings:
          json['parserWarnings']
                  as List? ??
              [],

      rawPayload:
          json['rawPayload'],
    );
  }
}
