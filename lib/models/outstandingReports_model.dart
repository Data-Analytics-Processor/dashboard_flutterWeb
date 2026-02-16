// lib/models/outstandingReports_model.dart

class OutstandingReport {
  final String id;
  final DateTime? reportDate;
  final double securityDepositAmt;
  final double pendingAmt;
  final double lessThan10Days;
  final double days10To15;
  final double days15To21;
  final double days21To30;
  final double days30To45;
  final double days45To60;
  final double days60To75;
  final double days75To90;
  final double greaterThan90Days;
  final bool isOverdue;
  final bool isAccountJsbJud;
  
  // Foreign Keys
  final int? verifiedDealerId;
  final String? collectionReportId;
  final String? dvrId;

  // Joined Context Data
  final String? dealerPartyName; // From Verified Dealer Table
  final String? dealerCode;      // From Verified Dealer Table
  final String? zone;
  
  // 🔥 NEW: Raw Name Fallback (For unmatched rows like "Tripura")
  final String? tempDealerName; 

  final DateTime? createdAt;
  final DateTime? updatedAt;

  OutstandingReport({
    required this.id,
    required this.securityDepositAmt,
    required this.pendingAmt,
    required this.lessThan10Days,
    required this.days10To15,
    required this.days15To21,
    required this.days21To30,
    required this.days30To45,
    required this.days45To60,
    required this.days60To75,
    required this.days75To90,
    required this.greaterThan90Days,
    required this.isOverdue,
    required this.isAccountJsbJud,
    this.reportDate,
    this.verifiedDealerId,
    this.collectionReportId,
    this.dvrId,
    this.dealerPartyName,
    this.dealerCode,
    this.zone,
    this.tempDealerName, // Added to constructor
    this.createdAt,
    this.updatedAt,
  });

  factory OutstandingReport.fromJson(Map<String, dynamic> json) {
    // Helper to safely parse dynamic values to double since Postgres numeric 
    // often comes back as a String in JSON.
    double parseDouble(dynamic value) {
      if (value == null) return 0.0;
      if (value is num) return value.toDouble();
      if (value is String) return double.tryParse(value) ?? 0.0;
      return 0.0;
    }

    return OutstandingReport(
      id: json['id'] as String? ?? '',
      reportDate: json['reportDate'] != null ? DateTime.tryParse(json['reportDate']) : null,
      securityDepositAmt: parseDouble(json['securityDepositAmt']),
      pendingAmt: parseDouble(json['pendingAmt']),
      lessThan10Days: parseDouble(json['lessThan10Days']),
      days10To15: parseDouble(json['days10To15']),
      days15To21: parseDouble(json['days15To21']),
      days21To30: parseDouble(json['days21To30']),
      days30To45: parseDouble(json['days30To45']),
      days45To60: parseDouble(json['days45To60']),
      days60To75: parseDouble(json['days60To75']),
      days75To90: parseDouble(json['days75To90']),
      greaterThan90Days: parseDouble(json['greaterThan90Days']),
      isOverdue: json['isOverdue'] as bool? ?? false,
      isAccountJsbJud: json['isAccountJsbJud'] as bool? ?? false,
      
      verifiedDealerId: json['verifiedDealerId'] as int?,
      collectionReportId: json['collectionReportId'] as String?,
      dvrId: json['dvrId'] as String?,
      
      dealerPartyName: json['dealerPartyName'] as String?,
      dealerCode: json['dealerCode'] as String?,
      zone: json['zone'] as String?,
      
      // 🔥 Match this key to whatever your API sends (e.g., 'temp_dealer_name' or 'tempDealerName')
      tempDealerName: json['tempDealerName'] as String? ?? json['temp_dealer_name'] as String?, 

      createdAt: json['createdAt'] != null ? DateTime.tryParse(json['createdAt']) : null,
      updatedAt: json['updatedAt'] != null ? DateTime.tryParse(json['updatedAt']) : null,
    );
  }
}