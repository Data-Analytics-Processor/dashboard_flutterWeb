// lib/models/sales_reports_model.dart

class SalesReport {
  final String id;
  final String reportDate;
  final String? sourceFileName;
  final List<SalesData> salesData;
  final List<CollectionData> collectionData;

  SalesReport({
    required this.id,
    required this.reportDate,
    this.sourceFileName,
    this.salesData = const [],
    this.collectionData = const [],
  });

  factory SalesReport.fromJson(Map<String, dynamic> json) {
    var sList = json['salesDataPayload'] as List? ?? [];
    var cList = json['collectionDataPayload'] as List? ?? [];

    return SalesReport(
      id: json['id']?.toString() ?? '',
      reportDate: json['reportDate']?.toString() ?? 'Unknown Date',
      sourceFileName: json['sourceFileName']?.toString(),
      salesData: sList.map((s) => SalesData.fromJson(s)).toList(),
      collectionData: cList.map((c) => CollectionData.fromJson(c)).toList(),
    );
  }
}

class SalesData {
  final String area;
  final String dealerName;
  final String district;
  final String responsiblePerson;
  final double total;
  final double target;
  final String achievedPercentage;
  final double? avgRequiredPerDay;
  final double? askingRate;
  final Map<String, double> dailySales;

  SalesData({
    required this.area,
    required this.dealerName,
    required this.district,
    required this.responsiblePerson,
    required this.total,
    required this.target,
    required this.achievedPercentage,
    this.avgRequiredPerDay,
    this.askingRate,
    required this.dailySales,
  });

  factory SalesData.fromJson(Map<String, dynamic> json) {
    // Parse the dynamic dailySales map safely
    Map<String, double> parsedDailySales = {};
    if (json['dailySales'] != null && json['dailySales'] is Map) {
      (json['dailySales'] as Map).forEach((key, value) {
        parsedDailySales[key.toString()] = (num.tryParse(value.toString()) ?? 0).toDouble();
      });
    }

    return SalesData(
      area: json['area']?.toString() ?? '-',
      dealerName: json['dealerName']?.toString() ?? 'Unknown',
      district: json['district']?.toString() ?? '-',
      responsiblePerson: json['responsiblePerson']?.toString() ?? '-',
      total: (num.tryParse(json['total']?.toString() ?? '0') ?? 0).toDouble(),
      target: (num.tryParse(json['target']?.toString() ?? '0') ?? 0).toDouble(),
      achievedPercentage: json['achievedPercentage']?.toString() ?? '0%',
      avgRequiredPerDay: (num.tryParse(json['avgRequiredPerDay']?.toString() ?? '0') ?? 0).toDouble(),
      askingRate: (num.tryParse(json['askingRate']?.toString() ?? '0') ?? 0).toDouble(),
      dailySales: parsedDailySales,
    );
  }
}

class CollectionData {
  final String voucherNo;
  final String date;
  final String partyName;
  final String zone;
  final String district;
  final String salesPromoter;
  final double amount;

  CollectionData({
    required this.voucherNo,
    required this.date,
    required this.partyName,
    required this.zone,
    required this.district,
    required this.salesPromoter,
    required this.amount,
  });

  factory CollectionData.fromJson(Map<String, dynamic> json) {
    return CollectionData(
      voucherNo: json['voucherNo']?.toString() ?? 'Unknown',
      date: json['date']?.toString() ?? '-',
      partyName: json['partyName']?.toString() ?? 'Unknown',
      zone: json['zone']?.toString() ?? '-',
      district: json['district']?.toString() ?? '-',
      salesPromoter: json['salesPromoter']?.toString() ?? '-',
      amount: (num.tryParse(json['amount']?.toString() ?? '0') ?? 0).toDouble(),
    );
  }
}

// Model for the Manual Data (Non-Trade Approvals)
class NonTradeApproval {
  final String id;
  final String partyName;
  final String rate;
  final String unit;
  final String status;
  final String submittedAt;

  NonTradeApproval({
    required this.id,
    required this.partyName,
    required this.rate,
    required this.unit,
    required this.status,
    required this.submittedAt,
  });

  factory NonTradeApproval.fromJson(Map<String, dynamic> json) {
    return NonTradeApproval(
      id: json['id']?.toString() ?? '',
      partyName: json['partyName']?.toString() ?? '',
      rate: json['rate']?.toString() ?? '',
      unit: json['unit']?.toString() ?? '',
      status: json['status']?.toString() ?? 'Pending',
      submittedAt: json['submittedAt']?.toString() ?? '',
    );
  }
}