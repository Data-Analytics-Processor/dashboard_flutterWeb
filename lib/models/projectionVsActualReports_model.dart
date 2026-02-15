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
  
  // --- Relations & Joined Fields ---
  final int? verifiedDealerId;
  final int? userId;
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
    this.userName,
    this.verifiedDealerPartyName,
    this.sourceMessageId,
    this.sourceFileName,
    required this.createdAt,
  });

  factory ProjectionVsActualReport.fromJson(Map<String, dynamic> json) {
    // Helper to safely parse doubles from String/Number/Null
    double safeDouble(dynamic val) {
      if (val == null) return 0.0;
      return double.tryParse(val.toString()) ?? 0.0;
    }

    return ProjectionVsActualReport(
      id: json['id']?.toString() ?? '',
      institution: json['institution']?.toString() ?? '',
      zone: json['zone']?.toString() ?? '',
      dealerName: json['dealerName']?.toString() ?? 'Unknown Dealer',
      
      reportDate: json['reportDate'] != null 
          ? DateTime.parse(json['reportDate']) 
          : DateTime.now(),
      
      createdAt: json['createdAt'] != null 
          ? DateTime.parse(json['createdAt']) 
          : DateTime.now(),

      // Nullable Numerics (Converted to Safe Doubles)
      orderProjectionMt: safeDouble(json['orderProjectionMt']),
      actualOrderReceivedMt: safeDouble(json['actualOrderReceivedMt']),
      doDoneMt: safeDouble(json['doDoneMt']),
      projectionVsActualOrderMt: safeDouble(json['projectionVsActualOrderMt']),
      actualOrderVsDoMt: safeDouble(json['actualOrderVsDoMt']),
      collectionProjection: safeDouble(json['collectionProjection']),
      actualCollection: safeDouble(json['actualCollection']),
      shortFall: safeDouble(json['shortFall']),
      percent: safeDouble(json['percent']),
      
      // Relations & Joined Strings
      verifiedDealerId: json['verifiedDealerId'] is int 
          ? json['verifiedDealerId'] 
          : int.tryParse(json['verifiedDealerId']?.toString() ?? ''),
          
      userId: json['userId'] is int 
          ? json['userId'] 
          : int.tryParse(json['userId']?.toString() ?? ''),
          
      userName: json['userName']?.toString(),
      verifiedDealerPartyName: json['verifiedDealerPartyName']?.toString(),

      // Nullable Metadata
      sourceMessageId: json['sourceMessageId']?.toString(),
      sourceFileName: json['sourceFileName']?.toString(),
    );
  }
}