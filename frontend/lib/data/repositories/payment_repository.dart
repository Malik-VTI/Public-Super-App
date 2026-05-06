import '../datasources/remote/api_client.dart';
import '../../core/constants/api_constants.dart';
import '../models/payment_model.dart';

class PaymentRepository {
  final ApiClient _apiClient;

  PaymentRepository(this._apiClient);

  Future<List<PaymentModel>> getBills() async {
    final response = await _apiClient.dio.get(ApiConstants.bills);
    final List data = response.data['data'] ?? [];
    return data.map((e) => PaymentModel.fromJson(e)).toList();
  }

  Future<PaymentModel> processPayment(int billId, String method) async {
    final response = await _apiClient.dio.post(
      ApiConstants.processPayment,
      data: {'bill_id': billId, 'payment_method': method},
    );
    return PaymentModel.fromJson(response.data['data']);
  }

  Future<List<PaymentModel>> getHistory() async {
    final response = await _apiClient.dio.get(ApiConstants.paymentHistory);
    final List data = response.data['data'] ?? [];
    return data.map((e) => PaymentModel.fromJson(e)).toList();
  }
}
