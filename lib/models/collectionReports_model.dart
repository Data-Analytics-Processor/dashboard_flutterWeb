// lib/models/collectionReports_model.dart
class CollectionReport {
  final String id;
  final String institution;
  final String voucherNo;
  final DateTime voucherDate;
  final double amount;
  final String? bankAccount;
  final String? remarks;
  final String partyName;
  final String? salesPromoterName;
  final String? zone;
  final String? district;
  final String? dealerId;
  final int? salesPromoterUserId;
  final String? sourceMessageId;
  final String? sourceFileName;
  final DateTime createdAt;

  CollectionReport({
    required this.id,
    required this.institution,
    required this.voucherNo,
    required this.voucherDate,
    required this.amount,
    this.bankAccount,
    this.remarks,
    required this.partyName,
    this.salesPromoterName,
    this.zone,
    this.district,
    this.dealerId,
    this.salesPromoterUserId,
    this.sourceMessageId,
    this.sourceFileName,
    required this.createdAt,
  });

  factory CollectionReport.fromJson(Map<String, dynamic> json) {
    return CollectionReport(
      id: json['id']?.toString() ?? '',
      institution: json['institution']?.toString() ?? '',
      voucherNo: json['voucherNo']?.toString() ?? '',
      partyName: json['partyName']?.toString() ?? 'Unknown Party',
      
      voucherDate: json['voucherDate'] != null 
          ? DateTime.parse(json['voucherDate']) 
          : DateTime.now(),
      
      createdAt: json['createdAt'] != null 
          ? DateTime.parse(json['createdAt']) 
          : DateTime.now(),
          
      amount: double.tryParse(json['amount'].toString()) ?? 0.0,

      // Nullable fields (Pass through nulls correctly)
      bankAccount: json['bankAccount']?.toString(),
      remarks: json['remarks']?.toString(),
      salesPromoterName: json['salesPromoterName']?.toString(),
      zone: json['zone']?.toString(),
      district: json['district']?.toString(),
      dealerId: json['dealerId']?.toString(),
      salesPromoterUserId: json['salesPromoterUserId'] is int 
          ? json['salesPromoterUserId'] 
          : int.tryParse(json['salesPromoterUserId'].toString()),
      sourceMessageId: json['sourceMessageId']?.toString(),
      sourceFileName: json['sourceFileName']?.toString(),
    );
  }
}