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
    this.userName,
    this.dealerPartyName,
    this.sourceMessageId,
    this.sourceFileName,
    required this.createdAt,
  });

  factory ProjectionReport.fromJson(Map<String, dynamic> json) {
    return ProjectionReport(
      id: json['id']?.toString() ?? '',
      institution: json['institution']?.toString() ?? '',
      zone: json['zone']?.toString() ?? 'Unknown Zone',
      
      reportDate: json['reportDate'] != null 
          ? DateTime.parse(json['reportDate']) 
          : DateTime.now(),
          
      createdAt: json['createdAt'] != null 
          ? DateTime.parse(json['createdAt']) 
          : DateTime.now(),

      // Nullable fields
      orderDealerName: json['orderDealerName']?.toString(),
      orderQtyMt: json['orderQtyMt'] != null 
          ? double.tryParse(json['orderQtyMt'].toString()) 
          : null,
          
      collectionDealerName: json['collectionDealerName']?.toString(),
      collectionAmount: json['collectionAmount'] != null 
          ? double.tryParse(json['collectionAmount'].toString()) 
          : null,
          
      salesPromoterUserId: json['salesPromoterUserId'] is int 
          ? json['salesPromoterUserId'] 
          : int.tryParse(json['salesPromoterUserId']?.toString() ?? ''),
          
      verifiedDealerId: json['verifiedDealerId'] is int 
          ? json['verifiedDealerId'] 
          : int.tryParse(json['verifiedDealerId']?.toString() ?? ''),
          
      userId: json['userId'] is int 
          ? json['userId'] 
          : int.tryParse(json['userId']?.toString() ?? ''),
          
      userName: json['userName']?.toString(),
      dealerPartyName: json['dealerPartyName']?.toString(),
          
      sourceMessageId: json['sourceMessageId']?.toString(),
      sourceFileName: json['sourceFileName']?.toString(),
    );
  }
}