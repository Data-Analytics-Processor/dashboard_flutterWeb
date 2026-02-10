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
    this.sourceMessageId,
    this.sourceFileName,
    required this.createdAt,
  });

  factory ProjectionVsActualReport.fromJson(Map<String, dynamic> json) {
    // Helper to safely parse doubles from String/Number/Null
    double parseDouble(dynamic value) {
      if (value == null) return 0.0;
      return double.tryParse(value.toString()) ?? 0.0;
    }

    return ProjectionVsActualReport(
      id: json['id'] ?? '',
      reportDate: DateTime.parse(json['reportDate']),
      institution: json['institution'] ?? '',
      zone: json['zone'] ?? '',
      dealerName: json['dealerName'] ?? '',
      
      // Order Metrics
      orderProjectionMt: parseDouble(json['orderProjectionMt']),
      actualOrderReceivedMt: parseDouble(json['actualOrderReceivedMt']),
      doDoneMt: parseDouble(json['doDoneMt']),
      projectionVsActualOrderMt: parseDouble(json['projectionVsActualOrderMt']),
      actualOrderVsDoMt: parseDouble(json['actualOrderVsDoMt']),
      
      // Collection Metrics
      collectionProjection: parseDouble(json['collectionProjection']),
      actualCollection: parseDouble(json['actualCollection']),
      shortFall: parseDouble(json['shortFall']),
      percent: parseDouble(json['percent']),
      
      // Metadata
      sourceMessageId: json['sourceMessageId'],
      sourceFileName: json['sourceFileName'],
      createdAt: json['createdAt'] != null 
          ? DateTime.parse(json['createdAt']) 
          : DateTime.now(),
    );
  }
}