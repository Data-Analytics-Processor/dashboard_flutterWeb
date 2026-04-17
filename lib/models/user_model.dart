class UserModel {
  final int id;
  final String email;
  final String role;
  final String? firstName;
  final String? lastName;
  final String? phoneNumber;
  final int companyId;
  final String? companyName;
  final String? region;
  final String? area;
  final bool isTechnicalRole;
  final String status;
  final int? reportsToId;
  final int? noOfPJP;

  UserModel({
    required this.id,
    required this.email,
    required this.role,
    required this.companyId,
    required this.status,
    this.firstName,
    this.lastName,
    this.phoneNumber,
    this.companyName,
    this.region,
    this.area,
    this.isTechnicalRole = false,
    this.reportsToId,
    this.noOfPJP,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json["id"],
      email: json["email"],
      role: json["role"],
      companyId: json["companyId"],
      status: json["status"],
      firstName: json["firstName"],
      lastName: json["lastName"],
      phoneNumber: json["phoneNumber"],
      companyName: json["companyName"],
      region: json["region"],
      area: json["area"],
      isTechnicalRole: json["isTechnicalRole"] ?? false,
      reportsToId: json["reportsToId"],
      noOfPJP: json["noOfPJP"],
    );
  }

  String get fullName => "${firstName ?? ""} ${lastName ?? ""}".trim();
}
