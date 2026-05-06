import '../datasources/remote/api_client.dart';
import '../../core/constants/api_constants.dart';
import '../models/document_model.dart';

class DocumentRepository {
  final ApiClient _apiClient;

  DocumentRepository(this._apiClient);

  Future<List<DocumentModel>> getDocuments() async {
    final response = await _apiClient.dio.get(ApiConstants.documents);
    final List data = response.data['data'] ?? [];
    return data.map((e) => DocumentModel.fromJson(e)).toList();
  }

  Future<DocumentModel> createDocument(String type, Map<String, dynamic> docData) async {
    final response = await _apiClient.dio.post(
      ApiConstants.documents,
      data: {'type': type, 'data': docData},
    );
    return DocumentModel.fromJson(response.data['data']);
  }

  Future<DocumentModel> getStatus(int id) async {
    final response = await _apiClient.dio.get(ApiConstants.documentStatus(id));
    return DocumentModel.fromJson(response.data['data']);
  }
}
