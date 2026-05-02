// lib/models/accounts_reports_model.dart
class AccountsDashboardRow {
  final Map<String, dynamic> values;

  AccountsDashboardRow({
    required this.values,
  });

  factory AccountsDashboardRow.fromJson(
    Map<String, dynamic> json,
  ) {
    return AccountsDashboardRow(
      values: json,
    );
  }
}

class AccountsReport {
  final String id;
  final String reportDate;

  final String? sourceFileName;
  final String? sourceMessageId;

  final List<AccountsDashboardRow>
      accountsDashboardData;

  final List<dynamic> parserWarnings;

  final dynamic rawPayload;

  AccountsReport({
    required this.id,
    required this.reportDate,

    this.sourceFileName,
    this.sourceMessageId,

    required this.accountsDashboardData,

    required this.parserWarnings,

    this.rawPayload,
  });

  factory AccountsReport.fromJson(
    Map<String, dynamic> json,
  ) {
    return AccountsReport(
      id: json['id'] ?? '',

      reportDate:
          json['reportDate'] ?? '',

      sourceFileName:
          json['sourceFileName'],

      sourceMessageId:
          json['sourceMessageId'],

      accountsDashboardData:
          (json['accountsDashboardData']
                      as List? ??
                  [])
              .map(
                (e) =>
                    AccountsDashboardRow
                        .fromJson(
                  Map<String, dynamic>.from(e),
                ),
              )
              .toList(),

      parserWarnings:
          json['parserWarnings']
                  as List? ??
              [],

      rawPayload:
          json['rawPayload'],
    );
  }
}
