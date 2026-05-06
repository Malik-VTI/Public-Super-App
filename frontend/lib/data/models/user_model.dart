class UserModel {
  final int id;
  final String nik;
  final String fullName;
  final String email;
  final String phone;
  final DateTime createdAt;

  UserModel({
    required this.id,
    required this.nik,
    required this.fullName,
    required this.email,
    required this.phone,
    required this.createdAt,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'],
      nik: json['nik'] ?? '',
      fullName: json['full_name'] ?? '',
      email: json['email'] ?? '',
      phone: json['phone'] ?? '',
      createdAt: DateTime.parse(json['created_at']),
    );
  }
}
