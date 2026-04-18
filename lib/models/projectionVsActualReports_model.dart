// lib/models/projectionVsActualReports_model.dart
class ProjectionVsActualReport {
  final String id;
  final DateTime reportDate;
  final String institution;
  final String zone;
  final String dealerName;

  // --- Order Metrics ---
  final double orderProjectionMt;
  final double actualOrderReceivedMt;
  final double doDoneMt;
  final double projectionVsActualOrderMt;
  final double actualOrderVsDoMt;

  // --- Collection Metrics ---
  final double collectionProjection;
  final double actualCollection;
  final double shortFall;
  final double percent;

  // --- Relations ---
  final int? verifiedDealerId;
  final int? userId;
  final String? dealerId;

  // --- Joined ---
  final String? userName;
  final String? verifiedDealerPartyName;

  // --- Metadata ---
  final String? sourceMessageId;
  final String? sourceFileName;
  final DateTime createdAt;

  ProjectionVsActualReport({
    required this.id,
    required this.reportDate,
    required this.institution,
    required this.zone,
    required this.dealerName,
    required this.orderProjectionMt,
    required this.actualOrderReceivedMt,
    required this.doDoneMt,
    required this.projectionVsActualOrderMt,
    required this.actualOrderVsDoMt,
    required this.collectionProjection,
    required this.actualCollection,
    required this.shortFall,
    required this.percent,
    this.verifiedDealerId,
    this.userId,
    this.dealerId,
    this.userName,
    this.verifiedDealerPartyName,
    this.sourceMessageId,
    this.sourceFileName,
    required this.createdAt,
  });

  factory ProjectionVsActualReport.fromJson(Map<String, dynamic> json) {
    double safeDouble(dynamic val) {
      if (val == null) return 0.0;
      return double.tryParse(val.toString()) ?? 0.0;
    }

    int? safeInt(dynamic val) {
      if (val == null) return null;
      return int.tryParse(val.toString());
    }

    return ProjectionVsActualReport(
      id: json['id']?.toString() ?? '',
      institution: json['institution'] ?? '',
      zone: json['zone'] ?? '',
      dealerName: json['dealer_name'] ?? 'Unknown Dealer',

      reportDate: json['report_date'] != null
          ? DateTime.parse(json['report_date'])
          : DateTime.now(),

      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : DateTime.now(),

      orderProjectionMt: safeDouble(json['order_projection_mt']),
      actualOrderReceivedMt: safeDouble(json['actual_order_received_mt']),
      doDoneMt: safeDouble(json['do_done_mt']),
      projectionVsActualOrderMt: safeDouble(json['projection_vs_actual_order_mt']),
      actualOrderVsDoMt: safeDouble(json['actual_order_vs_do_mt']),

      collectionProjection: safeDouble(json['collection_projection']),
      actualCollection: safeDouble(json['actual_collection']),
      shortFall: safeDouble(json['short_fall']),
      percent: safeDouble(json['percent']),

      verifiedDealerId: safeInt(json['verified_dealer_id']),
      userId: safeInt(json['user_id']),
      dealerId: json['dealer_id'],

      // Joined fields
      userName: json['user_name'],
      verifiedDealerPartyName: json['verified_dealer_party_name'],

      sourceMessageId: json['source_message_id'],
      sourceFileName: json['source_file_name'],
    );
  }
}
