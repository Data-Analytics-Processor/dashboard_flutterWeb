// lib/models/verifiedDealers_model.dart

class VerifiedDealer {
  final int id;
  final String? dealerCode;
  final String? dealerCategory;
  final bool? isSubdealer;
  final String? dealerPartyName;
  final String? zone;
  final String? area;
  final String? contactNo1;
  final String? contactNo2;
  final String? email;
  final String? address;
  final String? pinCode;
  final String? relatedSpName;
  final String? ownerProprietorName;
  final String? natureOfFirm;
  final String? gstNo;
  final String? panNo;

  // Foreign Keys
  final int? userId; // TSO User ID
  final String? dealerId; // System Dealer ID

  // Joined Context Data
  final String? tsoName;
  final String? systemDealerName;

  VerifiedDealer({
    required this.id,
    this.dealerCode,
    this.dealerCategory,
    this.isSubdealer,
    this.dealerPartyName,
    this.zone,
    this.area,
    this.contactNo1,
    this.contactNo2,
    this.email,
    this.address,
    this.pinCode,
    this.relatedSpName,
    this.ownerProprietorName,
    this.natureOfFirm,
    this.gstNo,
    this.panNo,
    this.userId,
    this.dealerId,
    this.tsoName,
    this.systemDealerName,
  });

  factory VerifiedDealer.fromJson(Map<String, dynamic> json) {
    return VerifiedDealer(
      id: json['id'] as int? ?? 0,
      dealerCode: json['dealerCode'] as String?,
      dealerCategory: json['dealerCategory'] as String?,
      isSubdealer: json['isSubdealer'] as bool?,
      dealerPartyName: json['dealerPartyName'] as String?,
      zone: json['zone'] as String?,
      area: json['area'] as String?,
      contactNo1: json['contactNo1'] as String?,
      contactNo2: json['contactNo2'] as String?,
      email: json['email'] as String?,
      address: json['address'] as String?,
      pinCode: json['pinCode'] as String?,
      relatedSpName: json['relatedSpName'] as String?,
      ownerProprietorName: json['ownerProprietorName'] as String?,
      natureOfFirm: json['natureOfFirm'] as String?,
      gstNo: json['gstNo'] as String?,
      panNo: json['panNo'] as String?,
      userId: json['userId'] as int?,
      dealerId: json['dealerId'] as String?,
      tsoName: json['tsoName'] as String?,
      systemDealerName: json['systemDealerName'] as String?,
    );
  }
}