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

  final int? salesPromoterUserId;
  final int? verifiedDealerId;
  final int? userId;

  final String? dealerId;
  final String? emailReportId;

  // Optional joined fields (if you SELECT with joins)
  final String? userName;
  final String? dealerPartyName;

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
    this.salesPromoterUserId,
    this.verifiedDealerId,
    this.userId,
    this.dealerId,
    this.emailReportId,
    this.userName,
    this.dealerPartyName,
    this.sourceMessageId,
    this.sourceFileName,
    required this.createdAt,
  });

  factory ProjectionReport.fromJson(Map<String, dynamic> json) {
    double? safeDouble(dynamic val) {
      if (val == null) return null;
      return double.tryParse(val.toString());
    }

    int? safeInt(dynamic val) {
      if (val == null) return null;
      return int.tryParse(val.toString());
    }

    return ProjectionReport(
      id: json['id']?.toString() ?? '',
      institution: json['institution'] ?? '',
      zone: json['zone'] ?? '',

      reportDate: json['report_date'] != null
          ? DateTime.parse(json['report_date'])
          : DateTime.now(),

      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : DateTime.now(),

      orderDealerName: json['order_dealer_name'],
      orderQtyMt: safeDouble(json['order_qty_mt']),

      collectionDealerName: json['collection_dealer_name'],
      collectionAmount: safeDouble(json['collection_amount']),

      salesPromoterUserId: safeInt(json['sales_promoter_user_id']),
      verifiedDealerId: safeInt(json['verified_dealer_id']),
      userId: safeInt(json['user_id']),

      dealerId: json['dealer_id'],
      emailReportId: json['email_report_id'],

      // Joined fields (optional)
      userName: json['user_name'],
      dealerPartyName: json['dealer_party_name'],

      sourceMessageId: json['source_message_id'],
      sourceFileName: json['source_file_name'],
    );
  }
}
