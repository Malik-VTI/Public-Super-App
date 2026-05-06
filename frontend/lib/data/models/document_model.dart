class DocumentModel {
  final int id;
  final int userId;
  final String type;
  final String status;
  final String? rejectReason;
  final String? data;
  final String? filePath;
  final DateTime createdAt;
  final DateTime updatedAt;

  DocumentModel({
    required this.id,
    required this.userId,
    required this.type,
    required this.status,
    this.rejectReason,
    this.data,
    this.filePath,
    required this.createdAt,
    required this.updatedAt,
  });

  factory DocumentModel.fromJson(Map<String, dynamic> json) {
    return DocumentModel(
      id: json['id'],
      userId: json['user_id'],
      type: json['type'] ?? '',
      status: json['status'] ?? '',
      rejectReason: json['reject_reason'],
      data: json['data'],
      filePath: json['file_path'],
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
    );
  }
}
