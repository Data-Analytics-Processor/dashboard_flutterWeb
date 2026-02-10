// lib/models/projectionReports_model.dart
class ProjectionReport {
  final String id;
  final String institution;
  final DateTime reportDate;
  final String zone;
  final String? orderDealerName;
  final double? orderQtyMt;
  final String? collectionDealerName;
  final double? collectionAmount;
  final String? dealerId;
  final int? salesPromoterUserId;
  final String? sourceMessageId;
  final String? sourceFileName;
  final DateTime createdAt;

  ProjectionReport({
    required this.id,
    required this.institution,
    required this.reportDate,
    required this.zone,
    this.orderDealerName,
    this.orderQtyMt,
    this.collectionDealerName,
    this.collectionAmount,
    this.dealerId,
    this.salesPromoterUserId,
    this.sourceMessageId,
    this.sourceFileName,
    required this.createdAt,
  });

  factory ProjectionReport.fromJson(Map<String, dynamic> json) {
    return ProjectionReport(
      id: json['id'],
      institution: json['institution'],
      // Handle ISO 8601 date strings
      reportDate: DateTime.parse(json['reportDate']),
      zone: json['zone'],
      orderDealerName: json['orderDealerName'],
      // Safely parse numerics (which might come as strings or numbers)
      orderQtyMt: json['orderQtyMt'] != null 
          ? double.tryParse(json['orderQtyMt'].toString()) 
          : null,
      collectionDealerName: json['collectionDealerName'],
      collectionAmount: json['collectionAmount'] != null 
          ? double.tryParse(json['collectionAmount'].toString()) 
          : null,
      dealerId: json['dealerId'],
      salesPromoterUserId: json['salesPromoterUserId'],
      sourceMessageId: json['sourceMessageId'],
      sourceFileName: json['sourceFileName'],
      createdAt: json['createdAt'] != null 
          ? DateTime.parse(json['createdAt']) 
          : DateTime.now(),
    );
  }
}