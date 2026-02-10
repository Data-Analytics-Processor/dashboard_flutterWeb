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
      id: json['id'],
      institution: json['institution'],
      voucherNo: json['voucherNo'],
      // Handle date strings from API (ISO 8601)
      voucherDate: DateTime.parse(json['voucherDate']), 
      // Handle Numeric/Decimal types safely
      amount: double.tryParse(json['amount'].toString()) ?? 0.0, 
      bankAccount: json['bankAccount'],
      remarks: json['remarks'],
      partyName: json['partyName'],
      salesPromoterName: json['salesPromoterName'],
      zone: json['zone'],
      district: json['district'],
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