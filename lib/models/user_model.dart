class UserModel {
  final String id;
  final String name;
  final String email;
  final String role;
  final String? disability;
  final Map<String, dynamic>? assessmentResults;

  UserModel({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
    this.disability,
    this.assessmentResults,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['_id'] ?? json['id'] ?? '',
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      role: json['role'] ?? 'student',
      disability: json['disability'],
      assessmentResults: json['assessmentResults'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'name': name,
      'email': email,
      'role': role,
      'disability': disability,
      'assessmentResults': assessmentResults,
    };
  }
}

