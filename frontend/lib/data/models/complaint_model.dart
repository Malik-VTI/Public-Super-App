class ComplaintModel {
  final int id;
  final int userId;
  final String category;
  final String description;
  final double latitude;
  final double longitude;
  final String address;
  final String? photoPath;
  final String status;
  final DateTime createdAt;

  ComplaintModel({
    required this.id,
    required this.userId,
    required this.category,
    required this.description,
    required this.latitude,
    required this.longitude,
    required this.address,
    this.photoPath,
    required this.status,
    required this.createdAt,
  });

  factory ComplaintModel.fromJson(Map<String, dynamic> json) {
    return ComplaintModel(
      id: json['id'],
      userId: json['user_id'],
      category: json['category'] ?? '',
      description: json['description'] ?? '',
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
      address: json['address'] ?? '',
      photoPath: json['photo_path'],
      status: json['status'] ?? '',
      createdAt: DateTime.parse(json['created_at']),
    );
  }
}
