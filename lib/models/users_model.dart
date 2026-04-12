class User {
  final String id;
  final String email;
  final String? orgRole;
  final List<String> jobRoles; 
  final List<String> permissions;
  final bool isAdminAppUser;

  User({
    required this.id,
    required this.email,
    this.orgRole,
    this.jobRoles = const [],
    this.permissions = const [],
    this.isAdminAppUser = false,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'].toString(),
      email: json['email'] ?? '',
      orgRole: json['orgRole'],
       jobRoles: json['jobRole'] != null
          ? List<String>.from(json['jobRole'])
          : [],
      permissions: json['permissions'] != null
          ? List<String>.from(json['permissions'])
          : [],
      isAdminAppUser: json['isAdmin'] ?? json['isAdminAppUser'] ?? true, 
    );
  }

  bool hasPermission(String perm) => permissions.contains('ALL_ACCESS') || permissions.contains(perm);
}