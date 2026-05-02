// lib/models/process_reports_model.dart
class ProcessMetricRow {
  final String parameter;
  final dynamic value;
  final String? unit;
  final String? remarks;

  ProcessMetricRow({
    required this.parameter,
    this.value,
    this.unit,
    this.remarks,
  });

  factory ProcessMetricRow.fromJson(
    Map<String, dynamic> json,
  ) {
    return ProcessMetricRow(
      parameter:
          json['parameter'] ?? '',

      value:
          json['value'],

      unit:
          json['unit'],

      remarks:
          json['remarks'],
    );
  }
}

class TargetAchievementRow {
  final String parameter;

  final dynamic target;
  final dynamic achievement;
  final dynamic variance;

  final String? unit;
  final String? remarks;

  TargetAchievementRow({
    required this.parameter,
    this.target,
    this.achievement,
    this.variance,
    this.unit,
    this.remarks,
  });

  factory TargetAchievementRow.fromJson(
    Map<String, dynamic> json,
  ) {
    return TargetAchievementRow(
      parameter:
          json['parameter'] ?? '',

      target:
          json['target'],

      achievement:
          json['achievement'],

      variance:
          json['variance'],

      unit:
          json['unit'],

      remarks:
          json['remarks'],
    );
  }
}

class ProcessReport {
  final String id;
  final String reportDate;

  final String? sourceFileName;
  final String? sourceMessageId;

  final List<ProcessMetricRow>
      dailyStatusReports;

  final List<ProcessMetricRow>
      closingStock;

  final List<ProcessMetricRow>
      coalConsumption;

  final List<TargetAchievementRow>
      targetAchievement;

  final List<dynamic> parserWarnings;

  final dynamic rawPayload;

  ProcessReport({
    required this.id,
    required this.reportDate,

    this.sourceFileName,
    this.sourceMessageId,

    required this.dailyStatusReports,
    required this.closingStock,
    required this.coalConsumption,
    required this.targetAchievement,

    required this.parserWarnings,

    this.rawPayload,
  });

  factory ProcessReport.fromJson(
    Map<String, dynamic> json,
  ) {
    return ProcessReport(
      id: json['id'] ?? '',

      reportDate:
          json['reportDate'] ?? '',

      sourceFileName:
          json['sourceFileName'],

      sourceMessageId:
          json['sourceMessageId'],

      dailyStatusReports:
          (json['dailyStatusReports']
                      as List? ??
                  [])
              .map(
                (e) =>
                    ProcessMetricRow
                        .fromJson(
                  Map<String, dynamic>.from(e),
                ),
              )
              .toList(),

      closingStock:
          (json['closingStock']
                      as List? ??
                  [])
              .map(
                (e) =>
                    ProcessMetricRow
                        .fromJson(
                  Map<String, dynamic>.from(e),
                ),
              )
              .toList(),

      coalConsumption:
          (json['coalConsumption']
                      as List? ??
                  [])
              .map(
                (e) =>
                    ProcessMetricRow
                        .fromJson(
                  Map<String, dynamic>.from(e),
                ),
              )
              .toList(),

      targetAchievement:
          (json['targetAchievement']
                      as List? ??
                  [])
              .map(
                (e) =>
                    TargetAchievementRow
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
