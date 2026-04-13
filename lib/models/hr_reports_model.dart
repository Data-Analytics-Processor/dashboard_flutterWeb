// lib/models/hr_reports_model.dart

class HrReport {
  final String id;
  final String reportDate;
  final String? sourceFileName;
  final List<HrVacancy> vacancies;

  HrReport({
    required this.id,
    required this.reportDate,
    this.sourceFileName,
    this.vacancies = const [],
  });

  factory HrReport.fromJson(Map<String, dynamic> json) {
    var vacList = json['vacancies'] as List? ?? [];
    return HrReport(
      id: json['id']?.toString() ?? '',
      reportDate: json['reportDate']?.toString() ?? 'Unknown Date',
      sourceFileName: json['sourceFileName']?.toString(),
      vacancies: vacList.map((v) => HrVacancy.fromJson(v)).toList(),
    );
  }
}

class HrVacancy {
  final String position;
  final String department;
  final int vacantNos;
  final String location;
  final String company;
  final String critical;

  HrVacancy({
    required this.position,
    required this.department,
    required this.vacantNos,
    required this.location,
    required this.company,
    required this.critical,
  });

  factory HrVacancy.fromJson(Map<String, dynamic> json) {
    return HrVacancy(
      position: json['position']?.toString() ?? 'Unknown',
      department: json['department']?.toString() ?? '-',
      vacantNos: int.tryParse(json['vacantNos']?.toString() ?? '0') ?? 0,
      location: json['location']?.toString() ?? '-',
      company: json['company']?.toString() ?? '-',
      critical: json['critical']?.toString() ?? '-',
    );
  }
}