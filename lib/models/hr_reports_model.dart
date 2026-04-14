// lib/models/hr_reports_model.dart

class HrReport {
  final String id;
  final String reportDate;
  final String? sourceFileName;
  final List<HrVacancy> vacancies;
  final List<HrPerformer> topPerformers; 
  final List<HrPerformer> bottomPerformers; 
  final List<HrInterview> interviews; 

  HrReport({
    required this.id,
    required this.reportDate,
    this.sourceFileName,
    this.vacancies = const [],
    this.topPerformers = const [],
    this.bottomPerformers = const [],
    this.interviews = const [],
  });

  factory HrReport.fromJson(Map<String, dynamic> json) {
    var vacList = json['vacancies'] as List? ?? [];
    var topList = json['topPerformers'] as List? ?? [];
    var bottomList = json['bottomPerformers'] as List? ?? [];
    var intList = json['interviews'] as List? ?? [];

    return HrReport(
      id: json['id']?.toString() ?? '',
      reportDate: json['reportDate']?.toString() ?? 'Unknown Date',
      sourceFileName: json['sourceFileName']?.toString(),
      vacancies: vacList.map((v) => HrVacancy.fromJson(v)).toList(),
      topPerformers: topList.map((p) => HrPerformer.fromJson(p)).toList(),
      bottomPerformers: bottomList.map((p) => HrPerformer.fromJson(p)).toList(),
      interviews: intList.map((i) => HrInterview.fromJson(i)).toList(),
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

class HrInterview {
  final String id;
  final String name;
  final String designation;
  final String department;
  final String dateOfInterview;

  HrInterview({required this.id, required this.name, required this.designation, required this.department, required this.dateOfInterview});

  factory HrInterview.fromJson(Map<String, dynamic> json) => HrInterview(
    id: json['id']?.toString() ?? '',
    name: json['name']?.toString() ?? '',
    designation: json['designation']?.toString() ?? '',
    department: json['department']?.toString() ?? '',
    dateOfInterview: json['dateOfInterview']?.toString() ?? '',
  );
}

class HrPerformer {
  final String id;
  final String name;
  final String designation;
  final String department;

  HrPerformer({required this.id, required this.name, required this.designation, required this.department});

  factory HrPerformer.fromJson(Map<String, dynamic> json) => HrPerformer(
    id: json['id']?.toString() ?? '',
    name: json['name']?.toString() ?? '',
    designation: json['designation']?.toString() ?? '',
    department: json['department']?.toString() ?? '',
  );
}
