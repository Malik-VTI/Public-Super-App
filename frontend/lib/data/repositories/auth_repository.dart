import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../datasources/remote/api_client.dart';
import '../../core/constants/api_constants.dart';

class AuthRepository {
  final ApiClient _apiClient;

  AuthRepository(this._apiClient);

  Future<String> login(String email, String password) async {
    final response = await _apiClient.dio.post(
      ApiConstants.login,
      data: {'email': email, 'password': password},
    );
    final token = response.data['data']['token'];
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('auth_token', token);
    return token;
  }

  Future<String> biometricLogin(String biometricKey) async {
    final response = await _apiClient.dio.post(
      ApiConstants.biometric,
      data: {'biometric_key': biometricKey},
    );
    final token = response.data['data']['token'];
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('auth_token', token);
    return token;
  }

  Future<void> logout() async {
    try {
      await _apiClient.dio.post(ApiConstants.logout);
    } catch (_) {}
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('auth_token');
  }

  Future<Map<String, dynamic>> getProfile() async {
    final response = await _apiClient.dio.get(ApiConstants.profile);
    return response.data['data'];
  }

  Future<String?> getSavedToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('auth_token');
  }
}
