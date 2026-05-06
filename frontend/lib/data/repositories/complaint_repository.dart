import '../datasources/remote/api_client.dart';
import '../../core/constants/api_constants.dart';
import '../models/complaint_model.dart';

class ComplaintRepository {
  final ApiClient _apiClient;

  ComplaintRepository(this._apiClient);

  Future<List<ComplaintModel>> getComplaints() async {
    final response = await _apiClient.dio.get(ApiConstants.complaints);
    final List data = response.data['data'] ?? [];
    return data.map((e) => ComplaintModel.fromJson(e)).toList();
  }

  Future<ComplaintModel> createComplaint({
    required String category,
    required String description,
    required String address,
    required double latitude,
    required double longitude,
  }) async {
    final response = await _apiClient.dio.post(
      ApiConstants.complaints,
      data: {
        'category': category,
        'description': description,
        'address': address,
        'latitude': latitude,
        'longitude': longitude,
      },
    );
    return ComplaintModel.fromJson(response.data['data']);
  }

  Future<ComplaintModel> getDetail(int id) async {
    final response = await _apiClient.dio.get(ApiConstants.complaintDetail(id));
    return ComplaintModel.fromJson(response.data['data']);
  }
}
