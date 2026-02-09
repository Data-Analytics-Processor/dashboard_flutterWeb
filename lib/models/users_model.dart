// lib/models/users_model.dart

class User {
  final int id;
  final String email;
  final String firstName;
  final String lastName;
  final String role;
  final String? phoneNumber;
  final String? region;
  final String? area;
  final String status;
  
  // App Specific Flags
  final String? salesmanLoginId;
  final bool isTechnicalRole;
  final String? techLoginId;
  final bool isAdminAppUser; // <-- NEW
  final String? adminAppLoginId; // <-- NEW
  
  final String? fcmToken;
  final String? deviceId;

  User({
    required this.id,
    required this.email,
    required this.firstName,
    required this.lastName,
    required this.role,
    this.phoneNumber,
    this.region,
    this.area,
    required this.status,
    this.salesmanLoginId,
    this.isTechnicalRole = false,
    this.techLoginId,
    this.isAdminAppUser = false, // <-- NEW
    this.adminAppLoginId,        // <-- NEW
    this.fcmToken,
    this.deviceId,
  });

  // Factory constructor to create a User from JSON
  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] is int ? json['id'] : int.parse(json['id'].toString()),
      email: json['email'] ?? '',
      firstName: json['firstName'] ?? '',
      lastName: json['lastName'] ?? '',
      role: json['role'] ?? 'junior-executive',
      phoneNumber: json['phoneNumber'],
      region: json['region'],
      area: json['area'],
      status: json['status'] ?? 'active',
      
      salesmanLoginId: json['salesmanLoginId'],
      
      isTechnicalRole: json['isTechnicalRole'] == true || json['isTechnicalRole'] == 1,
      techLoginId: json['techLoginId'],
      
      // Handle the new Admin flag safely
      isAdminAppUser: json['isAdminAppUser'] == true || json['isAdminAppUser'] == 1,
      adminAppLoginId: json['adminAppLoginId'],
      
      fcmToken: json['fcmToken'],
      deviceId: json['deviceId'],
    );
  }

  // Method to convert User instance to JSON (for caching/storage)
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'firstName': firstName,
      'lastName': lastName,
      'role': role,
      'phoneNumber': phoneNumber,
      'region': region,
      'area': area,
      'status': status,
      'salesmanLoginId': salesmanLoginId,
      'isTechnicalRole': isTechnicalRole,
      'techLoginId': techLoginId,
      'isAdminAppUser': isAdminAppUser,
      'adminAppLoginId': adminAppLoginId,
      'fcmToken': fcmToken,
      'deviceId': deviceId,
    };
  }

  // Helper copyWith method for updates
  User copyWith({
    String? fcmToken,
    String? deviceId,
  }) {
    return User(
      id: id,
      email: email,
      firstName: firstName,
      lastName: lastName,
      role: role,
      phoneNumber: phoneNumber,
      region: region,
      area: area,
      status: status,
      salesmanLoginId: salesmanLoginId,
      isTechnicalRole: isTechnicalRole,
      techLoginId: techLoginId,
      isAdminAppUser: isAdminAppUser,
      adminAppLoginId: adminAppLoginId,
      fcmToken: fcmToken ?? this.fcmToken,
      deviceId: deviceId ?? this.deviceId,
    );
  }
}