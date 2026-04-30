// lib/models/logistics_reports_model.dart

class CementDispatchRow {
  final String area;
  final double? targetDispatchQty;
  final double? achievedDispatchQty;
  final String? remarks;

  CementDispatchRow({
    required this.area,
    this.targetDispatchQty,
    this.achievedDispatchQty,
    this.remarks,
  });

  factory CementDispatchRow.fromJson(Map<String, dynamic> json) {
    return CementDispatchRow(
      area: json['area'] ?? '',
      targetDispatchQty: (json['targetDispatchQty'] as num?)?.toDouble(),
      achievedDispatchQty: (json['achievedDispatchQty'] as num?)?.toDouble(),
      remarks: json['remarks'],
    );
  }
}

class RawMaterialStockRow {
  final String material;
  final String unit;
  final double? jsbClosingStock;
  final double? judClosingStock;
  final double? totalStock;
  final String? remarks;

  RawMaterialStockRow({
    required this.material,
    required this.unit,
    this.jsbClosingStock,
    this.judClosingStock,
    this.totalStock,
    this.remarks,
  });

  factory RawMaterialStockRow.fromJson(Map<String, dynamic> json) {
    return RawMaterialStockRow(
      material: json['material'] ?? '',
      unit: json['unit'] ?? '',
      jsbClosingStock: (json['jsbClosingStock'] as num?)?.toDouble(),
      judClosingStock: (json['judClosingStock'] as num?)?.toDouble(),
      totalStock: (json['totalStock'] as num?)?.toDouble(),
      remarks: json['remarks'],
    );
  }
}

class TransporterPaymentRow {
  final int? serialNo;
  final String transporterName;
  final double? paymentAmount;
  final String? remarks;

  TransporterPaymentRow({
    this.serialNo,
    required this.transporterName,
    this.paymentAmount,
    this.remarks,
  });

  factory TransporterPaymentRow.fromJson(Map<String, dynamic> json) {
    return TransporterPaymentRow(
      serialNo: json['serialNo'],
      transporterName: json['transporterName'] ?? '',
      paymentAmount: (json['paymentAmount'] as num?)?.toDouble(),
      remarks: json['remarks'],
    );
  }
}

class LogisticsReport {
  final String id;
  final String reportDate;
  final String? sourceFileName;
  final String? sourceMessageId;
  final List<CementDispatchRow> cementDispatchData;
  final List<RawMaterialStockRow> rawMaterialStockData;
  final List<TransporterPaymentRow> transporterPaymentData;
  final List<dynamic> parserWarnings;
  final dynamic rawPayload;
  final DateTime? createdAt;

  LogisticsReport({
    required this.id,
    required this.reportDate,
    this.sourceFileName,
    this.sourceMessageId,
    required this.cementDispatchData,
    required this.rawMaterialStockData,
    required this.transporterPaymentData,
    required this.parserWarnings,
    this.rawPayload,
    this.createdAt,
  });

  factory LogisticsReport.fromJson(Map<String, dynamic> json) {
    return LogisticsReport(
      id: json['id'] ?? '',
      reportDate: json['reportDate'] ?? '',
      sourceFileName: json['sourceFileName'],
      sourceMessageId: json['sourceMessageId'],
      cementDispatchData: (json['cementDispatchData'] as List? ?? [])
          .map((e) => CementDispatchRow.fromJson(Map<String, dynamic>.from(e)))
          .toList(),
      rawMaterialStockData: (json['rawMaterialStockData'] as List? ?? [])
          .map(
            (e) => RawMaterialStockRow.fromJson(Map<String, dynamic>.from(e)),
          )
          .toList(),
      transporterPaymentData: (json['transporterPaymentData'] as List? ?? [])
          .map(
            (e) => TransporterPaymentRow.fromJson(Map<String, dynamic>.from(e)),
          )
          .toList(),
      parserWarnings: json['parserWarnings'] as List? ?? [],
      rawPayload: json['rawPayload'],
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'])
          : null,
    );
  }
}
